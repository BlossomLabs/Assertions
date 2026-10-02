#!/usr/bin/env python3
"""Audit complete Assertions source coverage against retained native proof evidence."""
import argparse,hashlib,json,subprocess
from pathlib import Path
if not __debug__:raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inspect(path):
    p=json.loads(path.read_text());assert p['status']=='passed',str(path)
    for name,digest in p['sourceSha256'].items():assert sha(ROOT/name)==digest,('Source drift',name)
    for name,digest in p['evidenceSha256'].items():assert sha(path.parent/name)==digest,('Artifact drift',name)
    proof=next((x for x in p.get('checks',[]) if x.get('name')=='proof'),None)
    native=p.get('nativeResults') if proof is None else proof['nativeResults']
    declarations=p.get('declarationResults') if proof is None else proof['declarations']
    assert native and all(r['TestResult.Outcome']=='Passed' for r in native)
    names={r['TestResult.DisplayName'].split(' (')[0] for r in native}
    for d in declarations:
        if d['kind'] in ['lemma','method']:assert d['status']=='passed' and d['name'] in names,d['name']
    return {d['name']:d for d in declarations}
def main():
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    requirements=json.loads((HERE/'requirements.json').read_text());checked=[];covered=set()
    for item in requirements:
        path=ROOT/item['evidence'];declarations=inspect(path)
        for name in item['theorems']:assert name in declarations and declarations[name]['status']=='passed',name
        covered.update(item.get('sourceFunctions',[]));checked.append({**item,'evidenceSha256':sha(path)})
    names=['contracts/Assertions.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol']
    req={'language':'Solidity','sources':{n:{'content':(ROOT/n).read_text()} for n in names},'settings':{'outputSelection':{'*':{'':['ast'],'*':['abi']}}}}
    proc=subprocess.run([str(a.solc),'--standard-json'],input=json.dumps(req),text=True,capture_output=True,check=True);out=json.loads(proc.stdout)
    assert not any(e['severity']=='error' for e in out.get('errors',[]))
    contract=next(n for n in out['sources'][names[0]]['ast']['nodes'] if n['nodeType']=='ContractDefinition' and n['name']=='Assertions')
    functions=[{'name':n['name'],'visibility':n['visibility'],'inputs':len(n['parameters']['parameters'])} for n in contract['nodes'] if n['nodeType']=='FunctionDefinition']
    assert all(n['name'] for n in functions),'Unmodeled constructor/fallback/receive'
    assert {n['name'] for n in functions}==covered,('Source function coverage mismatch',{n['name'] for n in functions}-covered,covered-{n['name'] for n in functions})
    public=json.loads((ROOT/'formal/core/public-boundary/evidence/seventeen-entrypoints/generation.log').read_text())
    assert public['publicFunctions']==17 and public['explicitFunctions']==15
    result={'status':'passed-under-explicit-premises','sourceSha256':{n:sha(ROOT/n) for n in names},'requirements':checked,'functions':functions,'functionDefinitions':len(functions),'publicEntries':public['abi'],'getters':public['getters'],'scope':'Resource-adequate finite source-frame executions; faithful compiler ABI/decoder/context and reviewed source/memory translation. Complete/TreeFits are required, not guaranteed for every mathematical input. Exact bytecode, physical gas, deployment/performance and other contracts remain separate.'}
    a.output.write_text(json.dumps(result,indent=2)+'\n');print('PASS:',len(functions),'Assertions function definitions, 17 public ABI entries,',len(checked),'requirements')
if __name__=='__main__':main()
