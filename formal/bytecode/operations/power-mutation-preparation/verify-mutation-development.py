#!/usr/bin/env python3
"""Retain mathematical integer exponent foundation development only."""
import argparse,csv,datetime,importlib.util,json,re,shutil,subprocess
from pathlib import Path
if not __debug__: raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
v=load('getters',ROOT/'formal/bytecode/getters/verify.py');common=v.common
identity=load('operations_identity',HERE.parent/'identity.py')
DEPS=HERE.parent/'power-kernel'
PROOFS=[]
def collect(f):
 f=f.resolve()
 if f in PROOFS:return
 for name in re.findall(r'^include "([^"]+)"',f.read_text(),re.M):collect(f.parent/name)
 PROOFS.append(f)
collect(HERE/'Witness.generated.dfy')
def inventory(path):
 rows=v.inventory(path);symbol=re.search(r'^module (\w+)',path.read_text(),re.M)[1]
 rows += [{'name':symbol+'.'+m[1],'kind':'const','file':str(path.relative_to(ROOT))} for m in re.finditer(r'^  const (\w+)\s*:',path.read_text(),re.M)]
 return rows
def inputs():
 files={p for folder in {HERE,DEPS,HERE.parent/'power-entry-preparation',*[f.parent for f in PROOFS]} for p in folder.iterdir() if p.is_file()}
 files|={HERE.parent/'identity.py',HERE.parent/'inventory.json',ROOT/'formal/constraints/verify.py',ROOT/'formal/bytecode/getters/verify.py',ROOT/'formal/bytecode/dispatch/identity.py',ROOT/'formal/abi/toolchain.json',ROOT/'hardhat.config.ts',ROOT/'package.json',ROOT/'pnpm-lock.yaml'}
 artifact=ROOT/'artifacts/contracts/Operations.sol/Operations.json';a=json.loads(artifact.read_text());build=ROOT/'artifacts/build-info'/(a['buildInfoId']+'.json');files|={artifact,build}
 for key in json.loads(build.read_text())['input']['sources']:
  files.add(identity.source_path(key))
  if key.startswith('npm/'):files.add(ROOT/'node_modules'/re.fullmatch(r'npm/(@[^/]+/[^/@]+)@([^/]+)/(.+)',key)[1]/'package.json')
 return sorted(files)
def main():
 p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 assert len(PROOFS)==7 and set(HERE.glob('*.dfy'))=={f for f in PROOFS if f.parent==HERE}
 closed=set()
 def visit(f):
  f=f.resolve();assert f in PROOFS
  if f in closed:return
  closed.add(f)
  for name in re.findall(r'^include "([^"]+)"',f.read_text(),re.M):visit(f.parent/name)
 for f in PROOFS:visit(f)
 assert closed==set(PROOFS)
 tools={'dafny':a.dafny.resolve(),'Dafny.dll':a.dafny.resolve().parent/'Dafny.dll','z3':a.dafny.resolve().parent/'z3/bin/z3-4.12.1'}
 files=inputs();hashes={str(f.relative_to(ROOT)):common.sha(f) for f in files}
 for f in files:
  dest=out/'source-snapshot'/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dest)
 versions={k:subprocess.check_output([str(tools[k]),'--version'],text=True).strip() for k in ['dafny','z3']}
 assert versions['dafny']==json.load(open(ROOT/'formal/abi/toolchain.json'))['dafnyVersion'] and '4.12.1' in versions['z3']
 m={'schemaVersion':1,'status':'development-running-no-public-credit','selectedDevelopmentOnly':True,'scope':'Selected exact reached EXP checkpoint at PC21115, unsigned ordinal10 base3 exponent31. Complete seven-module captured dependency graph, but only the two checkpoint declarations are verified here. Native intended successor must pass baseline and fail the one-byte EXP-to-MUL candidate, with independently replayed complete physical candidate receipt. Full dependency-native/raw/loop retention remain open; no public credit','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'versions':versions,'executableSha256':{k:common.sha(f) for k,f in tools.items()},'proofFiles':[str(f.relative_to(ROOT)) for f in PROOFS],'checks':[]}
 def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
 def record(name,cmd,timeout=7200):
  j=common.run(cmd,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
 save();snap=out/'source-snapshot'
 gate=record('format',[tools['dafny'],'format','--check',*[snap/f.relative_to(ROOT) for f in PROOFS]],180)
 if not gate['passed']:m['status']='development-format-failed-preserved';save();raise SystemExit(1)
 owner=snap/DEPS.relative_to(ROOT)
 generation=record('generation',[shutil.which('python3'),'-B',owner/'generate-bounds.py','--output',out/'generated'],180)
 fmt=record('generation-format',[shutil.which('python3'),'-B',owner/'format-generated.py','--output',out/'generated','--include-root',owner],180)
 generation['passed']=generation['passed'] and fmt['passed'] and (owner/'Bounds.generated.dfy').read_bytes()==(out/'generated/Bounds.generated.dfy').read_bytes();save()
 conversionOwner=snap/(HERE.parent/'signed-multiply-repair-v2').relative_to(ROOT)
 conversion=record('generation-conversion',[shutil.which('python3'),'-B',conversionOwner/'generate-conversion.py','--output',out/'conversion'],180)
 conversion['passed']=conversion['passed'] and (conversionOwner/'Conversion.generated.dfy').read_bytes()==(out/'conversion/Conversion.generated.dfy').read_bytes();save()
 if not generation['passed'] or not conversion['passed']:m['status']='development-regeneration-failed-preserved';save();raise SystemExit(1)
 owner=snap/HERE.relative_to(ROOT)
 checkpoint=record('generation-checkpoint',[shutil.which('python3'),'-B',owner/'generate.py','--output',out/'checkpoint'],180)
 checkpointFormat=record('generation-checkpoint-format',[shutil.which('python3'),'-B',owner/'format-generated.py','--output',out/'checkpoint','--include-root',owner],180)
 checkpoint['passed']=checkpoint['passed'] and checkpointFormat['passed'] and (owner/'Witness.generated.dfy').read_bytes()==(out/'checkpoint/Witness.generated.dfy').read_bytes();save()
 if not checkpoint['passed']:m['status']='development-checkpoint-regeneration-failed-preserved';save();raise SystemExit(1)
 sf=owner/'Witness.generated.dfy';symbol='OperationsPowerSemanticCheckpoint'
 baseline=record('baseline-checkpoint',common.proof_command(tools['dafny'],sf,out/'baseline.csv')+['--filter-symbol',symbol,'--filter-position',str(sf),'--progress','Symbol'])
 common.check_proof(baseline,out/'baseline-checkpoint.log',out/'baseline.csv',inventory(HERE/'Witness.generated.dfy'));save()
 audit=record('baseline-audit',[tools['dafny'],'audit',sf],180);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'baseline-audit.log').read_text();save()
 if not baseline['passed'] or not audit['passed']:m['status']='development-baseline-failed-preserved';save();raise SystemExit(1)
 artifact=json.loads((snap/'artifacts/contracts/Operations.sol/Operations.json').read_text());code=bytearray.fromhex(artifact['deployedBytecode'][2:]);assert code[21115]==10;code[21115]=2;candidate=out/'candidate.bin';candidate.write_bytes(code)
 mutant=out/'candidate-snapshot';shutil.copytree(snap,mutant);mutantOwner=mutant/HERE.relative_to(ROOT)
 translate=record('candidate-generation',[shutil.which('python3'),'-B',mutantOwner/'generate.py','--output',mutantOwner,'--runtime',candidate],180)
 fmt=record('candidate-format',[shutil.which('python3'),'-B',mutantOwner/'format-generated.py','--output',mutantOwner,'--include-root',mutantOwner],180)
 file=mutantOwner/'Witness.generated.dfy';selected=symbol+'.IntendedResult'
 native=record('candidate-native',common.proof_command(tools['dafny'],file,out/'candidate.csv')+['--filter-symbol',selected,'--filter-position',str(file),'--progress','Symbol'])
 log=(out/'candidate-native.log').read_text();rows=list(csv.DictReader((out/'candidate.csv').open())) if (out/'candidate.csv').exists() else []
 native['passed']=native['exitCode'] not in [0,None] and rows and any(r['TestResult.Outcome']=='Failed' for r in rows) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in rows) and 'postcondition could not be proved' in log and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',log,re.I);save()
 concrete=record('candidate-physical',[shutil.which('node'),owner/'evm-traces.mjs',out/'evm-traces',candidate],180)
 observed=json.loads((out/'evm-traces/results.json').read_text()) if (out/'evm-traces/results.json').exists() else []
 wrong=[r for r in observed if not r['passed']]
 concrete['passed']=concrete['passed'] and len(observed)==67 and len(wrong)==3 and any(r['ordinal']==10 and int(r['actual'],16)==93 and int(r['expected'],16)==617673396283947 for r in wrong);save()
 record('candidate-physical-independent',[shutil.which('python3'),'-B',owner/'check-physical.py',out/'evm-traces','--runtime',candidate],180)
 m['matchingSemanticFault']={'pc':21115,'baselineOpcode':10,'candidateOpcode':2,'fixedRealFixtureOrdinal':10,'intended':617673396283947,'actual':93,'nativeBaseline':baseline['passed'],'nativeCandidateContradiction':bool(native['passed']),'fullPhysicalReceipts':len(observed),'fullPhysicalContradictions':len(wrong)}
 m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):common.sha(f) for f in inputs()};m['toolsUnchanged']=m['executableSha256']=={k:common.sha(f) for k,f in tools.items()}
 m['nativeResults']=[row for file in out.glob('*.csv') for row in csv.DictReader(file.open())]
 m['status']='development-passed-no-public-credit' if m['inputsUnchanged'] and m['toolsUnchanged'] and all(c['passed'] for c in m['checks']) else 'development-failed-preserved'
 m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):common.sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save();raise SystemExit(0 if m['status']=='development-passed-no-public-credit' else 1)
if __name__=='__main__':main()
