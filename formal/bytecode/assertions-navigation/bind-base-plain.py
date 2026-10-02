#!/usr/bin/env python3
"""Bind the frozen plain-name parser helper closure and retained physical gates."""
import argparse
import csv
import datetime
import hashlib
import importlib.util
import json
import re
import subprocess
from pathlib import Path

if not __debug__:
    raise RuntimeError('Run without Python -O')
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
spec = importlib.util.spec_from_file_location('getter', ROOT / 'formal/bytecode/getters/verify.py')
getter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(getter)
sha = getter.sha


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--native', type=Path, required=True)
    p.add_argument('--runtime-certificate', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    args = p.parse_args()
    native, runtime_certificate = args.native.resolve(), args.runtime_certificate.resolve()
    n = json.loads((native / 'manifest.json').read_text())
    r = json.loads((runtime_certificate / 'manifest.json').read_text())
    assert n['status'] == r['status'] == 'passed'
    for origin in n['originPackages']:
        d = Path(origin['directory'])
        assert sha(d / 'manifest.json') == origin['manifestSha256']
        m = json.loads((d / 'manifest.json').read_text())
        assert all(sha(d / f) == h for f, h in m['evidenceSha256'].items())
    assert all(sha(runtime_certificate / f) == h for f, h in r['evidenceSha256'].items())
    assert all(sha(ROOT / f) == h for f, h in n['sourceSha256'].items())
    assert all(sha(ROOT / f) == h for f, h in r['sourceSha256'].items())
    runtime = (runtime_certificate / 'identity/Assertions.runtime.bin').read_bytes()
    assert hashlib.sha256(runtime).hexdigest() == r['runtimeSha256']
    entry = 'formal/bytecode/assertions-navigation/BasePlain.dfy'
    bindings = []
    for relative in n['entryIncludeClosures'][entry]:
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
                assert m and runtime[int(m[1])] == int(m[2]), ('Unchecked/mismatched Matches clause', clause)
        bindings.append({'file': relative, 'clausesChecked': len(body.split('&&')), 'passed': True})
    assert len(bindings) == 9
    gates = HERE / 'development/name-gates-v1'
    gm = json.loads((gates / 'development-manifest.json').read_text())
    assert all(sha(gates / f) == h for f, h in gm['evidenceSha256'].items())
    assert all(sha(ROOT / f) == h for f, h in gm['sourceSha256'].items())
    baseline = HERE / 'development/name-character-v3/Character.dfy'
    changed = baseline.read_text().replace('code[12553] == 17', 'code[12553] == 16').replace('Op(17,12554,0)', 'Op(16,12554,0)')
    mutant = gates / 'mutant-gt-to-lt'
    assert changed == (mutant / 'Character.dfy').read_text()
    candidate = bytes.fromhex(json.loads((mutant / 'runtime.json').read_text())['runtime'][2:])
    assert len(candidate) == len(runtime) and [i for i in range(len(runtime)) if candidate[i] != runtime[i]] == [12553]
    assert runtime[12553] == 17 and candidate[12553] == 16
    rows = list(csv.DictReader((mutant / 'proof.csv').open()))
    text = (mutant / 'proof.log').read_text()
    assert sum(row['TestResult.Outcome'] == 'Failed' for row in rows) == 1
    assert all(row['TestResult.Outcome'] in ['Passed', 'Failed'] for row in rows)
    assert 'postcondition could not be proved' in text and not re.search(r'time.?out|inconclusive|resource limit|parse error|resolution error', text, re.I)
    assert gm['mutation']['nativeExitCode'] not in [0, None] and gm['mutation']['evmExitCode'] not in [0, None]
    assert 'Name receipt mismatch (a)' in (mutant / 'evm.log').read_text()
    failed_receipt = json.loads((mutant / 'evm/case-0.json').read_text())
    assert failed_receipt['descriptor'] == '(a)' and failed_receipt['runtimeSha256'] == hashlib.sha256(candidate).hexdigest()
    evidence = {str(f.relative_to(ROOT)): sha(f) for f in gates.rglob('*') if f.is_file()}
    class_evm = HERE / 'development/name-class-gates-v1/evm'
    pinned_tools = json.loads((runtime_certificate / 'evm/toolchain.json').read_text())
    for directory in [gates / 'evm', class_evm, mutant / 'evm']:
        t = json.loads((directory / 'toolchain.json').read_text())
        for key, digest in [('nodeExecutable', 'nodeSha256'), ('hardhatEntry', 'hardhatEntrySha256'), ('edrEntry', 'edrEntrySha256'), ('nativeBinding', 'nativeBindingSha256')]:
            assert t[digest] == pinned_tools[digest] and sha(Path(pinned_tools[key])) == t[digest]
        assert sha(ROOT / 'pnpm-lock.yaml') == t['lockfileSha256']
        evidence.update({str(f.relative_to(ROOT)): sha(f) for f in directory.rglob('*') if f.is_file()})
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    subprocess.run(['python3', str(HERE / 'check-base-plain-fixtures.py'), str(out), str(gates / 'evm'), str(class_evm)], check=True)
    admission = json.loads((out / 'base-plain-admission.json').read_text())
    assert admission['runtimeSha256'] == r['runtimeSha256'] and admission['admittedCallCount'] == 23 and len(admission['cases']) == 14
    for case in admission['cases']:
        assert sha(Path(case['trace'])) == case['traceSha256']
    inputs = [Path(__file__).resolve(), HERE / 'check-base-plain-fixtures.py']
    for version in admission['bindings']:
        inputs.append(HERE / 'development' / version / 'inventory.json')
    source = {str(f.relative_to(ROOT)): sha(f) for f in inputs}
    result = {'status': 'passed', 'completedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'scope': 'Exact runtime-bound complete physical typeShape helper class for fitting nonempty scanner names without array suffixes, from PC8442 to actual return destination. Arbitrary name lengths, independent maximal endpoint, exact bytes/string dynamic classification and one-word footprint, with external frame preservation. Tuple/array/error classes and whole nav/get remain open.',
              'wholeEntry': False, 'nativeEntry': entry, 'nativeCertificate': str(native / 'manifest.json'),
              'nativeManifestSha256': sha(native / 'manifest.json'), 'runtimeCertificate': str(runtime_certificate / 'manifest.json'),
              'runtimeManifestSha256': sha(runtime_certificate / 'manifest.json'), 'runtimeSha256': r['runtimeSha256'],
              'sourceSha256': source, 'runtimeMatches': bindings, 'retainedEvidenceSha256': evidence,
              'publicReceipts': 14, 'admittedHelperExecutions': 23, 'mutation': gm['mutation'],
              'evidenceSha256': {'base-plain-admission.json': sha(out / 'base-plain-admission.json')},
              'assumptions': n['assumptions']}
    (out / 'manifest.json').write_text(json.dumps(result, indent=2) + '\n')
    print('PASS: plain-name typeShape admitted helper class; wholeEntry=false')


if __name__ == '__main__':
    main()
