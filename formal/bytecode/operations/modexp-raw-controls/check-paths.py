#!/usr/bin/env python3
"""Compare every prepared extracted prefix against independently replayed receipts.

This is finite extraction evidence only, not a universal admission proof.
"""
import argparse, hashlib, json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--fixtures', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    mapping = json.loads((HERE / 'raw.mapping.json').read_text())
    artifact = json.loads((ROOT / 'artifacts/contracts/Operations.sol/Operations.json').read_text())
    runtime = bytes.fromhex(artifact['deployedBytecode'][2:])
    runtime_hash = hashlib.sha256(runtime).hexdigest()
    assert runtime_hash == mapping['runtimeSha256']
    instructions = {}
    pc = 0
    while pc < len(runtime):
        op = runtime[pc]
        width = op - 95 if 96 <= op <= 127 else 0
        nxt = pc + 1 + width
        instructions[pc] = (op, nxt, int.from_bytes(runtime[pc + 1:nxt], 'big'))
        pc = nxt
    paths = {p['name']: p for p in mapping['paths']}
    assert len(paths) == 16
    for path in paths.values():
        for node in path['states']:
            assert instructions[node['pc']] == (node['opcode'], node['next'], node['immediate'])
        assert all(instructions[d][0] == 0x5b for d in path['destinations'])
    results = []
    for file in sorted(args.fixtures.glob('*.json')):
        receipt = json.loads(file.read_text())
        if not isinstance(receipt, dict) or 'trace' not in receipt:
            continue
        assert receipt['runtimeSha256'] == runtime_hash
        family = receipt['kind']
        data = bytes.fromhex(receipt['data'][2:])
        value = int(receipt['value'], 16)
        case = 'Nonzero' if value else 'Short' if len(data) < 4 else 'Args' if len(data) < 100 else 'Accepted'
        path = paths[family + case]
        logs = receipt['trace']['structLogs']
        count = len(path['states'])
        assert [n['pc'] for n in path['states']] == [x['pc'] for x in logs[:count]], receipt['name']
        if case == 'Accepted':
            terminal = logs[count]
            assert terminal['pc'] == mapping['bodyFrontiers'][family]
            expected = [mapping['selectors'][family], 1329] + [int.from_bytes(data[i:i + 32], 'big') for i in [4, 36, 68]]
            assert [int(x, 16) for x in terminal['stack']] == expected, receipt['name']
        else:
            assert len(logs) == count and logs[-1]['op'] == 'REVERT' and receipt['trace']['returnValue'] == '0x'
        results.append({'fixture': receipt['name'], 'path': path['name'], 'instructionOccurrences': count})
    assert len(results) == 122
    report = {'status': 'finite-extraction-preflight-passed-no-public-credit',
              'runtimeSha256': runtime_hash, 'fixtures': len(results), 'paths': len(paths),
              'results': results, 'mappingSha256': hashlib.sha256((HERE / 'raw.mapping.json').read_bytes()).hexdigest(),
              'fixtureSha256': {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(args.fixtures.glob('*.json'))}}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print('PASS: 122 finite physical admission prefixes; universal native proofs remain unlaunched')

if __name__ == '__main__':
    main()
