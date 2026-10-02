#!/usr/bin/env python3
"""Bind construction, memory and context models to the complete production AST.

Memory arrays are projected to sequences. MSTORE writes Word(value), and MCOPY
performs byte-exact replacement, under explicit nonwrapping physical-memory and
allocation assumptions. The proofs discharge both object-relative copy spans.
"""
import argparse
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
spec = importlib.util.spec_from_file_location('layout_generator', HERE.parent/'layout/generate.py')
prior = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prior)
shape = prior.shape


def expression(n):
    k = n['nodeType']
    if k == 'Identifier':
        return {'array': 'asArray'}.get(n['name'], n['name'])
    if k == 'Literal':
        return str(int(n['value'], 0))
    if k == 'MemberAccess':
        if n['expression'].get('name') == 'x':
            assert n['memberName'] in ('words','tail')
            return n['memberName']
        if n['expression'].get('name') == 'context':
            assert n['memberName'] in ('index','other','operation','target')
            return 'c.'+n['memberName']
        assert n['memberName'] == 'length'
        return '|'+expression(n['expression'])+'|'
    if k == 'IndexAccess':
        return expression(n['baseExpression'])+'['+expression(n['indexExpression'])+']'
    if k == 'Conditional':
        return '(if '+expression(n['condition'])+' then '+expression(n['trueExpression'])+' else '+expression(n['falseExpression'])+')'
    assert k == 'BinaryOperation' and n['operator'] in ('+', '-', '*')
    return '('+expression(n['leftExpression'])+' '+n['operator']+' '+expression(n['rightExpression'])+')'


def context_audit(contract):
    """Context cannot alter any validator decision or arithmetic.

    Every context use outside requireValue is a bare argument forwarded to a
    known context-aware callee. There are no writes to it. Consequently the
    Value-context trace is identical until a failing requireValue; only its
    terminal error constructor changes. Parser errors and panics are untouched.
    """
    checked = []
    names = {'checkWords', 'checkRule', 'word', 'validate', 'validateStatic', 'validateDynamic', 'body'}
    for f in contract['nodes']:
        if f.get('nodeType') != 'FunctionDefinition' or f['name'] not in names:
            continue
        if not any(p['name'] == 'context' for p in f['parameters']['parameters']):
            continue
        uses = []
        def walk(n, parent=None):
            if isinstance(n, dict):
                if n.get('nodeType') == 'Identifier' and n.get('name') == 'context':
                    assert parent and parent['nodeType'] == 'FunctionCall'
                    callee = parent['expression']
                    assert callee['nodeType'] == 'Identifier' and callee['name'] in names | {'requireValue'}
                    assert parent['arguments'][-1] is n
                    uses.append(callee['name'])
                for v in n.values():
                    if isinstance(v, list):
                        for child in v: walk(child, n)
                    elif isinstance(v, dict): walk(v, n)
        walk(f['body'])
        assert uses
        checked.append({'function': f['name'], 'id': f['id'], 'calls': uses})
    assert {r['function'] for r in checked} == names
    return checked


def generate(source, solc, bootstrap=False, context_only=False):
    if context_only:
        # Isolate requireValue for its mutation proof. The older bytes/string
        # translator intentionally pins that entire helper to the Value-only
        # version; it cannot translate a changed non-Value error field. This
        # mode compiles the actual AST and emits ONLY the independently gated
        # context helper, never a whole-validator correspondence program.
        *_, request, output = shape.generate(source, solc)
    else:
        *_, request, output = prior.generate(source, solc)
    contract = next(n for n in output['sources']['AbiCodec.sol']['ast']['nodes'] if n['nodeType']=='ContractDefinition')
    fs = [n for n in contract['nodes'] if n['nodeType']=='FunctionDefinition']
    names = {'copy','store','slice','requireValue','validate','validateComponent','tuple','isDynamic','assemble','pack','unpack'}
    structure = {'functions': [shape.form(f) for f in fs if f['name'] in names],
                 'context': [shape.form(n) for n in contract['nodes'] if n.get('name') in ('ContextKind','Context')]}
    assembly = next(f for f in structure['functions'] if f['name']=='assemble')
    slots = {}
    # Solc serializes falseBody before trueBody. Bind semantic branches by
    # their AST fields, never by generic dictionary traversal order.
    for branch in shape.walk(assembly):
        if branch.get('nodeType')!='IfStatement' or not branch.get('falseBody'):continue
        assert branch['condition'].get('nodeType')=='IndexAccess'
        assert branch['condition']['baseExpression'].get('name')=='dynamic'
        for body,key in ((branch['trueBody'],'HEAD_DYNAMIC'),(branch['falseBody'],'HEAD_STATIC')):
            updates=[n for n in shape.walk(body) if n.get('nodeType')=='Assignment' and n['leftHandSide'].get('name')=='head']
            assert len(updates)==1
            n=updates[0];assert n['operator'] in ('+=','-=')
            slots[key]='(head '+n['operator'][0]+' '+expression(n['rightHandSide'])+')'
            n['operator']='$'+key;n['rightHandSide']={'slot':key}
    for n in shape.walk(assembly):
        if n.get('nodeType') == 'VariableDeclarationStatement' and n['declarations'][0].get('name') == 'prefix':
            slots['PREFIX'] = expression(n['initialValue']); n['initialValue'] = {'slot':'PREFIX'}
        if n.get('nodeType') != 'Assignment': continue
        lhs = n['leftHandSide']
        if lhs.get('nodeType') != 'Identifier' or lhs['name'] not in ('size','tail'): continue
        assert n['operator'] in ('+=','-=')
        key = {'size':'SIZE_STEP','tail':'TAIL_STEP'}.get(lhs['name'])
        slots[key] = '('+lhs['name']+' '+n['operator'][0]+' '+expression(n['rightHandSide'])+')'
        n['operator'] = '$'+key; n['rightHandSide'] = {'slot':key}
    require_value = next(f for f in structure['functions'] if f['name']=='requireValue')
    for n in shape.walk(require_value):
        if n.get('nodeType')=='RevertStatement' and n['errorCall']['expression'].get('name')=='InvalidComponentValue':
            args = n['errorCall']['arguments']
            slots['ROUTE_INDEX'] = expression(args[0]); args[0] = {'slot':'ROUTE_INDEX'}
    component = next(f for f in structure['functions'] if f['name']=='validateComponent')
    products = 0
    for n in shape.walk(component):
        if n.get('nodeType')=='BinaryOperation' and n['leftExpression'].get('name')=='words':
            value = expression(n)
            assert 'COMPONENT_BYTES' not in slots or slots['COMPONENT_BYTES']==value
            slots['COMPONENT_BYTES']=value;products+=1
            n.clear(); n.update({'slot':'COMPONENT_BYTES'})
    assert products==2
    unpack = next(f for f in structure['functions'] if f['name']=='unpack')
    for n in shape.walk(unpack):
        if n.get('nodeType')=='FunctionCall' and n['expression'].get('name')=='slice' and n['arguments'][1].get('name')=='p':
            slots['UNPACK_WIDTH']=expression(n['arguments'][2]);n['arguments'][2]={'slot':'UNPACK_WIDTH'}
    if bootstrap: return structure
    assert structure == json.loads((HERE/'structure.json').read_text()), 'Unsupported construction source drift'
    assert set(slots)=={'PREFIX','SIZE_STEP','TAIL_STEP','HEAD_DYNAMIC','HEAD_STATIC','ROUTE_INDEX','COMPONENT_BYTES','UNPACK_WIDTH'}
    digest = hashlib.sha256(source.encode()).hexdigest()
    texts = {}
    for name in (('Context',) if context_only else ('Assembly','Context','Component','Tuple','Pack','Unpack')):
        text = (HERE/(name+'.template.dfy')).read_text().replace('$HASH',digest)
        for key,value in slots.items():text=text.replace('$'+key,value)
        assert '$' not in text
        texts[name+'.generated.dfy'] = text
    mapping = {'sourceSha256':digest, 'translatedSlots':slots, 'contextForwarding':context_audit(contract),
      'scope':'Isolated requireValue helper only; no whole-validator claim.' if context_only else 'Full construction connection with all inherited source gates.',
      'functions': {f['name']+':'+str(f['id']):f['src'] for f in fs if f['name'] in names},
      'normalizations':[
        'Solidity memory bytes are bounded byte sequences; fresh allocations are zero initialized. Memory.dfy proves exact MCOPY/MSTORE projection and slice guards under the stated physical layout and allocation assumptions.',
        'Assembly loops preserve source branch order, indexing, stores and copies. Source arithmetic RHS expressions are translated; invariants prove every intermediate fits uint256 under the output representability premise.',
        'Context forwarding is structurally audited at every identifier use. It cannot affect decisions or arithmetic; requireValue selects the exact error fields. Routes preserve parser failures and panics.',
        'Component validation retains envelope and static footprint checks, including checked multiplication panic for unusually wide static tuples. Cached validation requires a matching descriptor shape.'
      ]}
    return texts,mapping,request,output


def main():
    p=argparse.ArgumentParser();p.add_argument('--solc',required=True);p.add_argument('--source',type=Path,default=ROOT/'contracts/lib/AbiCodec.sol');p.add_argument('--output',type=Path,required=True)
    p.add_argument('--context-only',action='store_true',help='Emit only the independently gated requireValue helper for an isolated mutation check')
    a=p.parse_args()
    texts,mapping,request,output=generate(a.source.read_text(),a.solc,context_only=a.context_only)
    a.output.mkdir(parents=True,exist_ok=True)
    for name,text in texts.items(): (a.output/name).write_text(text)
    (a.output/'mapping.json').write_text(json.dumps(mapping,indent=2)+'\n')
    (a.output/'solc-input.json').write_text(json.dumps(request))
    with gzip.open(a.output/'solc-output.json.gz','wt') as stream:json.dump(output,stream)

if __name__=='__main__': main()
