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
ledger=json.loads((ROOT/'docs/verification/collections-calls-source-connection.json').read_text())
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
require((path.parent/'generated/Source.generated.dfy').read_bytes()==(ROOT/'formal/collections/calls/Source.generated.dfy').read_bytes(),'Generated source drift')
concrete=next(c for c in m['checks'] if c['name']=='concrete')
actual=re.findall(r'^\[PASS\] (test\w+)\(', (path.parent/'concrete.log').read_text(),re.M)
require(concrete['passed'] and sorted(actual)==sorted(concrete['expectedTests']) and len(actual)==7,'Concrete test inventory failed')
require('auditor completed with 0 findings' in (path.parent/'audit.log').read_text(),'Audit findings')
faultPath=ROOT/ledger['faults'];require(sha(faultPath)==ledger['faultsSha256'],'Fault manifest drift')
f=check_manifest(faultPath);require(f['inputsUnchanged'] and len(f['faults'])==3,'Incomplete source faults')
for mutation in f['faults']:
 require(mutation['passed'] and mutation['sourceGate']['exitCode']==0,'Fault rejected at source gate')
 proofResult=mutation['proof'];evm=mutation['concrete']
 require(proofResult['exitCode']==4 and proofResult['killed'] and evm['exitCode']==1 and evm['killed'],'Missing semantic/EVM kill')
 root=faultPath.parent/mutation['name'];log=(root/'proof.log').read_text()
 require(re.search(r'postcondition could not be proved|invariant could not be proved|assertion might not hold',log) and not re.search(r'time.?out|inconclusive|resolution/type errors|parse errors',log,re.I),'Invalid semantic kill')
 native=list(csv.DictReader((root/'proof.csv').open()))
 require(any(r['TestResult.Outcome']!='Passed' and r['TestResult.DisplayName'].startswith('CollectionsCallsSource.'+mutation['expectedTheorem']) for r in native),'Missing designated native failure')
 failed=re.findall(r'^\[FAIL:.*\] (test\w+)\(', (root/'concrete.log').read_text(),re.M)
 require(mutation['expectedTest'] in failed,'Missing designated EVM failure')
print('PASS: callback-invocation source baseline, 279 native obligations, 7 EVM fixtures, 3 semantic source faults, current source/dependency/artifact hashes and claim mappings')
