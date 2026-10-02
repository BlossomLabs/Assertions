#!/usr/bin/env python3
"""Retain the identical complete mapWords/filterWords graph with checked native reuse.

Finish all package edits before launching. This script snapshots all owners and
includes, regenerates physical certificates, checks every declaration, and keeps
failed runs. It does not publish a ledger or assign public coverage.
"""
import argparse
import concurrent.futures
import csv
import datetime
import importlib.util
import json
import re
import shutil
import subprocess
import sys
import threading
from pathlib import Path

if not __debug__:
    raise RuntimeError('Run without Python -O')
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
ORIGINAL = ROOT / 'formal/bytecode/word-apply/retention'
DEPENDENCY = ROOT / 'formal/bytecode/rejections/evidence/operations-guard-current-inputs-v2/manifest.json'


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    obj = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(obj)
    return obj


getter = module('getter', ROOT / 'formal/bytecode/getters/verify.py')
reuse = module('word_apply_native_reuse', HERE/'reuse-native.py')
common = getter.common
sha = common.sha


def graph(spec):
    closed = set()

    def visit(path):
        path = path.resolve()
        assert path.is_relative_to(ROOT) and path.is_file()
        if path in closed:
            return
        closed.add(path)
        for inc in re.findall(r'^include "([^"]+)"', path.read_text(), re.M):
            visit(path.parent / inc)

    for root in spec['rootProofs']:
        visit(ROOT / root)
    names = [match[1] for f in closed if (match := re.search(r'^module (\w+)', f.read_text(), re.M))]
    assert len(names) == len(set(names)), 'Duplicate module owners in proof graph'
    return sorted(closed)


def inputs(spec):
    closed = graph(spec)
    folders = {f.parent for f in closed} | {HERE, ORIGINAL, HERE.parent / 'map-prefix', ROOT / 'formal/bytecode/rejections'}
    files = set(getter.inputs()) | set(closed) | {f for folder in folders for f in folder.iterdir() if f.is_file()}
    files |= {DEPENDENCY, ROOT / 'scripts/check-raw-rejections-bytecode-evidence.py', ROOT / 'docs/verification/raw-rejections-bytecode.json'}
    return sorted(files)


def dependencies():
    m = json.loads(DEPENDENCY.read_text())
    assert m['status'] == 'passed' and m['inputsUnchanged'] and all(j['passed'] for j in m['checks'])
    paths = {DEPENDENCY} | {DEPENDENCY.parent / name for name in m['evidenceSha256']}
    return {str(f.relative_to(ROOT)): sha(f) for f in sorted(paths)}


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--dafny', type=Path, required=True)
    p.add_argument('--solc', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--workers', type=int, default=2)
    p.add_argument('--reuse-native-from', type=Path, required=True)
    p.add_argument('--reuse-repair-from', type=Path)
    a = p.parse_args()
    assert 1 <= a.workers <= 4, 'Root allocation is at most eight native cores'
    out = a.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    dafny, solc = a.dafny.resolve(), a.solc.resolve()
    z3 = dafny.parent / 'z3/bin/z3-4.12.1'
    tools = {'dafny': dafny, 'Dafny.dll': dafny.parent / 'Dafny.dll', 'z3': z3, 'solc': solc}
    versions = {k: subprocess.check_output([str(v), '--version'], text=True).strip() for k, v in tools.items() if k != 'Dafny.dll'}
    assert versions['dafny'] == json.loads((ROOT / 'formal/abi/toolchain.json').read_text())['dafnyVersion']
    assert '4.12.1' in versions['z3'] and '0.8.36+commit.8a079791' in versions['solc']
    spec = json.loads((HERE / 'proof-spec.json').read_text())
    pin = json.loads((ROOT / 'formal/bytecode/dispatch/inventory.json').read_text())['Collections']
    assert pin['methodIdentifiers']['mapWords(bytes,address,bytes,uint256[])'] == spec['selectors']['mapWords']
    assert pin['methodIdentifiers']['filterWords(bytes,address,bytes,uint256[])'] == spec['selectors']['filterWords']
    paths, closed = inputs(spec), graph(spec)
    hashes = {str(f.relative_to(ROOT)): sha(f) for f in paths}
    reused, reuse_provenance = reuse.prepare(ROOT,a.reuse_native_from,spec,closed,hashes,{k:sha(v) for k,v in tools.items()},getter,common,out)
    repair_provenance = None
    if a.reuse_repair_from:
        repaired,repair_provenance = reuse.repair(ROOT,a.reuse_repair_from,spec,closed,{k:sha(v) for k,v in tools.items()},getter,common,out)
        assert not set(reused)&set(repaired)
        reused.update(repaired)
    dep = dependencies()
    snap = out / 'source-snapshot'
    for f in paths:
        dest = snap / f.relative_to(ROOT)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(f, dest)
    source = snap / HERE.relative_to(ROOT)
    lock = threading.Lock()
    m = dict(schemaVersion=1, status='incomplete', startedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),
             scope=spec['scope'], publicEntries=spec['publicEntries'], sourceSha256=hashes, dependencyEvidenceSha256=dep,
             dependencyGraph={str(f.relative_to(ROOT)): sha(f) for f in closed}, rootProofs=spec['rootProofs'],
             priorNativeEvidence=reuse_provenance, priorRepairEvidence=repair_provenance, versions=versions, executableSha256={k: sha(v) for k, v in tools.items()}, checks=[], assumptions=spec['assumptions'])

    def save():
        (out / 'manifest.json').write_text(json.dumps(m, indent=2)+'\n')

    def record(name, cmd, timeout=1200):
        name = name.replace('/', '-')
        j = common.run(cmd, out / (name+'.log'), timeout)
        j.update(name=name, passed=j['exitCode'] == 0)
        with lock:
            m['checks'].append(j)
            save()
        return j

    def stop_if_failed(message):
        if not all(j['passed'] for j in m['checks']):
            m['status'] = 'failed'
            m['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
            m['evidenceSha256'] = {str(f.relative_to(out)): sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name != 'manifest.json'}
            save()
            raise SystemExit(message)

    save()
    record('dependency-before', [sys.executable, '-B', ROOT / 'scripts/check-raw-rejections-bytecode-evidence.py'], 600)
    record('runtime-identity', [sys.executable, '-B', snap / 'formal/bytecode/dispatch/identity.py', '--solc', solc, '--output', out / 'identity'], 600)
    groups = []
    for folder in sorted({f.parent for f in closed if f.name.endswith('.generated.dfy')}):
        scripts = sorted(f.name for f in folder.glob('generate*.py'))
        assert scripts, 'Generated owner has no generator'
        package = str(folder.relative_to(ROOT))
        groups.append((package, scripts))
        generated = out / 'generated' / package
        generated.mkdir(parents=True)
        for gen in scripts:
            record('generation-'+package+'-'+gen, [sys.executable, '-B', snap / package / gen, '--output', generated], 300)
        expected = {f.name for f in folder.iterdir() if f.is_file() and f.name.endswith(('.generated.dfy', '.mapping.json'))}
        same = expected == {f.name for f in generated.iterdir()} and all((snap / package / name).read_bytes() == (generated / name).read_bytes() for name in expected)
        m['checks'].append(dict(name='regeneration-'+package, passed=same, expectedFiles=sorted(expected)))
        save()
    m['generatorGroups'] = groups
    adapter = out / 'predicate-parser-baseline'
    record('predicate-parser-baseline', [sys.executable, '-B', source / 'generate-predicate-candidate.py', '--output', adapter], 300)
    owner = snap / 'formal/bytecode/word-apply/predicate-error-repair-v3'
    m['checks'].append(dict(name='predicate-parser-baseline-identical', passed=all((owner / name).read_bytes() == (adapter / name).read_bytes() for name in ['Predicate.generated.dfy', 'Predicate.mapping.json'])))
    serializer_adapter = out / 'serializer-parser-baseline'
    record('serializer-parser-baseline', [sys.executable, '-B', source / 'generate-serializer-candidate.py', '--output', serializer_adapter], 300)
    serializer_owner = snap / 'formal/bytecode/word-apply/serializer-repair-v2'
    m['checks'].append(dict(name='serializer-parser-baseline-identical', passed=all((serializer_owner / name).read_bytes() == (serializer_adapter / name).read_bytes() for name in ['Control.generated.dfy', 'Control.mapping.json'])))
    save()
    record('format', [dafny, 'format', '--check', *[snap / f.relative_to(ROOT) for f in closed]], 600)
    stop_if_failed('Pre-native dependency/identity/generation/format gate failed')

    def prove(path):
        file = snap / path.relative_to(ROOT)
        mod = re.search(r'^module (\w+)', file.read_text(), re.M)[1]
        name = 'proof-'+mod
        if name in reused:
            j = reused[name]
            with lock:
                m['checks'].append(j)
                save()
            return j
        assert name in reuse.EXPECTED_TIMEOUTS, 'Unreviewed native retry'
        csvpath = out / (name+'.csv')
        cmd = common.proof_command(dafny,file,csvpath)
        assert cmd.count('--verification-time-limit') == 1
        cmd[cmd.index('--verification-time-limit')+1] = '120'
        j = record(name,cmd+['--filter-symbol',mod,'--filter-position',str(file),'--progress','Symbol'],7200)
        common.check_proof(j,out/(name+'.log'),csvpath,getter.inventory(path))
        j['nativeEvidenceOrigin']='fresh-complete-module-unchanged-statements-120-second-ordinary-allowance'
        with lock:
            save()
        return j

    module_files = [f for f in closed if re.search(r'^module (\w+)', f.read_text(), re.M)]
    m['includeOnlyFiles'] = [str(f.relative_to(ROOT)) for f in closed if f not in module_files]
    # Include-only forwarding files have no declarations. Every module they
    # transitively include is independently inventoried and proved here.
    with concurrent.futures.ThreadPoolExecutor(max_workers=a.workers) as pool:
        jobs = list(pool.map(prove, module_files))
    for root in spec['rootProofs']:
        name = 'audit-'+Path(root).parent.name
        j = record(name, [dafny, 'audit', snap / root], 600)
        j['passed'] = j['passed'] and 'auditor completed with 0 findings' in (out / (name+'.log')).read_text()
        save()
    m['nativeResults'] = [r for j in jobs for r in j['nativeResults']]
    m['declarationResults'] = [d for j in jobs for d in j['declarations']]
    m['nativeObligations'] = len(m['nativeResults'])
    stop_if_failed('Complete native graph/inventory/audit gate failed')
    for script, suite, count, extra in [('evm-traces.mjs', 'evm-traces', 138, []), ('guard-traces.mjs', 'guard-traces', 12, ['--suite', 'guard'])]:
        j = record(suite, [shutil.which('node'), HERE / script, '--output', out / suite, '--root', snap, *extra], 600)
        rows = json.loads((out / suite / 'results.json').read_text()) if (out / suite / 'results.json').is_file() else []
        j['passed'] = j['passed'] and len(rows) == count and len({r['name'] for r in rows}) == count and all(r['passed'] and r['receiptPassed'] for r in rows)
        save()
    m['concreteToolchain'] = json.loads((out / 'evm-traces/toolchain.json').read_text())
    stop_if_failed('Complete physical receipt/observation gate failed')
    record('candidate-generation', [sys.executable, '-B', source / 'make-candidates.py', '--output', out / 'candidates'], 300)
    candidates = json.loads((out / 'candidates/candidates.json').read_text())
    faults = []
    for candidate in candidates:
        name = candidate['name']
        folder = out / 'mutations' / name
        folder.mkdir(parents=True)
        work = folder / 'source-snapshot'
        shutil.copytree(snap, work)
        runtime = out / 'candidates' / candidate['runtime']
        artifact = work / 'artifacts/contracts/Collections.sol/Collections.json'
        obj = json.loads(artifact.read_text())
        obj['deployedBytecode'] = '0x'+runtime.read_bytes().hex()
        artifact.write_text(json.dumps(obj, indent=2)+'\n')
        inventory = work / 'formal/bytecode/dispatch/inventory.json'
        obj = json.loads(inventory.read_text())
        obj['Collections']['runtimeSha256'] = sha(runtime)
        inventory.write_text(json.dumps(obj, indent=2)+'\n')
        package = work / candidate['package']
        translated = record(name+'-generation', [sys.executable, '-B', work / candidate['generator'], '--output', package], 300)
        stop_if_failed('Candidate extraction failed; not a semantic mutation result')
        file = package / candidate['source']
        lines = file.read_text().splitlines()
        method = candidate['nativeSymbol'].split('.')[-1]
        start = next(i for i, line in enumerate(lines) if 'lemma '+method+'(' in line)
        anchor = next(i for i in range(start, len(lines)) if 'ensures var next :=' in lines[i])
        baseline = next(d for d in m['declarationResults'] if d['name'] == candidate['nativeSymbol'])
        assert baseline['status'] == 'passed'
        native = record(name+'-native', common.proof_command(dafny, file, folder / 'proof.csv')+['--filter-symbol', candidate['nativeSymbol'], '--filter-position', str(file)+':'+str(anchor+1), '--progress', 'Symbol'], 600)
        log = (out / (name+'-native.log')).read_text()
        rows = list(csv.DictReader((folder / 'proof.csv').open())) if (folder / 'proof.csv').is_file() else []
        native['passed'] = native['exitCode'] not in [0, None] and bool(rows) and any(r['TestResult.Outcome'] == 'Failed' for r in rows) and all(r['TestResult.Outcome'] in {'Passed', 'Failed'} for r in rows) and 'postcondition could not be proved' in log and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call', log, re.I)
        physical = record(name+'-concrete', [shutil.which('node'), HERE / 'evm-traces.mjs', '--output', folder / 'evm-traces', '--root', snap, '--runtime', runtime, '--case', candidate['evmFixture']], 300)
        receipts = json.loads((folder / 'evm-traces/results.json').read_text()) if (folder / 'evm-traces/results.json').is_file() else []
        physical['passed'] = physical['exitCode'] not in [0, None] and len(receipts) == 1 and receipts[0]['name'] == candidate['evmFixture'] and not receipts[0]['receiptPassed']
        faults.append(dict(candidate=candidate, baselineCoveredSymbol=candidate['nativeSymbol'], semanticAssertion=dict(line=anchor+1, text=lines[anchor]), checks=[translated, native, physical], contradictoryReceipts=receipts))
        save()
    (out / 'mutations/results.json').write_text(json.dumps(faults, indent=2)+'\n')
    record('dependency-after', [sys.executable, '-B', ROOT / 'scripts/check-raw-rejections-bytecode-evidence.py'], 600)
    m['priorManifestUnchanged'] = sha(a.reuse_native_from) == reuse_provenance['manifestSha256'] and (not a.reuse_repair_from or sha(a.reuse_repair_from)==repair_provenance['manifestSha256'])
    m['inputsUnchanged'] = hashes == {str(f.relative_to(ROOT)): sha(f) for f in inputs(spec)}
    m['dependenciesUnchanged'] = dep == dependencies()
    m['toolsUnchanged'] = m['executableSha256'] == {k: sha(v) for k, v in tools.items()}
    ct = m['concreteToolchain']
    m['concreteToolsUnchanged'] = all(sha(Path(ct[k])) == ct[k+'Sha256'] for k in ['hardhatEntry', 'edrEntry', 'nativeBinding']) and sha(Path(ct['nodeExecutable'])) == ct['nodeSha256'] and sha(ROOT / 'pnpm-lock.yaml') == ct['lockfileSha256']
    m['status'] = 'passed' if m['priorManifestUnchanged'] and m['inputsUnchanged'] and m['dependenciesUnchanged'] and m['toolsUnchanged'] and m['concreteToolsUnchanged'] and all(j['passed'] for j in m['checks']) else 'failed'
    m['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    m['evidenceSha256'] = {str(f.relative_to(out)): sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name != 'manifest.json'}
    save()
    print(m['status'])
    raise SystemExit(0 if m['status'] == 'passed' else 1)


if __name__ == '__main__':
    main()
