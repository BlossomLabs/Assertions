#!/usr/bin/env python3
"""Snapshot and check selected development certificates, never public evidence."""
import argparse,concurrent.futures,hashlib,importlib.util,json,re,shutil,subprocess,sys,threading
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--sources',nargs='+',required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
spec=importlib.util.spec_from_file_location('common',ROOT/'formal/constraints/verify.py');common=importlib.util.module_from_spec(spec);spec.loader.exec_module(common)
files=[p for p in HERE.iterdir() if p.is_file()]+[ROOT/'formal/bytecode/getters/Machine.dfy',ROOT/'formal/bytecode/dispatch/inventory.json',ROOT/'formal/constraints/verify.py',ROOT/'artifacts/contracts/Collections.sol/Collections.json']
snapshot=out/'source-snapshot'
for f in files:
 target=snapshot/f.relative_to(ROOT);target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,target)
manifest={'status':'development-running-not-retained','scope':'Selected development native certificates only. Public entry/body/whole-contract coverage is unchanged; dependency/audit/EVM/mutation retention remains required.','inputs':{str(f.relative_to(ROOT)):sha(f) for f in files},'jobs':{}}
dafny=Path('/tmp/assertions-dafny-4.11.0/dafny/dafny');z3=dafny.parent/'z3/bin/z3-4.12.1'
manifest['tools']={n:{'path':str(f),'sha256':sha(f),'version':subprocess.check_output([str(f),'--version'],text=True).strip()} for n,f in [('dafny',dafny),('z3',z3)]};lock=threading.Lock()
def save():(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
save()
def prove(name):
 source=snapshot/'formal/bytecode/scans'/name;module=re.search(r'^module (\w+)',source.read_text(),re.M)[1]
 decls=[{'name':module+'.'+m[2],'kind':m[1],'file':name} for m in re.finditer(r'^  (?:(?:ghost|opaque) )?(lemma|method|function|predicate|type) (\w+)(?:\(| =)',source.read_text(),re.M)]
 stem=source.stem;log=out/(stem+'.log');csv=out/(stem+'.csv');cmd=common.proof_command(dafny,source,csv)+['--filter-symbol',module,'--progress','Symbol'];job=common.run(cmd,log,timeout=1200);common.check_proof(job,log,csv,decls)
 with lock:manifest['jobs'][name]=job;save();print(name,'passed' if job['passed'] else 'FAILED',len(job['nativeResults']),flush=True)
 return job['passed']
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:results=list(pool.map(prove,a.sources))
unchanged=all(sha(f)==manifest['inputs'][str(f.relative_to(ROOT))] for f in files)
manifest['inputsUnchanged']=unchanged;manifest['status']='development-native-passed-not-retained' if all(results) and unchanged else 'development-native-failed';manifest['nativeObligations']=sum(len(j['nativeResults']) for j in manifest['jobs'].values());save()
raise SystemExit(0 if all(results) and unchanged else 1)
