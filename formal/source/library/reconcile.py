"""Reconcile original conventional source files and retained correspondence ledgers.

This records provenance and unresolved references, not verification acceptance.
"""
import hashlib
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIB = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('mapping', LIB/'declarations.py')
mapping = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mapping)
OWNERS = {'constraints':'Assertions','composition':'Assertions','arguments':'Assertions',
          'navigation':'Assertions','control':'Assertions','resolution':'Assertions','core':'Assertions',
          'signed-mod':'Operations','operations':'Operations','collections':'Collections',
          'expressions':'Expressions','abi':'SharedABI'}

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def leaves(value, path=()):
    if isinstance(value, dict):
        for key, item in value.items():
            yield from leaves(item, path+(key,))
    elif isinstance(value, list):
        for i, item in enumerate(value):
            yield from leaves(item, path+(str(i),))
    elif isinstance(value, str):
        yield path, value

def build():
    selected = json.loads((ROOT/'formal/source/active-inventory.json').read_text())
    registry = json.loads((LIB/'registry.json').read_text())
    mapped = set()
    for owner in registry['contracts']:
        mapped.update(r['originalFile'] for r in json.loads((LIB/'contracts'/owner/'claims.json').read_text())['records'])
    files = []
    issues = []
    for candidate in selected['files']:
        if candidate['classification'] != 'live-source':
            continue
        p = ROOT/candidate['path']
        row = {'path':candidate['path'],'contract':OWNERS[p.relative_to(ROOT/'formal').parts[0]],
               'currentSha256':sha(p),'mapped':candidate['path'] in mapped}
        try:
            declarations = mapping.declarations(p)
            row['declarations'] = [{'id':candidate['path']+'::'+name,'symbol':name,'kind':d['kind'],
                                    'logicalInterface':d['interface'],'interfaceSha256':hashlib.sha256(d['interface'].encode()).hexdigest()}
                                   for name,d in declarations.items()]
        except (AssertionError, ValueError) as error:
            row['declarations'] = None
            issues.append({'file':candidate['path'],'issue':'conservative-declaration-extraction-failed','detail':str(error)})
        imports = []
        for name in re.findall(r'^include "([^"]+)"',p.read_text(),re.M):
            child = (p.parent/name).resolve()
            relative = str(child.relative_to(ROOT)) if child.is_relative_to(ROOT) else str(child)
            item = {'path':relative,'exists':child.is_file()}
            if child.is_file():
                item['sha256'] = sha(child)
            else:
                issues.append({'file':candidate['path'],'issue':'missing-include','include':relative})
            imports.append(item)
        row['imports'] = imports
        files.append(row)
    ledgers = []
    for original in selected['sourceCorrespondenceLedgers']:
        p = ROOT/original['path']
        data = json.loads(p.read_text())
        references = []
        for field,value in leaves(data):
            if value.startswith('formal/') and not any(c.isspace() for c in value):
                target = ROOT/value
                item = {'field':list(field),'path':value,'exists':target.exists()}
                if target.is_file():
                    item['sha256'] = sha(target)
                    expected = data
                    for component in field[:-1]:
                        expected = expected[int(component)] if isinstance(expected,list) else expected[component]
                    expected = expected.get(field[-1]+'Sha256') if isinstance(expected,dict) else None
                    if expected:
                        item['recordedHashMatches'] = expected == item['sha256']
                references.append(item)
        ledgers.append({'path':original['path'],'sha256':sha(p),'scope':data.get('scope'),
                        'claims':data.get('claims',data.get('entries',[])),
                        'assumptions':data.get('assumptions',data.get('partialClaims')),
                        'references':references,'status':'retained-original-not-recertified'})
    result = {'scope':'Conventional original source selection plus retained ledger provenance; complete-interface extraction and direct-import resolution. Missing/generated references and selection reconciliation remain explicit. No acceptance inferred.',
              'sourceFiles':files,'ledgers':ledgers,'issues':issues,
              'counts':{'sourceFiles':len(files),'extractedDeclarations':sum(len(f['declarations'] or []) for f in files),
                        'ledgerFiles':len(ledgers),'issues':len(issues)}}
    (LIB/'original-inventory.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result['counts']))

if __name__ == '__main__':
    build()
