#!/usr/bin/env python3
"""Fresh complete include/native/audit/regeneration closure for one development root."""
import argparse,hashlib,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--root-proof',default='CheckedEntry.dfy');a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
spec=importlib.util.spec_from_file_location('common',ROOT/'formal/constraints/verify.py');common=importlib.util.module_from_spec(spec);spec.loader.exec_module(common)
closed=set()
def visit(path):
 path=path.resolve();assert path.is_relative_to(ROOT) and path.is_file()
 if path in closed:return
 closed.add(path)
 for name in re.findall(r'^include "([^\"]+)"',path.read_text(),re.M):visit(path.parent/name)
visit(HERE/a.root_proof)
files=set(p for p in HERE.iterdir() if p.is_file())|closed|{ROOT/'formal/constraints/verify.py',ROOT/'formal/bytecode/dispatch/inventory.json',ROOT/'artifacts/contracts/Collections.sol/Collections.json',ROOT/'contracts/Collections.sol',ROOT/'contracts/lib/AbiCodec.sol'}
snap=out/'source-snapshot'
for f in sorted(files):
 target=snap/f.relative_to(ROOT);target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,target)
dafny=Path('/tmp/assertions-dafny-4.11.0/dafny/dafny');z3=dafny.parent/'z3/bin/z3-4.12.1'
m={'status':'development-running-not-retained','scope':'Current fitting-calldata accepted sumWords physical instruction/decoder/loop/return/error root closure only. Raw malformed bytes decoder frames, wordIndexOf, retained EVM/mutation/runtime identity/dependency ledger and all other public bytecode entries remain separate. No public coverage update.','rootProof':a.root_proof,'sourceSha256':{str(f.relative_to(ROOT)):sha(f) for f in sorted(files)},'dependencyGraph':sorted(str(f.relative_to(ROOT)) for f in closed),'checks':[],'tools':{n:{'path':str(f),'sha256':sha(f),'version':subprocess.check_output([str(f),'--version'],text=True).strip()} for n,f in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',z3)] if n!='Dafny.dll'}}
m['tools']['Dafny.dll']={'path':str(dafny.parent/'Dafny.dll'),'sha256':sha(dafny.parent/'Dafny.dll')}
def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
def record(name,cmd,timeout=1200):
 j=common.run(cmd,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
save();source=snap/HERE.relative_to(ROOT);generated=out/'generated';generated.mkdir()
for gen in ['generate.py','generate-helpers.py','generate-kernels.py','generate-segments.py','generate-return.py','generate-prefix.py','generate-errors.py']:
 record(gen,[sys.executable,'-B',source/gen,'--output',generated],120)
expected={p.name for p in source.iterdir() if p.is_file() and (p.name.endswith('.generated.dfy') or p.name.endswith('.mapping.json'))};actual={p.name for p in generated.iterdir()};m['regenerationPassed']=expected==actual and all((source/f).read_bytes()==(generated/f).read_bytes() for f in expected);save()
if not m['regenerationPassed'] or not all(j['passed'] for j in m['checks']):m['status']='development-generation-failed';save();raise SystemExit(1)
declarations=[]
for f in sorted(closed):
 s=f.read_text();module=re.search(r'^module (\w+)',s,re.M)[1]
 declarations.extend({'name':module+'.'+x[2],'kind':x[1],'file':str(f.relative_to(ROOT))} for x in re.finditer(r'^  (?:(?:ghost|opaque) )*(lemma|method|function|predicate|type)(?: \{:[^}]+\})* (\w+)(?:\(| =)',s,re.M))
root=source/a.root_proof;csv=out/'proof.csv';j=record('proof',common.proof_command(dafny,root,csv)+['--filter-symbol','Bytecode','--progress','Symbol'],7200);common.check_proof(j,out/'proof.log',csv,declarations);save()
j=record('audit',[dafny,'audit',root],180);j['passed']=j['passed'] and 'auditor completed with 0 findings' in (out/'audit.log').read_text();save()
m['inputsUnchanged']=all(sha(f)==m['sourceSha256'][str(f.relative_to(ROOT))] for f in files);m['nativeObligations']=len(next(j for j in m['checks'] if j['name']=='proof')['nativeResults']);m['status']='development-full-native-closure-passed-not-retained' if m['inputsUnchanged'] and all(j['passed'] for j in m['checks']) else 'development-full-native-closure-failed';save();print(m['status'],m['nativeObligations'],flush=True)
raise SystemExit(0 if m['status']=='development-full-native-closure-passed-not-retained' else 1)
