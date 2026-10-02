#!/usr/bin/env python3
"""Complete retained raw charset entry; finish before snapshot."""
import argparse,csv,datetime,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
if not __debug__:raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];OWNER=HERE.parent
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
workflow=load('charset_full_development',OWNER/'charset-full/verify-development.py');common=workflow.common;identity=workflow.identity;PROOFS=list(workflow.PROOFS);inventory=workflow.inventory;sha=common.sha
for folder in ['charset-mutation']:
 file=OWNER/folder/'Witness.generated.dfy';assert all((file.parent/n).resolve() in PROOFS for n in re.findall(r'^include "([^"]+)"',file.read_text(),re.M));PROOFS.append(file)
def inputs():
 return sorted(set(workflow.inputs())|{f for folder in [HERE,OWNER/'charset-mutation'] for f in folder.iterdir() if f.is_file()}|{ROOT/'formal/bytecode/word-apply/map-prefix/format-generated.py',OWNER/'inventory.py',OWNER/'check-charset-evidence.py'})
GENERATORS=[('charset-preparation','generate-source-gate.py'),('charset-raw','generate.py'),('charset-controls','generate.py'),('charset-mutation','generate.py')]
def regenerate(source,out,record):
 checks=[]
 for folder,script in GENERATORS:
  owner=source/folder;generated=out/('generated-'+folder)
  gen=record('generation-'+folder,[sys.executable,'-B',owner/script,'--output',generated],180)
  gen['passed']=gen['passed'] and all((owner/f.name).read_bytes()==f.read_bytes() for f in generated.iterdir() if f.is_file());checks.append(gen)
 for rel,name,file in [('word-apply/word-conversion','conversion','Conversion.generated.dfy'),('word-fold/byte-representation-repair-v8','first-byte-shift','Shift.generated.dfy')]:
  owner=source.parent/rel;gen=record('generation-'+name,[sys.executable,'-B',owner/'generate.py','--output',out/name],180)
  gen['passed']=gen['passed'] and (owner/file).read_bytes()==(out/name/file).read_bytes();checks.append(gen)
 return all(j['passed'] for j in checks)
def main():
 p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 assert len(PROOFS)==32
 closed=set()
 def visit(f):
  f=f.resolve();assert f in PROOFS
  if f in closed:return
  closed.add(f)
  for n in re.findall(r'^include "([^"]+)"',f.read_text(),re.M):visit(f.parent/n)
 for f in PROOFS:visit(f)
 assert closed==set(PROOFS)
 dafny=a.dafny.resolve();z3=dafny.parent/'z3/bin/z3-4.12.1';solc=a.solc.resolve();tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':z3,'solc':solc}
 versions={k:subprocess.check_output([str(tools[k]),'--version'],text=True).strip() for k in ['dafny','z3','solc']}
 assert versions['dafny']==json.load(open(ROOT/'formal/abi/toolchain.json'))['dafnyVersion'] and '4.12.1' in versions['z3'] and '0.8.36+commit.8a079791' in versions['solc']
 files=inputs();hashes={str(f.relative_to(ROOT)):sha(f) for f in files};snap=out/'source-snapshot'
 for f in files:
  d=snap/f.relative_to(ROOT);d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,d)
 source=snap/OWNER.relative_to(ROOT)
 m={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Complete32-module raw charset retention: complete31-module raw admission, original-byte membership induction, full fitting memory and exact canonical32-byte scalar BOOL RETURN graph plus matching reached AND semantic witness. All ordered raw rejections and accepted byte offsets connect to independent original-byte set membership. No gas, deployment or performance claim','publicEntries':['Operations.charset(bytes,uint256)'],'sourceSha256':hashes,'versions':versions,'executableSha256':{k:sha(f) for k,f in tools.items()},'nativeWholeModuleWatchdogSeconds':7200,'nativeObligationTimeLimitSeconds':30,'proofFiles':[str(f.relative_to(ROOT)) for f in PROOFS],'checks':[],'assumptions':['Exact current compiler/runtime/selector extraction and reviewed complete reached instruction-boundary scanner. No compiler correctness shortcut replaces executed instructions.','Complete original finite calldata below2^64 with actual zero-padded word observations, truthful call value, fresh zero byte memory and sufficient reached stack/memory/instruction resources. No gas cost/availability, deployment or performance theorem.','Reviewed normative unsigned integer EVM word interpretation: arithmetic modulo2^256, quotient SHR/DIV, multiplication-by-power SHL, actual byte stores/loads and genuine jumped instruction traces. No equivalence to another interpreter or library correctness premise is assumed.','Dafny/Boogie/Z3 and reviewed evidence tooling are trusted; source proofs and finite fixtures do not replace native exact-opcode correspondence.']}
 def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
 def record(name,cmd,timeout=1800):
  j=common.run(cmd,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
 save();gate=record('format-before',[dafny,'format','--check',*[snap/f.relative_to(ROOT) for f in PROOFS]],180)
 if not gate['passed']:m['status']='failed-format-gate';save();raise SystemExit(1)
 ident=record('runtime-identity',[sys.executable,'-B',source/'identity.py','--solc',solc,'--output',out/'identity'],240);generated=regenerate(source,out,record);save()
 if not ident['passed'] or not generated:m['status']='failed-identity-regeneration-gate';save();raise SystemExit(1)
 def required_failure(name,proofjobs):
  m['status']='failed-required-native-gate';m['failedRequiredGate']=name
  m['nativeResults']=[r for j in proofjobs for r in j.get('nativeResults',[])]
  m['declarationResults']=[d for j in proofjobs for d in j.get('declarations',[])]
  m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()}
  m['toolsUnchanged']=m['executableSha256']=={k:sha(f) for k,f in tools.items()}
  m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
  m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'}
  save();raise SystemExit(1)
 proofjobs=[]
 for f in PROOFS:
  symbol=re.search(r'^module (\w+)',f.read_text(),re.M)[1];sf=snap/f.relative_to(ROOT);csvpath=out/(symbol+'.csv')
  j=record('proof-'+symbol,common.proof_command(dafny,sf,csvpath)+['--filter-symbol',symbol,'--filter-position',str(sf),'--progress','Symbol'],7200);common.check_proof(j,out/('proof-'+symbol+'.log'),csvpath,inventory(f));proofjobs.append(j);save()
  if not j['passed']:required_failure(j['name'],proofjobs)
  audit=record('audit-'+symbol,[dafny,'audit',sf],180);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/('audit-'+symbol+'.log')).read_text();save()
  if not audit['passed']:required_failure(audit['name'],proofjobs)
 script=source/'charset-retention'
 concrete=record('concrete',[shutil.which('node'),script/'evm-traces.mjs',out/'evm-traces'],180);rows=json.loads((out/'evm-traces/results.json').read_text()) if (out/'evm-traces/results.json').exists() else []
 concrete['passed']=concrete['passed'] and len(rows)==81 and all(r['passed'] for r in rows) and {r['ordinal'] for r in rows}==set(range(81));save()
 record('concrete-raw-mapping',[sys.executable,'-B',source/'charset-raw/check-mapping.py',out/'evm-traces'],180)
 record('concrete-body-mapping',[sys.executable,'-B',source/'charset-controls/check-mapping.py',out/'evm-traces'],180)
 record('concrete-independent',[sys.executable,'-B',script/'check-physical.py',out/'evm-traces'],180);ct=json.loads((out/'evm-traces/toolchain.json').read_text());m['concreteToolchain']=ct;save()
 faults=[]
 configs=[dict(name='and-to-or',folder='charset-mutation',pc=4164,old=22,new=23,symbol='OperationsCharsetSemanticWitness.Witness',ordinal=5)]
 code=bytes.fromhex(json.loads((snap/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:])
 (out/'candidates').mkdir()
 for info in configs:
  candidate=out/'candidates'/(info['name']+'.bin');mutated=bytearray(code);assert mutated[info['pc']]==info['old'];mutated[info['pc']]=info['new'];candidate.write_bytes(mutated)
  folder=out/'mutations'/info['name'];folder.mkdir(parents=True);mutant=folder/'source-snapshot';shutil.copytree(snap,mutant);owner=mutant/OWNER.relative_to(ROOT)/info['folder']
  baseline=next(j for j in proofjobs if any(d['name']==info['symbol'] for d in j['declarations']));declaration=next(d for d in baseline['declarations'] if d['name']==info['symbol']);assert declaration['status']=='passed'
  translation=record(info['name']+'-translation',[sys.executable,'-B',owner/'generate.py','--runtime',candidate,'--output',owner],180)
  fmt=record(info['name']+'-format',[dafny,'format','--check',owner/'Witness.generated.dfy'],180)
  file=owner/'Witness.generated.dfy';native=record(info['name']+'-native',common.proof_command(dafny,file,folder/'proof.csv')+['--filter-symbol',info['symbol'],'--filter-position',str(file),'--progress','Symbol'],7200)
  log=(out/(info['name']+'-native.log')).read_text();csvrows=list(csv.DictReader((folder/'proof.csv').open())) if (folder/'proof.csv').exists() else []
  native['passed']=native['exitCode'] not in [0,None] and bool(csvrows) and any(r['TestResult.Outcome']=='Failed' for r in csvrows) and all(r['TestResult.Outcome'] in ['Passed','Failed'] for r in csvrows) and 'a postcondition could not be proved' in log and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',log,re.I)
  physicalOwner=source/info['folder'];physical=record(info['name']+'-concrete',[ct['nodeExecutable'],physicalOwner/'evm-traces.mjs',folder/'evm-traces',candidate],180)
  physicalRows=json.loads((folder/'evm-traces/results.json').read_text()) if (folder/'evm-traces/results.json').exists() else [];physical['passed']=physical['passed'] and len(physicalRows)==81 and not next(r for r in physicalRows if r['ordinal']==info['ordinal'])['passed'];save()
  independent=record(info['name']+'-independent',[sys.executable,'-B',physicalOwner/'check-physical.py',folder/'evm-traces','--runtime',candidate,'--expect-semantic-fault'],180)
  fault=dict(info);fault.update(baselineDeclaration=info['symbol'],baselineObligations=declaration['batches'],nativeResults=csvrows,physicalReceipts=len(physicalRows),physicalIntendedOutcomeContradictions=sum(not r['passed'] for r in physicalRows),candidateSha256=sha(candidate),passed=all(j['passed'] for j in [translation,fmt,native,physical,independent]));faults.append(fault);save()
 (out/'candidates/inventory.json').write_text(json.dumps(configs,indent=2)+'\n')
 (out/'mutations/results.json').write_text(json.dumps(faults,indent=2)+'\n');m['semanticFaults']=faults
 m['nativeResults']=[r for j in proofjobs for r in j['nativeResults']];m['declarationResults']=[d for j in proofjobs for d in j['declarations']]
 m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()};m['toolsUnchanged']=m['executableSha256']=={k:sha(f) for k,f in tools.items()}
 m['concreteToolsUnchanged']=sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and all(sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['hardhatEntry','edrEntry','nativeBinding']) and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256']
 m['status']='passed' if m['inputsUnchanged'] and m['toolsUnchanged'] and m['concreteToolsUnchanged'] and all(j['passed'] for j in m['checks']) and all(f['passed'] for f in faults) else 'failed';m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)
if __name__=='__main__':main()
