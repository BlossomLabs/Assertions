#!/usr/bin/env python3
"""Compare complete shape returns/rejections with independent descriptor syntax."""
import argparse
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def graph(paths):
    closed = set()

    def visit(path):
        path = path.resolve()
        assert path.is_relative_to(ROOT) and path.is_file()
        if path in closed:
            return
        closed.add(path)
        for include in re.findall(r'^include "([^"]+)"', path.read_text(), re.M):
            visit(path.parent / include)

    for path in paths:
        visit(path)
    return closed


def parse(data, offset, start, limit):
    """Finite ASCII descriptor parser independent of proof mappings/EVM states."""
    assert start < limit

    def byte(pos):
        return data[offset + pos] if offset + pos < len(data) else 0

    def allowed(c):
        return 48 <= c <= 57 or 97 <= c <= 122

    if byte(start) == 40:
        cursor = start + 1
        dynamic = total = 0
        depth = 1
        children = []
        while True:
            child = parse(data, offset, cursor, limit)
            children.append(child)
            total += child['words']
            assert total <= 0xffffffff * (child['end'] - start - len(children))
            assert total < 2**256
            dynamic |= child['dynamic']
            depth = max(depth, 1 + child['tupleDepth'])
            cursor = child['end']
            assert cursor < limit
            if byte(cursor) == 44:
                cursor += 1
                continue
            assert byte(cursor) == 41
            end = cursor + 1
            words = 1 if dynamic else total
            tree = dict(kind='tuple', children=children)
            break
    else:
        end = start
        while end < limit and allowed(byte(end)):
            end += 1
        assert end > start
        name = data[offset + start:offset + end]
        dynamic = int(name in [b'bytes', b'string'])
        words = 1
        depth = 0
        tree = dict(kind='named', name=name.decode('ascii'))
    suffixes = []
    while end < limit and byte(end) == 91:
        opening = end
        close = end + 1
        number = 0
        while close < limit and 48 <= byte(close) <= 57 and number <= 0xffffffff:
            number = 10 * number + byte(close) - 48
            close += 1
        empty = close == opening + 1
        assert close < limit and byte(close) == 93
        assert empty or number > 0
        if empty:
            dynamic, words = 1, 1
        elif not dynamic:
            words *= number
            assert words < 2**256
        assert (number | words) <= 0xffffffff
        suffixes.append(dict(opening=opening, close=close, number=number))
        end = close + 1
    assert 1 <= words <= 0xffffffff * (end - start)
    tree.update(start=start, end=end, dynamic=dynamic, words=words,
                tupleDepth=depth, suffixes=suffixes)
    return tree


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--output', type=Path, required=True)
    args = ap.parse_args()
    out = args.output.resolve()
    assert not out.exists()
    scope = json.loads((HERE / 'scope.json').read_text())
    closed = graph([ROOT / path for path in scope['selectedSources']])
    folders = {path.parent for path in closed} | {HERE}
    sources = closed | {path for folder in folders for path in folder.iterdir() if path.is_file()}
    hashes = {str(path.relative_to(ROOT)): sha(path) for path in sorted(sources)}
    pin = json.loads((ROOT / 'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']
    artifact = ROOT / 'artifacts/contracts/Collections.sol/Collections.json'
    code = bytes.fromhex(json.loads(artifact.read_text())['deployedBytecode'][2:])
    assert hashlib.sha256(code).hexdigest() == pin
    mappings = {mode: json.loads((HERE / (mode + '.mapping.json')).read_text())
                for mode in ['Success', 'Trailing']}
    callmap = json.loads((HERE.parent / 'shape-type-call/Call.mapping.json').read_text())
    for mapping in [*mappings.values(), callmap]:
        assert mapping['runtimeSha256'] == pin
        assert all(code[int(pc)] == value for pc, value in mapping['requiredBytes'].items())
    histories = [
        ('physical-pack-admission/development/raw-pack-receipts-v1', 91),
        ('physical-fixed-dynamic/development/receipts-v1', 4),
        ('physical-suffix-chains/development/receipts-v1', 6),
        ('physical-tuples/development/receipts-v1', 8),
        ('physical-tuple-first-dynamic/development/receipts-v1', 2),
        ('physical-descriptor-errors/development/receipts-v2', 60),
        ('physical-descriptor-start-errors/development/receipts-v1', 8),
    ]
    memory = lambda row: bytes.fromhex(''.join(word.removeprefix('0x') for word in row['memory']))
    stack = lambda row: [int(value, 16) for value in row['stack']]

    def store(data, offset, value):
        size = max(len(data), ((offset + 32 + 31) // 32) * 32)
        result = bytearray(data + b'\0' * (size - len(data)))
        result[offset:offset + 32] = value.to_bytes(32, 'big')
        return bytes(result)

    manifests = []
    fixtures = []
    counts = dict(Success=0, Trailing=0, CompleteSuccessfulShape=0,
                  CompleteTrailingShape=0, RejectingParserNotYetConnected=0)
    instructions = dict(Success=0, Trailing=0, CompleteSuccessfulShape=0,
                        CompleteTrailingShape=0)
    operations = {mode: set() for mode in ['Success', 'Trailing']}
    for relative, count in histories:
        original = HERE.parent / relative
        manifest = json.loads((original / 'manifest.json').read_text())
        assert manifest['status'] == 'development-physical-passed-not-retained'
        assert manifest['completedAt'] and manifest['concreteFixtures'] == count
        assert manifest['inputsUnchanged'] and manifest['concreteToolsUnchanged']
        assert all(check['passed'] and check['exitCode'] == 0 for check in manifest['checks'])
        for path, digest in manifest['sourceSha256'].items():
            assert sha(ROOT / path) == sha(original / 'source-snapshot' / path) == digest
        for path, digest in manifest['evidenceSha256'].items():
            assert sha(original / path) == digest
        tools = manifest['concreteToolchain']
        for key in ['hardhatEntry', 'edrEntry', 'nativeBinding']:
            assert sha(Path(tools[key])) == tools[key + 'Sha256']
        assert sha(Path(tools['nodeExecutable'])) == tools['nodeSha256']
        assert sha(ROOT / 'pnpm-lock.yaml') == tools['lockfileSha256']
        assert sha(artifact) == manifest['sourceSha256'][str(artifact.relative_to(ROOT))]
        manifests.append(dict(manifest=str((original / 'manifest.json').relative_to(ROOT)),
                              manifestSha256=sha(original / 'manifest.json'), fixtureCount=count))
        files = [path for path in sorted((original / 'evm-traces').glob('*.json'))
                 if path.name not in ['results.json', 'toolchain.json']]
        assert len(files) == count
        for file in files:
            doc = json.loads(file.read_text())
            assert doc['runtimeSha256'] == pin
            trace = doc['trace']
            fixture = doc['fixture']
            logs = trace['structLogs']
            data = bytes.fromhex(fixture['data'][2:])
            assert logs and logs[0]['pc'] == 0 and all(row['depth'] == 1 for row in logs)
            assert trace['failed'] == fixture['failed']
            assert trace['returnValue'].removeprefix('0x') == fixture['expected']
            spans = []
            starts = {}
            for i, row in enumerate(logs):
                if row['pc'] == 9893:
                    initial = stack(row)
                    prefix = initial[:-3]
                    ret, offset, length = initial[-3:]
                    assert offset < 2**64 and length < 2**64 and code[ret] == 91
                    try:
                        tree = parse(data, offset, 0, length)
                    except AssertionError:
                        counts['RejectingParserNotYetConnected'] += 1
                        continue
                    assert len(prefix) + 6 + 13 * tree['tupleDepth'] <= 1004
                    fields = dict(returnPc=ret, descriptorOffset=offset, descriptorLength=length)
                    evaluate = lambda text: int(text) if text.isdecimal() else fields[text]
                    for k, expected in enumerate(callmap['states']):
                        actual = logs[i + k]
                        assert actual['pc'] == expected['pc']
                        assert stack(actual) == prefix + [evaluate(value) for value in expected['stack']]
                        assert memory(actual) == memory(row)
                    target = prefix + [ret, offset, length, 0, 0, 0,
                                       tree['end'], tree['dynamic'], tree['words']]
                    j = i + len(callmap['states'])
                    while j < len(logs) and not (logs[j]['pc'] == 9908 and stack(logs[j]) == target):
                        assert memory(logs[j]) == memory(row), (fixture['name'], 'parser memory')
                        j += 1
                    assert j < len(logs), (fixture['name'], 'missing complete successful parser')
                    assert j not in starts
                    starts[j] = dict(start=i, prefix=prefix, fields=fields,
                                     tree=tree, initialMemory=memory(row))
                if row['pc'] != 9908:
                    continue
                assert i in starts, (fixture['name'], 'unconnected shape return')
                invocation = starts[i]
                prefix = invocation['prefix']
                fields = invocation['fields']
                tree = invocation['tree']
                mode = 'Success' if tree['end'] == fields['descriptorLength'] else 'Trailing'
                mapping = mappings[mode]
                initial = memory(row)
                assert initial == invocation['initialMemory']
                assert len(initial) % 32 == 0 and len(initial) >= 96
                fp = int.from_bytes(initial[64:96], 'big')
                fields.update(end=tree['end'], dyn=tree['dynamic'], words=tree['words'], fp=fp)
                header = int(mapping['errorSelector'], 16) << 224
                if mode == 'Trailing':
                    assert fp >= 96 and fp + 64 < 2**256
                    first = store(initial, fp, header)
                    complete = store(first, fp + 4, tree['end'])

                def evaluate(text):
                    if text.isdecimal():
                        return int(text)
                    if text in fields:
                        return fields[text]
                    if text == 'fp+4':
                        return fp + 4
                    if text == 'fp+36':
                        return fp + 36
                    raise AssertionError(('unknown exact generated expression', text))

                for k, expected in enumerate(mapping['states']):
                    actual = logs[i + k]
                    assert actual['pc'] == expected['pc'], (fixture['name'], mode, k, 'PC')
                    assert stack(actual) == prefix + [evaluate(value) for value in expected['stack']], (fixture['name'], mode, k, 'full stack')
                    if expected['memory'] == 'mem':
                        expected_memory = initial
                    elif expected['memory'] == 'H.First(mem,fp)':
                        expected_memory = first
                    else:
                        assert expected['memory'] == 'H.Complete(mem,fp,end)'
                        expected_memory = complete
                    assert memory(actual) == expected_memory, (fixture['name'], mode, k, 'full memory')
                end_index = i + len(mapping['states'])
                if mode == 'Success':
                    terminal = logs[end_index]
                    assert terminal['pc'] == fields['returnPc']
                    assert stack(terminal) == prefix + [tree['dynamic'], tree['words']]
                    assert memory(terminal) == initial
                    full = 'CompleteSuccessfulShape'
                else:
                    assert end_index == len(logs) and logs[-1]['op'] == 'REVERT'
                    packet = bytes.fromhex(mapping['errorSelector']) + tree['end'].to_bytes(32, 'big')
                    assert complete[fp:fp + 36] == packet
                    assert trace['returnValue'].removeprefix('0x') == packet.hex() == fixture['expected']
                    assert tree['end'] == fixture['position']
                    full = 'CompleteTrailingShape'
                counts[mode] += 1
                counts[full] += 1
                instructions[mode] += len(mapping['states'])
                instructions[full] += end_index - invocation['start']
                operations[mode].add(fixture['operation'])
                spans.append(dict(mode=mode, startIndex=invocation['start'], parserReturnIndex=i,
                                  terminalIndex=end_index, fullInstructions=end_index - invocation['start'],
                                  exactReturnInstructions=len(mapping['states']), prefixWords=len(prefix), shape=tree))
            fixtures.append(dict(name=fixture['name'], trace=str(file.relative_to(ROOT)),
                                 traceSha256=sha(file), spans=spans))
    assert len(fixtures) == sum(count for _, count in histories) == 179
    assert counts['Success'] and counts['Trailing'] and counts['RejectingParserNotYetConnected']
    assert all(value == {'packArray', 'unpackArray'} for value in operations.values())
    assert all(sha(ROOT / path) == digest for path, digest in hashes.items())
    out.mkdir(parents=True)
    result = dict(status='development-physical-complete-shape-returns-passed-not-retained',
                  runtimeSha256=pin, historicalManifests=manifests, sourceSha256=hashes,
                  inputsUnchanged=True, fixtureCount=len(fixtures), checkedSpans=counts,
                  checkedSpanInstructions=instructions, fixtures=fixtures,
                  scope='All reached exact 21-instruction successful returns and complete 38-instruction trailing-descriptor rejections, independently parsed complete preceding shape/type parser spans, full lower stacks and physical memory, and exact InvalidTypeDescriptor(end) bytes among 179 complete PC-zero receipts. Rejecting preceding parser invocations are explicitly recorded as not connected; universal native closure and full codecs/retention remain open. No public credit.')
    (out / 'results.json').write_text(json.dumps(result, indent=2) + '\n')
    print(result['status'], counts, instructions)


if __name__ == '__main__':
    main()
