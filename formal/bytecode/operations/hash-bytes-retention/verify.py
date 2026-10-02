#!/usr/bin/env python3
"""Complete retained exact hash(bytes) raw entry under explicit faithful hash observations."""
import argparse,csv,datetime,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
if not __debug__:raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];OWNER=HERE.parent
SUCCESS=OWNER/'hash-bytes-success';DEPS=OWNER/'hash-bytes-repair-v3'
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
workflow=load('hash_development',SUCCESS/'verify-entry-development.py');common=workflow.common;identity=workflow.identity;PROOFS=workflow.PROOFS;inventory=workflow.inventory
sha=common.sha
def inputs():
 return sorted(set(workflow.inputs())|{p for p in HERE.iterdir() if p.is_file()}|{OWNER/'check-hash-bytes-evidence.py',OWNER/'inventory.py'})
def regenerate(source,out,record):
 dep=source/'hash-bytes-repair-v3';success=source/'hash-bytes-success';jobs=[]
 def gen(folder,commands,formatter,include):
  own=[record(name,[sys.executable,'-B',script,*args],180) for name,script,args in commands]
  own.append(record('format-'+folder.name,[sys.executable,'-B',formatter,'--output',folder,'--include-root',include],180))
  own[-1]['passed']=own[-1]['passed'] and all((include/f.name).read_bytes()==f.read_bytes() for f in folder.iterdir() if f.is_file());jobs.extend(own)
 generated=out/'generated-admission'
 gen(generated,[('generation-admission',dep/'generate-admission.py',['--output',generated]),('generation-raw-lift',dep/'generate-raw-lift.py',['--output',generated,'--mapping-root',generated])],dep/'format-generated.py',dep)
 conversion=record('generation-conversion',[sys.executable,'-B',dep/'generate-conversion.py','--output',out/'conversion'],180)
 conversion['passed']=conversion['passed'] and (dep/'Conversion.generated.dfy').read_bytes()==(out/'conversion/Conversion.generated.dfy').read_bytes();jobs.append(conversion)
 generated=out/'generated-success'
 gen(generated,[('generation-body',success/'generate.py',['--output',generated]),('generation-prefix',success/'generate-prefix.py',['--output',generated]),('generation-prefix-lift',success/'generate-prefix-lift.py',['--output',generated,'--mapping-root',generated])],success/'format-generated.py',success)
 return all(j['passed'] for j in jobs)
def main():
 p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 assert len(PROOFS)==66 and set(PROOFS)==set(SUCCESS.glob('*.dfy'))|set(DEPS.glob('*.dfy'))
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
 m={'schemaVersion':1,'status':'incomplete','wholeModuleWatchdogSeconds':7200,'ordinaryObligationLimitSeconds':30,'startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Complete exact current Operations hash(bytes) raw entry: all actual PC0 admission/rejections and151-instruction accepted decoder,60-instruction physical copy/zero/KECCAK/store/RETURN body and independently specified exact payload hash result. Loose compatible offsets including zero and unaligned windows and arbitrary trailing data admitted within finite below2^64 frames. Other public entries remain open.','publicEntries':['Operations.hash(bytes)'],'sourceSha256':hashes,'versions':versions,'executableSha256':{k:sha(f) for k,f in tools.items()},'checks':[],'proofFiles':[str(f.relative_to(ROOT)) for f in PROOFS],'assumptions':['Exact current compiler job/runtime and selector extraction, reviewed complete instruction-boundary scanning and reached opcode interpreter. No compiler correctness premise replaces executed instructions.','Actual complete finite calldata below2^64 with zero-padded loads, fresh zero call memory, fixed-width big-endian byte stores/loads and truthful call value. Reached stack/memory/instruction resources are sufficient. No gas availability/cost, deployment or performance theorem.','Matches constrains every reached instruction/immediate and actual destination. All generated paths execute their complete instructions with no cutoff.','The hash-engine observation map faithfully supplies KECCAK256 for the exact requested copied payload. No hash algorithm correctness, collision resistance or cryptographic security is inferred.','Dafny/Boogie/Z3 and reviewed tooling are trusted. Source evidence and concrete EVM fixtures do not substitute for native exact-opcode correspondence.']}
 def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
 def record(name,cmd,timeout=7200):
  j=common.run(cmd,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
 save();gate=record('format-before',[dafny,'format','--check',*[snap/f.relative_to(ROOT) for f in PROOFS]],180)
 if not gate['passed']:m['status']='failed-format-gate';save();raise SystemExit(1)
 ident=record('runtime-identity',[sys.executable,'-B',source/'identity.py','--solc',solc,'--output',out/'identity'],240)
 generated=regenerate(source,out,record);save()
 if not ident['passed'] or not generated:m['status']='failed-regeneration-identity-gate';save();raise SystemExit(1)
 proofjobs=[]
 for f in PROOFS:
  symbol=re.search(r'^module (\w+)',f.read_text(),re.M)[1];sf=snap/f.relative_to(ROOT);csvpath=out/(symbol+'.csv')
  j=record('proof-'+symbol,common.proof_command(dafny,sf,csvpath)+['--filter-symbol',symbol,'--filter-position',str(sf),'--progress','Symbol']);common.check_proof(j,out/('proof-'+symbol+'.log'),csvpath,inventory(f));proofjobs.append(j);save()
  audit=record('audit-'+symbol,[dafny,'audit',sf],180);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/('audit-'+symbol+'.log')).read_text();save()
 record('format',[dafny,'format','--check',*[snap/f.relative_to(ROOT) for f in PROOFS]],180)
 script=source/'hash-bytes-retention'
 concrete=record('concrete',[shutil.which('node'),script/'evm-traces.mjs',out/'evm-traces'],180)
 rows=json.loads((out/'evm-traces/results.json').read_text()) if (out/'evm-traces/results.json').exists() else []
 concrete['passed']=concrete['passed'] and len(rows)==38 and all(r['passed'] for r in rows) and {r['ordinal'] for r in rows}==set(range(38));save()
 record('concrete-independent',[sys.executable,'-B',script/'check-physical.py',out/'evm-traces'],180)
 ct=json.loads((out/'evm-traces/toolchain.json').read_text());m['concreteToolchain']=ct;save()
 record('candidate-generation',[sys.executable,'-B',script/'make-candidates.py','--output',out/'candidates'],180)
 faults=[]
 for info in json.loads((out/'candidates/inventory.json').read_text()):
  folder=out/'mutations'/info['name'];folder.mkdir(parents=True);candidate=out/'candidates'/(info['name']+'.bin')
  mutant=folder/'source-snapshot';shutil.copytree(snap,mutant);owner=mutant/SUCCESS.relative_to(ROOT)
  trans=record(info['name']+'-translation',[sys.executable,'-B',owner/'generate.py','--runtime',candidate,'--output',owner],180)
  fmt=record(info['name']+'-format',[sys.executable,'-B',owner/'format-generated.py','--output',owner,'--include-root',owner],180)
  file=owner/'Entry.generated.dfy';lines=file.read_text().splitlines();symbol=info['baselineSemanticSymbol'];begin=next(i for i,l in enumerate(lines) if 'lemma SemanticWitness(' in l);anchor=next(i for i in range(begin,len(lines)) if 'ensures state.stack[|state.stack|-2]==result' in lines[i])
  base=next(j for j in proofjobs if any(d['name']==symbol for d in j['declarations']));assert next(d for d in base['declarations'] if d['name']==symbol)['status']=='passed'
  native=record(info['name']+'-native',common.proof_command(dafny,file,folder/'proof.csv')+['--filter-symbol',symbol,'--filter-position',str(file)+':'+str(anchor+1),'--progress','Symbol'],240)
  log=(out/(info['name']+'-native.log')).read_text();nr=list(csv.DictReader((folder/'proof.csv').open())) if (folder/'proof.csv').exists() else []
  native['passed']=native['exitCode'] not in [0,None] and bool(nr) and any(r['TestResult.Outcome']=='Failed' for r in nr) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in nr) and 'postcondition could not be proved' in log and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',log,re.I)
  evm=record(info['name']+'-concrete',[ct['nodeExecutable'],script/'evm-traces.mjs',folder/'evm-traces',candidate],180)
  wrong=[r for r in json.loads((folder/'evm-traces/results.json').read_text()) if not r['passed']]
  evm['passed']=evm['exitCode'] not in [0,None] and len(wrong)==22 and all(r['reason']=='Success' and r['actual']!=r['expected'] for r in wrong) and any(r['ordinal']==4 and r['actual']==info['actual'] and r['expected']==info['expected'] for r in wrong) and 'Wrong physical raw hash/preimage receipt' in (out/(info['name']+'-concrete.log')).read_text();save()
  independent=record(info['name']+'-independent',[sys.executable,'-B',script/'check-physical.py',folder/'evm-traces','--runtime',candidate],180)
  faults.append(dict(info,semanticAssertion={'line':anchor+1,'text':lines[anchor],'file':str(file.relative_to(out))},checks=[trans,fmt,native,evm,independent],concreteFailures=wrong));save()
 (out/'mutations/results.json').write_text(json.dumps(faults,indent=2)+'\n')
 m['nativeResults']=[r for j in proofjobs for r in j['nativeResults']];m['declarationResults']=[d for j in proofjobs for d in j['declarations']]
 m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()};m['toolsUnchanged']=m['executableSha256']=={k:sha(f) for k,f in tools.items()}
 m['concreteToolsUnchanged']=all(sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['hardhatEntry','edrEntry','nativeBinding','viemEntry']) and sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256']
 m['status']='passed' if m['inputsUnchanged'] and m['toolsUnchanged'] and m['concreteToolsUnchanged'] and all(j['passed'] for j in m['checks']) else 'failed';m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)
if __name__=='__main__':main()
