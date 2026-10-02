#!/usr/bin/env python3
"""Retain and recheck an exact composed whole-address native/physical candidate.
No inherited method is accepted without identical transitive source/tool hashes.
"""
import argparse,csv,datetime,hashlib,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def graph(p):
 seen=set()
 def visit(f):
  f=f.resolve()
  if f in seen:return
  seen.add(f)
  for inc in re.findall(r'^include "([^"]+)"',f.read_text(),re.M):visit(f.parent/inc)
 visit(p);return sorted(seen)
def declarations(paths):
 rows=[]
 for f in paths:
  module=re.search(r'^module (\w+)',f.read_text(),re.M)[1]
  for d in re.finditer(r'^  (?:(?:ghost|opaque) )?(lemma|method|function|predicate|type)(?: \{:[^}]+\})* (\w+)(?:\(| =)',f.read_text(),re.M):rows.append({'name':module+'.'+d[2],'kind':d[1],'file':str(f.relative_to(ROOT))})
 return rows
def native(csvfile,logfile):
 rows=list(csv.DictReader(csvfile.open()));log=logfile.read_text();summary=re.search(r'Dafny program verifier finished with (\d+) verified, (\d+) errors?',log)
 assert summary and int(summary[1])==len(rows) and int(summary[2])==0 and rows and all(r['TestResult.Outcome']=='Passed' for r in rows) and not re.search(r'time.?out|inconclusive|resource limit|Error:',log,re.I),str(logfile)
 return rows
p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--node',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--development',type=Path,default=HERE/'complete-development-20261002-v8a');p.add_argument('--faults',type=Path,default=HERE/'whole-address-faults-development-20261002-v5');a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False);dev=a.development.resolve();faults=a.faults.resolve();dafny=a.dafny.resolve();solc=a.solc.resolve();node=a.node.resolve();tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':dafny.parent/'z3/bin/z3-4.12.1','solc':solc,'node':node};toolhash={k:sha(v) for k,v in tools.items()}
spec=importlib.util.spec_from_file_location('common',ROOT/'formal/constraints/verify.py');common=importlib.util.module_from_spec(spec);spec.loader.exec_module(common)
closure=graph(dev/'ConnectionV2.dfy');inventory=declarations(closure);files=set(closure)|{HERE/'generate-address-complete-v8-development.py',HERE/'evm-address-complete-development.mjs',Path(__file__).resolve(),ROOT/'formal/constraints/verify.py',ROOT/'formal/bytecode/unknown/format-generated.py',ROOT/'formal/bytecode/dispatch/identity.py',ROOT/'proof-workspace/work/expressions/prepare-whole-address-faults.py',ROOT/'proof-workspace/work/expressions/build-context-bridge-v2.py'}|set(dev.glob('*native-receipt.json'))|{dev/'generator.py',dev/'Address.mapping.json',dev/'AddressDirty.mapping.json'}
identity=json.loads((HERE/'identity-20261002/identity.json').read_text())[0];files|={ROOT/f for f in identity['sourceSha256']}|{ROOT/'artifacts/contracts/Expressions.sol/Expressions.json',ROOT/'artifacts/build-info'/(identity['buildInfoId']+'.json'),ROOT/'formal/abi/toolchain.json',ROOT/'package.json',ROOT/'pnpm-lock.yaml',ROOT/'hardhat.config.ts'}
priorpath=HERE/'evidence/address-length-20261002-v1/manifest.json';prior=json.loads(priorpath.read_text());assert prior['status']=='passed'
for name,digest in prior['executableSha256'].items():assert toolhash[name]==digest,'dependency tool '+name
for f,digest in prior['sourceSha256'].items():assert sha(ROOT/f)==digest,'dependency source '+f
for f,digest in prior['evidenceSha256'].items():assert sha(priorpath.parent/f)==digest,'dependency artifact '+f
files.add(priorpath);hashes={str(f.relative_to(ROOT)):sha(f) for f in sorted(files)};snap=out/'source-snapshot'
for f in sorted(files):dst=snap/f.relative_to(ROOT);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dst)
m={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'contracts':['Expressions'],'publicEntries':[],'scope':'Complete _address helper at runtime PC5440: all length/range classes, exact InvalidNode(index), clean address word, complete default Context allocation/span-check/load instructions. Caller/evaluator/public ABI composition remains open.','sourceSha256':hashes,'includeClosure':[str(f.relative_to(ROOT)) for f in closure],'executableSha256':toolhash,'versions':{k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in tools.items() if k!='Dafny.dll'},'checks':[],'assumptions':['Reviewed EVM semantics, compiler extraction and byte-memory projection are trusted.','Admitted physical bytes object and disjoint allocator, rounded nonwrapping memory, valid stack/return destination, adequate reached resources.','No gas, unconditional termination, public-entry or whole-contract credit.','Shared exact native closure is reused only after all source/tool/evidence/declaration checks.']}
def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
def record(name,cmd,timeout=300):
 r=common.run(cmd,out/(name+'.log'),timeout);r.update(name=name,passed=r['exitCode']==0);m['checks'].append(r);save();return r
save();nativeRows=[];nativeReceipts=[]
for stem,source in [('dirty',dev/'AddressDirty.generated.dfy'),('clean',dev/'Address.generated.dfy'),('bridge-v2',dev/'ConnectionV2.dfy')]:
 receipt=json.loads((dev/(stem+'-native-receipt.json')).read_text())
 for f,digest in receipt['sourceSha256'].items():assert sha(ROOT/f)==digest,'local source '+f
 for name,digest in receipt['executableSha256'].items():assert toolhash[name]==digest,'local tool '+name
 for f,digest in receipt['evidenceSha256'].items():assert sha(dev/f)==digest,'local artifact '+f
 rows=native(dev/(stem+'-proof.csv'),dev/(stem+'-proof.log'));nativeRows.extend(rows);dest=out/'native'/stem;dest.mkdir(parents=True)
 for suffix in ['-proof.csv','-proof.log','-native-receipt.json']:shutil.copy2(dev/(stem+suffix),dest/(stem+suffix))
 nativeReceipts.append({'name':stem,'receipt':str((dev/(stem+'-native-receipt.json')).relative_to(ROOT)),'sha256':sha(dev/(stem+'-native-receipt.json')),'nativeRows':len(rows),'cores':receipt['cores'],'passed':True})
priorRows=prior['nativeResults'];priorDecl={d['name']:d for d in prior['declarationResults']};assert all(r['TestResult.Outcome']=='Passed' for r in priorRows)
reused=[]
for f in closure:
 needed=declarations([f]);own=[d for d in needed if d['name'].startswith(('ExpressionsPrimitiveAddress.','ExpressionsPrimitiveAddressDirty.','ExpressionsWholeAddressConnection.','ExpressionsAddressCompleteFrameFacts.'))]
 if own:continue
 assert all(prior['sourceSha256'].get(str(dep.relative_to(ROOT)))==sha(dep) for dep in graph(f)),'dependency transitive '+str(f)
 assert all(d['name'] in priorDecl and priorDecl[d['name']]['file']==d['file'] and (d['kind'] not in ['lemma','method'] or priorDecl[d['name']]['status']=='passed') for d in needed if d['kind']!='type'),'dependency inventory '+str(f)
 reused.append(str(f.relative_to(ROOT)))
shutil.copy2(priorpath,out/'dependency-address-length.json');nativeRows.extend(r for r in priorRows if r['TestResult.DisplayName'].split(' (')[0] in {d['name'] for d in inventory})
results=[]
for d in inventory:
 batches=[r for r in nativeRows if r['TestResult.DisplayName'].split(' (')[0]==d['name']];results.append(dict(d,status='passed' if batches else 'definition-only',batches=len(batches)))
assert all(d['status']=='passed' for d in results if d['kind'] in ['lemma','method'])
assert all(any(r['TestResult.DisplayName'].split(' (')[0]==d['name'] for d in inventory) for r in nativeRows)
m['nativeResults']=nativeRows;m['declarationResults']=results;m['checks']+=[{'name':'composed-native-closure','passed':True,'localReceipts':nativeReceipts,'dependencyManifest':str(priorpath.relative_to(ROOT)),'dependencyManifestSha256':sha(priorpath),'reusedModules':reused,'nativeRows':len(nativeRows),'distinctNativeBatches':len({r['TestResult.DisplayName'] for r in nativeRows}),'uniqueDeclarations':len(inventory),'maximumObservedCores':max(r['cores'] for r in nativeReceipts),'verificationTimeLimitSeconds':30}];save()
runtime=record('runtime-identity',[sys.executable,'-B',ROOT/'formal/bytecode/dispatch/identity.py','--contract','Expressions','--solc',solc,'--output',out/'identity'])
regenerated=out/'regenerated-snapshot'/dev.relative_to(ROOT)
for f in closure:
 dst=out/'regenerated-snapshot'/f.relative_to(ROOT);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dst)
gen=record('generation',[sys.executable,'-B',HERE/'generate-address-complete-v8-development.py','--runtime',out/'identity/Expressions.runtime.bin','--output',regenerated])
gen['passed']=gen['passed'] and all((regenerated/f).read_bytes()==(dev/f).read_bytes() for f in ['Address.generated.dfy','Address.mapping.json','AddressDirty.generated.dfy','AddressDirty.mapping.json']);save()
audit=record('audit',[dafny,'audit',snap/(dev/'ConnectionV2.dfy').relative_to(ROOT)]);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'audit.log').read_text();save()
record('format',[dafny,'format','--check',*[snap/f.relative_to(ROOT) for f in closure]])
physical=record('physical',[node,HERE/'evm-address-complete-development.mjs','--root',ROOT,'--mapping-dir',snap/dev.relative_to(ROOT),'--output',out/'physical']);physicalRows=json.loads((out/'physical/results.json').read_text());physical['passed']=physical['passed'] and len(physicalRows)==5 and all(r['physical']['passed'] and r['frame']['passed'] and r['receiptPassed'] and r['kernelPassed'] for r in physicalRows);save()
for fault in json.loads((faults/'preparation.json').read_text()):
 name=fault['name'];d=faults/name;assert fault['generationExitCode']==0
 log=(d/'native.log').read_text();csvrows=list(csv.DictReader((d/'native.csv').open()));summary=re.search(r'Dafny program verifier finished with (\d+) verified, (\d+) errors?',log)
 semantic=bool(summary and int(summary[2])>0 and any(r['TestResult.Outcome']!='Passed' for r in csvrows) and re.search(r'Error: (?:assertion might not hold|a postcondition could not be proved)',log) and not re.search(r'time.?out|inconclusive|resource limit|resolution/type errors|parse errors',log,re.I))
 rr=json.loads((d/'physical/results.json').read_text());faithful=len(rr)==1 and all(not r['receiptPassed'] and r['physical']['passed'] and r['kernelPassed'] for r in rr)
 shutil.copytree(d,out/'faults'/name);m['checks'].append({'name':'fault-'+name,'passed':semantic and faithful,'fault':fault,'nativeRows':len(csvrows),'semanticNativeFailure':semantic,'faithfulPhysicalMapping':faithful,'sourceSha256':{str(f.relative_to(d)):sha(f) for f in d.rglob('*') if f.is_file() and 'source-snapshot' in f.parts},'runtimeSha256':sha(d/'Expressions.runtime.bin')});save()
m['inputsUnchanged']=all(sha(ROOT/f)==h for f,h in hashes.items());m['status']='passed' if m['inputsUnchanged'] and all(r['passed'] for r in m['checks']) else 'failed';m['finishedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in out.rglob('*') if f.is_file() and f.name!='manifest.json' and 'source-snapshot' not in f.parts};save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)
