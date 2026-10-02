#!/usr/bin/env python3
"""Source-check the entire typeShape skeleton and translate selected RHS slots.

Translation trust includes structured-loop normalization, checked arithmetic
outcomes, calldata projection, and ghost syntax accumulation. Unsupported source
changes fail closed; supported arithmetic/boolean faults must reach the verifier.
"""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]

def form(n):
    if isinstance(n,list): return [form(x) for x in n]
    if not isinstance(n,dict): return n
    # Preserve all semantics including assembly, declared types and unchecked
    # blocks; remove compiler identities, source spans and documentation only.
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters',
             'isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType',
             'nativeSrc','externalReferences','documentation','nameLocation','memberLocation','assignments'}
    return {k:form(v) for k,v in n.items() if k not in ignored}

def walk(n):
    if isinstance(n,dict):
        yield n
        for v in n.values(): yield from walk(v)
    elif isinstance(n,list):
        for v in n: yield from walk(v)

def expression(n):
    k=n['nodeType']
    if k=='Literal':
        return n['value'] if n['kind']=='bool' else str(int(n['value'],0))
    if k=='Identifier':
        assert n['name'] in ('k','c','words','sum','w')
        return n['name']
    if k=='TupleExpression':
        assert len(n['components'])==1
        return expression(n['components'][0])
    if k=='BinaryOperation':
        assert n['operator'] in ('+','-','*')
        return '('+expression(n['leftExpression'])+' '+n['operator']+' '+expression(n['rightExpression'])+')'
    raise ValueError('unsupported RHS '+k)

def generate(source,solc):
    assert '0.8.36+commit.8a079791' in subprocess.check_output([str(solc),'--version'],text=True)
    request={'language':'Solidity','sources':{'AbiCodec.sol':{'content':source}},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(request),capture_output=True,text=True,check=True)
    output=json.loads(proc.stdout)
    assert not any(e['severity']=='error' for e in output.get('errors',[]))
    contract=next(n for n in output['sources']['AbiCodec.sol']['ast']['nodes'] if n['nodeType']=='ContractDefinition')
    fs={n['name']:n for n in contract['nodes'] if n['nodeType']=='FunctionDefinition'}
    original=fs['typeShape']; tree=form(original)
    slots={}; assignments=[n for n in walk(tree) if n.get('nodeType')=='Assignment']
    for n in assignments:
        lhs=n['leftHandSide']
        if lhs.get('nodeType')!='Identifier': continue
        name=lhs['name']; rhs=n['rightHandSide']
        slot=None
        if name=='sum':
            assert n['operator']=='+='
            slot='SUM'; slots[slot]='(sum + '+expression(rhs)+')'
        elif name=='k': slot='DIGIT'
        elif name=='words' and rhs.get('nodeType')=='BinaryOperation': slot='PRODUCT'
        elif name=='dyn' and rhs.get('kind')=='bool': slot='TUPLE_DYNAMIC' if 'TUPLE_DYNAMIC' not in slots else 'ARRAY_DYNAMIC'
        if slot:
            if slot not in slots: slots[slot]=expression(rhs)
            n['rightHandSide']={'slot':slot}
    constants={n['name']:form(n) for n in contract['nodes'] if n['nodeType']=='VariableDeclaration' and n['name'] in ('LPAREN','RPAREN','COMMA','LBRACKET','RBRACKET','NAME_BYTES','NAME_STRING')}
    structure={'typeShape':tree,'shape':form(fs['shape']),'byteAt':form(fs['byteAt']),'scanName':form(fs['scanName']),'constants':constants}
    assert structure==json.loads((HERE/'structure.json').read_text()),'Unsupported source skeleton drift'
    assert set(slots)=={'SUM','DIGIT','PRODUCT','TUPLE_DYNAMIC','ARRAY_DYNAMIC'}
    # Values verified in the matched constant AST; permit no hand-entered drift.
    slots.update(BYTES=str(int(constants['NAME_BYTES']['value']['value'],0)),STRING=str(int(constants['NAME_STRING']['value']['value'],0)))
    text=(HERE/'TypeShape.template.dfy').read_text().replace('$HASH',hashlib.sha256(source.encode()).hexdigest())
    for name,value in slots.items(): text=text.replace('$'+name,value)
    assert '$' not in text
    mapping={'sourceSha256':hashlib.sha256(source.encode()).hexdigest(),'functions':{n:{'id':fs[n]['id'],'src':fs[n]['src']} for n in ('typeShape','shape','scanName','byteAt')},'translatedSlots':slots,'scope':'Successful recursive prefix parses imply descriptor grammar, exact byte spelling, dynamic flag and head width. Rejection completeness is not asserted.'}
    return text,mapping,request,output

def main():
    p=argparse.ArgumentParser();p.add_argument('--solc',required=True);p.add_argument('--source',type=Path,default=ROOT/'contracts/lib/AbiCodec.sol');p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    text,mapping,request,output=generate(a.source.read_text(),a.solc)
    a.output.mkdir(parents=True,exist_ok=True)
    (a.output/'TypeShape.generated.dfy').write_text(text)
    (a.output/'mapping.json').write_text(json.dumps(mapping,indent=2)+'\n')
    (a.output/'solc-input.json').write_text(json.dumps(request))
    with gzip.open(a.output/'solc-output.json.gz','wt') as f: json.dump(output,f)

if __name__=='__main__': main()
