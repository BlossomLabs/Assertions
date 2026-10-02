#!/usr/bin/env python3
"""Retain complete native declaration coverage in each file's minimal include context."""
import argparse
import copy
from concurrent.futures import ThreadPoolExecutor, as_completed
import datetime
import importlib.util
import json
from pathlib import Path
import re
import shutil
import os
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


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


def inventory(path):
    source = path.read_text()
    module = re.search(r'^module (\w+)', source, re.M)[1]
    pattern = r'^  (?:(?:ghost|opaque) )*(lemma|method|function|predicate|type)(?: \{:[^}]+\})* (\w+)(?:<[^>]*>)?(?:\(| =)'
    return [{'name': module+'.'+m[2], 'kind': m[1], 'file': str(path.relative_to(ROOT))}
            for m in re.finditer(pattern, source, re.M)]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--dafny', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--workers', type=int, default=2)
    parser.add_argument('--entry', type=Path, action='append', required=True)
    parser.add_argument('--reuse-evidence', type=Path, action='append', default=[])
    parser.add_argument('--seconds', type=int, default=30)
    args = parser.parse_args()
    assert 1 <= args.workers <= 6 and 1 <= args.seconds <= 120
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

    reused = []
    for i, path in enumerate(args.reuse_evidence):
        path = path.resolve()
        prior = json.loads((path / 'manifest.json').read_text())
        assert prior['verificationMode'] == 'modular-complete-closure' and prior['completedAt']
        assert prior['coverageComplete'] and prior['inputsUnchanged'] and prior['toolsUnchanged']
        assert prior['executableSha256'] == manifest['executableSha256']
        assert all(sha(path / name) == digest for name, digest in prior['evidenceSha256'].items())
        retained = out / 'retained-native-roots' / str(i)
        shutil.copytree(path, retained, copy_function=os.link)
        assert sha(retained / 'manifest.json') == sha(path / 'manifest.json')
        reused.append((path, prior, i))
    manifest['reusePolicy'] = 'Only complete passed native/audit module runs are reused. Every transitive minimal dependency source hash and native tool hash must match the current proof file closure. Historical failed union runs are retained; no failed module obligation is accepted.'
    save()
    fmt = common.run([dafny, 'format', *[snapshot / p.relative_to(ROOT) for p in closed]], out / 'format-snapshot.log', 300)
    fmt.update(name='format-snapshot', passed=fmt['exitCode'] == 0)
    manifest['checks'].append(fmt)
    save()
    isolated = {'formal/bytecode/assertions-navigation/TupleLoop.dfy', 'formal/bytecode/assertions-navigation/Conversion.dfy',
                'formal/bytecode/assertions-navigation/Shift.dfy',
                'formal/bytecode/assertions-primitives-control/math/Mask.dfy'}

    def verify(index, p):
        relative = str(p.relative_to(ROOT))
        folder = out / 'modules' / f'{index:03d}'
        folder.mkdir(parents=True)
        minimal = [str(f.relative_to(ROOT)) for f in closure(p)]
        for origin, prior, retained_index in reused:
            candidate = next((m for m in prior['moduleProofs'] if m['file'] == relative), None)
            if candidate is None or candidate['minimalIncludeClosure'] != minimal:
                continue
            if any(prior['sourceSha256'][f] != hashes[f] for f in minimal):
                continue
            proof, audit = candidate['proof'], candidate['audit']
            if not proof['passed'] or proof['exitCode'] != 0 or not audit['passed'] or audit['exitCode'] != 0:
                continue
            previous_folder = origin / 'modules' / proof['name'].split('-')[1]
            if proof['nativeResults']:
                checked = dict(proof)
                common.check_proof(checked, previous_folder / 'proof.log', previous_folder / 'proof.csv', inventory(p))
                assert checked['passed'] and checked['nativeResults'] == proof['nativeResults']
            else:
                assert proof.get('definitionOnly') and proof.get('nativeObligationCount') == 0
                assert all(d['kind'] not in {'method','lemma'} and d['status'] == 'definition-only' for d in proof['declarations'])
                assert 'Dafny program verifier finished with 0 verified, 0 errors' in (previous_folder / 'proof.log').read_text()
            assert 'auditor completed with 0 findings' in (previous_folder / 'audit.log').read_text()
            shutil.copytree(previous_folder, folder, dirs_exist_ok=True)
            selected = copy.deepcopy(candidate)
            selected['proof']['name'] = f'proof-{index:03d}'
            selected['audit']['name'] = f'audit-{index:03d}'
            selected['selectedEvidence'] = {'manifestSha256': sha(origin / 'manifest.json'),
                'retainedPath': 'retained-native-roots/' + str(retained_index),
                'originalModulePath': str(previous_folder.relative_to(origin)),
                'matchedMinimalClosureSha256': {f: prior['sourceSha256'][f] for f in minimal}}
            return selected
        proof_file = snapshot / p.relative_to(ROOT)
        declarations = inventory(p)
        command = [dafny, 'verify', proof_file, '--manual-lemma-induction', '--cores', '1',
                   '--verification-time-limit', str(args.seconds), '--solver-path', tools['z3'],
                   '--log-format', 'csv;LogFileName=' + str(folder / 'proof.csv'), '--progress', 'Symbol']
        if relative in isolated or relative in {'formal/bytecode/assertions-navigation/development/recursive-suffix-v1/Construct.dfy', 'formal/bytecode/assertions-navigation/development/recursive-suffix-v2/Construct.dfy', 'formal/bytecode/assertions-navigation/development/recursive-suffix-v3/Construct.dfy', 'formal/bytecode/assertions-navigation/development/recursive-spelling-v1/Construct.dfy', 'formal/bytecode/assertions-navigation/development/recursive-spelling-v2/Construct.dfy', 'formal/bytecode/assertions-navigation/development/recursive-spelling-v3/Construct.dfy', 'formal/bytecode/assertions-navigation/development/recursive-spelling-v4/Construct.dfy', 'formal/bytecode/assertions-navigation/development/recursive-spelling-v5/Construct.dfy', 'formal/bytecode/assertions-navigation/development/recursive-spelling-v6/Construct.dfy', 'formal/bytecode/assertions-navigation/development/recursive-spelling-v7/Construct.dfy', 'formal/bytecode/assertions-navigation/development/recursive-spelling-v9/Construct.dfy', 'formal/bytecode/assertions-navigation/development/recursive-spelling-v10/Construct.dfy'}:
            command.append('--isolate-assertions')
        proof = common.run(command, folder / 'proof.log', 7200)
        common.check_proof(proof, folder / 'proof.log', folder / 'proof.csv', declarations)
        definition_only = (proof['exitCode'] == 0 and not proof['nativeResults'] and
                           all(d['status'] == 'definition-only' and d['kind'] not in {'lemma','method'} for d in proof['declarations']) and
                           'Dafny program verifier finished with 0 verified, 0 errors' in (folder / 'proof.log').read_text() and
                           not re.search(r'time.?out|inconclusive|resource limit|Error:', (folder / 'proof.log').read_text(), re.I))
        proof.update(name=f'proof-{index:03d}', passed=proof['passed'] or definition_only,
                     nativeObligationCount=len(proof['nativeResults']), definitionOnly=definition_only)
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
    manifest['evidenceSha256'] = {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p != out / 'manifest.json'}
    save()
    print(manifest['status'])
    raise SystemExit(0 if manifest['status'] == 'passed' else 1)


if __name__ == '__main__':
    main()
