#!/usr/bin/env python3
"""Retain complete passed per-file native proofs with identical minimal dependencies."""
import argparse
import copy
import datetime
import importlib.util
import json
from pathlib import Path
import shutil

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
spec = importlib.util.spec_from_file_location('native_matrix', HERE / 'verify-modular-v5.py')
matrix = importlib.util.module_from_spec(spec)
spec.loader.exec_module(matrix)
sha = matrix.sha


def evidence(path):
    path = path.resolve()
    manifest = json.loads((path / 'manifest.json').read_text())
    assert manifest['verificationMode'] == 'modular-complete-closure' and manifest['completedAt']
    assert manifest['coverageComplete'] and manifest['inputsUnchanged'] and manifest['toolsUnchanged']
    assert all(sha(path / name) == digest for name, digest in manifest['evidenceSha256'].items())
    return path, manifest


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--current', type=Path, required=True)
    parser.add_argument('--candidate', type=Path, action='append', default=[])
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    runs = [evidence(args.current)] + [evidence(p) for p in args.candidate]
    current = runs[0][1]
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    for i, (path, _) in enumerate(runs):
        shutil.copytree(path, out / 'retained-runs' / str(i))
    for name, digest in current['sourceSha256'].items():
        assert sha(ROOT / name) == digest, ('Current source drift', name)
    selected = []
    references = []
    for file in current['includeClosure']:
        expected = [str(p.relative_to(ROOT)) for p in matrix.closure(ROOT / file)]
        found = None
        for i, (path, candidate) in enumerate(runs):
            if candidate['executableSha256'] != current['executableSha256']:
                continue
            entry = next((m for m in candidate['moduleProofs'] if m['file'] == file), None)
            if entry is None or entry['minimalIncludeClosure'] != expected:
                continue
            if any(candidate['sourceSha256'][f] != current['sourceSha256'][f] for f in expected):
                continue
            proof, audit = entry['proof'], entry['audit']
            if not proof['passed'] or proof['exitCode'] != 0 or not audit['passed'] or audit['exitCode'] != 0:
                continue
            if any(r['TestResult.Outcome'] != 'Passed' for r in proof['nativeResults']):
                continue
            if any(d['status'] != 'passed' for d in proof['declarations'] if d['kind'] in {'lemma', 'method'}):
                continue
            folder = path / 'modules' / proof['name'].split('-')[1]
            if proof['nativeResults']:
                check = dict(proof)
                matrix.common.check_proof(check, folder / 'proof.log', folder / 'proof.csv', matrix.inventory(ROOT / file))
                assert check['passed'] and check['nativeResults'] == proof['nativeResults']
            else:
                assert proof.get('definitionOnly') and proof.get('nativeObligationCount') == 0
                assert all(d['kind'] not in {'lemma', 'method'} and d['status'] == 'definition-only' for d in proof['declarations'])
                assert 'Dafny program verifier finished with 0 verified, 0 errors' in (folder / 'proof.log').read_text()
            assert 'auditor completed with 0 findings' in (folder / 'audit.log').read_text()
            found = copy.deepcopy(entry)
            found['selectedEvidence'] = {'run': i, 'manifestSha256': sha(path / 'manifest.json'),
                                        'retainedPath': 'retained-runs/' + str(i),
                                        'matchedMinimalClosureSha256': {f: candidate['sourceSha256'][f] for f in expected}}
            references.append({'file': file, **found['selectedEvidence']})
            break
        assert found is not None, ('No complete passed exact-source native module', file)
        selected.append(found)
    manifest = copy.deepcopy(current)
    manifest.update(status='passed', completedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                    moduleProofs=selected, selectedModuleEvidence=references,
                    scope=current['scope'] + ' Complete passed per-file native/audit runs are selected only when all transitive minimal dependency and tool hashes match. Historical failed matrices are retained without accepting their failed obligations; unrelated union files are not required to match.')
    manifest['checks'] = [copy.deepcopy(j) for j in current['checks']
                          if not j['name'].startswith(('proof-', 'audit-'))]
    assert all(j['passed'] for j in manifest['checks'])
    manifest['checks'] += [job for m in selected for job in [m['proof'], m['audit']]]
    manifest['nativeResults'] = [r for m in selected for r in m['proof']['nativeResults']]
    manifest['declarationResults'] = [d for m in selected for d in m['proof']['declarations']]
    manifest['coverageComplete'] = {m['file'] for m in selected} == set(current['includeClosure'])
    manifest['sourceSha256'][str(Path(__file__).resolve().relative_to(ROOT))] = sha(Path(__file__).resolve())
    for i, (path, candidate) in enumerate(runs):
        assert sha(out / 'retained-runs' / str(i) / 'manifest.json') == sha(path / 'manifest.json')
        assert all(sha(out / 'retained-runs' / str(i) / name) == digest for name, digest in candidate['evidenceSha256'].items())
    manifest['evidenceSha256'] = {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*'))
                                if p.is_file() and p != out / 'manifest.json'}
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print('passed:', len(selected), 'files,', len(manifest['nativeResults']), 'native checks')


if __name__ == '__main__':
    main()
