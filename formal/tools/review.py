"""Independently reconstruct a receipt closure and rerun its native obligations."""
import collections
import csv
import hashlib
import json
import subprocess

import capture
import compiler
import evidence
import runtime_facts


def inspect(directory):
    manifest = json.loads((directory / 'manifest.json').read_text())
    assert manifest['schemaVersion'] == 1 and manifest['status'] == 'verified', 'Incomplete native receipt'
    required = {'verify', 'audit', 'compiler', 'format'}
    assert len(manifest['results']) == len(required) and {r['gate'] for r in manifest['results']} == required, 'Missing verification gate'
    assert all(r['exitCode'] == 0 and r['passed'] for r in manifest['results']), 'Failed verification gate'
    files = {str(p.relative_to(directory)) for p in directory.rglob('*')
             if p.is_file() and p != directory / 'manifest.json'}
    assert files == set(manifest['evidenceSha256']), 'Missing or unbound evidence'
    assert all(evidence.sha(directory / p) == h for p, h in manifest['evidenceSha256'].items()), 'Tampered evidence'
    snapshot = directory / 'snapshot'
    catalog = json.loads((snapshot / 'formal/catalog.json').read_text())
    selected = evidence.select(catalog, manifest['signatures'])
    assert all(evidence.sha(snapshot / p) == h for p, h in catalog['specifications'].items()), 'Changed independent specification'
    assert all(evidence.theorem_contract(snapshot / t['file'], t['entrypoint']) == t['contractSha256']
               for f in selected for t in f['theorems']), 'Changed public theorem contract'
    entries = sorted({t['file'] for f in selected for t in f['theorems']})
    names = sorted({t['entrypoint'] for f in selected for t in f['theorems']})
    assert entries == manifest['entries'] and names == manifest['entrypoints'], 'Wrong public theorem coverage'
    sources = evidence.closure(snapshot, entries)
    hashes = {str(p.relative_to(snapshot)): evidence.sha(p) for p in sources}
    assert hashes == manifest['sources'], 'Incomplete or modified imported closure'
    for theorem in catalog.get('sharedTheorems', []):
        if theorem['file'] in hashes:
            assert evidence.theorem_contract(snapshot / theorem['file'], theorem['id']) == theorem['contractSha256'], 'Changed shared theorem contract'
    evidence.audit_sources(sources)
    lock = json.loads((snapshot / 'formal/dependencies/dafnyevm/lock.json').read_text())
    for path, digest in hashes.items():
        if path.startswith('proof-tools/dafnyevm/'):
            assert lock['effectiveSources'].get(path.removeprefix('proof-tools/dafnyevm/')) == digest, 'Unaccepted dependency source'
    required_bindings = {'formal/catalog.json', 'formal/claims.json', 'docs/claim-evidence.json',
                         'formal/contracts/Operations/runtime.json', 'formal/dependencies/dafnyevm/lock.json',
                         'formal/dependencies/dafnyevm/tools.json'}
    required_bindings |= {str(p.relative_to(evidence.ROOT)) for p in (evidence.ROOT / 'formal/tools').glob('*.py')}
    assert required_bindings == set(manifest['bindings']), 'Missing provenance binding'
    assert all(evidence.sha(snapshot / p) == h and evidence.sha(evidence.ROOT / p) == h
               for p, h in manifest['bindings'].items()), 'Stale metadata or producer'
    binding = json.loads((snapshot / 'formal/contracts/Operations/runtime.json').read_text())
    code = bytes.fromhex((snapshot / 'formal/.generated/Operations.runtime.hex').read_text())
    assert hashlib.sha256(code).hexdigest() == binding['runtimeSha256'] == manifest['runtimeSha256'], 'Wrong runtime bytes'
    compiled = next(r for r in manifest['results'] if r['gate'] == 'compiler')
    tool_lock = json.loads((snapshot / 'formal/dependencies/dafnyevm/tools.json').read_text())
    assert compiled['runtimeSha256'] == binding['runtimeSha256'] and compiled['compilerSha256'] == tool_lock['solcSha256'], 'Wrong compiler evidence'
    assert (snapshot / 'formal/.generated/OperationsRuntime.dfy').read_text() == capture.runtime_source(code), 'Runtime constants differ from bound bytes'
    if 'formal/.generated/OperationsCodeFacts.dfy' in hashes:
        assert (snapshot / 'formal/.generated/OperationsCodeFacts.dfy').read_text() == runtime_facts.facts_source(code), 'Runtime facts differ from bound bytes'
    assert all((evidence.ROOT / p).is_file() and evidence.sha(evidence.ROOT / p) == h
               for p, h in hashes.items()), 'Stale proof source or imported dependency'
    data = json.loads((snapshot / 'formal/.generated/solc-input.json').read_text())
    canonical = json.dumps(data, sort_keys=True, separators=(',', ':')).encode()
    assert hashlib.sha256(canonical).hexdigest() == binding['inputSha256'], 'Wrong compiler input'
    result = next(r for r in manifest['results'] if r['gate'] == 'verify')
    if 'nativePartitions' in manifest:
        parts = evidence.partitions(snapshot, sources)
        recorded = manifest['nativePartitions']
        assert parts == [p['selection'] for p in recorded], 'Missing native partition'
        rows = []
        for i, part in enumerate(recorded):
            valid, part_rows = evidence.partition_result((directory / f'verify-{i:03d}.log').read_text(), directory / f'native-{i:03d}.csv')
            assert valid and part['exitCode'] == 0 and part['passed'] and len(part_rows) == part['rows'], 'Missing native results'
            command = part['command']
            prefix = 2 + len(entries)
            assert command[1] == 'verify' and all(arg.endswith('/snapshot/' + p) for arg, p in zip(command[2:prefix], entries)), 'Wrong verification inputs'
            assert command[prefix:prefix+len(evidence.POLICY)] == evidence.POLICY, 'Wrong verification policy'
            assert command[prefix+len(evidence.POLICY):prefix+len(evidence.POLICY)+2] == part['selection'], 'Wrong native partition command'
            assert len(command) == prefix+len(evidence.POLICY)+6 and command[-4] == '--solver-path' and command[-2] == '--log-format', 'Incomplete verification command'
            assert command[-1].startswith('csv;LogFileName=') and command[-1].endswith(f'/native-{i:03d}.csv'), 'Wrong verification log'
            rows.extend(part_rows)
        with (directory / 'native.csv').open() as source:
            assert rows == list(csv.DictReader(source)), 'Incomplete aggregate native results'
        coverage = evidence.entry_coverage(rows, names)
        assert all(coverage.values()) and len(rows) == result['rows'] and coverage == result['coverage'], 'Missing native results or entrypoint'
    else:
        valid, rows, coverage = evidence.native_result((directory / 'verify.log').read_text(), directory / 'native.csv', names)
        assert valid and len(rows) == result['rows'] and coverage == result['coverage'], 'Missing native results or entrypoint'
        command = result['command']
        assert command[1] == 'verify' and all(arg.endswith('/snapshot/' + p) for arg, p in zip(command[2:2+len(entries)], entries)), 'Wrong verification inputs'
        assert command[2+len(entries):2+len(entries)+len(evidence.POLICY)] == evidence.POLICY, 'Wrong verification policy'
        assert len(command) == 2+len(entries)+len(evidence.POLICY)+4 and command[-4] == '--solver-path' and command[-2] == '--log-format', 'Incomplete verification command'
        assert command[-1].startswith('csv;LogFileName=') and command[-1].endswith('/native.csv'), 'Wrong verification log'
    assert 'auditor completed with 0 findings' in (directory / 'audit.log').read_text(), 'Audit findings'
    return manifest, rows


def run(directory, dafny, solc, output):
    assert not output.exists(), 'Use a fresh independent-review directory'
    manifest, original_rows = inspect(directory)
    receipt_hash = evidence.sha(directory / 'manifest.json')
    z3, hashes = evidence.tools(dafny)
    assert hashes == manifest['tools'], 'Different proof tool binaries'
    output.mkdir(parents=True)
    compiled = compiler.reproduce(directory / 'snapshot', solc, output)
    entries = [str(directory / 'snapshot' / p) for p in manifest['entries']]
    snapshot = directory / 'snapshot'
    parts = evidence.partitions(snapshot, evidence.closure(snapshot, manifest['entries']))
    commands, rows, results = [], [], []
    for i, selection in enumerate(parts):
        command = [str(dafny), 'verify', *entries, *evidence.POLICY, *selection, '--solver-path', str(z3),
                   '--log-format', 'csv;LogFileName=' + str(output / f'native-{i:03d}.csv')]
        commands.append(command)
        with (output / f'verify-{i:03d}.log').open('w') as log:
            process = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT)
        valid, part_rows = evidence.partition_result((output / f'verify-{i:03d}.log').read_text(), output / f'native-{i:03d}.csv')
        results.append({'selection': selection, 'exitCode': process.returncode, 'passed': process.returncode == 0 and valid,
                        'rows': len(part_rows)})
        rows.extend(part_rows)
        evidence.write(output / 'progress.json', {'status': 'running', 'results': results})
    with (output / 'native.csv').open('w') as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=rows[0].keys() if rows else ['TestResult.DisplayName', 'TestResult.Outcome'])
        writer.writeheader();writer.writerows(rows)
    coverage = evidence.entry_coverage(rows, manifest['entrypoints'])
    identity = lambda rs: collections.Counter((r['TestResult.DisplayName'], r['TestResult.Outcome']) for r in rs)
    passed = all(r['passed'] for r in results) and all(coverage.values()) and identity(rows) == identity(original_rows)
    audit_command = [str(dafny), 'audit', *entries]
    with (output / 'audit.log').open('w') as log:
        audit = subprocess.run(audit_command, stdout=log, stderr=subprocess.STDOUT)
    passed &= audit.returncode == 0 and 'auditor completed with 0 findings' in (output / 'audit.log').read_text()
    format_command = [str(dafny), 'format', '--check', *[str(directory / 'snapshot' / p) for p in manifest['sources']
                                                     if p.startswith('formal/') and '/.generated/' not in p]]
    with (output / 'format.log').open('w') as log:
        formatted = subprocess.run(format_command, stdout=log, stderr=subprocess.STDOUT)
    passed &= formatted.returncode == 0
    assert evidence.sha(directory / 'manifest.json') == receipt_hash, 'Receipt changed during review'
    inspect(directory)
    report = {'schemaVersion': 1, 'status': 'verified' if passed else 'failed-incomplete',
              'receiptSha256': receipt_hash, 'tools': hashes,
              'commands': commands + [audit_command, format_command], 'partitions': results, 'compiler': compiled, 'coverage': coverage, 'rows': len(rows),
              'scope': 'Independent native, audit, compiler and format rerun; concrete and fault gates remain separate'}
    report['evidenceSha256'] = {str(p.relative_to(output)): evidence.sha(p) for p in output.rglob('*') if p.is_file()}
    evidence.write(output / 'review.json', report)
    return 0 if passed else 1
