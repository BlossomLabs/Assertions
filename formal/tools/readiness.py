"""Report current public claims and their explicit library mappings."""
import argparse
import json
from check import ROOT, LIBRARY, check

def readiness():
    index=json.loads((LIBRARY/'claims.json').read_text())
    evidence=json.loads((ROOT/index['ledger']).read_text())['claims']
    rows=[]
    for identifier, claim in index['claims'].items():
        current=evidence[identifier]
        rows.append({'id':identifier,'claim':claim['recordedClaim'],
                     'mappingStatus':claim['mappingStatus'],
                     'publicEvidence':{'type':current.get('evidenceType'),'executionStatus':current.get('executionStatus')},
                     'sourceProofs':claim['sourceProofs'],'bytecodeProofs':claim['bytecodeProofs'],
                     'libraryAcceptance':'pending' if claim['mappingStatus']=='mapped' else 'unmapped'})
    return {'scope':'Current public ledger evidence remains separate from library acceptance. Historical mappings are excluded.',
            'counts':{'claims':len(rows),'mapped':sum(r['mappingStatus']=='mapped' for r in rows),
                      'unmapped':sum(r['mappingStatus']=='unmapped' for r in rows)},'claims':rows}

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--json',action='store_true')
    parser.add_argument('--claim',help='Show one current public claim ID.')
    args=parser.parse_args()
    check(); result=readiness()
    if args.claim:
        result['claims']=[r for r in result['claims'] if r['id']==args.claim]
        if not result['claims']:parser.error('Unknown public claim ID')
    if args.json:print(json.dumps(result,indent=2))
    else:
        print(json.dumps(result['counts']))
        for row in result['claims']:print(row['id'],row['mappingStatus'],row['publicEvidence']['type'],row['publicEvidence']['executionStatus'])
if __name__=='__main__':main()
