#!/usr/bin/env python3
"""Independent current-input/native/generated/physical/mutation closure check for byteAt(bytes,int256)."""
import csv,hashlib,importlib.util,json,re,subprocess,sys,tempfile,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];OWNER=Path(__file__).resolve().parent

def read(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,message):
 if not ok:raise SystemExit(message)
def load(name,p):
 spec=importlib.util.spec_from_file_location(name,p);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m

def main():
 ledger=read(ROOT/'docs/verification/operations-byte-at-bytecode.json');out=(ROOT/ledger['baseline']).parent;m=read(out/'manifest.json');v=load('byte_at_retainer',OWNER/'byte-at-retention/verify.py')
 require(sha(out/'manifest.json')==ledger['baselineSha256'] and m['status']=='passed' and all(m[k] for k in ['inputsUnchanged','toolsUnchanged','concreteToolsUnchanged']) and all(j['passed'] for j in m['checks']),'Incomplete retained evidence')
 require(m.get('wholeModuleWatchdogSeconds')==7200 and m.get('ordinaryObligationLimitSeconds')==30,'Native watchdog/per-obligation policy drift')
 require(m['publicEntries']==ledger['publicEntries']==['Operations.byteAt(bytes,int256)'] and m['assumptions']==ledger['assumptions'],'Public scope drift')
 require({str(p.relative_to(ROOT)):sha(p) for p in v.inputs()}==m['sourceSha256'],'Current input inventory drift')
 for name,digest in m['sourceSha256'].items():require(sha(out/'source-snapshot'/name)==digest,'Source snapshot drift '+name)
 require({str(p.relative_to(out)):sha(p) for p in out.rglob('*') if p.is_file() and p.name!='manifest.json'}==m['evidenceSha256'],'Whole evidence closure drift')
 require(m['proofFiles']==[str(p.relative_to(ROOT)) for p in v.PROOFS] and len(v.PROOFS)==63,'Incomplete native graph');closed=set()
 def visit(p):
  p=p.resolve();require(p in v.PROOFS,'Uninventoried native include')
  if p in closed:return
  closed.add(p)
  for name in re.findall(r'^include "([^"]+)"',p.read_text(),re.M):visit(p.parent/name)
 for p in v.PROOFS:visit(p)
 require(closed==set(v.PROOFS),'Incomplete native include closure')
 jobs={j['name']:j for j in m['checks']};rows=[];declarations=[]
 for p in v.PROOFS:
  module=re.search(r'^module (\w+)',p.read_text(),re.M)[1];j=jobs['proof-'+module];file=out/'source-snapshot'/p.relative_to(ROOT);csvpath=out/(module+'.csv');dafny=Path(j['command'][0])
  expected=[str(x) for x in v.common.proof_command(dafny,file,csvpath)]+['--filter-symbol',module,'--filter-position',str(file),'--progress','Symbol']
  require(j['command']==expected and j['exitCode']==0 and expected[expected.index('--verification-time-limit')+1]=='30','Partial native command/source/limit drift')
  fresh=dict(j);v.common.check_proof(fresh,out/('proof-'+module+'.log'),csvpath,v.inventory(p));require(fresh['passed'] and fresh['nativeResults']==j['nativeResults'] and fresh['declarations']==j['declarations'],'Native declaration/CSV drift');rows+=fresh['nativeResults'];declarations+=fresh['declarations']
  audit=jobs['audit-'+module];require(audit['exitCode']==0 and audit['command']==[str(dafny),'audit',str(file)] and 'auditor completed with 0 findings' in (out/('audit-'+module+'.log')).read_text(),'Incomplete audit')
 require(rows==m['nativeResults'] and declarations==m['declarationResults'] and len(rows)==ledger['nativeObligations'] and len(declarations)==ledger['nativeDeclarations'],'Native aggregate drift');proved={d['name'] for d in declarations if d['status']=='passed'}
 require(ledger['connections']==['OperationsByteAtFullConnection.Run'] and all(n in proved for n in ledger['connections']),'Missing complete raw connection')
 code=bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();require(digest==ledger['runtimeSha256']==read(out/'identity/identity.json')[0]['runtimeSha256'],'Runtime drift')
 prefix=read(OWNER/'byte-at-success-prefix/Prefix.mapping.json');body=read(OWNER/'byte-at-serialization/serialization.mapping.json')
 require(len(prefix['states'])==171 and prefix['states'][-1]['pc']==7143 and len(body['states'])==195 and body['states'][-1]['opcode']==0xf3,'Complete successful instruction inventory drift')
 fixtures=read(out/'evm-traces/results.json');require(len(fixtures)==80 and all(r['passed'] for r in fixtures) and {r['ordinal'] for r in fixtures}==set(range(80)),'Physical inventory drift')
 require(sum(r['reason']=='Success' for r in fixtures)==ledger['concreteSuccessReceipts']==28 and ledger['concreteCustomErrorReceipts']==36 and ledger['concreteRejectionReceipts']==16,'Complementary physical partition drift')
 for r in fixtures:
  t=read(out/'evm-traces'/r['trace']);require(not t['candidate'] and t['runtimeSha256']==digest,'Physical runtime drift')
  if r['reason'] in {'Success','InvalidByteIndex'}:
   data=bytes.fromhex(t['data'][2:]);load=lambda a:int.from_bytes(data[a:a+32].ljust(32,b'\0'),'big');offset,index,length=load(4),load(36),load(4+load(4));signed=index if index<(1<<255) else index-(1<<256)
   kind=('InvalidHigh' if signed>=length else 'InvalidLow') if r['reason']=='InvalidByteIndex' else ('Positive' if signed>=0 else 'Negative')
   path=read(OWNER/'byte-at-index-controls'/(kind+'.mapping.json'))
   require(path['runtimeSha256']==digest,'Index path runtime drift')
   expected=[x['pc'] for x in prefix['states'][:-1]]+[x['pc'] for x in path['states'] if not x.get('frontier')]
   if r['reason']=='Success':expected += [x['pc'] for x in body['states']]
   require([x['pc'] for x in t['trace']['structLogs']]==expected,'Wrong complete actual successful/custom-error instruction path')
 faults=read(out/'mutations/results.json');require(len(faults)==ledger['semanticBytecodeFaults']==1,'Semantic fault inventory drift');f=faults[0]
 require(f['pc']==18907 and f['oldOpcode']==0x5e and f['newOpcode']==0x37 and f['witnessOrdinal']==6 and f['source']==100 and f['originalByte']==165 and f['changedByte']==0 and f['baselineSemanticSymbol']=='OperationsByteAtSerialization.SemanticWitness' and f['baselineSemanticSymbol'] in proved and all(j['passed'] for j in f['checks']),'Wrong matching baseline-covered semantic fault')
 candidate=out/'candidates'/(f['name']+'.bin');bits=candidate.read_bytes();require(sha(candidate)==f['sha256'] and len(bits)==len(code) and [(i,a,b) for i,(a,b) in enumerate(zip(code,bits)) if a!=b]==[(18907,0x5e,0x37)],'Wrong one-byte runtime mutation')
 folder=out/'mutations'/f['name'];file=out/f['semanticAssertion']['file'];lines=file.read_text().splitlines();line=f['semanticAssertion'];require(lines[line['line']-1]==line['text'] and line['text'].strip()=='ensures state.memory[256]==165' and 'requires Source(data)==100 && data[Source(data)]==165 && I.Cell(data,160)==0' in '\n'.join(lines),'Semantic postcondition/witness drift')
 native=f['checks'][2];expected=[str(x) for x in v.common.proof_command(dafny,file,folder/'proof.csv')]+['--filter-symbol',f['baselineSemanticSymbol'],'--filter-position',str(file)+':'+str(line['line']),'--progress','Symbol'];require(native['command']==expected and native['exitCode'] not in [0,None],'Semantic native source/command drift')
 nr=list(csv.DictReader((folder/'proof.csv').open()));log=(out/native['log']).read_text();require(any(r['TestResult.Outcome']=='Failed' for r in nr) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in nr) and 'postcondition could not be proved' in log and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',log,re.I),'Nonsemantic native failure')
 wrong=[r for r in read(folder/'evm-traces/results.json') if not r['passed']];require(len(wrong)==28 and all(r['reason']=='Success' and r['actual']!=r['expected'] for r in wrong) and any(r['ordinal']==6 and r['actual']==f['actual'] and r['expected']==f['expected'] for r in wrong),'Missing matching complete physical fault')
 solc=Path(jobs['runtime-identity']['command'][4]);ct=m['concreteToolchain']
 for name,path in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',dafny.parent/'z3/bin/z3-4.12.1'),('solc',solc)]:require(sha(path)==m['executableSha256'][name],'Native executable drift')
 for name in ['hardhatEntry','edrEntry','nativeBinding','viemEntry']:require(sha(Path(ct[name]))==ct[name+'Sha256'],'Concrete tool drift')
 require(sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'],'Node/lock drift')
 script=OWNER/'byte-at-retention'
 subprocess.run([sys.executable,'-B',script/'check-physical.py',out/'evm-traces'],check=True,cwd=ROOT)
 subprocess.run([sys.executable,'-B',script/'check-physical.py',folder/'evm-traces','--runtime',candidate],check=True,cwd=ROOT)
 with tempfile.TemporaryDirectory(prefix='operations-byte-at-evidence-check-') as tmp:
  dest=Path(tmp)
  def record(name,cmd,timeout):
   result=subprocess.run([str(x) for x in cmd],cwd=ROOT,capture_output=True,text=True,timeout=timeout);return {'name':name,'passed':result.returncode==0}
  require(v.regenerate(OWNER,dest,record),'Fresh full graph regeneration drift')
  subprocess.run([sys.executable,'-B',script/'make-candidates.py','--output',dest/'candidates'],check=True,stdout=subprocess.DEVNULL);require((dest/'candidates/inventory.json').read_bytes()==(out/'candidates/inventory.json').read_bytes() and (dest/'candidates'/(f['name']+'.bin')).read_bytes()==bits,'Fresh candidate drift')
  clone=dest/'source-snapshot';shutil.copytree(out/'source-snapshot',clone);success=clone/v.SUCCESS.relative_to(ROOT)
  subprocess.run([sys.executable,'-B',success/'generate.py','--runtime',candidate,'--output',success],check=True,stdout=subprocess.DEVNULL)
  subprocess.run([sys.executable,'-B',success/'format-generated.py','--output',success,'--include-root',success],check=True,stdout=subprocess.DEVNULL)
  mutable={str(v.SUCCESS.relative_to(ROOT)/f.name) for f in v.SUCCESS.iterdir() if f.is_file() and (f.suffix=='.dfy' or f.name=='serialization.mapping.json')}
  for name,h in m['sourceSha256'].items():
   actual=folder/'source-snapshot'/name
   require(sha(actual)==sha(clone/name) if name in mutable else sha(actual)==h,'Mutation graph/source drift '+name)
  subprocess.run([sys.executable,'-B',OWNER/'identity.py','--solc',solc,'--output',dest/'identity'],check=True,stdout=subprocess.DEVNULL);require((dest/'identity/identity.json').read_bytes()==(out/'identity/identity.json').read_bytes(),'Fresh compiler/runtime/selector identity drift')
  subprocess.run([ct['nodeExecutable'],script/'evm-traces.mjs',dest/'baseline'],check=True,cwd=ROOT,stdout=subprocess.DEVNULL);subprocess.run([sys.executable,'-B',script/'check-physical.py',dest/'baseline'],check=True,cwd=ROOT)
  failure=subprocess.run([ct['nodeExecutable'],script/'evm-traces.mjs',dest/'fault',candidate],cwd=ROOT,capture_output=True,text=True);require(failure.returncode!=0 and 'Wrong physical raw byteAt receipt' in failure.stderr,'Fresh physical semantic fault not rejected');subprocess.run([sys.executable,'-B',script/'check-physical.py',dest/'fault','--runtime',candidate],check=True,cwd=ROOT)
 print(f'PASS: one complete exact Operations byteAt raw entry; {len(rows)} native obligations,{len(declarations)} declarations,63 zero audits;28 physical original-byte ABI returns+36 exact index errors+16 raw rejections; matching native/full-physical MCOPY-to-CALLDATACOPY semantic fault. Explicit finite fitting and reached resources remain.')
if __name__=='__main__':main()
