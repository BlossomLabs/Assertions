#!/usr/bin/env python3
"""Retain the whole native dependency closure for the exact unbounded RAW gather body."""
import sys,os,json,re,shutil,concurrent.futures,threading,importlib.util
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def module(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
g=module('control',ROOT/'formal/bytecode/assertions-primitives-control/verify.py');getter=g.getter;common=g.common;sha=g.sha
out=Path(sys.argv[1]).resolve();out.mkdir(parents=True,exist_ok=False);closure=g.graph(HERE/'BodyEntry.dfy');snapshot=out/'source-snapshot';files=set(closure)|set(getter.inputs())|{f for d in [HERE,HERE.parent] for f in d.iterdir() if f.is_file() and f.suffix in {'.dfy','.json','.py','.mjs'}}|{ROOT/'formal/bytecode/unknown/format-generated.py'};hashes={str(f.relative_to(ROOT)):sha(f) for f in files}
for f in files:
 target=snapshot/f.relative_to(ROOT);target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,target)
dafny=Path('/home/sem/assertions-tools/dafny/dafny');node=Path('/home/sem/assertions-tools/node-v24.14.0-linux-x64/bin/node');solc=Path('/home/sem/assertions-tools/solc-0.8.36');lock=threading.Lock();manifest={'schemaVersion':1,'status':'incomplete','contracts':['Assertions'],'scope':'Exact PC2379 gather allocation and arbitrary-count initialization, followed by unbounded PC2461 element decoding, RAW/no-constraints resolution and result storage, returning the pointer array at a scanned caller label. Independent result theorem certifies every pointer, length and original payload. This closes the RAW successful body class; public dispatcher/outer decoder/bytes[] serializer, other fetchers and constraints remain open.','publicEntries':[],'includeClosure':[str(f.relative_to(ROOT)) for f in closure],'sourceSha256':hashes,'checks':[],'assumptions':['The reached instruction model, compiler identity and full runtime instruction-boundary scan are trusted; adequate gas/memory resources are premises.','Caller stack prefix fits EVM limits, calldata length fits uint256, and helper return is a valid scanned destination. Physical element relative offsets may be any accepted signed EVM word. Finite calldata and allocation bounds, proper initial heap and RAW fetcher/zero-constraint structural spans are premises.','Dafny/Boogie/Z3, solc, Node/Hardhat/EDR and evidence scripts are trusted. No whole-contract/public-entry or gas/deployment claim.']}
def save():
 with lock:(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
def record(name,cmd,timeout=7200):
 job=common.run(cmd,out/(name+'.log'),timeout);job.update(name=name,passed=job['exitCode']==0)
 with lock:manifest['checks'].append(job)
 save();return job
save();record('runtime-identity',[sys.executable,'-B',snapshot/'formal/bytecode/dispatch/identity.py','--contract','Assertions','--solc',solc,'--output',out/'identity'],300)
# Regenerate in an independent copied compiler-helper tree, then compare all bytes.
regen=out/'regeneration';shutil.copytree(snapshot,regen);source=regen/HERE.relative_to(ROOT);record('generation',[sys.executable,'-B',source/'generate-decoder.py'],300)
for f in ['ElementSpec.dfy','ElementSuccess.generated.dfy','ElementFailure.generated.dfy']:
 record('generation-format-'+f,[dafny,'format',source/f],300)
manifest['generationIdentical']=all((source/f).read_bytes()==(snapshot/HERE.relative_to(ROOT)/f).read_bytes() for f in ['ElementSpec.dfy','ElementSuccess.generated.dfy','ElementFailure.generated.dfy','ElementSuccess.mapping.json','ElementFailure.mapping.json']);save()
def prove(f):
 name=re.search(r'^module (\w+)',f.read_text(),re.M)[1];csv=out/('proof-'+name+'.csv');cmd=common.proof_command(dafny,snapshot/f.relative_to(ROOT),csv);cmd[cmd.index('--cores')+1]='1';cmd+=['--filter-symbol',name,'--progress','Symbol'];job=record('proof-'+name,cmd);common.check_proof(job,out/('proof-'+name+'.log'),csv,getter.inventory(f));save();print(name,len(job['nativeResults']),'passed' if job['passed'] else 'FAILED',flush=True);return job
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:jobs=list(pool.map(prove,[f for f in closure if re.search(r'^module (\w+)',f.read_text(),re.M)]))
manifest['nativeResults']=[r for j in jobs for r in j['nativeResults']];manifest['declarationResults']=[d for j in jobs for d in j['declarations']]
audit=record('audit',[dafny,'audit',snapshot/HERE.relative_to(ROOT)/'BodyEntry.dfy'],300);audit['passed'] &= 'auditor completed with 0 findings' in (out/'audit.log').read_text();record('format',[dafny,'format','--check',*[snapshot/f.relative_to(ROOT) for f in closure]],300)
concrete=record('concrete',[node,HERE/'evm-traces.mjs','--root',snapshot,'--output',out/'evm-traces'],300);rows=json.loads((out/'evm-traces/results.json').read_text());concrete['passed'] &= len(rows)==7 and all(x['passed'] for x in rows)
control=record('concrete-control',[node,HERE.parent/'evm-traces.mjs','--root',snapshot,'--output',out/'evm-control'],300);controlRows=json.loads((out/'evm-control/results.json').read_text());control['passed'] &= len(controlRows)==28 and all(x['passed'] for x in controlRows)
# Independently regenerate every body fragment and the caller-scanned return inventories.
controlSource=regen/HERE.parent.relative_to(ROOT);record('generation-control',[sys.executable,'-B',controlSource/'generate.py','--output',out/'control-regeneration'],300)
controlNames=[f.name for f in closure if f.parent==HERE.parent and f.name.endswith('.generated.dfy')]
manifest['generationIdentical'] &= all((out/'control-regeneration'/f).read_bytes()==(snapshot/HERE.parent.relative_to(ROOT)/f).read_bytes() for f in controlNames)
record('generation-callers',[sys.executable,'-B',source/'generate-callers.py'],300)
for f in ['CallerElementSpec.dfy','CallerElementSuccess.generated.dfy','CallerGatherDone.generated.dfy']:record('generation-format-'+f,[dafny,'format',source/f],300)
manifest['generationIdentical'] &= all((source/f).read_bytes()==(snapshot/HERE.relative_to(ROOT)/f).read_bytes() for f in ['CallerElementSpec.dfy','CallerElementSuccess.generated.dfy','CallerGatherDone.generated.dfy','caller-provenance.json'])
record('body-mutations',[sys.executable,'-B',HERE.parent/'mutations.py','--dafny',dafny,'--node',node,'--root',snapshot,'--output',out/'body-mutations'],900)
# Mutation changes NOT's header-size constant 126 ->127. Tight128 is accepted by
# canonical code and bare-rejected by this candidate, independently changing the receipt.
mutations=out/'mutations';mutations.mkdir();runtime=bytes.fromhex(json.loads((snapshot/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);assert runtime[17808]==126
for value in [126,127]:
 program=mutations/('physical-mask-'+str(value)+'.dfy');program.write_text('// SPDX-License-Identifier: MIT\ninclude "'+str(snapshot/'formal/bytecode/scans/Scalar.dfy')+'"\ninclude "'+str(snapshot/'formal/bytecode/scans/Fetch.dfy')+'"\nmodule PhysicalAllocationMask {\n import S = BytecodeScanMachine\n import G = BytecodeGetterMachine\n import F = BytecodeScanFetch\n import P = BytecodeScanScalar\n lemma PhysicalMask()\n  ensures S.BitNot('+str(value)+') == G.Modulus()-127\n {\n  var code: seq<S.Byte> := seq(17810,i => if i==17807 then 96 else if i==17808 then '+str(value)+' else 0);\n  F.Push1(code,17807);\n  assert S.Fetch(code,17807).immediate == '+str(value)+';\n  P.Narrow('+str(value)+');\n }\n}\n')
 job=record('mutation-native-'+str(value),[dafny,'verify',program,'--filter-symbol','PhysicalAllocationMask','--verification-time-limit','30','--solver-path',dafny.parent/'z3/bin/z3-4.12.1'],300)
 if value==127:
  log=(out/('mutation-native-'+str(value)+'.log')).read_text();job['passed']=job['exitCode']!=0 and 'postcondition could not be proved' in log and 'timed out' not in log and 'parse error' not in log;job['expectedSemanticFailure']=True
mutated=bytearray(runtime);mutated[17808]=127;candidate=mutations/'header-127.bin';candidate.write_bytes(mutated);job=record('mutation-complete-receipt',[node,HERE/'evm-traces.mjs','--root',snapshot,'--runtime',candidate,'--case','element-tight128','--output',mutations/'evm'],300);mutrow=json.loads((mutations/'evm/results.json').read_text());job['passed']=job['exitCode']!=0 and len(mutrow)==1 and not mutrow[0]['receiptPassed'] and mutrow[0]['actualFailed'] and mutrow[0]['actualBytes']=='';job['expectedSemanticFailure']=True
manifest['inputsUnchanged']=all(sha(ROOT/f)==h for f,h in hashes.items());manifest['status']='passed' if manifest['inputsUnchanged'] and manifest['generationIdentical'] and all(j['passed'] for j in manifest['checks']) else 'failed';save();print(manifest['status'],len(manifest['nativeResults']),flush=True);raise SystemExit(0 if manifest['status']=='passed' else 1)
