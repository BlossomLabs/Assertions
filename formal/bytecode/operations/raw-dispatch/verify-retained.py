#!/usr/bin/env python3
"""Retain complete exact dispatcher/raw-prefix graph; known wrappers earn no body credit."""
import argparse,csv,datetime,importlib.util,json,re,shutil,sys,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
v=load('getters',ROOT/'formal/bytecode/getters/verify.py');common=v.common
physical=load('physical_workflow',HERE/'verify-physical-development.py')
PROOFS=[HERE/name for name in ['Machine.dfy','Physical.dfy','Bridge.dfy','Execution.dfy','Operations.generated.dfy','OperationsKnown.generated.dfy','OperationsUnknown.generated.dfy','OperationsEarly.generated.dfy','OperationsTerminal.generated.dfy','Connection.dfy']]
def main():
 p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 assert set(HERE.glob('*.dfy'))==set(PROOFS)
 closed=set()
 def visit(f):
  f=f.resolve();assert f in PROOFS
  if f in closed:return
  closed.add(f)
  for name in re.findall(r'^include "([^"]+)"',f.read_text(),re.M):visit(f.parent/name)
 for f in PROOFS:visit(f)
 assert closed==set(PROOFS)
 versions={k:subprocess.check_output([str(f),'--version'],text=True).strip() for k,f in [('dafny',a.dafny.resolve()),('z3',a.dafny.resolve().parent/'z3/bin/z3-4.12.1'),('solc',a.solc.resolve())]}
 assert versions['dafny']==json.loads((ROOT/'formal/abi/toolchain.json').read_text())['dafnyVersion'] and '4.12.1' in versions['z3'] and '0.8.36+commit.8a079791' in versions['solc']
 files=sorted(set(physical.inputs())|{ROOT/'formal/constraints/verify.py',ROOT/'formal/bytecode/getters/verify.py',ROOT/'formal/bytecode/dispatch/identity.py',ROOT/'formal/abi/toolchain.json'});hashes={str(f.relative_to(ROOT)):common.sha(f) for f in files};snap=out/'source-snapshot'
 for f in files:
  d=snap/f.relative_to(ROOT);d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,d)
 dafny=a.dafny.resolve();tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':dafny.parent/'z3/bin/z3-4.12.1','solc':a.solc.resolve(),'node':Path(shutil.which('node')).resolve(),'python':Path(sys.executable).resolve()};owner=snap/HERE.relative_to(ROOT)
 m={'status':'retained-running-no-body-credit','scope':'Complete all92 exact current dispatcher wrapper prefixes and physical short/nonpayable/unknown empty rejection receipts, from actual complete raw calldata and PC0. Known wrappers stop before function bodies and earn no public-entry credit. Finite calldata below2^64, reviewed opcode/physical interpreter and sufficient reached resources are explicit. No gas/deployment/performance claim.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'versions':versions,'sourceSha256':hashes,'executableSha256':{k:common.sha(f) for k,f in tools.items()},'proofFiles':[str(f.relative_to(ROOT)) for f in PROOFS],'checks':[]}
 def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
 def record(name,cmd,timeout=1800):
  j=common.run(cmd,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
 save();gate=record('format',[dafny,'format','--check',*[snap/f.relative_to(ROOT) for f in PROOFS]],180)
 if not gate['passed']:m['status']='development-format-failed-preserved';save();raise SystemExit(1)
 record('runtime-identity',[sys.executable,'-B',owner.parent/'identity.py','--solc',a.solc.resolve(),'--output',out/'identity'],240)
 generated=out/'generated';generated.mkdir()
 jobs=[('routing','generate-routing.py',['--solc',a.solc.resolve(),'--contract','Operations'],['Operations.generated.dfy','Operations.mapping.json']),('known','generate-known.py',[],['OperationsKnown.generated.dfy','OperationsKnown.mapping.json']),('unknown','generate-unknown.py',[],['OperationsUnknown.generated.dfy','OperationsUnknown.mapping.json']),('early','generate-early.py',[],['OperationsEarly.generated.dfy','OperationsEarly.mapping.json']),('terminal','generate-terminal.py',[],['OperationsTerminal.generated.dfy'])]
 for name,generator,extra,names in jobs:
  j=record('generation-'+name,[sys.executable,'-B',owner/generator,*extra,'--output',generated],240)
  fmt=record('generation-format-'+name,[sys.executable,'-B',owner/'format-generated.py','--output',generated,'--include-root',owner],240)
  j['passed']=j['passed'] and fmt['passed'] and all((owner/n).read_bytes()==(generated/n).read_bytes() for n in names);save()
 if not all(c['passed'] for c in m['checks']):m['status']='retained-preflight-failed-preserved';save();raise SystemExit(1)
 positive=[]
 for f in PROOFS:
  symbol=re.search(r'^module (\w+)',f.read_text(),re.M)[1];sf=snap/f.relative_to(ROOT);csvfile=out/(symbol+'.csv')
  j=record('proof-'+symbol,common.proof_command(dafny,sf,csvfile)+['--filter-symbol',symbol,'--progress','Symbol']);common.check_proof(j,out/('proof-'+symbol+'.log'),csvfile,v.inventory(f));positive.extend(j.get('nativeResults',[]));save()
  audit=record('audit-'+symbol,[dafny,'audit',sf],180);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/('audit-'+symbol+'.log')).read_text();save()
 record('candidate-generation',[sys.executable,'-B',owner/'make-candidates.py','--output',out/'candidates'])
 candidate=json.loads((out/'candidates/inventory.json').read_text())[0];folder=out/'mutation';folder.mkdir()
 for f in PROOFS:
  if not f.name.endswith('.generated.dfy') and f.name!='Connection.dfy':shutil.copy2(snap/f.relative_to(ROOT),folder/f.name)
 record('candidate-translation',[sys.executable,'-B',owner/'generate-terminal.py','--output',folder,'--runtime',out/'candidates'/(candidate['name']+'.bin')])
 source=folder/'OperationsTerminal.generated.dfy';lines=source.read_text().splitlines();short=candidate['semanticSymbol'].rsplit('.',1)[1];start=next(i for i,l in enumerate(lines) if 'lemma '+short+'(' in l);anchor=next(i for i in range(start,len(lines)) if 'ensures G.Step(' in lines[i]);csvfile=folder/'proof.csv'
 job=record('candidate-native',common.proof_command(dafny,source,csvfile)+['--filter-symbol',candidate['semanticSymbol'],'--filter-position',str(source)+':'+str(anchor+1),'--progress','Symbol'])
 rows=list(csv.DictReader(csvfile.open())) if csvfile.is_file() else [];text=(out/'candidate-native.log').read_text();job['passed']=job['exitCode'] not in [0,None] and bool(rows) and any(r['TestResult.Outcome']=='Failed' for r in rows) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in rows) and 'postcondition could not be proved' in text and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',text,re.I);job['nativeResults']=rows;job['semanticAssertion']={'line':anchor+1,'text':lines[anchor]};save()
 record('baseline-physical',[tools['node'],owner/'evm-traces.mjs',out/'baseline'],180)
 record('baseline-independent',[tools['python'],'-B',owner/'check-development.py',out/'baseline'],180)
 baseline=next(j for j in m['checks'] if j['name']=='proof-OperationsRawUnknownTerminal')
 assert next(d for d in baseline['declarations'] if d['name']==candidate['semanticSymbol'])['status']=='passed'
 fault=record('fault-physical',[tools['node'],owner/'evm-traces.mjs',out/'fault',out/'candidates'/(candidate['name']+'.bin')],180)
 fault['passed']=fault['exitCode']==1 and 'Wrong raw rejection receipts: 5' in (out/'fault-physical.log').read_text();save()
 record('fault-independent',[tools['python'],'-B',owner/'check-development.py',out/'fault','--runtime',out/'candidates'/(candidate['name']+'.bin'),'--expect-unknown-faults'],180)
 ct=json.loads((out/'baseline/toolchain.json').read_text());m['concreteToolchain']=ct;m['concreteToolsUnchanged']=all(common.sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['hardhatEntry','edrEntry','nativeBinding']) and common.sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and common.sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256']
 current=sorted(set(physical.inputs())|{ROOT/'formal/constraints/verify.py',ROOT/'formal/bytecode/getters/verify.py',ROOT/'formal/bytecode/dispatch/identity.py',ROOT/'formal/abi/toolchain.json'});m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):common.sha(f) for f in current};m['toolsUnchanged']=m['executableSha256']=={k:common.sha(f) for k,f in tools.items()};m['positiveNativeResults']=positive;m['status']='retained-passed-no-body-credit' if m['inputsUnchanged'] and m['toolsUnchanged'] and m['concreteToolsUnchanged'] and all(j['passed'] for j in m['checks']) else 'development-failed-preserved';m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['declarationResults']=[d for j in m['checks'] for d in j.get('declarations',[])];m['evidenceSha256']={str(f.relative_to(out)):common.sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save();raise SystemExit(0 if m['status']=='retained-passed-no-body-credit' else 1)
if __name__=='__main__':main()
