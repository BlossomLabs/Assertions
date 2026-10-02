#!/usr/bin/env python3
"""Baseline and mutant selected semantic assertions; development evidence only."""
import argparse
import csv
import datetime
import importlib.util
import json
import re
import shutil
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
    dafny = Path('/tmp/assertions-dafny-4.11.0/dafny/dafny')
    tools = {'dafny': dafny, 'Dafny.dll': dafny.parent / 'Dafny.dll', 'z3': dafny.parent / 'z3/bin/z3-4.12.1'}
    tool_hashes = {k: v.sha(f) for k, f in tools.items()}
    m = dict(status='development-semantic-running-not-retained', sourceSha256=hashes, executableSha256=tool_hashes,
             checks=[], faults=[], startedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),
             scope='Selected baseline semantic postconditions and matching ordinary native/PCzero receipt contradictions. Included contracts are assumed; fresh full retained graph and independent checker remain mandatory. No public proof coverage.')

    def save():
        (out / 'manifest.json').write_text(json.dumps(m, indent=2)+'\n')

    def record(name, cmd):
        j = v.common.run(cmd, out / (name+'.log'), 600)
        j.update(name=name, passed=j['exitCode'] == 0)
        m['checks'].append(j)
        save()
        return j

    def selected(file, candidate, name, expected_fault):
        lines = file.read_text().splitlines()
        method = candidate['nativeSymbol'].split('.')[-1]
        start = next(i for i, line in enumerate(lines) if 'lemma '+method+'(' in line)
        anchor = next(i for i in range(start, len(lines)) if 'ensures var next :=' in lines[i])
        csvpath = out / (name+'.csv')
        j = record(name, v.common.proof_command(dafny, file, csvpath)+['--filter-symbol', candidate['nativeSymbol'], '--filter-position', str(file)+':'+str(anchor+1), '--progress', 'Symbol'])
        rows = list(csv.DictReader(csvpath.open())) if csvpath.is_file() else []
        log = (out / (name+'.log')).read_text()
        valid = bool(rows) and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call', log, re.I)
        if expected_fault:
            j['passed'] = valid and j['exitCode'] not in [0, None] and any(r['TestResult.Outcome'] == 'Failed' for r in rows) and all(r['TestResult.Outcome'] in {'Passed', 'Failed'} for r in rows) and 'postcondition could not be proved' in log
        else:
            j['passed'] = valid and j['exitCode'] == 0 and all(r['TestResult.Outcome'] == 'Passed' for r in rows)
        j['nativeResults'] = rows
        save()
        return dict(symbol=candidate['nativeSymbol'], line=anchor+1, assertion=lines[anchor], check=j)

    save()
    record('candidates', [sys.executable, '-B', snap / HERE.relative_to(ROOT) / 'make-candidates.py', '--output', out / 'candidates'])
    candidates = json.loads((out / 'candidates/candidates.json').read_text())
    for c in candidates:
        name = c['name']
        baseline = selected(snap / c['package'] / c['source'], c, name+'-baseline', False)
        work = out / 'mutations' / name / 'source-snapshot'
        shutil.copytree(snap, work)
        runtime = out / 'candidates' / c['runtime']
        artifact = work / 'artifacts/contracts/Collections.sol/Collections.json'
        obj = json.loads(artifact.read_text())
        obj['deployedBytecode'] = '0x'+runtime.read_bytes().hex()
        artifact.write_text(json.dumps(obj, indent=2)+'\n')
        pin = work / 'formal/bytecode/dispatch/inventory.json'
        obj = json.loads(pin.read_text())
        obj['Collections']['runtimeSha256'] = v.sha(runtime)
        pin.write_text(json.dumps(obj, indent=2)+'\n')
        translation = record(name+'-generation', [sys.executable, '-B', work / c['generator'], '--output', work / c['package']])
        if not translation['passed']:
            m['faults'].append(dict(candidate=c, baseline=baseline, translation=translation, scope='Extraction failure is not a semantic contradiction'))
            save()
            continue
        native = selected(work / c['package'] / c['source'], c, name+'-native', True)
        physical = record(name+'-concrete', [shutil.which('node'), HERE / 'evm-traces.mjs', '--root', snap, '--output', out / name, '--runtime', runtime, '--case', c['evmFixture']])
        rows = json.loads((out / name / 'results.json').read_text()) if (out / name / 'results.json').is_file() else []
        physical['passed'] = physical['exitCode'] not in [0, None] and len(rows) == 1 and rows[0]['name'] == c['evmFixture'] and not rows[0]['receiptPassed'] and rows[0]['runtimeSha256'] == c['runtimeSha256']
        m['faults'].append(dict(candidate=c, baseline=baseline, native=native, physical=physical, contradictoryReceipts=rows))
        save()
    m['inputsUnchanged'] = hashes == {str(f.relative_to(ROOT)): v.sha(f) for f in paths}
    m['toolsUnchanged'] = tool_hashes == {k: v.sha(f) for k, f in tools.items()}
    m['status'] = 'development-semantic-passed-not-retained' if m['inputsUnchanged'] and m['toolsUnchanged'] and len(m['faults']) == 3 and all(j['passed'] for j in m['checks']) else 'development-semantic-failed'
    m['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    m['evidenceSha256'] = {str(f.relative_to(out)): v.sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name != 'manifest.json'}
    save()
    print(m['status'])
    raise SystemExit(0 if m['status'] == 'development-semantic-passed-not-retained' else 1)


if __name__ == '__main__':
    main()
