#!/usr/bin/env python3
"""Independent retained current-runtime square-root closure and physical replay."""
import csv,hashlib,importlib.util,json,re,shutil,subprocess,sys,tempfile
from pathlib import Path
if not __debug__:raise RuntimeError('Run without Python -O')
OWNER=Path(__file__).resolve().parent;ROOT=OWNER.parents[2]
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
v=load('sqrt_retainer',OWNER/'sqrt-retention-v3/verify.py');common=v.common;sha=v.sha
def read(p):return json.loads(p.read_text())
def require(ok,message):
 if not ok:raise RuntimeError(message)
def main():
 ledger=read(ROOT/'docs/verification/operations-sqrt-bytecode-v3.json');out=(ROOT/ledger['baseline']).parent;m=read(out/'manifest.json');checks={j['name']:j for j in m['checks']};snap=out/'source-snapshot'
 require(sha(out/'manifest.json')==ledger['baselineSha256'] and m['status']=='passed','Incomplete or drifting manifest')
 require(m['publicEntries']==ledger['publicEntries']==['Operations.sqrt(uint256)'] and m['assumptions']==ledger['assumptions'],'Public scope drift')
 require(m['nativeWholeModuleWatchdogSeconds']==7200 and m['nativeObligationTimeLimitSeconds']==30,'Native limit policy drift')
 require(all(m[k] for k in ['inputsUnchanged','toolsUnchanged','concreteToolsUnchanged']) and all(j['passed'] for j in m['checks']),'Required retained gate did not pass')
 current={str(f.relative_to(ROOT)):sha(f) for f in v.inputs()};require(current==m['sourceSha256'],'Current complete input closure drift')
 require(all(sha(snap/p)==h for p,h in current.items()),'Source snapshot drift')
 require(m['evidenceSha256']=={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'},'Evidence closure drift')
 tools={'dafny':Path('/tmp/assertions-dafny-4.11.0/dafny/dafny'),'Dafny.dll':Path('/tmp/assertions-dafny-4.11.0/dafny/Dafny.dll'),'z3':Path('/tmp/assertions-dafny-4.11.0/dafny/z3/bin/z3-4.12.1'),'solc':Path('/home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791')}
 require(m['executableSha256']=={k:sha(f) for k,f in tools.items()},'Native tool drift')
 require(m['versions']=={k:subprocess.check_output([str(tools[k]),'--version'],text=True).strip() for k in ['dafny','z3','solc']},'Native version drift')
 require(m['proofFiles']==[str(f.relative_to(ROOT)) for f in v.PROOFS] and len(v.PROOFS)==46,'Complete native graph inventory drift')
 closed=set()
 def visit(f):
  f=f.resolve();require(f in v.PROOFS,'Missing included native declaration owner')
  if f in closed:return
  closed.add(f)
  for name in re.findall(r'^include "([^"]+)"',f.read_text(),re.M):visit(f.parent/name)
 for f in v.PROOFS:visit(f)
 require(closed==set(v.PROOFS),'Native include closure mismatch')
 allrows=[];alldecl=[]
 for f in v.PROOFS:
  symbol=re.search(r'^module (\w+)',f.read_text(),re.M)[1];j=checks['proof-'+symbol];sf=snap/f.relative_to(ROOT);csvpath=out/(symbol+'.csv')
  expected=[str(x) for x in common.proof_command(tools['dafny'],sf,csvpath)]+['--filter-symbol',symbol,'--filter-position',str(sf),'--progress','Symbol'];require(j['command']==expected and j['exitCode']==0,'Native command/scope drift')
  actual=dict(j);common.check_proof(actual,out/('proof-'+symbol+'.log'),csvpath,v.inventory(f));require(actual['passed'] and actual['nativeResults']==j['nativeResults'] and actual['declarations']==j['declarations'],'Native inventory/log/CSV mismatch')
  allrows+=actual['nativeResults'];alldecl+=actual['declarations'];audit=checks['audit-'+symbol];require(audit['exitCode']==0 and audit['command']==[str(tools['dafny']),'audit',str(sf)] and 'auditor completed with 0 findings' in (out/('audit-'+symbol+'.log')).read_text(),'Native audit gap')
 require(allrows==m['nativeResults'] and alldecl==m['declarationResults'] and len(allrows)==ledger['nativeObligations'] and len(alldecl)==ledger['nativeDeclarations'],'Native aggregate drift')
 proved={d['name'] for d in alldecl if d['status']=='passed'};require(ledger['connections']==['OperationsSquareRootFull.Run'] and all(n in proved for n in ledger['connections']),'Missing full public raw theorem')
 raw=bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);digest=hashlib.sha256(raw).hexdigest();identity=read(out/'identity/identity.json')[0]
 require(digest==ledger['runtimeSha256']==identity['runtimeSha256'] and identity['methodIdentifiers']['sqrt(uint256)']=='677342ce','Runtime/compiler/selector drift')
 baseline=read(out/'evm-traces/results.json');require(len(baseline)==167 and all(r['passed'] for r in baseline) and sum(r['reason']=='Success' for r in baseline)==158 and sum(r['reason']!='Success' for r in baseline)==9,'Physical baseline partition drift')
 require(ledger['concreteSuccessReceipts']==158 and ledger['concreteRejectionReceipts']==9 and ledger.get('concretePanicReceipts',0)==0 and ledger.get('concreteCustomErrorReceipts',0)==0,'Ledger physical partition drift')
 ct=m['concreteToolchain'];require(sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and all(sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['hardhatEntry','edrEntry','nativeBinding','viemEntry']) and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'],'Concrete tool graph drift')
 faults=read(out/'mutations/results.json');require(len(faults)==ledger['semanticBytecodeFaults']==1,'Mutation inventory drift')
 for f in faults:
  name=f['name'];folder=out/'mutations'/name;candidate=out/'candidates'/(name+'.bin');code=candidate.read_bytes();require(len(code)==len(raw) and [i for i,(a,b) in enumerate(zip(raw,code)) if a!=b]==[11298] and raw[11298]==4 and code[11298]==2 and sha(candidate)==f['runtimeSha256'],'Not the intended actual one-byte opcode mutation')
  require(f['passed'] and f['baselineSemanticSymbol']=='OperationsSquareRootNewton0.SemanticWitness' and f['baselineSemanticSymbol'] in proved and f['witnessOrdinal']==20,'Missing baseline-covered matching witness')
  file=folder/'source-snapshot'/v.OWNER.relative_to(ROOT)/'sqrt-newton-controls/Newton0.generated.dfy';native=checks[name+'-native'];expected=[str(x) for x in common.proof_command(tools['dafny'],file,folder/'proof.csv')]+['--filter-symbol',f['baselineSemanticSymbol'],'--filter-position',str(file)+':'+str(f['nativeAnchorLine']),'--progress','Symbol'];require(native['command']==expected,'Native mutation scope drift')
  lines=file.read_text().splitlines();require(re.search(r'ensures state\.stack\[\|state\.stack\|-1\]\s*==\s*11',lines[f['nativeAnchorLine']-1]),'Wrong mutation property anchor')
  rows=list(csv.DictReader((folder/'proof.csv').open()));log=(out/(name+'-native.log')).read_text();require(rows==f['nativeResults'] and native['exitCode'] not in [0,None] and any(r['TestResult.Outcome']=='Failed' for r in rows) and all(r['TestResult.Outcome'] in ['Passed','Failed'] for r in rows) and 'a postcondition could not be proved' in log and not re.search(r'timed out|timeout|resolution/type errors|precondition could not be proved',log,re.I),'Mutation was not a semantic postcondition contradiction')
  mutable={str((v.OWNER/'sqrt-newton-controls'/('Newton'+str(i)+'.generated.dfy')).relative_to(ROOT)) for i in range(6)}|{str((v.OWNER/'sqrt-newton-controls/newton.mapping.json').relative_to(ROOT))}
  require(all(p in mutable or sha(folder/'source-snapshot'/p)==h for p,h in current.items()),'Mutation changed an unrelated trusted input')
  physical=read(folder/'evm-traces/results.json');witness=physical[20];require(len(physical)==167 and witness['ordinal']==20 and witness['expected']==f['expected']==(11).to_bytes(32,'big').hex() and witness['actual']==f['actual']==(23).to_bytes(32,'big').hex() and not witness['passed'],'Missing matching full physical wrong result')
  trace=read(folder/'evm-traces'/witness['trace']);checkpoint=next(s for s in trace['trace']['structLogs'] if s['pc']==11305);require(int(trace['model']['input'])==123 and int(checkpoint['stack'][-1],16)==744,'Native/physical checkpoint mismatch')
 subprocess.run([sys.executable,'-B',OWNER/'sqrt-retention-v3/check-physical.py',out/'evm-traces'],check=True,cwd=ROOT)
 for f in faults:subprocess.run([sys.executable,'-B',OWNER/'sqrt-retention-v3/check-physical.py',out/'mutations'/f['name']/'evm-traces','--runtime',out/'candidates'/(f['name']+'.bin'),'--expect-fault'],check=True,cwd=ROOT)
 with tempfile.TemporaryDirectory(prefix='operations-sqrt-independent-') as directory:
  dest=Path(directory);records=[]
  def record(name,cmd,timeout=180):
   j=common.run(cmd,dest/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);records.append(j);return j
  require(v.regenerate(v.OWNER,dest,record),'Fresh complete generation drift')
  for folder,_ in v.GENERATORS:
   generated=dest/('generated-'+folder);require(all((v.OWNER/folder/f.name).read_bytes()==f.read_bytes() for f in generated.iterdir() if f.is_file()),'Generated current owner drift')
  subprocess.run([sys.executable,'-B',v.OWNER/'identity.py','--solc',tools['solc'],'--output',dest/'identity'],check=True,cwd=ROOT,stdout=subprocess.DEVNULL);require(read(dest/'identity/identity.json')==read(out/'identity/identity.json'),'Fresh compiler/runtime identity drift')
  subprocess.run([sys.executable,'-B',OWNER/'sqrt-retention-v3/make-candidates.py','--output',dest/'candidates'],check=True,stdout=subprocess.DEVNULL);require((dest/'candidates/inventory.json').read_bytes()==(out/'candidates/inventory.json').read_bytes(),'Candidate inventory regeneration drift')
  subprocess.run([ct['nodeExecutable'],OWNER/'sqrt-retention-v3/evm-traces.mjs',dest/'baseline'],check=True,cwd=ROOT,stdout=subprocess.DEVNULL);subprocess.run([sys.executable,'-B',OWNER/'sqrt-retention-v3/check-physical.py',dest/'baseline'],check=True,cwd=ROOT)
  for f in faults:
   target=dest/f['name'];candidate=out/'candidates'/(f['name']+'.bin')
   clone=dest/(f['name']+'-source-snapshot');shutil.copytree(snap,clone);owner=clone/OWNER.relative_to(ROOT)/'sqrt-newton-controls'
   subprocess.run([sys.executable,'-B',owner/'generate.py','--runtime',candidate,'--output',owner],check=True,cwd=ROOT,stdout=subprocess.DEVNULL)
   subprocess.run([sys.executable,'-B',owner/'format-generated.py','--output',owner,'--include-root',owner],check=True,cwd=ROOT,stdout=subprocess.DEVNULL)
   retained=out/'mutations'/f['name']/'source-snapshot'/OWNER.relative_to(ROOT)/'sqrt-newton-controls'
   require(all((retained/file.name).read_bytes()==file.read_bytes() for file in owner.iterdir() if file.is_file()),'Fresh semantic candidate extraction drift')
   fault=subprocess.run([ct['nodeExecutable'],OWNER/'sqrt-retention-v3/evm-traces.mjs',target,candidate],cwd=ROOT,capture_output=True,text=True);require(fault.returncode!=0 and 'Wrong physical sqrt receipt' in fault.stderr,'Fresh complete physical mutation not rejected');subprocess.run([sys.executable,'-B',OWNER/'sqrt-retention-v3/check-physical.py',target,'--runtime',candidate,'--expect-fault'],check=True,cwd=ROOT)
 print('PASS complete current exact sqrt entry: '+str(len(allrows))+' obligations/'+str(len(alldecl))+' declarations/46 zero audits/158 success+9 raw/one matching native and physical semantic fault; explicit representation, interpretation and resource premises; no gas/deployment/performance claim')
if __name__=='__main__':main()
