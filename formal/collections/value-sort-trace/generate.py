#!/usr/bin/env python3
"""Gate complete sortValues source; lower observed comparison merge loops."""
import argparse,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def form(n):
    if isinstance(n,list):return [form(x) for x in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments','isSimpleCounterLoop'}
    return {k:(['compiler-node-id']*len(v) if k=='overloadedDeclarations' else form(v)) for k,v in n.items() if k not in ignored}
def walk(n):
    if isinstance(n,dict):
        yield n
        for v in n.values():yield from walk(v)
    elif isinstance(n,list):
        for v in n:yield from walk(v)
def expr(n):
    if n['nodeType']=='Identifier' and n['name'] in {'a','b','middle','end','dest','start','width','count'}:return {'count':'n'}.get(n['name'],n['name'])
    if n['nodeType']=='MemberAccess' and n['expression'].get('name')=='c' and n['memberName'] in {'a','b','middle','end','start','width','n'}:return n['memberName']
    if n['nodeType']=='Literal' and n['kind'] in {'number','bool'}:return n['value']
    if n['nodeType']=='BinaryOperation' and n['operator'] in {'==','!=','<','<=','>','>=','&&','||','+','*'}:return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    raise ValueError('Unsupported expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong compiler')
    sources={p:(root/p).read_text() for p in ['contracts/Collections.sol','contracts/lib/AbiCodec.sol']}
    req={'language':'Solidity','sources':{k:{'content':v} for k,v in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast'],'*':['abi']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in data.get('errors',[])):raise ValueError(data['errors'])
    contract=next(x for x in data['sources']['contracts/Collections.sol']['ast']['nodes'] if x.get('name')=='Collections')
    f=form(next(x for x in contract['nodes'] if x.get('nodeType')=='FunctionDefinition' and x['name']=='sortValues'))
    loops=[x for x in walk(f) if x.get('nodeType')=='ForStatement'];assert len(loops)==4
    inner=loops[3];stmts=inner['body']['statements'];slots={}
    def slot(n,key,name):slots[name]=expr(n[key]);n[key]={'slot':name}
    slot(loops[1],'condition','WIDTH_GUARD');slot(loops[2],'condition','START_GUARD')
    slot(inner,'condition','DEST_GUARD');slot(stmts[0],'initialValue','TAKE_INIT')
    slot(stmts[1],'condition','COMPARE_GUARD');slot(stmts[2],'condition','LEFT_EMPTY')
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(f,indent=2)+'\n');return
    if f!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported sortValues source drift')
    code=(HERE/'Source.template.dfy').read_text()
    for key,value in slots.items():code=code.replace('$'+key,value)
    if '$' in code:raise ValueError('Unexpanded slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Source.generated.dfy').write_text(code)
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
    (out/'mapping.json').write_text(json.dumps({'slots':slots,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
