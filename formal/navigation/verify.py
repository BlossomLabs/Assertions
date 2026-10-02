#!/usr/bin/env python3
"""Retain navigation correspondence evidence with a complete dependency inventory.

Every theorem and dependency must have an accounted-for execution result.
Source correspondence is distinct from compiler or arbitrary-bytecode proof.
"""
import argparse
import csv
import datetime
import importlib.util
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import time

if not __debug__:
    raise RuntimeError('Run without Python -O: evidence gates use assertions')

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
ABI = HERE.parent / 'abi'
spec = importlib.util.spec_from_file_location('abi_navigation_common', ABI / 'dynamic/verify.py')
base = importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)
common = base.common
run, sha = common.run, common.sha


def closure(path):
    result = {path}
    for name in re.findall(r'^include "([^"]+)"', path.read_text(), re.M):
        result.update(closure((path.parent / name).resolve()))
    return result


def inventory(sources):
    result = []
    for path in sorted(sources):
        text = path.read_text()
        module = re.search(r'^module (\w+)', text, re.M)[1]
        for match in re.finditer(r'^  (?:(?:ghost|opaque) )?(lemma|method|function|predicate)(?: \{:[^}]+\})? (\w+)\(', text, re.M):
            result.append({'name': module + '.' + match[2], 'kind': match[1], 'file': str(path.relative_to(ROOT))})
    assert result and len({d['name'] for d in result}) == len(result)
    return result


def verify_modules(binary, solver, pin, sources, snap, out, prior_path, hashes):
    prior = json.loads(prior_path.read_text())
    assert prior['status'] == 'passed' and prior['completedAt']
    assert prior['executableSha256'] == hashes and prior['toolchain'] == pin
    assert all(sha(prior_path.parent / name) == digest for name, digest in prior['evidenceSha256'].items())
    prior_jobs = {j['moduleFile']: j for check in prior['checks'] if check.get('name') == 'all-proof-modules' for j in check['moduleExecutions']}
    shutil.copy2(prior_path, out / 'dependency-baseline.json')
    directory = out / 'modules'
    directory.mkdir()
    jobs, rows, logs = [], [], []
    verified = errors = 0
    started = time.monotonic()
    for path in sorted(sources):
        key = str(path.relative_to(ROOT))
        name = key.replace('/', '_').removesuffix('.dfy')
        log, data = directory / (name + '.log'), directory / (name + '.csv')
        command = list(map(str, common.proof_command(binary, solver, pin, snap / key, data)))
        command.remove('--verify-included-files')
        old_job = prior_jobs.get(key)
        reusable = False
        if old_job:
            # ABI baseline used names relative to formal/abi. Navigation uses
            # repository-relative names; compare commands after path relocation.
            old_name = str(path.relative_to(ABI)).replace('/', '_').removesuffix('.dfy')
            old_log = prior_path.parent / 'modules' / (old_name + '.log')
            old_data = prior_path.parent / 'modules' / (old_name + '.csv')
            dependencies = {str(p.relative_to(ROOT)): sha(snap / p.relative_to(ROOT)) for p in closure(path)}
            same_inputs = all(prior['sourceSha256'].get(n) == h for n, h in dependencies.items())
            old_command = list(map(str, old_job['command']))
            if len(old_command) == len(command) and old_command[2].endswith('/' + key) and old_command[-1].startswith('csv;LogFileName='):
                old_command[2], old_command[-1] = command[2], command[-1]
            prior_rows = common.native_results(old_data)
            reusable = (same_inputs and old_command == command and old_job['exitCode'] == 0
                        and old_job['summaryPresent'] and old_job['reportedErrors'] == 0
                        and len(prior_rows) == old_job['verifiedBatches']
                        and all(r['TestResult.Outcome'] == 'Passed' for r in prior_rows)
                        and not re.search(r'Error:|time.?out|inconclusive|resource limit', old_log.read_text(), re.I))
        if reusable:
            shutil.copy2(old_log, log)
            if old_data.exists():
                shutil.copy2(old_data, data)
            job = dict(old_job)
            job['reusedFrom'] = {'manifestPath': str(prior_path), 'manifestSha256': sha(prior_path),
                                 'transitiveInputSha256': dependencies, 'matchingVerifierArguments': True}
        else:
            remaining = 1800 - (time.monotonic() - started)
            if remaining <= 0:
                log.write_text('Outer proof budget exhausted; module incomplete.\n')
                job = {'command': command, 'exitCode': None, 'timeout': True}
            else:
                job = run(command, log, max(1, int(remaining)))
        text = log.read_text()
        match = re.search(r'Dafny program verifier finished with (\d+) verified, (\d+) errors?', text)
        job.update(moduleFile=key, summaryPresent=bool(match), verifiedBatches=int(match[1]) if match else 0,
                   reportedErrors=int(match[2]) if match else None, retainedLog=str(log.relative_to(out)))
        verified += job['verifiedBatches']
        errors += job['reportedErrors'] or 0
        jobs.append(job)
        rows.extend(common.native_results(data))
        logs.append('MODULE ' + key + '\n' + re.sub(r'Dafny program verifier finished with[^\n]*', '', text))
    with (out / 'verification.csv').open('w', newline='') as stream:
        if rows:
            writer = csv.DictWriter(stream, fieldnames=list(rows[0]))
            writer.writeheader()
            writer.writerows(rows)
    logs.append(f'Dafny program verifier finished with {verified} verified, {errors} errors\n')
    (out / 'verify.log').write_text('\n'.join(logs))
    return {'name': 'all-proof-modules', 'exitCode': 0 if all(j['exitCode'] == 0 and j['summaryPresent'] for j in jobs) else 1,
            'moduleExecutions': jobs, 'moduleCount': len(jobs), 'outerBudgetSeconds': 1800,
            'reusedModules': sum('reusedFrom' in j for j in jobs),
            'verificationMode': 'Every reachable module accounted for. ABI module reuse requires identical transitive inputs, tool hashes, settings and complete successful native results.'}


def evm(snap, compiler, out):
    oracle = snap / 'formal/navigation/NavigationOracle.t.sol'
    tests = re.findall(r'function (test\w+)\(', oracle.read_text())
    assert len(tests) >= 29 and len(set(tests)) == len(tests)
    with tempfile.TemporaryDirectory(prefix='navigation-oracle-') as temp:
        scratch = Path(temp)
        for relative in ['contracts/Assertions.sol', 'contracts/lib/AbiCodec.sol', 'contracts/lib/ERC8211.sol', 'formal/navigation/NavigationOracle.t.sol']:
            dest = scratch / relative
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(snap / relative, dest)
        config = '[profile.default]\nsrc="contracts"\ntest="formal/navigation"\nsolc=' + json.dumps(str(compiler)) + '\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\n[lint]\nlint_on_build=false\n'
        (scratch / 'foundry.toml').write_text(config)
        (out / 'foundry.toml').write_text(config)
        result = run(['forge', 'test', '--root', scratch, '-vv'], out / 'concrete.log', 120)
    text = (out / 'concrete.log').read_text()
    result.update(expectedTests=tests, passedTests=re.findall(r'^\[PASS\] (test\w+)\(', text, re.M),
                  failedTests=sorted(set(re.findall(r'^\[FAIL:.*?\] (test\w+)\(', text, re.M))))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dafny', required=True)
    parser.add_argument('--solc', required=True)
    parser.add_argument('--abi-evidence', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    binary, solver, compiler, pin, versions, hashes = common.tools(args.dafny, args.solc)
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    entries = sorted(p for p in HERE.glob('*.dfy') if not p.name.endswith('.template.dfy'))
    sources = set().union(*(closure(p) for p in entries))
    declarations = inventory(sources)
    # Retain the prior translators and gates as well as the precise theorem
    # closure, so dependency correspondence can be independently reproduced.
    artifacts = set(sources)
    for directory in {HERE, ABI, *(p.parent for p in sources)}:
        artifacts.update(p for p in directory.iterdir() if p.is_file() and p.suffix in {'.py', '.dfy', '.json', '.smt2', '.sol', '.md'})
    artifacts.update(ROOT / p for p in ['contracts/Assertions.sol', 'contracts/lib/AbiCodec.sol', 'contracts/lib/ERC8211.sol'])
    snap = out / 'source-snapshot'
    for path in sorted(artifacts):
        dest = snap / path.relative_to(ROOT)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, dest)
    versions['forge'] = subprocess.check_output(['forge', '--version'], text=True).strip()
    manifest = {'schemaVersion': 1, 'status': 'incomplete',
                'scope': 'Source-level navigation after operand resolution: arbitrary finite canonical query correspondence, cursor/rejection order, static and dynamic terminal validation, raw return memory, LEN/PAYLOAD and empty paths. Recursive codec diagnostics are propagated from source-connected helper receipts; the independent ABI validator specifies acceptance and values, not a second recursive diagnostic locator. This is not a compiled-bytecode or full-resolver proof.',
                'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
                'revision': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                'sourceSha256': {str(p.relative_to(ROOT)): sha(p) for p in sorted(artifacts)},
                'sourceSnapshot': 'source-snapshot', 'versions': versions, 'executableSha256': hashes,
                'toolchain': pin, 'inventory': declarations, 'checks': [],
                'bounds': {'pathLength': None, 'tupleDepth': None, 'arrayCount': 'uint256 with explicit runtime guards',
                           'loopUnrolling': None, 'solverSecondsPerBatch': pin['verificationTimeLimitSeconds']},
                'assumptions': ['Input bytes begin after the single operand resolution; full resolver correctness remains separate.',
                                'Actual uint256 and int256 arithmetic, error order and checked panic paths are modeled; sufficient gas, stack and allocation remain environmental premises.',
                                'The pinned solc AST, restricted source translator and memory-object projection, Dafny/Boogie/Z3 are trusted.',
                                'Canonical data is a return tuple body. Arbitrary-input navigation preserves loose offsets and selective sibling validation.',
                                'Every ABI dependency is rechecked or reused only with identical transitive hashes and successful complete native results.']}
    def save():
        (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    def add(result, passed):
        result['passed'] = bool(passed)
        manifest['checks'].append(result)
        save()
    save()
    prior = json.loads(args.abi_evidence.read_text())
    same = all(prior['sourceSha256'].get(str(p.relative_to(ROOT))) == sha(p) for p in sources if ABI in p.parents)
    same = same and prior['sourceSha256']['contracts/lib/AbiCodec.sol'] == sha(snap / 'contracts/lib/AbiCodec.sol')
    add({'name': 'ABI-source-and-dependency-identity', 'manifestPath': str(args.abi_evidence.resolve()),
         'manifestSha256': sha(args.abi_evidence), 'matchingSources': same}, same and prior['status'] == 'passed')
    gen = run([sys.executable, '-B', snap / 'formal/navigation/generate.py', '--solc', compiler,
               '--source', snap / 'contracts/Assertions.sol', '--codec', snap / 'contracts/lib/AbiCodec.sol',
               '--wire', snap / 'contracts/lib/ERC8211.sol', '--output', out / 'generated'], out / 'generate.log')
    generated = sorted((snap / 'formal/navigation').glob('*.generated.dfy'))
    gen['freshness'] = gen['exitCode'] == 0 and all((out / 'generated' / p.name).read_bytes() == p.read_bytes() for p in generated)
    add(gen, gen['freshness'])
    if not gen['passed'] or not same:
        return 1
    mask = run([solver, '-smt2', out / 'generated/mask.smt2'], out / 'mask.log', 60)
    mask['outcomes'] = (out / 'mask.log').read_text().splitlines()
    add(mask, mask['exitCode'] == 0 and mask['outcomes'] == ['unsat'] * 32)
    proof = verify_modules(binary, solver, pin, sources, snap, out, args.abi_evidence.resolve(), hashes)
    native, results, passed = base.proof_results(out, declarations, proof)
    manifest.update(nativeResults=native, declarationResults=results,
                    lemmaCount=sum(d['kind'] == 'lemma' for d in declarations), methodCount=sum(d['kind'] == 'method' for d in declarations))
    add(proof, passed)
    audit = run([binary, 'audit', *[snap / p.relative_to(ROOT) for p in entries]], out / 'audit.log')
    add(audit, audit['exitCode'] == 0 and 'auditor completed with 0 findings' in (out / 'audit.log').read_text())
    concrete = evm(snap, compiler, out)
    add(concrete, concrete['exitCode'] == 0 and sorted(concrete['expectedTests']) == sorted(concrete['passedTests']))
    fmt = run([binary, 'format', '--check', *[snap / p.relative_to(ROOT) for p in sorted(sources)]], out / 'format.log')
    add(fmt, fmt['exitCode'] == 0)
    sfmt = run(['forge', 'fmt', '--check', snap / 'formal/navigation/NavigationOracle.t.sol'], out / 'solidity-format.log')
    add(sfmt, sfmt['exitCode'] == 0)
    add({'name': 'source-drift', 'files': len(artifacts)}, all(sha(ROOT / p) == h for p, h in manifest['sourceSha256'].items()))
    manifest['status'] = 'passed' if all(c['passed'] for c in manifest['checks']) else 'incomplete'
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['evidenceSha256'] = {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p != out / 'manifest.json'}
    save()
    print(json.dumps({'status': manifest['status'], 'batches': proof['verifiedBatches'],
                      'modules': proof['moduleCount'], 'tests': len(concrete['passedTests']), 'output': str(out)}))
    return 0 if manifest['status'] == 'passed' else 1


if __name__ == '__main__':
    sys.exit(main())
