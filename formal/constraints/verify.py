#!/usr/bin/env python3
"""Run the constraint proof, source gate, audit, and exact-error EVM oracle."""
import argparse
import csv
import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run(command, log, timeout=600):
    start = time.monotonic()
    with log.open('w') as stream:
        process = subprocess.Popen(list(map(str, command)), stdout=stream, stderr=subprocess.STDOUT, start_new_session=True)
        try:
            code = process.wait(timeout)
        except subprocess.TimeoutExpired:
            os.killpg(process.pid, signal.SIGKILL)
            process.wait()
            code = None
    return {'command': list(map(str, command)), 'exitCode': code, 'seconds': round(time.monotonic()-start, 3), 'log': log.name}


def inputs():
    return sorted([p for p in HERE.iterdir() if p.is_file()] + [ROOT / p for p in [
        'contracts/Assertions.sol', 'contracts/lib/AbiCodec.sol', 'contracts/lib/ERC8211.sol',
        'formal/navigation/generate.py', 'formal/abi/shape/generate.py', 'formal/abi/source/generate.py', 'formal/abi/toolchain.json']])


def proof_command(dafny, source, csv_path):
    return [dafny, 'verify', source, '--verify-included-files', '--manual-lemma-induction', '--isolate-assertions',
            '--cores', '2', '--verification-time-limit', '30', '--solver-path', dafny.parent / 'z3/bin/z3-4.12.1',
            '--log-format', 'csv;LogFileName=' + str(csv_path)]


def inventory(source):
    declarations = []
    for path in [source / 'Model.dfy', source / 'Engine.generated.dfy']:
        module = re.search(r'^module (\w+)', path.read_text(), re.M)[1]
        for match in re.finditer(r'^  (?:(?:ghost|opaque) )?(lemma|method|function|predicate|type) (\w+)(?:\(| =)', path.read_text(), re.M):
            declarations.append({'name': module+'.'+match[2], 'kind': match[1], 'file': path.name})
    return declarations


def check_proof(job, log, csv_path, declarations):
    text = log.read_text()
    match = re.search(r'Dafny program verifier finished with (\d+) verified, (\d+) errors', text)
    rows = list(csv.DictReader(csv_path.open())) if csv_path.exists() else []
    job['nativeResults'] = rows
    job['declarations'] = []
    for declaration in declarations:
        batches = [r for r in rows if r['TestResult.DisplayName'].split(' (')[0] == declaration['name']]
        status = ('passed' if all(r['TestResult.Outcome'] == 'Passed' for r in batches) else 'failed') if batches else 'definition-only'
        job['declarations'].append(dict(declaration, status=status, batches=len(batches)))
    job['passed'] = bool(job['exitCode'] == 0 and match and int(match[1]) == len(rows) and int(match[2]) == 0 and rows
        and all(r['TestResult.Outcome'] == 'Passed' for r in rows)
        and all(d['status'] == 'passed' for d in job['declarations'] if d['kind'] in {'lemma', 'method'})
        and all(any(r['TestResult.DisplayName'].split(' (')[0] == d['name'] for d in declarations) for r in rows)
        and not re.search(r'time.?out|inconclusive|resource limit|Error:', text, re.I))


def check_dependencies(dafny, solc, sources, out, *, root, here, paths, inventory, closure, hash_file):
    """Validate complete identical dependency evidence before reusing a module."""
    ROOT, HERE, sha = root, here, hash_file
    tools={'dafny':sha(dafny),'Dafny.dll':sha(dafny.parent/'Dafny.dll'),
           'z3':sha(dafny.parent/'z3/bin/z3-4.12.1'),'solc':sha(solc)}
    checked=[]; candidates=[]
    for relative in paths:
        path=ROOT/relative; prior=json.loads(path.read_text())
        if prior['status']!='passed':raise ValueError('Unproved dependency '+relative)
        native=prior.get('nativeResults')
        declarations=prior.get('declarationResults')
        if native is None:
            proof=next(c for c in prior['checks'] if c.get('name')=='proof')
            native=proof['nativeResults'];declarations=proof['declarations']
            if not proof['passed']:raise ValueError('Dependency proof not passed')
        if not native or any(r['TestResult.Outcome']!='Passed' for r in native):raise ValueError('Dependency native failures')
        previous=prior['executableSha256']
        if 'dafnyLauncher' in previous:
            previous={new:previous[old] for new,old in [('dafny','dafnyLauncher'),('Dafny.dll','dafnyAssembly'),('z3','solver'),('solc','solc')]}
        if tools!=previous:raise ValueError('Dependency tool drift')
        for artifact,digest in prior['evidenceSha256'].items():
            if sha(path.parent/artifact)!=digest:raise ValueError('Dependency artifact drift '+artifact)
        for source,digest in prior['sourceSha256'].items():
            if sha(ROOT/source)!=digest:raise ValueError('Dependency source drift '+source)
        rows={}
        for row in native:rows.setdefault(row['TestResult.DisplayName'].split(' (')[0],[]).append(row)
        for declaration in declarations:
            if declaration['kind'] in {'lemma','method'} and (declaration['status']!='passed' or not rows.get(declaration['name'])):
                raise ValueError('Unproved dependency declaration '+declaration['name'])
        retained='dependency-'+path.parent.name+'.json';shutil.copy2(path,out/retained)
        checked.append({'manifest':relative,'sha256':sha(path),'retainedManifest':retained,'nativeRows':len(native)})
        candidates.append((prior,{d['name']:d for d in declarations}))
    reused=[]
    for source in sorted(sources):
        if source.parent==HERE:continue
        key=str(source.relative_to(ROOT)); required=inventory({source})
        for prior,declarations in candidates:
            if not all(prior['sourceSha256'].get(str(p.relative_to(ROOT)))==sha(p) for p in closure(source)):continue
            if not all(d['name'] in declarations and declarations[d['name']]['file']==key for d in required if d['kind']!='type'):continue
            if not all(declarations[d['name']]['status']=='passed' for d in required if d['kind'] in {'method','lemma'}):continue
            reused.append(key);break
        else:raise ValueError('No complete identical dependency proof '+key)
    return {'name':'dependency-closure','passed':True,'dependencies':checked,'reusedModules':reused,
            'policy':'Identical transitive source/tool hashes; all retained artifact hashes and successful native/declaration results checked. Original proof arguments and logs retained in linked baseline manifests.'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dafny', type=Path, required=True)
    parser.add_argument('--solc', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    dafny, solc = args.dafny.resolve(), args.solc.resolve()
    solver = dafny.parent / 'z3/bin/z3-4.12.1'
    pin = json.loads((HERE.parent / 'abi/toolchain.json').read_text())
    versions = {n: subprocess.check_output([str(p), '--version'], text=True).strip() for n,p in [('dafny',dafny),('solc',solc),('z3',solver),('forge',Path(shutil.which('forge')))]}
    if versions['dafny'] != pin['dafnyVersion'] or '4.12.1' not in versions['z3'] or '0.8.36+commit.8a079791' not in versions['solc']:
        raise ValueError('Unpinned proof toolchain')
    proof_files = {p.name for p in HERE.glob('*.dfy') if not p.name.endswith('.template.dfy')}
    if proof_files != {'Model.dfy', 'Engine.generated.dfy'}:
        raise ValueError('Uninventoried proof source')
    for p in [HERE/'Model.dfy', HERE/'Engine.generated.dfy']:
        if any(name != 'Model.dfy' for name in re.findall(r'^include \"([^\"]+)\"', p.read_text(), re.M)):
            raise ValueError('Uninventoried dependency')
    paths = inputs()
    hashes = {str(p.relative_to(ROOT)): sha(p) for p in paths}
    snap = out / 'source-snapshot'
    for path in paths:
        dest = snap / path.relative_to(ROOT)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, dest)
    source = snap / 'formal/constraints'
    manifest = {'schemaVersion': 1, 'status': 'incomplete', 'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'scope': 'Source constraint semantics, conditional on restricted translation, memory projection, supplied ABI decoder outcome and adequate resources. Not compiled-bytecode verification.',
        'bounds': {'constraintCount': None, 'orLeafCount': None, 'wordWidth': 256},
        'assumptions': ['Pinned solc AST, gated hand-written control-flow lowering and expression translator are trusted.',
            'OR decoding outcome equals solc abi.decode: Rejected or its actual Constraint[] result; decoder correctness is not proved here.',
            'Valid disjoint nonwrapping Solidity byte/array memory objects and big-endian word projection.',
            'Representable uint256 lengths, valid enum values, adequate gas, stack and allocation; no resource-failure claim.',
            'Typed error projection uses the Solidity custom-error ABI encoding; error serialization is tested, not formally proved.',
            'Dafny, Boogie and Z3 are trusted. No axioms, admits or automatic induction.'],
        'versions': versions, 'executableSha256': {n:sha(p) for n,p in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',solver),('solc',solc)]},
        'sourceSha256': hashes, 'checks': []}
    def save():
        (out / 'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    save()
    def record(name, command, timeout=600):
        job = run(command, out / (name+'.log'), timeout)
        job.update(name=name, passed=job['exitCode'] == 0)
        manifest['checks'].append(job)
        save()
        return job
    generated = out / 'generated'
    gate = record('source-gate', [sys.executable, '-B', source/'generate.py', '--solc', solc, '--root', snap, '--output', generated])
    gate['passed'] = gate['passed'] and (generated/'Engine.generated.dfy').read_bytes() == (source/'Engine.generated.dfy').read_bytes()
    if not gate['passed']:
        save()
        raise SystemExit('Source gate or checked-in generated output differs')
    proof = record('proof', proof_command(dafny, source/'Engine.generated.dfy', out/'proof.csv'))
    check_proof(proof, out/'proof.log', out/'proof.csv', inventory(source))
    audit = record('audit', [dafny, 'audit', source/'Engine.generated.dfy'])
    audit['passed'] = audit['passed'] and 'auditor completed with 0 findings' in (out/'audit.log').read_text()
    record('format', [dafny, 'format', '--check', source/'Model.dfy', source/'Engine.generated.dfy'])
    record('solidity-format', ['forge', 'fmt', '--check', source/'ConstraintOracle.t.sol'])
    (snap/'foundry.toml').write_text('[profile.default]\nsrc="contracts"\ntest="formal/constraints"\nsolc='+json.dumps(str(solc))+'\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\n[fuzz]\nruns=256\nseed="0x8211"\n[lint]\nlint_on_build=false\n')
    concrete = record('concrete', ['forge', 'test', '--root', snap, '--match-contract', 'ConstraintOracleTest', '-vv'], 180)
    expected = re.findall(r'function (test\w+)\(', (source/'ConstraintOracle.t.sol').read_text())
    actual = re.findall(r'^\[PASS\] (test\w+)\(', (out/'concrete.log').read_text(), re.M)
    concrete.update(expectedTests=expected, passed=concrete['passed'] and sorted(expected) == sorted(actual) and bool(expected))
    manifest['inputsUnchanged'] = hashes == {str(p.relative_to(ROOT)):sha(p) for p in paths}
    manifest['status'] = 'passed' if manifest['inputsUnchanged'] and all(c['passed'] for c in manifest['checks']) else 'failed'
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    # The snapshot's Forge build outputs are reproducible, not evidence inputs.
    shutil.rmtree(snap/'out', ignore_errors=True)
    shutil.rmtree(snap/'cache', ignore_errors=True)
    manifest['evidenceSha256'] = {str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name != 'manifest.json'}
    save()
    print(manifest['status'])
    raise SystemExit(0 if manifest['status'] == 'passed' else 1)


if __name__ == '__main__':
    main()
