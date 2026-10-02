#!/usr/bin/env python3
"""Snapshot selected zipWords actual loop development modules; no public evidence claim."""
import argparse,importlib.util,json,re,shutil,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--sources',nargs='+',required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
spec=importlib.util.spec_from_file_location('v',ROOT/'formal/bytecode/getters/verify.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v);common=v.common;sha=common.sha
files=set();closed=set()
def visit(f):
 f=f.resolve()
 if f in closed:return
 assert f.is_file() and f.is_relative_to(ROOT);closed.add(f)
 for inc in re.findall(r'^include "([^"]+)"',f.read_text(),re.M):visit(f.parent/inc)
for name in a.sources:visit(HERE/name)
files|=closed|{f for f in HERE.iterdir() if f.is_file()}|{ROOT/'formal/bytecode/dispatch/inventory.json',ROOT/'artifacts/contracts/Collections.sol/Collections.json',ROOT/'formal/constraints/verify.py',ROOT/'formal/bytecode/getters/verify.py'}
files=sorted(files);snap=out/'source-snapshot'
for f in files:
 dest=snap/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dest)
m={'status':'development-running-not-retained','scope':'Actual zipWords actual loop development modules only; complete raw entry and physical output composition and retained public evidence remain open. No public bytecode coverage.','sourceSha256':{str(f.relative_to(ROOT)):sha(f) for f in files},'jobs':{}}
def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
save()
for name in a.sources:
 f=HERE/name;source=snap/f.relative_to(ROOT);mod=re.search(r'^module (\w+)',f.read_text(),re.M)[1];log=out/(mod+'.log');csv=out/(mod+'.csv');cmd=common.proof_command(Path('/tmp/assertions-dafny-4.11.0/dafny/dafny'),source,csv)+['--filter-symbol',mod,'--progress','Symbol'];job=common.run(cmd,log,1800);common.check_proof(job,log,csv,v.inventory(f));m['jobs'][name]=job;save();print(name,'passed' if job['passed'] else 'FAILED',len(job['nativeResults']),flush=True)
m['inputsUnchanged']=all(sha(f)==m['sourceSha256'][str(f.relative_to(ROOT))] for f in files);m['nativeObligations']=sum(len(j['nativeResults']) for j in m['jobs'].values());m['status']='development-native-passed-not-retained' if m['inputsUnchanged'] and all(j['passed'] for j in m['jobs'].values()) else 'development-native-failed';save();raise SystemExit(0 if m['status']=='development-native-passed-not-retained' else 1)
