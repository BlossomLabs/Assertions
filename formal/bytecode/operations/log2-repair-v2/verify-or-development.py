#!/usr/bin/env python3
"""Retain selected same-contract log2 OR bridge repair candidates.

No complete native graph or public credit; complete fresh retention is required.
"""
import argparse,csv,datetime,importlib.util,json,re,shutil,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def load(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
v=load('log2_workflow',HERE.parent/'log2/verify-development.py');common=v.common
def inputs():return sorted(set(v.inputs())|{f for f in HERE.iterdir() if f.is_file()})
p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
files=inputs();hashes={str(f.relative_to(ROOT)):common.sha(f) for f in files};snap=out/'source-snapshot'
for f in files:
 d=snap/f.relative_to(ROOT);d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,d)
tools={'dafny':a.dafny.resolve(),'Dafny.dll':a.dafny.resolve().parent/'Dafny.dll','z3':a.dafny.resolve().parent/'z3/bin/z3-4.12.1'}
m={'status':'development-running-no-public-credit','scope':'Three selected generic bit-vector OR identity/projection bridge helpers and unchanged full-word OrZero identity theorem, adding explicit fitting/narrow/wide result round-trip hints. Captures full original owner and isolated native input/tool graph; all other declarations are excluded from this selected check. Native obligation30s limit unchanged. No public or complete-graph credit.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'executableSha256':{k:common.sha(f) for k,f in tools.items()},'checks':[]}
def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
def record(n,cmd,limit):
 j=common.run(cmd,out/(n+'.log'),limit);j.update(name=n,passed=j['exitCode']==0);m['checks'].append(j);save();return j
save();file=snap/HERE.relative_to(ROOT)/'Kernel.dfy'
format=record('format',[tools['dafny'],'format','--check',*[snap/f.relative_to(ROOT) for f in sorted(HERE.glob('*.dfy'))]],180)
if not format['passed']:m['status']='development-format-failed-preserved';save();raise SystemExit(1)
proofjobs=[]
for sourcefile,short,symbol in [('Kernel.dfy','ProjectionCongruence','OperationsBytecodeLog2Kernel.ProjectionCongruence'),('Kernel.dfy','Projection','OperationsBytecodeLog2Kernel.OrProjection'),('Kernel.dfy','OrZero','OperationsBytecodeLog2Kernel.OrZero')]:
 file=snap/HERE.relative_to(ROOT)/sourcefile;inventory=[d for d in v.inventory(HERE/sourcefile) if d['name']==symbol];assert len(inventory)==1
 j=record(short,common.proof_command(tools['dafny'],file,out/(short+'.csv'))+['--filter-symbol',symbol,'--progress','Symbol'],300);common.check_proof(j,out/(short+'.log'),out/(short+'.csv'),inventory);proofjobs.append(j);save()
for sourcefile in ['Kernel.dfy','Positive.generated.dfy']:
 file=snap/HERE.relative_to(ROOT)/sourcefile;name='audit-'+sourcefile.replace('.dfy','')
 audit=record(name,[tools['dafny'],'audit',file],180);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/(name+'.log')).read_text();save()
m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):common.sha(f) for f in inputs()};m['toolsUnchanged']=m['executableSha256']=={k:common.sha(f) for k,f in tools.items()};m['nativeResults']=[r for j in proofjobs for r in j.get('nativeResults',[])];m['declarationResults']=[d for j in proofjobs for d in j.get('declarations',[])];m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['status']='development-selected-passed-no-public-credit' if m['inputsUnchanged'] and m['toolsUnchanged'] and all(j['passed'] for j in m['checks']) else 'development-failed-preserved';m['evidenceSha256']={str(f.relative_to(out)):common.sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save();print(m['status']);raise SystemExit(0 if m['status']=='development-selected-passed-no-public-credit' else 1)
