#!/usr/bin/env python3
"""Retain Assertions-only unknown-selector proofs with the full include closure."""
import argparse
import csv
import datetime
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


getter = module('getter', ROOT / 'formal/bytecode/getters/verify.py')
common, sha = getter.common, getter.sha


def graph(path):
    closed = set()

    def visit(file):
        file = file.resolve()
        assert file.is_relative_to(ROOT) and file.is_file()
        if file in closed:
            return
        closed.add(file)
        for include in re.findall(r'^include "([^"]+)"', file.read_text(), re.M):
            visit(file.parent / include)

    visit(path)
    return sorted(closed)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--dafny', type=Path, required=True)
    parser.add_argument('--solc', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    dafny, solc, out = args.dafny.resolve(), args.solc.resolve(), args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    os.environ['DAFNY'] = str(dafny)
    root_proof = HERE / 'AssertionsConnection.dfy'
    closure = graph(root_proof)
    assert all(not any(name in str(p.relative_to(ROOT)) for name in ['Expressions', 'Collections', '/operations/']) for p in closure)
    files = set(getter.inputs()) | set(closure) | {ROOT / 'formal/bytecode/dispatch/Assertions.mapping.json'} | {
        HERE / name for name in ['verify-assertions.py', 'generate.py', 'generate-terminal.py',
                                'format-generated.py', 'make-candidates.py', 'evm-traces.mjs',
                                'Assertions.mapping.json']}
    hashes = {str(p.relative_to(ROOT)): sha(p) for p in sorted(files)}
    tools = {'dafny': dafny, 'Dafny.dll': dafny.parent / 'Dafny.dll',
             'z3': dafny.parent / 'z3/bin/z3-4.12.1', 'solc': solc}
    versions = {k: subprocess.check_output([str(p), '--version'], text=True).strip()
                for k, p in tools.items() if k != 'Dafny.dll'}
    assert versions['dafny'] == json.loads((ROOT / 'formal/abi/toolchain.json').read_text())['dafnyVersion']
    assert '4.12.1' in versions['z3'] and '0.8.36+commit.8a079791' in versions['solc']
    snapshot = out / 'source-snapshot'
    for p in files:
        dest = snapshot / p.relative_to(ROOT)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(p, dest)
    source = snapshot / HERE.relative_to(ROOT)
    manifest = {'status': 'incomplete', 'contracts': ['Assertions'],
        'scope': 'All zero-value frames with at least four calldata bytes and an unknown selector: actual PC-zero through physical empty REVERT, arbitrary 256-bit environment words. No accepted body coverage.',
        'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'sourceSha256': hashes, 'versions': versions,
        'executableSha256': {k: sha(p) for k, p in tools.items()},
        'includeClosure': [str(p.relative_to(ROOT)) for p in closure], 'checks': [],
        'assumptions': ['Reviewed EVM instruction interpretation, full-runtime instruction boundary scanning and exact artifact extraction are trusted.',
            'Fresh byte memory, truthful CALLVALUE/CALLDATASIZE/CALLDATALOAD observations and adequate reached execution resources are required.',
            'Complete native include closure is verified afresh; no historical manifest or assumed successful child execution substitutes for proofs.',
            'Dafny/Boogie/Z3, solc, Node/Hardhat/EDR and retention scripts are trusted. No gas cost or unconditional resource availability claim.']}

    def save():
        (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')

    def record(name, command, timeout=240):
        job = common.run(command, out / (name + '.log'), timeout)
        job.update(name=name, passed=job['exitCode'] == 0)
        manifest['checks'].append(job)
        save()
        return job

    save()
    record('runtime-identity', [sys.executable, '-B', snapshot / 'formal/bytecode/dispatch/identity.py',
                              '--contract', 'Assertions', '--solc', solc, '--output', out / 'identity'])
    generated = out / 'generated'
    mapping = json.loads((source / 'Assertions.mapping.json').read_text())
    generation = [sys.executable, '-B', source / 'generate.py', '--contract', 'Assertions', '--output', generated]
    if mapping['dispatchManifest']:
        generation += ['--dispatch-manifest', mapping['dispatchManifest']]
    record('generation', generation)
    record('terminal-generation', [sys.executable, '-B', source / 'generate-terminal.py',
                                   '--contract', 'Assertions', '--output', generated])
    if not all(j['passed'] for j in manifest['checks']):
        manifest['status'] = 'failed'
        save()
        raise SystemExit('Identity/generation failed; retained failed evidence')
    manifest['regenerationPassed'] = all((source / n).read_bytes() == (generated / n).read_bytes()
        for n in ['Assertions.generated.dfy', 'Assertions.mapping.json', 'AssertionsTerminal.generated.dfy'])
    save()
    if not manifest['regenerationPassed'] or not all(j['passed'] for j in manifest['checks']):
        manifest['status'] = 'failed'
        save()
        raise SystemExit('Identity/generation failed; retained incomplete evidence')
    proof = record('proof', common.proof_command(dafny, source / root_proof.name, out / 'proof.csv')
                   + ['--progress', 'Symbol'], 7200)
    declarations = [d for p in closure for d in getter.inventory(p)]
    common.check_proof(proof, out / 'proof.log', out / 'proof.csv', declarations)
    proof['passed'] = proof['passed'] and all(d['status'] == 'passed' for d in proof['declarations']
                                            if d['kind'] in ['method', 'lemma'])
    manifest['nativeResults'], manifest['declarationResults'] = proof['nativeResults'], proof['declarations']
    save()
    audit = record('audit', [dafny, 'audit', source / root_proof.name])
    audit['passed'] = audit['passed'] and 'auditor completed with 0 findings' in (out / 'audit.log').read_text()
    record('format', [dafny, 'format', '--check', *[snapshot / p.relative_to(ROOT) for p in closure]])
    evm = record('concrete', [shutil.which('node'), HERE / 'evm-traces.mjs', '--contract', 'Assertions',
                             '--output', out / 'evm-traces', '--root', snapshot])
    receipts = json.loads((out / 'evm-traces/results.json').read_text())
    evm['passed'] = evm['passed'] and len(receipts) == 5 and {(r['contract'], r['index']) for r in receipts} == {('Assertions', i) for i in range(5)} and all(r['passed'] and r['receiptPassed'] for r in receipts)
    manifest['concreteToolchain'] = json.loads((out / 'evm-traces/toolchain.json').read_text())
    save()
    record('candidate-generation', [sys.executable, '-B', source / 'make-candidates.py',
                                    '--contract', 'Assertions', '--output', out / 'candidates'])
    candidates = json.loads((out / 'candidates/candidates.json').read_text())
    assert len(candidates) == 1 and candidates[0]['contract'] == 'Assertions'
    candidate = candidates[0]
    folder = out / 'mutation'
    work = folder / 'source-snapshot'
    shutil.copytree(snapshot, work)
    mutated_source = work / HERE.relative_to(ROOT)
    runtime = out / 'candidates' / candidate['runtime']
    record('fault-generation', [sys.executable, '-B', mutated_source / 'generate-terminal.py',
        '--runtime', runtime, '--contract', 'Assertions', '--output', mutated_source])
    assert any(d['name'] == candidate['nativeSymbol'] and d['status'] == 'passed' for d in proof['declarations'])
    native = record('fault-native', common.proof_command(dafny, mutated_source / candidate['source'], folder / 'proof.csv') + ['--filter-symbol', candidate['nativeSymbol']], 240)
    text = (out / 'fault-native.log').read_text()
    rows = list(csv.DictReader((folder / 'proof.csv').open()))
    native['passed'] = native['exitCode'] not in [0, None] and any(r['TestResult.Outcome'] == 'Failed' for r in rows) and all(r['TestResult.Outcome'] in ['Passed', 'Failed'] for r in rows) and 'postcondition could not be proved' in text and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call', text, re.I)
    fault_evm = record('fault-concrete', [shutil.which('node'), HERE / 'evm-traces.mjs', '--root', snapshot,
        '--output', folder / 'evm-traces', '--runtime', runtime, '--contract', 'Assertions', '--case', '0'])
    wrong = json.loads((folder / 'evm-traces/results.json').read_text())
    fault_evm['passed'] = fault_evm['exitCode'] not in [0, None] and len(wrong) == 1 and wrong[0]['contract'] == 'Assertions' and wrong[0]['index'] == 0 and not wrong[0]['receiptPassed']
    manifest['mutation'] = {'candidate': candidate, 'candidateSha256': sha(runtime), 'contradictoryReceipts': wrong}
    manifest['inputsUnchanged'] = hashes == {str(p.relative_to(ROOT)): sha(p) for p in sorted(files)}
    manifest['toolsUnchanged'] = manifest['executableSha256'] == {k: sha(p) for k, p in tools.items()}
    ct = manifest['concreteToolchain']
    manifest['concreteToolsUnchanged'] = all(sha(Path(ct[k])) == ct[k + 'Sha256'] for k in ['hardhatEntry', 'edrEntry', 'nativeBinding']) and sha(Path(ct['nodeExecutable'])) == ct['nodeSha256'] and sha(ROOT / 'pnpm-lock.yaml') == ct['lockfileSha256']
    manifest['status'] = 'passed' if all(manifest[k] for k in ['inputsUnchanged', 'toolsUnchanged', 'concreteToolsUnchanged']) and all(j['passed'] for j in manifest['checks']) else 'failed'
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['evidenceSha256'] = {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name != 'manifest.json'}
    save()
    print(manifest['status'])
    raise SystemExit(0 if manifest['status'] == 'passed' else 1)


if __name__ == '__main__':
    main()
