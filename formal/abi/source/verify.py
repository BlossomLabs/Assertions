#!/usr/bin/env python3
"""Verify the restricted source-derived bytes/string program and retain evidence."""
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
import tempfile
import time

HERE = Path(__file__).resolve().parent
ABI = HERE.parent
ROOT = HERE.parents[2]
CONTRACT = ROOT / 'contracts/lib/AbiCodec.sol'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def canonical_sources(request):
    """Check both project and versioned npm inputs in a Hardhat compiler job.

    Incremental builds may group several contracts in one job. Package contents
    remain retained in the complete compiler input, not ignored node_modules
    snapshot directories.
    """
    project, dependencies = [], {}
    for name, value in request['sources'].items():
        if name.startswith('project/'):
            path = ROOT/name.removeprefix('project/')
            project.append(path)
        else:
            match = re.fullmatch(r'npm/(@[^/]+/[^@/]+|[^@/]+)@([^/]+)/(.+)', name)
            if not match:
                raise ValueError('Unsupported compiler input key: '+name)
            package, version, relative = match.groups()
            base = ROOT/'node_modules'/package
            assert json.loads((base/'package.json').read_text())['version'] == version
            path = base/relative
            dependencies[name] = {'package': package, 'version': version, 'sha256': sha(path)}
        assert path.read_text() == value['content'], 'Stale canonical build source: '+name
    return project, dependencies


def run(command, log, timeout=900):
    command = list(map(str, command))
    start = time.monotonic()
    with log.open('w') as stream:
        proc = subprocess.Popen(command, cwd=ROOT, stdout=stream, stderr=subprocess.STDOUT, start_new_session=True)
        try:
            status = proc.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            os.killpg(proc.pid, signal.SIGTERM)
            try:
                proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                os.killpg(proc.pid, signal.SIGKILL)
                proc.wait()
            status = None
    return {'command': command, 'exitCode': status, 'seconds': round(time.monotonic()-start, 3),
            'log': log.name, 'logSha256': sha(log)}


def tools(dafny, solc):
    binary = Path(shutil.which(dafny) or dafny).resolve()
    compiler = Path(shutil.which(solc) or solc).resolve()
    pin = json.loads((ABI/'toolchain.json').read_text())
    solver = binary.parent / pin['solverRelativePath']
    versions = {name: subprocess.check_output([str(path), '--version'], text=True).strip()
                for name, path in [('dafny', binary), ('solver', solver), ('solc', compiler)]}
    if versions['dafny'] != pin['dafnyVersion'] or not re.search(r'\b'+re.escape(pin['solverVersion'])+r'\b', versions['solver']):
        raise ValueError('Unpinned Dafny/Z3 versions')
    if '0.8.36+commit.8a079791' not in versions['solc']:
        raise ValueError('Unpinned solc version')
    hashes = {name: sha(path) for name, path in [('dafnyLauncher', binary),
              ('dafnyAssembly', binary.parent/'Dafny.dll'), ('solver', solver), ('solc', compiler)]}
    versions['python'] = sys.version
    versions['node'] = subprocess.check_output(['node', '--version'], text=True).strip()
    return binary, solver, compiler, pin, versions, hashes


def proof_command(binary, solver, pin, entry, csv_path, target=None):
    command = [binary, 'verify', entry, '--verify-included-files', '--manual-lemma-induction',
               '--cores', str(pin['cores']), '--solver-path', solver,
               '--verification-time-limit', str(pin['verificationTimeLimitSeconds']),
               '--log-format', f'csv;LogFileName={csv_path}']
    if target:
        command += ['--filter-symbol', target]
    return command


def native_results(path):
    if not path.exists():
        return []
    with path.open(newline='') as stream:
        return list(csv.DictReader(stream))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dafny', required=True)
    parser.add_argument('--solc', required=True)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    binary, solver, compiler, pin, versions, hashes = tools(args.dafny, args.solc)
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    sources = sorted([*ABI.glob('*.dfy'), *HERE.glob('*.dfy')])
    seen = set()
    def includes(path):
        seen.add(path)
        for child in re.findall(r'^include "([^"]+)"', path.read_text(), re.M):
            dest = (path.parent/child).resolve()
            if dest not in seen:
                includes(dest)
    includes(HERE/'Correspondence.dfy')
    if seen != set(sources):
        raise ValueError('Entrypoint must include every ABI proof source')
    inventory = []
    for path in sources:
        module = re.search(r'^module (\w+)', path.read_text(), re.M)[1]
        for m in re.finditer(r'^  (?:(?:ghost|opaque) )?(lemma|method|function|predicate) (\w+)\(', path.read_text(), re.M):
            inventory.append({'name': module+'.'+m[2], 'kind': m[1], 'file': str(path.relative_to(ROOT))})
    artifacts = sorted(set(sources + [CONTRACT] + list(HERE.glob('*.py')) + list(HERE.glob('*.sol')) +
                           [ABI/n for n in ('toolchain.json', 'check-fixtures.mjs', 'fixtures.json',
                                            'EncodingOracle.t.sol', 'ValidationOracle.t.sol')]))
    snapshot = output/'source-snapshot'
    for path in artifacts:
        dest = snapshot/path.relative_to(ROOT)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, dest)
    entry = snapshot/'formal/abi/source/Correspondence.dfy'
    source = snapshot/'contracts/lib/AbiCodec.sol'
    manifest = {
        'schemaVersion': 1, 'status': 'incomplete',
        'scope': 'Restricted source-derived bytes/string program under trusted AST translation and memory semantics; not compiled-bytecode or full ABI refinement',
        'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'revision': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
        'sourceSha256': {str(p.relative_to(ROOT)): sha(p) for p in artifacts},
        'sourceSnapshot': 'source-snapshot', 'toolchain': pin, 'versions': versions,
        'executableSha256': hashes,
        'assumptions': ['Descriptors are exactly bytes or string; s=0 and e=t.length; ContextKind.Value',
                        'Valid bytes-memory representation; in-bounds MLOAD reads a big-endian 32-byte word',
                        'Lengths and offsets fit uint256; sufficient gas; allocation and pointer arithmetic outside scope',
                        'Pinned solc typed AST and restricted Python translator are trusted, not verified',
                        'Dafny/Boogie and Z3 are trusted; compiler-to-bytecode correctness is not proved'],
        'bounds': {'inputLength': '<2^256', 'offset': '<2^256', 'unrollLimit': None,
                   'paddingBitvectorCases': list(range(32)), 'solverSecondsPerBatch': pin['verificationTimeLimitSeconds']},
        'inventory': inventory, 'checks': []}
    def save():
        (output/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    def add(check, passed):
        check['passed'] = bool(passed)
        manifest['checks'].append(check)
        save()
    save()
    generated = output/'generated'
    generation = run([sys.executable, snapshot/'formal/abi/source/generate.py', '--solc', compiler,
                      '--source', source, '--output', generated], output/'generate.log')
    generation['freshSourceMatches'] = (generated/'BytesBody.generated.dfy').exists() and (
        (generated/'BytesBody.generated.dfy').read_bytes() == (entry.parent/'BytesBody.generated.dfy').read_bytes())
    add(generation, generation['exitCode'] == 0 and generation['freshSourceMatches'])
    if not generation['passed']:
        manifest['status'] = 'failed' if generation['exitCode'] is not None else 'incomplete'
        save()
        return 1
    masks = run([solver, '-smt2', generated/'mask.smt2'], output/'mask.log', 120)
    masks['outcomes'] = (output/'mask.log').read_text().splitlines()
    add(masks, masks['exitCode'] == 0 and masks['outcomes'] == ['unsat']*32)
    proof = run(proof_command(binary, solver, pin, entry, output/'verification.csv'), output/'verify.log')
    proof_text = (output/'verify.log').read_text()
    summary = re.search(r'Dafny program verifier finished with (\d+) verified, (\d+) errors', proof_text)
    proof['verifiedBatches'] = int(summary[1]) if summary else 0
    native = native_results(output/'verification.csv')
    manifest['nativeResults'] = native
    results = []
    for declaration in inventory:
        batches = [r for r in native if r['TestResult.DisplayName'].split(' (')[0] == declaration['name']]
        states = [r['TestResult.Outcome'] for r in batches]
        status = ('failed' if 'Failed' in states else 'incomplete' if any(s != 'Passed' for s in states)
                  else 'passed') if states else 'definition-no-separate-batch'
        results.append(dict(declaration, status=status, batches=len(batches)))
    manifest['declarationResults'] = results
    manifest['lemmaCount'] = sum(r['kind'] == 'lemma' for r in results)
    manifest['methodCount'] = sum(r['kind'] == 'method' for r in results)
    add(proof, proof['exitCode'] == 0 and summary and summary[2] == '0' and
        len(native) == proof['verifiedBatches'] > 0 and all(r['TestResult.Outcome'] == 'Passed' for r in native) and
        all(r['status'] == 'passed' for r in results if r['kind'] in ('lemma', 'method')) and
        not re.search(r'time.?out|inconclusive|resource limit', proof_text, re.I))
    audit = run([binary, 'audit', entry], output/'audit.log')
    add(audit, audit['exitCode'] == 0 and 'auditor completed with 0 findings' in (output/'audit.log').read_text())
    # Fixture checker resolves pinned viem from the repository's installed dependencies.
    fixture = run(['node', ABI/'check-fixtures.mjs'], output/'fixtures.log')
    add(fixture, fixture['exitCode'] == 0 and 'PASS: 1 ' in (output/'fixtures.log').read_text())
    oracles = [snapshot/'formal/abi'/n for n in ('EncodingOracle.t.sol', 'ValidationOracle.t.sol', 'source/BytesSourceOracle.t.sol')]
    tests = [name for path in oracles for name in re.findall(r'\bfunction\s+(test\w+)\s*\(', path.read_text())]
    if len(tests) != 15 or len(set(tests)) != 15:
        raise ValueError('Unexpected oracle inventory')
    with tempfile.TemporaryDirectory(prefix='abi-source-oracle-') as tmp:
        scratch = Path(tmp)
        (scratch/'src').mkdir()
        (scratch/'test').mkdir()
        shutil.copy2(source, scratch/'src/AbiCodec.sol')
        for path in oracles:
            shutil.copy2(path, scratch/'test'/path.name)
        config = ('[profile.default]\nsrc = "src"\ntest = "test"\nsolc = '+json.dumps(str(compiler))+
                  '\noptimizer = true\noptimizer_runs = 200\nevm_version = "cancun"\n[lint]\nlint_on_build = false\n')
        (scratch/'foundry.toml').write_text(config)
        (output/'oracle-foundry.toml').write_text(config)
        oracle = run(['forge', 'test', '--root', scratch, '-vv'], output/'solc-oracle.log')
        oracle['expectedTests'] = tests
        oracle['compilerSettings'] = {'optimizerRuns': 200, 'evmVersion': 'cancun'}
        text = (output/'solc-oracle.log').read_text()
        observed = re.findall(r'^\[PASS\] (test\w+)\(', text, re.M)
        add(oracle, oracle['exitCode'] == 0 and sorted(observed) == sorted(tests) and
            '15 tests passed, 0 failed, 0 skipped (15 total tests)' in text)
    manifest['versions']['forge'] = subprocess.check_output(['forge', '--version'], text=True).strip()
    formatting = run([binary, 'format', '--check', *[snapshot/p.relative_to(ROOT) for p in sources]], output/'format.log')
    add(formatting, formatting['exitCode'] == 0)
    solfmt = run(['forge', 'fmt', '--check', *oracles], output/'solidity-format.log')
    add(solfmt, solfmt['exitCode'] == 0)
    manifest['sourceDrift'] = any(sha(p) != manifest['sourceSha256'][str(p.relative_to(ROOT))] for p in artifacts)
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['status'] = ('passed' if all(c['passed'] for c in manifest['checks']) else
                          'incomplete' if any(c['exitCode'] is None for c in manifest['checks']) or
                          any(r['TestResult.Outcome'] not in ('Passed', 'Failed') for r in native) else 'failed')
    if manifest['sourceDrift']:
        manifest['status'] = 'incomplete'
    manifest['evidenceSha256'] = {str(p.relative_to(output)): sha(p) for p in sorted(output.rglob('*'))
                                if p.is_file() and p.name != 'manifest.json'}
    save()
    print(json.dumps({k: manifest[k] for k in ('status', 'lemmaCount', 'methodCount')}, indent=2))
    print(f'{proof["verifiedBatches"]} verification batches; evidence: {output}')
    return 0 if manifest['status'] == 'passed' else 1


if __name__ == '__main__':
    sys.exit(main())
