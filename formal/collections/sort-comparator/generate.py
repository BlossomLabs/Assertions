#!/usr/bin/env python3
"""Gate complete sortValues source; lower signed result checking and error context."""
import argparse,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def form(n):
    if isinstance(n,list):return [form(x) for x in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments'}
    return {k:(['compiler-node-id']*len(v) if k=='overloadedDeclarations' else form(v)) for k,v in n.items() if k not in ignored}
def walk(n):
    if isinstance(n,dict):
        yield n
        for v in n.values():yield from walk(v)
    elif isinstance(n,list):
        for v in n:yield from walk(v)
def expr(n):
    k=n['nodeType']
    if k=='Literal' and n['kind'] in {'number','bool'}:return n['value']
    if k=='MemberAccess':
        base=n['expression'].get('name');name=n['memberName']
        if base=='answer' and name=='length':return '|answer|'
        if base=='c' and name in {'a','b'}:return name
        if base=='msg' and name=='sig':return 'operation'
        if base=='cb' and name=='target':return 'target'
    if k=='IndexAccess' and n['baseExpression'].get('name')=='out':return 'values['+expr(n['indexExpression'])+']'
    if k=='BinaryOperation' and n['operator'] in {'==','!=','<','<=','>','>='}:return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    raise ValueError('Unsupported expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong compiler')
    sources={p:(root/p).read_text() for p in ['contracts/Collections.sol','contracts/lib/AbiCodec.sol']}
    req={'language':'Solidity','sources':{k:{'content':v} for k,v in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast'],'*':['abi','evm.methodIdentifiers']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in data.get('errors',[])):raise ValueError(data['errors'])
    contract=next(x for x in data['sources']['contracts/Collections.sol']['ast']['nodes'] if x.get('name')=='Collections')
    f=form(next(x for x in contract['nodes'] if x.get('nodeType')=='FunctionDefinition' and x['name']=='sortValues'))
    nodes=list(walk(f));slots={}
    def slot(n,key,name):slots[name]=expr(n[key]);n[key]={'slot':name}
    invoke=next(x for x in nodes if x.get('nodeType')=='FunctionCall' and x['expression'].get('name')=='_callValue')
    for i,key in [(2,'ARG_A'),(3,'ARG_B'),(4,'BINARY'),(5,'CALL_INDEX'),(6,'CALL_OTHER')]:slot(invoke['arguments'],i,key)
    length=next(x for x in nodes if x.get('nodeType')=='IfStatement' and x['condition'].get('leftExpression',{}).get('expression',{}).get('name')=='answer')
    slot(length,'condition','LENGTH')
    args=length['trueBody']['errorCall']['arguments']
    for i,key in enumerate(['OPERATION','INDEX','OTHER','TARGET']):slot(args,i,key)
    assignment=next(x for x in nodes if x.get('nodeType')=='Assignment' and x['leftHandSide'].get('name')=='takeA')
    cmp=assignment['rightHandSide']
    if cmp['operator'] not in {'<=','<','>=','>','==','!='}:raise ValueError('Unsupported comparator')
    slots['ORDER']=cmp['operator'];cmp['operator']={'slot':'ORDER'}
    slot(cmp,'rightExpression','BOUND')
    call=cmp['leftExpression']['arguments'][0]
    slot(call['arguments'],1,'OFFSET')
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(f,indent=2)+'\n');return
    if f!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported sortValues source drift')
    selector=data['contracts']['contracts/Collections.sol']['Collections']['evm']['methodIdentifiers']['sortValues(string,bytes[],(address,bytes4,string,bytes[],uint256,uint256,bytes))']
    slots['SELECTOR']='['+','.join('0x'+selector[i:i+2] for i in range(0,8,2))+']'
    code=(HERE/'Source.template.dfy').read_text()
    for key,value in slots.items():code=code.replace('$'+key,value)
    if '$' in code:raise ValueError('Unexpanded slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Source.generated.dfy').write_text(code)
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
    (out/'mapping.json').write_text(json.dumps({'slots':slots,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
