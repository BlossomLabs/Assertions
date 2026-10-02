#!/usr/bin/env python3
"""Recheck retained exact word-entry evidence; does not replace native proofs."""
import csv, hashlib, importlib.util, json, re, subprocess, sys, tempfile
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def require(ok, message):
    if not ok: raise SystemExit(message)
def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec); spec.loader.exec_module(result); return result

def check(ledger_name):
    ledger = json.loads((ROOT / 'docs/verification' / ledger_name).read_text())
    path = ROOT / ledger['baseline']; out = path.parent
    require(sha(path) == ledger['baselineSha256'], 'Manifest drift')
    m = json.loads(path.read_text()); package = ROOT / ledger['package']
    v = load('word_entry_verify', package / 'verify.py')
    require(m['status'] == 'passed' and all(m[k] for k in ['inputsUnchanged', 'dependenciesUnchanged', 'toolsUnchanged', 'concreteToolsUnchanged', 'regenerationPassed']) and all(j['passed'] for j in m['checks']), 'Incomplete retained evidence')
    require(m['publicEntries'] == ledger['publicEntries'] and m['assumptions'] == ledger['assumptions'], 'Scope drift')
    require({str(p.relative_to(ROOT)): sha(p) for p in v.inputs()} == m['sourceSha256'], 'Current source/input inventory drift')
    for name, digest in m['sourceSha256'].items():
        require(sha(out / 'source-snapshot' / name) == digest, 'Snapshot drift ' + name)
    for name, digest in m['evidenceSha256'].items(): require(sha(out / name) == digest, 'Evidence drift ' + name)
    require(v.dependency_hashes() == m['dependencyEvidenceSha256'], 'Retained dependency drift')
    graph = v.graph()
    require({str(p.relative_to(ROOT)): sha(p) for p in graph} == m['dependencyGraph'] and m['rootProof'] == str(v.PROOF.relative_to(ROOT)), 'Proof graph drift')
    rows, declarations = [], []
    jobs = {j['name']: j for j in m['checks']}
    for source in graph:
        mod = re.search(r'^module (\w+)', source.read_text(), re.M)[1]; name = 'proof-' + mod; job = jobs[name]
        require(all(flag in job['command'] for flag in ['--verify-included-files', '--manual-lemma-induction', '--isolate-assertions']) and '--filter-position' not in job['command'] and job['command'][job['command'].index('--filter-symbol')+1] == mod, 'Incomplete native coverage ' + mod)
        fresh = dict(job)
        v.common.check_proof(fresh, out / (name + '.log'), out / (name + '.csv'), v.getter.inventory(source))
        require(fresh['passed'] and fresh['nativeResults'] == job['nativeResults'] and fresh['declarations'] == job['declarations'], 'Native inventory drift ' + mod)
        rows += job['nativeResults']; declarations += job['declarations']
    require(rows == m['nativeResults'] and declarations == m['declarationResults'] and len(rows) == m['nativeObligations'] == ledger['nativeObligations'] and len(declarations) == ledger['nativeDeclarations'], 'Aggregate proof drift')
    proved = {d['name'] for d in declarations if d['status'] == 'passed'}
    require(all(t in proved for t in ledger['connections']), 'Unproved connection')
    require('auditor completed with 0 findings' in (out / 'audit.log').read_text(), 'Audit findings')
    receipts = json.loads((out / 'evm-traces/results.json').read_text())
    require(len(receipts) == ledger['concreteFixtures'] and {r['name'] for r in receipts} == set(ledger['fixtureNames']), 'Concrete fixture inventory drift')
    for r in receipts:
        t = json.loads((out / 'evm-traces' / r['trace']).read_text()); trace = t['trace']; logs = trace['structLogs']
        require(r['passed'] and r['receiptPassed'] and not t['candidate'] and trace['failed'] == r['expectedFailed'] and trace['returnValue'].removeprefix('0x') == r['expectedBytes'], 'Incorrect complete receipt')
        require(logs[0]['pc'] == 0 and all(s['depth'] == 1 for s in logs), 'Incomplete physical trace')
        last = logs[-1]; off, size = int(last['stack'][-1],16), int(last['stack'][-2],16)
        memory = ''.join(w.removeprefix('0x') for w in last['memory'])
        require(last['op'] == ('REVERT' if trace['failed'] else 'RETURN') and size == len(r['expectedBytes'])//2 and memory[off*2:(off+size)*2] == r['expectedBytes'], 'Physical final slice differs')
    faults = json.loads((out / 'mutations/results.json').read_text())
    require(len(faults) == ledger['semanticBytecodeFaults'] and {f['candidate']['name'] for f in faults} == set(ledger['faultNames']), 'Fault inventory drift')
    base = bytes.fromhex(json.loads((ROOT / 'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:])
    for fault in faults:
        c = fault['candidate']; candidate = (out / 'candidates' / c['runtime']).read_bytes()
        require(hashlib.sha256(candidate).hexdigest() == c['runtimeSha256'] and c['baselineRuntimeSha256'] == hashlib.sha256(base).hexdigest() and len(candidate) == len(base) and [(i,a,b) for i,(a,b) in enumerate(zip(base,candidate)) if a != b] == [(c['byteOffset'],c['before'],c['after'])], 'Binary fault drift')
        require(fault['baselineCoveredSymbol'] == c['nativeSymbol'] and c['nativeSymbol'] in proved and all(j['passed'] for j in fault['checks']), 'Fault closure drift')
        native = fault['checks'][1]; text = (out / native['log']).read_text(); native_rows = list(csv.DictReader((out / 'mutations' / c['name'] / 'proof.csv').open()))
        require(native['exitCode'] not in [0,None] and any(r['TestResult.Outcome'] == 'Failed' for r in native_rows) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in native_rows) and 'postcondition could not be proved' in text and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call', text, re.I), 'Non-semantic fault result')
        require(len(fault['contradictoryReceipts']) == 1, 'Missing concrete counterexample')
        r = fault['contradictoryReceipts'][0]; t = json.loads((out / 'mutations' / c['name'] / 'evm-traces' / r['trace']).read_text())
        require(t['candidate'] and t['runtimeSha256'] == c['runtimeSha256'] and not r['receiptPassed'] and r['name'] == c['evmFixture'] and (t['trace']['failed'] != r['expectedFailed'] or t['trace']['returnValue'].removeprefix('0x') != r['expectedBytes']), 'False EVM counterexample')
    dafny = Path(next(j for j in m['checks'] if j['name'].startswith('proof-'))['command'][0]); solc = Path(jobs['runtime-identity']['command'][4])
    for key, p in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',dafny.parent/'z3/bin/z3-4.12.1'),('solc',solc)]: require(sha(p) == m['executableSha256'][key], 'Proof tool drift ' + key)
    ct = m['concreteToolchain']
    for key in ['hardhatEntry','edrEntry','nativeBinding']: require(sha(Path(ct[key])) == ct[key+'Sha256'], 'Concrete tool drift')
    require(sha(Path(ct['nodeExecutable'])) == ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml') == ct['lockfileSha256'], 'Node/lockfile drift')
    with tempfile.TemporaryDirectory(prefix='unzip-entry-check-') as folder:
        dest = Path(folder)
        require(m['generatorGroups'] == ledger['generatorGroups'] == json.loads(json.dumps(v.GENERATOR_GROUPS)), 'Generator group drift')
        for name, scripts in v.GENERATOR_GROUPS:
            source = ROOT / 'formal/bytecode' / name
            generated = dest / name; generated.mkdir(parents=True)
            for gen in scripts:
                subprocess.run([sys.executable,'-B',source/gen,'--output',generated],check=True,stdout=subprocess.DEVNULL)
            expected = {p.name for p in source.iterdir() if p.name.endswith(('.generated.dfy','.mapping.json'))}
            require(expected == {p.name for p in generated.iterdir()} and all((generated/n).read_bytes() == (source/n).read_bytes() for n in expected), 'Current generation drift ' + name)
        subprocess.run([sys.executable,'-B',package/'make-candidates.py','--output',dest/'candidates'],check=True,stdout=subprocess.DEVNULL)
        require((dest/'candidates/candidates.json').read_bytes() == (out/'candidates/candidates.json').read_bytes(), 'Current candidate inventory drift')
        for f in faults: require((dest/'candidates'/f['candidate']['runtime']).read_bytes() == (out/'candidates'/f['candidate']['runtime']).read_bytes(), 'Current fault generation drift')
        subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/dispatch/identity.py','--solc',solc,'--output',dest/'identity'],check=True,stdout=subprocess.DEVNULL)
        require((dest/'identity/identity.json').read_bytes() == (out/'identity/identity.json').read_bytes(), 'Current exact runtime identity differs')
        subprocess.run([ct['nodeExecutable'],package/'evm-traces.mjs','--output',dest/'evm','--root',ROOT],check=True,stdout=subprocess.DEVNULL)
        require((dest/'evm/results.json').read_bytes() == (out/'evm-traces/results.json').read_bytes(), 'Current physical EVM receipt drift')
    subprocess.run([sys.executable,'-B',ROOT/'scripts/check-raw-rejections-bytecode-evidence.py'],check=True,stdout=subprocess.DEVNULL)
    print('PASS: ' + ', '.join(ledger['publicEntries']) + f"; {len(rows)} native obligations, zero audit, {len(receipts)} complete EVM receipts, {len(faults)} semantic bytecode faults; whole-contract bytecode remains open")
if __name__ == '__main__':
    require(len(sys.argv) == 2, 'Pass an evidence ledger filename')
    check(sys.argv[1])
