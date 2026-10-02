"""Bind each library package to its canonical relocated closure."""
import hashlib
import json
import re
from pathlib import Path
from check import ROOT, LIBRARY


def main():
    registry = json.loads((LIBRARY/'registry.json').read_text())
    sources = json.loads((LIBRARY/'canonical-sources.json').read_text())
    aliases = dict(sources['implementationAliases'])
    for row in sources['files']:
        aliases[row['selectedImplementation']] = row['canonicalFile']
    for package in registry['packages']:
        old = json.loads((ROOT/package['descriptor']).read_text())
        implementations = sorted({aliases[f] for f in package['implementations']})
        seen = {}
        missing = set()
        edges = {}
        def walk(relative):
            path = ROOT/relative
            if not path.exists():
                missing.add(relative)
                return
            if relative in seen:
                return
            seen[relative] = hashlib.sha256(path.read_bytes()).hexdigest()
            edges[relative] = []
            for include in re.findall(r'^include "([^"]+)"',path.read_text(),re.M):
                child = str((path.parent/include).resolve().relative_to(ROOT))
                edges[relative].append(child)
                walk(child)
        for implementation in implementations:
            walk(implementation)
        included = {p for children in edges.values() for p in children}
        entries = sorted(set(seen)-included)
        assert entries, package['id']
        layers = {key:[] for key in ['mathematics','execution','correspondence','foundations']}
        for file in sorted(seen):
            p = Path(file)
            kind = 'foundations' if '/foundations/' in file else 'execution' if '.generated.' in file else 'correspondence' if p.name in ['Refinement.dfy','Connection.dfy','Correspondence.dfy'] else 'mathematics'
            layers[kind].append(file)
        descriptor = {'id':package['id'],'status':'blocked-missing-inputs' if missing else 'canonical-relocated-unverified',
                      'selectedImplementationStatus':package['status'],'entry':entries[0],
                      'verificationEntries':entries,'implementations':implementations,
                      'resourcePolicy':old['resourcePolicy'],'layers':layers,'closureSha256':seen,
                      'missingInputs':sorted(missing),'verificationScope':'Canonical relocated source closure. Fresh native gates required; historical/source correspondence acceptance is not inherited automatically.'}
        path = ROOT/package['descriptor']
        destination = path.with_name('canonical.json')
        destination.write_text(json.dumps(descriptor,indent=2)+'\n')
        package['canonicalDescriptor'] = str(destination.relative_to(ROOT))
    (LIBRARY/'registry.json').write_text(json.dumps(registry,indent=2)+'\n')
    print('Bound',len(registry['packages']),'canonical package closures.')

if __name__ == '__main__':
    main()
