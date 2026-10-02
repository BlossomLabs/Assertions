#!/usr/bin/env python3
"""Independently admit all successful array suffixes and check their complete physical PCs."""
from pathlib import Path
import argparse
import hashlib
import json

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
p = argparse.ArgumentParser()
p.add_argument('output', type=Path)
p.add_argument('receipts', type=Path)
a = p.parse_args()
code = bytes.fromhex(json.loads((ROOT / 'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:])
digest = hashlib.sha256(code).hexdigest()
assert digest == json.loads((ROOT / 'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
versions = ['array-init-v1', 'array-digit-v1', 'array-close-v1', 'array-static-finish-v1', 'array-dynamic-finish-v1', 'array-empty-finish-v1']
inventories = [json.loads((HERE / 'development' / v / 'inventory.json').read_text()) for v in versions]
assert all(i['runtimeSha256'] == digest for i in inventories)
initial, digit, close, finish, dynamic_finish, empty_finish = [i['pcSequence'] for i in inventories]
cases = []
total = 0
for result in json.loads((a.receipts / 'results.json').read_text()):
    assert result['passed'] and result['expected'] == result['actual']
    file = a.receipts / result['trace']
    case = json.loads(file.read_text())
    assert case['runtimeSha256'] == digest
    data = bytes.fromhex(case['data'][2:])
    rows = case['trace']['structLogs']
    calls = []
    for i, row in enumerate(rows):
        if row['pc'] != 8882 or row['depth'] != 1:
            continue
        stack = [int(v, 16) for v in row['stack']]
        ret, offset, length, start, limit, end, dyn, words = stack[-8:]
        prefix = stack[:-8]
        if not (start <= end < limit <= length and offset + length <= len(data) < 1 << 64 and len(prefix) <= 950):
            continue
        if dyn not in [0, 1] or words == 0 or (dyn == 1 and words != 1) or data[offset + end] != 91:
            continue
        stop = end + 1
        count = 0
        while stop < limit and 48 <= data[offset + stop] <= 57:
            count = count * 10 + data[offset + stop] - 48
            stop += 1
        if not (end + 1 <= stop < limit and data[offset + stop] == 93 and count <= 4294967295 and (stop == end + 1 or count > 0) and (dyn == 1 or words * count <= 4294967295)):
            continue
        j = next(k for k in range(i + 1, len(rows)) if rows[k]['pc'] == 8882 and rows[k]['depth'] == 1)
        new_dyn = dyn == 1 or stop == end + 1
        new_words = 1 if new_dyn else words * count
        expected = initial + digit * (stop - end - 1) + close + (empty_finish if stop == end + 1 else dynamic_finish if dyn == 1 else finish)
        assert [r['pc'] for r in rows[i:j]] == expected
        assert [int(v, 16) for v in rows[j]['stack']] == prefix + [ret, offset, length, start, limit, stop + 1, int(new_dyn), new_words]
        assert all(r['memory'] == row['memory'] for r in rows[i:j + 1])
        calls.append({'entryRow': i, 'end': end, 'stop': stop, 'count': count, 'wordsBefore': words,
                      'wordsAfter': new_words, 'dynamicBefore': bool(dyn), 'dynamicAfter': new_dyn, 'physicalInstructions': len(expected), 'passed': True})
        total += 1
    cases.append({'descriptor': case['descriptor'], 'trace': str(file.resolve()),
                  'traceSha256': hashlib.sha256(file.read_bytes()).hexdigest(), 'admittedCalls': calls})
assert total >= 5
a.output.mkdir(parents=True, exist_ok=True)
(a.output / 'admission.json').write_text(json.dumps({'scope': 'Finite witnesses for the complete physical single successful array suffix class; no whole descriptor or public-entry completion claim.',
                                                   'runtimeSha256': digest, 'cases': cases, 'admittedCalls': total,
                                                   'inventorySha256': {v: hashlib.sha256((HERE / 'development' / v / 'inventory.json').read_bytes()).hexdigest() for v in versions}}, indent=2) + '\n')
print(f'PASS: {len(cases)} complete public receipts; {total} admitted complete array suffix executions')
