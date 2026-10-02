#!/usr/bin/env python3
"""Retain exact native/runtime/physical receipt and radix-mutation suffix gates."""
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
    p.add_argument('--runtime-certificate', type=Path, required=True)
    p.add_argument('--receipts', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    args = p.parse_args()
    native, runtime_certificate, receipts = args.native.resolve(), args.runtime_certificate.resolve(), args.receipts.resolve()
    n, r = [json.loads((d / 'manifest.json').read_text()) for d in [native, runtime_certificate]]
    assert n['status'] == r['status'] == 'passed' and n['coverageComplete'] and n['inputsUnchanged'] and n['toolsUnchanged']
    for d, m in [(native, n), (runtime_certificate, r)]:
        assert all(sha(d / f) == h for f, h in m['evidenceSha256'].items())
        assert all(sha(ROOT / f) == h for f, h in m['sourceSha256'].items())
    entry = 'formal/bytecode/assertions-navigation/ArraySuffix.dfy'
    assert entry in n['entryIncludeClosures']
    runtime = (runtime_certificate / 'identity/Assertions.runtime.bin').read_bytes()
    digest = hashlib.sha256(runtime).hexdigest()
    assert digest == r['runtimeSha256']
    dafny = Path(n['moduleProofs'][0]['proof']['command'][0])
    tools = {'dafny': dafny, 'Dafny.dll': dafny.parent / 'Dafny.dll', 'z3': dafny.parent / 'z3/bin/z3-4.12.1'}
    assert {k: sha(v) for k, v in tools.items()} == n['executableSha256']
    node = Path('/home/sem/assertions-tools/node-v24.14.0-linux-x64/bin/node')
    bindings = []
    covered = set()
    for relative in n['includeClosure']:
        text = (ROOT / relative).read_text()
        match = re.search(r'opaque predicate Matches\([^\n]*\)\s*\{', text)
        if not match:
            continue
        body = text[match.end():text.index('}', match.end())]
        for clause in body.split('&&'):
            clause = clause.strip()
            if m := re.fullmatch(r'\|code\| == (\d+)', clause):
                assert len(runtime) == int(m[1])
            else:
                m = re.fullmatch(r'code\[(\d+)\] == (\d+)', clause)
                assert m and runtime[int(m[1])] == int(m[2])
                covered.add(int(m[1]))
        bindings.append({'file': relative, 'clausesChecked': len(body.split('&&')), 'passed': True})
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    inputs = [Path(__file__).resolve(), HERE / 'check-array-suffix-fixtures.py', HERE / 'evm-array-shape.mjs']
    for version in ['array-init-v1', 'array-digit-v1', 'array-close-v1', 'array-static-finish-v1', 'array-dynamic-finish-v1', 'array-empty-finish-v1']:
        inputs += [HERE / 'development' / version / 'inventory.json']
    hashes = {str(f.relative_to(ROOT)): sha(f) for f in inputs}
    manifest = {'status': 'incomplete', 'scope': 'Complete physical single successful array suffix class, PC8882 through numeral scanning and validation back to PC8882. Includes empty [], static [k], and fixed arrays of dynamic elements. Arbitrary-length positive uint32 decimal numerals including leading zeroes; exact dynamic flag and checked uint32 static footprint/product. Explicit input and reached-resource premises; whole descriptor and whole nav/get remain open.',
                'wholeEntry': False, 'nativeEntry': entry, 'nativeCertificate': str(native / 'manifest.json'),
                'nativeManifestSha256': sha(native / 'manifest.json'), 'runtimeCertificate': str(runtime_certificate / 'manifest.json'),
                'runtimeManifestSha256': sha(runtime_certificate / 'manifest.json'), 'runtimeSha256': digest,
                'sourceSha256': hashes, 'runtimeMatches': bindings, 'checks': []}
    def save():
        (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    def run(name, command):
        j = common.run(command, out / (name + '.log'), 600)
        j.update(name=name, passed=j['exitCode'] == 0)
        manifest['checks'].append(j)
        save()
        return j
    save()
    assert run('admission', ['python3', HERE / 'check-array-suffix-fixtures.py', out, receipts])['passed']
    admission = json.loads((out / 'admission.json').read_text())
    for case in admission['cases']:
        trace = json.loads(Path(case['trace']).read_text())['trace']['structLogs']
        for call in case['admittedCalls']:
            start = call['entryRow']
            for row in trace[start:start + call['physicalInstructions']]:
                pc = row['pc']
                width = 1 + (runtime[pc] - 95 if 96 <= runtime[pc] <= 127 else 0)
                assert set(range(pc, pc + width)) <= covered
    baseline = HERE / 'development/array-digit-v1/Character.dfy'
    source = baseline.read_text()
    assert source.count('code[9000] == 10') == source.count('Op(96,9001,10)') == 1
    changed = source.replace('code[9000] == 10', 'code[9000] == 9').replace('Op(96,9001,10)', 'Op(96,9001,9)')
    (out / 'Mutant.dfy').write_text(changed)
    mutant = bytearray(runtime)
    assert mutant[9000] == 10
    mutant[9000] = 9
    (out / 'mutant-runtime.json').write_text(json.dumps({'runtime': '0x' + mutant.hex()}, indent=2) + '\n')
    j = run('native-mutation', [dafny, 'verify', out / 'Mutant.dfy', '--manual-lemma-induction', '--cores', '1', '--verification-time-limit', '30', '--solver-path', tools['z3'], '--filter-symbol', 'AssertionsNavigationArrayDigit.Advance69', '--log-format', 'csv;LogFileName=' + str(out / 'mutation.csv')])
    rows = list(csv.DictReader((out / 'mutation.csv').open()))
    text = (out / 'native-mutation.log').read_text()
    j['passed'] = j['exitCode'] not in [0, None] and sum(row['TestResult.Outcome'] == 'Failed' for row in rows) == 1 and all(row['TestResult.Outcome'] in ['Passed', 'Failed'] and row['TestResult.DisplayName'].split(' (')[0] == 'AssertionsNavigationArrayDigit.Advance69' for row in rows) and 'postcondition could not be proved' in text and not re.search(r'time.?out|inconclusive|resource limit|parse error|resolution error', text, re.I)
    assert j['passed']
    j = run('evm-mutation', [node, HERE / 'evm-array-shape.mjs', out / 'mutant-evm', out / 'mutant-runtime.json'])
    failure = json.loads((out / 'mutant-evm/case-0.json').read_text())
    j['passed'] = j['exitCode'] not in [0, None] and 'Array descriptor receipt mismatch (uint256[12])' in (out / 'evm-mutation.log').read_text() and failure['descriptor'] == '(uint256[12])' and failure['actual'] != failure['expected']
    assert j['passed']
    pinned = json.loads((runtime_certificate / 'evm/toolchain.json').read_text())
    for folder in [receipts, out / 'mutant-evm']:
        t = json.loads((folder / 'toolchain.json').read_text())
        for key, digest_key in [('nodeExecutable', 'nodeSha256'), ('hardhatEntry', 'hardhatEntrySha256'), ('edrEntry', 'edrEntrySha256'), ('nativeBinding', 'nativeBindingSha256')]:
            assert t[digest_key] == pinned[digest_key] and sha(Path(pinned[key])) == t[digest_key]
        assert t['lockfileSha256'] == sha(ROOT / 'pnpm-lock.yaml')
    manifest['retainedReceiptSha256'] = {str(f): sha(f) for f in receipts.rglob('*') if f.is_file()}
    manifest['publicReceipts'] = len(admission['cases'])
    manifest['admittedSuffixExecutions'] = admission['admittedCalls']
    manifest['mutation'] = {'pc': 9000, 'oldImmediate': 10, 'newImmediate': 9, 'nativeFailedRows': 1, 'publicFixture': '(uint256[12])'}
    manifest['inputsUnchanged'] = all(sha(ROOT / f) == h for f, h in hashes.items()) and all(sha(ROOT / f) == h for f, h in n['sourceSha256'].items())
    manifest['toolsUnchanged'] = {k: sha(v) for k, v in tools.items()} == n['executableSha256']
    manifest['status'] = 'passed' if manifest['inputsUnchanged'] and manifest['toolsUnchanged'] and all(c['passed'] for c in manifest['checks']) else 'failed'
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['evidenceSha256'] = {str(f.relative_to(out)): sha(f) for f in out.rglob('*') if f.is_file() and f.name != 'manifest.json'}
    save()
    print(manifest['status'], ': successful array suffix class; wholeEntry=false')
    raise SystemExit(0 if manifest['status'] == 'passed' else 1)


if __name__ == '__main__':
    main()
