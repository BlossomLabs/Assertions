#!/usr/bin/env python3
"""Retain exact canonical ConstraintFailed helper connection, with explicit scope."""
import argparse,csv,datetime,hashlib,json,re,shutil
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def main():
    p=argparse.ArgumentParser();p.add_argument('--identity',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    dirs=[HERE/'development'/n for n in ['false-native-consolidated-v2','false-selector-native-consolidated-v1','false-receipts-consolidated-v3','false-mutant-receipts-consolidated-v1','false-selector-negative-consolidated-v1','serialization-generation-consolidated-v1','caller-generation-consolidated-v1']]+[a.identity.resolve()]
    for d in dirs[:2]:
        m=read(d/'manifest.json');assert m['status']=='passed' and m['coverageComplete'] and m['inputsUnchanged'] and m['toolsUnchanged']
        assert all(sha(d/f)==h for f,h in m['evidenceSha256'].items()) and all(sha(ROOT/f)==h for f,h in m['sourceSha256'].items())
        assert all(r['TestResult.Outcome']=='Passed' for r in m['nativeResults']) and all(x['proof']['passed'] and x['audit']['passed'] for x in m['moduleProofs'])
    code=bytes.fromhex(read(ROOT/'artifacts/contracts/Assertions.sol/Assertions.json')['deployedBytecode'][2:]);runtime=hashlib.sha256(code).hexdigest();assert runtime in str(read(a.identity/'identity.json'))
    replay=read(dirs[2]/'full-replay.json');assert replay['status']=='passed' and replay['runtimeSha256']==runtime and replay['instructionCount']==2943 and len(replay['checks'])==15
    assert len(read(dirs[2]/'results.json'))==15 and all(r['passed'] for r in read(dirs[2]/'results.json'))
    assert len(read(dirs[3]/'results.json'))==15 and all(not r['passed'] and 'Independent canonical ConstraintFailed bytes differ' in r['errors'] for r in read(dirs[3]/'results.json'))
    rows=list(csv.DictReader((dirs[4]/'proof.csv').open()));log=(dirs[4]/'proof.log').read_text();assert any(r['TestResult.Outcome']=='Failed' for r in rows) and all(r['TestResult.Outcome'] in ['Passed','Failed'] for r in rows)
    assert 'postcondition could not be proved' in log and not re.search('timed out|inconclusive|resource limit|parse error|resolution error|type error',log,re.I)
    binary=HERE/'development/false-selector-mutant-consolidated-v1.bin';mutant=binary.read_bytes();assert [(i,x,y) for i,(x,y) in enumerate(zip(code,mutant)) if x!=y]==[(8058,0xaf,0xae)] and len(mutant)==len(code)
    for stems,d in [(['Start','Heads','End'],dirs[5]),(['Caller'],dirs[6])]:
        for stem in stems:
            for suffix in ['.generated.dfy','.mapping.json']:assert (HERE/(stem+suffix)).read_bytes()==(d/(stem+suffix)).read_bytes()
    closed=read(dirs[0]/'manifest.json')['includeClosure'];guards=0
    for f in closed:
        for match in re.finditer(r'code\[(\d+)\]\s*==\s*(0x[0-9a-fA-F]+|[0-9]+)',(ROOT/f).read_text()):assert code[int(match[1])]==int(match[2],0);guards+=1
    tools=read(dirs[2]/'toolchain.json');assert tools['nodeVersion']=='v26.10.0'
    for name in ['nodeExecutable','hardhatEntry','edrEntry','nativeBinding']:
        key='nodeSha256' if name=='nodeExecutable' else name+'Sha256';assert sha(Path(tools[name]))==tools[key]
    assert sha(ROOT/'pnpm-lock.yaml')==tools['lockfileSha256']
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    for i,d in enumerate(dirs):shutil.copytree(d,out/'retained'/str(i))
    shutil.copy2(binary,out/binary.name)
    sources=set(HERE.glob('*.dfy'))|set(HERE.glob('*.mapping.json'))|{Path(__file__).resolve(),HERE/'generate-caller-consolidated-v1.py',HERE/'generate-serialization-consolidated-v1.py',HERE/'check-false-replay-consolidated-v1.py',HERE/'evm-false-discovery-consolidated-v2.mjs',HERE.parent/'or/check-structure-replay-consolidated-v1.py'}
    for source in sources:
        dest=out/'source-snapshot'/source.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(source,dest)
    m={'status':'passed','completedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Exact false non-OR validator caller PC8035 through canonical independently specified ConstraintFailed physical REVERT, preserving world frame. Caller discharges selector-bearing serializer heap. Arbitrary admitted assertion/reference byte lengths; explicit input heap/decoded record/resource premises. No decoder/predicate admission or public entry completion credit.','publicEntries':[],'nativeCheckCount':len(read(dirs[0]/'manifest.json')['nativeResults']),'nativeManifestSha256':sha(dirs[0]/'manifest.json'),'selectorManifestSha256':sha(dirs[1]/'manifest.json'),'identityManifestSha256':sha(a.identity/'identity.json'),'runtimeSha256':runtime,'runtimeBytes':len(code),'runtimeGuardCount':guards,'physicalReplay':replay,'mutation':{'pc':8058,'originalByte':175,'mutantByte':174,'nativeFailedCount':sum(r['TestResult.Outcome']=='Failed' for r in rows),'all15CanonicalReceiptsKilled':True,'runtimeSha256':sha(binary)},'sourceSha256':{str(s.relative_to(ROOT)):sha(s) for s in sources},'retainedPaths':{str(i):str(d.relative_to(ROOT)) for i,d in enumerate(dirs)},'authoredProofs':['Blob.generated.dfy is the authored 40-step proof adapter for unaligned destinations. No generator for that authored adapter is claimed. Its complete native declaration closure, exact opcode guards and extracted PC schedule are discharged; Start/Heads/End/Caller generated files reproduce byte-for-byte.'],'assumptions':['Reviewed machine semantics and pinned Dafny/Boogie/Z3 remain trusted. Sufficient reached execution resources and explicit independent caller heap/decoded record premises are required.']}
    m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in out.rglob('*') if f.is_file()};(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');print('passed',m['nativeCheckCount'],'native checks')
if __name__=='__main__':main()
