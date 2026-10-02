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
ledger=json.loads((ROOT/'docs/verification/collections-preparation-source-connection.json').read_text())
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
require((path.parent/'generated/Source.generated.dfy').read_bytes()==(ROOT/'formal/collections/preparation/Source.generated.dfy').read_bytes(),'Generated source drift')
concrete=next(c for c in m['checks'] if c['name']=='concrete')
actual=re.findall(r'^\[PASS\] (test\w+)\(', (path.parent/'concrete.log').read_text(),re.M)
require(concrete['passed'] and sorted(actual)==sorted(concrete['expectedTests']) and len(actual)==7,'Concrete test inventory failed')
require('auditor completed with 0 findings' in (path.parent/'audit.log').read_text(),'Audit findings')
fp=ROOT/ledger['faultAudit'];require(sha(fp)==ledger['faultAuditSha256'],'Fault audit drift')
f=check_manifest(fp);require(f['inputsUnchanged'] and f['proof']['exitCode']==4,'Focused fault failed')
log=(fp.parent/'proof.log').read_text()
require('postcondition could not be proved' in log and not re.search(r'time.?out|inconclusive|resolution/type errors|parse errors',log,re.I),'Focused failure is not semantic')
fr=list(csv.DictReader((fp.parent/'proof.csv').open()))
require(any(r['TestResult.Outcome']!='Passed' and r['TestResult.DisplayName'].startswith('CollectionsPreparationSource.PrepareCallback') for r in fr),'Missing focused native failure')
op=ROOT/f['originalCampaign'];require(sha(op)==f['originalCampaignSha256'],'Original campaign drift')
o=json.loads(op.read_text())
for src,digest in o['sourceSha256'].items():require(sha(ROOT/src)==digest,'Original source drift '+src)
for artifact,digest in o['evidenceSha256'].items():require(sha(op.parent/artifact)==digest,'Original artifact drift '+artifact)
require(o['inputsUnchanged'] and len(o['faults'])==3,'Incomplete fault inventory')
for fault in o['faults']:
 require(fault['sourceGate']['exitCode']==0 and fault['concrete']['killed'],'Missing gated EVM fault')
 root=op.parent/fault['name'];elog=(root/'concrete.log').read_text()
 require(fault['expectedTest'] in re.findall(r'^\[FAIL:.*\] (test\w+)\(',elog,re.M),'Missing designated EVM failure')
 if fault['name']!='binary-skip':
  require(fault['proof']['killed'] and fault['proof']['exitCode']==4,'Missing semantic fault')
  plog=(root/'proof.log').read_text()
  require(re.search(r'postcondition could not be proved|invariant could not be proved|assertion might not hold',plog) and not re.search(r'time.?out|inconclusive|resolution/type errors|parse errors',plog,re.I),'Invalid semantic fault')
print('PASS: preparation/binding baseline, 225 native obligations, 7 EVM fixtures, 3 source faults including focused postcondition evidence, source/dependency/artifact hashes and claim mappings')
