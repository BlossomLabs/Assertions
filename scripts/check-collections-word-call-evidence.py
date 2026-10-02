#!/usr/bin/env python3
"""Audit retained receipt proof evidence, current inputs and claim mappings."""
import csv,hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,message):
 if not ok:raise SystemExit(message)
def check_manifest(path):
 m=json.loads(path.read_text());require(m['status']=='passed','Unproved manifest '+str(path))
 for src,digest in m['sourceSha256'].items():require(sha(ROOT/src)==digest,'Source drift '+src)
 for artifact,digest in m['evidenceSha256'].items():require(sha(path.parent/artifact)==digest,'Evidence drift '+artifact)
 return m
ledger=json.loads((ROOT/'docs/verification/collections-word-call-source-connection.json').read_text())
path=ROOT/ledger['baseline'];require(sha(path)==ledger['baselineSha256'],'Manifest drift')
m=check_manifest(path);require(m['inputsUnchanged'] and all(c['passed'] for c in m['checks']),'Failed checks')
deps=next(c for c in m['checks'] if c['name']=='dependency-closure')
for dep in deps['dependencies']:
 p=ROOT/dep['manifest'];require(sha(p)==dep['sha256'],'Dependency manifest drift');check_manifest(p)
proof=next(c for c in m['checks'] if c['name']=='proof')
rows=list(csv.DictReader((path.parent/'proof.csv').open()))
require(rows and all(r['TestResult.Outcome']=='Passed' for r in rows),'Native proof failed')
declarations={d['name']:d for d in proof['declarations']}
for d in declarations.values():
 if d['kind'] in {'method','lemma'}:
  require(d['status']=='passed' and any(r['TestResult.DisplayName'].split(' (')[0]==d['name'] for r in rows),'Missing native declaration '+d['name'])
for claim,names in ledger['claims'].items():
 require(re.search(r'^\| '+re.escape(claim)+r' \|',(ROOT/'docs/claims.md').read_text(),re.M),'Unknown claim '+claim)
 for name in names:require(name in declarations and declarations[name]['status']=='passed','Unproved claim '+name)
gate=next(c for c in m['checks'] if c['name']=='source-gate')
require(gate['passed'],'Failed source gate')
require((path.parent/'generated/Source.generated.dfy').read_bytes()==(ROOT/'formal/collections/word-call/Source.generated.dfy').read_bytes(),'Generated source drift')
concrete=next(c for c in m['checks'] if c['name']=='concrete')
actual=re.findall(r'^\[PASS\] (test\w+)\(', (path.parent/'concrete.log').read_text(),re.M)
require(concrete['passed'] and sorted(actual)==sorted(concrete['expectedTests']) and len(actual)==8,'Concrete test inventory failed')
require('auditor completed with 0 findings' in (path.parent/'audit.log').read_text(),'Audit findings')
faults=json.loads((path.parent/'source-faults/results.json').read_text())
require(len(faults)==3 and all(all(c['passed'] for c in f['checks']) for f in faults),'Missing source fault evidence')
for f in faults:
 folder=path.parent/'source-faults'/f['name']
 require(any(x in (folder/'proof.log').read_text() for x in ['might not hold','postcondition could not be proved']),'No semantic fault rejection')
 require(re.search(r'\[FAIL[^\n]*\] test',(folder/'concrete.log').read_text()),'No EVM fault rejection')
require(ledger['completedPublicEntries']==[],'Fragment must not claim public source coverage')
require(len(rows)==ledger['obligations'],'Obligation count drift')
print(f"PASS: word domain/call source connection, {len(rows)} native obligations, zero audit, 8 EVM fixtures, 3 detected domain/call faults and dependency/source/evidence hashes")
