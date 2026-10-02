#!/usr/bin/env python3
"""Selected dispatcher foundations/terminal faults; no complete routing credit."""
import argparse,csv,datetime,importlib.util,json,re,shutil,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
v=load('getters',ROOT/'formal/bytecode/getters/verify.py');common=v.common
physical=load('physical_workflow',HERE/'verify-physical-development.py')
PROOFS=[HERE/name for name in ['Machine.dfy','Physical.dfy','Bridge.dfy','Execution.dfy','OperationsTerminal.generated.dfy']]
def main():
 p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 files=sorted(set(physical.inputs())|{ROOT/'formal/constraints/verify.py',ROOT/'formal/bytecode/getters/verify.py',ROOT/'formal/abi/toolchain.json'});hashes={str(f.relative_to(ROOT)):common.sha(f) for f in files};snap=out/'source-snapshot'
 for f in files:
  d=snap/f.relative_to(ROOT);d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,d)
 dafny=a.dafny.resolve();tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':dafny.parent/'z3/bin/z3-4.12.1'};owner=snap/HERE.relative_to(ROOT)
 m={'status':'development-selected-running-no-public-credit','scope':'Complete local reached-opcode machine/byte-memory bridge/execution foundation declarations and16 actual raw unknown-selector terminal receipts, plus one real one-byte native semantic terminal fault. Complete dispatcher/control/known/unknown trace proofs remain open; no public coverage.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'executableSha256':{k:common.sha(f) for k,f in tools.items()},'proofFiles':[str(f.relative_to(ROOT)) for f in PROOFS],'checks':[]}
 def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
 def record(name,cmd,timeout=300):
  j=common.run(cmd,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
 save();gate=record('format',[dafny,'format','--check',*[snap/f.relative_to(ROOT) for f in PROOFS]],180)
 if not gate['passed']:m['status']='development-format-failed-preserved';save();raise SystemExit(1)
 positive=[]
 for f in PROOFS:
  symbol=re.search(r'^module (\w+)',f.read_text(),re.M)[1];sf=snap/f.relative_to(ROOT);csvfile=out/(symbol+'.csv')
  j=record('proof-'+symbol,common.proof_command(dafny,sf,csvfile)+['--filter-symbol',symbol,'--progress','Symbol']);common.check_proof(j,out/('proof-'+symbol+'.log'),csvfile,v.inventory(f));positive.extend(j.get('nativeResults',[]));save()
  audit=record('audit-'+symbol,[dafny,'audit',sf],180);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/('audit-'+symbol+'.log')).read_text();save()
 record('candidate-generation',[sys.executable,'-B',owner/'make-candidates.py','--output',out/'candidates'])
 candidate=json.loads((out/'candidates/inventory.json').read_text())[0];folder=out/'mutation';folder.mkdir()
 for f in PROOFS[:-1]:shutil.copy2(snap/f.relative_to(ROOT),folder/f.name)
 record('candidate-translation',[sys.executable,'-B',owner/'generate-terminal.py','--output',folder,'--runtime',out/'candidates'/(candidate['name']+'.bin')])
 source=folder/'OperationsTerminal.generated.dfy';lines=source.read_text().splitlines();short=candidate['semanticSymbol'].rsplit('.',1)[1];start=next(i for i,l in enumerate(lines) if 'lemma '+short+'(' in l);anchor=next(i for i in range(start,len(lines)) if 'ensures G.Step(' in lines[i]);csvfile=folder/'proof.csv'
 job=record('candidate-native',common.proof_command(dafny,source,csvfile)+['--filter-symbol',candidate['semanticSymbol'],'--filter-position',str(source)+':'+str(anchor+1),'--progress','Symbol'])
 rows=list(csv.DictReader(csvfile.open())) if csvfile.is_file() else [];text=(out/'candidate-native.log').read_text();job['passed']=job['exitCode'] not in [0,None] and bool(rows) and any(r['TestResult.Outcome']=='Failed' for r in rows) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in rows) and 'postcondition could not be proved' in text and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',text,re.I);job['nativeResults']=rows;job['semanticAssertion']={'line':anchor+1,'text':lines[anchor]};save()
 current=sorted(set(physical.inputs())|{ROOT/'formal/constraints/verify.py',ROOT/'formal/bytecode/getters/verify.py',ROOT/'formal/abi/toolchain.json'});m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):common.sha(f) for f in current};m['toolsUnchanged']=m['executableSha256']=={k:common.sha(f) for k,f in tools.items()};m['positiveNativeResults']=positive;m['status']='development-selected-passed-no-public-credit' if m['inputsUnchanged'] and m['toolsUnchanged'] and all(j['passed'] for j in m['checks']) else 'development-failed-preserved';m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();save();raise SystemExit(0 if m['status']=='development-selected-passed-no-public-credit' else 1)
if __name__=='__main__':main()
