#!/usr/bin/env python3
"""Independent complete successful non-tuple typeShape receipts and grammar."""
from pathlib import Path
import hashlib
import json
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
out = Path(sys.argv[1])
out.mkdir(parents=True, exist_ok=True)
code = bytes.fromhex(json.loads((ROOT / 'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:])
digest = hashlib.sha256(code).hexdigest()
assert digest == json.loads((ROOT / 'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
versions = {'prefix': 'base-prefix-v1', 'nameCharacter': 'name-character-v3', 'nameExit': 'name-exit-v1', 'nameLimit': 'name-limit-v1',
            'five': 'base-five-v2', 'six': 'base-six-v2', 'other': 'base-other-v1', 'arrayInit': 'array-init-v1',
            'arrayDigit': 'array-digit-v1', 'arrayClose': 'array-close-v1', 'arrayStatic': 'array-static-finish-v1',
            'arrayDynamic': 'array-dynamic-finish-v1', 'arrayEmpty': 'array-empty-finish-v1',
            'byteReturn': 'shape-byte-return-v1', 'limitReturn': 'shape-limit-return-v1'}
sequences, hashes = {}, {}
for kind, version in versions.items():
    file = HERE / 'development' / version / 'inventory.json'
    inv = json.loads(file.read_text())
    assert inv['runtimeSha256'] == digest
    sequences[kind] = inv['pcSequence']
    hashes[version] = hashlib.sha256(file.read_bytes()).hexdigest()
legal = set()
pc = 0
while pc < len(code):
    op = code[pc]
    if op == 91:
        legal.add(pc)
    pc += 1 + (op - 95 if 96 <= op <= 127 else 0)
def character(c):
    return 97 <= c <= 122 or 48 <= c <= 57
cases = []
total = 0
for directory in map(Path, sys.argv[2:]):
    for result in json.loads((directory / 'results.json').read_text()):
        assert result['passed'] and result['actual'] == result['expected']
        file = directory / result['trace']
        case = json.loads(file.read_text())
        assert case['runtimeSha256'] == digest
        data = bytes.fromhex(case['data'][2:])
        rows = case['trace']['structLogs']
        admitted, excluded = [], []
        for i, row in enumerate(rows):
            if row['pc'] != 8442 or row['depth'] != 1:
                continue
            stack = [int(v, 16) for v in row['stack']]
            ret, offset, length, p, limit = stack[-5:]
            prefix = stack[:-5]
            if not (p < limit <= length and offset + length <= len(data) < 1 << 64 and len(prefix) <= 950 and character(data[offset + p])):
                excluded.append({'entryRow': i, 'reason': 'Outside fitting nonempty-name class'})
                continue
            q = p
            while q < limit and character(data[offset + q]):
                q += 1
            name_end = q
            name = data[offset + p:offset + q]
            dyn, words = name in [b'bytes', b'string'], 1
            expected = sequences['prefix'] + [12520, 12521] + sequences['nameCharacter'] * (q - p)
            expected += sequences['nameExit' if q < limit else 'nameLimit']
            expected += sequences['five' if q - p == 5 else 'six' if q - p == 6 else 'other']
            closings = []
            valid = True
            while q < limit and data[offset + q] == 91:
                start = q
                stop = q + 1
                count = 0
                while stop < limit and 48 <= data[offset + stop] <= 57:
                    count = count * 10 + data[offset + stop] - 48
                    stop += 1
                empty = stop == start + 1
                new_dyn = dyn or empty
                new_words = 1 if new_dyn else words * count
                if stop >= limit or data[offset + stop] != 93 or count > 4294967295 or (not empty and count == 0) or new_words > 4294967295:
                    valid = False
                    break
                expected += sequences['arrayInit'] + sequences['arrayDigit'] * (stop - start - 1) + sequences['arrayClose']
                expected += sequences['arrayEmpty' if empty else 'arrayDynamic' if dyn else 'arrayStatic']
                closings.append(stop)
                q, dyn, words = stop + 1, new_dyn, new_words
            if not valid:
                excluded.append({'entryRow': i, 'reason': 'Outside successful suffix grammar/uint32 footprint class'})
                continue
            expected += sequences['limitReturn' if q == limit else 'byteReturn']
            assert ret in legal
            j = next(k for k in range(i + 1, len(rows)) if rows[k]['pc'] == ret and rows[k]['depth'] == 1)
            assert [r['pc'] for r in rows[i:j]] == expected, (case['descriptor'], p, q)
            assert [int(v, 16) for v in rows[j]['stack']] == prefix + [q, int(dyn), words]
            assert all(r['memory'] == row['memory'] for r in rows[i:j + 1])
            admitted.append({'entryRow': i, 'p': p, 'nameEnd': name_end, 'nameHex': name.hex(), 'closings': closings,
                             'end': q, 'dynamic': dyn, 'words': words, 'physicalInstructions': len(expected), 'passed': True})
            total += 1
        cases.append({'trace': str(file.resolve()), 'traceSha256': hashlib.sha256(file.read_bytes()).hexdigest(),
                      'descriptor': case['descriptor'], 'admittedCalls': admitted, 'excludedCalls': excluded})
assert total > 0
(out / 'admission.json').write_text(json.dumps({'scope': 'Finite complete successful non-tuple typeShape executions only. Explicitly excluded tuple/error classes; arbitrary native grammar proof and whole public entries remain separate.',
                                              'runtimeSha256': digest, 'inventorySha256': hashes, 'cases': cases, 'admittedCalls': total}, indent=2) + '\n')
print(f'PASS: {len(cases)} public receipts; {total} independently admitted complete non-tuple typeShape executions')
