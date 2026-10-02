#!/usr/bin/env python3
"""Independent closed retained evidence checker for checked sorted-pair hash raw entries."""
import csv,hashlib,importlib.util,json,re,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];OWNER=Path(__file__).resolve().parent
MOD=1<<256
PANIC='4e487b71'+format(17,'064x')
from Crypto.Hash import keccak
def digest(preimage):
 h=keccak.new(digest_bits=256);h.update(bytes.fromhex(preimage));return h.hexdigest()
def intended(t):
 data=t['data'][2:];require(data[:8]=='c203edb3' and len(data)>=136,'Wrong raw scalar head')
 a,b=int(data[8:72],16),int(data[72:136],16)
 preimage=format(min(a,b),'064x')+format(max(a,b),'064x')
 return a,b,preimage,digest(preimage)
def read(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,msg):
 if not ok:raise SystemExit(msg)
def load(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m

def candidate_path(logs,code):
 ins={};pc=0
 names={1:'ADD',2:'MUL',3:'SUB',4:'DIV',6:'MOD',8:'ADDMOD',9:'MULMOD',16:'LT',17:'GT',18:'SLT',19:'SGT',20:'EQ',21:'ISZERO',22:'AND',23:'OR',24:'XOR',25:'NOT',32:'KECCAK256',27:'SHL',28:'SHR',52:'CALLVALUE',53:'CALLDATALOAD',54:'CALLDATASIZE',80:'POP',81:'MLOAD',82:'MSTORE',86:'JUMP',87:'JUMPI',91:'JUMPDEST',95:'PUSH0',243:'RETURN',253:'REVERT'}
 while pc<len(code):
  op=code[pc];width=op-95 if 96<=op<=127 else 0
  ins[pc]=(op,pc+1+width,int.from_bytes(code[pc+1:pc+1+width],'big'));pc+=1+width
 for i,step in enumerate(logs):
  require(step['pc'] in ins,'Candidate PC is not an instruction boundary');op,nxt,immediate=ins[step['pc']]
  name='PUSH'+str(op-95) if 96<=op<=127 else 'DUP'+str(op-127) if 128<=op<=143 else 'SWAP'+str(op-143) if 144<=op<=159 else names.get(op)
  require(name==step['op'],'Candidate trace opcode differs from executed runtime byte')
  if i+1<len(logs):
   if op==86 or op==87 and int(step['stack'][-2],16)!=0:
    nxt=int(step['stack'][-1],16);require(nxt in ins and ins[nxt][0]==91,'Invalid actual candidate jump')
   require(logs[i+1]['pc']==nxt,'Incomplete actual candidate instruction path')
   if 95<=op<=127:require(int(logs[i+1]['stack'][-1],16)==immediate,'Wrong actual candidate PUSH immediate')

def physical(t,expected,failed,mapping=None,runtime=None,preimage=None):
 trace=t['trace'];logs=trace['structLogs'];last=logs[-1]
 require(logs[0]['pc']==0 and all(x['depth']==1 for x in logs),'Incomplete physical call frame')
 if mapping is not None:require([x['pc'] for x in logs]==[x['pc'] for x in mapping['states']],'Incomplete physical instruction path')
 else:require(runtime is not None,'Missing candidate runtime');candidate_path(logs,runtime)
 off,size=int(last['stack'][-1],16),int(last['stack'][-2],16);memory=''.join(x.removeprefix('0x') for x in last['memory'])
 require(trace['failed']==failed and trace['returnValue'].removeprefix('0x')==expected and last['op']==('REVERT' if failed else 'RETURN'),'Wrong actual physical receipt')
 require((off,size)==((0,0) if failed else (224,32)) and memory[off*2:(off+size)*2]==expected,'Wrong physical RETURN/empty REVERT bytes')
 if failed:require(expected=='','Unexpected source error bytes');return
 hashes=[(i,x) for i,x in enumerate(logs) if x['op'] in ['KECCAK256','SHA3']];require(len(hashes)==1,'Wrong actual hash invocation count');i,step=hashes[0]
 offset,length=int(step['stack'][-1],16),int(step['stack'][-2],16);mem=''.join(x.removeprefix('0x') for x in step['memory']);actualPreimage=mem[offset*2:(offset+length)*2]
 require((offset,length)==(160,64) and len(actualPreimage)==128,'Wrong actual64-byte SHA3 window')
 if preimage is not None:require(actualPreimage==preimage,'Wrong independently sorted pair preimage')
 observed=logs[i+1]['stack'][-1].removeprefix('0x').zfill(64);require(observed==expected==digest(actualPreimage),'Unfaithful concrete hash-engine observation')
 a,b=int(actualPreimage[:64],16),int(actualPreimage[64:],16);stores=[x for x in logs if x['op']=='MSTORE'];values=[(int(x['stack'][-1],16),int(x['stack'][-2],16)) for x in stores]
 require(values==[(64,128),(160,a),(192,b),(128,64),(64,224),(224,int(expected,16))],'Wrong original-word/packed-header/heap/hash stores')

def main():
 ledger=read(ROOT/'docs/verification/operations-hash-pair-sorted-bytecode.json');out=(ROOT/ledger['baseline']).parent;m=read(out/'manifest.json');v=load('hash-pair-sorted_retainer',OWNER/'hash-pair-sorted-retention/verify.py')
 require(sha(out/'manifest.json')==ledger['baselineSha256'] and m['status']=='passed' and all(m[k] for k in ['inputsUnchanged','toolsUnchanged','concreteToolsUnchanged']) and all(j['passed'] for j in m['checks']), 'Incomplete retained evidence')
 require(m['publicEntries']==ledger['publicEntries'] and m['assumptions']==ledger['assumptions'], 'Scope drift')
 require({str(p.relative_to(ROOT)):sha(p) for p in v.inputs()}==m['sourceSha256'], 'Current input inventory drift')
 for name,digest in m['sourceSha256'].items():require(sha(out/'source-snapshot'/name)==digest,'Snapshot drift '+name)
 require({str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='manifest.json'}==m['evidenceSha256'], 'Complete evidence file closure drift')
 require(m['proofFiles']==[str(p.relative_to(ROOT)) for p in v.PROOFS] and len(v.PROOFS)==9, 'Native graph inventory drift');closed=set()
 def visit(p):
  p=p.resolve();require(p in v.PROOFS,'Uninventoried native dependency')
  if p in closed:return
  closed.add(p)
  for i in re.findall(r'^include "([^"]+)"',p.read_text(),re.M):visit(p.parent/i)
 for p in v.PROOFS:visit(p)
 require(closed==set(v.PROOFS), 'Incomplete native graph');jobs={j['name']:j for j in m['checks']};rows=[];declarations=[]
 for p in v.PROOFS:
  mod=re.search(r'^module (\w+)',p.read_text(),re.M)[1];job=jobs['proof-'+mod];command=job['command'];require(job['exitCode']==0 and '--filter-position' not in command and command[command.index('--filter-symbol')+1]==mod and command[command.index('--verification-time-limit')+1]=='30' and all(x in command for x in ['--verify-included-files','--manual-lemma-induction','--isolate-assertions']), 'Partial native coverage')
  expected=[str(x) for x in v.common.proof_command(Path(command[0]),out/'source-snapshot'/p.relative_to(ROOT),out/(mod+'.csv'))]+['--filter-symbol',mod,'--progress','Symbol'];require(command==expected,'Native command/source/solver drift')
  audit=jobs['audit-'+mod];require(audit['command']==[command[0],'audit',str(out/'source-snapshot'/p.relative_to(ROOT))],'Audit command/source drift')
  fresh=dict(job);v.common.check_proof(fresh,out/('proof-'+mod+'.log'),out/(mod+'.csv'),v.v.inventory(p));require(fresh['passed'] and fresh['nativeResults']==job['nativeResults'] and fresh['declarations']==job['declarations'], 'Native declaration/obligation drift')
  rows+=fresh['nativeResults'];declarations+=fresh['declarations'];require(jobs['audit-'+mod]['exitCode']==0 and 'auditor completed with 0 findings' in (out/('audit-'+mod+'.log')).read_text(),'Native audit findings')
 require(rows==m['nativeResults'] and declarations==m['declarationResults'] and len(rows)==ledger['nativeObligations'] and len(declarations)==ledger['nativeDeclarations'],'Native aggregate drift');proved={d['name'] for d in declarations if d['status']=='passed'}
 require(all(n in proved for n in ledger['connections']),'Unproved complete raw connection')
 base=bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);digestRuntime=hashlib.sha256(base).hexdigest();require(digestRuntime==ledger['runtimeSha256']==read(out/'identity/identity.json')[0]['runtimeSha256'],'Runtime drift')
 receipts=read(out/'evm-traces/results.json');require(len(receipts)==16 and {r['ordinal'] for r in receipts}==set(range(16)),'Physical success inventory drift')
 for receipt in receipts:
  t=read(out/'evm-traces'/receipt['trace']);a,b,preimage,expected=intended(t);require(receipt['passed'] and not t['candidate'] and t['runtimeSha256']==digestRuntime and t['expected']==expected and t['preimage']==preimage,'Wrong independent sorted result')
  case='Keep' if a<=b else 'Swap';physical(t,expected,False,read(OWNER/'hash-pair-sorted'/(case+'.mapping.json')),preimage=preimage)
 rejected=read(out/'rejection-traces/results.json');require(len(rejected)==16 and all(r['passed'] for r in rejected),'Physical rejection inventory drift')
 for r in rejected:
  data=r['data'][2:];value=int(r['value'],16)
  require(value>0 if r['name']=='Nonzero' else value==0 and (len(data)//2<4 if r['name']=='Short' else data[:8]=='c203edb3' and 4<=len(data)//2<68),'Wrong raw rejection admission')
  physical(read(out/'rejection-traces'/r['trace']),'',True,read(OWNER/'hash-pair-sorted/rejections'/(r['name']+'.mapping.json')))
 faults=read(out/'mutations/results.json');candidates=read(out/'candidates/inventory.json');require(len(faults)==ledger['semanticBytecodeFaults']==1 and {f['publicFamily'] for f in faults}=={'HashPairSorted'},'Semantic fault inventory drift')
 for f,c in zip(faults,candidates):
  require(all(f[k]==value for k,value in c.items()) and c['baselineSemanticSymbol'] in proved and all(j['passed'] for j in f['checks']) and c['entry']=='Swap' and c['witnessArguments']==[456,123] and c['witnessOrdinal']==4,'Fault baseline closure drift')
  candidate=out/'candidates'/(c['name']+'.bin');bits=candidate.read_bytes();require(sha(candidate)==c['sha256'] and len(bits)==len(base) and [(i,a,b) for i,(a,b) in enumerate(zip(base,bits)) if a!=b]==[(c['pc'],c['oldOpcode'],c['newOpcode'])],'Wrong exact one-byte runtime mutation')
  mapping=read(OWNER/'hash-pair-sorted'/(c['entry']+'.mapping.json'));require(any(s['pc']==c['pc'] and s['opcode']==c['oldOpcode'] and sorted(s['stack'][-2:])==['a','b'] for s in mapping['states']),'Mutation is not the reached operand opcode')
  native=f['checks'][2];text=(out/native['log']).read_text();nr=list(csv.DictReader((out/'mutations'/c['name']/'proof.csv').open()));require(native['exitCode'] not in [0,None] and any(r['TestResult.Outcome']=='Failed' for r in nr) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in nr) and 'postcondition could not be proved' in text and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',text,re.I),'Nonsemantic native mutation failure')
  file=out/'mutations'/c['name']/(c['entry']+'.generated.dfy');line=f['semanticAssertion'];expected=[str(x) for x in v.common.proof_command(Path(native['command'][0]),file,out/'mutations'/c['name']/'proof.csv')]+['--filter-symbol',c['baselineSemanticSymbol'],'--filter-position',str(file)+':'+str(line['line']),'--progress','Symbol'];require(native['command']==expected,'Semantic native command/source/solver drift')
  source=(out/'mutations'/c['name']/(c['entry']+'.generated.dfy')).read_text().splitlines();line=f['semanticAssertion'];require(source[line['line']-1]==line['text'] and 'ensures state.memory[160..224] == SortedPair(a,b)' in line['text'] and 'requires a == 456 && b == 123' in '\n'.join(source),'Native witness target drift')
  witnesses=[r for r in f['concreteFailures'] if r['ordinal']==c['witnessOrdinal']];require(len(witnesses)==1,'Missing matching physical witness')
  for receipt in f['concreteFailures']:
   t=read(out/'mutations'/c['name']/'evm-traces'/receipt['trace']);a,b,preimage,expected=intended(t);actual=t['trace']['returnValue'].removeprefix('0x')
   require(t['candidate'] and t['runtimeSha256']==c['sha256'] and receipt['expected']==expected and receipt['actual']==actual and actual!=expected and receipt['actualPreimage']!=preimage,'False independently computed wrong preimage/receipt')
   case='Keep' if a<=b else 'Swap';physical(t,actual,False,read(out/'mutations'/c['name']/(case+'.mapping.json')) if receipt['ordinal']==c['witnessOrdinal'] else None,runtime=bits,preimage=receipt['actualPreimage'])
   if receipt['ordinal']==c['witnessOrdinal']:require([a,b]==c['witnessArguments'],'Native/physical witness mismatch')
 dafny=Path(jobs['proof-OperationsHashPairSortedMachine']['command'][0]);solc=Path(jobs['runtime-identity']['command'][4])
 for k,p in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',dafny.parent/'z3/bin/z3-4.12.1'),('solc',solc)]:require(sha(p)==m['executableSha256'][k],'Native tool drift')
 ct=m['concreteToolchain']
 for k in ['hardhatEntry','edrEntry','nativeBinding','viemEntry']:require(sha(Path(ct[k]))==ct[k+'Sha256'],'Concrete tool drift')
 require(sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'],'Node/lockfile drift')
 with tempfile.TemporaryDirectory(prefix='operations-hash-pair-sorted-check-') as tmp:
  dest=Path(tmp)
  for folder,names in [('hash-pair-sorted',v.NAMES),('hash-pair-sorted/rejections',v.REJECTIONS)]:
   target=dest/folder;subprocess.run([sys.executable,'-B',OWNER/folder/'generate.py','--output',target],check=True,stdout=subprocess.DEVNULL);subprocess.run([sys.executable,'-B',OWNER/'hash-pair-sorted/format-generated.py','--output',target,'--include-root',OWNER/folder],check=True,stdout=subprocess.DEVNULL)
   for n in names:
    for suffix in ['.generated.dfy','.mapping.json']:require((target/(n+suffix)).read_bytes()==(OWNER/folder/(n+suffix)).read_bytes(),'Generated entry drift')
  subprocess.run([sys.executable,'-B',OWNER/'hash-pair-sorted/generate-conversion.py','--output',dest/'conversion'],check=True,stdout=subprocess.DEVNULL);require((dest/'conversion/Conversion.generated.dfy').read_bytes()==(OWNER/'hash-pair-sorted/Conversion.generated.dfy').read_bytes(),'Conversion generation drift')
  subprocess.run([sys.executable,'-B',OWNER/'hash-pair-sorted-retention/make-candidates.py','--output',dest/'candidates'],check=True,stdout=subprocess.DEVNULL);require((dest/'candidates/inventory.json').read_bytes()==(out/'candidates/inventory.json').read_bytes(),'Candidate inventory drift')
  for c in candidates:require((dest/'candidates'/(c['name']+'.bin')).read_bytes()==(out/'candidates'/(c['name']+'.bin')).read_bytes(),'Candidate byte generation drift')
  subprocess.run([sys.executable,'-B',OWNER/'identity.py','--solc',solc,'--output',dest/'identity'],check=True,stdout=subprocess.DEVNULL);require((dest/'identity/identity.json').read_bytes()==(out/'identity/identity.json').read_bytes(),'Current exact compiler identity differs')
  subprocess.run([ct['nodeExecutable'],OWNER/'check-selectors.mjs',dest/'selectors'],check=True,cwd=ROOT,stdout=subprocess.DEVNULL)
  for script,folder in [('evm-traces.mjs','success'),('rejection-traces.mjs','reject')]:subprocess.run([ct['nodeExecutable'],OWNER/'hash-pair-sorted-retention'/script,dest/folder],check=True,cwd=ROOT,stdout=subprocess.DEVNULL)
  require(len(read(dest/'success/results.json'))==16 and len(read(dest/'reject/results.json'))==16,'Fresh physical fixture inventory differs')
  for c in candidates:
   folder=dest/'fresh-mutants'/c['name'];candidate=dest/'candidates'/(c['name']+'.bin');subprocess.run([sys.executable,'-B',OWNER/'hash-pair-sorted/generate.py','--runtime',candidate,'--output',folder/'maps'],check=True,stdout=subprocess.DEVNULL)
   replay=subprocess.run([ct['nodeExecutable'],OWNER/'hash-pair-sorted-retention/evm-traces.mjs',folder/'traces',candidate],cwd=ROOT,capture_output=True,text=True)
   require(replay.returncode!=0 and 'Wrong SHA3 sorted preimage or physical hash receipt' in replay.stderr,'Fresh candidate EVM failure missing');results=read(folder/'traces/results.json');family=c.get('publicFamily',c['entry']);witnesses=[r for r in results if r['name']==family and r['ordinal']==c['witnessOrdinal'] and not r['passed']];require(len(witnesses)==1,'Fresh matching physical witness missing')
   receipt=witnesses[0];t=read(folder/'traces'/receipt['trace']);a,b,preimage,expected=intended(t);actual=t['trace']['returnValue'].removeprefix('0x');require([a,b]==c['witnessArguments'] and expected!=actual and preimage!=receipt['actualPreimage'] and t['runtimeSha256']==c['sha256'],'Fresh physical mathematical witness drift');case='Keep' if a<=b else 'Swap';physical(t,actual,False,read(folder/'maps'/(case+'.mapping.json')),preimage=receipt['actualPreimage'])
 print(f'PASS: 1 Operations checked sorted-pair hash raw entry; {len(rows)} native obligations, {len(declarations)} declarations, 9 zero audits, 16 SHA3/input/return + 16 raw reject receipts, 1 matching native/physical semantic faults. Other entries stay open.')
if __name__=='__main__':main()
