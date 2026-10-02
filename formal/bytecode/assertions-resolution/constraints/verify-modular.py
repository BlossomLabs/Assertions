#!/usr/bin/env python3
"""Retain complete native declaration coverage in each file's minimal include context."""
import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import datetime
import importlib.util
import json
from pathlib import Path
import re
import shutil
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


getter = load('getter', ROOT / 'formal/bytecode/getters/verify.py')
common, sha = getter.common, getter.sha


def closure(entry):
    seen = set()

    def visit(path):
        path = path.resolve()
        assert path.is_relative_to(ROOT) and path.is_file()
        if path in seen:
            return
        seen.add(path)
        for name in re.findall(r'^include "([^"]+)"', path.read_text(), re.M):
            visit(path.parent / name)

    visit(entry)
    return sorted(seen)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--dafny', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--workers', type=int, default=2)
    parser.add_argument('--entry', type=Path, action='append', required=True)
    args = parser.parse_args()
    assert 1 <= args.workers <= 6
    dafny = args.dafny.resolve()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    entries = [p.resolve() for p in args.entry]
    entry_closures = {str(p.relative_to(ROOT)): [str(f.relative_to(ROOT)) for f in closure(p)] for p in entries}
    closed = sorted({ROOT / f for files in entry_closures.values() for f in files})
    helpers = [ROOT / 'formal/constraints/verify.py', ROOT / 'formal/bytecode/getters/verify.py',
               ROOT / 'formal/bytecode/dispatch/identity.py', ROOT / 'formal/abi/toolchain.json', Path(__file__).resolve()]
    files = sorted(set(closed + helpers))
    hashes = {str(p.relative_to(ROOT)): sha(p) for p in files}
    tools = {'dafny': dafny, 'Dafny.dll': dafny.parent / 'Dafny.dll', 'z3': dafny.parent / 'z3/bin/z3-4.12.1'}
    versions = {name: subprocess.check_output([str(p), '--version'], text=True).strip()
                for name, p in tools.items() if name != 'Dafny.dll'}
    assert versions['dafny'] == json.loads((ROOT / 'formal/abi/toolchain.json').read_text())['dafnyVersion']
    assert '4.12.1' in versions['z3']
    snapshot = out / 'source-snapshot'
    for p in files:
        dest = snapshot / p.relative_to(ROOT)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(p, dest)
    for p in closed:
        dest = snapshot / p.relative_to(ROOT)
        def remap(match):
            dependency = (p.parent / match.group(1)).resolve()
            return 'include "' + str(snapshot / dependency.relative_to(ROOT)) + '"'
        dest.write_text(re.sub(r'^include "([^"]+)"', remap, p.read_text(), flags=re.M))
    manifest = {
        'schemaVersion': 1, 'status': 'incomplete',
        'startedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'scope': 'Complete native include-closure coverage for the named Assertions proof entries. Every file is verified independently in its exact minimal include context, including every own lemma/method and function well-formedness. Imported contracts are discharged by separate native verification of every dependency file; there are no new axioms or source assumptions. Runtime reproduction and mutation gates are separate.',
        'verificationMode': 'modular-complete-closure', 'entryIncludeClosures': entry_closures,
        'includeClosure': [str(p.relative_to(ROOT)) for p in closed],
        'sourceSha256': hashes, 'versions': versions,
        'executableSha256': {name: sha(p) for name, p in tools.items()},
        'checks': [], 'moduleProofs': [],
        'assumptions': ['Reviewed machine semantics and pinned Dafny/Boogie/Z3 are trusted boundaries.',
                        'Each entry retains its stated physical input/resource premises. An exact runtime caller certificate and independent behavioral specification are required before counting a public class.']}

    def save():
        (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')

    save()
    fmt = common.run([dafny, 'format', *[snapshot / p.relative_to(ROOT) for p in closed]], out / 'format-snapshot.log', 300)
    fmt.update(name='format-snapshot', passed=fmt['exitCode'] == 0)
    manifest['checks'].append(fmt)
    save()
    isolated = {'formal/bytecode/assertions-navigation/Conversion.dfy',
                'formal/bytecode/assertions-navigation/Shift.dfy',
                'formal/bytecode/assertions-primitives-control/math/Mask.dfy'}

    def verify(index, p):
        relative = str(p.relative_to(ROOT))
        folder = out / 'modules' / f'{index:03d}'
        folder.mkdir(parents=True)
        proof_file = snapshot / p.relative_to(ROOT)
        inventory = getter.inventory(p)
        command = [dafny, 'verify', proof_file, '--manual-lemma-induction', '--cores', '1',
                   '--verification-time-limit', '30', '--solver-path', tools['z3'],
                   '--log-format', 'csv;LogFileName=' + str(folder / 'proof.csv'), '--progress', 'Symbol']
        if relative in isolated:
            command.append('--isolate-assertions')
        proof = common.run(command, folder / 'proof.log', 7200)
        common.check_proof(proof, folder / 'proof.log', folder / 'proof.csv', inventory)
        proof.update(name=f'proof-{index:03d}', passed=proof['passed'] and proof['exitCode'] == 0 and bool(proof['nativeResults']) and
                     all(row['TestResult.Outcome'] == 'Passed' for row in proof['nativeResults']) and
                     all(d['status'] == 'passed' for d in proof['declarations'] if d['kind'] in ['method', 'lemma']))
        audit = common.run([dafny, 'audit', proof_file], folder / 'audit.log', 300)
        audit.update(name=f'audit-{index:03d}', passed=audit['exitCode'] == 0 and
                     'auditor completed with 0 findings' in (folder / 'audit.log').read_text())
        return {'file': relative, 'minimalIncludeClosure': [str(f.relative_to(ROOT)) for f in closure(p)],
                'proof': proof, 'audit': audit}

    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        pending = {executor.submit(verify, i, p): p for i, p in enumerate(closed)}
        for future in as_completed(pending):
            result = future.result()
            manifest['moduleProofs'].append(result)
            manifest['checks'].extend([result['proof'], result['audit']])
            save()
            print(result['file'], 'passed' if result['proof']['passed'] and result['audit']['passed'] else 'failed', flush=True)
    manifest['moduleProofs'].sort(key=lambda x: x['file'])
    manifest['nativeResults'] = [r for m in manifest['moduleProofs'] for r in m['proof']['nativeResults']]
    manifest['declarationResults'] = [d for m in manifest['moduleProofs'] for d in m['proof']['declarations']]
    manifest['coverageComplete'] = {m['file'] for m in manifest['moduleProofs']} == set(manifest['includeClosure'])
    fmt = common.run([dafny, 'format', '--check', *[snapshot / p.relative_to(ROOT) for p in closed]], out / 'format.log', 300)
    fmt.update(name='format', passed=fmt['exitCode'] == 0)
    manifest['checks'].append(fmt)
    manifest['inputsUnchanged'] = hashes == {str(p.relative_to(ROOT)): sha(p) for p in files}
    manifest['toolsUnchanged'] = manifest['executableSha256'] == {name: sha(p) for name, p in tools.items()}
    manifest['status'] = 'passed' if all(manifest[k] for k in ['coverageComplete', 'inputsUnchanged', 'toolsUnchanged']) and all(j['passed'] for j in manifest['checks']) else 'failed'
    manifest['completedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['evidenceSha256'] = {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name != 'manifest.json'}
    save()
    print(manifest['status'])
    raise SystemExit(0 if manifest['status'] == 'passed' else 1)


if __name__ == '__main__':
    main()
