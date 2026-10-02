#!/usr/bin/env python3
"""Independent closed retained evidence checker for all-word account-environment raw entries."""
import csv,hashlib,importlib.util,json,re,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];OWNER=Path(__file__).resolve().parent
BOUND=1<<160
SELECTORS={'Balance':'e3d670d7','CodeHash':'3dc44827'}
from Crypto.Hash import keccak
def independent_hash(code):
 h=keccak.new(digest_bits=256);h.update(bytes.fromhex(code.removeprefix('0x')));return h.hexdigest()
def observations(context):
 result={}
 for key,obs in context['observations'].items():
  account=int(key);balance=int(obs['balance'],16)
  require(0<=account<BOUND and int(obs['address'],16)==account and balance>0,'Incorrect injected existing account')
  require(obs['codeHash'].removeprefix('0x')==independent_hash(obs['code']),'Wrong independent code hash fixture')
  result[account]={'Balance':format(balance,'064x'),'CodeHash':independent_hash(obs['code'])}
 return result
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
 ledger=read(ROOT/'docs/verification/operations-account-environment-bytecode.json');out=(ROOT/ledger['baseline']).parent;m=read(out/'manifest.json');v=load('account-environment_retainer',OWNER/'account-environment-retention/verify.py')
 require(sha(out/'manifest.json')==ledger['baselineSha256'] and m['status']=='passed' and all(m[k] for k in ['inputsUnchanged','toolsUnchanged','concreteToolsUnchanged']) and all(j['passed'] for j in m['checks']), 'Incomplete retained evidence')
 require(m['publicEntries']==ledger['publicEntries'] and m['assumptions']==ledger['assumptions'], 'Scope drift')
 require({str(p.relative_to(ROOT)):sha(p) for p in v.inputs()}==m['sourceSha256'], 'Current input inventory drift')
 for name,digest in m['sourceSha256'].items():require(sha(out/'source-snapshot'/name)==digest,'Snapshot drift '+name)
 require({str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='manifest.json'}==m['evidenceSha256'], 'Complete evidence file closure drift')
 require(m['proofFiles']==[str(p.relative_to(ROOT)) for p in v.PROOFS] and len(v.PROOFS)==13, 'Native graph inventory drift');closed=set()
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
 receipts=read(out/'evm-traces/results.json');require(len(receipts)==24 and {(r['name'],r['ordinal'],r['tailOrdinal']) for r in receipts}=={(n,i,j) for n in SELECTORS for i in range(4) for j in range(3)},'Physical receipt inventory drift')
 context=observations(read(out/'evm-traces/context.json'))
 def intended(t,name,profile):
  data=t['data'][2:];require(data[:8]==SELECTORS[name] and len(data)>=72,'Wrong address calldata admission');account=int(data[8:72],16);require(account<BOUND and account in profile,'Noncanonical or unknown fixture account');return account,profile[account][name]
 for r in receipts:
  t=read(out/'evm-traces'/r['trace']);account,expected=intended(t,r['name'],context);require(r['passed'] and not t['candidate'] and t['runtimeSha256']==digest and t['expected']==expected and int(t['index'])==account,'Wrong independently computed observation')
  physical(t,expected,False,read(OWNER/'account-environment'/(r['name']+'.mapping.json')))
 rejected=read(out/'rejection-traces/results.json');require(len(rejected)==24 and all(r['passed'] for r in rejected),'Physical rejection inventory drift')
 for r in rejected:
  data=r['data'][2:];value=int(r['value'],16)
  if r['name']=='Nonzero':require(value>0,'Missing nonpayable guard')
  elif r['name']=='Short':require(value==0 and len(data)//2<4,'Wrong short selector rejection')
  elif r['name'].endswith('Args'):require(value==0 and data[:8]==SELECTORS[r['name'].removesuffix('Args')] and 4<=len(data)//2<36,'Wrong short address head')
  else:require(r['name'].endswith('BadAddress') and value==0 and data[:8]==SELECTORS[r['name'].removesuffix('BadAddress')] and len(data)//2>=36 and int(data[8:72],16)>=BOUND,'Wrong dirty-address rejection')
  physical(read(out/'rejection-traces'/r['trace']),'',True,read(OWNER/'account-environment/rejections'/(r['name']+'.mapping.json')))
 faults=read(out/'mutations/results.json');candidates=read(out/'candidates/inventory.json');require(len(faults)==ledger['semanticBytecodeFaults']==2 and {f['entry'] for f in faults}==set(SELECTORS),'Semantic fault inventory drift')
 for f,c in zip(faults,candidates):
  require(all(f[k]==value for k,value in c.items()) and c['baselineSemanticSymbol'] in proved and all(j['passed'] for j in f['checks']) and c['witnessAccount']==123 and c['witnessOrdinal']==0 and c['witnessTailOrdinal']==0 and c['worldWitness']=='Balance(world,a) != CodeHash(world,a)','Fault baseline closure drift')
  candidate=out/'candidates'/(c['name']+'.bin');bits=candidate.read_bytes();require(sha(candidate)==c['sha256'] and len(bits)==len(base) and [(i,a,b) for i,(a,b) in enumerate(zip(base,bits)) if a!=b]==[(c['pc'],c['oldOpcode'],c['newOpcode'])],'Wrong exact one-byte runtime mutation')
  mapping=read(OWNER/'account-environment'/(c['entry']+'.mapping.json'));require(any(s['pc']==c['pc'] and s['opcode']==c['oldOpcode'] and s['stack'][-1]=='Clean(a)' for s in mapping['states']),'Mutation is not the reached operand opcode')
  native=f['checks'][2];text=(out/native['log']).read_text();nr=list(csv.DictReader((out/'mutations'/c['name']/'proof.csv').open()));require(native['exitCode'] not in [0,None] and any(r['TestResult.Outcome']=='Failed' for r in nr) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in nr) and 'postcondition could not be proved' in text and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',text,re.I),'Nonsemantic native mutation failure')
  file=out/'mutations'/c['name']/(c['entry']+'.generated.dfy');line=f['semanticAssertion'];expected=[str(x) for x in v.common.proof_command(Path(native['command'][0]),file,out/'mutations'/c['name']/'proof.csv')]+['--filter-symbol',c['baselineSemanticSymbol'],'--filter-position',str(file)+':'+str(line['line']),'--progress','Symbol'];require(native['command']==expected,'Semantic native command/source/solver drift')
  source=(out/'mutations'/c['name']/(c['entry']+'.generated.dfy')).read_text().splitlines();line=f['semanticAssertion'];require(source[line['line']-1]==line['text'] and 'ensures state.stack[|state.stack|-2] == Result(world,a)' in line['text'] and 'requires Balance(world,a) != CodeHash(world,a)' in '\n'.join(source),'Native witness target drift')
  witnesses=[r for r in f['concreteFailures'] if r['ordinal']==c['witnessOrdinal'] and r['tailOrdinal']==c['witnessTailOrdinal']];require(len(witnesses)==1,'Missing matching physical witness')
  for r in f['concreteFailures']:
   t=read(out/'mutations'/c['name']/'evm-traces'/r['trace']);profile=observations(read(out/'mutations'/c['name']/'evm-traces/context.json'));account,expected=intended(t,c['entry'],profile);actual=t['trace']['returnValue'].removeprefix('0x');require(t['candidate'] and t['runtimeSha256']==c['sha256'] and r['expected']==expected and r['actual']==actual and actual!=expected,'False independently computed EVM counterexample');physical(t,actual,False,read(out/'mutations'/c['name']/(c['entry']+'.mapping.json')))
   if r['ordinal']==c['witnessOrdinal'] and r['tailOrdinal']==c['witnessTailOrdinal']:require(account==c['witnessAccount'] and profile[account]['Balance']!=profile[account]['CodeHash'],'Native/physical world witness mismatch')
 dafny=Path(jobs['proof-OperationsAccountEnvironmentMachine']['command'][0]);solc=Path(jobs['runtime-identity']['command'][4])
 for k,p in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',dafny.parent/'z3/bin/z3-4.12.1'),('solc',solc)]:require(sha(p)==m['executableSha256'][k],'Native tool drift')
 ct=m['concreteToolchain']
 for k in ['hardhatEntry','edrEntry','nativeBinding']:require(sha(Path(ct[k]))==ct[k+'Sha256'],'Concrete tool drift')
 require(sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'],'Node/lockfile drift')
 with tempfile.TemporaryDirectory(prefix='operations-account-environment-check-') as tmp:
  dest=Path(tmp)
  for folder,names in [('account-environment',v.NAMES),('account-environment/rejections',v.REJECTIONS)]:
   target=dest/folder;subprocess.run([sys.executable,'-B',OWNER/folder/'generate.py','--output',target],check=True,stdout=subprocess.DEVNULL);subprocess.run([sys.executable,'-B',OWNER/'account-environment/format-generated.py','--output',target,'--include-root',OWNER/folder],check=True,stdout=subprocess.DEVNULL)
   for n in names:
    for suffix in ['.generated.dfy','.mapping.json']:require((target/(n+suffix)).read_bytes()==(OWNER/folder/(n+suffix)).read_bytes(),'Generated entry drift')
  subprocess.run([sys.executable,'-B',OWNER/'account-environment/generate-conversion.py','--output',dest/'account-environment'],check=True,stdout=subprocess.DEVNULL);require((dest/'account-environment/Conversion.generated.dfy').read_bytes()==(OWNER/'account-environment/Conversion.generated.dfy').read_bytes(),'Conversion regeneration drift')
  subprocess.run([sys.executable,'-B',OWNER/'account-environment-retention/make-candidates.py','--output',dest/'candidates'],check=True,stdout=subprocess.DEVNULL);require((dest/'candidates/inventory.json').read_bytes()==(out/'candidates/inventory.json').read_bytes(),'Candidate inventory drift')
  for c in candidates:require((dest/'candidates'/(c['name']+'.bin')).read_bytes()==(out/'candidates'/(c['name']+'.bin')).read_bytes(),'Candidate byte generation drift')
  subprocess.run([sys.executable,'-B',OWNER/'identity.py','--solc',solc,'--output',dest/'identity'],check=True,stdout=subprocess.DEVNULL);require((dest/'identity/identity.json').read_bytes()==(out/'identity/identity.json').read_bytes(),'Current exact compiler identity differs')
  subprocess.run([ct['nodeExecutable'],OWNER/'check-selectors.mjs',dest/'selectors'],check=True,cwd=ROOT,stdout=subprocess.DEVNULL)
  for script,folder in [('success-traces.mjs','success'),('rejection-traces.mjs','reject')]:subprocess.run([ct['nodeExecutable'],OWNER/'account-environment-retention'/script,dest/folder],check=True,cwd=ROOT,stdout=subprocess.DEVNULL)
  require(len(read(dest/'success/results.json'))==24 and len(read(dest/'reject/results.json'))==24,'Fresh physical fixture inventory differs')
  for c in candidates:
   folder=dest/'fresh-mutants'/c['name'];candidate=dest/'candidates'/(c['name']+'.bin');subprocess.run([sys.executable,'-B',OWNER/'account-environment/generate.py','--runtime',candidate,'--output',folder/'maps'],check=True,stdout=subprocess.DEVNULL)
   replay=subprocess.run([ct['nodeExecutable'],OWNER/'account-environment-retention/success-traces.mjs',folder/'traces',candidate],cwd=ROOT,capture_output=True,text=True)
   require(replay.returncode!=0 and 'Wrong EVM' in replay.stderr,'Fresh candidate EVM failure missing');results=read(folder/'traces/results.json');family=c.get('publicFamily',c['entry']);witnesses=[r for r in results if r['name']==family and r['ordinal']==c['witnessOrdinal'] and r['tailOrdinal']==c['witnessTailOrdinal'] and not r['passed']];require(len(witnesses)==1,'Fresh matching physical witness missing')
   r=witnesses[0];t=read(folder/'traces'/r['trace']);profile=observations(read(folder/'traces/context.json'));account,expected=intended(t,family,profile);actual=t['trace']['returnValue'].removeprefix('0x');require(account==c['witnessAccount'] and profile[account]['Balance']!=profile[account]['CodeHash'] and expected!=actual and t['runtimeSha256']==c['sha256'],'Fresh physical mathematical witness drift');physical(t,actual,False,read(folder/'maps'/(t.get('caseName',family)+'.mapping.json')))
 print(f'PASS: 2 Operations account observation raw entries; {len(rows)} native obligations, {len(declarations)} declarations, 13 zero audits, 24 successful + 24 raw reject receipts, 2 matching native/physical semantic faults. Other entries stay open.')
if __name__=='__main__':main()
