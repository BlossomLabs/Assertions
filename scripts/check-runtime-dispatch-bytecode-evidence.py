#!/usr/bin/env python3
"""Check exact current runtime routing evidence without inferring body correctness."""
import csv,hashlib,importlib.util,json,re,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,message):
 if not ok:raise SystemExit(message)
def module(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
ledger=json.loads((ROOT/'docs/verification/runtime-dispatch-bytecode.json').read_text());path=ROOT/ledger['baseline'];require(sha(path)==ledger['baselineSha256'],'Manifest drift');m=json.loads(path.read_text());out=path.parent
require(m['status']=='passed' and all(m[k] for k in ['inputsUnchanged','toolsUnchanged','concreteToolsUnchanged']) and all(j['passed'] for j in m['checks']),'Incomplete retained dispatcher baseline')
for name,digest in m['sourceSha256'].items():require(sha(ROOT/name)==digest,'Current input drift '+name)
for name,digest in m['evidenceSha256'].items():require(sha(out/name)==digest,'Evidence drift '+name)
verify=module('dispatch_verify',ROOT/'formal/bytecode/dispatch/verify.py');rows=[];decls=[]
for name in ['Machine','Assertions','Expressions','Collections']:
 file='Machine.dfy' if name=='Machine' else name+'.generated.dfy';job=next(j for j in m['checks'] if j['name']=='proof-'+name);prefix='BytecodeDispatch'+name
 require(all(flag in job['command'] for flag in ['--verify-included-files','--manual-lemma-induction','--isolate-assertions']) and '--filter-position' not in job['command'] and job['command'][job['command'].index('--filter-symbol')+1]==prefix,'Incomplete native scope '+name)
 fresh=dict(job);verify.common.check_proof(fresh,out/('proof-'+name+'.log'),out/('proof-'+name+'.csv'),verify.inventory([ROOT/'formal/bytecode/dispatch'/file]));require(fresh['passed'] and fresh['nativeResults']==job['nativeResults'] and fresh['declarations']==job['declarations'],'Native declaration/CSV drift '+name)
 require('auditor completed with 0 findings' in (out/('audit-'+name+'.log')).read_text(),'Audit findings '+name);rows+=job['nativeResults'];decls+=job['declarations']
require(rows==m['nativeResults'] and len(rows)==ledger['nativeObligations']==17579 and decls==m['declarationResults'],'Aggregate native inventory drift');proved={d['name'] for d in decls if d['status']=='passed'}
require(all(n in proved for n in ledger['connectionTheorems']),'Unproved routing composition')
inv=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text());traces=json.loads((out/'evm-traces/results.json').read_text())
expected={(n,k+s) for n in ledger['selectorCounts'] for k in inv[n]['methodIdentifiers'] for s in ['','-tail','-nonzero-value']}|{(n,'short-'+str(i)) for n in ledger['selectorCounts'] for i in range(4)}|{(n,'unknown-'+s) for n in ledger['selectorCounts'] for s in ['00000000','ffffffff','12345678']}
require(len(traces)==ledger['concreteFixtures']==168 and {(t['contract'],t['name']) for t in traces}==expected,'Fixture inventory drift')
for contract,count in ledger['selectorCounts'].items():
 require(len(inv[contract]['methodIdentifiers'])==len(inv[contract]['selectorToDeclaredEntryPc'])==count,'Selector coverage drift')
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts'/f'{contract}.sol'/f'{contract}.json').read_text())['deployedBytecode'][2:]);require(hashlib.sha256(code).hexdigest()==inv[contract]['runtimeSha256'],'Exact runtime drift')
 mapping=json.loads((ROOT/'formal/bytecode/dispatch'/(contract+'.mapping.json')).read_text());require(mapping['ABI']==inv[contract]['methodIdentifiers'] and mapping['selectorToWrapper']==inv[contract]['selectorToDeclaredEntryPc'] and mapping['actualEqualityTargets']==mapping['selectorToWrapper'] and not mapping['candidateRuntime'],'Declared entry table drift')
 for result in [t for t in traces if t['contract']==contract]:
  t=json.loads((out/'evm-traces'/result['trace']).read_text());case=t['case'];p=t['prefix'];require(t['runtimeSha256']==inv[contract]['runtimeSha256'] and not t['candidate'],'Trace runtime drift')
  size=len(case['data'].removeprefix('0x'))//2;value=int(case['value'],16);selector=int(case['data'][2:10],16) if size>=4 else -1;target=-1 if value!=0 or size<4 else inv[contract]['selectorToDeclaredEntryPc'].get(str(selector),-1)
  require(target==case['expected']==result['expected']==result['reached'],'Wrong frozen routing oracle')
  store=next((r for r in p if r['pc']==4 and r['op']=='MSTORE'),None);require(store and int(store['stack'][-1],16)==64 and int(store['stack'][-2],16)==128,'Initial MSTORE trace drift')
  if target>=0:require(p[-1]['pc']==target and len(p[-1]['stack'])==1 and int(p[-1]['stack'][0],16)==selector,'Wrong entry/selector stack')
  else:require(t['failedAfterDispatch'] and t['returnValueAfterDispatch'] in ['','0x'] and p[-1]['op']=='REVERT','Wrong exact empty rejection')
faults=json.loads((out/'mutations/results.json').read_text());require({f['name'] for f in faults}=={'getter-entry-redirect','short-frame-admission-bypass'} and len(faults)==ledger['semanticBytecodeFaults']==2,'Fault inventory drift')
for f in faults:
 require(f['baselineCoveredSymbol'] in proved and all(j['passed'] for j in f['checks']),'Fault baseline closure drift');candidate=out/'candidates'/(f['name']+'.bin');require(sha(candidate)==f['candidateSha256'],'Candidate drift')
 native=f['checks'][1];text=(out/native['log']).read_text();rs=list(csv.DictReader((out/'mutations'/f['name']/'proof.csv').open()));require(native['exitCode'] not in [0,None] and rs and any(r['TestResult.Outcome']=='Failed' for r in rs) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in rs) and 'postcondition could not be proved' in text and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error',text,re.I),'Non-semantic native fault result')
 require(f['concreteFailures'],'Missing real wrong-entry trace')
 for failure in f['concreteFailures']:
  t=json.loads((out/failure['trace']).read_text());entries=set(inv['Assertions']['selectorToDeclaredEntryPc'].values());actual=next((r['pc'] for r in t['prefix'] if r['pc'] in entries),-1);require(actual==failure['actual']!=failure['expected']==t['case']['expected'],'False wrong-entry counterexample')
dafny=Path(next(j for j in m['checks'] if j['name']=='proof-Machine')['command'][0]);cmd=next(j for j in m['checks'] if j['name']=='runtime-identity')['command'];solc=Path(cmd[cmd.index('--solc')+1])
for key,p in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',dafny.parent/'z3/bin/z3-4.12.1'),('solc',solc)]:require(sha(p)==m['executableSha256'][key],'Proof tool drift '+key)
ct=m['concreteToolchain']
for key in ['hardhatEntry','edrEntry','nativeBinding']:require(sha(Path(ct[key]))==ct[key+'Sha256'],'Concrete tool drift '+key)
require(sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'],'Node/lock drift')
with tempfile.TemporaryDirectory(prefix='dispatcher-bytecode-check-') as folder:
 dest=Path(folder)
 for name in ledger['selectorCounts']:
  subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/dispatch/generate.py','--solc',solc,'--contract',name,'--output',dest/'generated'],check=True)
  for suffix in ['.generated.dfy','.mapping.json']:require((dest/'generated'/(name+suffix)).read_bytes()==(ROOT/'formal/bytecode/dispatch'/(name+suffix)).read_bytes(),'Current generation drift')
 subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/dispatch/identity.py','--solc',solc,'--output',dest/'identity'],check=True);require((dest/'identity/identity.json').read_bytes()==(out/'identity/identity.json').read_bytes(),'Current runtime identity differs')
print('PASS: all 49 exact-runtime declared entry routes, 17579 native obligations, zero audits, 168 EVM prefix traces and two semantic bytecode faults; decoding and bodies remain separate')
