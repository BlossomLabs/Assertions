#!/usr/bin/env python3
"""Retain a complete public RAW first-false class only after all gates pass."""
import argparse,hashlib,json,re,shutil,datetime
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def main():
    p=argparse.ArgumentParser();p.add_argument('--native',type=Path,required=True);p.add_argument('--identity',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    native=a.native.resolve();nm=read(native/'manifest.json');assert nm['status']=='passed' and nm['coverageComplete'] and nm['inputsUnchanged'] and nm['toolsUnchanged']
    assert all(sha(native/f)==h for f,h in nm['evidenceSha256'].items()) and all(sha(ROOT/f)==h for f,h in nm['sourceSha256'].items())
    assert all(m['proof']['passed'] and m['audit']['passed'] for m in nm['moduleProofs']) and all(r['TestResult.Outcome']=='Passed' for r in nm['nativeResults'])
    entry='formal/bytecode/assertions-resolution/constrained-raw/public/False.dfy';assert set(nm['entryIncludeClosures'][entry])==set(nm['includeClosure'])
    helper=HERE.parent.parent/'constraints/failed/evidence/false-bound-consolidated-v1';hm=read(helper/'manifest.json');assert hm['status']=='passed' and hm['mutation']['all15CanonicalReceiptsKilled']
    assert all(sha(helper/f)==h for f,h in hm['evidenceSha256'].items()) and all(sha(ROOT/f)==h for f,h in hm['sourceSha256'].items())
    receipts=HERE/'evidence/false-receipts-consolidated-v1';mutants=HERE/'evidence/false-mutant-receipts-consolidated-v1'
    rows=read(receipts/'results.json');assert len(rows)==12 and all(r['passed'] for r in rows)
    mutation=read(mutants/'results.json');assert len(mutation)==12 and all(not r['passed'] and 'Independent canonical ConstraintFailed bytes differ' in r['errors'] for r in mutation)
    replay=read(receipts/'full-replay.json');assert replay['status']=='passed' and len(replay['checks'])==12 and replay['instructionCount']==25668 and all(r['fromPC0'] and r['fullStackMemoryReplay'] for r in replay['checks'])
    code=bytes.fromhex(read(ROOT/'artifacts/contracts/Assertions.sol/Assertions.json')['deployedBytecode'][2:]);runtime=hashlib.sha256(code).hexdigest();assert replay['runtimeSha256']==runtime==hm['runtimeSha256'] and runtime in str(read(a.identity/'identity.json'))
    destinations=set();pc=0
    while pc<len(code):
        op=code[pc]
        if op==91:destinations.add(pc)
        pc+=1+(op-95 if 96<=op<=127 else 0)
    assert read(HERE.parent/'Before.mapping.json')['fullRuntimeDestinations']==sorted(destinations)
    guards=0
    for f in nm['includeClosure']:
        for m in re.finditer(r'code\[(\d+)\]\s*==\s*(0x[0-9a-fA-F]+|[0-9]+)',(ROOT/f).read_text()):assert code[int(m[1])]==int(m[2],0);guards+=1
    for stem in ['Prefix']:
        mapping=read(HERE/(stem+'.mapping.json'));assert mapping['runtimeSha256']==runtime and all(code[int(i)]==v for i,v in mapping['requiredBytes'].items())
    tools=read(receipts/'toolchain.json');assert tools['nodeVersion']=='v26.10.0'
    for name in ['nodeExecutable','hardhatEntry','edrEntry','nativeBinding']:
        key='nodeSha256' if name=='nodeExecutable' else name+'Sha256';assert sha(Path(tools[name]))==tools[key]
    assert sha(ROOT/'pnpm-lock.yaml')==tools['lockfileSha256']
    generation=HERE/'evidence/false-prefix-generation-consolidated-v1'
    for suffix in ['.generated.dfy','.mapping.json']:assert (HERE/('Prefix'+suffix)).read_bytes()==(generation/('Prefix'+suffix)).read_bytes()
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False);dirs=[native,helper,receipts,mutants,a.identity.resolve(),generation]
    for i,d in enumerate(dirs):shutil.copytree(d,out/'retained'/str(i))
    sources={HERE/'generate-prefix-consolidated-v1.py',HERE/'Prefix.mapping.json',HERE/'False.dfy',HERE/'evm-false-consolidated-v1.mjs',HERE/'check-false-replay-consolidated-v1.py',Path(__file__).resolve(),HERE.parent.parent/'constraints/failed/check-false-replay-consolidated-v1.py',HERE.parent.parent/'constraints/or/check-structure-replay-consolidated-v1.py'}
    for source in sources:
        dest=out/'source-snapshot'/source.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(source,dest)
    m={'status':'passed','completedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Complete public resolve RAW class from empty PC0 frame to physical canonical ConstraintFailed REVERT at first false non-OR constraint, after arbitrary successful non-OR prefixes. Independent calldata/word bounds and stated reached-resource limits apply; all in-memory caller premises discharged. Later constraints are not evaluated. This class does not complete the whole resolve ABI entry.','publicEntries':[],'publicClasses':['resolve-raw-first-false-non-or'],'nativeManifestSha256':sha(native/'manifest.json'),'nativeCheckCount':len(nm['nativeResults']),'nativeIncludeFileCount':len(nm['includeClosure']),'helperManifestSha256':sha(helper/'manifest.json'),'identityManifestSha256':sha(a.identity/'identity.json'),'runtimeSha256':runtime,'runtimeBytes':len(code),'runtimeGuardCount':guards,'pushAwareDestinationCount':len(destinations),'physicalReplay':replay,'mutation':hm['mutation']|{'all12PublicCanonicalReceiptsKilled':True},'sourceSha256':{str(s.relative_to(ROOT)):sha(s) for s in sources},'retainedPaths':{str(i):str(d.relative_to(ROOT)) for i,d in enumerate(dirs)},'regenerationReuse':'Fresh Prefix generator reproduces138 reached instructions byte-for-byte. Exact unchanged remaining generated dependency maps/native sources and accepted helper generation receipts retained. All current native dependency hashes match. Fresh entire PC0 physical replay runs on active Node.','assumptions':['Reviewed machine semantics, exact compiler/native EVM and Dafny/Boogie/Z3 remain trusted. Native admission states independent ABI spans, legal RAW fetcher, complete resolved words, first-false predicate policy and explicit finite resource bounds. No opaque caller heap or child trace is assumed at PC0.']}
    m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in out.rglob('*') if f.is_file()};(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');print('passed')
if __name__=='__main__':main()
