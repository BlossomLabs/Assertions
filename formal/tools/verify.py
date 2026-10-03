"""Unified integrity, selected native verification, review and coverage reporting."""
import argparse
import csv
import json
import re
import shutil
import subprocess
from pathlib import Path

import bootstrap
import capture
import compiler
import evidence
import runtime_facts

ROOT = evidence.ROOT


def check():
    lock = json.loads((ROOT / 'formal/dependencies/dafnyevm/lock.json').read_text())
    bootstrap.validate(ROOT / 'proof-tools/dafnyevm', lock)
    claims = json.loads((ROOT / 'formal/claims.json').read_text())
    ledger = ROOT / claims['ledger']
    assert evidence.sha(ledger) == claims['ledgerSha256'], 'Public evidence ledger changed'
    existing = json.loads(ledger.read_text())['claims']
    assert len(existing) == 326 and set(existing) == set(claims['claims']), 'Missing public claim'
    assert all(v['recordedClaim'] == claims['claims'][k]['recordedClaim'] for k, v in existing.items()), 'Changed claim wording'
    binding = capture.capture()
    runtime_facts.generate()
    catalog = json.loads((ROOT / 'formal/catalog.json').read_text())
    assert all(evidence.sha(ROOT / p) == h for p, h in catalog['specifications'].items()), 'Changed independent specification'
    assert len(catalog['functions']) == 141
    assert all(f['status'] in evidence.STATUSES for f in catalog['functions'])
    assert len({f['id'] for f in catalog['functions']}) == 141
    for function in catalog['functions']:
        for theorem in function['theorems']:
            assert (ROOT / theorem['file']).is_file(), 'Missing theorem source'
            assert evidence.theorem_contract(ROOT / theorem['file'], theorem['entrypoint']) == theorem['contractSha256'], 'Changed public theorem contract'
        if function['theorems']:
            assert function['proofHome'] == str(Path(function['theorems'][0]['file']).parent)
    return catalog, binding


def run(signatures, dafny, solc, output):
    assert not output.exists(), 'Use a fresh evidence directory'
    catalog, binding = check()
    selected = evidence.select(catalog, signatures)
    entries = sorted({t['file'] for f in selected for t in f['theorems']})
    entrypoints = sorted({t['entrypoint'] for f in selected for t in f['theorems']})
    sources = evidence.closure(ROOT, entries)
    evidence.audit_sources(sources)
    z3, tools = evidence.tools(dafny)
    output.mkdir(parents=True)
    snapshot = output / 'snapshot'
    for path in sources:
        dest = snapshot / path.relative_to(ROOT)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, dest)
    metadata = ['formal/catalog.json', 'formal/claims.json', 'docs/claim-evidence.json',
                'formal/contracts/Operations/runtime.json', 'formal/dependencies/dafnyevm/lock.json',
                'formal/dependencies/dafnyevm/tools.json']
    producers = sorted(str(p.relative_to(ROOT)) for p in (ROOT / 'formal/tools').glob('*.py'))
    for name in metadata + producers + ['formal/.generated/solc-input.json', 'formal/.generated/Operations.runtime.hex']:
        dest = snapshot / name
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(ROOT / name, dest)
    receipt = {'schemaVersion': 1, 'status': 'running', 'signatures': [f['id'] for f in selected],
               'entries': entries, 'entrypoints': entrypoints, 'sources': {str(p.relative_to(ROOT)): evidence.sha(p) for p in sources},
               'bindings': {p: evidence.sha(ROOT / p) for p in metadata + producers},
               'runtimeSha256': binding['runtimeSha256'], 'tools': tools, 'results': [],
               'scope': 'Native public-entry closure; independent review and other acceptance gates are separate'}
    evidence.write(output / 'manifest.json', receipt)
    try:
        receipt['results'].append(compiler.reproduce(snapshot, solc, output))
    except Exception as error:
        receipt['status'] = 'failed-incomplete'
        receipt['results'].append({'gate': 'compiler', 'passed': False, 'error': str(error)})
        evidence.write(output / 'manifest.json', receipt)
        raise
    paths = [str(snapshot / p) for p in entries]
    parts = evidence.partitions(snapshot, evidence.closure(snapshot, entries))
    results = []
    for i, selection in enumerate(parts):
        command = [str(dafny), 'verify', *paths, *evidence.POLICY, *selection, '--solver-path', str(z3),
                   '--log-format', 'csv;LogFileName=' + str(output / f'native-{i:03d}.csv')]
        with (output / f'verify-{i:03d}.log').open('w') as log:
            process = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT)
        log = (output / f'verify-{i:03d}.log').read_text()
        csv_path = output / f'native-{i:03d}.csv'
        valid, rows = evidence.partition_result(log, csv_path)
        passed = process.returncode == 0 and valid
        results.append({'selection': selection, 'command': command, 'exitCode': process.returncode, 'passed': bool(passed), 'rows': len(rows)})
        receipt['nativePartitions'] = results
        evidence.write(output / 'manifest.json', receipt)
    all_rows = []
    for i in range(len(parts)):
        _, rows = evidence.partition_result((output / f'verify-{i:03d}.log').read_text(), output / f'native-{i:03d}.csv')
        all_rows.extend(rows)
    with (output / 'native.csv').open('w') as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=all_rows[0].keys() if all_rows else ['TestResult.DisplayName', 'TestResult.Outcome'])
        writer.writeheader();writer.writerows(all_rows)
    passed = all(r['passed'] for r in results)
    (output / 'verify.log').write_text(''.join((output / f'verify-{i:03d}.log').read_text() for i in range(len(parts))))
    coverage = evidence.entry_coverage(all_rows, entrypoints)
    valid = bool(all_rows) and all(coverage.values())
    receipt['results'].append({'gate': 'verify', 'command': None, 'exitCode': 0 if passed else 1,
                               'passed': bool(passed and valid), 'rows': len(all_rows), 'coverage': coverage})
    commands = [('audit', [str(dafny), 'audit', *paths]),
                ('format', [str(dafny), 'format', '--check', *[str(snapshot / p.relative_to(ROOT)) for p in sources
                                                          if p.is_relative_to(ROOT / 'formal') and '.generated' not in p.parts]])]
    for gate, command in commands:
        with (output / (gate + '.log')).open('w') as log:
            process = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT)
        log = (output / (gate + '.log')).read_text()
        passed = process.returncode == 0
        result = {'gate': gate, 'command': command, 'exitCode': process.returncode}
        if gate == 'audit':
            passed &= 'auditor completed with 0 findings' in log
        result['passed'] = bool(passed)
        receipt['results'].append(result)
        evidence.write(output / 'manifest.json', receipt)
    unchanged = all(evidence.sha(ROOT / p) == h for p, h in (receipt['sources'] | receipt['bindings']).items())
    receipt['status'] = 'verified' if unchanged and all(r['passed'] for r in receipt['results']) else 'failed-incomplete'
    receipt['evidenceSha256'] = {str(p.relative_to(output)): evidence.sha(p) for p in output.rglob('*')
                               if p.is_file() and p != output / 'manifest.json'}
    evidence.write(output / 'manifest.json', receipt)
    return 0 if receipt['status'] == 'verified' else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--check', action='store_true')
    mode.add_argument('--status', action='store_true')
    mode.add_argument('--run', action='store_true')
    mode.add_argument('--review', type=Path)
    parser.add_argument('--signature', action='append')
    parser.add_argument('--output', type=Path)
    parser.add_argument('--dafny', type=Path, default=ROOT / 'proof-tools/dafny/dafny')
    parser.add_argument('--solc', type=Path, default=ROOT / 'proof-tools/solc-0.8.36')
    args = parser.parse_args()
    if args.review:
        import review
        assert args.output, '--review needs a fresh --output directory'
        return review.run(args.review.resolve(), args.dafny.absolute(), args.solc.absolute(), args.output.resolve())
    if args.run:
        assert args.output, '--run needs --output'
        return run(args.signature, args.dafny.absolute(), args.solc.absolute(), args.output.resolve())
    catalog, _ = check()
    if args.status:
        counts = {s: sum(f['status'] == s for f in catalog['functions']) for s in sorted(evidence.STATUSES)}
        print(json.dumps({'publicSignatures': 141, 'catalogStatuses': counts,
                          'sharedTheorems': len(catalog['sharedTheorems']),
                          'note': 'Catalog labels require current independently reviewed evidence for acceptance'}, indent=2))
    else:
        print('Integrity passed: 141 signatures, 326 preserved claims, exact runtime and pinned installation')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
