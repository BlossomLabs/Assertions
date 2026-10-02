#!/usr/bin/env python3
"""Retain complete current native/physical address length-rejection evidence."""
import argparse,csv,datetime,hashlib,importlib.util,json,os,re,shutil,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def graph(path):
 seen=set()
 def visit(p):
  p=p.resolve()
  if p in seen:return
  assert p.is_relative_to(ROOT);seen.add(p)
  for name in re.findall(r'^include "([^"]+)"',p.read_text(),re.M):visit(p.parent/name)
 visit(path);return sorted(seen)
def inventory(paths):
 rows=[]
 for p in paths:
  module=re.search(r'^module (\w+)',p.read_text(),re.M)[1]
  for m in re.finditer(r'^  (?:(?:ghost|opaque) )?(lemma|method|function|predicate|type)(?: \{:[^}]+\})* (\w+)(?:\(| =)',p.read_text(),re.M):rows.append({'name':module+'.'+m[2],'kind':m[1],'file':str(p.relative_to(ROOT))})
 return rows
def main():
 p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--node',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 dafny,solc,node=[x.resolve() for x in (a.dafny,a.solc,a.node)];os.environ['DAFNY']=str(dafny)
 spec=importlib.util.spec_from_file_location('common',ROOT/'formal/constraints/verify.py');common=importlib.util.module_from_spec(spec);spec.loader.exec_module(common)
 sources=graph(HERE/'AddressConnection.dfy');files=set(sources)|{HERE/x for x in ['generate-address.py','verify-address.py','evm-address-traces.mjs','AddressLength.mapping.json']}|{ROOT/'formal/constraints/verify.py',ROOT/'formal/bytecode/unknown/format-generated.py',ROOT/'formal/bytecode/dispatch/identity.py',ROOT/'proof-workspace/work/expressions/prepare-address-faults.py'}
 identities=json.loads((HERE/'identity-20261002/identity.json').read_text())[0]
 files|={ROOT/x for x in identities['sourceSha256']}|{ROOT/'artifacts/contracts/Expressions.sol/Expressions.json',ROOT/'artifacts/build-info'/(identities['buildInfoId']+'.json'),ROOT/'pnpm-lock.yaml',ROOT/'hardhat.config.ts',ROOT/'package.json',ROOT/'formal/abi/toolchain.json'}
 hashes={str(f.relative_to(ROOT)):sha(f) for f in sorted(files)};snap=out/'source-snapshot'
 for f in sorted(files):
  dst=snap/f.relative_to(ROOT);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dst)
 source=snap/HERE.relative_to(ROOT);tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':dafny.parent/'z3/bin/z3-4.12.1','solc':solc,'node':node}
 m={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'contracts':['Expressions'],'publicEntries':[],'scope':'Complete _address length != 32 physical path (39 instructions), exact InvalidNode(index) bytes. Length32, ABI decoder, caller/evaluator composition and public entries remain open.','sourceSha256':hashes,'includeClosure':[str(f.relative_to(ROOT)) for f in sources],'executableSha256':{k:sha(v) for k,v in tools.items()},'versions':{k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in tools.items() if k!='Dafny.dll'},'checks':[],'assumptions':['Reviewed exact EVM instruction semantics, word/memory projection and compiler extraction are trusted.','Rounded actual nonwrapping bytes object, physical free-memory pointer at least128, valid stack/return label and adequate reached resources.','No gas, unconditional termination, whole helper, whole public entry or whole contract claim.','Native proof, physical replay and semantic fault evidence establish only the explicitly named class.']}
 def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
 def record(name,cmd,timeout=7200):
  r=common.run(cmd,out/(name+'.log'),timeout);r.update(name=name,passed=r['exitCode']==0);m['checks'].append(r);save();return r
 save()
 identity=record('runtime-identity',[sys.executable,'-B',ROOT/'formal/bytecode/dispatch/identity.py','--contract','Expressions','--solc',solc,'--output',out/'identity'],300)
 generated=record('generation',[sys.executable,'-B',source/'generate-address.py','--runtime',out/'identity/Expressions.runtime.bin','--output',out/'generated'],300)
 generated['passed']=generated['passed'] and all((out/'generated'/x).read_bytes()==(source/x).read_bytes() for x in ['AddressLength.generated.dfy','AddressLength.mapping.json']);save()
 if not identity['passed'] or not generated['passed']:m['status']='failed';save();raise SystemExit('Identity/generation failure')
 proof=record('proof',common.proof_command(dafny,source/'AddressConnection.dfy',out/'proof.csv'))
 common.check_proof(proof,out/'proof.log',out/'proof.csv',inventory(sources));m['nativeResults']=proof.get('nativeResults',[]);m['declarationResults']=proof.get('declarations',[]);save()
 audit=record('audit',[dafny,'audit',source/'AddressConnection.dfy'],300);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'audit.log').read_text()
 record('format',[dafny,'format','--check',*[snap/f.relative_to(ROOT) for f in sources]],300)
 physical=record('physical',[node,HERE/'evm-address-traces.mjs','--root',ROOT,'--mapping-dir',source,'--output',out/'physical'],300);rows=json.loads((out/'physical/results.json').read_text()) if (out/'physical/results.json').exists() else [];physical['passed']=physical['passed'] and len(rows)==4 and all(x['passed'] and x['physical']['states']==39 for x in rows);save()
 prep=record('fault-preparation',[sys.executable,ROOT/'proof-workspace/work/expressions/prepare-address-faults.py','--output',out/'faults'],300)
 if prep['passed']:
  for fault in json.loads((out/'faults/preparation.json').read_text()):
   name=fault['name'];d=out/'faults'/name;native=record('fault-'+name+'-native',common.proof_command(dafny,Path(fault['nativeSource']),d/'proof.csv')+['--filter-symbol','ExpressionsAddressConnection.RejectLength'],300)
   log=(out/('fault-'+name+'-native.log')).read_text();native['passed']=native['exitCode']!=0 and bool(re.search(r'Error: (?:assertion might not hold|a postcondition could not be proved)',log)) and not re.search(r'time.?out|inconclusive|resource limit|resolution/type errors|parse errors',log,re.I)
   phys=record('fault-'+name+'-physical',[node,HERE/'evm-address-traces.mjs','--root',ROOT,'--runtime',d/'Expressions.runtime.bin','--mapping-dir',d/'source-snapshot/formal/bytecode/expressions','--output',d/'physical'],300)
   rr=json.loads((d/'physical/results.json').read_text()) if (d/'physical/results.json').exists() else [];phys['passed']=phys['exitCode']!=0 and len(rr)==4 and all(not x['receiptPassed'] and x['physical']['passed'] for x in rr);save()
 m['inputsUnchanged']=all((ROOT/f).is_file() and sha(ROOT/f)==h for f,h in hashes.items());m['status']='passed' if m['inputsUnchanged'] and all(x['passed'] for x in m['checks']) else 'failed';m['finishedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in out.rglob('*') if f.is_file() and f.name!='manifest.json' and 'source-snapshot' not in f.parts};save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)
if __name__=='__main__':main()
