#!/usr/bin/env python3
"""Complete retained sqrt raw entry; prepared before any retained snapshot."""
import argparse,csv,datetime,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
if not __debug__:raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];OWNER=HERE.parent
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
workflow=load('sqrt_full_development',OWNER/'sqrt-full-v3/verify-development.py');common=workflow.common;identity=workflow.identity;PROOFS=workflow.PROOFS;inventory=workflow.inventory;sha=common.sha
def inputs():
 return sorted(set(workflow.inputs())|{f for f in HERE.iterdir() if f.is_file()}|{OWNER/'check-sqrt-v3-evidence.py',OWNER/'inventory.py'})
GENERATORS=[('sqrt-repair-v3','generate-seed-limits.py'),('sqrt-seed-controls','generate.py'),('sqrt-seed-connection-v2','generate.py'),('sqrt-newton-controls','generate.py'),('sqrt-edge-controls','generate.py'),('sqrt-return-controls','generate.py'),('sqrt-raw-repair-v3','generate.py'),('sqrt-pipeline','generate.py')]
def regenerate(source,out,record):
 checks=[]
 for folder,script in GENERATORS:
  owner=source/folder;generated=out/('generated-'+folder)
  gen=record('generation-'+folder,[sys.executable,'-B',owner/script,'--output',generated],180)
  fmt=record('generation-format-'+folder,[sys.executable,'-B',owner/'format-generated.py','--output',generated,'--include-root',owner],180)
  gen['passed']=gen['passed'] and fmt['passed'] and all((owner/f.name).read_bytes()==f.read_bytes() for f in generated.iterdir() if f.is_file());checks.extend([gen,fmt])
 conversion=record('generation-conversion',[sys.executable,'-B',source/'log2-repair-v7/generate-conversion.py','--output',out/'conversion'],180)
 conversion['passed']=conversion['passed'] and (source/'log2-repair-v7/Conversion.generated.dfy').read_bytes()==(out/'conversion/Conversion.generated.dfy').read_bytes();checks.append(conversion)
 return all(j['passed'] for j in checks)
def main():
 p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 assert len(PROOFS)==46
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
 m={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Complete exact raw Operations.sqrt(uint256), PCzero through nonpayable/short empty REVERT or physical32-byte floor-root RETURN. Exact seven seed branches, initial scaling, six updates, final correction and every machine transition; all intermediate fitting bounds derived from independent integer-square inequalities and uniqueness. Other public entries remain open.','publicEntries':['Operations.sqrt(uint256)'],'sourceSha256':hashes,'versions':versions,'executableSha256':{k:sha(f) for k,f in tools.items()},'nativeWholeModuleWatchdogSeconds':7200,'nativeObligationTimeLimitSeconds':30,'proofFiles':[str(f.relative_to(ROOT)) for f in PROOFS],'checks':[],'assumptions':['Exact current compiler/runtime/selector extraction and reviewed complete reached instruction-boundary scanner. No compiler correctness shortcut replaces executed instructions.','Complete original finite calldata below2^64 with actual zero-padded word observations, truthful call value, fresh zero byte memory and sufficient reached stack/memory/instruction resources. No gas cost/availability, deployment or performance theorem.','Reviewed normative unsigned integer EVM word interpretation: arithmetic modulo2^256, quotient SHR/DIV, multiplication-by-power SHL, actual byte stores/loads and genuine jumped instruction traces. No equivalence to another interpreter or library correctness premise is assumed.','Dafny/Boogie/Z3 and reviewed evidence tooling are trusted; source proofs and finite fixtures do not replace native exact-opcode correspondence.']}
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
 script=source/'sqrt-retention-v3'
 concrete=record('concrete',[shutil.which('node'),script/'evm-traces.mjs',out/'evm-traces'],180);rows=json.loads((out/'evm-traces/results.json').read_text()) if (out/'evm-traces/results.json').exists() else []
 concrete['passed']=concrete['passed'] and len(rows)==167 and all(r['passed'] for r in rows) and {r['ordinal'] for r in rows}==set(range(167));save()
 record('concrete-independent',[sys.executable,'-B',script/'check-physical.py',out/'evm-traces'],180);ct=json.loads((out/'evm-traces/toolchain.json').read_text());m['concreteToolchain']=ct;save()
 generation=record('candidate-generation',[sys.executable,'-B',script/'make-candidates.py','--output',out/'candidates'],180);faults=[]
 for info in json.loads((out/'candidates/inventory.json').read_text()):
  folder=out/'mutations'/info['name'];folder.mkdir(parents=True);candidate=out/'candidates'/(info['name']+'.bin');mutant=folder/'source-snapshot';shutil.copytree(snap,mutant);owner=mutant/OWNER.relative_to(ROOT)/'sqrt-newton-controls'
  translation=record(info['name']+'-translation',[sys.executable,'-B',owner/'generate.py','--runtime',candidate,'--output',owner],180);fmt=record(info['name']+'-format',[sys.executable,'-B',owner/'format-generated.py','--output',owner,'--include-root',owner],180)
  file=owner/'Newton0.generated.dfy';lines=file.read_text().splitlines();begin=next(i for i,l in enumerate(lines) if 'lemma SemanticWitness(' in l);anchor=next(i for i in range(begin,len(lines)) if re.search(r'ensures state\.stack\[\|state\.stack\|-1\]\s*==\s*11',lines[i]))
  baseline=next(j for j in proofjobs if any(d['name']==info['baselineSemanticSymbol'] for d in j['declarations']));assert next(d for d in baseline['declarations'] if d['name']==info['baselineSemanticSymbol'])['status']=='passed'
  native=record(info['name']+'-native',common.proof_command(dafny,file,folder/'proof.csv')+['--filter-symbol',info['baselineSemanticSymbol'],'--filter-position',str(file)+':'+str(anchor+1),'--progress','Symbol'],240)
  log=(out/(info['name']+'-native.log')).read_text();csvrows=list(csv.DictReader((folder/'proof.csv').open())) if (folder/'proof.csv').exists() else []
  native['passed']=native['exitCode'] not in [0,None] and bool(csvrows) and any(r['TestResult.Outcome']=='Failed' for r in csvrows) and all(r['TestResult.Outcome'] in ['Passed','Failed'] for r in csvrows) and 'a postcondition could not be proved' in log and not re.search(r'timed out|timeout|resolution/type errors|precondition could not be proved',log,re.I)
  physical=record(info['name']+'-concrete',[ct['nodeExecutable'],script/'evm-traces.mjs',folder/'evm-traces',candidate],180);physical['passed']=physical['exitCode'] not in [0,None] and 'Wrong physical sqrt receipt' in (out/(info['name']+'-concrete.log')).read_text();save()
  independent=record(info['name']+'-independent',[sys.executable,'-B',script/'check-physical.py',folder/'evm-traces','--runtime',candidate,'--expect-fault'],180)
  fault=dict(info);fault.update(baselineDeclaration=info['baselineSemanticSymbol'],baselineObligations=next(d['batches'] for d in baseline['declarations'] if d['name']==info['baselineSemanticSymbol']),nativeAnchorLine=anchor+1,nativeResults=csvrows,passed=all(j['passed'] for j in [translation,fmt,native,physical,independent]));faults.append(fault);save()
 (out/'mutations/results.json').write_text(json.dumps(faults,indent=2)+'\n');m['semanticFaults']=faults
 m['nativeResults']=[r for j in proofjobs for r in j['nativeResults']];m['declarationResults']=[d for j in proofjobs for d in j['declarations']]
 m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()};m['toolsUnchanged']=m['executableSha256']=={k:sha(f) for k,f in tools.items()}
 m['concreteToolsUnchanged']=sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and all(sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['hardhatEntry','edrEntry','nativeBinding','viemEntry']) and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256']
 m['status']='passed' if m['inputsUnchanged'] and m['toolsUnchanged'] and m['concreteToolsUnchanged'] and all(j['passed'] for j in m['checks']) and all(f['passed'] for f in faults) else 'failed';m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)
if __name__=='__main__':main()
