#!/usr/bin/env python3
"""Hash-linked acceptance gates for OR structural helper; never public credit."""
import argparse,csv,hashlib,json,re,shutil,datetime
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def main():
    p=argparse.ArgumentParser();p.add_argument('--identity',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    native=HERE/'evidence/structure-native-consolidated-v1';branch=HERE/'evidence/structure-branch-native-consolidated-v1'
    receipts=HERE/'development/structure-receipts-consolidated-v1';mutant=HERE/'development/structure-mutant-receipts-consolidated-v1'
    negative=HERE/'development/structure-branch-negative-consolidated-v1';generated=HERE/'development/structure-generation-consolidated-v1'
    paths=[native,branch,receipts,mutant,negative,generated,a.identity.resolve()]
    for directory in [native,branch]:
        m=read(directory/'manifest.json');assert m['status']=='passed' and m['coverageComplete'] and m['inputsUnchanged'] and m['toolsUnchanged']
        assert all(sha(directory/f)==h for f,h in m['evidenceSha256'].items())
        assert all(sha(ROOT/f)==h for f,h in m['sourceSha256'].items())
        assert all(x['proof']['passed'] and x['audit']['passed'] for x in m['moduleProofs'])
    code=bytes.fromhex(read(ROOT/'artifacts/contracts/Assertions.sol/Assertions.json')['deployedBytecode'][2:]);runtime=hashlib.sha256(code).hexdigest()
    identity=read(a.identity/'identity.json');assert 'Assertions' in str(identity) and runtime in str(identity)
    replay=read(receipts/'full-replay.json');assert replay['status']=='passed' and replay['runtimeSha256']==runtime and replay['instructionCount']==539
    assert all(r['passed'] for r in read(receipts/'results.json'))
    assert any(r['name']=='nested-after-true' and 'Independent flat OR receipt differs' in r['errors'] for r in read(mutant/'results.json'))
    rows=list(csv.DictReader((negative/'proof.csv').open()));log=(negative/'proof.log').read_text()
    assert rows and any(r['TestResult.Outcome']=='Failed' for r in rows) and all(r['TestResult.Outcome'] in ['Passed','Failed'] for r in rows)
    assert 'postcondition could not be proved' in log and not re.search('timed out|inconclusive|resource limit|parse error|resolution error|type error',log,re.I)
    binary=HERE/'development/structure-branch-mutant-consolidated-v1.bin';mutcode=binary.read_bytes();assert len(mutcode)==len(code) and [(i,x,y) for i,(x,y) in enumerate(zip(code,mutcode)) if x!=y]==[(7889,3,1)]
    for name in ['Start','Iteration','Nested','Exit']:
        for suffix in ['.generated.dfy','.mapping.json']:
            f='Structure'+name+suffix;assert (HERE/f).read_bytes()==(generated/f).read_bytes()
    tools=read(receipts/'toolchain.json');assert tools['nodeVersion']=='v26.10.0'
    for name in ['nodeExecutable','hardhatEntry','edrEntry','nativeBinding']:
        key='nodeSha256' if name=='nodeExecutable' else name+'Sha256';assert sha(Path(tools[name]))==tools[key]
    assert sha(ROOT/'pnpm-lock.yaml')==tools['lockfileSha256']
    dest=a.output.resolve();dest.mkdir(parents=True,exist_ok=False)
    for i,path in enumerate(paths):shutil.copytree(path,dest/'retained'/str(i))
    shutil.copy2(binary,dest/binary.name)
    sources={HERE/'Structure.dfy',HERE/'NativeStructureBranch.dfy',Path(__file__).resolve(),HERE/'check-structure-replay-consolidated-v1.py',HERE/'generate-structure-consolidated-v1.py',HERE/'evm-discovery-consolidated-v1.mjs'}
    sources.update(HERE.glob('Structure*.mapping.json'))
    for source in sources:
        to=dest/'source-snapshot'/source.relative_to(ROOT);to.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(source,to)
    m={'status':'passed','completedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Exact arbitrary-length nonempty in-memory OR structural scan with first nested position supplied independently. All prior children non-OR before exit PC7943 or physical InvalidOrConstraint REVERT. Supplied decoded child table, memory/resource premises remain; no nonempty decoder, verdict evaluation, public admission or entry completion credit.','publicEntries':[],
       'nativeManifestSha256':sha(native/'manifest.json'),'nativeCheckCount':len(read(native/'manifest.json')['nativeResults']),'branchManifestSha256':sha(branch/'manifest.json'),'runtimeSha256':runtime,'runtimeBytes':len(code),'physicalReplay':replay,'mutation':{'pc':7889,'originalOpcode':'SUB','mutantOpcode':'ADD','nativeFailedCount':sum(r['TestResult.Outcome']=='Failed' for r in rows),'nestedAfterTrueKilled':True,'runtimeSha256':sha(binary)},'sourceSha256':{str(s.relative_to(ROOT)):sha(s) for s in sources},'identityManifestSha256':sha(a.identity/'identity.json'),'retainedPaths':{str(i):str(path.relative_to(ROOT)) for i,path in enumerate(paths)},'assumptions':['Reviewed machine semantics and pinned Dafny/Boogie/Z3 are trusted. Sufficient reached execution resources and explicit independent in-memory child table are required.'], 'notes':['Historical structural maps carry inaccurate empty-OR scope text; actual native sources and this scope specify structural scan. Generated bytes reproduced exactly without rewriting retained maps.']}
    m['evidenceSha256']={str(f.relative_to(dest)):sha(f) for f in dest.rglob('*') if f.is_file()};(dest/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');print('passed')
if __name__=='__main__':main()
