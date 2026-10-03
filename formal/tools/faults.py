"""Run native bytecode mutations only after the unchanged public proof passes."""
import csv
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

import capture
import evidence
import review
import runtime_facts

MUTATIONS = [
    ('unsigned-arithmetic', 'Operations.add(uint256,uint256)', 20235, 1, 3,
     'formal/contracts/Operations/add/Arithmetic.dfy', 'OperationsUnsignedArithmetic.Sum'),
    ('unsigned-overflow-branch', 'Operations.add(uint256,uint256)', 20239, 0x15, 0x5f,
     'formal/contracts/Operations/add/Arithmetic.dfy', 'OperationsUnsignedArithmetic.OverflowFlag'),
    ('unsigned-return-length', 'Operations.add(uint256,uint256)', 1337, 32, 31,
     'formal/contracts/Operations/shared/Return.dfy', 'OperationsReturn.Encode'),
    ('signed-arithmetic', 'Operations.add(int256,int256)', 20858, 1, 3,
     'formal/contracts/Operations/add/SignedArithmetic.dfy', 'OperationsSignedArithmetic.Check'),
    ('signed-overflow-branch', 'Operations.add(int256,int256)', 20874, 0x15, 0x5f,
     'formal/contracts/Operations/add/SignedArithmetic.dfy', 'OperationsSignedArithmetic.Check'),
    ('signed-return-length', 'Operations.add(int256,int256)', 1337, 32, 31,
     'formal/contracts/Operations/shared/Return.dfy', 'OperationsReturn.Encode'),
]


def run(baseline, reviewed, dafny, output, signatures=None):
    assert not output.exists(), 'Use a fresh fault-evidence directory'
    manifest, _ = review.inspect(baseline)
    result = json.loads((reviewed / 'review.json').read_text())
    assert result['status'] == 'verified', 'Independent review did not pass'
    assert result['receiptSha256'] == evidence.sha(baseline / 'manifest.json'), 'Review covers another receipt'
    assert result['tools'] == manifest['tools'] and result['rows'] == next(
        r['rows'] for r in manifest['results'] if r['gate'] == 'verify'), 'Incomplete review coverage'
    assert result['coverage'] == {name: True for name in manifest['entrypoints']}, 'Missing reviewed public theorem'
    files = {str(p.relative_to(reviewed)) for p in reviewed.rglob('*')
             if p.is_file() and p != reviewed / 'review.json'}
    assert files == set(result['evidenceSha256']) and all(
        evidence.sha(reviewed / p) == h for p, h in result['evidenceSha256'].items()), 'Tampered review evidence'
    z3, hashes = evidence.tools(dafny)
    assert hashes == manifest['tools'], 'Different proof tools'
    selected = signatures or manifest['signatures']
    assert selected and len(set(selected)) == len(selected) and set(selected) <= set(manifest['signatures']), 'Unverified fault selection'
    mutations = [m for m in MUTATIONS if m[1] in selected]
    assert len(mutations) == 3 * len(selected), 'Missing mutation family'
    snapshot = baseline / 'snapshot'
    catalog = json.loads((snapshot / 'formal/catalog.json').read_text())
    code = bytes.fromhex((snapshot / 'formal/.generated/Operations.runtime.hex').read_text())
    output.mkdir(parents=True)
    report = {'schemaVersion': 1, 'status': 'running', 'signatures': selected,
              'baselineSha256': evidence.sha(baseline / 'manifest.json'),
              'reviewSha256': evidence.sha(reviewed / 'review.json'), 'tools': hashes,
              'specifications': catalog['specifications'], 'mutations': [],
              'scope': 'Native fault sensitivity with refreshed byte bindings; no compiler or public-function proof credit'}
    evidence.write(output / 'faults.json', report)
    for name, signature, pc, before, after, target, theorem in mutations:
        assert target in manifest['sources'] and code[pc] == before, 'Stale mutation location'
        directory = output / name
        scratch = directory / 'snapshot'
        for path in manifest['sources']:
            dest = scratch / path
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(snapshot / path, dest)
        altered = bytearray(code)
        altered[pc] = after
        altered = bytes(altered)
        digest = hashlib.sha256(altered).hexdigest()
        generated = scratch / 'formal/.generated'
        (generated / 'Operations.runtime.hex').write_text(altered.hex() + '\n')
        (generated / 'OperationsRuntime.dfy').write_text(capture.runtime_source(altered))
        (generated / 'OperationsCodeFacts.dfy').write_text(runtime_facts.facts_source(altered))
        binding = json.loads((snapshot / 'formal/contracts/Operations/runtime.json').read_text())
        binding['runtimeSha256'] = digest
        binding['evidenceKind'] = 'scratch bytecode mutation; compiler binding is the unchanged baseline'
        (scratch / 'formal/contracts/Operations/runtime.json').write_text(json.dumps(binding, indent=2) + '\n')
        assert all(evidence.sha(scratch / p) == h for p, h in catalog['specifications'].items()), 'Mutation changed an independent specification'
        for path, original in manifest['sources'].items():
            if path not in {'formal/.generated/OperationsRuntime.dfy', 'formal/.generated/OperationsCodeFacts.dfy'}:
                assert evidence.sha(scratch / path) == original, 'Mutation changed proof source'
        entries = [t['file'] for f in evidence.select(catalog, [signature]) for t in f['theorems']]
        command = [str(dafny), 'verify', *[str(scratch / p) for p in entries], *evidence.POLICY,
                   '--filter-position', target, '--solver-path', str(z3), '--log-format',
                   'csv;LogFileName=' + str(directory / 'native.csv')]
        with (directory / 'verify.log').open('w') as log:
            process = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT)
        log = (directory / 'verify.log').read_text()
        rows = list(csv.DictReader((directory / 'native.csv').open())) if (directory / 'native.csv').exists() else []
        summary = re.search(r'finished with (\d+) verified, (\d+) errors', log)
        failed = [r for r in rows if r['TestResult.Outcome'] == 'Failed'
                  and r['TestResult.DisplayName'].startswith(theorem + ' (correctness)')]
        killed = process.returncode != 0 and bool(summary) and int(summary[2]) > 0 and bool(failed)
        killed &= not bool(re.search(r'time.?out|timed out|inconclusive|parse errors|resolution/type errors', log, re.I))
        report['mutations'].append({'name': name, 'signature': signature, 'pc': pc, 'before': before,
                                    'after': after, 'runtimeSha256': digest, 'command': command,
                                    'exitCode': process.returncode, 'killed': bool(killed),
                                    'failedObligations': [r['TestResult.DisplayName'] for r in failed],
                                    'sources': {str(p.relative_to(scratch)): evidence.sha(p)
                                                for p in evidence.closure(scratch, entries)}})
        evidence.write(output / 'faults.json', report)
    assert evidence.sha(baseline / 'manifest.json') == report['baselineSha256'], 'Baseline changed during faults'
    review.inspect(baseline)
    report['status'] = 'passed' if all(m['killed'] for m in report['mutations']) else 'failed-incomplete'
    report['evidenceSha256'] = {str(p.relative_to(output)): evidence.sha(p) for p in output.rglob('*')
                               if p.is_file() and p != output / 'faults.json'}
    evidence.write(output / 'faults.json', report)
    return 0 if report['status'] == 'passed' else 1
