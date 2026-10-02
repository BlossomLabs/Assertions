#!/usr/bin/env python3
"""Verify the signed modular arithmetic model and retain implementation evidence.

Requires Dafny 4.11.0. EVM checks use the repository's pinned Hardhat compiler.
The result explicitly distinguishes model proofs from bytecode equivalence.
"""
import argparse
import csv
import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[2]
MODEL = ROOT / 'formal/signed-mod/SignedMod.dfy'
TEST = ROOT / 'test/signed-mod.test.ts'
CONTRACT = ROOT / 'contracts/Operations.sol'

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def capture(command):
    return subprocess.check_output(command, cwd=ROOT, text=True, stderr=subprocess.STDOUT).strip()

def function_sources():
    source = CONTRACT.read_text()
    bindings = []
    for signature, symbol in [
        ('function _magnitude(int256 value)', 'MagnitudeImpl'),
        ('function _signedMagnitude(uint256 value, bool negative)', 'SignedMagnitudeImpl'),
        ('function addMod(int256 a, int256 b, int256 m)', 'AddImpl'),
        ('function mulMod(int256 a, int256 b, int256 m)', 'MulImpl'),
    ]:
        start = source.index(signature)
        end = source.index('{', start)
        depth = 1
        while depth:
            end += 1
            depth += (source[end] == '{') - (source[end] == '}')
        body = source[start:end + 1]
        bindings.append(dict(signature=signature, modelSymbol=symbol, source=body,
                             line=source[:start].count('\n') + 1,
                             sha256=hashlib.sha256(body.encode()).hexdigest()))
    return {'status': 'MANUAL_SOURCE_CORRESPONDENCE', 'bindings': bindings,
            'limitation': 'Hashes identify the reviewed source. They do not prove model-to-Solidity or compiler equivalence.'}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dafny', default=os.environ.get('DAFNY', 'dafny'))
    parser.add_argument('--output', default='docs/verification/signed-mod')
    parser.add_argument('--runs', type=int, default=4096)
    parser.add_argument('--seed', type=int, default=20260929)
    args = parser.parse_args()
    assert args.runs > 0 and 0 < args.seed <= 0xffffffff
    output = (ROOT / args.output).resolve()
    output.mkdir(parents=True, exist_ok=True)
    if (output / 'manifest.json').exists():
        raise SystemExit('Refusing to overwrite retained evidence; choose another --output')
    dafny = Path(shutil.which(args.dafny) or args.dafny).resolve()
    version = capture([str(dafny), '--version'])
    if not version.startswith('4.11.0'):
        raise SystemExit('Expected Dafny 4.11.0; review and pin any tool upgrade')
    proof = MODEL.read_text()
    if re.search(r'\bassume\s|\{:\s*(?:axiom|extern)|\{:\s*verify\s+false', proof):
        raise SystemExit('Unproved assumptions or disabled verification in model')
    lemmas = re.findall(r'^  lemma(?:\s+\{:[^}]+\})?\s+(\w+)\(', proof, re.M)
    assert len(lemmas) == 10
    paths = [MODEL, TEST, CONTRACT, Path(__file__), ROOT / 'hardhat.config.ts', ROOT / 'package.json', ROOT / 'pnpm-lock.yaml']
    hashes = {str(p.relative_to(ROOT)): sha(p) for p in paths}
    manifest = dict(schemaVersion=1, startedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                    revision=capture(['git', 'rev-parse', 'HEAD']), sourceSha256=hashes,
                    scope=['O13', 'O14'], modelProof='incomplete', bytecodeEquivalence='NOT_PROVED',
                    dafnyVersion=version, dafnyExecutableSha256=sha(dafny),
                    solverVersion=capture([str(dafny.parent / 'z3/bin/z3-4.12.1'), '-version']),
                    solverExecutableSha256=sha(dafny.parent / 'z3/bin/z3-4.12.1'),
                    bounds={'input': 'All a,b,m in [-2^255, 2^255-1]; mathematical intermediates unbounded',
                            'loopBound': None, 'cores': 2, 'assertionTimeoutSeconds': 30},
                    assumptions=['Solidity checked %, addmod and mulmod reject zero modulus with Panic(0x12).',
                                 'ADDMOD/MULMOD compute unbounded intermediates before reduction.',
                                 'The manually reviewed translation represents the four recorded Solidity functions.',
                                 'Concrete calls use valid ABI encodings, sufficient gas and the pinned local EVM/compiler.'],
                    checks=[])
    (output / 'source-correspondence.json').write_text(json.dumps(function_sources(), indent=2) + '\n')
    def save():
        (output / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    def run(name, command, env=None):
        start = time.monotonic()
        log = output / (name + '.log')
        with log.open('w') as stream:
            try:
                code = subprocess.run(command, cwd=ROOT, env=env, stdout=stream, stderr=subprocess.STDOUT, timeout=240).returncode
            except subprocess.TimeoutExpired:
                code = None
        result = dict(name=name, command=command, exitCode=code, seconds=round(time.monotonic() - start, 3),
                      log=log.name, logSha256=sha(log))
        manifest['checks'].append(result)
        save()
        return result, log.read_text()
    save()
    proof_result, text = run('dafny', [str(dafny), 'verify', str(MODEL), '--cores', '2', '--verification-time-limit', '30',
                                     '--solver-path', str(dafny.parent / 'z3/bin/z3-4.12.1'),
                                     '--log-format', f'csv;LogFileName={output / "proof-results.csv"}'])
    csv_path = output / 'proof-results.csv'
    rows = list(csv.DictReader(csv_path.open())) if csv_path.exists() else []
    passed = proof_result['exitCode'] == 0 and rows and all(r['TestResult.Outcome'] == 'Passed' for r in rows)
    manifest['lemmas'] = []
    for name in lemmas:
        batches = [r for r in rows if r['TestResult.DisplayName'].startswith('SignedMod.' + name + ' ')]
        ok = bool(batches) and all(r['TestResult.Outcome'] == 'Passed' for r in batches)
        manifest['lemmas'].append(dict(name=name, status='proved' if ok else 'incomplete', batches=len(batches)))
        passed = passed and ok
    proof_result['assertionBatches'] = len(rows)
    manifest['modelProof'] = 'PROVED' if passed else 'INCOMPLETE'
    save()
    if not passed:
        raise SystemExit('Proof did not complete; see retained results')
    env = dict(os.environ, SIGNED_MOD_SEED=str(args.seed), SIGNED_MOD_RUNS=str(args.runs))
    test_result, text = run('evm', ['pnpm', 'exec', 'hardhat', 'test', 'nodejs', 'test/signed-mod.test.ts'], env)
    matches = re.findall(r'\b(\d+) passing\b', text)
    test_result.update(tests=int(matches[-1]) if matches else 0, seed=args.seed, runsPerOperation=args.runs,
                       expectedCalls=2 * (11**3 + args.runs + 11**2))
    test_result['status'] = 'passed' if test_result['exitCode'] == 0 and test_result['tests'] == 6 else 'incomplete'
    assert all(sha(ROOT / name) == value for name, value in hashes.items()), 'Sources changed during verification'
    artifact_path = ROOT / 'artifacts/contracts/Operations.sol/Operations.json'
    artifact = json.loads(artifact_path.read_text())
    build_path = ROOT / 'artifacts/build-info' / (artifact['buildInfoId'] + '.json')
    build = json.loads(build_path.read_text())
    contract_inputs = [v['content'] for k, v in build['input']['sources'].items() if k.endswith('/contracts/Operations.sol') or k == 'contracts/Operations.sol']
    assert contract_inputs == [CONTRACT.read_text()], 'Artifact source does not match the verified source snapshot'
    manifest['compiler'] = dict(version=build['solcLongVersion'], settings=build['input']['settings'],
                                buildInfoId=artifact['buildInfoId'], buildInfoSha256=sha(build_path),
                                inputSourcesSha256={k: hashlib.sha256(v['content'].encode()).hexdigest() for k, v in build['input']['sources'].items()})
    manifest['artifact'] = dict(path=str(artifact_path.relative_to(ROOT)), sha256=sha(artifact_path),
                               runtimeBytes=(len(artifact['deployedBytecode'])-2)//2,
                               runtimeSha256=hashlib.sha256(bytes.fromhex(artifact['deployedBytecode'][2:])).hexdigest())
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['status'] = 'passed' if test_result['status'] == 'passed' else 'incomplete'
    save()
    print(json.dumps({'modelProof': manifest['modelProof'], 'lemmas': len(lemmas), 'assertionBatches': len(rows),
                      'evmTests': test_result['tests'], 'calls': test_result['expectedCalls'], 'status': manifest['status']}))
    if manifest['status'] != 'passed':
        raise SystemExit('EVM check did not complete')

if __name__ == '__main__':
    main()
