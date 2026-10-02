#!/usr/bin/env python3
"""Retain full fitting-calldata word-index entry evidence; never edit production artifacts."""
import argparse,concurrent.futures,csv,datetime,importlib.util,json,re,shutil,subprocess,sys,threading
from pathlib import Path
if not __debug__:raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];SCANS=HERE;PROOF=SCANS/'raw-decoder/Connection.dfy'
def module(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
getter=module('getter',ROOT/'formal/bytecode/getters/verify.py');common=getter.common;sha=common.sha
DEPENDENCY=ROOT/'formal/bytecode/rejections/evidence/operations-guard-current-inputs-v2/manifest.json'
def graph():
 closed=set()
 def visit(p):
  p=p.resolve();assert p.is_relative_to(ROOT) and p.is_file()
  if p in closed:return
  closed.add(p)
  for name in re.findall(r'^include "([^"]+)"',p.read_text(),re.M):visit(p.parent/name)
 visit(PROOF);return sorted(closed)
def inputs():
 files=set(getter.inputs())|set(graph())|{p for folder in [HERE,SCANS,SCANS/'raw-decoder',ROOT/'formal/bytecode/rejections'] for p in folder.iterdir() if p.is_file()}
 files|={DEPENDENCY,ROOT/'scripts/check-raw-rejections-bytecode-evidence.py',ROOT/'docs/verification/raw-rejections-bytecode.json',ROOT/'scripts/check-constant-getters-bytecode-evidence.py',ROOT/'docs/verification/constant-getters-bytecode.json'}
 return sorted(files)
def dependency_hashes():
 dep=json.loads(DEPENDENCY.read_text());assert dep['status']=='passed' and dep['inputsUnchanged'] and all(j['passed'] for j in dep['checks'])
 files={DEPENDENCY}|{DEPENDENCY.parent/p for p in dep['evidenceSha256']}
 return {str(p.relative_to(ROOT)):sha(p) for p in sorted(files)}
def main():
 p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 dafny,solc=a.dafny.resolve(),a.solc.resolve();z3=dafny.parent/'z3/bin/z3-4.12.1';tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':z3,'solc':solc};versions={k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in tools.items() if k!='Dafny.dll'}
 assert versions['dafny']==json.loads((ROOT/'formal/abi/toolchain.json').read_text())['dafnyVersion'] and '4.12.1' in versions['z3'] and '0.8.36+commit.8a079791' in versions['solc']
 frozen=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections'];assert frozen['methodIdentifiers']['wordIndexOf(bytes,bytes32)']=='e8bc8883'
 paths=inputs();hashes={str(f.relative_to(ROOT)):sha(f) for f in paths};dependencies=dependency_hashes();snap=out/'source-snapshot'
 for f in paths:
  dest=snap/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dest)
 source=snap/HERE.relative_to(ROOT);scans=snap/SCANS.relative_to(ROOT);closed=graph();lock=threading.Lock()
 m={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Exact current Collections.wordIndexOf runtime from PC zero through actual raw bytes decoder, unbounded fitting least-match word loop, checked arithmetic/slice/read helpers and physical RETURN/UnalignedWords or empty ABI rejection. Assigned selector, zero value and calldata size from four through 2^64-1. Nonpayable/short rejection remains the independently checked retained dependency. Other public bodies and whole-contract completion remain open.','publicEntries':['Collections.wordIndexOf(bytes,bytes32)'],'sourceSha256':hashes,'dependencyEvidenceSha256':dependencies,'dependencyGraph':{str(f.relative_to(ROOT)):sha(f) for f in closed},'rootProof':str(PROOF.relative_to(ROOT)),'versions':versions,'executableSha256':{k:sha(v) for k,v in tools.items()},'checks':[],'assumptions':[
 'Reviewed exact runtime/input extraction, full-runtime instruction-boundary scanning and reached EVM opcode interpretation remain trusted; jumps in local traces must denote actual instruction boundaries. Faithful CALLVALUE/CALLDATASIZE/CALLDATALOAD observations, fresh memory and adequate reached execution/allocation/stack resources are explicit. No gas/resource-availability theorem.',
 'This native root admits zero call value, calldata size at least four and below 2^64, and SHR(CALLDATALOAD(0),224) equal to compiler-bound wordIndexOf selector. Every malformed bytes frame within that representation is classified and physically rejected; accepted loose offsets, noncanonical bytes padding and trailing bytes are allowed. Nonzero/short classes have independent immutable retained evidence; no silent claim for calldata size at least 2^64.',
 'Loop count-index proves every reached word before the first match or count sentinel is executed, without fuel, a fixture bound or dropped input path. Least and First characterize the first actual full-width big-endian calldata word equal to the needle. Alignment is a checked outcome. Exact empty decoder rejection, UnalignedWords(length) and 32-byte least index or count sentinel use actual physical stores and return/revert slices, not compiler/allocator/serializer assumptions.',
 'Dafny/Boogie/Z3, solc reproduction, Node/Hardhat/EDR and reviewed scripts are trusted. All reached include graph declarations must have native/CSV evidence, zero audit, fixed regeneration and tool/source/runtime/dependency closure. Three semantic bytecode faults require baseline-covered native postcondition failure and contradictory EVM receipts; timeout, typing failure and generation rejection are not detections.',
 'No source-to-whole-bytecode equivalence, gas, deployment, complexity, performance, unrestricted representation or unconditional resource-safety claim. Coverage may update only after retained evidence and a current checker pass.'
 ]}
 def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
 def record(name,cmd,timeout=1200):
  j=common.run(cmd,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0)
  with lock:m['checks'].append(j);save()
  return j
 save();record('dependency-before',[sys.executable,'-B',ROOT/'scripts/check-raw-rejections-bytecode-evidence.py'],300)
 record('runtime-identity',[sys.executable,'-B',snap/'formal/bytecode/dispatch/identity.py','--solc',solc,'--output',out/'identity'],300)
 generated=out/'generated';generated.mkdir()
 for gen in ['generate-decoder.py','generate-kernels.py','generate-segments.py','generate-return.py','generate-prefix.py','generate-errors.py']:
  record('generation-'+gen,[sys.executable,'-B',scans/gen,'--output',generated],180)
 expected={f.name for f in scans.iterdir() if f.is_file() and (f.name.endswith('.generated.dfy') or f.name.endswith('.mapping.json'))}
 m['regenerationPassed']=expected=={f.name for f in generated.iterdir()} and all((scans/f).read_bytes()==(generated/f).read_bytes() for f in expected)
 rawgen=out/'generated-raw';g=record('generation-raw',[sys.executable,'-B',scans/'raw-decoder/generate.py','--output',rawgen],180);rawexpected={f.name for f in (scans/'raw-decoder').iterdir() if f.name.endswith('.generated.dfy') or f.name.endswith('.mapping.json')};m['rawRegenerationPassed']=rawexpected=={f.name for f in rawgen.iterdir()} and all((scans/'raw-decoder'/f).read_bytes()==(rawgen/f).read_bytes() for f in rawexpected);save()
 if not m['regenerationPassed'] or not m['rawRegenerationPassed'] or not all(j['passed'] for j in m['checks']):m['status']='failed';save();raise SystemExit('Dependency/identity/generation failed')
 record('format',[dafny,'format','--check',*[snap/f.relative_to(ROOT) for f in closed]],180)
 def prove(path):
  rel=path.relative_to(ROOT);file=snap/rel;mod=re.search(r'^module (\w+)',file.read_text(),re.M)[1];csvpath=out/('proof-'+mod+'.csv');j=record('proof-'+mod,common.proof_command(dafny,file,csvpath)+['--filter-symbol',mod,'--progress','Symbol'],1800);common.check_proof(j,out/('proof-'+mod+'.log'),csvpath,getter.inventory(path))
  with lock:save()
  return j
 with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:jobs=list(pool.map(prove,closed))
 audit=record('audit',[dafny,'audit',snap/PROOF.relative_to(ROOT)],240);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'audit.log').read_text();save()
 evm=record('concrete',[shutil.which('node'),HERE/'evm-traces.mjs','--output',out/'evm-traces','--root',snap],240);receipts=json.loads((out/'evm-traces/results.json').read_text()) if (out/'evm-traces/results.json').is_file() else [];evm['passed']=evm['passed'] and len(receipts)==26 and len({r['name'] for r in receipts})==26 and all(r['passed'] and r['receiptPassed'] for r in receipts);m['concreteToolchain']=json.loads((out/'evm-traces/toolchain.json').read_text()) if (out/'evm-traces/toolchain.json').is_file() else {};save()
 record('candidate-generation',[sys.executable,'-B',source/'make-candidates.py','--output',out/'candidates'],180);candidates=json.loads((out/'candidates/candidates.json').read_text());faults=[]
 for candidate in candidates:
  name=candidate['name'];folder=out/'mutations'/name;folder.mkdir(parents=True);work=folder/'source-snapshot';shutil.copytree(snap,work);runtime=out/'candidates'/candidate['runtime'];artifact=work/'artifacts/contracts/Collections.sol/Collections.json';obj=json.loads(artifact.read_text());obj['deployedBytecode']='0x'+runtime.read_bytes().hex();artifact.write_text(json.dumps(obj,indent=2)+'\n');pin=work/'formal/bytecode/dispatch/inventory.json';obj=json.loads(pin.read_text());obj['Collections']['runtimeSha256']=sha(runtime);pin.write_text(json.dumps(obj,indent=2)+'\n')
  candidate_scans=work/'formal/bytecode/word-index';translation=record(name+'-generation',[sys.executable,'-B',candidate_scans/candidate['generator'],'--output',candidate_scans],180)
  file=candidate_scans/candidate['source'];lines=file.read_text().splitlines();method=candidate['nativeSymbol'].split('.')[-1];start=next(i for i,l in enumerate(lines) if 'lemma '+method+'(' in l);anchor=next(i for i in range(start,len(lines)) if 'ensures var next :=' in lines[i]);baseline=next(j for j in jobs if any(d['name']==candidate['nativeSymbol'] for d in j['declarations']));assert next(d for d in baseline['declarations'] if d['name']==candidate['nativeSymbol'])['status']=='passed'
  native=record(name+'-native',common.proof_command(dafny,file,folder/'proof.csv')+['--filter-symbol',candidate['nativeSymbol'],'--filter-position',str(file)+':'+str(anchor+1),'--progress','Symbol'],240);text=(out/(name+'-native.log')).read_text();rows=list(csv.DictReader((folder/'proof.csv').open())) if (folder/'proof.csv').is_file() else [];native['passed']=native['exitCode'] not in [0,None] and bool(rows) and any(r['TestResult.Outcome']=='Failed' for r in rows) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in rows) and 'postcondition could not be proved' in text and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',text,re.I)
  fault_evm=record(name+'-concrete',[shutil.which('node'),HERE/'evm-traces.mjs','--output',folder/'evm-traces','--root',snap,'--runtime',runtime,'--case',candidate['evmFixture']],180);observed=json.loads((folder/'evm-traces/results.json').read_text()) if (folder/'evm-traces/results.json').is_file() else [];fault_evm['passed']=fault_evm['exitCode'] not in [0,None] and len(observed)==1 and observed[0]['name']==candidate['evmFixture'] and not observed[0]['receiptPassed'];faults.append({'candidate':candidate,'baselineCoveredSymbol':candidate['nativeSymbol'],'semanticAssertion':{'line':anchor+1,'text':lines[anchor]},'checks':[translation,native,fault_evm],'contradictoryReceipts':observed});save()
 (out/'mutations/results.json').write_text(json.dumps(faults,indent=2)+'\n');record('dependency-after',[sys.executable,'-B',ROOT/'scripts/check-raw-rejections-bytecode-evidence.py'],300)
 m['nativeResults']=[r for j in jobs for r in j['nativeResults']];m['declarationResults']=[d for j in jobs for d in j['declarations']];m['nativeObligations']=len(m['nativeResults']);m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()};m['dependenciesUnchanged']=dependencies==dependency_hashes();m['toolsUnchanged']=m['executableSha256']=={k:sha(v) for k,v in tools.items()};ct=m['concreteToolchain'];m['concreteToolsUnchanged']=bool(ct) and all(sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['hardhatEntry','edrEntry','nativeBinding']) and sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'];m['status']='passed' if m['inputsUnchanged'] and m['dependenciesUnchanged'] and m['toolsUnchanged'] and m['concreteToolsUnchanged'] and all(j['passed'] for j in m['checks']) else 'failed';m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)
if __name__=='__main__':main()
