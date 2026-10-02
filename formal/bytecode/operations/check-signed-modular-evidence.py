#!/usr/bin/env python3
"""Independently check complete retained signed-modular native/provenance/physical/fault closure."""
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
 ledger=read(ROOT/'docs/verification/operations-signed-modular-bytecode.json');out=(ROOT/ledger['baseline']).parent;m=read(out/'manifest.json');v=load('signed-modular_retainer',OWNER/'signed-modular-retention/verify.py')
 require(sha(out/'manifest.json')==ledger['baselineSha256'] and m['status']=='passed' and all(m[k] for k in ['inputsUnchanged','toolsUnchanged','concreteToolsUnchanged']) and all(j['passed'] for j in m['checks']),'Incomplete retained evidence')
 require(m['publicEntries']==ledger['publicEntries']==['Operations.addMod(int256,int256,int256)','Operations.mulMod(int256,int256,int256)'] and m['assumptions']==ledger['assumptions'],'Public scope drift')
 require({str(p.relative_to(ROOT)):sha(p) for p in v.inputs()}==m['sourceSha256'],'Current input inventory drift')
 for n,h in m['sourceSha256'].items():require(sha(out/'source-snapshot'/n)==h,'Source snapshot drift '+n)
 require({str(p.relative_to(out)):sha(p) for p in out.rglob('*') if p.is_file() and p.name!='manifest.json'}==m['evidenceSha256'],'Whole evidence file closure drift')
 require(m['proofFiles']==[str(p.relative_to(ROOT)) for p in v.PROOFS] and len(v.PROOFS)==37,'Incomplete native graph');closed=set()
 def visit(p):
  p=p.resolve();require(p in v.PROOFS,'Uninventoried included native dependency')
  if p in closed:return
  closed.add(p)
  for n in re.findall(r'^include "([^"]+)"',p.read_text(),re.M):visit(p.parent/n)
 for p in v.PROOFS:visit(p)
 require(closed==set(v.PROOFS),'Incomplete include closure')
 jobs={j['name']:j for j in m['checks']};rows=[];decl=[]
 for p in v.PROOFS:
  mod=re.search(r'^module (\w+)',p.read_text(),re.M)[1];j=jobs['proof-'+mod];cmd=j['command'];expected=[str(x) for x in v.common.proof_command(Path(cmd[0]),out/'source-snapshot'/p.relative_to(ROOT),out/(mod+'.csv'))]+['--filter-symbol',mod,'--progress','Symbol']
  require(j['exitCode']==0 and cmd==expected and '--filter-position' not in cmd and cmd[cmd.index('--verification-time-limit')+1]=='30','Partial native command/source/limit drift')
  fresh=dict(j);v.common.check_proof(fresh,out/('proof-'+mod+'.log'),out/(mod+'.csv'),v.inventory(p));require(fresh['passed'] and fresh['nativeResults']==j['nativeResults'] and fresh['declarations']==j['declarations'],'Native declaration/CSV drift');rows+=fresh['nativeResults'];decl+=fresh['declarations']
  audit=jobs['audit-'+mod];require(audit['exitCode']==0 and audit['command']==[cmd[0],'audit',str(out/'source-snapshot'/p.relative_to(ROOT))] and 'auditor completed with 0 findings' in (out/('audit-'+mod+'.log')).read_text(),'Incomplete audit')
 require(rows==m['nativeResults'] and decl==m['declarationResults'] and len(rows)==ledger['nativeObligations'] and len(decl)==ledger['nativeDeclarations'],'Native aggregate drift');proved={d['name'] for d in decl if d['status']=='passed'}
 require(ledger['connections']==['OperationsSignedModularOpcodeConnection.Run'] and all(n in proved for n in ledger['connections']),'Missing whole raw connection')
 code=bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();require(digest==ledger['runtimeSha256']==read(out/'identity/identity.json')[0]['runtimeSha256'],'Runtime drift')
 fixtures=read(out/'evm-traces/results.json');require(len(fixtures)==1476 and all(t['passed'] for t in fixtures) and len({(t['name'],t['ordinal']) for t in fixtures})==1476,'Fixture inventory drift')
 require(ledger['concreteSuccessReceipts']==1210 and ledger['concretePanicReceipts']==242 and ledger['concreteRejectionReceipts']==24 and ledger.get('concreteCustomErrorReceipts',0)==0,'Physical partition counts drift')
 H=1<<255
 def classify(t):
  family=t['name']
  if family not in ['AddModS','MulModS']:return 'Nonzero' if family.endswith('Nonzero') else 'Short' if family.endswith('Short') else family
  a,b,c=[int(t[k]) for k in ['a','b','modulus']]
  if family=='MulModS':id=0 if c==0 else (1 if c>0 else 5)+(1 if a<0 else 0)+(2 if b<0 else 0)
  elif a>=0 and b>=0:id=0 if c==0 else 1 if c>0 else 2
  elif a<0 and b<0:id=15 if c==0 else 16 if c>0 else 17
  elif a>=0:
   id=(5 if c==0 else 6 if c>0 else 8) if abs(a)>=abs(b) else (3 if c==0 else 4 if c>0 else 7)
  else:id=(11 if c==0 else 12 if c>0 else 14) if abs(a)>=abs(b) else (9 if c==0 else 10 if c>0 else 13)
  return family+'Case'+str(id)
 observed=set()
 for t in fixtures:
  receipt=read(out/'evm-traces'/t['trace']);name=classify(t);observed.add(name)
  mapping=read(OWNER/'signed-modular'/('rejections' if name in v.REJECTIONS else '')/(name+'.mapping.json'))
  require(not receipt['candidate'] and receipt['runtimeSha256']==digest and [s['pc'] for s in receipt['trace']['structLogs']]==[s['pc'] for s in mapping['states']],'Wrong complete compiled path '+name)
 require(observed==set(v.NAMES+v.REJECTIONS),'Physical path classes missing')
 faults=read(out/'mutations/results.json');require(len(faults)==ledger['semanticBytecodeFaults']==2,'Semantic fault inventory drift')
 for f in faults:
  expected=('AddModSCase1',3512,8,9,223) if f['publicFamily']=='AddModS' else ('MulModSCase1',4107,9,8,445)
  require((f['entry'],f['pc'],f['oldOpcode'],f['newOpcode'])==expected[:4] and f['witnessArguments']==[123,456,7] and f['witnessOrdinal']==514 and f['baselineSemanticSymbol']=='OperationsSignedModularOpcode'+f['entry']+'.SemanticWitness' and f['baselineSemanticSymbol'] in proved and all(j['passed'] for j in f['checks']),'Wrong baseline-covered matching semantic fault')
  candidate=out/'candidates'/(f['name']+'.bin');bits=candidate.read_bytes();require(sha(candidate)==f['sha256'] and len(bits)==len(code) and [(i,a,b) for i,(a,b) in enumerate(zip(code,bits)) if a!=b]==[expected[1:4]],'Wrong exact one-byte runtime mutation')
  native=f['checks'][2];folder=out/'mutations'/f['name'];file=folder/(f['entry']+'.generated.dfy');lines=file.read_text().splitlines();line=f['semanticAssertion']
  require(lines[line['line']-1]==line['text'] and line['text'].strip()=='ensures state.stack[|state.stack|-2] == Result(a,b,c)' and 'requires a == 123 && b == 456 && c == 7' in '\n'.join(lines),'Semantic postcondition/witness drift')
  expectedcommand=[str(x) for x in v.common.proof_command(Path(native['command'][0]),file,folder/'proof.csv')]+['--filter-symbol',f['baselineSemanticSymbol'],'--filter-position',str(file)+':'+str(line['line']),'--progress','Symbol']
  require(native['command']==expectedcommand and native['exitCode'] not in [0,None],'Semantic native command/source drift')
  nr=list(csv.DictReader((folder/'proof.csv').open()));log=(out/native['log']).read_text();require(any(r['TestResult.Outcome']=='Failed' for r in nr) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in nr) and 'postcondition could not be proved' in log and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',log,re.I),'Nonsemantic native failure')
  wrong=[t for t in read(folder/'evm-traces/results.json') if not t['passed']];require(len(wrong)==expected[4] and all(t['name']==f['publicFamily'] and t['actual']!=t['expected'] for t in wrong) and any(t['ordinal']==514 for t in wrong),'Missing matching physical fault')
 dafny=Path(jobs['proof-OperationsSignedModularOpcodeMachine']['command'][0]);solc=Path(jobs['runtime-identity']['command'][4]);ct=m['concreteToolchain']
 for n,p in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',dafny.parent/'z3/bin/z3-4.12.1'),('solc',solc)]:require(sha(p)==m['executableSha256'][n],'Native executable drift')
 for n in ['hardhatEntry','edrEntry','nativeBinding']:require(sha(Path(ct[n]))==ct[n+'Sha256'],'Concrete tool drift')
 require(sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'],'Node/lock drift')
 subprocess.run([sys.executable,'-B',OWNER/'signed-modular/check-development.py',out/'evm-traces'],check=True,cwd=ROOT)
 for f in faults:
  subprocess.run([sys.executable,'-B',OWNER/'signed-modular/check-development.py',out/'mutations'/f['name']/'evm-traces','--runtime',out/'candidates'/(f['name']+'.bin'),'--expect-fault'],check=True,cwd=ROOT)
 with tempfile.TemporaryDirectory(prefix='operations-signed-modular-evidence-check-') as tmp:
  dest=Path(tmp)
  for relative,names in [('signed-modular',v.NAMES),('signed-modular/rejections',v.REJECTIONS)]:
   gen=dest/'generated'/relative;subprocess.run([sys.executable,'-B',OWNER/relative/'generate.py','--output',gen],check=True,stdout=subprocess.DEVNULL);subprocess.run([sys.executable,'-B',OWNER/'signed-modular/format-generated.py','--output',gen,'--include-root',OWNER/relative],check=True,stdout=subprocess.DEVNULL)
   for n in names:
    for suffix in ['.generated.dfy','.mapping.json']:require((gen/(n+suffix)).read_bytes()==(OWNER/relative/(n+suffix)).read_bytes(),'Generated control drift')
  subprocess.run([sys.executable,'-B',OWNER/'signed-modular/generate-conversion.py','--output',dest/'conversion'],check=True,stdout=subprocess.DEVNULL);require((dest/'conversion/Conversion.generated.dfy').read_bytes()==(OWNER/'signed-modular/Conversion.generated.dfy').read_bytes(),'Conversion regeneration drift')
  subprocess.run([sys.executable,'-B',OWNER/'signed-modular/generate-connection.py','--output',dest/'connection'],check=True,stdout=subprocess.DEVNULL);subprocess.run([sys.executable,'-B',OWNER/'signed-modular/format-generated.py','--output',dest/'connection','--include-root',OWNER/'signed-modular'],check=True,stdout=subprocess.DEVNULL);require((dest/'connection/Connection.generated.dfy').read_bytes()==(OWNER/'signed-modular/Connection.generated.dfy').read_bytes(),'Connection regeneration drift')
  subprocess.run([sys.executable,'-B',OWNER/'signed-modular-retention/make-candidates.py','--output',dest/'candidates'],check=True,stdout=subprocess.DEVNULL);require((dest/'candidates/inventory.json').read_bytes()==(out/'candidates/inventory.json').read_bytes(),'Semantic inventory regeneration drift')
  for f in faults:require((dest/'candidates'/(f['name']+'.bin')).read_bytes()==(out/'candidates'/(f['name']+'.bin')).read_bytes(),'Semantic bytes regeneration drift')
  subprocess.run([sys.executable,'-B',OWNER/'identity.py','--solc',solc,'--output',dest/'identity'],check=True,stdout=subprocess.DEVNULL);require((dest/'identity/identity.json').read_bytes()==(out/'identity/identity.json').read_bytes(),'Fresh compiler/runtime/selector identity drift')
  subprocess.run([ct['nodeExecutable'],OWNER/'signed-modular-retention/evm-traces.mjs',dest/'baseline'],check=True,cwd=ROOT,stdout=subprocess.DEVNULL);subprocess.run([sys.executable,'-B',OWNER/'signed-modular/check-development.py',dest/'baseline'],check=True,cwd=ROOT)
  for f in faults:
   candidate=out/'candidates'/(f['name']+'.bin');target=dest/f['name'];fault=subprocess.run([ct['nodeExecutable'],OWNER/'signed-modular-retention/evm-traces.mjs',target,candidate],cwd=ROOT,capture_output=True,text=True);require(fault.returncode!=0 and 'Wrong physical signed modular receipt: ' in fault.stderr,'Fresh physical fault not rejected');subprocess.run([sys.executable,'-B',OWNER/'signed-modular/check-development.py',target,'--runtime',candidate,'--expect-fault'],check=True,cwd=ROOT)
 print(f'PASS: two Operations signed modular whole raw entries; {len(rows)} native obligations, {len(decl)} declarations,37 zero audits,1210 mathematical returns,242 exact Panic12 and24 raw rejects; two matching native/physical semantic opcode faults. Other entries remain open.')
if __name__=='__main__':main()
