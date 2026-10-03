"""Validate the self-contained canonical proof library; historical files are provenance."""
import argparse
import hashlib
import json
import re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
LIBRARY=Path(__file__).resolve().parents[1]

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def check():
    from declarations import declarations
    from evm_dependency import external_sources
    external = external_sources()
    registry=json.loads((LIBRARY/'registry.json').read_text())
    preservation=json.loads((LIBRARY/'preservation.json').read_text())['files']
    actual={str(p.relative_to(ROOT)) for folder in ['source/assertions','source/operations','source/collections','source/expressions','source/abi','foundations','bridges','bytecode'] for p in (LIBRARY/folder).rglob('*.dfy')}
    assert actual==set(preservation),'Unbound canonical proof file'
    parsed={}
    for relative,record in preservation.items():
        path=ROOT/relative
        assert digest(path)==record['sha256'],relative
        parsed[relative]=declarations(path)
        bound={s:{'kind':d['kind'],'fullSha256':hashlib.sha256(d['full'].encode()).hexdigest()} for s,d in parsed[relative].items()}
        assert bound==record['declarations'],'Changed logical interface or proof body: '+relative
    packages={p['id']:p for p in registry['packages']}
    for package in packages.values():
        descriptor=json.loads((ROOT/package['canonicalDescriptor']).read_text())
        assert descriptor['id']==package['id']
        closure=descriptor['closureSha256'];visited=set()
        def walk(relative):
            if relative in visited:return
            visited.add(relative)
            path=ROOT/relative
            assert relative in preservation or relative in external, 'Unbound closure dependency: '+relative
            assert digest(path)==closure[relative]
            for include in re.findall(r'^\s*include "([^\"]+)"',path.read_text(),re.M):
                child=str((path.parent/include).resolve().relative_to(ROOT))
                if child not in closure:
                    assert package['selectionRole']=='generation-intermediate'
                    assert child in descriptor['missingInputs'] and not (ROOT/child).exists()
                else:walk(child)
        for entry in descriptor['verificationEntries']:walk(entry)
        assert visited==set(closure) and set(descriptor['implementations'])<=visited
    count=0
    for contract in registry['contracts']:
        for record in json.loads((LIBRARY/'source/declarations'/contract/'declarations.json').read_text())['records']:
            assert record['contract']==contract
            declaration=parsed[record['canonicalFile']][record['symbol']]
            assert declaration['kind']==record['kind'] and declaration['interface']==record['logicalInterface']
            assert hashlib.sha256(record['logicalInterface'].encode()).hexdigest()==record['interfaceSha256']
            count+=1
    assert count==registry['uniqueIndexedDeclarations']
    for record in json.loads((LIBRARY/'helper-interfaces.json').read_text())['records']:
        d=parsed[record['canonicalFile']][record['symbol']]
        assert d['kind']==record['kind'] and d['interface']==record['logicalInterface']
    graph=json.loads((LIBRARY/'dependency-graph.json').read_text())['files']
    assert set(graph)==actual
    for relative,edges in graph.items():
        path=ROOT/relative
        expected=[{'path':str((path.parent/i).resolve().relative_to(ROOT)), 'exists':(path.parent/i).resolve().is_file()} for i in re.findall(r'^include "([^\"]+)"',path.read_text(),re.M)]
        assert edges==expected,relative
    for foundation in json.loads((LIBRARY/'foundations/registry.json').read_text())['foundations']:
        assert digest(ROOT/foundation['file'])==foundation['sha256']
        for interface in foundation['interfaces']:
            d=parsed[foundation['file']][interface['symbol']]
            assert d['kind']==interface['kind'] and d['interface']==interface['logicalInterface']
    from claim_mapping import validate_mappings
    validate_mappings(ROOT, LIBRARY, parsed)
    from migration import validate_migration
    validate_migration(parsed)
    print(f'PASS: {len(actual)} canonical files, {count} indexed declarations, {len(packages)} descriptors. No acceptance transferred.')

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--list',action='store_true');args=parser.parse_args()
    check()
    if args.list:
        for p in json.loads((LIBRARY/'registry.json').read_text())['packages']:print(p['id'],p['selectionRole'])
