#!/usr/bin/env python3
"""Reparse retained native evidence and reject changed published foundations."""
import copy
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('foundation_runner', ROOT / 'formal/bytecode/assertions-navigation/verify-modular-grammar-consolidated-v1.py')
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)
registry = json.loads((ROOT / 'formal/foundations/registry.json').read_text())
for package in registry['packages']:
    path = ROOT / package['manifest']
    assert runner.sha(path) == package['manifestSha256']
    d = json.loads(path.read_text())
    assert d['status'] == 'passed'
    assert all(d[k] for k in ['coverageComplete', 'inputsUnchanged', 'toolsUnchanged'])
    for name, digest in d['sourceSha256'].items():
        assert runner.sha(ROOT / name) == digest, name
    for name, digest in d['evidenceSha256'].items():
        assert runner.sha(path.parent / name) == digest, name
    toolroot = ROOT / 'proof-tools/assertions/dafny'
    tools = {'dafny': toolroot / 'dafny', 'Dafny.dll': toolroot / 'Dafny.dll', 'z3': toolroot / 'z3/bin/z3-4.12.1'}
    assert d['executableSha256'] == {k: runner.sha(v) for k, v in tools.items()}
    union = set()
    for entry, expected in d['entryIncludeClosures'].items():
        actual = [str(p.relative_to(ROOT)) for p in runner.closure(ROOT / entry)]
        assert actual == expected
        union.update(actual)
    assert union == set(d['includeClosure']) == {m['file'] for m in d['moduleProofs']}
    for m in d['moduleProofs']:
        assert m['minimalIncludeClosure'] == [str(p.relative_to(ROOT)) for p in runner.closure(ROOT / m['file'])]
        folder = path.parent / 'modules' / m['proof']['name'].split('-')[1]
        proof = copy.deepcopy(m['proof'])
        assert proof['passed'] and proof['exitCode'] == 0
        if proof['nativeResults']:
            runner.common.check_proof(proof, folder / 'proof.log', folder / 'proof.csv', runner.inventory(ROOT / m['file']))
            assert proof['passed'] and proof['nativeResults'] == m['proof']['nativeResults']
            assert proof['declarations'] == m['proof']['declarations']
        else:
            assert proof['definitionOnly'] and proof['nativeObligationCount'] == 0
            assert all(x['kind'] not in {'method', 'lemma'} and x['status'] == 'definition-only' for x in proof['declarations'])
        assert m['audit']['passed'] and m['audit']['exitCode'] == 0
        assert 'auditor completed with 0 findings' in (folder / 'audit.log').read_text()
    print(package['name'], 'passed:', len(d['moduleProofs']), 'files,', len(d['nativeResults']), 'native batches')
print('Registry passed; mathematical foundation only, no additional bytecode credit.')
