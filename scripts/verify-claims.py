#!/usr/bin/env python3
"""Inventory every check_* property and retain bounded Halmos run provenance.

Run after `forge build`. No property, timeout, or blocked path is silently omitted.
An outer watchdog protects against path exploration stalls without overriding
Halmos's solver timeouts or per-property annotations. Incomplete is not proved.
"""
import argparse
import concurrent.futures
import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import signal
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]

def capture(args):
    return subprocess.check_output(args, cwd=ROOT, text=True, stderr=subprocess.STDOUT).strip()

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', default='docs/verification/2026-09-29')
    parser.add_argument('--workers', type=int, default=4)
    parser.add_argument('--wall-timeout', type=int, default=900)
    parser.add_argument('--resume', action='store_true')
    args = parser.parse_args()
    dest = (ROOT / args.output).resolve()
    dest.mkdir(parents=True, exist_ok=True)
    inventory = []
    for path in sorted((ROOT / 'contracts/tests').glob('*.t.sol')):
        source = path.read_text()
        contracts = list(re.finditer(r'^contract\s+(\w+)\b', source, re.M))
        for match in re.finditer(r'^\s+function\s+(check_\w+)\s*\(', source, re.M):
            owner = next(m[1] for m in reversed(contracts) if m.start() < match.start())
            inventory.append({'source': str(path.relative_to(ROOT)), 'contract': owner, 'property': match[1]})
    if not inventory:
        raise SystemExit('No symbolic properties found')
    halmos_bin = Path(shutil.which('halmos')).resolve()
    solver_bin = shutil.which('yices-smt2') or str(halmos_bin.parent / 'yices-smt2')
    forge_config = json.loads(capture(['forge', 'config', '--json']))
    hashes = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in sorted((ROOT / 'contracts').rglob('*.sol'))}
    # Source hashes also identify dirty working trees, avoiding a false claim
    # that the parent commit alone identifies the code under verification.
    manifest = {'schemaVersion': 1, 'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
                'revision': capture(['git', 'rev-parse', 'HEAD']),
                'workingTree': capture(['git', 'status', '--porcelain']),
                'sourceSha256': hashes,
                'versions': {'halmos': capture(['halmos', '--version']), 'forge': capture(['forge', '--version']),
                             'solver': capture([solver_bin, '--version'])},
                'compiler': {k: forge_config[k] for k in ['solc', 'evm_version', 'optimizer', 'optimizer_runs', 'via_ir', 'bytecode_hash']},
                'runnerSha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                'bounds': {'loop': 70, 'defaultBytesLengths': [0,1,31,32,33,64,65],
                           'solverThreads': 2, 'wallTimeoutSeconds': args.wall_timeout,
                           'solverTimeouts': 'Halmos defaults and per-property annotations, unmodified'},
                'gasModel': 'No concrete gas model; explicit outOfGasArtifact assumptions exclude symbolic exhaustion. GasPropagationTest supplies concrete evidence.',
                'inventoryCount': len(inventory), 'results': []}
    manifest['configurationSha256'] = {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest()
                                     for p in ['foundry.toml', 'hardhat.config.ts', 'package.json', 'pnpm-lock.yaml']}
    old = {}
    if args.resume and (dest / 'manifest.json').exists():
        prior = json.loads((dest / 'manifest.json').read_text())
        if prior['sourceSha256'] != hashes:
            raise SystemExit('Sources changed: choose a new output directory, do not merge different baselines')
        old = {r['contract']+'.'+r['property']: r for r in prior['results']}
    def save():
        manifest['results'].sort(key=lambda r: (r['contract'], r['property']))
        (dest / 'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    def run(item):
        key = item['contract']+'.'+item['property']
        if key in old:
            return old[key]
        command = ['halmos', '--contract', item['contract'], '--match-test', '^'+item['property']+r'\(',
                   '--loop', '70', '--default-bytes-lengths', '0,1,31,32,33,64,65',
                   '--solver-threads', '2', '--no-status', '--json-output', str(dest / (key+'.json'))]
        result = dict(item, command=command, log=key+'.log', json=key+'.json')
        start = time.monotonic()
        with (dest / result['log']).open('w') as log:
            proc = subprocess.Popen(command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
            try:
                result['exitCode'] = proc.wait(timeout=args.wall_timeout)
            except subprocess.TimeoutExpired:
                os.killpg(proc.pid, signal.SIGTERM)
                try: proc.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    os.killpg(proc.pid, signal.SIGKILL); proc.wait()
                result['exitCode'] = None
                result['reason'] = 'Property wall-time watchdog expired; solver settings were not changed'
        result['seconds'] = round(time.monotonic()-start, 3)
        result['status'] = 'incomplete'
        report = dest / result['json']
        if report.exists():
            data = json.loads(report.read_text())
            tests = [r for values in (data.get('test_results') or {}).values() for r in values]
            result['observedCount'] = len(tests)
            if len(tests) == 1 and tests[0]['name'].split('(')[0] == item['property']:
                test = tests[0]
                result['halmos'] = test
                if test['exitcode'] == 1: result['status'] = 'failed'
                elif (result['exitCode'] == 0 and test['exitcode'] == 0 and not test.get('num_bounded_loops')
                      and test.get('num_paths') and test['num_paths'][1] > 0 and test['num_paths'][2] == 0):
                    result['status'] = 'passed'
            else: result['reason'] = 'Expected exactly one matching property'
        else: result.setdefault('reason', 'No machine-readable Halmos result')
        logtext = (dest / result['log']).read_text()
        result['warnings'] = [line for line in logtext.splitlines() if re.search(r'warning|NotConcreteError|loop.bound|timeout', line, re.I)]
        if result['status'] == 'passed' and any(re.search(r'loop.bound|NotConcreteError', w, re.I) for w in result['warnings']):
            result['status'] = 'incomplete'
        return result
    save()
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as pool:
        for future in concurrent.futures.as_completed([pool.submit(run, item) for item in inventory]):
            result = future.result()
            manifest['results'].append(result)
            save()
            print(f"{len(manifest['results'])}/{len(inventory)} {result['status']}: {result['contract']}.{result['property']}", flush=True)
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['summary'] = {s: sum(r['status']==s for r in manifest['results']) for s in ['passed','failed','incomplete']}
    save()
    print(json.dumps(manifest['summary']), flush=True)
    return 1 if manifest['summary']['failed'] or manifest['summary']['incomplete'] else 0

if __name__ == '__main__':
    raise SystemExit(main())
