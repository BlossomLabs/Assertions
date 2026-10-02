#!/usr/bin/env python3
"""Validate physical nonpayable/short raw rejection evidence and model closure."""
import csv,hashlib,importlib.util,json,re,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,message):
 if not ok:raise SystemExit(message)
def module(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
ledger=json.loads((ROOT/'docs/verification/raw-rejections-bytecode.json').read_text());path=ROOT/ledger['baseline'];require(sha(path)==ledger['baselineSha256'],'Manifest drift');m=json.loads(path.read_text());out=path.parent
require(m['status']=='passed' and all(m[k] for k in ['inputsUnchanged','toolsUnchanged','concreteToolsUnchanged']) and all(j['passed'] for j in m['checks']),'Incomplete retained rejection evidence')
for name,digest in m['sourceSha256'].items():require(sha(ROOT/name)==digest,'Current input drift '+name)
for name,digest in m['evidenceSha256'].items():require(sha(out/name)==digest,'Evidence drift '+name)
require(m['dependency']==ledger['dependency'] and sha(ROOT/m['dependency']['manifest'])==sha(out/m['dependency']['retainedManifest'])==m['dependency']['sha256'],'Dependency manifest drift')
require(sha(ROOT/'formal/bytecode/getters/Machine.dfy')==m['dependency']['modelSha256'],'Unproved/different shared model')
subprocess.run([sys.executable,'-B',ROOT/'scripts/check-constant-getters-bytecode-evidence.py'],check=True)
verify=module('rejection_verify',ROOT/'formal/bytecode/rejections/verify.py');rows=[];decls=[]
for name in verify.NAMES:
 job=next(j for j in m['checks'] if j['name']=='proof-'+name);require(all(f in job['command'] for f in ['--verify-included-files','--manual-lemma-induction','--isolate-assertions']) and '--filter-position' not in job['command'] and job['command'][job['command'].index('--filter-symbol')+1]=='BytecodeReject'+name,'Incomplete native scope')
 fresh=dict(job);verify.common.check_proof(fresh,out/('proof-'+name+'.log'),out/('proof-'+name+'.csv'),verify.getter.inventory(ROOT/'formal/bytecode/rejections'/(name+'.generated.dfy')));require(fresh['passed'] and fresh['nativeResults']==job['nativeResults'] and fresh['declarations']==job['declarations'],'Native declaration/CSV drift')
 require('auditor completed with 0 findings' in (out/('audit-'+name+'.log')).read_text(),'Audit findings');rows+=job['nativeResults'];decls+=job['declarations']
require(rows==m['nativeResults'] and len(rows)==ledger['nativeObligations']==2442 and decls==m['declarationResults'],'Aggregate native inventory drift');proved={d['name'] for d in decls if d['status']=='passed'};require(all(n in proved for n in ledger['connectionTheorems']),'Unproved rejection connection')
results=json.loads((out/'evm-traces/results.json').read_text());require(len(results)==ledger['concreteFixtures']==21 and {(r['contract'],r['index']) for r in results}=={(c,i) for c in ['Assertions','Expressions','Collections'] for i in range(7)},'Fixture inventory drift')
for r in results:
 t=json.loads((out/'evm-traces'/r['trace']).read_text());mapping=json.loads((ROOT/'formal/bytecode/rejections'/(r['contract']+r['kind']+'.mapping.json')).read_text());code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts'/f"{r['contract']}.sol"/f"{r['contract']}.json").read_text())['deployedBytecode'][2:]);require(hashlib.sha256(code).hexdigest()==mapping['runtimeSha256']==t['runtimeSha256'],'Trace/certificate runtime drift')
 value=int(t['case']['value'],16);size=len(t['case']['data'].removeprefix('0x'))//2;require((value!=0 if r['kind']=='Nonzero' else value==0 and size<4),'Wrong raw environment class')
 logs=t['trace']['structLogs'];require(t['trace']['failed'] and t['trace']['returnValue'] in ['','0x'] and logs[-1]['op']=='REVERT' and [r['pc'] for r in logs]==[s['pc'] for s in mapping['states']] and all(r['depth']==1 for r in logs),'Wrong complete empty rejection')
 ret=logs[-1];mem=''.join(w.removeprefix('0x') for w in ret['memory']);require(len(mem)==192 and int(mem[128:192],16)==128 and int(ret['stack'][-1],16)==int(ret['stack'][-2],16)==0 and max(len(r['stack']) for r in logs)==mapping['maximumStackWords']==3,'Physical rejection frame drift')
 stores=[r for r in logs if r['op']=='MSTORE'];require(len(stores)==1 and int(stores[0]['stack'][-1],16)==64 and int(stores[0]['stack'][-2],16)==128,'Initial physical store drift')
faults=json.loads((out/'mutations/results.json').read_text());require({f['name'] for f in faults}==set(verify.NAMES) and len(faults)==ledger['semanticBytecodeFaults']==6,'Fault inventory drift')
for f in faults:
 require(f['baselineCoveredSymbol'] in proved and all(j['passed'] for j in f['checks']),'Fault baseline closure drift');name=f['name'];mapping=json.loads((ROOT/'formal/bytecode/rejections'/(name+'.mapping.json')).read_text());c=mapping['contract'];base=bytes.fromhex(json.loads((ROOT/'artifacts/contracts'/f'{c}.sol'/f'{c}.json').read_text())['deployedBytecode'][2:]);candidate=out/'candidates'/(name+'.bin');mut=candidate.read_bytes()
 require(sha(candidate)==f['candidateSha256'] and len(mut)==len(base) and [(i,a,b) for i,(a,b) in enumerate(zip(base,mut)) if a!=b]==[(mapping['states'][-1]['pc'],0xfd,0xf3)],'Wrong binary fault')
 native=f['checks'][1];text=(out/native['log']).read_text();rs=list(csv.DictReader((out/'mutations'/name/'proof.csv').open()));require(native['exitCode'] not in [0,None] and rs and any(r['TestResult.Outcome']=='Failed' for r in rs) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in rs) and 'postcondition could not be proved' in text and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error',text,re.I),'Non-semantic native fault outcome')
 require(f['concreteFailures'],'Missing real successful receipt counterexample')
 for failure in f['concreteFailures']:
  t=json.loads((out/failure['trace']).read_text());require(not t['trace']['failed'] and t['trace']['structLogs'][-1]['op']=='RETURN' and t['trace']['returnValue']==failure['returnValue'] and failure['actualSuccess'],'False concrete counterexample')
dafny=Path(next(j for j in m['checks'] if j['name'].startswith('proof-'))['command'][0]);cmd=next(j for j in m['checks'] if j['name']=='runtime-identity')['command'];solc=Path(cmd[cmd.index('--solc')+1])
for key,p in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',dafny.parent/'z3/bin/z3-4.12.1'),('solc',solc)]:require(sha(p)==m['executableSha256'][key],'Proof tool drift')
ct=m['concreteToolchain']
for key in ['hardhatEntry','edrEntry','nativeBinding']:require(sha(Path(ct[key]))==ct[key+'Sha256'],'Concrete tool drift')
require(sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'],'Node/lock drift')
with tempfile.TemporaryDirectory(prefix='raw-rejection-bytecode-check-') as folder:
 dest=Path(folder);subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/rejections/generate.py','--output',dest/'generated'],check=True)
 for name in verify.NAMES:
  for suffix in ['.generated.dfy','.mapping.json']:require((dest/'generated'/(name+suffix)).read_bytes()==(ROOT/'formal/bytecode/rejections'/(name+suffix)).read_bytes(),'Current generation drift')
 subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/dispatch/identity.py','--solc',solc,'--output',dest/'identity'],check=True);require((dest/'identity/identity.json').read_bytes()==(out/'identity/identity.json').read_bytes(),'Current runtime identity differs')
print('PASS: physical nonzero-value/short-frame rejection in all three runtimes, 2442 obligations, zero audits, 21 EVM receipts and six semantic bytecode faults; accepted bodies remain open')
