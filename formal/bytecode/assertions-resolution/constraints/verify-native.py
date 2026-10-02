#!/usr/bin/env python3
"""Retain native include-closure evidence for an Assertions proof. Not a runtime binding certificate."""
import argparse
import datetime
import importlib.util
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


getter = load('getter', ROOT / 'formal/bytecode/getters/verify.py')
common, sha = getter.common, getter.sha


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--dafny', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--cores', type=int, default=2)
    parser.add_argument('--entry', type=Path, required=True)
    args = parser.parse_args()
    assert 1 <= args.cores <= 4
    dafny, out = args.dafny.resolve(), args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    closed = set()

    def visit(path):
        path = path.resolve()
        assert path.is_relative_to(ROOT) and path.is_file()
        if path in closed:
            return
        closed.add(path)
        for name in re.findall(r'^include "([^"]+)"', path.read_text(), re.M):
            visit(path.parent / name)

    entry = args.entry.resolve()
    visit(entry)
    helpers = {ROOT / 'formal/constraints/verify.py', ROOT / 'formal/bytecode/getters/verify.py',
               ROOT / 'formal/bytecode/dispatch/identity.py', ROOT / 'formal/abi/toolchain.json', Path(__file__).resolve()}
    files = sorted(closed | helpers)
    hashes = {str(p.relative_to(ROOT)): sha(p) for p in files}
    tools = {'dafny': dafny, 'Dafny.dll': dafny.parent / 'Dafny.dll', 'z3': dafny.parent / 'z3/bin/z3-4.12.1'}
    versions = {k: subprocess.check_output([str(p), '--version'], text=True).strip() for k, p in tools.items() if k != 'Dafny.dll'}
    assert versions['dafny'] == json.loads((ROOT / 'formal/abi/toolchain.json').read_text())['dafnyVersion'] and '4.12.1' in versions['z3']
    snapshot = out / 'source-snapshot'
    for p in files:
        dest = snapshot / p.relative_to(ROOT)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(p, dest)
    for p in sorted(closed):
        dest = snapshot / p.relative_to(ROOT)
        text = p.read_text()
        def remap(match):
            dependency = (p.parent / match.group(1)).resolve()
            return 'include \"' + str(snapshot / dependency.relative_to(ROOT)) + '\"'
        dest.write_text(re.sub(r'^include \"([^\"]+)\"', remap, text, flags=re.M))
    root_proof = snapshot / entry.relative_to(ROOT)
    manifest = {'status': 'incomplete', 'scope': 'Native verification of the chosen Assertions include closure. Scope is its explicit preconditions and postconditions; no whole public-entry completion claim, no runtime reproduction or mutation gate in this native-only manifest.',
        'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'sourceSha256': hashes, 'includeClosure': [str(p.relative_to(ROOT)) for p in sorted(closed)],
        'versions': versions, 'executableSha256': {k: sha(p) for k, p in tools.items()}, 'checks': [],
        'assumptions': ['Reviewed opcode interpretation and trusted Dafny/Boogie/Z3.',
            'Representable, fitting physical memory/stack and sufficient reached execution resources.',
            'External observations must be truthful for actual balances, code sizes, gas and static calls; KECCAK observations must be the EVM Keccak-256 result for their exact bytes.',
            'These foundations require exact-bytecode caller certificates and independent behavioral specifications before counting any contract entry as verified.']}

    def save():
        (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')

    def record(name, command, timeout=240):
        job = common.run(command, out / (name + '.log'), timeout)
        job.update(name=name, passed=job['exitCode'] == 0)
        manifest['checks'].append(job)
        save()
        return job

    save()
    record('format-snapshot', [dafny, 'format', *[snapshot / p.relative_to(ROOT) for p in sorted(closed)]], 240)
    command = common.proof_command(dafny, root_proof, out / 'proof.csv') + ['--progress', 'Symbol']
    command.remove('--isolate-assertions')
    command[command.index('--cores') + 1] = str(args.cores)
    job = record('proof', command, 7200)
    common.check_proof(job, out / 'proof.log', out / 'proof.csv', [d for p in sorted(closed) for d in getter.inventory(p)])
    job['passed'] = job['passed'] and all(d['status'] == 'passed' for d in job['declarations'] if d['kind'] in ['lemma', 'method'])
    manifest['nativeResults'], manifest['declarationResults'] = job['nativeResults'], job['declarations']
    save()
    for i, p in enumerate(sorted(closed)):
        audit = record('audit-' + str(i), [dafny, 'audit', snapshot / p.relative_to(ROOT)])
        audit['passed'] = audit['passed'] and 'auditor completed with 0 findings' in (out / (audit['name'] + '.log')).read_text()
    record('format', [dafny, 'format', '--check', *[snapshot / p.relative_to(ROOT) for p in sorted(closed)]])
    manifest['inputsUnchanged'] = hashes == {str(p.relative_to(ROOT)): sha(p) for p in files}
    manifest['toolsUnchanged'] = manifest['executableSha256'] == {k: sha(p) for k, p in tools.items()}
    manifest['status'] = 'passed' if manifest['inputsUnchanged'] and manifest['toolsUnchanged'] and all(j['passed'] for j in manifest['checks']) else 'failed'
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['evidenceSha256'] = {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name != 'manifest.json'}
    save()
    print(manifest['status'])
    raise SystemExit(0 if manifest['status'] == 'passed' else 1)


if __name__ == '__main__':
    main()
