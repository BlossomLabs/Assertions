#!/usr/bin/env python3
"""Accept a complete frozen modular closure, with explicitly retained retries.

This checks existing native evidence; it neither edits nor relabels a failed run.
Runtime identity and public behavioral/mutation gates remain separate obligations.
"""
import argparse
import copy
import datetime
import importlib.util
import json
import re
from pathlib import Path

if not __debug__:
    raise RuntimeError('Run without Python -O')
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
spec = importlib.util.spec_from_file_location('getter', ROOT / 'formal/bytecode/getters/verify.py')
getter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(getter)
common, sha = getter.common, getter.sha


def require(condition, message):
    if not condition:
        raise ValueError(message)


def closure(entry, snapshot):
    seen = set()
    def visit(path):
        path = path.resolve()
        require(path.is_relative_to(snapshot), 'Include escapes frozen snapshot')
        if path in seen:
            return
        seen.add(path)
        for dependency in re.findall(r'^include "([^"]+)"', path.read_text(), re.M):
            visit(path.parent / dependency)
    visit(snapshot / entry)
    return sorted(str(path.relative_to(snapshot)) for path in seen)


def package(path):
    manifest = json.loads((path / 'manifest.json').read_text())
    require(manifest.get('completedAt'), 'Unfinished evidence package')
    for key in ['coverageComplete', 'inputsUnchanged', 'toolsUnchanged']:
        require(manifest.get(key) is True, 'Failed package invariant: ' + key)
    require(manifest.get('evidenceSha256'), 'Missing evidence inventory')
    actual = {str(f.relative_to(path)): sha(f) for f in path.rglob('*')
              if f.is_file() and f.name != 'manifest.json'}
    require(actual == manifest['evidenceSha256'], 'Evidence hash/inventory drift: ' + str(path))
    return manifest


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--matrix', type=Path, required=True)
    parser.add_argument('--retry', type=Path, action='append', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    matrix = args.matrix.resolve()
    out = args.output.resolve()
    require(not out.exists(), 'Output already exists')
    base = package(matrix)
    snapshot = (matrix / 'source-snapshot').resolve()
    require(base['status'] in ['failed', 'passed'], 'Nonterminal matrix')
    for relative, digest in base['sourceSha256'].items():
        require(sha(ROOT / relative) == digest, 'Live source drift: ' + relative)
    dafny = Path(base['moduleProofs'][0]['proof']['command'][0])
    tools = {'dafny': dafny, 'Dafny.dll': dafny.parent / 'Dafny.dll',
             'z3': dafny.parent / 'z3/bin/z3-4.12.1'}
    require({name: sha(path) for name, path in tools.items()} == base['executableSha256'], 'Tool drift')
    for entry, files in base['entryIncludeClosures'].items():
        require(closure(entry, snapshot) == files, 'Entry include closure mismatch: ' + entry)
    required = set(base['includeClosure'])
    require(required == {f for files in base['entryIncludeClosures'].values() for f in files}, 'Entry union mismatch')
    selected = {m['file']: (matrix, m) for m in base['moduleProofs']}
    require(len(selected) == len(base['moduleProofs']) and set(selected) == required, 'Matrix coverage mismatch')
    failed = {f for f, (_, m) in selected.items() if not(m['proof']['passed'] and m['audit']['passed'])}
    replacements = set()
    origins = [{'directory': str(matrix), 'manifestSha256': sha(matrix / 'manifest.json'), 'status': base['status']}]
    for path in args.retry:
        path = path.resolve()
        retry = package(path)
        require(retry['status'] == 'passed' and Path(retry['matrix']).resolve() == matrix, 'Wrong retry parent/status')
        for key in ['sourceSha256', 'executableSha256', 'versions']:
            require(retry[key] == base[key], 'Retry identity mismatch: ' + key)
        snapshot_hashes = {str(f.relative_to(matrix)): sha(f) for f in snapshot.rglob('*') if f.is_file()}
        require(retry['snapshotSha256'] == snapshot_hashes, 'Frozen snapshot drift')
        for relative, digest in retry['helperSha256'].items():
            require(sha(ROOT / relative) == digest, 'Retry helper drift')
        own = {m['file'] for m in retry['moduleProofs']}
        require(len(own) == len(retry['moduleProofs']) and own == set(retry['selectedFiles']), 'Retry coverage mismatch')
        require(own <= failed and not own & replacements, 'Duplicate or unnecessary replacement')
        replacements.update(own)
        for m in retry['moduleProofs']:
            selected[m['file']] = (path, m)
        origins.append({'directory': str(path), 'manifestSha256': sha(path / 'manifest.json'), 'status': retry['status']})
    require(replacements == failed, 'Unproved failed files remain')
    formats = [c for c in base['checks'] if c['name'] in ['format', 'format-snapshot']]
    require(len(formats) == 2 and all(c['passed'] and c['exitCode'] == 0 for c in formats), 'Format gate missing/failed')
    modules = []
    for relative in sorted(required):
        origin, module = selected[relative]
        module = copy.deepcopy(module)
        folder = origin / module.get('evidenceDirectory', 'modules/' + f'{base["includeClosure"].index(relative):03d}')
        command = module['proof']['command']
        require(Path(command[0]) == dafny and command[1] == 'verify' and Path(command[2]).resolve() == snapshot / relative, 'Wrong verified file/tool')
        require('--verify-included-files' not in command and not any('filter' in item for item in command), 'Filtered/imported proof scope')
        inventory = getter.inventory(snapshot / relative)
        for declaration in inventory:
            declaration['file'] = relative
        common.check_proof(module['proof'], folder / 'proof.log', folder / 'proof.csv', inventory)
        require(module['proof']['passed'], 'Native proof/own declaration coverage failed: ' + relative)
        require(module['audit']['exitCode'] == 0 and 'auditor completed with 0 findings' in (folder / 'audit.log').read_text(), 'Audit failed: ' + relative)
        dependencies = closure(relative, snapshot)
        require(set(dependencies) <= required, 'Unproved imported dependency')
        module.update(originPackage=str(origin), evidenceDirectory=str(folder), minimalIncludeClosure=dependencies)
        modules.append(module)
    result = {'schemaVersion': 1, 'status': 'passed', 'completedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'scope': 'Complete native modular include-closure proof coverage of the named entries, selecting matching frozen per-file proofs and explicitly retained isolated retries. Runtime identity, public behavioral and mutation gates remain separate. No whole ABI entry or whole contract completion claim.',
              'wholeEntry': False, 'verificationMode': 'modular-complete-closure-with-retained-retries',
              'entryIncludeClosures': base['entryIncludeClosures'], 'includeClosure': base['includeClosure'],
              'sourceSha256': base['sourceSha256'], 'executableSha256': base['executableSha256'], 'versions': base['versions'],
              'sourceSnapshot': str(snapshot), 'originPackages': origins, 'moduleProofs': modules,
              'nativeResults': [r for m in modules for r in m['proof']['nativeResults']],
              'declarationResults': [d for m in modules for d in m['proof']['declarations']],
              'assumptions': base['assumptions'], 'checks': formats,
              'coverageComplete': True, 'inputsUnchanged': True, 'toolsUnchanged': True,
              'acceptanceHelperSha256': {str(p.relative_to(ROOT)): sha(p) for p in [Path(__file__).resolve(), ROOT / 'formal/bytecode/getters/verify.py', ROOT / 'formal/constraints/verify.py']}}
    out.mkdir(parents=True)
    (out / 'manifest.json').write_text(json.dumps(result, indent=2) + '\n')
    print(f'PASS: {len(modules)} files, {len(result["nativeResults"])} native checks; complete named native closures only')


if __name__ == '__main__':
    main()
