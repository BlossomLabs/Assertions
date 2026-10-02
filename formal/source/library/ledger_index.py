"""Resolve retained ledger declaration references to the canonical source library.

This publishes navigation and preserved premises, never fresh acceptance.
"""
import argparse
import json
import hashlib
import re
from check import ROOT, LIBRARY, check, digest
from declarations import declarations


def leaves(value, field=()):
    if isinstance(value,dict):
        for key, child in value.items():
            yield from leaves(child,field+(key,))
    elif isinstance(value,list):
        for index, child in enumerate(value):
            yield from leaves(child,field+(index,))
    elif isinstance(value,str):
        yield field,value


def build_index():
    inventory = json.loads((LIBRARY/'original-inventory.json').read_text())
    registry = json.loads((LIBRARY/'registry.json').read_text())
    packages = {}
    for package in registry['packages']:
        if package['selectionRole'] != 'proof-package':
            continue
        descriptor = json.loads((ROOT/package['canonicalDescriptor']).read_text())
        for path in descriptor['implementations']:
            packages.setdefault(path,[]).append(package['id'])
    names = {}
    for path in (LIBRARY/'src').rglob('*.dfy'):
        relative = str(path.relative_to(ROOT))
        module = re.search(r'(?m)^module (\w+)',path.read_text())[1]
        for symbol, declaration in declarations(path).items():
            names.setdefault(module+'.'+symbol,[]).append({
                'canonicalFile':relative,'canonicalDeclarationId':relative+'::'+symbol,
                'kind':declaration['kind'],'interfaceSha256':hashlib.sha256(declaration['interface'].encode()).hexdigest(),
                'packages':packages.get(relative,[])})
    ledgers = []
    for ledger in inventory['ledgers']:
        assert digest(ROOT/ledger['path']) == ledger['sha256'], ledger['path']
        references = []
        for field,text in leaves(ledger.get('claims')):
            # Claim records use either an exact qualified name or prose. Only
            # entire qualified-name strings are interpreted as declarations.
            if not re.fullmatch(r'[A-Za-z_]\w*\.[A-Za-z_]\w*',text):
                continue
            matches = names.get(text,[])
            references.append({'field':list(field),'qualifiedName':text,
                               'resolution':'unique' if len(matches)==1 else 'ambiguous' if matches else 'unresolved',
                               'candidates':matches})
        ledgers.append(dict(ledger, declarationReferences=references,
                            canonicalAcceptance='not-recertified',bytecodeCredit=False))
    refs = [r for ledger in ledgers for r in ledger['declarationReferences']]
    return {'scope':'Retained public/source ledger claims and premises, resolved by exact qualified declaration names. Navigation does not transfer historical acceptance.',
            'inputs':{'originalInventorySha256':digest(LIBRARY/'original-inventory.json'),
                      'canonicalSourcesSha256':digest(LIBRARY/'canonical-sources.json'),
                      'registrySha256':digest(LIBRARY/'registry.json')},
            'counts':{'ledgers':len(ledgers),'declarationReferences':len(refs),
                      **{state:sum(r['resolution']==state for r in refs) for state in ['unique','ambiguous','unresolved']}},
            'ledgers':ledgers}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check',action='store_true')
    args=parser.parse_args()
    check()
    result=build_index()
    target=LIBRARY/'claim-ledgers.json'
    if args.check:
        assert json.loads(target.read_text()) == result, 'Stale claim ledger index'
    else:
        target.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result['counts']))

if __name__=='__main__':
    main()
