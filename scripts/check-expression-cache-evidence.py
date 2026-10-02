#!/usr/bin/env python3
"""Check retained expression cache transition evidence and its supplemental claim mapping."""
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def require(condition, message):
    if not condition:
        raise SystemExit(message)


def main():
    path = ROOT/'docs/verification/expression-cache-source-connection.json'
    ledger = json.loads(path.read_text())
    manifests = []
    for key in ['baseline', 'faults']:
        p = ROOT/ledger[key]
        require(sha(p) == ledger[key+'Sha256'], key+' manifest drift')
        manifest = json.loads(p.read_text())
        require(manifest['status'] == 'passed' and manifest['inputsUnchanged'], key+' did not pass')
        for source,digest in manifest['sourceSha256'].items():
            require(sha(ROOT/source) == digest, 'Source drift: '+source)
        for artifact,digest in manifest['evidenceSha256'].items():
            require(sha(p.parent/artifact) == digest, 'Evidence drift: '+artifact)
        manifests.append(manifest)
    baseline,faults = manifests
    dependency = next(c for c in baseline['checks'] if c.get('name')=='dependency-closure')
    require(dependency['passed'] and dependency['reusedModules'], 'Missing dependency closure')
    for entry in dependency['dependencies']:
        p=ROOT/entry['manifest']
        require(sha(p)==entry['sha256'], 'Dependency manifest drift')
        prior=json.loads(p.read_text())
        require(prior['status']=='passed', 'Unproved dependency')
        for source,digest in prior['sourceSha256'].items():
            require(sha(ROOT/source)==digest, 'Dependency source drift: '+source)
        for artifact,digest in prior['evidenceSha256'].items():
            require(sha(p.parent/artifact)==digest, 'Dependency evidence drift: '+artifact)
    require(baseline['sourceSha256'] == faults['sourceSha256'], 'Baseline/fault inputs differ')
    require(baseline['executableSha256'] == faults['executableSha256'], 'Baseline/fault tools differ')
    declarations = {d['name']:d for c in baseline['checks'] for d in c.get('declarations',[])}
    for claim,names in ledger['claims'].items():
        require(re.search(r'^\| '+re.escape(claim)+r' \|', (ROOT/'docs/claims.md').read_text(), re.M), 'Unknown claim '+claim)
        for name in names:
            require(name in declarations and declarations[name]['status']=='passed', 'Unproved declaration '+name)
    require(all(f['passed'] and f['sourceGate']['exitCode']==0 and f['proof']['killed'] and f['concrete']['killed'] for f in faults['faults']), 'Incomplete fault campaign')
    require(ledger['productionSourceSha256'] == sha(ROOT/'contracts/Expressions.sol'), 'Production source drift')
    print('PASS: expression cache baseline, fault campaign, current source/evidence hashes and '+str(len(ledger['claims']))+' supplemental claim mappings')


if __name__ == '__main__':
    main()
