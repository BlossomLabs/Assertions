#!/usr/bin/env python3
"""Check retained guarded-control source evidence and its supplemental claim mapping."""
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
    path = ROOT/'docs/verification/control-source-connection.json'
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
    require(baseline['sourceSha256'] == faults['sourceSha256'], 'Baseline/fault inputs differ')
    require(baseline['executableSha256'] == faults['executableSha256'], 'Baseline/fault tools differ')
    declarations = {d['name']:d for c in baseline['checks'] for d in c.get('declarations',[])}
    for claim,names in ledger['claims'].items():
        require(re.search(r'^\| '+re.escape(claim)+r' \|', (ROOT/'docs/claims.md').read_text(), re.M), 'Unknown claim '+claim)
        for name in names:
            require(name in declarations and declarations[name]['status']=='passed', 'Unproved declaration '+name)
    require(all(f['passed'] and f['sourceGate']['exitCode']==0 and f['proof']['killed'] and f['concrete']['killed'] for f in faults['faults']), 'Incomplete fault campaign')
    require(ledger['productionSourceSha256'] == sha(ROOT/'contracts/Assertions.sol'), 'Production source drift')
    print('PASS: guarded-control baseline, fault campaign, current source/evidence hashes and '+str(len(ledger['claims']))+' supplemental claim mappings')


if __name__ == '__main__':
    main()
