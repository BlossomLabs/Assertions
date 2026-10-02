#!/usr/bin/env python3
"""Bind retained native RAW/empty-path nav class to exact runtime and receipts."""
import argparse
import csv
import datetime
import hashlib
import importlib.util
import json
import re
from pathlib import Path

if not __debug__:
    raise RuntimeError('Run without Python -O')
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
spec = importlib.util.spec_from_file_location('getter', ROOT / 'formal/bytecode/getters/verify.py')
getter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(getter)
common, sha = getter.common, getter.sha


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--native', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    args = p.parse_args()
    native = args.native.resolve()
    n = json.loads((native / 'manifest.json').read_text())
    assert n['status'] == 'passed' and n['coverageComplete'] and n['inputsUnchanged'] and n['toolsUnchanged']
    entry = 'formal/bytecode/assertions-navigation/PublicRawCase.dfy'
    assert entry in n['entryIncludeClosures']
    for origin in n['originPackages']:
        d = Path(origin['directory'])
        assert sha(d / 'manifest.json') == origin['manifestSha256']
        m = json.loads((d / 'manifest.json').read_text())
        for f, digest in m['evidenceSha256'].items():
            assert sha(d / f) == digest
    for f, digest in n['sourceSha256'].items():
        assert sha(ROOT / f) == digest
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    sources = [HERE / name for name in ['verify-public-raw.py', 'evm-passthrough.mjs', 'check-raw-fixtures.py']]
    sources += getter.inputs()
    hashes = {str(f.relative_to(ROOT)): sha(f) for f in sources}
    dafny = Path(n['moduleProofs'][0]['proof']['command'][0])
    solc = Path('/home/sem/assertions-tools/solc-0.8.36')
    node = Path('/home/sem/assertions-tools/node-v24.14.0-linux-x64/bin/node')
    tools = {'dafny': dafny, 'Dafny.dll': dafny.parent / 'Dafny.dll',
             'z3': dafny.parent / 'z3/bin/z3-4.12.1', 'solc': solc, 'node': node}
    tool_hashes = {k: sha(v) for k, v in tools.items()}
    assert {k: tool_hashes[k] for k in n['executableSha256']} == n['executableSha256']
    manifest = {'status': 'incomplete', 'scope': 'Complete physical PC0-to-RETURN nav proof for the independently admitted RAW/no-constraints/empty-path calldata class. Payload bytes, length, descriptor bytes and accepted offsets remain symbolic subject to Calldata and explicit reached resource premises. Other nav classes and whole-entry completion remain open.',
                'wholeEntry': False, 'nativeCertificate': str(native / 'manifest.json'),
                'nativeManifestSha256': sha(native / 'manifest.json'), 'nativeEntry': entry,
                'sourceSha256': hashes, 'executableSha256': tool_hashes,
                'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(), 'checks': []}
    def save():
        (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    def run(name, command, timeout=600):
        j = common.run(command, out / (name + '.log'), timeout)
        j.update(name=name, passed=j['exitCode'] == 0)
        manifest['checks'].append(j)
        save()
        return j
    save()
    j = run('identity', ['python3', ROOT / 'formal/bytecode/dispatch/identity.py', '--solc', solc, '--contract', 'Assertions', '--output', out / 'identity'])
    assert j['passed']
    runtime = (out / 'identity/Assertions.runtime.bin').read_bytes()
    digest = hashlib.sha256(runtime).hexdigest()
    assert digest == json.loads((ROOT / 'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
    legal = set()
    pc = 0
    while pc < len(runtime):
        opcode = runtime[pc]
        if opcode == 91:
            legal.add(pc)
        pc += 1 + (opcode - 95 if 96 <= opcode <= 127 else 0)
    files = [HERE / f for f in ['development/dispatch-v5/Dispatch.dfy', 'development/decoder-v7/Decoder.generated.dfy', 'development/setup-v1/Setup.dfy', 'development/passthrough-v3/Passthrough.dfy']]
    raw = ROOT / 'formal/bytecode/assertions-resolution/raw/Raw.generated.dfy'
    files.append(raw)
    covered = set()
    matches = []
    for f in files:
        relative = str(f.relative_to(ROOT))
        assert relative in n['entryIncludeClosures'][entry] and sha(f) == n['sourceSha256'][relative]
        text = f.read_text()
        start = re.search(r'opaque predicate Matches\([^\n]*\)\s*\{', text).end()
        body = text[start:text.index('}', start)]
        clauses = [v.strip() for v in body.split('&&')]
        for clause in clauses:
            if m := re.fullmatch(r'\|code\| == (\d+)', clause):
                assert len(runtime) == int(m[1])
            elif clause == 'ret < |code|':
                assert 1081 < len(runtime)
            else:
                m = re.fullmatch(r'code\[(\d+|ret)\] == (\d+)', clause)
                assert m, ('Unchecked Matches clause', clause)
                at = 1081 if m[1] == 'ret' else int(m[1])
                assert runtime[at] == int(m[2])
                covered.add(at)
        targets = re.findall(r'function Targets\(\): set<nat> \{ \{([\d,]+)\} \}', text)
        for target in targets:
            assert {int(v) for v in target.split(',')} <= legal
        matches.append({'file': relative, 'clausesChecked': len(clauses), 'passed': True})
    chunks = re.findall(r'function DestinationsChunk\d+\(\): set<nat> \{ \{([\d,]+)\} \}', raw.read_text())
    assert chunks and {int(v) for chunk in chunks for v in chunk.split(',')} == legal
    manifest.update(runtimeSha256=digest, runtimeBytes=len(runtime), runtimeMatches=matches, legalDestinations=len(legal))
    assert run('evm', [node, HERE / 'evm-passthrough.mjs', out / 'evm'])['passed']
    assert run('admission', ['python3', HERE / 'check-raw-fixtures.py', out / 'evm'])['passed']
    for length in [0, 1, 31, 32, 33, 257]:
        case = json.loads((out / 'evm' / f'case-{length}.json').read_text())
        for row in case['trace']['structLogs']:
            at = row['pc']
            width = 1 + (runtime[at] - 95 if 96 <= runtime[at] <= 127 else 0)
            assert set(range(at, at + width)) <= covered, ('Reached instruction not bound by Matches', at)
    mutant = bytearray(runtime)
    assert mutant[1100] == 243
    mutant[1100] = 253
    (out / 'mutant-runtime.json').write_text(json.dumps({'runtime': '0x' + mutant.hex()}, indent=2) + '\n')
    baseline = HERE / 'development/passthrough-v3/Passthrough.dfy'
    source = baseline.read_text()
    assert source.count('code[1100] == 243') == 1 and source.count('Op(243,1101,0)') == 1
    changed = source.replace('code[1100] == 243', 'code[1100] == 253').replace('Op(243,1101,0)', 'Op(253,1101,0)')
    (out / 'Mutant.dfy').write_text(changed)
    j = run('native-mutation', [dafny, 'verify', out / 'Mutant.dfy', '--manual-lemma-induction', '--cores', '1', '--verification-time-limit', '30', '--solver-path', tools['z3'], '--log-format', 'csv;LogFileName=' + str(out / 'mutation.csv')])
    rows = list(csv.DictReader((out / 'mutation.csv').open()))
    text = (out / 'native-mutation.log').read_text()
    j['passed'] = j['exitCode'] not in [0, None] and sum(r['TestResult.Outcome'] == 'Failed' for r in rows) == 1 and all(r['TestResult.Outcome'] in ['Passed', 'Failed'] for r in rows) and 'postcondition could not be proved' in text and not re.search(r'time.?out|inconclusive|resource limit|parse error|resolution error', text, re.I)
    assert j['passed']
    j = run('evm-mutation', [node, HERE / 'evm-passthrough.mjs', out / 'mutant-evm', out / 'mutant-runtime.json'])
    failure = json.loads((out / 'mutant-evm/case-0.json').read_text())
    j['passed'] = j['exitCode'] not in [0, None] and 'Wrong nav passthrough receipt 0' in (out / 'evm-mutation.log').read_text() and failure['trace']['failed']
    assert j['passed']
    for folder in ['evm', 'mutant-evm']:
        t = json.loads((out / folder / 'toolchain.json').read_text())
        for path, digest_key in [('nodeExecutable', 'nodeSha256'), ('hardhatEntry', 'hardhatEntrySha256'), ('edrEntry', 'edrEntrySha256'), ('nativeBinding', 'nativeBindingSha256')]:
            assert sha(Path(t[path])) == t[digest_key]
        assert sha(ROOT / 'pnpm-lock.yaml') == t['lockfileSha256']
    manifest['inputsUnchanged'] = all(sha(ROOT / f) == h for f, h in hashes.items()) and all(sha(ROOT / f) == h for f, h in n['sourceSha256'].items()) and sha(native / 'manifest.json') == manifest['nativeManifestSha256']
    manifest['toolsUnchanged'] = {k: sha(v) for k, v in tools.items()} == tool_hashes
    manifest['publicReceipts'] = 6
    manifest['physicalInstructionsPerReceipt'] = 567
    manifest['mutation'] = {'pc': 1100, 'before': 243, 'after': 253, 'nativeFailedRows': 1, 'concreteRejection': True}
    manifest['status'] = 'passed' if manifest['inputsUnchanged'] and manifest['toolsUnchanged'] and all(j['passed'] for j in manifest['checks']) else 'failed'
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['evidenceSha256'] = {str(f.relative_to(out)): sha(f) for f in out.rglob('*') if f.is_file() and f.name != 'manifest.json'}
    save()
    print(manifest['status'], ': public RAW nav admitted class; wholeEntry=false')
    raise SystemExit(0 if manifest['status'] == 'passed' else 1)


if __name__ == '__main__':
    main()
