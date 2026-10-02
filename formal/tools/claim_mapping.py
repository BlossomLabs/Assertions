"""Validate current claim bindings without inferring acceptance from theorem names."""
import hashlib
import json

def validate_mappings(root, library, parsed):
    index=json.loads((library/'claims.json').read_text())
    assert index['schemaVersion']==1
    assert index['ledger']=='docs/claim-evidence.json'
    current=json.loads((root/index['ledger']).read_text())['claims']
    assert set(index['claims'])==set(current), 'Public claim inventory drift; reconcile formal/claims.json'
    for identifier, claim in index['claims'].items():
        assert claim['recordedClaim']==current[identifier]['recordedClaim'], 'Public claim wording drift: '+identifier
        proofs=claim['sourceProofs']+claim['bytecodeProofs']
        assert claim['mappingStatus']==('mapped' if proofs else 'unmapped'), identifier
        for proof in proofs:
            assert proof['coverage'] in ['partial','full']
            assert proof['obligation'].strip() and proof['assumptions'].strip()
            assert proof['mappingReview']=='pending', 'Independent mapping acceptance is not implemented'
            for theorem in proof['theorems']:
                file,symbol=theorem['declaration'].rsplit('::',1)
                declaration=parsed[file][symbol]
                assert declaration['kind'] in ['lemma','method'], 'Mapping must cite a proof declaration'
                assert hashlib.sha256(declaration['full'].encode()).hexdigest()==theorem['fullSha256'], 'Mapped theorem drift'
            assert proof['theorems'], 'Empty proof mapping'
    return index, current
