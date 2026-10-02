#!/usr/bin/env python3
"""Gate recursive Solidity control and translate supported semantic fault slots."""
import argparse,gzip,hashlib,importlib.util,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('nav',ROOT/'formal/navigation/generate.py')
nav=importlib.util.module_from_spec(spec);spec.loader.exec_module(nav)

def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Unpinned solc')
    sources={p:(root/p).read_text() for p in ['contracts/Expressions.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol']}
    req={'language':'Solidity','sources':{k:{'content':v} for k,v in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);ast=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in ast.get('errors',[])):raise ValueError('Compiler error')
    contract=next(n for n in ast['sources']['contracts/Expressions.sol']['ast']['nodes'] if n.get('name')=='Expressions')
    functions={n['name']:nav.normalized_form(n) for n in contract['nodes'] if n.get('name') in {'_evaluate','_tryEvaluate','evaluateGuarded'}}
    for n in nav.shape.walk(functions):
        if 'overloadedDeclarations' in n:n['overloadedDeclarations']=['declaration']*len(n['overloadedDeclarations'])
    slots={}
    statements=functions['_evaluate']['body']['statements']
    hit=statements[0]['trueBody']['expression']
    if hit['nodeType']!='IndexAccess':raise ValueError('Cache hit drift')
    index=hit['indexExpression']
    if index.get('name')=='index':slots['HIT_INDEX']='index'
    else:raise ValueError('Unsupported hit index')
    hit['indexExpression']={'slot':'HIT_INDEX'}
    selected=[n for n in nav.shape.walk(functions['_evaluate']) if n.get('nodeType')=='Conditional' and n.get('condition',{}).get('nodeType')=='BinaryOperation']
    if len(selected)!=1:raise ValueError('Select expression drift')
    conditional=selected[0]
    for member,key in [('trueExpression','SELECT_TRUE'),('falseExpression','SELECT_FALSE')]:
        n=conditional[member]
        if n.get('nodeType')!='Literal' or n.get('kind')!='number':raise ValueError('Unsupported branch index')
        slots[key]=str(int(n['value']));conditional[member]={'slot':key}
    call_refs=[n for n in nav.shape.walk(functions['_evaluate']) if n.get('nodeType')=='IndexAccess' and n.get('baseExpression',{}).get('memberName')=='refs' and n.get('indexExpression',{}).get('nodeType')=='BinaryOperation']
    if len(call_refs)!=1:raise ValueError('Call argument reference drift')
    ref=call_refs[0]['indexExpression']
    if ref.get('operator')!='+' or ref['leftExpression'].get('name')!='i' or ref['rightExpression'].get('value') not in {'0','1'}:raise ValueError('Unsupported argument reference')
    slots['CALL_REF_OFFSET']=ref['rightExpression']['value'];ref['rightExpression']={'slot':'CALL_REF_OFFSET'}
    validators=[(i,n) for i,n in enumerate(statements) if n.get('nodeType')=='ExpressionStatement' and n.get('expression',{}).get('nodeType')=='FunctionCall' and n['expression']['expression'].get('memberName')=='validate']
    slots['VALIDATE']='false'
    validation_shape=HERE/'validation.json'
    if validators:
        if len(validators)!=1 or validators[0][0]!=len(statements)-3:raise ValueError('Validation order drift')
        position,node=validators[0]
        if bootstrap:validation_shape.write_text(json.dumps(node,indent=2)+'\n')
        elif node!=json.loads(validation_shape.read_text()):raise ValueError('Validator argument drift')
        slots['VALIDATE']='true';statements.pop(position)
    structure={'functions':functions,'typesAndErrors':[nav.normalized_form(n) for n in contract['nodes'] if n.get('nodeType') in {'StructDefinition','EnumDefinition','ErrorDefinition'}]}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported recursive control AST drift')
    out.mkdir(parents=True,exist_ok=True)
    text=(HERE/'Source.template.dfy').read_text().replace('$HASH',hashlib.sha256(sources['contracts/Expressions.sol'].encode()).hexdigest())
    for key,value in slots.items():text=text.replace('$'+key,value)
    if '$' in text:raise ValueError('Template expansion failed')
    (out/'Source.generated.dfy').write_text(text)
    (out/'mapping.json').write_text(json.dumps({'scope':'Recursive source control under faithful primitive receipts and validation projection; helper payload semantics remain separate','translatedSlots':slots,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
