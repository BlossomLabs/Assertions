#!/usr/bin/env python3
"""Gate raw fold admission and all three public wrappers; extract compiler selectors."""
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
    if kind=='Identifier':return {'n':'k.count','count':'run.count'}[n['name']]
    if kind=='MemberAccess':
        if n['expression'].get('name')=='s' and n['memberName']=='length':return '|k.subject|'
        if n['expression'].get('name')=='FoldDomain':return 'Call.'+n['memberName']
    if kind=='Literal' and n['kind']=='number':return str(int(n['value']))
    if kind=='BinaryOperation' and n['operator'] in {'<','>','<=','>=','==','!=','%','/','+','*'}:
        return '('+expr(n['leftExpression'])+' '+n['operator']+' '+expr(n['rightExpression'])+')'
    raise ValueError('Unsupported entry expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong compiler')
    sources={p:(root/p).read_text() for p in ['contracts/Collections.sol','contracts/lib/AbiCodec.sol']}
    req={'language':'Solidity','sources':{k:{'content':v} for k,v in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in data.get('errors',[])):raise ValueError(data['errors'])
    contract=next(x for x in data['sources']['contracts/Collections.sol']['ast']['nodes'] if x.get('name')=='Collections')
    names={'_fold','foldRange','foldBytes','foldWords'}
    functions={x['name']:form(x) for x in contract['nodes'] if x.get('nodeType')=='FunctionDefinition' and x['name'] in names}
    if set(functions)!=names:raise ValueError('Missing helper')
    slots={};selectors={}
    def slot(node,key,name):slots[name]=expr(node[key]);node[key]={'translated-slot':name}
    for name,prefix in [('foldRange','R'),('foldBytes','B'),('foldWords','W')]:
        f=functions[name];selectors[name]=f['functionSelector']
        args=f['body']['statements'][-1]['expression']['arguments']
        slot(args,0,prefix+'_DOMAIN');slot(args,1,prefix+'_COUNT')
    slot(functions['foldWords']['body']['statements'][0],'condition','UNALIGNED')
    slot(functions['_fold']['body']['statements'][1],'condition','EMPTY')
    error=next(x for x in contract['nodes'] if x.get('nodeType')=='ErrorDefinition' and x['name']=='UnalignedWords')
    functions['UnalignedWords']=form(error);selectors['UnalignedWords']=error['errorSelector']
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(functions,indent=2)+'\n');return
    if functions!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported helper structure')
    code=(HERE/'Source.template.dfy').read_text()
    for key,value in slots.items():code=code.replace('$'+key,value)
    if '$' in code:raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Source.generated.dfy').write_text(code)
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
    selectorCode='// SPDX-License-Identifier: MIT\n// Generated compiler selectors.\ninclude "../../abi/Frames.dfy"\nmodule CollectionsWordFoldEntrySelectors {\n  import opened AbiFrames\n'
    for sourceName,name in [('foldRange','RangeSelector'),('foldBytes','BytesSelector'),('foldWords','WordsSelector'),('UnalignedWords','UnalignedSelector')]:
        selectorCode+='  function '+name+'(): seq<Byte> ensures |'+name+'()| == 4 { ['+','.join(str(x) for x in bytes.fromhex(selectors[sourceName]))+'] }\n'
    selectorCode+='}\n'
    (out/'Selectors.generated.dfy').write_text(selectorCode)
    (out/'mapping.json').write_text(json.dumps({'slots':slots,'selectors':selectors,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
