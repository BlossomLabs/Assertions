#!/usr/bin/env python3
"""Check exact terminal native-evidence reuse and fail-closed drift gates; no public credit."""
import argparse,copy,datetime,json,re,shutil
from pathlib import Path
import importlib.util
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
if not __debug__:raise RuntimeError('Run without Python -O')
p=argparse.ArgumentParser();p.add_argument('--prior',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
v=load('apply_reuse_preflight',HERE/'verify.py');spec=json.loads((HERE/'proof-spec.json').read_text());closed=v.graph(spec);paths=v.inputs(spec);hashes={str(p.relative_to(ROOT)):v.sha(p) for p in paths}
dafny=Path('/tmp/assertions-dafny-4.11.0/dafny/dafny');tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':dafny.parent/'z3/bin/z3-4.12.1','solc':Path('/home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791')};toolhash={k:v.sha(p) for k,p in tools.items()}
record={'status':'preflight-running','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'executableSha256':toolhash,'checks':[],'scope':'Complete205 prior whole-module native artifacts under identical current700-file original closure, fresh verifier owner and current inventory; no new native proof, full physical/mutation/audit/retained checking still required.'}
def save():(out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n')
save()
for source in paths:
 dest=out/'source-snapshot'/source.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(source,dest)
reused,provenance=v.reuse.prepare(ROOT,a.prior,spec,closed,hashes,toolhash,v.getter,v.common,out)
assert len(reused)==205 and provenance['failedModulesNotReused']==sorted(v.reuse.EXPECTED_TIMEOUTS)
record['priorNativeEvidence']=provenance;record['completeReusedModules']=len(reused);record['nativeObligations']=sum(len(j['nativeResults']) for j in reused.values());record['nativeDeclarations']=sum(len(j['declarations']) for j in reused.values())
record['checks'].append({'name':'complete-terminal-native-reuse-current-closure','passed':True,'modules':len(reused),'originalCapturedInputs':provenance['identicalPriorInputFiles']})
# Wrong proof tools and missing/changed captured inputs must be rejected before any reuse artifacts are written.
for name,bad_hashes,bad_tools in [('reject-tool-drift',hashes,{**toolhash,'z3':'0'*64}),('reject-missing-input',{k:h for k,h in hashes.items() if k!='contracts/Collections.sol'},toolhash),('reject-changed-input',{**hashes,'contracts/Collections.sol':'0'*64},toolhash)]:
 try:v.reuse.prepare(ROOT,a.prior,spec,closed,bad_hashes,bad_tools,v.getter,v.common,out/name)
 except AssertionError:record['checks'].append({'name':name,'passed':True})
 else:raise AssertionError(name+' accepted invalid provenance')
record['inputsUnchanged']=hashes=={str(p.relative_to(ROOT)):v.sha(p) for p in v.inputs(spec)}
record['toolsUnchanged']=toolhash=={k:v.sha(p) for k,p in tools.items()}
record['priorManifestUnchanged']=v.sha(a.prior)==provenance['manifestSha256']
assert record['inputsUnchanged'] and record['toolsUnchanged'] and record['priorManifestUnchanged']
record['status']='preflight-passed-native-reuse-not-retained';record['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();record['evidenceSha256']={str(p.relative_to(out)):v.sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='manifest.json'};save()
print('preflight passed:',len(reused),'complete native modules',record['nativeObligations'],'obligations; original two failed modules not reused;3 drift gates rejected invalid provenance')
