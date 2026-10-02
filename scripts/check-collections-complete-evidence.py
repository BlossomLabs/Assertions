#!/usr/bin/env python3
"""Check complete Collections source coverage, native selectors and current closure."""
import csv,hashlib,importlib.util,json,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,message):
    if not ok:raise SystemExit(message)
ledger=json.loads((ROOT/'docs/verification/collections-complete-source-connection.json').read_text());path=ROOT/ledger['baseline']
require(sha(path)==ledger['baselineSha256'],'Completion manifest drift');m=json.loads(path.read_text())
require(m['status']=='passed' and m['inputsUnchanged'] and all(c['passed'] for c in m['checks']),'Completion checks failed')
for name,digest in m['sourceSha256'].items():require(sha(ROOT/name)==digest,'Source drift '+name)
for name,digest in m['evidenceSha256'].items():require(sha(path.parent/name)==digest,'Artifact drift '+name)
proof=next(c for c in m['checks'] if c['name']=='proof');rows=list(csv.DictReader((path.parent/'proof.csv').open()))
require(rows==proof['nativeResults'] and len(rows)==ledger['nativeObligations']==126 and all(r['TestResult.Outcome']=='Passed' for r in rows),'Native selector proof failed')
declarations={d['name']:d for d in proof['declarations']}
for d in declarations.values():
    if d['kind'] in {'method','lemma'}:require(d['status']=='passed' and any(r['TestResult.DisplayName'].split(' (')[0]==d['name'] for r in rows),'Missing native declaration '+d['name'])
for name in ledger['boundaryTheorems']:require(name in declarations and declarations[name]['status']=='passed','Unproved boundary theorem '+name)
require('--isolate-assertions' in proof['command'] and '--filter-position' not in proof['command'],'Incomplete native assertion coverage')
require('auditor completed with 0 findings' in (path.parent/'audit.log').read_text(),'Audit findings')
require((path.parent/'generated/Boundary.generated.dfy').read_bytes()==(ROOT/'formal/collections/completion/Boundary.generated.dfy').read_bytes(),'Generated source drift')
deps=next(c for c in m['checks'] if c['name']=='dependency-closure')['dependencies'];require(len(deps)==ledger['dependencyManifests']==70,'Dependency inventory drift')
for d in deps:
    require(sha(ROOT/d['manifest'])==d['sha256'] and sha(path.parent/d['retainedManifest'])==d['sha256'],'Dependency manifest drift')
coverage=next(c for c in m['checks'] if c['name']=='coverage');command=coverage['command']
dafny=Path(command[command.index('--dafny')+1]);solc=Path(command[command.index('--solc')+1])
for key,p in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',dafny.parent/'z3/bin/z3-4.12.1'),('solc',solc)]:require(sha(p)==m['executableSha256'][key],'Tool drift '+key)
with tempfile.TemporaryDirectory(prefix='collections-complete-audit-') as folder:
    fresh=Path(folder)/'coverage.json'
    subprocess.run([sys.executable,'-B',ROOT/'formal/collections/completion/audit.py','--dafny',dafny,'--solc',solc,'--output',fresh],check=True)
    require(fresh.read_bytes()==(path.parent/'coverage.json').read_bytes()==(path.parent/'coverage-after.json').read_bytes(),'Current coverage differs from retained evidence')
    c=json.loads(fresh.read_text());require(c['functionDefinitions']==ledger['functionDefinitions']==51 and c['publicEntryCount']==ledger['publicEntries']==29,'Incomplete source coverage')
    require(ledger['completedPublicEntries']==sorted(v['name'] for v in c['publicAbi'].values()),'Public coverage drift')
    require(len(c['bodyRequirements'])==ledger['requirements']==21,'Requirement drift')
    require(c['nativeObligationsInUniqueDependencies']==ledger['nativeObligationsInUniqueDependencies'],'Dependency native count drift')
print('PASS: complete conditional Collections source coverage, 51 bodies, 29 public entries, 126 ABI selector obligations, 70 current retained dependency manifests; exact bytecode remains separate')
