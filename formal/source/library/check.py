"""Check canonical source-library interfaces and implementation provenance."""
import argparse
import hashlib
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIBRARY = Path(__file__).resolve().parent

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def check():
    registry = json.loads((LIBRARY / 'registry.json').read_text())
    spec = importlib.util.spec_from_file_location('mapping', LIBRARY / 'declarations.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    declarations = {}
    seen = set()
    packages = {p['id']: p for p in registry['packages']}
    for package in packages.values():
        if 'selectionEvidence' in package:
            evidence = package['selectionEvidence']
            assert digest(ROOT / evidence['generator']) == evidence['sha256']
        if 'mapping' in package:
            mapping = package['mapping']
            assert digest(ROOT / mapping['path']) == mapping['sha256'], mapping['path']
        descriptor = json.loads((ROOT / package['descriptor']).read_text())
        assert descriptor['id'] == package['id']
        assert descriptor['status'] == package['status']
        closure = descriptor['closureSha256']
        assert set(package['implementations']) <= set(closure), package['id']
        assert set(descriptor['verificationEntries']) <= set(closure)
        visited = set()
        def walk(relative):
            if relative in visited:
                return
            visited.add(relative)
            path = ROOT / relative
            assert digest(path) == closure[relative], relative
            for include in re.findall(r'^include "([^"]+)"', path.read_text(), re.M):
                child = str((path.parent / include).resolve().relative_to(ROOT))
                if child not in closure:
                    assert descriptor['status'] == 'blocked-missing-inputs'
                    assert child in descriptor['missingInputs'] and not (ROOT / child).exists(), child
                else:
                    walk(child)
        for entry in descriptor['verificationEntries']:
            walk(entry)
        assert visited == set(closure), (package['id'], set(closure) - visited)
    if (LIBRARY / 'canonical-sources.json').exists():
        source_receipt = json.loads((LIBRARY / 'canonical-sources.json').read_text())
        for record in source_receipt['files']:
            assert digest(ROOT / record['selectedImplementation']) == record['implementationSha256']
            assert digest(ROOT / record['canonicalFile']) == record['canonicalSha256']
            assert module.declarations(ROOT / record['selectedImplementation']) == module.declarations(ROOT / record['canonicalFile'])
        for package in packages.values():
            descriptor = json.loads((ROOT / package['canonicalDescriptor']).read_text())
            assert descriptor['id'] == package['id']
            closure = descriptor['closureSha256']
            visited = set()
            def canonical_walk(relative):
                if relative in visited:
                    return
                visited.add(relative)
                path = ROOT / relative
                assert path.is_relative_to(LIBRARY / 'src')
                assert digest(path) == closure[relative]
                for include in re.findall(r'^include "([^\"]+)"', path.read_text(), re.M):
                    child = str((path.parent / include).resolve().relative_to(ROOT))
                    if child not in closure:
                        assert descriptor['status'] == 'blocked-missing-inputs'
                        assert child in descriptor['missingInputs'] and not (ROOT / child).exists()
                    else:
                        canonical_walk(child)
            for entry in descriptor['verificationEntries']:
                canonical_walk(entry)
            assert visited == set(closure), package['id']
            assert set(descriptor['implementations']) <= visited
    for contract in registry['contracts']:
        index = json.loads((LIBRARY / 'contracts' / contract / 'claims.json').read_text())
        for record in index['records']:
            assert record['contract'] == contract
            assert record['id'] not in seen, record['id']
            seen.add(record['id'])
            assert digest(ROOT / record['originalFile']) == record['originalSha256']
            assert hashlib.sha256(record['logicalInterface'].encode()).hexdigest() == record['interfaceSha256']
            if 'canonicalFile' in record:
                canonical_path = ROOT / record['canonicalFile']
                if canonical_path not in declarations:
                    declarations[canonical_path] = module.declarations(canonical_path)
                canonical_declaration = declarations[canonical_path][record['symbol']]
                assert canonical_declaration['kind'] == record['kind']
                assert canonical_declaration['interface'] == record['logicalInterface'], record['id']
            for impl in record['implementations']:
                assert impl['package'] in packages
                assert impl['status'] == packages[impl['package']]['status']
                path = ROOT / impl['file']
                assert digest(path) == impl['sha256'], impl['file']
                if path not in declarations:
                    declarations[path] = module.declarations(path)
                declaration = declarations[path][record['symbol']]
                assert declaration['kind'] == record['kind']
                assert declaration['interface'] == record['logicalInterface'], record['id']
    assert len(seen) == registry.get('uniqueIndexedDeclarations', registry['uniqueMappedDeclarations'])
    if (LIBRARY / 'helper-interfaces.json').exists():
        helpers = json.loads((LIBRARY / 'helper-interfaces.json').read_text())['records']
        for record in helpers:
            path = ROOT / record['canonicalFile']
            actual = module.declarations(path)[record['symbol']]
            assert actual['kind'] == record['kind']
            assert actual['interface'] == record['logicalInterface']
            assert hashlib.sha256(actual['interface'].encode()).hexdigest() == record['interfaceSha256']
    if (LIBRARY / 'dependency-graph.json').exists():
        graph = json.loads((LIBRARY / 'dependency-graph.json').read_text())['files']
        actual_files = {str(p.relative_to(ROOT)) for p in (LIBRARY / 'src').rglob('*.dfy')}
        assert set(graph) == actual_files, 'Canonical dependency catalog is stale'
        for relative, edges in graph.items():
            path = ROOT / relative
            actual = []
            for include in re.findall(r'^include "([^"]+)"', path.read_text(), re.M):
                child = (path.parent / include).resolve()
                actual.append({'path':str(child.relative_to(ROOT)),'exists':child.is_file()})
            assert actual == edges, relative
    if (LIBRARY / 'foundations/registry.json').exists():
        catalog = json.loads((LIBRARY / 'foundations/registry.json').read_text())['foundations']
        for foundation in catalog:
            path = ROOT / foundation['file']
            assert digest(path) == foundation['sha256']
            actual = module.declarations(path)
            for interface in foundation['interfaces']:
                assert actual[interface['symbol']]['kind'] == interface['kind']
                assert actual[interface['symbol']]['interface'] == interface['logicalInterface']
            consumers = sorted(p['id'] for p in packages.values() if foundation['file'] in json.loads((ROOT / p['canonicalDescriptor']).read_text())['closureSha256'])
            assert consumers == foundation['consumers']
    print(f'PASS: {len(seen)} interfaces, {len(packages)} packages, {len(declarations)} implementation files. No proof acceptance granted.')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--list', action='store_true', help='List package status and bound implementations.')
    args = parser.parse_args()
    if args.list:
        for package in json.loads((LIBRARY / 'registry.json').read_text())['packages']:
            print(package['id'], package['status'])
    else:
        check()
