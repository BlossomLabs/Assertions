#!/usr/bin/env python3
"""Retain the full current public fold graph, compiler and semantic evidence.

Finish every package/checker/source list edit before launch. Never assign a
ledger or public coverage here. A separate independent checker is mandatory.
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
import time
from pathlib import Path

if not __debug__:
    raise RuntimeError('Run without Python -O')
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
DEPENDENCY = ROOT / 'formal/bytecode/rejections/evidence/operations-guard-current-inputs-v2/manifest.json'
SOURCE_OWNER = ROOT / 'formal/collections/word-fold-entry'


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    obj = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(obj)
    return obj


getter = load('fold_retained_getter', ROOT / 'formal/bytecode/getters/verify.py')
reuse = load('fold_retained_reuse', HERE / 'reuse-native.py')
source_verifier = load('fold_retained_source_verifier', SOURCE_OWNER / 'verify.py')
common, sha = getter.common, getter.sha


def graph(spec):
    return reuse.graph([ROOT / p for p in spec['rootProofs']])


def inputs(spec):
    closed = graph(spec)
    owners = {p.parent for p in closed} | {HERE, ROOT / spec['physicalOwner']}
    owners |= {ROOT / relative for relative in spec['supportOwners']}
    files = set(closed) | set(getter.inputs()) | set(source_verifier.inputs())
    files |= {ROOT / relative for relative in spec['generationSupportFiles']}
    files |= {p for folder in owners for p in folder.iterdir() if p.is_file()}
    files |= {DEPENDENCY, ROOT / 'scripts/check-raw-rejections-bytecode-evidence.py',
              ROOT / 'docs/verification/raw-rejections-bytecode.json',
              ROOT / 'scripts/check-fold-words-bytecode-v14-evidence.py',
              ROOT / 'scripts/check-collections-word-fold-entry-evidence.py',
              ROOT / 'docs/verification/collections-word-fold-entry-source-connection.json'}
    return sorted(files)


def dependencies():
    m = json.loads(DEPENDENCY.read_text())
    assert m['status'] == 'passed' and m['inputsUnchanged'] and all(j['passed'] for j in m['checks'])
    files = {DEPENDENCY} | {DEPENDENCY.parent / name for name in m['evidenceSha256']}
    return {str(p.relative_to(ROOT)): sha(p) for p in sorted(files)}


def source_campaign_config(solc):
    return '[profile.default]\nsrc="contracts"\ntest="formal/collections"\nlibs=["node_modules"]\nremappings=["@openzeppelin/contracts/=node_modules/@openzeppelin/contracts/"]\nsolc='+json.dumps(str(solc))+'\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\n[lint]\nlint_on_build=false\n'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--dafny', type=Path, required=True)
    parser.add_argument('--solc', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--workers', type=int, default=3)
    args = parser.parse_args()
    assert 1 <= args.workers <= 3, 'At most six root native cores'
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    dafny, solc = args.dafny.resolve(), args.solc.resolve()
    tools = {'dafny': dafny, 'Dafny.dll': dafny.parent / 'Dafny.dll',
             'z3': dafny.parent / 'z3/bin/z3-4.12.1', 'solc': solc}
    tool_hashes = {k: sha(v) for k, v in tools.items()}
    versions = {k: subprocess.check_output([str(v), '--version'], text=True).strip()
                for k, v in tools.items() if k != 'Dafny.dll'}
    assert versions['dafny'] == json.loads((ROOT / 'formal/abi/toolchain.json').read_text())['dafnyVersion']
    assert '4.12.1' in versions['z3'] and '0.8.36+commit.8a079791' in versions['solc']
    spec = json.loads((HERE / 'proof-spec.json').read_text())
    pin = json.loads((ROOT / 'formal/bytecode/dispatch/inventory.json').read_text())['Collections']
    for mode in ['Range', 'Bytes', 'Words']:
        signature = 'fold'+mode+'(' + ('uint256' if mode == 'Range' else 'bytes') + ',address,bytes,uint256,uint256[],bytes32,uint8)'
        assert pin['methodIdentifiers'][signature] == spec['selectors']['fold'+mode]
    closed = graph(spec)
    module_files = [p for p in closed if re.search(r'^module (\w+)', p.read_text(), re.M)]
    assert len(module_files) == 208 and len(closed) - len(module_files) == 2
    hashes = {str(p.relative_to(ROOT)): sha(p) for p in inputs(spec)}
    sources = [ROOT / p for p in json.loads((HERE / 'native-sources.json').read_text())]
    reused, provenance = reuse.prepare(sources, [ROOT / p for p in spec['rootProofs']], tool_hashes, out)
    (out / 'native-provenance.json').write_text(json.dumps(provenance, indent=2)+'\n')
    dep = dependencies()
    snap = out / 'source-snapshot'
    for relative in hashes:
        dest = snap / relative
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(ROOT / relative, dest)
    source = snap / HERE.relative_to(ROOT)
    forge = Path(shutil.which('forge')).resolve()
    m = dict(schemaVersion=1, status='incomplete',
             startedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),
             scope=spec['scope'], assumptions=spec['assumptions'], publicEntries=spec['publicEntries'],
             rootProofs=spec['rootProofs'], sourceSha256=hashes,
             dependencyGraph={str(p.relative_to(ROOT)): sha(p) for p in closed},
             dependencyEvidenceSha256=dep, nativeProvenance=provenance,
             executableSha256=tool_hashes, versions=versions, checks=[],
             sourceConcreteTool=dict(executable=str(forge), sha256=sha(forge),
                                     version=subprocess.check_output([forge, '--version'], text=True).strip()))
    lock = threading.Lock()

    def save():
        (out / 'manifest.json').write_text(json.dumps(m, indent=2)+'\n')

    def record(name, command):
        started = time.monotonic()
        with (out / (name+'.log')).open('w') as stream:
            process = subprocess.Popen(list(map(str, command)), stdout=stream, stderr=subprocess.STDOUT)
            code = process.wait()
        job = dict(name=name, command=list(map(str, command)), exitCode=code,
                   seconds=round(time.monotonic()-started, 3), log=name+'.log', passed=code == 0)
        with lock:
            m['checks'].append(job)
            save()
        return job

    def finish():
        m['inputsUnchanged'] = hashes == {str(p.relative_to(ROOT)): sha(p) for p in inputs(spec)}
        m['snapshotsUnchanged'] = all(sha(snap / k) == v for k, v in hashes.items())
        m['dependenciesUnchanged'] = dep == dependencies()
        m['toolsUnchanged'] = tool_hashes == {k: sha(v) for k, v in tools.items()} and sha(forge) == m['sourceConcreteTool']['sha256']
        m['priorManifestsUnchanged'] = all(sha(ROOT / p['manifest']) == p['manifestSha256'] for p in provenance['provenance'])
        m['status'] = 'passed' if all(m[k] for k in ['inputsUnchanged', 'snapshotsUnchanged', 'dependenciesUnchanged', 'toolsUnchanged', 'priorManifestsUnchanged']) and all(j['passed'] for j in m['checks']) else 'failed'
        m['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
        m['evidenceSha256'] = {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name != 'manifest.json'}
        save()

    def stop_if_failed(message):
        if not all(j['passed'] for j in m['checks']):
            finish()
            raise SystemExit(message)

    save()
    record('dispatcher-dependency-before', [sys.executable, '-B', ROOT / 'scripts/check-raw-rejections-bytecode-evidence.py'])
    record('conditional-source-dependency-before', [sys.executable, '-B', ROOT / 'scripts/check-collections-word-fold-entry-evidence.py'])
    record('runtime-identity', [sys.executable, '-B', snap / 'formal/bytecode/dispatch/identity.py', '--solc', solc, '--output', out / 'identity'])
    groups = []
    for folder in sorted({p.parent for p in closed if p.name.endswith('.generated.dfy')}):
        generators = sorted(p.name for p in folder.glob('generate*.py'))
        assert generators, 'Generated owner without generator'
        relative = str(folder.relative_to(ROOT))
        groups.append([relative, generators])
        generated = out / 'generated' / relative
        generated.mkdir(parents=True)
        for generator in generators:
            record('generation-'+relative.replace('/', '-')+'-'+generator,
                   [sys.executable, '-B', snap / relative / generator, '--output', generated])
        names = {p.name for p in folder.iterdir() if p.is_file() and p.name.endswith(('.generated.dfy', '.mapping.json'))}
        same = names == {p.name for p in generated.iterdir()} and all((snap / relative / name).read_bytes() == (generated / name).read_bytes() for name in names)
        m['checks'].append(dict(name='regeneration-'+relative, passed=same, expectedFiles=sorted(names)))
        save()
    m['generatorGroups'] = groups
    for adapter, owner in [('scalar', 'scalar-return'), ('error', 'callback-failed-repair-v2')]:
        generated = out / (adapter+'-parser-baseline')
        record(adapter+'-parser-baseline', [sys.executable, '-B', source / ('generate-'+adapter+'-candidate.py'), '--output', generated])
        folder = snap / 'formal/bytecode/word-fold' / owner
        names = {p.name for p in folder.iterdir() if p.is_file() and p.name.endswith(('.generated.dfy', '.mapping.json'))}
        m['checks'].append(dict(name=adapter+'-parser-baseline-identical', passed=names == {p.name for p in generated.iterdir()} and all((folder / name).read_bytes() == (generated / name).read_bytes() for name in names)))
        save()
    exclusions = spec['formatExclusions']
    for relative, digest in exclusions.items():
        assert hashes[relative] == digest and not relative.endswith('.generated.dfy')
    m['formatExclusions'] = exclusions
    record('format', [dafny, 'format', '--check', *[snap / p.relative_to(ROOT) for p in closed if str(p.relative_to(ROOT)) not in exclusions]])
    stop_if_failed('Pre-native retained gate failed; no public evidence')

    def prove(path):
        mod = re.search(r'^module (\w+)', path.read_text(), re.M)[1]
        name = 'proof-'+mod
        if name in reused:
            job = reused[name]
            with lock:
                m['checks'].append(job)
                save()
            return job
        file = snap / path.relative_to(ROOT)
        csv_path = out / (name+'.csv')
        job = record(name, common.proof_command(dafny, file, csv_path) +
                     ['--filter-symbol', mod, '--filter-position', str(file), '--progress', 'Symbol'])
        common.check_proof(job, out / (name+'.log'), csv_path, getter.inventory(path))
        job['nativeEvidenceOrigin'] = 'fresh-complete-current-module-standard-30-second-allowance'
        with lock:
            save()
        return job

    with concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as pool:
        jobs = list(pool.map(prove, module_files))
    m['includeOnlyFiles'] = [str(p.relative_to(ROOT)) for p in closed if p not in module_files]
    m['nativeResults'] = [r for j in jobs for r in j['nativeResults']]
    m['declarationResults'] = [d for j in jobs for d in j['declarations']]
    m['nativeObligations'] = len(m['nativeResults'])
    for relative in spec['rootProofs']:
        job = record('audit-'+Path(relative).parent.name, [dafny, 'audit', snap / relative])
        job['passed'] = job['passed'] and 'auditor completed with 0 findings' in (out / job['log']).read_text()
        save()
    stop_if_failed('Included native inventory or audit failed; preserve this run')
    physical = ROOT / spec['physicalOwner'] / 'evm-traces.mjs'
    job = record('complete-physical-receipts', [shutil.which('node'), physical, '--root', snap, '--output', out / 'evm-traces'])
    receipts = json.loads((out / 'evm-traces/results.json').read_text()) if (out / 'evm-traces/results.json').is_file() else []
    job['passed'] = job['passed'] and len(receipts) == spec['physicalFixtureCount'] == len({r['name'] for r in receipts}) and all(r['passed'] and r['receiptPassed'] for r in receipts)
    m['fixtureNames'] = [r['name'] for r in receipts]
    m['concreteToolchain'] = json.loads((out / 'evm-traces/toolchain.json').read_text())
    save()
    stop_if_failed('Physical receipts failed')
    record('candidate-generation', [sys.executable, '-B', source / 'make-candidates.py', '--output', out / 'candidates'])
    candidates = json.loads((out / 'candidates/candidates.json').read_text())
    faults = []
    for candidate in candidates:
        name = candidate['name']
        folder = out / 'mutations' / name
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
        translated = record(name+'-generation', [sys.executable, '-B', work / candidate['generator'], '--output', package])
        stop_if_failed('Mutation parser failed; not semantic evidence')
        file = package / candidate['source']
        lines = file.read_text().splitlines()
        method = candidate['nativeSymbol'].split('.')[-1]
        start = next(i for i, line in enumerate(lines) if 'lemma '+method+'(' in line)
        anchor = next(i for i in range(start, len(lines)) if 'ensures var next :=' in lines[i])
        baseline = next(d for d in m['declarationResults'] if d['name'] == candidate['nativeSymbol'])
        assert baseline['status'] == 'passed' and baseline['file'] == candidate['package']+'/'+candidate['source']
        native_owner = candidate['nativeSymbol']
        healthy_checks = []
        terminal_witness = None
        if name == 'callback-error-is-return':
            control = folder / 'terminal-witness'
            generation = record(name+'-terminal-generation', [sys.executable, '-B', source / 'generate-terminal-witness.py', '--root', snap, '--runtime', runtime, '--output', control])
            healthy_checks.append(generation)
            stop_if_failed('Exact terminal witness generation failed')
            for label, filename, owner in [('healthy-terminal', 'HealthyTerminal.dfy', 'FoldCallbackTerminalWitness'), ('healthy-packet-bridge', 'HealthyBridge.dfy', 'FoldCallbackTerminalBridge')]:
                proof_file = control / filename
                proof_csv = folder / (label+'.csv')
                healthy = record(name+'-'+label, common.proof_command(dafny, proof_file, proof_csv) + ['--filter-symbol', owner, '--filter-position', str(proof_file), '--progress', 'Symbol'])
                common.check_proof(healthy, out / healthy['log'], proof_csv, getter.inventory(proof_file))
                healthy['nativeObligations'] = len(healthy['nativeResults'])
                healthy_checks.append(healthy)
                save()
                stop_if_failed('Whole healthy terminal or all-admitted packet bridge failed')
            file = control / 'ChangedTerminal.dfy'
            lines = file.read_text().splitlines()
            anchor = next(i for i, line in enumerate(lines) if 'ensures var next :=' in line)
            native_owner = 'FoldCallbackTerminalWitness'
            terminal_witness = dict(healthyTerminal=str((control/'HealthyTerminal.dfy').relative_to(out)), healthyBridge=str((control/'HealthyBridge.dfy').relative_to(out)), changedTerminal=str(file.relative_to(out)), module=native_owner, semanticSymbol=native_owner+'.Terminal', baselineAdmission='Original unchanged Admitted+Good20, no restriction', terminalPc=1122, before=253, after=243, originalPacket='H.Packet(CL.Operation(domain),index,target,payload,reason)')
        native = record(name+'-native', common.proof_command(dafny, file, folder / 'proof.csv') +
                        ['--filter-symbol', native_owner, '--filter-position', str(file), '--progress', 'Symbol'])
        body = (out / native['log']).read_text()
        rows = list(csv.DictReader((folder / 'proof.csv').open())) if (folder / 'proof.csv').is_file() else []
        native['passed'] = native['exitCode'] not in [0, None] and bool(rows) and any(r['TestResult.Outcome'] == 'Failed' for r in rows) and all(r['TestResult.Outcome'] in {'Passed', 'Failed'} for r in rows) and 'postcondition could not be proved' in body and not re.search(r'time.?out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call', body, re.I) and bool(re.findall(r'^.*\(\d+,\d+\): Error: (.*)$', body, re.M)) and all('postcondition could not be proved' in e for e in re.findall(r'^.*\(\d+,\d+\): Error: (.*)$', body, re.M))
        concrete = record(name+'-physical', [shutil.which('node'), physical, '--root', snap, '--output', folder / 'evm-traces', '--runtime', runtime, '--case', candidate['evmFixture']])
        contrary = json.loads((folder / 'evm-traces/results.json').read_text()) if (folder / 'evm-traces/results.json').is_file() else []
        concrete['passed'] = concrete['exitCode'] not in [0, None] and len(contrary) == 1 and contrary[0]['name'] == candidate['evmFixture'] and not contrary[0]['receiptPassed']
        faults.append(dict(candidate=candidate, baselineCoveredSymbol=candidate['nativeSymbol'],
                           semanticAssertion=dict(line=anchor+1, text=lines[anchor]),
                           nativeOwner=native_owner, terminalWitness=terminal_witness,
                           checks=[translated, *healthy_checks, native, concrete], contradictoryReceipts=contrary))
        save()
    (out / 'mutations/results.json').write_text(json.dumps(faults, indent=2)+'\n')
    stop_if_failed('A bytecode fault lacks a matching native/physical semantic contradiction')
    source_root = snap / SOURCE_OWNER.relative_to(ROOT)
    job = record('source-baseline-generation', [sys.executable, '-B', source_root / 'generate.py', '--root', snap, '--solc', solc, '--output', out / 'source-generated'])
    job['passed'] = job['passed'] and all((source_root / name).read_bytes() == (out / 'source-generated' / name).read_bytes() for name in ['Source.generated.dfy', 'Selectors.generated.dfy'])
    save()
    # This configuration is a derived source-campaign input, not the deployment
    # build of record. The exact deployed runtime was recompiled above.
    (snap / 'foundry.toml').write_text(source_campaign_config(solc))
    job = record('source-baseline-physical', [forge, 'test', '--root', snap, '--match-contract', '^(WordFoldEntryOracleTest|WordFoldLoopOracleTest)$', '-vv'])
    body = (out / job['log']).read_text()
    fixtures = [source_root / 'WordFoldEntryOracle.t.sol', snap / 'formal/collections/word-fold-loop/WordFoldLoopOracle.t.sol']
    expected = [name for p in fixtures for name in re.findall(r'function (test\w+)\(', p.read_text())]
    actual = re.findall(r'^\[PASS\] (test\w+)\(', body, re.M)
    job['passed'] = job['passed'] and sorted(actual) == sorted(expected) and len(expected) == 14
    save()
    record('semantic-source-faults', [sys.executable, '-B', source / 'source-fault-audit.py', '--snapshot', snap, '--output', out / 'source-faults', '--dafny', dafny, '--solc', solc])
    for relative in ['out', 'cache']:
        shutil.rmtree(snap / relative, ignore_errors=True)
    record('dispatcher-dependency-after', [sys.executable, '-B', ROOT / 'scripts/check-raw-rejections-bytecode-evidence.py'])
    record('conditional-source-dependency-after', [sys.executable, '-B', ROOT / 'scripts/check-collections-word-fold-entry-evidence.py'])
    ct = m['concreteToolchain']
    m['concreteToolsUnchanged'] = all(sha(Path(ct[k])) == ct[k+'Sha256'] for k in ['hardhatEntry', 'edrEntry', 'nativeBinding']) and sha(Path(ct['nodeExecutable'])) == ct['nodeSha256'] and sha(ROOT / 'pnpm-lock.yaml') == ct['lockfileSha256']
    m['checks'].append(dict(name='concrete-tools-unchanged', passed=m['concreteToolsUnchanged']))
    finish()
    print(m['status'], len(module_files), 'whole modules', m['nativeObligations'], 'native obligations', flush=True)
    raise SystemExit(0 if m['status'] == 'passed' else 1)


if __name__ == '__main__':
    main()
