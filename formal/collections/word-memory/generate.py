#!/usr/bin/env python3
"""Gate the complete memory-word helpers; lower their actual Yul addresses."""
import argparse,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def form(n):
    if isinstance(n,list):return [form(x) for x in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments'}
    return {k:(['compiler-node-id']*len(v) if k=='overloadedDeclarations' else form(v)) for k,v in n.items() if k not in ignored}
def expr(n):
    if n['nodeType']=='YulIdentifier' and n['name'] in {'b','i'}:return {'b':'base','i':'index'}[n['name']]
    if n['nodeType']=='YulLiteral' and n['kind']=='number':return str(int(n['value'],0)) if n['value'].startswith('0x') else str(int(n['value']))
    if n['nodeType']=='YulFunctionCall' and n['functionName']['name'] in {'add','mul'} and len(n['arguments'])==2:
        return 'M.'+{'add':'Add','mul':'Mul'}[n['functionName']['name']]+'('+','.join(expr(x) for x in n['arguments'])+')'
    raise ValueError('Unsupported address expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong compiler')
    sources={p:(root/p).read_text() for p in ['contracts/Collections.sol','contracts/lib/AbiCodec.sol']}
    req={'language':'Solidity','sources':{k:{'content':v} for k,v in sources.items()},'settings':{'evmVersion':'cancun','outputSelection':{'*':{'':['ast']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(e['severity']=='error' for e in data.get('errors',[])):raise ValueError(data['errors'])
    contract=next(x for x in data['sources']['contracts/Collections.sol']['ast']['nodes'] if x.get('name')=='Collections')
    functions={x['name']:form(x) for x in contract['nodes'] if x.get('nodeType')=='FunctionDefinition' and x['name'] in ['_wordAt','_setWord']}
    if set(functions)!={'_wordAt','_setWord'}:raise ValueError('Missing helper')
    slots={}
    for name,f in functions.items():
        statement=f['body']['statements'][0]['AST']['statements'][0]
        call=statement['value'] if name=='_wordAt' else statement['expression']
        slots[name]=expr(call['arguments'][0]);call['arguments'][0]={'address-slot':name}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(functions,indent=2)+'\n');return
    if functions!=json.loads((HERE/'structure.json').read_text()):raise ValueError('Unsupported helper structure')
    code=(HERE/'Source.template.dfy').read_text().replace('$READ',slots['_wordAt']).replace('$WRITE',slots['_setWord'])
    if '$' in code:raise ValueError('Unexpanded source slot')
    out.mkdir(parents=True,exist_ok=True);(out/'Source.generated.dfy').write_text(code)
    (out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0))
    (out/'mapping.json').write_text(json.dumps({'slots':slots,'sourceSha256':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in sources.items()}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
