"""Report library structure and evidence without conflating native and source acceptance."""
import argparse
import hashlib
import json
from pathlib import Path
from check import ROOT, LIBRARY, check, digest


def covers_closure(manifest, descriptor):
    closure = descriptor['closureSha256']
    return bool(closure) and not descriptor.get('missingInputs') and all(
        manifest['sources'].get(p) == h and digest(ROOT/p) == h
        for p,h in closure.items())


def build_status():
    registry = json.loads((LIBRARY/'registry.json').read_text())
    reviews = {}
    for path in (LIBRARY/'evidence/reviews').glob('*.json'):
        review = json.loads(path.read_text())
        if review.get('status') != 'independently-reviewed-native-closure':
            continue
        manifest_path = ROOT/review['evidence']/'manifest.json'
        if digest(manifest_path) != review['manifestSha256']:
            continue
        manifest = json.loads(manifest_path.read_text())
        tools = {'dafny':ROOT/'proof-tools/assertions/dafny/dafny', 'Dafny.dll':ROOT/'proof-tools/assertions/dafny/Dafny.dll', 'z3':ROOT/'proof-tools/assertions/dafny/z3/bin/z3-4.12.1'}
        if any(digest(tools[k]) != h for k,h in manifest['tools'].items()):
            continue
        if any(not (ROOT/review['evidence']/p).is_file() or digest(ROOT/review['evidence']/p) != h for p,h in manifest['evidenceSha256'].items()):
            continue
        reviews.setdefault(review['package'],[]).append((path,review,manifest))
    from generation_status import generation_status
    generated=generation_status()
    rows = []
    all_reviews = [item for items in reviews.values() for item in items]
    for package in registry['packages']:
        descriptor = json.loads((ROOT/package['canonicalDescriptor']).read_text())
        native = 'not-independently-reviewed'
        accepted = []
        for path,review,manifest in all_reviews:
            # A reviewed complete closure also verifies its hash-identical subclosures.
            closure = descriptor['closureSha256']
            if covers_closure(manifest, descriptor):
                native = 'independently-reviewed-native'
                accepted.append({'review':str(path.relative_to(ROOT)),'coveringPackage':review['package'],'coverage':'exact-closure' if manifest['sources']==closure else 'reviewed-superset','coveringNativeRows':review['nativeRows']})
        rows.append({'package':package['id'],'role':package['selectionRole'],
                     'implementationStatus':package['status'],'canonicalNativeStatus':native,
                     'missingInputs':descriptor.get('missingInputs',[]),'nativeEvidence':accepted,
                     'canonicalGenerationStatus':'independently-reviewed-generation' if package['id'] in generated else 'not-independently-reviewed',
                     'generationEvidence':generated.get(package['id'],[]),
                     'canonicalSourceAcceptance':'not-established-by-native-status',
                     'bytecodeCredit':False})
    return {'scope':'Evidence-backed library status. Native review does not establish source correspondence or bytecode equivalence.',
            'canonicalFiles':len(json.loads((LIBRARY/'preservation.json').read_text())['files']),
            'originalDeclarationIdentities':registry['canonicalOriginalDeclarations'],
            'additionalHelperDeclarations':len(json.loads((LIBRARY/'helper-interfaces.json').read_text())['records']),
            'packages':rows}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--json', action='store_true')
    parser.add_argument('--include-intermediates', action='store_true')
    args = parser.parse_args()
    check()
    status = build_status()
    if args.json:
        print(json.dumps(status,indent=2))
    else:
        print(status['canonicalFiles'],'canonical files;',status['originalDeclarationIdentities'],'original declarations;',status['additionalHelperDeclarations'],'additional helpers')
        for row in status['packages']:
            if row['role'] == 'generation-intermediate' and not args.include_intermediates:
                continue
            print(row['package'],row['canonicalNativeStatus'],row['implementationStatus'])

if __name__ == '__main__':
    main()
