#!/usr/bin/env python3
"""Independent current-input/native/generated/physical/mutation closure check for hash(bytes)."""
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
 ledger=read(ROOT/'docs/verification/operations-hash-bytes-bytecode-v4.json');out=(ROOT/ledger['baseline']).parent;m=read(out/'manifest.json');v=load('hash_retainer',OWNER/'hash-bytes-retention-v4/verify.py')
 require(sha(out/'manifest.json')==ledger['baselineSha256'] and m['status']=='passed' and all(m[k] for k in ['inputsUnchanged','toolsUnchanged','concreteToolsUnchanged']) and all(j['passed'] for j in m['checks']),'Incomplete retained evidence')
 require(m.get('wholeModuleWatchdogSeconds')==7200 and m.get('ordinaryObligationLimitSeconds')==30,'Native watchdog/per-obligation policy drift')
 require(m['publicEntries']==ledger['publicEntries']==['Operations.hash(bytes)'] and m['assumptions']==ledger['assumptions'],'Public scope drift')
 require({str(p.relative_to(ROOT)):sha(p) for p in v.inputs()}==m['sourceSha256'],'Current input inventory drift')
 for name,digest in m['sourceSha256'].items():require(sha(out/'source-snapshot'/name)==digest,'Source snapshot drift '+name)
 require({str(p.relative_to(out)):sha(p) for p in out.rglob('*') if p.is_file() and p.name!='manifest.json'}==m['evidenceSha256'],'Whole evidence closure drift')
 require(m['proofFiles']==[str(p.relative_to(ROOT)) for p in v.PROOFS] and len(v.PROOFS)==67,'Incomplete native graph');closed=set()
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
 require(ledger['connections']==['OperationsHashFullConnection.Run'] and all(n in proved for n in ledger['connections']),'Missing complete raw connection')
 code=bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();require(digest==ledger['runtimeSha256']==read(out/'identity/identity.json')[0]['runtimeSha256'],'Runtime drift')
 mapping=read(OWNER/'hash-bytes-success-repair-v4/body.mapping.json');require(mapping['totalInstructions']==60 and len(mapping['states'])==60 and mapping['runtimeSha256']==digest,'Body instruction inventory drift')
 prefix=read(OWNER/'hash-bytes-success-repair-v4/Prefix.mapping.json');require(len(prefix['states'])==152 and prefix['states'][-1]['pc']==7568,'Accepted decoder instruction inventory drift')
 fixtures=read(out/'evm-traces/results.json');require(len(fixtures)==38 and all(r['passed'] for r in fixtures) and {r['ordinal'] for r in fixtures}==set(range(38)),'Physical inventory drift')
 require(sum(r['reason']=='Success' for r in fixtures)==22 and ledger['concreteSuccessReceipts']==22 and ledger['concreteRejectionReceipts']==16,'Complementary physical partition drift')
 for r in fixtures:
  t=read(out/'evm-traces'/r['trace']);require(not t['candidate'] and t['runtimeSha256']==digest,'Physical runtime drift')
  if r['reason']=='Success':require([s['pc'] for s in t['trace']['structLogs']]==[s['pc'] for s in prefix['states'][:-1]]+[s['pc'] for s in mapping['states']],'Wrong complete successful raw path')
 faults=read(out/'mutations/results.json');require(len(faults)==ledger['semanticBytecodeFaults']==1,'Semantic fault inventory drift');f=faults[0]
 require(f['pc']==7593 and f['baselineOpcode']==0x20 and f['candidateOpcode']==0x01 and f['witnessOrdinal']==4 and f['inputLength']==2 and f['witnessBytes']==[165,165] and f['baselineSemanticSymbol']=='OperationsHashSuccessEntry.SemanticWitness' and f['baselineSemanticSymbol'] in proved and all(j['passed'] for j in f['checks']),'Wrong matching baseline-covered semantic fault')
 candidate=out/'candidates'/(f['name']+'.bin');bits=candidate.read_bytes();require(sha(candidate)==f['runtimeSha256'] and len(bits)==len(code) and [(i,a,b) for i,(a,b) in enumerate(zip(code,bits)) if a!=b]==[(7593,0x20,0x01)],'Wrong one-byte runtime mutation')
 folder=out/'mutations'/f['name'];file=out/f['semanticAssertion']['file'];lines=file.read_text().splitlines();line=f['semanticAssertion'];require(lines[line['line']-1]==line['text'] and line['text'].strip()=='ensures state.stack[|state.stack|-2]==result' and 'requires count==2 && result==0xbc07f95faa953d0c799ffc75a8afda081bafda1396ac3ec9ba52784dccf67316' in '\n'.join(lines),'Semantic postcondition/witness drift')
 native=f['checks'][2];expected=[str(x) for x in v.common.proof_command(dafny,file,folder/'proof.csv')]+['--filter-symbol',f['baselineSemanticSymbol'],'--filter-position',str(file)+':'+str(line['line']),'--progress','Symbol'];require(native['command']==expected and native['exitCode'] not in [0,None],'Semantic native source/command drift')
 nr=list(csv.DictReader((folder/'proof.csv').open()));log=(out/native['log']).read_text();require(any(r['TestResult.Outcome']=='Failed' for r in nr) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in nr) and 'postcondition could not be proved' in log and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',log,re.I),'Nonsemantic native failure')
 wrong=[r for r in read(folder/'evm-traces/results.json') if not r['passed']];require(len(wrong)==22 and all(r['reason']=='Success' and r['actual']!=r['expected'] for r in wrong) and any(r['ordinal']==4 and r['actual']==f['actual'] and r['expected']==f['expected'] for r in wrong),'Missing matching complete physical fault')
 solc=Path(jobs['runtime-identity']['command'][4]);ct=m['concreteToolchain']
 for name,path in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',dafny.parent/'z3/bin/z3-4.12.1'),('solc',solc)]:require(sha(path)==m['executableSha256'][name],'Native executable drift')
 for name in ['hardhatEntry','edrEntry','nativeBinding','viemEntry']:require(sha(Path(ct[name]))==ct[name+'Sha256'],'Concrete tool drift')
 require(sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'],'Node/lock drift')
 script=OWNER/'hash-bytes-retention-v4'
 subprocess.run([sys.executable,'-B',script/'check-physical.py',out/'evm-traces'],check=True,cwd=ROOT)
 subprocess.run([sys.executable,'-B',script/'check-physical.py',folder/'evm-traces','--runtime',candidate],check=True,cwd=ROOT)
 with tempfile.TemporaryDirectory(prefix='operations-hash-evidence-check-') as tmp:
  dest=Path(tmp)
  def record(name,cmd,timeout):
   result=subprocess.run([str(x) for x in cmd],cwd=ROOT,capture_output=True,text=True,timeout=timeout);return {'name':name,'passed':result.returncode==0}
  require(v.regenerate(OWNER,dest,record),'Fresh full graph regeneration drift')
  subprocess.run([sys.executable,'-B',script/'make-candidates.py','--output',dest/'candidates'],check=True,stdout=subprocess.DEVNULL);require((dest/'candidates/inventory.json').read_bytes()==(out/'candidates/inventory.json').read_bytes() and (dest/'candidates'/(f['name']+'.bin')).read_bytes()==bits,'Fresh candidate drift')
  clone=dest/'source-snapshot';shutil.copytree(out/'source-snapshot',clone);success=clone/v.SUCCESS.relative_to(ROOT)
  subprocess.run([sys.executable,'-B',success/'generate.py','--runtime',candidate,'--output',success],check=True,stdout=subprocess.DEVNULL)
  subprocess.run([sys.executable,'-B',success/'format-generated.py','--output',success,'--include-root',success],check=True,stdout=subprocess.DEVNULL)
  mutable={str(v.SUCCESS.relative_to(ROOT)/name) for name in ['State.generated.dfy','Block0.generated.dfy','Block1.generated.dfy','Block2.generated.dfy','Entry.generated.dfy','body.mapping.json']}
  for name,h in m['sourceSha256'].items():
   actual=folder/'source-snapshot'/name
   require(sha(actual)==sha(clone/name) if name in mutable else sha(actual)==h,'Mutation graph/source drift '+name)
  subprocess.run([sys.executable,'-B',OWNER/'identity.py','--solc',solc,'--output',dest/'identity'],check=True,stdout=subprocess.DEVNULL);require((dest/'identity/identity.json').read_bytes()==(out/'identity/identity.json').read_bytes(),'Fresh compiler/runtime/selector identity drift')
  subprocess.run([ct['nodeExecutable'],script/'evm-traces.mjs',dest/'baseline'],check=True,cwd=ROOT,stdout=subprocess.DEVNULL);subprocess.run([sys.executable,'-B',script/'check-physical.py',dest/'baseline'],check=True,cwd=ROOT)
  failure=subprocess.run([ct['nodeExecutable'],script/'evm-traces.mjs',dest/'fault',candidate],cwd=ROOT,capture_output=True,text=True);require(failure.returncode!=0 and 'Wrong physical raw hash/preimage receipt' in failure.stderr,'Fresh physical semantic fault not rejected');subprocess.run([sys.executable,'-B',script/'check-physical.py',dest/'fault','--runtime',candidate],check=True,cwd=ROOT)
 print(f'PASS: one complete exact Operations hash(bytes) raw entry; {len(rows)} native obligations,{len(declarations)} declarations,67 zero audits,22 exact physical hash returns+16 raw rejections; matching native/physical SHA3-to-ADD semantic fault. Faithful requested hash observations remain explicit.')
if __name__=='__main__':main()
