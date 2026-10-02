#!/usr/bin/env python3
"""Check proof sensitivity to mutations of actual Solidity in isolated copies."""
import argparse
import datetime
import json
from pathlib import Path
import re
import shutil
import sys
import tempfile

from verify import ABI, CONTRACT, HERE, ROOT, native_results, proof_command, run, sha, tools


CASES = [
    ('payload-bound', 'requireValue(n <= v.length - p - 32, p, context);',
     'requireValue(true, p, context);', 'AbiBytesSource.BytesBody'),
    ('padding-bound', 'requireValue(padded <= v.length - p - 32, p, context);',
     'requireValue(true, p, context);', 'AbiBytesSource.BytesBody'),
    ('round-down', 'uint256 padded = (n + 31) / 32 * 32;',
     'uint256 padded = n / 32 * 32;', 'AbiBytesSource.BytesBody'),
    ('dirty-padding', 'requireValue(v[p + 32 + i] == 0, p + 32 + i, context);',
     'requireValue(true, p + 32 + i, context);', 'AbiBytesSource.BytesBody'),
    ('dirty-offset', 'requireValue(v[p + 32 + i] == 0, p + 32 + i, context);',
     'requireValue(v[p + 32 + i] == 0, p + 32 + i + 1, context);', 'AbiBytesSource.BytesBody'),
    ('consumed-extent', 'return 32 + padded;', 'return padded;', 'AbiBytesSource.BytesBody'),
    ('trailing-data', 'requireValue(end == v.length, end, context);',
     'requireValue(end <= v.length, end, context);', 'AbiBytesSource.ValidateBytes'),
    ('trailing-offset', 'requireValue(end == v.length, end, context);',
     'requireValue(end == v.length, 32, context);', 'AbiBytesSource.ValidateBytes'),
    ('word-bound', 'requireValue(p <= data.length && data.length - p >= 32, p, context);',
     'requireValue(p <= data.length && data.length - p > 32, p, context);', 'AbiBytesSource.ReadWord'),
    ('mask-shift', 'type(uint256).max >> ((32 - padding) * 8)',
     'type(uint256).max >> ((32 - padding) * 16)', 'mask-bitvector-equivalence'),
]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dafny', required=True)
    parser.add_argument('--solc', required=True)
    parser.add_argument('--baseline', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    binary, solver, compiler, pin, versions, hashes = tools(args.dafny, args.solc)
    baseline = json.loads(args.baseline.read_text())
    if baseline['status'] != 'passed' or baseline['executableSha256'] != hashes:
        raise ValueError('A passed baseline with identical tools is required')
    for name, digest in baseline['sourceSha256'].items():
        if sha(ROOT/name) != digest:
            raise ValueError('Baseline source drift: '+name)
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    shutil.copy2(args.baseline, output/'baseline-used.json')
    report = {'schemaVersion': 1, 'status': 'incomplete',
              'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'baselineSha256': sha(args.baseline), 'versions': versions, 'executableSha256': hashes,
              'scope': 'Solidity-source mutations; targeted semantic proof failures or mask equivalence counterexamples only',
              'expectedMutations': len(CASES), 'cases': []}
    def save():
        (output/'mutations.json').write_text(json.dumps(report, indent=2)+'\n')
    save()
    original = CONTRACT.read_text()
    for name, before, after, target in CASES:
        if original.count(before) != 1:
            raise ValueError('Mutation must identify exactly one source location: '+name)
        if target != 'mask-bitvector-equivalence' and not any(
                r['name'] == target and r['status'] == 'passed' for r in baseline['declarationResults']):
            raise ValueError('Mutation target did not pass the full baseline')
        case = output/name
        case.mkdir()
        source = case/'AbiCodec.sol'
        source.write_text(original.replace(before, after))
        generated = case/'generated'
        generation = run([sys.executable, HERE/'generate.py', '--solc', compiler,
                          '--source', source, '--output', generated], case/'generate.log')
        item = {'name': name, 'before': before, 'after': after, 'target': target,
                'sourceSha256': sha(source), 'generation': generation, 'detected': False,
                'status': 'incomplete'}
        report['cases'].append(item)
        save()
        if generation['exitCode'] != 0:
            item['reason'] = 'Translation/compilation failure is not semantic mutation detection'
            save()
            continue
        mask = run([solver, '-smt2', generated/'mask.smt2'], case/'mask.log', 120)
        mask['outcomes'] = (case/'mask.log').read_text().splitlines()
        item['mask'] = mask
        if target == 'mask-bitvector-equivalence':
            item['detected'] = mask['exitCode'] == 0 and len(mask['outcomes']) == 32 and 'sat' in mask['outcomes'] and all(
                r in ('sat', 'unsat') for r in mask['outcomes'])
            item['reason'] = 'SAT is a counterexample to the actual source mask equivalence'
        elif mask['exitCode'] == 0 and mask['outcomes'] == ['unsat']*32:
            # Preserve the relative include layout; all non-mutated files come
            # from the exact passing baseline, not another agent's worktree.
            project = case/'proof'
            shutil.copytree(args.baseline.parent/'source-snapshot/formal/abi', project)
            shutil.copy2(generated/'BytesBody.generated.dfy', project/'source/BytesBody.generated.dfy')
            command = proof_command(binary, solver, pin, project/'source/Correspondence.dfy', case/'verification.csv', target)
            # The round-down assertion is easier for Z3 when separated from
            # subsequent loop obligations. No obligation is dropped.
            if name == 'round-down':
                command += ['--isolate-assertions']
            proof = run(command, case/'verify.log', 240)
            proof['nativeResults'] = native_results(case/'verification.csv')
            text = (case/'verify.log').read_text()
            target_rows = [r for r in proof['nativeResults'] if r['TestResult.DisplayName'].split(' (')[0] == target]
            proof['semanticFailure'] = bool(re.search(
                r'(assertion might not hold|postcondition could not be proved|(?:loop |this )invariant could not be proved|precondition for this call could not be proved)', text))
            proof['incomplete'] = any(r['TestResult.Outcome'] not in ('Passed', 'Failed') for r in proof['nativeResults']) or bool(
                re.search(r'time.?out|inconclusive|resource limit', text, re.I))
            item['proof'] = proof
            item['detected'] = proof['exitCode'] not in (0, None) and bool(target_rows) and all(
                r['TestResult.Outcome'] in ('Passed', 'Failed') for r in target_rows) and any(
                r['TestResult.Outcome'] == 'Failed' for r in target_rows) and proof['semanticFailure'] and not proof['incomplete']
            item['reason'] = 'Target must have an explicit semantic failure; parser errors and timeouts never count'
            # Source and tools are retained once in the baseline snapshot. The
            # altered source, generated program, AST, commands and CSV remain.
            shutil.rmtree(project)
        # Confirm these are observable Solidity faults too. A compiler error,
        # missing tests, or a timeout is never a successful mutation check.
        with tempfile.TemporaryDirectory(prefix='abi-source-mutant-') as tmp:
            oracle_root = Path(tmp)
            (oracle_root/'src').mkdir()
            (oracle_root/'test').mkdir()
            shutil.copy2(source, oracle_root/'src/AbiCodec.sol')
            shutil.copy2(args.baseline.parent/'oracle-foundry.toml', oracle_root/'foundry.toml')
            snapshot = args.baseline.parent/'source-snapshot/formal/abi'
            for path in [snapshot/'EncodingOracle.t.sol', snapshot/'ValidationOracle.t.sol', snapshot/'source/BytesSourceOracle.t.sol']:
                shutil.copy2(path, oracle_root/'test'/path.name)
            oracle = run(['forge', 'test', '--root', oracle_root, '-vv'], case/'solc-oracle.log', 120)
            text = (case/'solc-oracle.log').read_text()
            summary = re.search(r'(\d+) tests passed, (\d+) failed, (\d+) skipped \((\d+) total tests\)', text)
            oracle['failedTests'] = re.findall(r'^\[FAIL[^\n]*?\] (test\w+)\(', text, re.M)
            oracle['detected'] = oracle['exitCode'] not in (0, None) and summary is not None and int(summary[2]) > 0 and (
                int(summary[1])+int(summary[2]) == 15 and summary[3] == '0' and summary[4] == '15' and bool(oracle['failedTests']))
            item['evm'] = oracle
            item['detected'] = item['detected'] and oracle['detected']
        item['status'] = 'detected' if item['detected'] else 'incomplete'
        print(name+': '+item['status'], flush=True)
        save()
    report['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    report['detected'] = sum(c['detected'] for c in report['cases'])
    report['sourceDrift'] = any(sha(ROOT/n) != h for n,h in baseline['sourceSha256'].items())
    report['status'] = 'passed' if report['detected'] == len(CASES) and not report['sourceDrift'] else 'incomplete'
    report['evidenceSha256'] = {str(p.relative_to(output)): sha(p) for p in sorted(output.rglob('*'))
                              if p.is_file() and p.name != 'mutations.json'}
    save()
    return 0 if report['status'] == 'passed' else 1


if __name__ == '__main__':
    sys.exit(main())
