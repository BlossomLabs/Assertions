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
ledger=json.loads((ROOT/'docs/verification/collections-value-sort-entry-source-connection.json').read_text())
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
require('auditor completed with 0 findings' in (path.parent/'audit.log').read_text(),'Audit findings')
require(len(rows)==ledger['obligations'],'Obligation count drift')
require(ledger['completedPublicEntries']==['sortValues'],'Public coverage drift')
concrete=next(c for c in m['checks'] if c['name']=='concrete')
actual=re.findall(r'^\[PASS\] (test\w+)\(', (path.parent/'concrete.log').read_text(),re.M)
require(concrete['passed'] and len(actual)==14 and sorted(actual)==sorted(concrete['expectedTests']),'EVM fixture inventory drift')
for name in ['formal/collections/plan.json','formal/verification-plan.json']:
 plan=json.loads((ROOT/name).read_text())
 if 'publicSourceCoverage' not in plan: plan=next(x for x in plan['milestones'] if x['name']=='Collections source correspondence')
 coverage=plan['publicSourceCoverage']
 require('sortValues' in coverage['completedEntries'] and 'sortValues' not in coverage['remainingEntries'],'Public completion not recorded')
 require(ledger['baseline'] in coverage['additionalEvidence'],'Missing public evidence')
print(f"PASS: public sortValues source composition, {len(rows)} native obligations, zero audit, 14 EVM fixtures, dependency/source/evidence hashes and claim mappings")
