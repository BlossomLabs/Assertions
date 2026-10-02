"""Show native coverage and outstanding source acceptance for retained claim ledgers."""
import argparse
import json
from check import ROOT, LIBRARY, check, digest
from status import build_status


def readiness():
    index=json.loads((LIBRARY/'claim-ledgers.json').read_text())
    statuses={p['package']:p for p in build_status()['packages']}
    rows=[]
    for ledger in index['ledgers']:
        references=[]
        for reference in ledger['declarationReferences']:
            covered=[]
            if reference['resolution']=='unique':
                candidate=reference['candidates'][0]
                covered=[p for p in candidate['packages']
                         if statuses[p]['canonicalNativeStatus']=='independently-reviewed-native']
            references.append({'field':reference['field'],'qualifiedName':reference['qualifiedName'],
                               'resolution':reference['resolution'],'nativeCoveredByPackages':covered})
        rows.append({'ledger':ledger['path'],'ledgerSha256':ledger['sha256'],
                     'nativeReferencedDeclarationsCovered':bool(references) and all(r['nativeCoveredByPackages'] for r in references),
                     'declarationReferences':references,
                     'canonicalSourceAcceptance':'pending-independent-source-correspondence-and-fault-review',
                     'premisesPreservedIn':'formal/claim-ledgers.json',
                     'exactBytecodeCredit':False})
    return {'scope':'Readiness of retained claims. Coverage of named declarations is not complete source acceptance, and is not evidence for unnamed/prose claims.',
            'counts':{'ledgers':len(rows),'ledgersWithAllNamedDeclarationsNativeCovered':sum(r['nativeReferencedDeclarationsCovered'] for r in rows)},
            'ledgers':rows}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--json',action='store_true')
    args=parser.parse_args()
    check()
    result=readiness()
    if args.json:
        print(json.dumps(result,indent=2))
    else:
        print(json.dumps(result['counts']))
        for row in result['ledgers']:
            covered=sum(bool(r['nativeCoveredByPackages']) for r in row['declarationReferences'])
            print(row['ledger'],f"named declarations native-covered {covered}/{len(row['declarationReferences'])}",row['canonicalSourceAcceptance'])

if __name__=='__main__':
    main()
