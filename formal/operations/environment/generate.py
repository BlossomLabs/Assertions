#!/usr/bin/env python3
"""Gate all fifteen public environment bodies and derive primitive observation projections."""
import argparse,copy,gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
SOURCES=['contracts/Operations.sol','contracts/lib/AbiCodec.sol','node_modules/@openzeppelin/contracts/utils/math/Math.sol','node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol','node_modules/@openzeppelin/contracts/utils/Panic.sol']
NAMES={'balance','codeHash','timestamp','blockNumber','chainId','baseFee','prevRandao','coinbase','gasLimit','blobBaseFee','blockHash','origin','gasPrice','blobHash','code'}
def form(n):
    if isinstance(n,list):return [form(x) for x in n]
    if not isinstance(n,dict):return n
    ignored={'id','src','referencedDeclaration','scope','typeDescriptions','functionReturnParameters','isConstant','isLValue','isPure','lValueRequested','argumentTypes','commonType','nativeSrc','externalReferences','documentation','nameLocation','memberLocation','nameLocations','assignments','isSimpleCounterLoop'}
    return {k:form(v) for k,v in n.items() if k not in ignored}
def expr(n):
    if n['nodeType']=='MemberAccess':
        variable=n['expression']['name'];member=n['memberName']
        if variable=='account':return 'M.'+{'balance':'Balance','codehash':'CodeHash','code':'Code'}[member]+'(e,a)'
        if variable in {'block','tx'}:return 'e.'+{'timestamp':'timestamp','number':'blockNumber','chainid':'chainId','basefee':'baseFee','prevrandao':'prevRandao','coinbase':'coinbase','gaslimit':'gasLimit','blobbasefee':'blobBaseFee','origin':'origin','gasprice':'gasPrice'}[member]
    if n['nodeType']=='FunctionCall' and n['expression']['name'] in {'blockhash','blobhash'}:
        if len(n['arguments'])!=1 or n['arguments'][0].get('name') not in {'n','index'}:raise ValueError('Unsupported observation index')
        return 'M.'+{'blockhash':'BlockHash','blobhash':'BlobHash'}[n['expression']['name']]+'(e,a)'
    raise ValueError('Unsupported observation expression '+str(n))
def generate(solc,root,out,bootstrap=False):
    if '0.8.36+commit.8a079791' not in subprocess.check_output([str(solc),'--version'],text=True):raise ValueError('Wrong solc')
    req={'language':'Solidity','sources':{p.replace('node_modules/',''):{'content':(root/p).read_text()} for p in SOURCES},'settings':{'evmVersion':'cancun','optimizer':{'enabled':True,'runs':200},'outputSelection':{'*':{'':['ast'],'*':['abi','evm.methodIdentifiers']}}}}
    proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),capture_output=True,text=True,check=True);data=json.loads(proc.stdout)
    if any(x['severity']=='error' for x in data.get('errors',[])):raise ValueError(data['errors'])
    c=next(x for x in data['sources']['contracts/Operations.sol']['ast']['nodes'] if x.get('name')=='Operations');fs=[x for x in c['nodes'] if x.get('nodeType')=='FunctionDefinition' and x['name'] in NAMES]
    if len(fs)!=15:raise ValueError('Environment inventory')
    structure={};entries=[];code=[]
    for f in fs:
        name=f['name'];ps=f['parameters']['parameters'];types=[x['typeDescriptions']['typeString'] for x in ps];sig=name+'('+','.join(types)+')';body=f['body']['statements']
        if len(body)!=1 or body[0]['nodeType']!='Return':raise ValueError('Unsupported public body '+sig)
        value=expr(body[0]['expression']);gate=copy.deepcopy(f);gate['body']['statements'][0]['expression']={'translated-expression':name};structure[sig]=form(gate)
        if data['contracts']['contracts/Operations.sol']['Operations']['evm']['methodIdentifiers'][sig]!=f['functionSelector']:raise ValueError('Selector disagreement')
        entries.append({'signature':sig,'selector':f['functionSelector'],'symbol':name});code.append('  function '+name+'(e: M.Env'+(', a: int' if ps else '')+'): '+('seq<bv8>' if name=='code' else 'int')+'\n    requires M.Valid(e)'+(' && M.Word(a)' if ps else '')+'\n  { '+value+' }\n')
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(structure,indent=2)+'\n');(HERE/'entries.json').write_text(json.dumps(entries,indent=2)+'\n');return
    if structure!=json.loads((HERE/'structure.json').read_text()) or entries!=json.loads((HERE/'entries.json').read_text()):raise ValueError('Complete environment AST/selector drift')
    out.mkdir(parents=True,exist_ok=True);(out/'Control.generated.dfy').write_text('include "Model.dfy"\nmodule OperationsEnvironmentSource {\n  import M = OperationsEnvironmentModel\n'+'\n'.join(code)+'}\n');(out/'solc-input.json').write_text(json.dumps(req));(out/'solc-output.json.gz').write_bytes(gzip.compress(proc.stdout.encode(),mtime=0));(out/'mapping.json').write_text(json.dumps({'entries':entries,'sourceSha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in SOURCES}},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
