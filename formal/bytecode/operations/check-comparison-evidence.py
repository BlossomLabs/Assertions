#!/usr/bin/env python3
"""Independent closed retained evidence checker for all-word comparison raw entries."""
import csv,hashlib,importlib.util,json,re,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];OWNER=Path(__file__).resolve().parent
MOD=1<<256
def signed(w):return w if w<MOD//2 else w-MOD
OPS={'Eq':lambda a,b:int(a==b),'Ne':lambda a,b:int(a!=b),'LtU':lambda a,b:int(a<b),'GtU':lambda a,b:int(a>b),'LeU':lambda a,b:int(a<=b),'GeU':lambda a,b:int(a>=b),'LtS':lambda a,b:int(signed(a)<signed(b)),'GtS':lambda a,b:int(signed(a)>signed(b)),'LeS':lambda a,b:int(signed(a)<=signed(b)),'GeS':lambda a,b:int(signed(a)>=signed(b))}
SELECTORS={'Eq':'32148d73','Ne':'33151e4c','LtU':'118fc88c','GtU':'21e5749b','LeU':'d3662cfd','GeU':'85e1f66c','LtS':'30880038','GtS':'ac08973d','LeS':'00136bb8','GeS':'6552f187'}
WITNESSES={n:([2,1],5) if n in ['Eq','Ne'] else ([123,456],13) for n in OPS}
def read(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,msg):
 if not ok:raise SystemExit(msg)
def load(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m

def physical(t,expected,failed,mapping):
 trace=t['trace'];logs=trace['structLogs'];last=logs[-1];off,size=int(last['stack'][-1],16),int(last['stack'][-2],16);memory=''.join(w.removeprefix('0x') for w in last['memory'])
 require(logs[0]['pc']==0 and all(s['depth']==1 for s in logs) and [s['pc'] for s in logs]==[s['pc'] for s in mapping['states']], 'Incomplete physical instruction path')
 require(trace['failed']==failed and trace['returnValue'].removeprefix('0x')==expected and last['op']==('REVERT' if failed else 'RETURN'), 'Wrong actual physical receipt')
 require((off,size)==((0,0) if failed else (128,32)) and memory[off*2:(off+size)*2]==expected, 'Wrong physical byte slice')
 if not failed:
  stores=[s for s in logs if s['op']=='MSTORE'];require(len(stores)==2 and int(stores[0]['stack'][-1],16)==64 and int(stores[0]['stack'][-2],16)==128 and int(stores[1]['stack'][-1],16)==128 and int(stores[1]['stack'][-2],16)==int(expected,16), 'Wrong physical word stores')

def main():
 ledger=read(ROOT/'docs/verification/operations-comparison-bytecode.json');out=(ROOT/ledger['baseline']).parent;m=read(out/'manifest.json');v=load('comparison_retainer',OWNER/'comparison-repair-v2-retention/verify.py')
 require(sha(out/'manifest.json')==ledger['baselineSha256'] and m['status']=='passed' and all(m[k] for k in ['inputsUnchanged','toolsUnchanged','concreteToolsUnchanged']) and all(j['passed'] for j in m['checks']), 'Incomplete retained evidence')
 require(m['publicEntries']==ledger['publicEntries'] and m['assumptions']==ledger['assumptions'], 'Scope drift')
 require({str(p.relative_to(ROOT)):sha(p) for p in v.inputs()}==m['sourceSha256'], 'Current input inventory drift')
 for name,digest in m['sourceSha256'].items():require(sha(out/'source-snapshot'/name)==digest,'Snapshot drift '+name)
 require({str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='manifest.json'}==m['evidenceSha256'], 'Complete evidence file closure drift')
 require(m['proofFiles']==[str(p.relative_to(ROOT)) for p in v.PROOFS] and len(v.PROOFS)==25, 'Native graph inventory drift');closed=set()
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
 base=bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);digest=hashlib.sha256(base).hexdigest();require(digest==ledger['runtimeSha256']==read(out/'identity/identity.json')[0]['runtimeSha256'],'Runtime drift')
 receipts=read(out/'evm-traces/results.json');require(len(receipts)==140 and {(r['name'],r['ordinal']) for r in receipts}=={(n,i) for n in OPS for i in range(14)},'Physical success inventory drift')
 def intended(t,name):
  data=t['data'][2:];require(data[:8]==SELECTORS[name] and len(data)>=136,'Wrong scalar calldata admission');a,b=int(data[8:72],16),int(data[72:136],16);return a,b,format(OPS[name](a,b),'064x')
 for r in receipts:
  t=read(out/'evm-traces'/r['trace']);a,b,expected=intended(t,r['name']);require(r['passed'] and not t['candidate'] and t['runtimeSha256']==digest and t['expected']==expected,'Wrong independently computed result')
  physical(t,expected,False,read(OWNER/'comparison-repair-v2'/(r['name']+'.mapping.json')))
 rejected=read(out/'rejection-traces/results.json');require(len(rejected)==88 and all(r['passed'] for r in rejected),'Physical rejection inventory drift')
 for r in rejected:
  data=r['data'][2:];value=int(r['value'],16)
  require(value>0 if r['name']=='Nonzero' else value==0 and (len(data)//2<4 if r['name']=='Short' else data[:8]==SELECTORS[r['name'].removesuffix('Args')] and 4<=len(data)//2<68),'Wrong raw rejection admission')
  physical(read(out/'rejection-traces'/r['trace']),'',True,read(OWNER/'comparison-repair-v2/rejections'/(r['name']+'.mapping.json')))
 faults=read(out/'mutations/results.json');candidates=read(out/'candidates/inventory.json');require(len(faults)==ledger['semanticBytecodeFaults']==10 and {f['entry'] for f in faults}==set(OPS),'Semantic fault inventory drift')
 for f,c in zip(faults,candidates):
  require(all(f[k]==value for k,value in c.items()) and c['baselineSemanticSymbol'] in proved and all(j['passed'] for j in f['checks']) and (c['witnessArguments'],c['witnessOrdinal'])==WITNESSES[c['entry']],'Fault baseline closure drift')
  candidate=out/'candidates'/(c['name']+'.bin');bits=candidate.read_bytes();require(sha(candidate)==c['sha256'] and len(bits)==len(base) and [(i,a,b) for i,(a,b) in enumerate(zip(base,bits)) if a!=b]==[(c['pc'],c['oldOpcode'],c['newOpcode'])],'Wrong exact one-byte runtime mutation')
  mapping=read(OWNER/'comparison-repair-v2'/(c['entry']+'.mapping.json'));require(any(s['pc']==c['pc'] and s['opcode']==c['oldOpcode'] and sorted(s['stack'][-2:])==['a','b'] for s in mapping['states']),'Mutation is not the reached operand opcode')
  native=f['checks'][2];text=(out/native['log']).read_text();nr=list(csv.DictReader((out/'mutations'/c['name']/'proof.csv').open()));require(native['exitCode'] not in [0,None] and any(r['TestResult.Outcome']=='Failed' for r in nr) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in nr) and 'postcondition could not be proved' in text and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',text,re.I),'Nonsemantic native mutation failure')
  file=out/'mutations'/c['name']/(c['entry']+'.generated.dfy');line=f['semanticAssertion'];expected=[str(x) for x in v.common.proof_command(Path(native['command'][0]),file,out/'mutations'/c['name']/'proof.csv')]+['--filter-symbol',c['baselineSemanticSymbol'],'--filter-position',str(file)+':'+str(line['line']),'--progress','Symbol'];require(native['command']==expected,'Semantic native command/source/solver drift')
  source=(out/'mutations'/c['name']/(c['entry']+'.generated.dfy')).read_text().splitlines();line=f['semanticAssertion'];require(source[line['line']-1]==line['text'] and 'ensures state.stack[|state.stack|-2] == Result(a,b)' in line['text'] and ('requires a == '+str(c['witnessArguments'][0])+' && b == '+str(c['witnessArguments'][1])) in '\n'.join(source),'Native witness target drift')
  witnesses=[r for r in f['concreteFailures'] if r['ordinal']==c['witnessOrdinal']];require(len(witnesses)==1,'Missing matching physical witness')
  for r in f['concreteFailures']:
   t=read(out/'mutations'/c['name']/'evm-traces'/r['trace']);a,b,expected=intended(t,c['entry']);actual=t['trace']['returnValue'].removeprefix('0x');require(t['candidate'] and t['runtimeSha256']==c['sha256'] and r['expected']==expected and r['actual']==actual and actual!=expected,'False independently computed EVM counterexample');physical(t,actual,False,mapping)
   if r['ordinal']==c['witnessOrdinal']:require([a,b]==c['witnessArguments'],'Native/physical witness mismatch')
 dafny=Path(jobs['proof-OperationsComparisonMachine']['command'][0]);solc=Path(jobs['runtime-identity']['command'][4])
 for k,p in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',dafny.parent/'z3/bin/z3-4.12.1'),('solc',solc)]:require(sha(p)==m['executableSha256'][k],'Native tool drift')
 ct=m['concreteToolchain']
 for k in ['hardhatEntry','edrEntry','nativeBinding']:require(sha(Path(ct[k]))==ct[k+'Sha256'],'Concrete tool drift')
 require(sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'],'Node/lockfile drift')
 with tempfile.TemporaryDirectory(prefix='operations-comparison-check-') as tmp:
  dest=Path(tmp)
  for folder,names in [('comparison-repair-v2',v.NAMES),('comparison-repair-v2/rejections',v.REJECTIONS)]:
   target=dest/folder;subprocess.run([sys.executable,'-B',OWNER/folder/'generate.py','--output',target],check=True,stdout=subprocess.DEVNULL);subprocess.run([sys.executable,'-B',OWNER/'comparison-repair-v2/format-generated.py','--output',target,'--include-root',OWNER/folder],check=True,stdout=subprocess.DEVNULL)
   for n in names:
    for suffix in ['.generated.dfy','.mapping.json']:require((target/(n+suffix)).read_bytes()==(OWNER/folder/(n+suffix)).read_bytes(),'Generated entry drift')
  subprocess.run([sys.executable,'-B',OWNER/'comparison-repair-v2-retention/make-candidates.py','--output',dest/'candidates'],check=True,stdout=subprocess.DEVNULL);require((dest/'candidates/inventory.json').read_bytes()==(out/'candidates/inventory.json').read_bytes(),'Candidate inventory drift')
  for c in candidates:require((dest/'candidates'/(c['name']+'.bin')).read_bytes()==(out/'candidates'/(c['name']+'.bin')).read_bytes(),'Candidate byte generation drift')
  subprocess.run([sys.executable,'-B',OWNER/'identity.py','--solc',solc,'--output',dest/'identity'],check=True,stdout=subprocess.DEVNULL);require((dest/'identity/identity.json').read_bytes()==(out/'identity/identity.json').read_bytes(),'Current exact compiler identity differs')
  subprocess.run([ct['nodeExecutable'],OWNER/'check-selectors.mjs',dest/'selectors'],check=True,cwd=ROOT,stdout=subprocess.DEVNULL)
  for script,folder in [('evm-traces.mjs','success'),('rejection-traces.mjs','reject')]:subprocess.run([ct['nodeExecutable'],OWNER/'comparison-repair-v2-retention'/script,dest/folder],check=True,cwd=ROOT,stdout=subprocess.DEVNULL)
  require(len(read(dest/'success/results.json'))==140 and len(read(dest/'reject/results.json'))==88,'Fresh physical fixture inventory differs')
  for c in candidates:
   folder=dest/'fresh-mutants'/c['name'];candidate=dest/'candidates'/(c['name']+'.bin');subprocess.run([sys.executable,'-B',OWNER/'comparison-repair-v2/generate.py','--runtime',candidate,'--output',folder/'maps'],check=True,stdout=subprocess.DEVNULL)
   replay=subprocess.run([ct['nodeExecutable'],OWNER/'comparison-repair-v2-retention/evm-traces.mjs',folder/'traces',candidate],cwd=ROOT,capture_output=True,text=True)
   require(replay.returncode!=0 and 'Wrong EVM' in replay.stderr,'Fresh candidate EVM failure missing');results=read(folder/'traces/results.json');family=c.get('publicFamily',c['entry']);witnesses=[r for r in results if r['name']==family and r['ordinal']==c['witnessOrdinal'] and not r['passed']];require(len(witnesses)==1,'Fresh matching physical witness missing')
   r=witnesses[0];t=read(folder/'traces'/r['trace']);a,b,expected=intended(t,family);actual=t['trace']['returnValue'].removeprefix('0x');require([a,b]==c['witnessArguments'] and expected!=actual and t['runtimeSha256']==c['sha256'],'Fresh physical mathematical witness drift');physical(t,actual,False,read(folder/'maps'/(t.get('caseName',family)+'.mapping.json')))
 print(f'PASS: 10 Operations all-word raw comparison entries; {len(rows)} native obligations, {len(declarations)} declarations, 25 zero audits, 140 successful + 88 raw reject receipts, 10 matching native/physical semantic faults. Other entries stay open.')
if __name__=='__main__':main()
