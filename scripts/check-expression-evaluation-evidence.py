#!/usr/bin/env python3
"""Audit recursive control evidence without claiming Solidity correspondence."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,message):
    if not ok:raise SystemExit(message)
p=ROOT/'formal/expressions/evaluation/evidence/recursive-control/manifest.json'
m=json.loads(p.read_text());require(m['status']=='passed' and m['inputsUnchanged'],'Incomplete recursive control proof')
for name,digest in m['sourceSha256'].items():require(sha(ROOT/name)==digest,'Source drift '+name)
for name,digest in m['evidenceSha256'].items():require(sha(p.parent/name)==digest,'Evidence drift '+name)
for check in m['checks']:require(check['passed'],'Failed check '+check['name'])
proof=next(c for c in m['checks'] if c['name']=='proof')
require(proof['nativeResults'] and all(r['TestResult.Outcome']=='Passed' for r in proof['nativeResults']),'Native proof failure')
require(all(d['status']=='passed' for d in proof['declarations'] if d['kind'] in {'method','lemma'}),'Unproved declaration')
closure=next(c for c in m['checks'] if c['name']=='dependency-closure')
for entry in closure['dependencies']:
    dep=ROOT/entry['manifest'];require(sha(dep)==entry['sha256'],'Dependency manifest drift')
    prior=json.loads(dep.read_text());require(prior['status']=='passed','Unproved dependency')
    for name,digest in prior['sourceSha256'].items():require(sha(ROOT/name)==digest,'Dependency source drift '+name)
    for name,digest in prior['evidenceSha256'].items():require(sha(dep.parent/name)==digest,'Dependency evidence drift '+name)
require(len(m['modelFaults'])==3 and all(f['killed'] and f['proof']['exitCode']==4 for f in m['modelFaults']),'Missing model fault kills')
print('PASS:',len(proof['nativeResults']),'recursive control/ABI bridge obligations and three model fault kills; production lowering remains open')
