#!/usr/bin/env python3
"""Retain complete raw comparison exact-bytecode entry evidence, never source substitutes."""
import argparse,csv,datetime,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
if not __debug__:raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];OWNER=HERE.parent

def module(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
v=module('getter_workflow',ROOT/'formal/bytecode/getters/verify.py');common=v.common;sha=common.sha
identity=module('operations_identity',OWNER/'identity.py')
NAMES=['AbsUT','AbsUF','AbsST','AbsSF'];REJECTIONS=['Nonzero','Short','AbsUArgs','AbsSArgs']
PROOFS=[OWNER/'absolute-difference/Machine.dfy',OWNER/'absolute-difference/Binary.dfy',*[OWNER/'absolute-difference'/(n+'.generated.dfy') for n in NAMES],*[OWNER/'absolute-difference/rejections'/(n+'.generated.dfy') for n in REJECTIONS],OWNER/'absolute-difference/Connection.dfy']
def inputs():
 files={f for folder in [HERE,OWNER/'absolute-difference',OWNER/'absolute-difference/rejections'] for f in folder.iterdir() if f.is_file()}
 files|={OWNER/'identity.py',OWNER/'inventory.py',OWNER/'inventory.json',ROOT/'formal/constraints/verify.py',ROOT/'formal/abi/toolchain.json',ROOT/'formal/bytecode/getters/verify.py',ROOT/'formal/bytecode/dispatch/identity.py',ROOT/'hardhat.config.ts',ROOT/'pnpm-lock.yaml',ROOT/'package.json'}
 ap=ROOT/'artifacts/contracts/Operations.sol/Operations.json';a=json.loads(ap.read_text());bp=ROOT/'artifacts/build-info'/(a['buildInfoId']+'.json');files|={ap,bp}
 for key in json.loads(bp.read_text())['input']['sources']:
  files.add(identity.source_path(key))
  if key.startswith('npm/'):files.add(ROOT/'node_modules'/re.fullmatch(r'npm/(@[^/]+/[^/@]+)@([^/]+)/(.+)',key)[1]/'package.json')
 return sorted(files)
def main():
 p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 dafny=a.dafny.resolve();solc=a.solc.resolve();z3=dafny.parent/'z3/bin/z3-4.12.1';out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 assert set((OWNER/'absolute-difference').glob('*.dfy'))==set(PROOFS[:6]+[PROOFS[-1]])
 assert set((OWNER/'absolute-difference/rejections').glob('*.dfy'))==set(PROOFS[6:-1])
 closed=set()
 def visit(f):
  f=f.resolve();assert f in PROOFS
  if f in closed:return
  closed.add(f)
  for i in re.findall(r'^include "([^"]+)"',f.read_text(),re.M):visit(f.parent/i)
 for f in PROOFS:visit(f)
 assert closed==set(PROOFS)
 versions={k:subprocess.check_output([str(f),'--version'],text=True).strip() for k,f in [('dafny',dafny),('z3',z3),('solc',solc)]}
 assert versions['dafny']==json.loads((ROOT/'formal/abi/toolchain.json').read_text())['dafnyVersion'] and '4.12.1' in versions['z3'] and '0.8.36+commit.8a079791' in versions['solc']
 tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':z3,'solc':solc}
 files=inputs();hashes={str(f.relative_to(ROOT)):sha(f) for f in files};snap=out/'source-snapshot'
 for f in files:
  dest=snap/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dest)
 source=snap/OWNER.relative_to(ROOT)
 m={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Complete exact Operations signed/unsigned absolute difference raw entries with complementary strict/complement source-math branch guards, all word operands, complete nonpayable/short-head rejection and exact physical scalar RETURN. Calldata fits below2^64; all other public bodies stay open.','publicEntries':['Operations.absDiff(uint256,uint256)','Operations.absDiff(int256,int256)'],'sourceSha256':hashes,'versions':versions,'executableSha256':{k:sha(f) for k,f in tools.items()},'checks':[],'proofFiles':[str(f.relative_to(ROOT)) for f in PROOFS],'assumptions':['Exact current compiler job/runtime and selector extraction, reviewed complete instruction-boundary scanning and reached opcode interpreter. No compiler correctness premise replaces executed instructions.','Physical zero-padded calldata windows, fresh zero call memory, fixed-width big-endian byte stores/loads and truthful call value. Calldata is finite with length below 2^64; reached stack/memory and instruction resources are sufficient. No gas availability/cost, deployment, complexity or performance theorem.','Matches constrains all reached instructions/immediates and valid actual JUMPDESTs; other runtime bytes remain arbitrary. Each generated path executes all its instructions without a cutoff. All input words and arbitrary trailing calldata are admitted.','Dafny/Boogie/Z3 and reviewed tooling are trusted. Source ledger completeness and concrete EVM fixtures do not substitute for native exact-opcode correspondence.']}
 def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
 def record(name,command,timeout=1800):
  j=common.run(command,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
 save();gate=record('format-before',[dafny,'format','--check',*[snap/f.relative_to(ROOT) for f in PROOFS]],180)
 if not gate['passed']:m['status']='failed-format-gate';save();raise SystemExit('Complete package format gate failed')
 record('runtime-identity',[sys.executable,'-B',source/'identity.py','--solc',solc,'--output',out/'identity'],240)
 for folder,names in [('absolute-difference',NAMES),('absolute-difference/rejections',REJECTIONS)]:
  generated=out/'generated'/folder
  gate=record('generation-'+folder.replace('/','-'),[sys.executable,'-B',source/folder/'generate.py','--output',generated],180)
  fmt=record('generation-format-'+folder.replace('/','-'),[sys.executable,'-B',source/'absolute-difference/format-generated.py','--output',generated,'--include-root',source/folder],180)
  gate['passed']=gate['passed'] and fmt['passed'] and all((source/folder/(n+s)).read_bytes()==(generated/(n+s)).read_bytes() for n in names for s in ['.generated.dfy','.mapping.json']);save()
 if not all(c['passed'] for c in m['checks']):raise SystemExit('Identity/regeneration gate failed')
 proofjobs=[]
 for f in PROOFS:
  module_name=re.search(r'^module (\w+)',f.read_text(),re.M)[1];sf=snap/f.relative_to(ROOT);csvpath=out/(module_name+'.csv')
  j=record('proof-'+module_name,common.proof_command(dafny,sf,csvpath)+['--filter-symbol',module_name,'--progress','Symbol']);common.check_proof(j,out/('proof-'+module_name+'.log'),csvpath,v.inventory(f));proofjobs.append(j);save()
  audit=record('audit-'+module_name,[dafny,'audit',sf],180);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/('audit-'+module_name+'.log')).read_text();save()
 record('format',[dafny,'format','--check',*[snap/f.relative_to(ROOT) for f in PROOFS]],180)
 concrete=record('concrete',[shutil.which('node'),HERE/'evm-traces.mjs',out/'evm-traces'],180)
 traces=json.loads((out/'evm-traces/results.json').read_text()) if (out/'evm-traces/results.json').is_file() else []
 concrete['passed']=concrete['passed'] and len(traces)==28 and {(t['name'],t['ordinal']) for t in traces}=={(n,i) for n in ['AbsU','AbsS'] for i in range(14)} and all(t['passed'] for t in traces)
 ct=json.loads((out/'evm-traces/toolchain.json').read_text());m['concreteToolchain']=ct;save()
 rejected=record('rejections-concrete',[shutil.which('node'),HERE/'rejection-traces.mjs',out/'rejection-traces'],180)
 r=json.loads((out/'rejection-traces/results.json').read_text()) if (out/'rejection-traces/results.json').is_file() else []
 rejected['passed']=rejected['passed'] and len(r)==24 and all(t['passed'] for t in r);save()
 record('candidate-generation',[sys.executable,'-B',source/'absolute-difference-retention/make-candidates.py','--output',out/'candidates'],180)
 faults=[]
 for info in json.loads((out/'candidates/inventory.json').read_text()):
  name=info['entry'];folder=out/'mutations'/info['name'];folder.mkdir(parents=True);candidate=out/'candidates'/(info['name']+'.bin');shutil.copy2(source/'absolute-difference/Machine.dfy',folder/'Machine.dfy');shutil.copy2(source/'absolute-difference/Binary.dfy',folder/'Binary.dfy')
  trans=record(info['name']+'-translation',[sys.executable,'-B',source/'absolute-difference/generate.py','--runtime',candidate,'--output',folder],180)
  fmt=record(info['name']+'-format',[sys.executable,'-B',source/'absolute-difference/format-generated.py','--output',folder,'--include-root',folder],180)
  file=folder/(name+'.generated.dfy');lines=file.read_text().splitlines();symbol=info['baselineSemanticSymbol'];short=symbol.rsplit('.',1)[1];begin=next(i for i,l in enumerate(lines) if 'lemma '+short+'(' in l);anchor=next(i for i in range(begin,len(lines)) if 'ensures state.stack[|state.stack|-2] == Result(a,b)' in lines[i])
  baseline=next(j for j in proofjobs if any(d['name']==symbol for d in j['declarations']));assert next(d for d in baseline['declarations'] if d['name']==symbol)['status']=='passed'
  native=record(info['name']+'-native',common.proof_command(dafny,file,folder/'proof.csv')+['--filter-symbol',symbol,'--filter-position',str(file)+':'+str(anchor+1),'--progress','Symbol'],240)
  log=(out/(info['name']+'-native.log')).read_text();rows=list(csv.DictReader((folder/'proof.csv').open())) if (folder/'proof.csv').is_file() else []
  native['passed']=native['exitCode'] not in [0,None] and bool(rows) and any(r['TestResult.Outcome']=='Failed' for r in rows) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in rows) and 'postcondition could not be proved' in log and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',log,re.I)
  evm=record(info['name']+'-concrete',[shutil.which('node'),HERE/'evm-traces.mjs',folder/'evm-traces',candidate],180)
  failed=json.loads((folder/'evm-traces/results.json').read_text()) if (folder/'evm-traces/results.json').is_file() else []
  failed=[t for t in failed if not t['passed'] and t['name']==info['publicFamily'] and t.get('actual')!=t.get('expected')]
  evm['passed']=evm['exitCode'] not in [0,None] and any(t['ordinal']==info['witnessOrdinal'] for t in failed) and 'Wrong EVM absolute difference output' in (out/(info['name']+'-concrete.log')).read_text()
  faults.append(dict(info,semanticAssertion={'line':anchor+1,'text':lines[anchor]},checks=[trans,fmt,native,evm],concreteFailures=failed));save()
 (out/'mutations/results.json').write_text(json.dumps(faults,indent=2)+'\n')
 m['nativeResults']=[r for j in proofjobs for r in j['nativeResults']];m['declarationResults']=[d for j in proofjobs for d in j['declarations']]
 m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()};m['toolsUnchanged']=m['executableSha256']=={k:sha(f) for k,f in tools.items()}
 m['concreteToolsUnchanged']=all(sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['hardhatEntry','edrEntry','nativeBinding']) and sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256']
 m['status']='passed' if m['inputsUnchanged'] and m['toolsUnchanged'] and m['concreteToolsUnchanged'] and all(c['passed'] for c in m['checks']) else 'failed';m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)
if __name__=='__main__':main()
