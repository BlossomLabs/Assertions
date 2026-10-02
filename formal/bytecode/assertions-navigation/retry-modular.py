#!/usr/bin/env python3
"""Retain isolated retries of exact frozen files; never edit or accept the parent matrix."""
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor,as_completed
import argparse,datetime,importlib.util,json,subprocess
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
getter=load('getter',ROOT/'formal/bytecode/getters/verify.py');common,sha=getter.common,getter.sha
p=argparse.ArgumentParser();p.add_argument('--matrix',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--file',action='append',required=True);p.add_argument('--workers',type=int,default=2);args=p.parse_args();assert 1<=args.workers<=4
matrix=args.matrix.resolve();out=args.output.resolve();out.mkdir(parents=True,exist_ok=False);original=json.loads((matrix/'manifest.json').read_text());snapshot=matrix/'source-snapshot'
selected=sorted(set(args.file));assert set(selected)<=set(original['includeClosure'])
source_hashes=original['sourceSha256'];assert all(sha(ROOT/q)==h for q,h in source_hashes.items())
snapshot_hashes={str(q.relative_to(matrix)):sha(q) for q in snapshot.rglob('*') if q.is_file()}
tools={name:Path(next(v['proof']['command'][0] for v in original['moduleProofs'])) if name=='dafny' else None for name in ['dafny']}
dafny=tools['dafny'];tools.update({'Dafny.dll':dafny.parent/'Dafny.dll','z3':dafny.parent/'z3/bin/z3-4.12.1'});assert {k:sha(v) for k,v in tools.items()}==original['executableSha256']
helpers={str(q.relative_to(ROOT)):sha(q) for q in [Path(__file__).resolve(),ROOT/'formal/bytecode/getters/verify.py',ROOT/'formal/constraints/verify.py']}
x={'status':'incomplete','scope':'Isolated native retries for every own declaration of selected files in the exact original frozen snapshot. This is partial retry evidence, not a complete closure or entry certificate. The unchanged parent matrix must supply passing proofs/audits for every remaining dependency file.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'matrix':str(matrix),'selectedFiles':selected,'sourceSha256':source_hashes,'snapshotSha256':snapshot_hashes,'helperSha256':helpers,'executableSha256':original['executableSha256'],'versions':original['versions'],'moduleProofs':[]}
def save():(out/'manifest.json').write_text(json.dumps(x,indent=2)+'\n')
save()
def verify(index,relative):
 folder=out/'modules'/f'{index:03d}';folder.mkdir(parents=True);file=snapshot/relative
 command=[str(dafny),'verify',str(file),'--manual-lemma-induction','--isolate-assertions','--cores','1','--verification-time-limit','30','--solver-path',str(tools['z3']),'--log-format','csv;LogFileName='+str(folder/'proof.csv'),'--progress','Symbol']
 proof=common.run(command,folder/'proof.log',7200);common.check_proof(proof,folder/'proof.log',folder/'proof.csv',getter.inventory(file))
 proof['passed']=proof['exitCode']==0 and bool(proof['nativeResults']) and all(r['TestResult.Outcome']=='Passed' for r in proof['nativeResults']) and all(d['status']=='passed' for d in proof['declarations'] if d['kind'] in ['method','lemma'])
 audit=common.run([dafny,'audit',file],folder/'audit.log',300);audit['passed']=audit['exitCode']==0 and 'auditor completed with 0 findings' in (folder/'audit.log').read_text()
 return {'file':relative,'proof':proof,'audit':audit,'evidenceDirectory':str(folder.relative_to(out))}
with ThreadPoolExecutor(max_workers=args.workers) as executor:
 futures=[executor.submit(verify,i,f) for i,f in enumerate(selected)]
 for future in as_completed(futures):
  m=future.result();x['moduleProofs'].append(m);save();print(m['file'],'passed' if m['proof']['passed'] and m['audit']['passed'] else 'failed',flush=True)
x['coverageComplete']=set(m['file'] for m in x['moduleProofs'])==set(selected)
x['inputsUnchanged']=all(sha(ROOT/q)==h for q,h in source_hashes.items()) and all(sha(matrix/q)==h for q,h in snapshot_hashes.items()) and all(sha(ROOT/q)==h for q,h in helpers.items())
x['toolsUnchanged']={k:sha(v) for k,v in tools.items()}==x['executableSha256'];x['status']='passed' if x['coverageComplete'] and x['inputsUnchanged'] and x['toolsUnchanged'] and all(m['proof']['passed'] and m['audit']['passed'] for m in x['moduleProofs']) else 'failed'
x['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();x['evidenceSha256']={str(q.relative_to(out)):sha(q) for q in out.rglob('*') if q.is_file() and q.name!='manifest.json'};save();print(x['status']);raise SystemExit(0 if x['status']=='passed' else 1)
