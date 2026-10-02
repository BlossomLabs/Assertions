#!/usr/bin/env python3
"""Retain exact Assertions primitive body closure; never count it as public entry coverage."""
import argparse,concurrent.futures,datetime,importlib.util,json,os,re,shutil,subprocess,sys,threading
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def module(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
getter=module('getter',ROOT/'formal/bytecode/getters/verify.py');common,sha=getter.common,getter.sha
NAMES=sorted(f.name.removesuffix('.generated.dfy') for f in HERE.glob('*.generated.dfy'))
def graph(path):
 closed=set()
 def visit(f):
  f=f.resolve();assert f.is_relative_to(ROOT) and f.is_file()
  if f in closed:return
  closed.add(f)
  for include in re.findall(r'^include "([^"]+)"',f.read_text(),re.M):visit(f.parent/include)
 visit(path);return sorted(closed)
def main():
 p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--node',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--jobs',type=int,default=4);a=p.parse_args()
 dafny,solc,node,out=[x.resolve() for x in (a.dafny,a.solc,a.node,a.output)];out.mkdir(parents=True,exist_ok=False);assert 1<=a.jobs<=4;os.environ['DAFNY']=str(dafny)
 closure=graph(HERE/'Entry.dfy');files=set(getter.inputs())|set(closure)|{p for p in HERE.iterdir() if p.is_file()}|{ROOT/'formal/bytecode/unknown/format-generated.py'}
 assert all('/operations/' not in str(f) and 'Collections' not in f.name and 'Expressions' not in f.name for f in closure)
 hashes={str(f.relative_to(ROOT)):sha(f) for f in sorted(files)};snapshot=out/'source-snapshot'
 for f in files:
  dst=snapshot/f.relative_to(ROOT);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dst)
 source=snapshot/HERE.relative_to(ROOT);tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':dafny.parent/'z3/bin/z3-4.12.1','solc':solc,'node':node};versions={k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in tools.items() if k!='Dafny.dll'}
 assert versions['dafny']==json.loads((ROOT/'formal/abi/toolchain.json').read_text())['dafnyVersion'];assert '4.12.1' in versions['z3'] and '0.8.36+commit.8a079791' in versions['solc']
 m={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'contracts':['Assertions'],'publicEntries':[],'scope':'Exact 35 helper-bounded body paths, independent result/routing/error specifications, external-frame lifting, and arbitrary-count gather allocation initialization. Public calldata decoder/resolver/call/serializer composition and whole-contract semantics remain open.','sourceSha256':hashes,'includeClosure':[str(f.relative_to(ROOT)) for f in closure],'versions':versions,'executableSha256':{k:sha(v) for k,v in tools.items()},'checks':[],'assumptions':['Reviewed instruction interpretation and exact canonical runtime extraction/full-runtime instruction-boundary scan are trusted.','Actual reached byte memory is rounded, finite below uint256 modulus and satisfies each represented physical body-frame/array/bytes guard; nonwrapping allocation and adequate execution resources are explicit.','Return labels belong to the full runtime instruction-boundary destination set; valid operand stack and adequate reached gas/memory/execution resources remain explicit.','External lifting preserves returned bytes and observation cursor; physical self-call/target-call observations and complete public dispatch/decoder/callee/serializer composition remain required.','Dafny/Boogie/Z3, solc, Node/Hardhat/EDR and evidence scripts are trusted. No resource availability, gas cost, deployment or whole-contract claim.']}
 lock=threading.Lock()
 def save():
  with lock:(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
 def record(name,cmd,timeout=7200):
  job=common.run(cmd,out/(name+'.log'),timeout);job.update(name=name,passed=job['exitCode']==0)
  with lock:m['checks'].append(job)
  save();return job
 save();record('runtime-identity',[sys.executable,'-B',snapshot/'formal/bytecode/dispatch/identity.py','--contract','Assertions','--solc',solc,'--output',out/'identity'],300)
 g=record('generation',[sys.executable,'-B',source/'generate.py','--output',out/'generated'],300);g['passed']=g['passed'] and all((source/(n+s)).read_bytes()==(out/'generated'/(n+s)).read_bytes() for n in NAMES for s in ['.generated.dfy','.mapping.json']);save()
 if not all(j['passed'] for j in m['checks']):m['status']='failed';save();raise SystemExit('Identity/generation failed; retained evidence')
 def prove(f):
  prefix=re.search(r'^module (\w+)',f.read_text(),re.M)[1];dst=snapshot/f.relative_to(ROOT);csv=out/('proof-'+prefix+'.csv');cmd=common.proof_command(dafny,dst,csv);cmd[cmd.index('--cores')+1]='1';cmd+=['--filter-symbol',prefix,'--progress','Symbol'];job=record('proof-'+prefix,cmd);common.check_proof(job,out/(job['name']+'.log'),csv,getter.inventory(f));save();print(prefix,'passed' if job['passed'] else 'FAILED',len(job['nativeResults']),flush=True);return job
 with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:jobs=list(pool.map(prove,[f for f in closure if re.search(r'^module (\w+)',f.read_text(),re.M)]))
 m['nativeResults']=[r for j in jobs for r in j['nativeResults']];m['declarationResults']=[d for j in jobs for d in j['declarations']];save()
 audit=record('audit',[dafny,'audit',source/'Entry.dfy'],300);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'audit.log').read_text()
 record('format',[dafny,'format','--check',*[snapshot/f.relative_to(ROOT) for f in closure]],300)
 concrete=record('concrete',[node,HERE/'evm-traces.mjs','--root',snapshot,'--output',out/'evm-traces'],300);rows=json.loads((out/'evm-traces/results.json').read_text()) if (out/'evm-traces/results.json').exists() else [];concrete['passed']=concrete['passed'] and len(rows)==28 and all(x['passed'] for x in rows)
 mutation=record('mutations',[sys.executable,'-B',HERE/'mutations.py','--dafny',dafny,'--node',node,'--root',snapshot,'--output',out/'mutations'],900);save()
 m['inputsUnchanged']=all(sha(ROOT/f)==h for f,h in hashes.items());m['status']='passed' if m['inputsUnchanged'] and all(j['passed'] for j in m['checks']) else 'failed';m['finishedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();save();m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in out.rglob('*') if f.is_file() and f.name!='manifest.json' and 'source-snapshot' not in f.parts};save();print(m['status'].upper(),len(m['nativeResults']),'native obligations; no public-entry coverage');raise SystemExit(0 if m['status']=='passed' else 1)
if __name__=='__main__':main()
