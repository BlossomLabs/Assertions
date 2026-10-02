#!/usr/bin/env python3
"""Explicit repair of the completed closure's sole whitespace-format race."""
import sys,os,json,re,shutil,datetime,subprocess,csv,importlib.util
from pathlib import Path
HERE=Path(__file__).resolve().parent.parent;ROOT=HERE.parents[3];prior=HERE/'evidence/public-raw-v1';out=Path(sys.argv[1]).resolve();out.mkdir(parents=True,exist_ok=False)
def module(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
g=module('control',HERE.parent/'verify.py');common=g.common;getter=g.getter;sha=g.sha;old=json.loads((prior/'manifest.json').read_text());assert old['status']=='failed' and old['generationIdentical'] and all(x['passed'] for x in old['checks'] if x['name']!='format')
changed='formal/bytecode/assertions-primitives-control/cond-class/FirstWord.dfy';oldFile=prior/'source-snapshot'/changed;newFile=ROOT/changed
assert oldFile.read_bytes()!=newFile.read_bytes() and [x.lstrip() for x in oldFile.read_text().splitlines()]==[x.lstrip() for x in newFile.read_text().splitlines()]
assert all(sha(ROOT/f)==h for f,h in old['sourceSha256'].items() if f!=changed);assert all(sha(prior/'source-snapshot'/f)==h for f,h in old['sourceSha256'].items())
snapshot=out/'source-snapshot';shutil.copytree(prior/'source-snapshot',snapshot);shutil.copy2(newFile,snapshot/changed);repairPath=Path(__file__).resolve();dst=snapshot/repairPath.relative_to(ROOT);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(repairPath,dst)
closure=[ROOT/f for f in old['includeClosure']];changedFile=ROOT/changed;rerun=[f for f in closure if changedFile in g.graph(f) and re.search(r'^module (\w+)',f.read_text(),re.M)];rerunNames={re.search(r'^module (\w+)',f.read_text(),re.M)[1] for f in rerun};assert len(rerun)==4
manifest=json.loads(json.dumps(old));manifest.update(status='incomplete',startedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),checks=[j for j in old['checks'] if j['name'] not in {'format'}|{'proof-'+n for n in rerunNames}],repair={'priorFailedManifest':str((prior/'manifest.json').relative_to(ROOT)),'priorFailedManifestSha256':sha(prior/'manifest.json'),'reason':'Formatter shell had not finished before v1 snapshot. Only two leading-indentation lines in FirstWord.dfy drifted; prior completed native closure and semantic gates are preserved. Exact formatted FirstWord plus every module whose transitive include graph reaches it is freshly verified. Other63 modules have byte-identical transitive input graphs and retain their successful native evidence.','changedVerifiedSourceFiles':[{'file':changed,'beforeSha256':old['sourceSha256'][changed],'afterSha256':sha(newFile),'leadingWhitespaceOnly':True}],'freshDependentModules':sorted(rerunNames),'reusedUnchangedModules':63});manifest['sourceSha256'][changed]=sha(newFile);manifest['sourceSha256'][str(repairPath.relative_to(ROOT))]=sha(repairPath);manifest['proofMode']='Complete modular native closure:63 unchanged per-file native dependency graphs retained from v1;4 changed/dependent modules verified freshly against the formatted repaired snapshot. Exact whitespace-only change and all prior failed evidence are explicit.'
manifest.pop('nativeResults',None);manifest.pop('declarationResults',None);manifest.pop('evidenceSha256',None);manifest.pop('finishedAt',None)
dafny=Path('/home/sem/assertions-tools/dafny/dafny');node=Path('/home/sem/assertions-tools/node-v24.14.0-linux-x64/bin/node');solc=Path('/home/sem/assertions-tools/solc-0.8.36');tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':dafny.parent/'z3/bin/z3-4.12.1','solc':solc,'node':node};assert all(sha(v)==old['executableSha256'][k] for k,v in tools.items());os.environ['DAFNY']=str(dafny)
def save():(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
def record(name,cmd,timeout=7200):
 j=common.run(cmd,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);manifest['checks'].append(j);save();return j
save()
for f in rerun:
 name=re.search(r'^module (\w+)',f.read_text(),re.M)[1];file=snapshot/f.relative_to(ROOT);csvfile=out/('proof-'+name+'.csv');cmd=common.proof_command(dafny,file,csvfile);cmd[cmd.index('--cores')+1]='1';cmd+=['--filter-symbol',name,'--filter-position',str(file),'--progress','Symbol'];j=record('proof-'+name,cmd);common.check_proof(j,out/('proof-'+name+'.log'),csvfile,getter.inventory(f));save();print(name,len(j['nativeResults']),'passed' if j['passed'] else 'FAILED',flush=True)
record('repaired-literal-runtime-binding',[sys.executable,'-B',snapshot/HERE.relative_to(ROOT)/'binding.py',snapshot,out/'manifest.json'],300)
# Check every concrete chunk inventory against real instruction boundaries, too.
code=bytes.fromhex(json.loads((snapshot/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);dest=set();pc=0
while pc<len(code):
 op=code[pc]
 if op==91:dest.add(pc)
 pc+=1+(op-95 if 96<=op<=127 else 0)
count=0
for f in closure:
 text=(snapshot/f.relative_to(ROOT)).read_text()
 for body in re.findall(r'(?:opaque )?function (?:Chunk\d+|DestinationsChunk\d+)\(\): set<nat> \{ \{([^}]+)\}',text):
  labels={int(x) for x in re.findall(r'\b\d+\b',body)};assert labels<=dest;count+=len(labels)
(snapshot.parent/'chunk-runtime-binding.json').write_text(json.dumps({'runtimeSha256':__import__('hashlib').sha256(code).hexdigest(),'runtimeDestinations':len(dest),'boundChunkLabels':count,'passed':True},indent=2)+'\n');manifest['checks'].append({'name':'scanned-chunk-runtime-binding','passed':len(dest)==1049 and count==2098,'exitCode':0});save()
audit=record('repaired-audit',[dafny,'audit',snapshot/HERE.relative_to(ROOT)/'Entry.dfy'],300);audit['passed'] &= 'auditor completed with 0 findings' in (out/'repaired-audit.log').read_text();record('format',[dafny,'format','--check',*[snapshot/f.relative_to(ROOT) for f in closure]],300)
concrete=record('repaired-concrete',[node,HERE/'evm-traces.mjs','--root',snapshot,'--output',out/'evm-traces'],300);rows=json.loads((out/'evm-traces/results.json').read_text());concrete['passed'] &= len(rows)==34 and all(x['passed'] for x in rows);manifest['concreteToolchain']=json.loads((out/'evm-traces/toolchain.json').read_text())
proofs=[j for j in manifest['checks'] if j['name'].startswith('proof-')];assert len(proofs)==67;manifest['nativeResults']=[r for j in proofs for r in j['nativeResults']];manifest['declarationResults']=[d for j in proofs for d in j['declarations']];manifest['inputsUnchanged']=all(sha(ROOT/f)==h and sha(snapshot/f)==h for f,h in manifest['sourceSha256'].items());manifest['toolsUnchanged']=all(sha(v)==manifest['executableSha256'][k] for k,v in tools.items());ct=manifest['concreteToolchain'];manifest['concreteToolsUnchanged']=all(sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['hardhatEntry','edrEntry','nativeBinding']) and sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'];manifest['status']='passed' if manifest['inputsUnchanged'] and manifest['toolsUnchanged'] and manifest['concreteToolsUnchanged'] and all(j['passed'] for j in manifest['checks']) else 'failed';manifest['finishedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();save();manifest['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in out.rglob('*') if f.is_file() and f.name!='manifest.json' and 'source-snapshot' not in f.parts};save();print(manifest['status'],len(manifest['nativeResults']),flush=True);raise SystemExit(0 if manifest['status']=='passed' else 1)
