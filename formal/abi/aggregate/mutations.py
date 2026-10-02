#!/usr/bin/env python3
"""Reject altered Solidity aggregate cursor expressions in isolated proof copies."""
import argparse
import datetime
import json
from pathlib import Path
import re
import shutil
import sys

from verify import ABI, HERE, ROOT, common, run, sha

CASES = [
    ('array-count-guard', 'requireValue(x.count <= (v.length - x.base) / 32 / x.words, x.base, context);',
     'requireValue(true, x.base, context);', 'ArrayHead'),
    ('tuple-head-guard', 'requireValue(w <= (v.length - p - x.tail) / 32, p, context);',
     'requireValue(true, p, context);', 'TupleHeadStep'),
    ('array-head-width', 'x.tail = x.count * x.words * 32;', 'x.tail = x.count * 32;', 'ArrayHead'),
    ('array-position', 'uint256 position = x.base + i * x.words * 32;',
     'uint256 position = x.base + i * x.words * 64;', 'ArrayPosition'),
    ('array-offset', 'requireValue(word(v, position, context) == x.tail, position, context);',
     'requireValue(true, position, context);', 'ArrayOffset'),
    ('tuple-offset', 'requireValue(word(v, p + x.base, context) == x.tail, p + x.base, context);',
     'requireValue(true, p + x.base, context);', 'TupleOffset'),
    ('array-tail', 'x.tail += body(t, s, x.j, v, x.base + x.tail, context);',
     'x.tail += body(t, s, x.j, v, x.base + x.tail, context) + 1;', 'ArrayTailAdvance'),
    ('tuple-head-width', 'x.tail += w * 32;', 'x.tail += 32;', 'TupleHeadStep'),
    ('tuple-tail', 'x.tail += body(t, x.j, next, v, p + x.tail, context);',
     'x.tail += body(t, x.j, next, v, p + x.tail, context) + 1;', 'TupleTailAdvance'),
]


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--dafny', required=True)
    p.add_argument('--solc', required=True)
    p.add_argument('--baseline', required=True, type=Path)
    p.add_argument('--output', required=True, type=Path)
    args = p.parse_args()
    binary, solver, compiler, pin, versions, hashes = common.tools(args.dafny, args.solc)
    baseline = json.loads(args.baseline.read_text())
    assert baseline['status'] == 'passed' and baseline['executableSha256'] == hashes
    assert all(sha(ROOT/n) == h for n,h in baseline['sourceSha256'].items())
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    shutil.copy2(args.baseline, out/'baseline-used.json')
    report = {'schemaVersion': 1, 'status': 'incomplete', 'baselineSha256': sha(args.baseline),
              'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'versions': versions, 'executableSha256': hashes, 'expectedMutations': len(CASES), 'cases': []}
    def save():
        (out/'mutations.json').write_text(json.dumps(report, indent=2)+'\n')
    original = (ROOT/'contracts/lib/AbiCodec.sol').read_text()
    save()
    for name, before, after, method in CASES:
        target = 'AbiCursorSource.'+method
        assert any(d['name'] == target and d['status'] == 'passed' for d in baseline['declarationResults'])
        # Array head sizing occurs in unpack too. This mutation deliberately
        # changes only the first occurrence, in body, and records its offset.
        assert original.count(before) == (2 if name == 'array-head-width' else 1)
        dest = out/name
        dest.mkdir()
        src = dest/'AbiCodec.sol'
        src.write_text(original.replace(before, after, 1))
        gen = run([sys.executable, HERE/'generate.py', '--source', src, '--solc', compiler,
                   '--output', dest/'generated'], dest/'generate.log')
        item = {'name': name, 'before': before, 'after': after, 'sourceOffset': original.index(before),
                'target': target, 'sourceSha256': sha(src), 'generation': gen, 'detected': False, 'status': 'incomplete'}
        report['cases'].append(item)
        save()
        if gen['exitCode'] != 0:
            continue
        project = dest/'proof'
        shutil.copytree(args.baseline.parent/'source-snapshot/formal/abi', project)
        shutil.copy2(dest/'generated/Cursors.generated.dfy', project/'aggregate/Cursors.generated.dfy')
        shutil.copy2(dest/'generated/BytesBody.generated.dfy', project/'source/BytesBody.generated.dfy')
        proof = run(common.proof_command(binary, solver, pin, project/'aggregate/Refinement.dfy',
                                        dest/'verification.csv', target), dest/'verify.log', 240)
        rows = common.native_results(dest/'verification.csv')
        proof['nativeResults'] = rows
        text = (dest/'verify.log').read_text()
        proof['semanticFailure'] = bool(re.search(r'assertion might not hold|postcondition could not be proved|(?:this |loop )invariant could not be proved|precondition for this call could not be proved', text))
        proof['incomplete'] = any(r['TestResult.Outcome'] not in ('Passed', 'Failed') for r in rows) or bool(re.search(r'time.?out|inconclusive|resource limit', text, re.I))
        failures = [r for r in rows if r['TestResult.DisplayName'].split(' (')[0] == target and r['TestResult.Outcome'] == 'Failed']
        item['proof'] = proof
        item['detected'] = proof['exitCode'] not in (0, None) and bool(failures) and proof['semanticFailure'] and not proof['incomplete']
        item['status'] = 'detected' if item['detected'] else 'incomplete'
        shutil.rmtree(project)
        print(name+': '+item['status'], flush=True)
        save()
    report['sourceDrift'] = any(sha(ROOT/n) != h for n,h in baseline['sourceSha256'].items())
    report['detected'] = sum(c['detected'] for c in report['cases'])
    report['status'] = 'passed' if report['detected'] == len(CASES) and not report['sourceDrift'] else 'incomplete'
    report['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    report['evidenceSha256'] = {str(path.relative_to(out)): sha(path) for path in sorted(out.rglob('*')) if path.is_file() and path.name != 'mutations.json'}
    save()
    return 0 if report['status'] == 'passed' else 1


if __name__ == '__main__':
    sys.exit(main())
