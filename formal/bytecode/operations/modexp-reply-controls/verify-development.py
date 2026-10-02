#!/usr/bin/env python3
"""Verify all actual modular-power postcall reply gates, development only."""
import argparse,csv,datetime,importlib.util,json,re,shutil,subprocess
from pathlib import Path
if not __debug__: raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
v=load('getters',ROOT/'formal/bytecode/getters/verify.py');common=v.common
identity=load('operations_identity',HERE.parent/'identity.py')
DEPS=HERE
PROOFS=[]
def collect(f):
 f=f.resolve()
 if f in PROOFS:return
 for name in re.findall(r'^include "([^"]+)"',f.read_text(),re.M):collect(f.parent/name)
 PROOFS.append(f)
for f in sorted(HERE.glob('*.generated.dfy')):collect(f)
def inventory(path):
 rows=v.inventory(path);symbol=re.search(r'^module (\w+)',path.read_text(),re.M)[1]
 rows += [{'name':symbol+'.'+m[1],'kind':'const','file':str(path.relative_to(ROOT))} for m in re.finditer(r'^  const (\w+)\s*:',path.read_text(),re.M)]
 return rows
def inputs():
 files={p for folder in {HERE,DEPS,*[f.parent for f in PROOFS]} for p in folder.iterdir() if p.is_file()}
 files|={HERE.parent/'identity.py',HERE.parent/'inventory.json',ROOT/'formal/constraints/verify.py',ROOT/'formal/bytecode/getters/verify.py',ROOT/'formal/bytecode/dispatch/identity.py',ROOT/'formal/abi/toolchain.json',ROOT/'hardhat.config.ts',ROOT/'package.json',ROOT/'pnpm-lock.yaml'}
 artifact=ROOT/'artifacts/contracts/Operations.sol/Operations.json';a=json.loads(artifact.read_text());build=ROOT/'artifacts/build-info'/(a['buildInfoId']+'.json');files|={artifact,build,ROOT/'artifacts/build-info'/(a['buildInfoId']+'.output.json')}
 files|={p for p in (HERE.parent/'modexp-entry-preparation').iterdir() if p.is_file()}
 files|={p for p in (HERE.parent/'modexp-inverse-dependencies').iterdir() if p.is_file()}
 for key in json.loads(build.read_text())['input']['sources']:
  files.add(identity.source_path(key))
  if key.startswith('npm/'):files.add(ROOT/'node_modules'/re.fullmatch(r'npm/(@[^/]+/[^/@]+)@([^/]+)/(.+)',key)[1]/'package.json')
 return sorted(files)
def main():
 p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 assert len(PROOFS)==18 and set(HERE.glob('*.dfy'))=={f for f in PROOFS if f.parent==HERE}
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
 m={'schemaVersion':1,'status':'development-running-no-public-credit','scope':'Complete18-module compiler-bound complementary post-MODEXP exact32-byte successful result, failed call and successful wrong-size fallback gates from9332 through9354, plus physical packet and explicit faithful reply foundation. Finite reached fitting frames and caller/external observation assumptions remain explicit. Universal surrounding loop/raw/error/physical return composition open; no precompile implementation/gas/deployment/performance/public coverage claim.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'versions':versions,'executableSha256':{k:common.sha(f) for k,f in tools.items()},'proofFiles':[str(f.relative_to(ROOT)) for f in PROOFS],'checks':[]}
 def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
 def record(name,cmd,timeout=7200):
  j=common.run(cmd,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
 save();snap=out/'source-snapshot'
 depout=out/'inverse-dependencies-regenerated'
 depgate=record('generation-inverse-dependencies',['python3','-B',snap/(HERE.parent/'modexp-inverse-dependencies/generate.py').relative_to(ROOT),'--output',depout],180)
 if not depgate['passed']:
  m['status']='development-dependency-generation-failed-preserved';save();raise SystemExit(1)
 assert (depout/'dependencies.mapping.json').read_bytes()==(snap/(HERE.parent/'modexp-inverse-dependencies/dependencies.mapping.json').relative_to(ROOT)).read_bytes()
 gate=record('format',[tools['dafny'],'format','--check',*[snap/f.relative_to(ROOT) for f in PROOFS]],180)
 if not gate['passed']:m['status']='development-format-failed-preserved';save();raise SystemExit(1)
 generated=out/'regenerated';generated.mkdir();record('generation',['python3','-B',snap/HERE.relative_to(ROOT)/'generate.py','--output',generated],180)
 for name in ['Exact.generated.dfy','Failed.generated.dfy','WrongSize.generated.dfy','source-gate.json','reply.mapping.json']:
  assert (generated/name).read_bytes()==(snap/HERE.relative_to(ROOT)/name).read_bytes()
 def fail_required(name):
  m['failedRequiredGate']=name;m['status']='development-failed-required-gate-preserved'
  m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):common.sha(f) for f in inputs()}
  m['toolsUnchanged']=m['executableSha256']=={k:common.sha(f) for k,f in tools.items()}
  m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
  m['evidenceSha256']={str(f.relative_to(out)):common.sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'}
  save();raise SystemExit(1)
 for f in PROOFS:
  symbol=re.search(r'^module (\w+)',f.read_text(),re.M)[1];sf=snap/f.relative_to(ROOT);csvpath=out/(symbol+'.csv')
  j=record('proof-'+symbol,common.proof_command(tools['dafny'],sf,csvpath)+['--filter-symbol',symbol,'--filter-position',str(sf),'--progress','Symbol']);common.check_proof(j,out/('proof-'+symbol+'.log'),csvpath,inventory(f));save()
  if not j['passed']:fail_required(j['name'])
  audit=record('audit-'+symbol,[tools['dafny'],'audit',sf],180);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/('audit-'+symbol+'.log')).read_text();save()
  if not audit['passed']:fail_required(audit['name'])
 m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):common.sha(f) for f in inputs()};m['toolsUnchanged']=m['executableSha256']=={k:common.sha(f) for k,f in tools.items()}
 m['nativeResults']=[row for file in out.glob('*.csv') for row in csv.DictReader(file.open())]
 m['status']='development-passed-no-public-credit' if m['inputsUnchanged'] and m['toolsUnchanged'] and all(c['passed'] for c in m['checks']) else 'development-failed-preserved'
 m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):common.sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save();raise SystemExit(0 if m['status']=='development-passed-no-public-credit' else 1)
if __name__=='__main__':main()
