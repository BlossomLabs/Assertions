#!/usr/bin/env python3
"""Verify the complete independent ABI model and retain auditable evidence.

Requires a pinned Dafny distribution; never installs tools or changes Solidity.
An existing output directory is refused so an earlier run cannot be overwritten.
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
import signal
import subprocess
import sys
import time
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run(command, log, timeout=900):
    start = time.monotonic()
    with log.open('w') as f:
        p = subprocess.Popen(command, cwd=ROOT, stdout=f, stderr=subprocess.STDOUT, start_new_session=True)
        try:
            status = p.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            os.killpg(p.pid, signal.SIGTERM)
            try:
                p.wait(timeout=5)
            except subprocess.TimeoutExpired:
                os.killpg(p.pid, signal.SIGKILL)
                p.wait()
            status = None
    return {'command': list(map(str, command)), 'exitCode': status,
            'seconds': round(time.monotonic() - start, 3), 'log': log.name,
            'logSha256': sha(log)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dafny', default=os.environ.get('DAFNY', 'dafny'))
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    binary = shutil.which(args.dafny)
    if not binary:
        raise SystemExit('Dafny not found; follow formal/abi/README.md')
    binary = Path(binary).resolve()
    pin = json.loads((HERE / 'toolchain.json').read_text())
    solver = binary.parent / pin['solverRelativePath']
    version = subprocess.check_output([binary, '--version'], text=True).strip()
    solver_version = subprocess.check_output([solver, '--version'], text=True).strip()
    if version != pin['dafnyVersion'] or not re.search(r'\b' + re.escape(pin['solverVersion']) + r'\b', solver_version):
        raise SystemExit(f'Unpinned tool versions: {version}; {solver_version}')
    output = Path(args.output).resolve()
    output.mkdir(parents=True, exist_ok=False)
    sources = sorted(HERE.glob('*.dfy'))
    # Every model file must be reachable from the entrypoint.
    seen = set()
    def includes(path):
        seen.add(path)
        for child in re.findall(r'^include "([^"]+)"', path.read_text(), re.M):
            dest = (path.parent / child).resolve()
            if dest not in seen:
                includes(dest)
    includes(HERE / 'Examples.dfy')
    if seen != set(sources):
        raise SystemExit('Entrypoint does not include every model source')
    inventory = []
    for path in sources:
        module = re.search(r'^module (\w+)', path.read_text(), re.M)[1]
        for match in re.finditer(r'^  (?:(?:ghost|opaque) )?(lemma|function|predicate) (\w+)\(', path.read_text(), re.M):
            inventory.append({'name': module + '.' + match[2], 'kind': match[1], 'file': path.name})
    artifacts = sources + [HERE / n for n in ['toolchain.json', 'fixtures.json', 'check-fixtures.mjs', 'verify.py', 'mutations.py', 'EncodingOracle.t.sol', 'ValidationOracle.t.sol']]
    manifest = {
        'schemaVersion': 1, 'scope': 'Independent mathematical model only; no Solidity refinement proof',
        'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'revision': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
        'sourceSha256': {str(p.relative_to(ROOT)): sha(p) for p in artifacts},
        'referenceSolidityNotVerified': {str(p.relative_to(ROOT)): sha(p) for p in
                                       [ROOT/'contracts/lib/AbiCodec.sol', ROOT/'contracts/Assertions.sol']},
        'concretelyTestedSolidity': {'contracts/lib/AbiCodec.sol': sha(ROOT/'contracts/lib/AbiCodec.sol')},
        'toolchain': pin, 'versions': {'dafny': version, 'solver': solver_version},
        'executableSha256': {'dafnyLauncher': sha(binary), 'dafnyAssembly': sha(binary.parent/'Dafny.dll'),
                             'solver': sha(solver)},
        'assumptions': ['WellTyped/WellFormed algebraic inputs; descriptor parsing is not modeled',
                        'Explicit Fits or 256-bit fit preconditions where offsets/lengths are decoded',
                        'Mathematical sequences and integers; no EVM gas, stack or allocation model',
                        'Dafny/Boogie translation and Z3 are trusted'],
        'bounds': {'nestingDepth': None, 'sequenceLength': None,
                   'meaning': 'Induction over arbitrary finite inputs, subject to theorem preconditions'},
        'inventory': inventory, 'checks': []
    }
    (output/'source-snapshot').mkdir()
    for path in artifacts:
        shutil.copy2(path, output/'source-snapshot'/path.name)
    manifest['sourceSnapshot'] = 'source-snapshot'
    def save():
        (output/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    save()
    command = [str(binary), 'verify', str(HERE/'Examples.dfy'), '--verify-included-files',
               '--manual-lemma-induction', '--cores', str(pin['cores']),
               '--solver-path', str(solver), '--verification-time-limit', str(pin['verificationTimeLimitSeconds']),
               '--log-format', f'csv;LogFileName={output / "verification.csv"}']
    verification = run(command, output/'verify.log')
    summary = re.search(r'Dafny program verifier finished with (\d+) verified, (\d+) errors', (output/'verify.log').read_text())
    verification['verifiedBatches'] = int(summary[1]) if summary else 0
    verification['errors'] = int(summary[2]) if summary else None
    verification['passed'] = verification['exitCode'] == 0 and verification['verifiedBatches'] >= len(inventory) and verification['errors'] == 0
    manifest['checks'].append(verification)
    save()
    audit = run([str(binary), 'audit', str(HERE/'Examples.dfy')], output/'audit.log')
    audit['passed'] = audit['exitCode'] == 0 and 'auditor completed with 0 findings' in (output/'audit.log').read_text()
    manifest['checks'].append(audit)
    fixture = run(['node', str(HERE/'check-fixtures.mjs')], output/'fixtures.log')
    fixture['passed'] = fixture['exitCode'] == 0 and 'PASS: 1 ' in (output/'fixtures.log').read_text()
    manifest['checks'].append(fixture)
    with tempfile.TemporaryDirectory(prefix='assertions-abi-solc-oracle-') as tmp:
        scratch = Path(tmp)
        (scratch/'test').mkdir()
        (scratch/'src').mkdir()
        oracles = [HERE/'EncodingOracle.t.sol', HERE/'ValidationOracle.t.sol']
        test_names = []
        for path in oracles:
            shutil.copy2(path, scratch/'test'/path.name)
            test_names.extend(re.findall(r'\bfunction\s+(test\w+)\s*\(', path.read_text()))
        assert len(test_names) == 9 and len(set(test_names)) == 9
        # Retain the exact implementation used by the concrete oracle. The
        # Dafny model still makes no claim of implementation refinement.
        (output/'oracle-src').mkdir()
        shutil.copy2(ROOT/'contracts/lib/AbiCodec.sol', output/'oracle-src/AbiCodec.sol')
        shutil.copy2(output/'oracle-src/AbiCodec.sol', scratch/'src/AbiCodec.sol')
        (scratch/'foundry.toml').write_text('[profile.default]\nsrc = "src"\ntest = "test"\nsolc_version = "0.8.36"\noptimizer = true\noptimizer_runs = 200\nevm_version = "cancun"\n[lint]\nlint_on_build = false\n')
        oracle = run(['forge', 'test', '--root', str(scratch), '--match-contract', 'AbiModel.*OracleTest', '-vv'], output/'solc-oracle.log')
        oracle['expectedTests'] = test_names
        oracle['passed'] = oracle['exitCode'] == 0 and '9 tests passed, 0 failed, 0 skipped (9 total tests)' in (output/'solc-oracle.log').read_text()
        oracle['sourceSha256'] = sha(output/'oracle-src/AbiCodec.sol')
        oracle['passed'] = oracle['passed'] and oracle['sourceSha256'] == manifest['concretelyTestedSolidity']['contracts/lib/AbiCodec.sol']
        oracle['compiler'] = {'version': '0.8.36', 'optimizerRuns': 200, 'evmVersion': 'cancun'}
        manifest['checks'].append(oracle)
    manifest['versions']['forge'] = subprocess.check_output(['forge','--version'], text=True).strip()
    formatting = run([str(binary), 'format', '--check', *map(str, sources)], output/'format.log')
    formatting['passed'] = formatting['exitCode'] == 0
    manifest['checks'].append(formatting)
    solidity_format = run(['forge', 'fmt', '--check', str(HERE/'EncodingOracle.t.sol'), str(HERE/'ValidationOracle.t.sol')], output/'solidity-format.log')
    solidity_format['passed'] = solidity_format['exitCode'] == 0
    manifest['checks'].append(solidity_format)
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['status'] = 'passed' if all(c['passed'] for c in manifest['checks']) else 'incomplete' if any(c['exitCode'] is None for c in manifest['checks']) else 'failed'
    csv_path = output/'verification.csv'
    if csv_path.exists():
        manifest['verificationCsvSha256'] = sha(csv_path)
        with csv_path.open(newline='') as f:
            manifest['nativeResults'] = list(csv.DictReader(f))
        if not manifest['nativeResults'] or any(r['TestResult.Outcome'] != 'Passed' for r in manifest['nativeResults']):
            manifest['status'] = 'incomplete'
    else:
        manifest['status'] = 'incomplete'
    def result_status(row):
        outcome = row['TestResult.Outcome'].lower()
        return 'passed' if outcome == 'passed' else 'failed' if outcome == 'failed' else 'incomplete'
    native = manifest.get('nativeResults', [])
    declaration_results = []
    for declaration in inventory:
        batches = [row for row in native if row['TestResult.DisplayName'].split(' (')[0] == declaration['name']]
        states = [result_status(row) for row in batches]
        state = ('failed' if 'failed' in states else 'incomplete' if 'incomplete' in states else 'passed') if states else 'definition-no-separate-batch'
        declaration_results.append(dict(declaration, status=state, batches=len(batches)))
        if declaration['kind'] == 'lemma' and state != 'passed':
            manifest['status'] = 'failed' if state == 'failed' else 'incomplete'
    manifest['declarationResults'] = declaration_results
    manifest['lemmaCount'] = sum(item['kind'] == 'lemma' for item in inventory)
    if any(result_status(row) == 'failed' for row in native):
        manifest['status'] = 'failed'
    if 'time out' in (output/'verify.log').read_text() and not any(result_status(row) == 'failed' for row in native):
        manifest['status'] = 'incomplete'
    if any(sha(p) != manifest['sourceSha256'][str(p.relative_to(ROOT))] for p in artifacts):
        manifest['status'] = 'incomplete'
        manifest['sourceDrift'] = True
    save()
    print(json.dumps({'status': manifest['status'], 'declarations': len(inventory),
                      'verifiedBatches': verification['verifiedBatches'], 'evidence': str(output)}, indent=2))
    return 0 if manifest['status'] == 'passed' else 1


if __name__ == '__main__':
    sys.exit(main())
