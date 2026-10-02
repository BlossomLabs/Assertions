"""Materialize canonical proof sources, preserving all old implementations.

Only include paths change. Exact declaration interfaces and bodies are checked
against selected implementations; relocated proofs require fresh verification.
"""
import hashlib
import json
import os
import re
from pathlib import Path
from declarations import declarations

ROOT = Path(__file__).resolve().parents[3]
LIB = Path(__file__).resolve().parent
SRC = LIB/'src'
ASSERTIONS = {'constraints','composition','arguments','navigation','control','resolution','core'}

def canonical(original):
    parts = Path(original).relative_to('formal').parts
    if parts[0] in ASSERTIONS:
        return SRC/'assertions'/Path(*parts)
    if parts[0] == 'signed-mod':
        return SRC/'operations'/Path(*parts)
    return SRC/Path(*parts)

def main():
    registry = json.loads((LIB/'registry.json').read_text())
    inventory = json.loads((LIB/'original-inventory.json').read_text())
    selected = {r['path']:r['path'] for r in inventory['sourceFiles']}
    aliases = {}
    for package in registry['packages']:
        if 'mapping' not in package:
            continue
        mapping = json.loads((ROOT/package['mapping']['path']).read_text())
        for record in mapping['rows']:
            original = record['oldFile']
            if original.endswith('Engine.original.dfy.txt'):
                original = 'formal/constraints/Engine.generated.dfy'
            elif original.endswith('Source.original.dfy.txt'):
                original = 'formal/expressions/recursive/Source.generated.dfy'
            assert original in selected, original
            selected[original] = record['newFile']
            aliases[record['newFile']] = canonical(original)
    for original in selected:
        aliases[original] = canonical(original)
    selected_modules = {}
    for relative in selected.values():
        p = ROOT/relative
        module = re.search(r'^module (\w+)',p.read_text(),re.M)
        assert module, relative
        name = module[1]
        selected_modules.setdefault(name, []).append(relative)
    closure = set()
    def walk(relative):
        if relative in closure:
            return
        p = ROOT/relative
        if not p.exists():
            return
        closure.add(relative)
        if relative not in aliases:
            module = re.search(r'^module (\w+)',p.read_text(),re.M)
            assert module, relative
            if module[1] in selected_modules:
                equivalents = [candidate for candidate in selected_modules[module[1]] if declarations(p) == declarations(ROOT/candidate)]
                assert equivalents, ('Different implementation of selected module',relative,selected_modules[module[1]])
                aliases[relative] = aliases[equivalents[0]]
            else:
                aliases[relative] = SRC/'foundations'/(module[1]+'.dfy')
        for child in re.findall(r'^include "([^"]+)"',p.read_text(),re.M):
            resolved = str((p.parent/child).resolve().relative_to(ROOT))
            if resolved in selected:
                resolved = selected[resolved]
            walk(resolved)
    for relative in selected.values():
        walk(relative)
    destinations = {}
    receipts = []
    for relative in sorted(closure):
        source = ROOT/relative
        destination = aliases[relative]
        text = source.read_text()
        def include(match):
            target = str((source.parent/match[1]).resolve().relative_to(ROOT))
            if target in selected:
                target = selected[target]
            path = aliases.get(target)
            if path is None:
                # Retain explicitly missing conventional inputs as missing canonical inputs.
                assert not (ROOT/target).exists(), target
                path = canonical(target)
            return 'include "'+os.path.relpath(path,destination.parent)+'"'
        updated = re.sub(r'^include "([^"]+)"',include,text,flags=re.M)
        if destination in destinations:
            assert destinations[destination] == updated, ('Conflicting canonical module',destination)
        destinations[destination] = updated
        destination.parent.mkdir(parents=True,exist_ok=True)
        destination.write_text(updated)
        before,after = declarations(source),declarations(destination)
        assert before == after, ('Relocation changed declaration',relative)
        receipts.append({'selectedImplementation':relative,'implementationSha256':hashlib.sha256(source.read_bytes()).hexdigest(),
                         'canonicalFile':str(destination.relative_to(ROOT)),
                         'canonicalSha256':hashlib.sha256(destination.read_bytes()).hexdigest(),
                         'interfacesAndBodiesUnchanged':True})
    receipt = {'scope':'Canonical path relocation only; original and migration proofs preserved. Fresh native/source acceptance still required.',
               'files':receipts,'canonicalFiles':len(destinations),'originalSelection':{original:str(aliases[implementation].relative_to(ROOT)) for original,implementation in selected.items()},'implementationAliases':{relative:str(destination.relative_to(ROOT)) for relative,destination in aliases.items()}}
    (LIB/'canonical-sources.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print('Materialized',len(destinations),'canonical source files; declaration interfaces and bodies unchanged.')

if __name__ == '__main__':
    main()
