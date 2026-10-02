#!/usr/bin/env python3
"""Exercise isolated guarded-dispatch candidate and both missing-check faults."""
import argparse, datetime, hashlib, importlib.util, json, re, shutil, subprocess, sys
from pathlib import Path
import patch
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
spec = importlib.util.spec_from_file_location('common', ROOT / 'formal/constraints/verify.py')
common = importlib.util.module_from_spec(spec); spec.loader.exec_module(common)
sha = common.sha

def main():
    p = argparse.ArgumentParser(); p.add_argument('--output', type=Path, required=True); p.add_argument('--solc', type=Path, required=True); p.add_argument('--dafny',type=Path,required=True); a=p.parse_args()
    out = a.output.resolve(); out.mkdir(parents=True, exist_ok=False)
    forge = Path(shutil.which('forge')); solc = a.solc.resolve()
    dafny=a.dafny.resolve(); solver=dafny.parent/'z3/bin/z3-4.12.1'
    versions = {k: subprocess.check_output([str(v), '--version'], text=True).strip() for k,v in [('forge',forge),('solc',solc)]}
    if '0.8.36+commit.8a079791' not in versions['solc']: raise ValueError('Unpinned solc')
    versions['dafny']=subprocess.check_output([str(dafny),'--version'],text=True).strip()
    versions['solver']=subprocess.check_output([str(solver),'--version'],text=True).strip()
    if versions['dafny']!='4.11.0+fcb2042d6d043a2634f0854338c08feeaaaf4ae2' or '4.12.1' not in versions['solver']:raise ValueError('Unpinned verifier')
    files = [ROOT/'contracts/Expressions.sol', ROOT/'contracts/lib/AbiCodec.sol', ROOT/'contracts/lib/ERC8211.sol', ROOT/'formal/expressions/cache/CacheOracle.t.sol', ROOT/'formal/expressions/admission/AdmissionOracle.t.sol', ROOT/'formal/constraints/verify.py', *[x for x in HERE.iterdir() if x.is_file()]]
    files += [ROOT/p for p in ['formal/navigation/generate.py','formal/abi/shape/generate.py','formal/abi/source/generate.py']]
    original = {str(x.relative_to(ROOT)):sha(x) for x in files}
    m = {'status':'incomplete', 'scope':'Candidate EVM experiment only; production unchanged, no universal source theorem or deployment adoption claimed.', 'sourceSha256':original, 'versions':versions, 'executableSha256':{'forge':sha(forge),'solc':sha(solc)}, 'startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(), 'runs':[]}
    m['scope']='Production guarded dispatch boundary only; no recursive evaluator or exact-bytecode proof claimed.'
    m['assumptions']=['Pinned solc AST and manually reviewed dispatch lowering are trusted.', 'Fixed deployed Expressions code; normal STATICCALL sender/target projection, no delegatecall execution context.', 'Typed memory byte sequences and selector extraction agree with Solidity; sufficient local resources.', 'The theorem restricts admitted guarded entry to the typed helper call site. Validity of caches supplied at that site still requires the recursive evaluator theorem.']
    m['executableSha256'].update({'dafny':sha(dafny),'Dafny.dll':sha(dafny.parent/'Dafny.dll'),'solver':sha(solver)})
    for name, omit, required in [('production',None,[]),('missing-call-check','call',['testCallCannotInjectCache']),('missing-probe-check','probe',['testProbeCannotDispatchGuardedEntry','testProbeCannotDispatchMalformedGuardedEntry'])]:
        run_dir = out/name; snap = run_dir/'source-snapshot'; snap.mkdir(parents=True)
        for f in files:
            dest=snap/f.relative_to(ROOT); dest.parent.mkdir(parents=True, exist_ok=True); shutil.copy2(f,dest)
        source=snap/'contracts/Expressions.sol'; source.write_text(patch.apply(source.read_text(),omit))
        generated=run_dir/'generated'
        gate=common.run([sys.executable,'-B',snap/HERE.relative_to(ROOT)/'generate.py','--solc',solc,'--root',snap,'--output',generated],run_dir/'source-gate.log')
        if gate['exitCode']!=0:raise ValueError('Source gate failed; not a semantic fault result')
        proof=common.run(common.proof_command(dafny,generated/'Source.generated.dfy',run_dir/'proof.csv'),run_dir/'proof.log')
        declarations=[]
        for f in generated.glob('*.dfy'):
            txt=f.read_text();module=re.search(r'^module (\w+)',txt,re.M)[1]
            declarations += [{'name':module+'.'+d[1],'kind':d[0],'file':f.name} for d in re.findall(r'^  (lemma|method|function|predicate|type) (\w+)(?:\(| =)',txt,re.M)]
        common.check_proof(proof,run_dir/'proof.log',run_dir/'proof.csv',declarations)
        if required:
            txt=(run_dir/'proof.log').read_text()
            proof['passed']=proof['exitCode']==4 and 'Error:' in txt and any(r['TestResult.DisplayName'].startswith('GuardedDispatchSource.Dispatch ') and r['TestResult.Outcome']!='Passed' for r in proof['nativeResults']) and not re.search(r'parse errors|resolution/type errors|time.?out|inconclusive|resource limit',txt,re.I)
        audit=common.run([dafny,'audit',generated/'Source.generated.dfy'],run_dir/'audit.log')
        audit['passed']=audit['exitCode']==0 and 'auditor completed with 0 findings' in (run_dir/'audit.log').read_text()
        test_dir=snap/'formal/expressions/oracles'; test_dir.mkdir()
        for f in [HERE/'BoundaryOracle.t.sol', ROOT/'formal/expressions/cache/CacheOracle.t.sol', ROOT/'formal/expressions/admission/AdmissionOracle.t.sol']:
            shutil.copy2(f,test_dir/f.name)
        (snap/'foundry.toml').write_text('[profile.default]\nsrc="contracts"\ntest="formal/expressions/oracles"\nsolc='+json.dumps(str(solc))+'\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\n[lint]\nlint_on_build=false\n')
        expected=sorted(re.findall(r'function (test\w+)\(', '\n'.join(f.read_text() for f in test_dir.glob('*.sol'))))
        job=common.run([forge,'test','--root',snap,'-vv'],run_dir/'concrete.log',180)
        log=(run_dir/'concrete.log').read_text()
        passed=sorted(set(re.findall(r'^\[PASS\] (test\w+)\(',log,re.M)))
        failed=sorted(set(re.findall(r'^\[FAIL[^\n]*\] (test\w+)\(',log,re.M)))
        job.update(name=name,expectedTests=expected,passedTests=passed,failedTests=failed,candidateSourceSha256=sha(source))
        job['passed'] = sorted(passed+failed)==expected and bool(expected) and ((job['exitCode']==0 and not failed) if not required else (job['exitCode']==1 and failed==sorted(required)))
        job.update(sourceGate=gate,proof=proof,audit=audit)
        job['passed']=job['passed'] and proof['passed'] and audit['passed']
        m['runs'].append(job)
        shutil.rmtree(snap/'out',ignore_errors=True); shutil.rmtree(snap/'cache',ignore_errors=True)
    m['inputsUnchanged']=original=={str(x.relative_to(ROOT)):sha(x) for x in files}
    m['status']='passed' if m['inputsUnchanged'] and all(j['passed'] for j in m['runs']) else 'failed'
    m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file()}
    (out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    print(json.dumps({k:m[k] for k in ['status','inputsUnchanged']}))
    for j in m['runs']: print(j['name'],j['exitCode'],j['passed'],j['failedTests'])
    raise SystemExit(0 if m['status']=='passed' else 1)

if __name__=='__main__': main()
