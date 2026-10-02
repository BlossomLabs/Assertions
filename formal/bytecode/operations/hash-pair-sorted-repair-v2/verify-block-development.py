#!/usr/bin/env python3
"""Retain selected complete same-theorem sorted-hash block/final composition candidates.

No complete native graph or public credit; complete fresh retention is required.
"""
import argparse,csv,datetime,importlib.util,json,re,shutil,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def load(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
v=load('signed_retainer',HERE.parent/'hash-pair-sorted-repair-v2-retention/verify.py');common=v.common
p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
files=v.inputs();hashes={str(f.relative_to(ROOT)):common.sha(f) for f in files};snap=out/'source-snapshot'
for f in files:
 d=snap/f.relative_to(ROOT);d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,d)
tools={'dafny':a.dafny.resolve(),'Dafny.dll':a.dafny.resolve().parent/'Dafny.dll','z3':a.dafny.resolve().parent/'z3/bin/z3-4.12.1'}
m={'status':'development-running-no-public-credit','scope':'Selected same-theorem Keep/Swap complete composition through at most20-instruction proved Good-state blocks, executing every original Advance once in order before the same final physical RETURN/Encode. Captures whole owner/dependency/tool graph; does not freshly verify all other declarations or grant public bytecode credit. Faithful hash-engine map, fitting finite frame and sufficient reached resources remain explicit. Native obligation30s limit unchanged; original full V1 remains frozen.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'executableSha256':{k:common.sha(f) for k,f in tools.items()},'checks':[]}
def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
def record(n,cmd,limit):
 j=common.run(cmd,out/(n+'.log'),limit);j.update(name=n,passed=j['exitCode']==0);m['checks'].append(j);save();return j
save()
format=record('format',[tools['dafny'],'format','--check',*[snap/f.relative_to(ROOT) for f in v.PROOFS]],180)
if not format['passed']:m['status']='development-format-failed-preserved';save();raise SystemExit(1)
proofs=[]
for name in ['Keep','Swap']:
 file=snap/HERE.relative_to(ROOT)/(name+'.generated.dfy');symbol='OperationsHashPairSorted'+name+'.Run';inventory=[d for d in v.v.inventory(HERE/(name+'.generated.dfy')) if d['name'].startswith(symbol)];assert len(inventory)==9
 j=record(name+'-blocks-and-run',common.proof_command(tools['dafny'],file,out/(name+'.csv'))+['--filter-symbol',symbol,'--progress','Symbol'],300);common.check_proof(j,out/(name+'-blocks-and-run.log'),out/(name+'.csv'),inventory);proofs.append(j);save()
 audit=record(name+'-audit',[tools['dafny'],'audit',file],180);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/(name+'-audit.log')).read_text();save()
m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):common.sha(f) for f in v.inputs()};m['toolsUnchanged']=m['executableSha256']=={k:common.sha(f) for k,f in tools.items()};m['nativeResults']=[r for j in proofs for r in j.get('nativeResults',[])];m['declarationResults']=[d for j in proofs for d in j.get('declarations',[])];m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['status']='development-selected-passed-no-public-credit' if m['inputsUnchanged'] and m['toolsUnchanged'] and all(j['passed'] for j in m['checks']) else 'development-failed-preserved';m['evidenceSha256']={str(f.relative_to(out)):common.sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save();print(m['status']);raise SystemExit(0 if m['status']=='development-selected-passed-no-public-credit' else 1)
