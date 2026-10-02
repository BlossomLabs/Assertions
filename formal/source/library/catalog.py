"""Generate shared-foundation and package dependency catalogs from bound closures."""
import hashlib
import json
import re
from pathlib import Path
from check import ROOT, LIBRARY, check
from declarations import declarations


def main():
    check()
    registry = json.loads((LIBRARY/'registry.json').read_text())
    descriptors = {p['id']:json.loads((ROOT/p['canonicalDescriptor']).read_text()) for p in registry['packages']}
    foundations = []
    for path in sorted((LIBRARY/'src/foundations').glob('*.dfy')):
        relative = str(path.relative_to(ROOT))
        module = re.search(r'^module (\w+)',path.read_text(),re.M)[1]
        interfaces = declarations(path)
        consumers = sorted(key for key,value in descriptors.items() if relative in value['closureSha256'])
        foundations.append({'module':module,'file':relative,'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
                            'role':'Assertions constraint reasoning' if 'ConstraintFacts' in module else 'shared mathematical foundation',
                            'consumers':consumers,'interfaces':[{'symbol':name,'kind':value['kind'],'logicalInterface':value['interface']} for name,value in interfaces.items()],
                            'acceptance':'No independent source or bytecode acceptance inferred from publication.'})
    directory = LIBRARY/'foundations'
    directory.mkdir(exist_ok=True)
    (directory/'registry.json').write_text(json.dumps({'scope':'Canonical foundation interfaces and complete transitive consumers. Representation bridges remain caller obligations.','foundations':foundations},indent=2)+'\n')
    graph = {}
    for path in sorted((LIBRARY/'src').rglob('*.dfy')):
        children = []
        for include in re.findall(r'^include "([^"]+)"',path.read_text(),re.M):
            child = (path.parent/include).resolve()
            children.append({'path':str(child.relative_to(ROOT)),'exists':child.is_file()})
        graph[str(path.relative_to(ROOT))] = children
    (LIBRARY/'dependency-graph.json').write_text(json.dumps({'scope':'Direct canonical include edges, with missing inputs explicit.','files':graph},indent=2)+'\n')
    print('Published',len(foundations),'foundation interfaces and',len(graph),'source dependency nodes.')

if __name__ == '__main__':
    main()
