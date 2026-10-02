#!/usr/bin/env python3
"""Independently recheck complete retained current mapWords/filterWords evidence."""
import csv,hashlib,importlib.util,json,re,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,message):
 if not ok:raise SystemExit(message)
def load(name,p):
 s=importlib.util.spec_from_file_location(name,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
if not __debug__:raise RuntimeError('Run without Python -O')
ledger=json.loads((ROOT/'docs/verification/map-filter-words-bytecode.json').read_text());path=ROOT/ledger['baseline'];out=path.parent
require(sha(path)==ledger['baselineSha256'],'Manifest drift');m=json.loads(path.read_text());package=ROOT/ledger['package'];v=load('map_filter_retained_checker',package/'verify.py');spec=json.loads((package/'proof-spec.json').read_text())
require(m['status']=='passed' and all(m[k] for k in ['inputsUnchanged','dependenciesUnchanged','toolsUnchanged','concreteToolsUnchanged','priorManifestUnchanged']) and all(j['passed'] for j in m['checks']),'Incomplete retained evidence')
require(m['scope']==ledger['scope']==spec['scope'] and m['assumptions']==ledger['assumptions']==spec['assumptions'] and m['publicEntries']==ledger['publicEntries']==spec['publicEntries'],'Scope drift')
inputs={str(p.relative_to(ROOT)):sha(p) for p in v.inputs(spec)};require(inputs==m['sourceSha256'],'Current input inventory drift')
for name,digest in inputs.items():require(sha(out/'source-snapshot'/name)==digest,'Snapshot drift '+name)
for name,digest in m['evidenceSha256'].items():require(sha(out/name)==digest,'Evidence drift '+name)
require(v.dependencies()==m['dependencyEvidenceSha256'],'Retained dependency drift')
graph=v.graph(spec);require({str(p.relative_to(ROOT)):sha(p) for p in graph}==m['dependencyGraph'] and m['rootProofs']==spec['rootProofs']==ledger['rootProofs'],'Proof graph drift')
module_files=[p for p in graph if re.search(r'^module (\w+)',p.read_text(),re.M)];require(len(module_files)==207 and [str(p.relative_to(ROOT)) for p in graph if p not in module_files]==m['includeOnlyFiles'],'Native graph inventory drift')
prior=ROOT/m['priorNativeEvidence']['manifest'];repair=ROOT/m['priorRepairEvidence']['manifest'];old=json.loads(prior.read_text());fixed=json.loads(repair.read_text())
require(sha(prior)==m['priorNativeEvidence']['manifestSha256']==sha(out/'prior-native/manifest.json') and old['status']=='failed' and old['completedAt'],'Prior terminal provenance drift')
require(sha(repair)==m['priorRepairEvidence']['manifestSha256']==sha(out/'prior-repair/manifest.json') and fixed['status']=='development-native-passed-not-retained' and fixed['inputsUnchanged'] and fixed['toolsUnchanged'] and all(j['passed'] for j in fixed['checks']),'Completed repair provenance drift')
require(old['dependencyGraph']==m['dependencyGraph'] and old['rootProofs']==m['rootProofs'] and old['scope']==m['scope'] and old['assumptions']==m['assumptions'],'Original full native graph differs')
require({j['name'] for j in old['checks'] if not j['passed']}=={'proof-BytecodeApplyRawSuccessfulEntry','proof-BytecodeApplyRawTemplateCopy'},'Unexpected original failure')
for parent,manifest in [(prior,old),(repair,fixed)]:
 for name,digest in manifest['sourceSha256'].items():require(sha(ROOT/name)==digest==sha(parent.parent/'source-snapshot'/name),'Cached proof current/historical input drift '+name)
for key,digest in old['executableSha256'].items():require(digest==m['executableSha256'][key],'Original tool drift')
for key,digest in fixed['executableSha256'].items():require(digest==m['executableSha256'][key],'Repair tool drift')
jobs={j['name']:j for j in m['checks']};require(len(jobs)==len(m['checks']),'Duplicate retained check names')
rows=[];declarations=[];origins={'original':0,'repair':0}
for source in module_files:
 mod=re.search(r'^module (\w+)',source.read_text(),re.M)[1];name='proof-'+mod;job=jobs[name]
 if job['nativeEvidenceOrigin']=='reused-completed-whole-module-identical-full-input-closure':
  parent,manifest,limit=prior,old,'30';origins['original']+=1
  require(job['priorManifest']==str(prior.relative_to(ROOT)) and job['priorManifestSha256']==sha(prior),'Native original provenance drift')
 elif job['nativeEvidenceOrigin']=='reused-completed-unchanged-120-second-repair-module-identical-current-include-closure':
  parent,manifest,limit=repair,fixed,'120';origins['repair']+=1
  require(job['priorRepairManifest']==str(repair.relative_to(ROOT)) and job['priorRepairManifestSha256']==sha(repair),'Native repair provenance drift')
 else:raise SystemExit('Unrecognized native evidence origin')
 original=next(j for j in manifest['checks'] if j['name']==name);require(original['passed'] and original['exitCode']==0 and original['nativeResults']==job['nativeResults'] and original['declarations']==job['declarations'],'Native parent result drift '+mod)
 historical=parent.parent/'source-snapshot'/source.relative_to(ROOT);old_csv=parent.parent/(name+'.csv');old_log=parent.parent/original['log']
 expected=v.common.proof_command(Path(job['command'][0]),historical,old_csv);expected[expected.index('--verification-time-limit')+1]=limit;expected+=['--filter-symbol',mod,'--filter-position',str(historical),'--progress','Symbol']
 require(job['command']==list(map(str,expected))==original['command'],'Incomplete native command '+mod)
 require(sha(old_log)==manifest['evidenceSha256'][old_log.name]==job['priorLogSha256']==sha(out/(name+'.log')) and sha(old_csv)==manifest['evidenceSha256'][old_csv.name]==job['priorCsvSha256']==sha(out/(name+'.csv')),'Native log/CSV provenance drift '+mod)
 checked=dict(job);v.common.check_proof(checked,out/(name+'.log'),out/(name+'.csv'),v.getter.inventory(source));require(checked['passed'] and checked['nativeResults']==job['nativeResults'] and checked['declarations']==job['declarations'],'Incomplete native inventory '+mod)
 rows+=job['nativeResults'];declarations+=job['declarations']
require(origins=={'original':205,'repair':2} and rows==m['nativeResults'] and declarations==m['declarationResults'] and len(rows)==m['nativeObligations']==ledger['nativeObligations'] and len(declarations)==ledger['nativeDeclarations'],'Aggregate native/provenance drift')
proved={d['name'] for d in declarations if d['status']=='passed'};require(all(t in proved for t in ledger['connections']),'Unproved required connection')
for source in spec['rootProofs']:
 name='audit-'+Path(source).parent.name;job=jobs[name];require(job['exitCode']==0 and job['passed'] and 'auditor completed with 0 findings' in (out/job['log']).read_text(),'Audit findings '+name)
base=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);base_hash=hashlib.sha256(base).hexdigest()
all_receipts=[]
for suite,count in [('evm-traces',138),('guard-traces',12)]:
 receipts=json.loads((out/suite/'results.json').read_text());require(len(receipts)==count and [r['name'] for r in receipts]==ledger['fixtureNames'][suite],'Fixture inventory drift '+suite)
 for r in receipts:
  t=json.loads((out/suite/r['trace']).read_text());trace=t['trace'];logs=trace['structLogs'];roots=[x for x in logs if x['depth']==1]
  require(r['passed'] and r['receiptPassed'] and not r['errors'] and r['runtimeSha256']==t['runtimeSha256']==t['baselineRuntimeSha256']==base_hash and trace['failed']==r['expectedFailed'] and trace['returnValue'].removeprefix('0x')==r['expectedBytes']==r['actualBytes'],'Wrong complete physical receipt')
  require(logs[0]['pc']==0 and logs[0]['depth']==1 and roots[-1]==logs[-1],'Incomplete root physical trace')
  last=roots[-1];off,size=int(last['stack'][-1],16),int(last['stack'][-2],16);memory=''.join(x.removeprefix('0x') for x in last['memory'])
  require(last['op']==('REVERT' if trace['failed'] else 'RETURN') and size==len(r['expectedBytes'])//2 and memory[off*2:(off+size)*2]==r['expectedBytes'],'Incorrect final memory slice')
 all_receipts+=receipts
require(len(all_receipts)==ledger['concreteFixtures'] and len({r['name'] for r in all_receipts})==150,'Duplicated physical fixture names')
faults=json.loads((out/'mutations/results.json').read_text());require(len(faults)==ledger['semanticBytecodeFaults']==3 and [f['candidate']['name'] for f in faults]==ledger['faultNames'],'Semantic fault inventory drift')
for fault in faults:
 c=fault['candidate'];candidate=(out/'candidates'/c['runtime']).read_bytes();require(hashlib.sha256(candidate).hexdigest()==c['runtimeSha256'] and c['baselineRuntimeSha256']==base_hash and len(candidate)==len(base) and [(i,a,b) for i,(a,b) in enumerate(zip(base,candidate)) if a!=b]==[(c['byteOffset'],c['before'],c['after'])],'Binary fault drift')
 require(fault['baselineCoveredSymbol']==c['nativeSymbol'] and c['nativeSymbol'] in proved and all(j['passed'] for j in fault['checks']),'Uncovered semantic fault')
 native=fault['checks'][1];body=(out/native['log']).read_text();native_rows=list(csv.DictReader((out/'mutations'/c['name']/'proof.csv').open()))
 require(native['exitCode'] not in [0,None] and any(r['TestResult.Outcome']=='Failed' for r in native_rows) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in native_rows) and 'postcondition could not be proved' in body and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',body,re.I),'Non-semantic native fault')
 file=out/'mutations'/c['name']/'source-snapshot'/c['package']/c['source'];anchor=fault['semanticAssertion'];require(file.read_text().splitlines()[anchor['line']-1]==anchor['text'],'Native semantic anchor drift')
 require(len(fault['contradictoryReceipts'])==1,'Missing actual fault counterexample');r=fault['contradictoryReceipts'][0];t=json.loads((out/'mutations'/c['name']/'evm-traces'/r['trace']).read_text());require(t['runtimeSha256']==c['runtimeSha256'] and not r['receiptPassed'] and r['name']==c['evmFixture'] and (t['trace']['failed']!=r['expectedFailed'] or t['trace']['returnValue'].removeprefix('0x')!=r['expectedBytes']),'False physical fault counterexample')
dafny=Path(next(j['command'][0] for j in m['checks'] if j['name'].startswith('proof-')));solc=Path(jobs['runtime-identity']['command'][4])
for key,p in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',dafny.parent/'z3/bin/z3-4.12.1'),('solc',solc)]:require(sha(p)==m['executableSha256'][key],'Proof/compiler tool drift')
ct=m['concreteToolchain']
for key in ['hardhatEntry','edrEntry','nativeBinding']:require(sha(Path(ct[key]))==ct[key+'Sha256'],'Concrete tool drift')
require(sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'],'Node/lockfile drift')
with tempfile.TemporaryDirectory(prefix='map-filter-independent-check-') as directory:
 dest=Path(directory);require(m['generatorGroups']==ledger['generatorGroups'],'Generator inventory drift')
 actual=[]
 for folder in sorted({p.parent for p in graph if p.name.endswith('.generated.dfy')}):actual.append([str(folder.relative_to(ROOT)),sorted(p.name for p in folder.glob('generate*.py'))])
 require(actual==m['generatorGroups'],'Current generator ownership drift')
 for owner,generators in actual:
  folder=ROOT/owner;generated=dest/'generated'/owner;generated.mkdir(parents=True)
  for generator in generators:subprocess.run([sys.executable,'-B',folder/generator,'--output',generated],check=True,stdout=subprocess.DEVNULL)
  names={p.name for p in folder.iterdir() if p.is_file() and p.name.endswith(('.generated.dfy','.mapping.json'))};require(names=={p.name for p in generated.iterdir()} and all((folder/name).read_bytes()==(generated/name).read_bytes() for name in names),'Generation drift '+owner)
 for generator,owner,files in [('generate-predicate-candidate.py','predicate-error-repair-v3',['Predicate.generated.dfy','Predicate.mapping.json']),('generate-serializer-candidate.py','serializer-repair-v2',['Control.generated.dfy','Control.mapping.json'])]:
  generated=dest/generator;subprocess.run([sys.executable,'-B',package/generator,'--output',generated],check=True,stdout=subprocess.DEVNULL);require(all((ROOT/'formal/bytecode/word-apply'/owner/name).read_bytes()==(generated/name).read_bytes() for name in files),'Current semantic parser baseline differs')
 subprocess.run([sys.executable,'-B',package/'make-candidates.py','--output',dest/'candidates'],check=True,stdout=subprocess.DEVNULL);require((dest/'candidates/candidates.json').read_bytes()==(out/'candidates/candidates.json').read_bytes(),'Current candidate inventory differs')
 for f in faults:require((dest/'candidates'/f['candidate']['runtime']).read_bytes()==(out/'candidates'/f['candidate']['runtime']).read_bytes(),'Current fault extraction differs')
 subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/dispatch/identity.py','--solc',solc,'--output',dest/'identity'],check=True,stdout=subprocess.DEVNULL);require((dest/'identity/identity.json').read_bytes()==(out/'identity/identity.json').read_bytes(),'Current runtime identity differs')
 for script,suite,extra in [('evm-traces.mjs','evm-traces',[]),('guard-traces.mjs','guard-traces',['--suite','guard'])]:
  target=dest/suite;subprocess.run([ct['nodeExecutable'],package/script,'--output',target,'--root',ROOT,*extra],check=True,stdout=subprocess.DEVNULL);require((target/'results.json').read_bytes()==(out/suite/'results.json').read_bytes(),'Independent current physical replay differs '+suite)
 for fault in faults:
  c=fault['candidate'];target=dest/'faults'/c['name'];result=subprocess.run([ct['nodeExecutable'],package/'evm-traces.mjs','--output',target,'--root',ROOT,'--runtime',dest/'candidates'/c['runtime'],'--case',c['evmFixture']],stdout=subprocess.DEVNULL,stderr=subprocess.PIPE,text=True)
  require(result.returncode!=0 and json.loads((target/'results.json').read_text())==fault['contradictoryReceipts'],'Independent semantic counterexample differs')
subprocess.run([sys.executable,'-B',ROOT/'scripts/check-raw-rejections-bytecode-evidence.py'],check=True,stdout=subprocess.DEVNULL)
require(inputs=={str(p.relative_to(ROOT)):sha(p) for p in v.inputs(spec)} and sha(path)==ledger['baselineSha256'],'Inputs changed during independent replay')
print('PASS: mapWords/filterWords complete current retained evidence;207 whole native modules,180375 obligations,5751 declarations,11 zero audits,150 complete physical receipts,3 matching native/physical semantic faults; source/compiler/tool/snapshot/dependency/provenance and fresh independent generation/runtime/physical replay checked. Whole-contract bytecode remains open.')
