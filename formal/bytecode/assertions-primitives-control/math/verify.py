#!/usr/bin/env python3
"""Retain every native obligation of the immutable low-mask dependency closure."""
import sys,os,json,re,shutil,datetime,concurrent.futures,threading,importlib.util
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def module(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
g=module('control',ROOT/'formal/bytecode/assertions-primitives-control/verify.py');getter=g.getter;common=g.common;sha=g.sha
out=Path(sys.argv[1]).resolve();out.mkdir(parents=True,exist_ok=False);closure=g.graph(HERE/'Mask.dfy');snapshot=out/'source-snapshot';files=closure+[Path(__file__).resolve()];hashes={str(f.relative_to(ROOT)):sha(f) for f in files}
for f in files:
 target=snapshot/f.relative_to(ROOT);target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,target)
dafny=Path('/home/sem/assertions-tools/dafny/dafny');lock=threading.Lock();manifest={'schemaVersion':1,'status':'incomplete','scope':'General low-five-bit rounding for each uint64-admitted input; pure mathematical kernel, no bytecode/public-entry claim.','publicEntries':[],'includeClosure':[str(f.relative_to(ROOT)) for f in closure],'sourceSha256':hashes,'checks':[]}
def save():
 with lock:(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
def prove(f):
 name=re.search(r'^module (\w+)',f.read_text(),re.M)[1];csv=out/('proof-'+name+'.csv');cmd=common.proof_command(dafny,snapshot/f.relative_to(ROOT),csv);cmd[cmd.index('--cores')+1]='1';cmd+=['--filter-symbol',name,'--progress','Symbol'];job=common.run(cmd,out/('proof-'+name+'.log'),7200);job.update(name=name,passed=job['exitCode']==0);common.check_proof(job,out/('proof-'+name+'.log'),csv,getter.inventory(f))
 with lock:manifest['checks'].append(job)
 save();print(name,len(job['nativeResults']),'passed' if job['passed'] else 'FAILED',flush=True);return job
save()
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:jobs=list(pool.map(prove,closure))
manifest['nativeResults']=[r for j in jobs for r in j['nativeResults']];manifest['declarationResults']=[d for j in jobs for d in j['declarations']]
for name,cmd in [('audit',[dafny,'audit',snapshot/HERE.relative_to(ROOT)/'Mask.dfy']),('format',[dafny,'format','--check',*[snapshot/f.relative_to(ROOT) for f in closure]])]:
 job=common.run(cmd,out/(name+'.log'),300);job.update(name=name,passed=job['exitCode']==0)
 if name=='audit':job['passed'] &= 'auditor completed with 0 findings' in (out/(name+'.log')).read_text()
 manifest['checks'].append(job)
manifest['inputsUnchanged']=all(sha(ROOT/f)==h for f,h in hashes.items());manifest['status']='passed' if manifest['inputsUnchanged'] and all(j['passed'] for j in manifest['checks']) else 'failed';save();print(manifest['status'],len(manifest['nativeResults']),flush=True);raise SystemExit(0 if manifest['status']=='passed' else 1)
