#!/usr/bin/env python3
"""Bind successful decoder kernels, complete closures and matching semantic fault."""
import argparse,csv,datetime,hashlib,json,re,shutil
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p): return json.loads(p.read_text())
def main():
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    dev=HERE/'development'
    native=dev/'nonempty-kernel-native-consolidated-v1'
    negative=dev/'nonempty-copy-fault-native-consolidated-v1'
    receipts=dev/'nonempty-receipts-consolidated-v2'
    fault=dev/'nonempty-copy-fault-consolidated-v1'
    generation=dev/'nonempty-kernel-regeneration-consolidated-v1'
    replaypath=dev/'nonempty-item-generation-consolidated-v6/full-decoder-replay.json'
    identity=ROOT/'proof-workspace/work/coordinator-runtime-identity-20261002'
    registry=ROOT/'formal/foundations/registry.json'
    n=read(native/'manifest.json')
    assert n['status']=='passed' and n['coverageComplete'] and n['inputsUnchanged'] and n['toolsUnchanged']
    assert all(sha(native/f)==h for f,h in n['evidenceSha256'].items())
    assert all(sha(ROOT/f)==h for f,h in n['sourceSha256'].items())
    assert all(x['proof']['passed'] and x['audit']['passed'] for x in n['moduleProofs'])
    for x in n['moduleProofs']:
        assert all(d['status'] in ['passed','definition-only'] for d in x['proof']['declarations'])
        assert all(r['TestResult.Outcome']=='Passed' for r in x['proof']['nativeResults'])
    code=bytes.fromhex(read(ROOT/'artifacts/contracts/Assertions.sol/Assertions.json')['deployedBytecode'][2:])
    runtime=hashlib.sha256(code).hexdigest()
    assert runtime in json.dumps(read(identity/'identity.json'))
    replay=read(replaypath);assert replay['status']=='passed' and replay['runtimeSha256']==runtime and replay['instructionCount']==4808 and len(replay['checks'])==8
    for name in ['Start','Item','Exit']:
        for suffix in ['.generated.dfy','.mapping.json']:
            f='Nonempty'+name+suffix;assert (HERE/f).read_bytes()==(generation/name.lower()/f).read_bytes()
        assert replay['mappingSha256'][name]==sha(HERE/f'Nonempty{name}.mapping.json')
    assert all(r['passed'] for r in read(receipts/'results.json'))
    killed=read(fault/'receipts/results.json');assert len(killed)==8 and sum(not r['passed'] for r in killed)==7
    assert killed[0]['name']=='or-mixed-ref-0' and killed[0]['passed'] and killed[0]['errors']==[]
    assert all(not r['passed'] and r['errors']==['Independent flat OR receipt differs'] for r in killed[1:])
    mutant=(fault/'runtime.bin').read_bytes()
    assert [(i,x,y) for i,(x,y) in enumerate(zip(code,mutant)) if x!=y]==[(19755,94,55)] and len(code)==len(mutant)
    neg=read(negative/'manifest.json');assert neg['status']=='failed' and neg['inputsUnchanged'] and neg['toolsUnchanged']
    owners=[x for x in neg['moduleProofs'] if not x['proof']['passed']];assert len(owners)==1 and 'NonemptyCopyWitness.mutant' in owners[0]['file']
    rows=owners[0]['proof']['nativeResults'];assert any(r['TestResult.Outcome']=='Failed' for r in rows) and all(r['TestResult.Outcome'] in ['Passed','Failed'] for r in rows)
    log=(negative/'modules/001/proof.log').read_text();assert 'postcondition could not be proved' in log and not re.search('timed out|inconclusive|resource limit|parse error|resolution error|type error',log,re.I)
    for r in [receipts,fault/'receipts']:
        t=read(r/'toolchain.json');assert t['nodeVersion']=='v26.10.0'
        for key in ['nodeExecutable','hardhatEntry','edrEntry','nativeBinding']:
            assert sha(Path(t[key]))==t['nodeSha256' if key=='nodeExecutable' else key+'Sha256']
        assert sha(ROOT/'pnpm-lock.yaml')==t['lockfileSha256']
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    paths=[native,negative,receipts,fault,generation,identity]
    for i,path in enumerate(paths):shutil.copytree(path,out/'retained'/str(i))
    shutil.copy2(replaypath,out/'full-decoder-replay.json');shutil.copy2(registry,out/'foundation-registry.json')
    sources={Path(__file__).resolve(),HERE/'check-nonempty-decoder-consolidated-v1.py',HERE/'evm-nonempty-discovery-consolidated-v2.mjs',HERE/'generate-nonempty-start-consolidated-v2.py',HERE/'generate-nonempty-item-consolidated-v6.py',HERE/'generate-nonempty-exit-consolidated-v1.py'}
    for s in sources:
        dst=out/'source-snapshot'/s.relative_to(ROOT);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(s,dst)
    m={'status':'passed','completedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Three successful nonempty OR decoder kernels: positive-count allocation Start, arbitrary single child Item and completed-table Exit. Independent input heap, child metadata and finite resources are explicit. No arbitrary child-fill induction, complete decoded table, OR verdict, failure composition or public entry credit.','publicEntries':[],'nativeCheckCount':len(n['nativeResults']),'nativeFiles':len(n['moduleProofs']),'runtimeSha256':runtime,'physicalReplay':replay,'mutation':{'pc':19755,'originalOpcode':'MCOPY','mutantOpcode':'CALLDATACOPY','nativeSemanticPostconditionFailed':True,'physicalPoliciesKilled':7,'physicalPolicySurvivor':'or-mixed-ref-0: empty SKIP succeeds after corrupted EQ fails'},'sourceSha256':{str(s.relative_to(ROOT)):sha(s) for s in sources},'nativeManifestSha256':sha(native/'manifest.json'),'identityManifestSha256':sha(identity/'identity.json'),'foundationRegistrySha256':sha(registry),'retainedPaths':{str(i):str(path.relative_to(ROOT)) for i,path in enumerate(paths)},'assumptions':['Reviewed bytecode machine semantics and pinned native verifier/toolchain remain trusted. Explicit input heap, metadata and sufficient execution resources are required.']}
    m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in out.rglob('*') if f.is_file()};(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');print('PASS',m['nativeCheckCount'],'native checks',m['nativeFiles'],'files')
if __name__=='__main__':main()
