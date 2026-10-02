#!/usr/bin/env python3
"""Independently check complete retained log2 native/provenance/physical/fault closure."""
import csv,hashlib,importlib.util,json,re,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];OWNER=Path(__file__).resolve().parent

def read(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def require(b,message):
 if not b:raise SystemExit(message)
def load(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m

def main():
 ledger=read(ROOT/'docs/verification/operations-log2-bytecode.json');out=(ROOT/ledger['baseline']).parent;m=read(out/'manifest.json');v=load('log2_retainer',OWNER/'log2-repair-v5-retention/verify.py')
 require(sha(out/'manifest.json')==ledger['baselineSha256'] and m['status']=='passed' and all(m[k] for k in ['inputsUnchanged','toolsUnchanged','concreteToolsUnchanged']) and all(j['passed'] for j in m['checks']),'Incomplete retained evidence')
 require(m['publicEntries']==ledger['publicEntries']==['Operations.log2(uint256)'] and m['assumptions']==ledger['assumptions'],'Public scope drift')
 require({str(p.relative_to(ROOT)):sha(p) for p in v.inputs()}==m['sourceSha256'],'Current input inventory drift')
 for n,h in m['sourceSha256'].items():require(sha(out/'source-snapshot'/n)==h,'Source snapshot drift '+n)
 require({str(p.relative_to(out)):sha(p) for p in out.rglob('*') if p.is_file() and p.name!='manifest.json'}==m['evidenceSha256'],'Whole evidence file closure drift')
 require(m['proofFiles']==[str(p.relative_to(ROOT)) for p in v.PROOFS] and len(v.PROOFS)==22,'Incomplete native graph');closed=set()
 def visit(p):
  p=p.resolve();require(p in v.PROOFS,'Uninventoried included native dependency')
  if p in closed:return
  closed.add(p)
  for n in re.findall(r'^include "([^"]+)"',p.read_text(),re.M):visit(p.parent/n)
 for p in v.PROOFS:visit(p)
 require(closed==set(v.PROOFS),'Incomplete include closure')
 jobs={j['name']:j for j in m['checks']};rows=[];decl=[]
 for p in v.PROOFS:
  mod=re.search(r'^module (\w+)',p.read_text(),re.M)[1];j=jobs['proof-'+mod];cmd=j['command'];expected=[str(x) for x in v.common.proof_command(Path(cmd[0]),out/'source-snapshot'/p.relative_to(ROOT),out/(mod+'.csv'))]+['--filter-symbol',mod,'--filter-position',str(out/'source-snapshot'/p.relative_to(ROOT)),'--progress','Symbol']
  require(j['exitCode']==0 and cmd==expected and cmd[cmd.index('--verification-time-limit')+1]=='30','Partial native command/source/limit drift')
  fresh=dict(j);v.common.check_proof(fresh,out/('proof-'+mod+'.log'),out/(mod+'.csv'),v.inventory(p));require(fresh['passed'] and fresh['nativeResults']==j['nativeResults'] and fresh['declarations']==j['declarations'],'Native declaration/CSV drift');rows+=fresh['nativeResults'];decl+=fresh['declarations']
  audit=jobs['audit-'+mod];require(audit['exitCode']==0 and audit['command']==[cmd[0],'audit',str(out/'source-snapshot'/p.relative_to(ROOT))] and 'auditor completed with 0 findings' in (out/('audit-'+mod+'.log')).read_text(),'Incomplete audit')
 require(rows==m['nativeResults'] and decl==m['declarationResults'] and len(rows)==ledger['nativeObligations'] and len(decl)==ledger['nativeDeclarations'],'Native aggregate drift');proved={d['name'] for d in decl if d['status']=='passed'}
 require(ledger['connections']==['OperationsBytecodeLog2Connection.Run'] and all(n in proved for n in ledger['connections']),'Missing whole raw connection')
 code=bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();require(digest==ledger['runtimeSha256']==read(out/'identity/identity.json')[0]['runtimeSha256'],'Runtime drift')
 fixtures=read(out/'evm-traces/results.json');require(len(fixtures)==31 and all(t['passed'] for t in fixtures) and {t['ordinal'] for t in fixtures}==set(range(31)),'Fixture inventory drift')
 counts={'Positive':21,'Zero':1,'Args':3,'Short':4,'Nonzero':2};require({n:sum(t['name']==n for t in fixtures) for n in counts}==counts,'Complementary physical admission inventory drift')
 for t in fixtures:
  receipt=read(out/'evm-traces'/t['trace']);mapping=read(OWNER/'log2-repair-v5'/(t['name']+'.mapping.json'));require(not receipt['candidate'] and receipt['runtimeSha256']==digest and [s['pc'] for s in receipt['trace']['structLogs']]==[s['pc'] for s in mapping['states']],'Wrong complete compiled path')
 require(ledger['concreteSuccessReceipts']==21 and ledger['concreteRejectionReceipts']==9 and ledger.get('concreteCustomErrorReceipts')==1,'Physical partition counts drift')
 faults=read(out/'mutations/results.json');require(len(faults)==ledger['semanticBytecodeFaults']==1,'Semantic fault inventory drift');f=faults[0];require(f['entry']=='Positive' and f['pc']==11109 and f['oldOpcode']==0x1a and f['newOpcode']==0x1c and f['witnessArgument']==4 and f['witnessOrdinal']==4 and f['baselineSemanticSymbol']=='OperationsBytecodeLog2Positive.SemanticWitness' and f['baselineSemanticSymbol'] in proved and all(j['passed'] for j in f['checks']),'Wrong matching baseline-covered semantic fault')
 candidate=out/'candidates'/(f['name']+'.bin');bits=candidate.read_bytes();require(sha(candidate)==f['sha256'] and len(bits)==len(code) and [(i,a,b) for i,(a,b) in enumerate(zip(code,bits)) if a!=b]==[(11109,0x1a,0x1c)],'Wrong one-byte actual runtime mutation')
 native=f['checks'][2];folder=out/'mutations'/f['name'];file=folder/'Positive.generated.dfy';lines=file.read_text().splitlines();line=f['semanticAssertion'];require(lines[line['line']-1]==line['text'] and line['text'].strip()=='ensures state.stack[|state.stack|-2]==Result(a)' and 'requires a==4' in '\n'.join(lines),'Semantic postcondition/witness drift')
 expected=[str(x) for x in v.common.proof_command(Path(native['command'][0]),file,folder/'proof.csv')]+['--filter-symbol',f['baselineSemanticSymbol'],'--filter-position',str(file)+':'+str(line['line']),'--progress','Symbol'];require(native['command']==expected and native['exitCode'] not in [0,None],'Semantic native command/source drift');nr=list(csv.DictReader((folder/'proof.csv').open()));log=(out/native['log']).read_text();require(any(r['TestResult.Outcome']=='Failed' for r in nr) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in nr) and 'postcondition could not be proved' in log and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',log,re.I),'Nonsemantic native failure')
 mismatches=read(folder/'evm-traces/results.json');wrong=[t for t in mismatches if not t['passed']];require(len(wrong)==21 and all(t['name']=='Positive' and t['actual']!=t['expected'] for t in wrong) and any(t['ordinal']==4 for t in wrong),'Missing matching independently replayed physical fault')
 dafny=Path(jobs['proof-OperationsBytecodeLog2Machine']['command'][0]);solc=Path(jobs['runtime-identity']['command'][4]);ct=m['concreteToolchain']
 for n,p in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',dafny.parent/'z3/bin/z3-4.12.1'),('solc',solc)]:require(sha(p)==m['executableSha256'][n],'Native executable drift')
 for n in ['hardhatEntry','edrEntry','nativeBinding']:require(sha(Path(ct[n]))==ct[n+'Sha256'],'Concrete tool drift')
 require(sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'],'Node/lock drift')
 subprocess.run([sys.executable,'-B',OWNER/'log2-repair-v5/check-development.py',out/'evm-traces'],check=True,cwd=ROOT)
 subprocess.run([sys.executable,'-B',OWNER/'log2-repair-v5/check-development.py',folder/'evm-traces','--runtime',candidate,'--expect-fault'],check=True,cwd=ROOT)
 with tempfile.TemporaryDirectory(prefix='operations-log2-evidence-check-') as tmp:
  dest=Path(tmp);gen=dest/'generated';subprocess.run([sys.executable,'-B',OWNER/'log2-repair-v5/generate.py','--output',gen],check=True,stdout=subprocess.DEVNULL);subprocess.run([sys.executable,'-B',OWNER/'log2-repair-v5/format-generated.py','--output',gen,'--include-root',OWNER/'log2-repair-v5'],check=True,stdout=subprocess.DEVNULL)
  for n in v.NAMES:
   for suffix in ['.generated.dfy','.mapping.json']:require((gen/(n+suffix)).read_bytes()==(OWNER/'log2-repair-v5'/(n+suffix)).read_bytes(),'Generated control drift')
  for n in ['PositiveState.generated.dfy',*[f'PositiveBlock{i}.generated.dfy' for i in range(10)]]:require((gen/n).read_bytes()==(OWNER/'log2-repair-v5'/n).read_bytes(),'Generated block drift')
  subprocess.run([sys.executable,'-B',OWNER/'log2-repair-v5/generate-conversion.py','--output',dest/'conversion'],check=True,stdout=subprocess.DEVNULL);require((dest/'conversion/Conversion.generated.dfy').read_bytes()==(OWNER/'log2-repair-v5/Conversion.generated.dfy').read_bytes(),'Conversion regeneration drift')
  subprocess.run([sys.executable,'-B',OWNER/'log2-repair-v5-retention/make-candidates.py','--output',dest/'candidates'],check=True,stdout=subprocess.DEVNULL);require((dest/'candidates/inventory.json').read_bytes()==(out/'candidates/inventory.json').read_bytes() and (dest/'candidates'/(f['name']+'.bin')).read_bytes()==bits,'Semantic candidate regeneration drift')
  subprocess.run([sys.executable,'-B',OWNER/'identity.py','--solc',solc,'--output',dest/'identity'],check=True,stdout=subprocess.DEVNULL);require((dest/'identity/identity.json').read_bytes()==(out/'identity/identity.json').read_bytes(),'Fresh compiler/runtime/selector identity drift')
  subprocess.run([ct['nodeExecutable'],OWNER/'log2-repair-v5-retention/evm-traces.mjs',dest/'baseline'],check=True,cwd=ROOT,stdout=subprocess.DEVNULL);subprocess.run([sys.executable,'-B',OWNER/'log2-repair-v5/check-development.py',dest/'baseline'],check=True,cwd=ROOT)
  fault=subprocess.run([ct['nodeExecutable'],OWNER/'log2-repair-v5-retention/evm-traces.mjs',dest/'fault',candidate],cwd=ROOT,capture_output=True,text=True);require(fault.returncode!=0 and 'Wrong physical logarithm/custom-error/raw receipt: 21' in fault.stderr,'Fresh physical mutation not rejected');subprocess.run([sys.executable,'-B',OWNER/'log2-repair-v5/check-development.py',dest/'fault','--runtime',candidate,'--expect-fault'],check=True,cwd=ROOT)
 print(f'PASS: one Operations log2 whole raw entry; {len(rows)} native obligations, {len(decl)} declarations, twenty-two zero audits,21 mathematical returns, one exact zero custom error and9 raw rejects; one matching native/physical semantic opcode fault. Other entries remain open.')
if __name__=='__main__':main()
