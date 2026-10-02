#!/usr/bin/env python3
"""Retain full byteAt admission foundation/control development; successful/error bodies open."""
import argparse,csv,datetime,importlib.util,json,re,shutil,subprocess
from pathlib import Path
if not __debug__: raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
v=load('getters',ROOT/'formal/bytecode/getters/verify.py');common=v.common
identity=load('operations_identity',HERE.parent/'identity.py')
PROOFS=[HERE/f for f in ['Indices.dfy','Inputs.dfy','Memory.dfy','Machine.dfy','Conversion.generated.dfy','AdmissionKernel.dfy','Output.dfy','Error.dfy','Nonzero.generated.dfy','Short.generated.dfy','Args.generated.dfy','OffsetBound.generated.dfy','LengthWindow.generated.dfy','LengthBound.generated.dfy','PayloadWindow.generated.dfy']]
def inventory(path):
 rows=v.inventory(path);symbol=re.search(r'^module (\w+)',path.read_text(),re.M)[1]
 rows += [{'name':symbol+'.'+m[1],'kind':'const','file':str(path.relative_to(ROOT))} for m in re.finditer(r'^  const (\w+)\s*:',path.read_text(),re.M)]
 return rows
def inputs():
 files={p for p in HERE.iterdir() if p.is_file()}
 files|={HERE.parent/'identity.py',HERE.parent/'inventory.json',ROOT/'formal/constraints/verify.py',ROOT/'formal/bytecode/getters/verify.py',ROOT/'formal/bytecode/dispatch/identity.py',ROOT/'formal/abi/toolchain.json',ROOT/'hardhat.config.ts',ROOT/'package.json',ROOT/'pnpm-lock.yaml'}
 artifact=ROOT/'artifacts/contracts/Operations.sol/Operations.json';a=json.loads(artifact.read_text());build=ROOT/'artifacts/build-info'/(a['buildInfoId']+'.json');files|={artifact,build}
 for key in json.loads(build.read_text())['input']['sources']:
  files.add(identity.source_path(key))
  if key.startswith('npm/'):files.add(ROOT/'node_modules'/re.fullmatch(r'npm/(@[^/]+/[^/@]+)@([^/]+)/(.+)',key)[1]/'package.json')
 return sorted(files)
def main():
 p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 assert set(HERE.glob('*.dfy'))==set(PROOFS)
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
 m={'schemaVersion':1,'status':'development-running-no-public-credit','scope':'Complete fifteen-module development graph: signed-index/raw-input/byte-memory/machine/conversion foundations, actual input selector and memory support, unverified exact original-byte envelope/overlapping custom-error write support, plus seven exact current raw decoder rejection paths from PC0 to physical empty REVERT. Complete successful and InvalidByteIndex body paths remain open; no retained public entry or gas/deployment/performance claim.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'versions':versions,'executableSha256':{k:common.sha(f) for k,f in tools.items()},'proofFiles':[str(f.relative_to(ROOT)) for f in PROOFS],'checks':[]}
 def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
 def record(name,cmd,timeout=1800):
  j=common.run(cmd,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
 save();snap=out/'source-snapshot'
 gate=record('format',[tools['dafny'],'format','--check',*[snap/f.relative_to(ROOT) for f in PROOFS]],180)
 if not gate['passed']:m['status']='development-format-failed-preserved';save();raise SystemExit(1)
 owner=snap/HERE.relative_to(ROOT)
 names=['Nonzero','Short','Args','OffsetBound','LengthWindow','LengthBound','PayloadWindow']
 generation=record('generation',[shutil.which('python3'),'-B',owner/'generate-admission.py','--output',out/'generated'])
 fmt=record('generation-format',[shutil.which('python3'),'-B',owner/'format-generated.py','--output',out/'generated','--include-root',owner],180)
 generation['passed']=generation['passed'] and fmt['passed'] and all((owner/(n+s)).read_bytes()==(out/'generated'/(n+s)).read_bytes() for n in names for s in ['.generated.dfy','.mapping.json']);save()
 conversion=record('generation-conversion',[shutil.which('python3'),'-B',owner/'generate-conversion.py','--output',out/'conversion'],180)
 conversion['passed']=conversion['passed'] and (owner/'Conversion.generated.dfy').read_bytes()==(out/'conversion/Conversion.generated.dfy').read_bytes();save()
 if not generation['passed'] or not conversion['passed']:m['status']='development-regeneration-failed-preserved';save();raise SystemExit(1)
 for f in PROOFS:
  symbol=re.search(r'^module (\w+)',f.read_text(),re.M)[1];sf=snap/f.relative_to(ROOT);csvpath=out/(symbol+'.csv')
  j=record('proof-'+symbol,common.proof_command(tools['dafny'],sf,csvpath)+['--filter-symbol',symbol,'--filter-position',str(sf),'--progress','Symbol']);common.check_proof(j,out/('proof-'+symbol+'.log'),csvpath,inventory(f));save()
  audit=record('audit-'+symbol,[tools['dafny'],'audit',sf],180);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/('audit-'+symbol+'.log')).read_text();save()
 m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):common.sha(f) for f in inputs()};m['toolsUnchanged']=m['executableSha256']=={k:common.sha(f) for k,f in tools.items()}
 m['nativeResults']=[row for file in out.glob('*.csv') for row in csv.DictReader(file.open())]
 m['status']='development-passed-no-public-credit' if m['inputsUnchanged'] and m['toolsUnchanged'] and all(c['passed'] for c in m['checks']) else 'development-failed-preserved'
 m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):common.sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save();raise SystemExit(0 if m['status']=='development-passed-no-public-credit' else 1)
if __name__=='__main__':main()
