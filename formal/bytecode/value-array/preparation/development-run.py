#!/usr/bin/env python3
"""Complete the explicitly selected native module gaps, without public credit.

Finish this owner's files before launch. A complete retained graph, compiler
identity, generated-owner reproduction, physical/source/bytecode faults and
independent checker are separate required gates. Observation timeouts never
cancel or restart a proof: each child is waited to actual termination.
"""
import argparse
import concurrent.futures
import datetime
import importlib.util
import json
import re
import shutil
import subprocess
import threading
import time
from pathlib import Path

if not __debug__:
    raise RuntimeError('Run without Python -O')
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    obj = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(obj)
    return obj


getter = load('array_closure_getter', ROOT / 'formal/bytecode/getters/verify.py')
common = getter.common
sha = common.sha


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
    return sorted(closed)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--dafny', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--workers', type=int, default=3)
    args = parser.parse_args()
    assert 1 <= args.workers <= 3, 'Root allocation is at most six native cores'
    scope = json.loads((HERE / 'scope.json').read_text())
    selected = [ROOT / p for p in scope['selectedSources']]
    assert len(selected) == len(set(selected)) == scope['selectedModuleCount']
    modules = [re.search(r'^module (\w+)', p.read_text(), re.M)[1] for p in selected]
    assert len(modules) == len(set(modules))
    dafny = args.dafny.resolve()
    tools = {'dafny': dafny, 'Dafny.dll': dafny.parent / 'Dafny.dll',
             'z3': dafny.parent / 'z3/bin/z3-4.12.1'}
    versions = {k: subprocess.check_output([str(v), '--version'], text=True).strip()
                for k, v in tools.items() if k != 'Dafny.dll'}
    assert versions['dafny'] == json.loads((ROOT / 'formal/abi/toolchain.json').read_text())['dafnyVersion']
    assert '4.12.1' in versions['z3']
    closed = graph(selected)
    folders = {p.parent for p in closed} | {HERE}
    paths = set(closed) | set(getter.inputs()) | {
        p for folder in folders for p in folder.iterdir() if p.is_file()}
    hashes = {str(p.relative_to(ROOT)): sha(p) for p in sorted(paths)}
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    snap = out / 'source-snapshot'
    for path in sorted(paths):
        dest = snap / path.relative_to(ROOT)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, dest)
    m = dict(status='development-running-not-retained',
             startedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),
             scope=scope['scope'], assumptions=scope['assumptions'],
             selectedSources=scope['selectedSources'],
             sourceSha256=hashes, dependencyGraph={str(p.relative_to(ROOT)): sha(p) for p in closed},
             executableSha256={k: sha(v) for k, v in tools.items()}, versions=versions, checks=[])
    lock = threading.Lock()

    def save():
        (out / 'manifest.json').write_text(json.dumps(m, indent=2)+'\n')

    def run(name, command):
        started = time.monotonic()
        with (out / (name+'.log')).open('w') as stream:
            process = subprocess.Popen(list(map(str, command)), stdout=stream,
                                       stderr=subprocess.STDOUT)
            code = process.wait()
        job = dict(name=name, command=list(map(str, command)), exitCode=code,
                   seconds=round(time.monotonic()-started, 3), log=name+'.log', passed=code == 0)
        with lock:
            m['checks'].append(job)
            save()
        return job

    save()
    exclusions = scope['formatExclusions']
    for relative, digest in exclusions.items():
        assert hashes[relative] == digest and not relative.endswith('.generated.dfy')
    m['formatExclusions'] = exclusions
    run('format', [dafny, 'format', '--check', *[snap / p.relative_to(ROOT) for p in selected if str(p.relative_to(ROOT)) not in exclusions]])
    if not m['checks'][0]['passed']:
        jobs = []
    else:
        def prove(path):
            mod = re.search(r'^module (\w+)', path.read_text(), re.M)[1]
            source = snap / path.relative_to(ROOT)
            name = 'proof-'+mod
            csv_path = out / (name+'.csv')
            job = run(name, common.proof_command(dafny, source, csv_path) +
                      ['--filter-symbol', mod, '--filter-position', str(source), '--progress', 'Symbol'])
            common.check_proof(job, out / (name+'.log'), csv_path, getter.inventory(path))
            with lock:
                save()
            audit = run('audit-'+mod, [dafny, 'audit', source])
            audit['passed'] = audit['passed'] and 'auditor completed with 0 findings' in (out / audit['log']).read_text()
            with lock:
                save()
            print(mod, 'passed' if job['passed'] else 'FAILED', len(job['nativeResults']), flush=True)
            return job

        with concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as pool:
            jobs = list(pool.map(prove, selected))
    m['nativeResults'] = [r for j in jobs for r in j['nativeResults']]
    m['declarationResults'] = [d for j in jobs for d in j['declarations']]
    m['nativeObligations'] = len(m['nativeResults'])
    m['inputsUnchanged'] = all(sha(ROOT / k) == v and sha(snap / k) == v for k, v in hashes.items())
    m['toolsUnchanged'] = m['executableSha256'] == {k: sha(v) for k, v in tools.items()}
    passed = len(jobs) == len(selected) and m['inputsUnchanged'] and m['toolsUnchanged'] and all(j['passed'] for j in m['checks'])
    m['status'] = 'development-native-passed-not-retained' if passed else 'development-native-failed'
    m['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    m['evidenceSha256'] = {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*'))
                          if p.is_file() and p.name != 'manifest.json'}
    save()
    print(m['status'], 'selected modules', len(jobs), 'native rows', m['nativeObligations'], flush=True)
    raise SystemExit(0 if passed else 1)


if __name__ == '__main__':
    main()
