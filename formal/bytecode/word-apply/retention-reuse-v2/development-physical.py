#!/usr/bin/env python3
"""Snapshot prepared physical fixture/candidate owners; no public native claim."""
import argparse
import datetime
import importlib.util
import json
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
spec = importlib.util.spec_from_file_location('retainer', HERE / 'verify.py')
v = importlib.util.module_from_spec(spec)
spec.loader.exec_module(v)


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    out = a.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    paths = v.inputs(json.loads((HERE / 'proof-spec.json').read_text()))
    hashes = {str(f.relative_to(ROOT)): v.sha(f) for f in paths}
    snap = out / 'source-snapshot'
    for f in paths:
        dest = snap / f.relative_to(ROOT)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(f, dest)
    m = dict(status='development-physical-running-not-retained', sourceSha256=hashes, checks=[],
             startedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),
             scope='Development complete PCzero physical receipts and same bytecode faults, no native/public proof coverage. Full fresh native/physical/semantic/independent retained evidence remains mandatory.')

    def save():
        (out / 'manifest.json').write_text(json.dumps(m, indent=2)+'\n')

    def record(name, cmd, expected=0):
        j = v.common.run(cmd, out / (name+'.log'), 600)
        j.update(name=name, passed=j['exitCode'] == expected)
        m['checks'].append(j)
        save()
        return j

    save()
    for script, suite, count, extra in [('evm-traces.mjs', 'evm-traces', 138, []), ('guard-traces.mjs', 'guard-traces', 12, ['--suite', 'guard'])]:
        j = record(suite, [shutil.which('node'), HERE / script, '--root', snap, '--output', out / suite, *extra])
        rows = json.loads((out / suite / 'results.json').read_text()) if (out / suite / 'results.json').is_file() else []
        j['passed'] = j['passed'] and len(rows) == count and len({r['name'] for r in rows}) == count and all(r['passed'] and r['receiptPassed'] for r in rows)
        save()
    record('candidates', [sys.executable, '-B', snap / HERE.relative_to(ROOT) / 'make-candidates.py', '--output', out / 'candidates'])
    candidates = json.loads((out / 'candidates/candidates.json').read_text())
    for c in candidates:
        j = record(c['name'], [shutil.which('node'), HERE / 'evm-traces.mjs', '--root', snap, '--output', out / c['name'], '--runtime', out / 'candidates' / c['runtime'], '--case', c['evmFixture']], expected=1)
        rows = json.loads((out / c['name'] / 'results.json').read_text()) if (out / c['name'] / 'results.json').is_file() else []
        j['passed'] = j['passed'] and len(rows) == 1 and rows[0]['name'] == c['evmFixture'] and not rows[0]['receiptPassed'] and rows[0]['runtimeSha256'] == c['runtimeSha256']
        save()
    m['inputsUnchanged'] = hashes == {str(f.relative_to(ROOT)): v.sha(f) for f in paths}
    ct = json.loads((out / 'evm-traces/toolchain.json').read_text())
    m['concreteToolchain'] = ct
    m['toolsUnchanged'] = all(v.sha(Path(ct[k])) == ct[k+'Sha256'] for k in ['hardhatEntry', 'edrEntry', 'nativeBinding']) and v.sha(Path(ct['nodeExecutable'])) == ct['nodeSha256'] and v.sha(ROOT / 'pnpm-lock.yaml') == ct['lockfileSha256']
    m['status'] = 'development-physical-passed-not-retained' if m['inputsUnchanged'] and m['toolsUnchanged'] and all(j['passed'] for j in m['checks']) else 'development-physical-failed'
    m['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    m['evidenceSha256'] = {str(f.relative_to(out)): v.sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name != 'manifest.json'}
    save()
    print(m['status'])
    raise SystemExit(0 if m['status'] == 'development-physical-passed-not-retained' else 1)


if __name__ == '__main__':
    main()
