#!/usr/bin/env python3
"""Validate and summarize the retained Kontrol/reference verification runs."""
import csv
import hashlib
import json
from pathlib import Path
import tarfile

ROOT = Path(__file__).resolve().parents[3]
EVIDENCE = ROOT / 'docs/verification/signed-mod'


def read(path):
    return json.loads((EVIDENCE / path).read_text())


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def closed(proof):
    return (proof['status'] == 'passed' and not proof['admitted']
            and not proof['pending'] and not proof['failing']
            and not proof['bounded'] and not proof['subproofs'])


def validate_archive(directory, label, records):
    manifest = read(directory + '/manifest.json')
    name = label + '-proofs.tar.gz'
    path = EVIDENCE / directory / name
    assert sha(path) == manifest[name]['sha256']
    with tarfile.open(path, 'r:gz') as archive:
        for proof in records:
            data = archive.extractfile('proofs/' + proof['id'] + '/proof.json').read()
            assert hashlib.sha256(data).hexdigest() == proof['proofJsonSha256']


def main():
    initial = read('kontrol/manifest.json')
    followup = read('kontrol-followup/manifest.json')
    values = read('kontrol-values/manifest.json')
    reference = read('reference/manifest.json')
    harness = read('kontrol-harness/manifest.json')
    proofs = read('kontrol-values/positive-proof-status.json')
    mutants = read('kontrol-followup/mutant-proof-status.json')
    assert followup.get('completedAt') and values.get('completedAt')
    validate_archive('kontrol-values', 'positive', proofs)
    validate_archive('kontrol-followup', 'mutant', mutants)
    assert reference['status'] == 'proved' and harness['status'] == 'passed'
    for path, expected in reference['sourceSha256'].items():
        assert sha(ROOT / path) == expected, 'Reference source drift: ' + path
    assert sha(ROOT / 'contracts/Operations.sol') == initial['sourceSha256']['contracts/Operations.sol']
    assert harness['checks'][0]['runtimeSha256'] == initial['runtimeSha256']
    rows = list(csv.DictReader((EVIDENCE / 'reference/results.csv').open()))
    assert len(rows) == 101 and all(row['TestResult.Outcome'] == 'Passed' for row in rows)
    setup = [p for p in proofs if '.setUp():' in p['id']]
    assert len(setup) == 1 and closed(setup[0])
    names = ['prove_addZeroModulus', 'prove_mulZeroModulus', 'prove_addReference', 'prove_mulReference']
    results = []
    for name in names:
        matches = [p for p in proofs if '.' + name + '(' in p['id']]
        assert len(matches) == 1
        proof = matches[0]
        status = 'PROVED' if closed(proof) else 'INCOMPLETE'
        results.append(dict(property=name, status=status, proofId=proof['id'],
                            pending=proof['pending'], failing=proof['failing'],
                            bounded=proof['bounded'], admitted=proof['admitted']))
    negative = [p for p in mutants if '.prove_' in p['id']]
    assert len(negative) == 2
    assert all(p['status'] == 'failed' and p['failing'] and not p['admitted']
               and not p['bounded'] for p in negative)
    reference_control = read('reference/negative-control.json')
    assert reference_control['status'] == 'killed'
    summary = dict(runtimeSha256=initial['runtimeSha256'], imageId=initial['imageId'],
                   properties=results, proved=sum(r['status'] == 'PROVED' for r in results),
                   incomplete=sum(r['status'] == 'INCOMPLETE' for r in results),
                   referenceAssertionBatches=101, includedLemmas=13,
                   concreteHarnessTests=5, concreteFuzzCases=1024, concreteFixedWitnesses=4,
                   zeroModulusMutantsRefutedByKontrol=2, referenceSignMutantRejected=True,
                   gas='Abstracted; sufficient-gas arithmetic only',
                   crossToolTranslation='Manually reviewed Yul-to-Dafny mapping; not certified',
                   limitations=['Nonzero-result properties are incomplete unless individually marked PROVED.',
                                'An SMT solver error is an incomplete proof, not a contract counterexample.'],
                   evidenceSha256={path: sha(EVIDENCE / path) for path in [
                       'kontrol/manifest.json', 'kontrol-followup/manifest.json',
                       'kontrol-values/manifest.json', 'reference/manifest.json',
                       'reference/negative-control.json', 'kontrol-harness/manifest.json']})
    (EVIDENCE / 'kontrol-summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary, indent=2))


if __name__ == '__main__':
    main()
