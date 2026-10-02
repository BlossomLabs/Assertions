#!/usr/bin/env python3
"""Validate exact physical unknown-selector rejection with immutable native reuse."""
import csv,hashlib,importlib.util,json,re,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,message):
 if not ok:raise SystemExit(message)
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
ledger=json.loads((ROOT/'docs/verification/unknown-selector-bytecode.json').read_text());path=ROOT/ledger['baseline'];out=path.parent;require(sha(path)==ledger['baselineSha256'],'Manifest drift');m=json.loads(path.read_text());v=load('unknown_verify',ROOT/'formal/bytecode/unknown/verify.py')
require(m['status']=='passed' and all(m[k] for k in ['inputsUnchanged','dependenciesUnchanged','toolsUnchanged','concreteToolsUnchanged','regenerationPassed']) and all(j['passed'] for j in m['checks']),'Incomplete retained baseline')
require(m['publicEntries']==[] and m['assumptions']==ledger['assumptions'],'Scope drift')
require({str(p.relative_to(ROOT)):sha(p) for p in v.inputs()}==m['sourceSha256'],'Current source/input inventory drift')
for name,digest in m['sourceSha256'].items():require(sha(out/'source-snapshot'/name)==digest,'Snapshot drift '+name)
for name,digest in m['evidenceSha256'].items():require(sha(out/name)==digest,'Evidence drift '+name)
require(v.dependency_hashes()==m['dependencyEvidenceSha256'],'Dependency evidence drift')
graph=v.graph();require({str(p.relative_to(ROOT)):sha(p) for p in graph}==m['dependencyGraph'] and m['rootProof']==str(v.PROOF.relative_to(ROOT)),'Include graph drift')
reused={j['file']:j for j in m['reusedProofs']};require(len(reused)==5,'Wrong immutable proof reuse inventory')
rows=[];declarations=[];allproved=set();covered=set()
for file in graph:
 rel=str(file.relative_to(ROOT));covered.add(rel)
 if rel in reused:
  reuse=reused[rel];dep_path=ROOT/reuse['manifest'];require(sha(dep_path)==reuse['manifestSha256'],'Reused manifest drift');dep=json.loads(dep_path.read_text());job=next(j for j in dep['checks'] if j['name']==reuse['proofName']);require(dep['status']=='passed' and job['passed'] and sha(file)==dep['sourceSha256'][rel],'Reused proof source/status drift')
  require(reuse['nativeResults']==job['nativeResults'] and reuse['declarations']==job['declarations'] and v.getter.inventory(file)==[{k:d[k] for k in ['name','kind','file']} for d in job['declarations']],'Reused native inventory drift')
  allproved|={d['name'] for d in reuse['declarations'] if d['status']=='passed'}
 else:
  mod=re.search(r'^module (\w+)',file.read_text(),re.M)[1];name='proof-'+mod;job=next(j for j in m['checks'] if j['name']==name)
  require(all(flag in job['command'] for flag in ['--verify-included-files','--manual-lemma-induction','--isolate-assertions']) and '--filter-position' not in job['command'] and job['command'][job['command'].index('--filter-symbol')+1]==mod,'Incomplete native coverage')
  fresh=dict(job);v.common.check_proof(fresh,out/(name+'.log'),out/(name+'.csv'),v.getter.inventory(file));require(fresh['passed'] and fresh['nativeResults']==job['nativeResults'] and fresh['declarations']==job['declarations'],'Fresh native inventory drift')
  rows+=job['nativeResults'];declarations+=job['declarations'];allproved|={d['name'] for d in job['declarations'] if d['status']=='passed'}
require(covered==set(m['dependencyGraph']) and set(reused)<=covered,'Uncovered include graph')
require(rows==m['nativeResults'] and declarations==m['declarationResults'] and len(rows)==m['nativeObligations']==ledger['nativeObligations'] and len(declarations)==ledger['nativeDeclarations'],'Fresh aggregate drift')
require(sum(len(j['nativeResults']) for j in reused.values())==m['reusedNativeObligations']==ledger['reusedNativeObligations'] and m['includeClosureNativeObligations']==len(rows)+m['reusedNativeObligations'],'Reused aggregate drift')
require(all(n in allproved for n in ledger['connections']),'Unproved physical connection')
require('auditor completed with 0 findings' in (out/'audit.log').read_text(),'Audit findings')
receipts=json.loads((out/'evm-traces/results.json').read_text());require(len(receipts)==ledger['concreteFixtures']==15 and {(r['contract'],r['index']) for r in receipts}=={(c,i) for c in ['Assertions','Expressions','Collections'] for i in range(5)},'Concrete fixture inventory drift')
for r in receipts:
 t=json.loads((out/'evm-traces'/r['trace']).read_text());trace=t['trace'];logs=trace['structLogs'];last=logs[-1];mem=''.join(w.removeprefix('0x') for w in last['memory']);stores=[s for s in logs if s['op']=='MSTORE']
 require(r['passed'] and r['receiptPassed'] and not t['candidate'] and trace['failed'] and trace['returnValue'].removeprefix('0x')=='' and logs[0]['pc']==0 and all(s['depth']==1 for s in logs),'False full rejection receipt')
 require(max(len(s['stack']) for s in logs)<=3 and mem=='00'*64+'00'*31+'80' and last['op']=='REVERT' and int(last['stack'][-1],16)==int(last['stack'][-2],16)==0 and len(stores)==1 and int(stores[0]['stack'][-1],16)==64 and int(stores[0]['stack'][-2],16)==128,'Physical stack/memory/revert drift')
faults=json.loads((out/'mutations/results.json').read_text());require(len(faults)==ledger['semanticBytecodeFaults']==3 and {f['candidate']['contract'] for f in faults}=={'Assertions','Expressions','Collections'},'Fault inventory drift')
for f in faults:
 c=f['candidate'];base=bytes.fromhex(json.loads((ROOT/f"artifacts/contracts/{c['contract']}.sol/{c['contract']}.json").read_text())['deployedBytecode'][2:]);candidate=(out/'candidates'/c['runtime']).read_bytes()
 require(hashlib.sha256(base).hexdigest()==c['baselineRuntimeSha256'] and hashlib.sha256(candidate).hexdigest()==c['runtimeSha256'] and len(candidate)==len(base) and [(i,a,b) for i,(a,b) in enumerate(zip(base,candidate)) if a!=b]==[(c['byteOffset'],253,243)],'Wrong binary semantic fault')
 require(f['baselineCoveredSymbol']==c['nativeSymbol'] and c['nativeSymbol'] in allproved and all(j['passed'] for j in f['checks']),'Fault closure drift')
 native=f['checks'][1];text=(out/native['log']).read_text();native_rows=list(csv.DictReader((out/'mutations'/c['name']/'proof.csv').open()));require(native['exitCode'] not in [0,None] and any(r['TestResult.Outcome']=='Failed' for r in native_rows) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in native_rows) and 'postcondition could not be proved' in text and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',text,re.I),'Non-semantic fault result')
 require(native['command'][native['command'].index('--filter-symbol')+1]==c['nativeSymbol'] and native['command'][native['command'].index('--filter-position')+1].endswith(':'+str(f['semanticAssertion']['line'])),'Wrong semantic obligation filter')
 require(len(f['contradictoryReceipts'])==1,'Missing EVM counterexample');r=f['contradictoryReceipts'][0];t=json.loads((out/'mutations'/c['name']/'evm-traces'/r['trace']).read_text());require(r['contract']==c['contract'] and r['index']==0 and not r['receiptPassed'] and t['candidate'] and t['runtimeSha256']==c['runtimeSha256'] and not t['trace']['failed'] and t['trace']['returnValue'].removeprefix('0x')=='' and t['trace']['structLogs'][-1]['op']=='RETURN','False concrete semantic counterexample')
dafny=Path(next(j for j in m['checks'] if j['name'].startswith('proof-'))['command'][0]);solc=Path(next(j for j in m['checks'] if j['name']=='runtime-identity')['command'][4])
for key,p in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',dafny.parent/'z3/bin/z3-4.12.1'),('solc',solc)]:require(sha(p)==m['executableSha256'][key],'Proof tool drift')
ct=m['concreteToolchain']
for key in ['hardhatEntry','edrEntry','nativeBinding']:require(sha(Path(ct[key]))==ct[key+'Sha256'],'Concrete tool drift')
require(sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'],'Node/lockfile drift')
with tempfile.TemporaryDirectory(prefix='unknown-bytecode-check-') as folder:
 dest=Path(folder);gen=dest/'generated';gen.mkdir()
 for script in ['generate.py','generate-terminal.py']:subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/unknown'/script,'--output',gen],check=True,stdout=subprocess.DEVNULL)
 expected={p.name for p in (ROOT/'formal/bytecode/unknown').iterdir() if p.name.endswith(('.generated.dfy','.mapping.json'))};require(expected=={p.name for p in gen.iterdir()} and all((gen/n).read_bytes()==(ROOT/'formal/bytecode/unknown'/n).read_bytes() for n in expected),'Current regeneration drift')
 subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/unknown/make-candidates.py','--output',dest/'candidates'],check=True,stdout=subprocess.DEVNULL);require((dest/'candidates/candidates.json').read_bytes()==(out/'candidates/candidates.json').read_bytes(),'Current candidate drift')
 for f in faults:require((dest/'candidates'/f['candidate']['runtime']).read_bytes()==(out/'candidates'/f['candidate']['runtime']).read_bytes(),'Current fault bytes drift')
 subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/dispatch/identity.py','--solc',solc,'--output',dest/'identity'],check=True,stdout=subprocess.DEVNULL);require((dest/'identity/identity.json').read_bytes()==(out/'identity/identity.json').read_bytes(),'Current exact identity drift')
 subprocess.run([ct['nodeExecutable'],ROOT/'formal/bytecode/unknown/evm-traces.mjs','--root',ROOT,'--output',dest/'evm'],check=True,stdout=subprocess.DEVNULL);require((dest/'evm/results.json').read_bytes()==(out/'evm-traces/results.json').read_bytes(),'Current physical receipts drift')
for script in ['check-runtime-dispatch-bytecode-evidence.py','check-raw-rejections-bytecode-evidence.py']:subprocess.run([sys.executable,'-B',ROOT/'scripts'/script],check=True,stdout=subprocess.DEVNULL)
print(f"PASS: all three exact physical unknown-selector rejections; {len(rows)} fresh and {m['reusedNativeObligations']} immutable reused obligations, zero audit, 15 complete EVM receipts and three semantic bytecode faults; public body coverage unchanged")
