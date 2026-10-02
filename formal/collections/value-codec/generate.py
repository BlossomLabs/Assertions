#!/usr/bin/env python3
"""Gate complete array codec bodies; lower signed clamps, counts and source indices."""
import argparse,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def form(n):
    if isinstance(n,list):return [form(x) for x in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments','isSimpleCounterLoop'}
    return {k:(['compiler-node-id']*len(v) if k=='overloadedDeclarations' else form(v)) for k,v in n.items() if k not in ignored}
def expr(n):
    kind=n['nodeType']
    if kind=='Identifier':return {'i':'i'}[n['name']]
    if kind=='Literal':return n['value'] if n['kind']=='bool' else str(int(n['value']))
    if kind=='MemberAccess':
        if n['expression'].get('name')=='x' and n['memberName']=='tail':return 'tail'
        if n['expression'].get('name')=='encoded' and n['memberName']=='length':return 'length'
    if kind=='FunctionCall' and n['expression'].get('name')=='word':
        if len(n['arguments'])==2 and n['arguments'][0].get('name')=='encoded' and n['arguments'][1].get('value')=='0':return 'first'
    if kind=='BinaryOperation' and n['operator'] in {'==','!=','+','-','*'}:return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    raise ValueError('Unsupported array codec expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong compiler')
    sources={p:(root/p).read_text() for p in ['contracts/Collections.sol','contracts/lib/AbiCodec.sol']}
    req={'language':'Solidity','sources':{k:{'content':v} for k,v in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in data.get('errors',[])):raise ValueError(data['errors'])
    contract=next(x for x in data['sources']['contracts/Collections.sol']['ast']['nodes'] if x.get('name')=='Collections')
    abi=next(x for x in data['sources']['contracts/lib/AbiCodec.sol']['ast']['nodes'] if x.get('name')=='AbiCodec')
    funcs={n['name']:form(n) for n in contract['nodes'] if n.get('nodeType')=='FunctionDefinition' and n.get('name') in {'packArray','unpackArray'}}
    funcs.update({n['name']:form(n) for n in abi['nodes'] if n.get('nodeType')=='FunctionDefinition' and n.get('name') in {'pack','unpack'}})
    slots={}
    def slot(node,key,name):slots[name]=expr(node[key]);node[key]={'translated-slot':name}
    p=funcs['pack']['body']['statements']
    slot(p[1]['body']['statements'][0]['expression']['arguments'][1],'indexExpression','PACK_VALIDATE')
    slot(p[-1]['expression']['arguments'],3,'ARRAY_MODE')
    u=funcs['unpack']['body']['statements']
    slot(u[2],'condition','FIRST_MISMATCH');slot(u[-1],'condition','TAIL_MISMATCH')
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(funcs,indent=2)+'\n');return
    if funcs!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported array codec structure')
    code=(HERE/'Control.template.dfy').read_text()
    for key,value in slots.items():code=code.replace('$'+key+'$',value)
    if '$' in code:raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text(code)
    for name in ['Pack','Unpack']:(out/(name+'.generated.dfy')).write_text((HERE/(name+'.template.dfy')).read_text())
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
    (out/'mapping.json').write_text(json.dumps({'slots':slots,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
