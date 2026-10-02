#!/usr/bin/env python3
"""Fresh closed physical/independent development replay, no native public credit."""
import argparse,datetime,hashlib,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
import math as math_engine
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def inputs():
 files={f for f in HERE.iterdir() if f.is_file()}
 files|={HERE.parent/'identity.py',HERE.parent/'inventory.json',ROOT/'hardhat.config.ts',ROOT/'package.json',ROOT/'pnpm-lock.yaml'}
 artifact=ROOT/'artifacts/contracts/Operations.sol/Operations.json';build=ROOT/'artifacts/build-info'/(read(artifact)['buildInfoId']+'.json');files|={artifact,build}
 spec=importlib.util.spec_from_file_location('identity',HERE.parent/'identity.py');identity=importlib.util.module_from_spec(spec);spec.loader.exec_module(identity)
 for key in read(build)['input']['sources']:
  files.add(identity.source_path(key))
  if key.startswith('npm/'):files.add(ROOT/'node_modules'/re.fullmatch(r'npm/(@[^/]+/[^/@]+)@([^/]+)/(.+)',key)[1]/'package.json')
 return sorted(files)
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 files=inputs();hashes={str(f.relative_to(ROOT)):sha(f) for f in files};snap=out/'source-snapshot'
 for f in files:
  d=snap/f.relative_to(ROOT);d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,d)
 owner=snap/HERE.relative_to(ROOT);node=Path(shutil.which('node')).resolve();python=Path(sys.executable).resolve()
 mathTools={'integerMathRuntime':python}
 mathOrigin=math_engine.__spec__.origin
 assert mathOrigin=='built-in' # Integer math belongs to the already hashed Python runtime.
 m={'status':'development-running-no-public-credit','scope':'Complete finite sqrt boundary/power/perfect-square/max inputs and all three complementary raw rejection gates. Independently replay every actual opcode/stack/expanded byte-memory/terminal, with Python integer-root outcomes. Native algorithm/complete universal raw body/serialization/semantic fault/public claims remain open; reviewed interpreter/extraction and reached resources explicit; no compiler correctness/gas/deployment/performance claim','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'executableSha256':{'node':sha(node),'python':sha(python)},'integerMathSha256':{k:sha(f) for k,f in mathTools.items()},'integerMathOrigin':mathOrigin,'nativeVerificationAttempted':False,'checks':[]}
 def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
 def run(name,cmd,expected=0):
  with (out/(name+'.log')).open('w') as log:r=subprocess.run([str(x) for x in cmd],cwd=ROOT,stdout=log,stderr=subprocess.STDOUT,timeout=180)
  job={'name':name,'command':[str(x) for x in cmd],'exitCode':r.returncode,'passed':r.returncode==expected};m['checks'].append(job);save();return job
 save();run('baseline-physical',[node,owner/'evm-traces.mjs',out/'baseline']);run('baseline-independent',[python,'-B',owner/'check-development.py',out/'baseline'])
 m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()};m['toolsUnchanged']=m['executableSha256']=={'node':sha(node),'python':sha(python)} and m['integerMathSha256']=={k:sha(f) for k,f in mathTools.items()}
 ct=read(out/'baseline/toolchain.json');m['concreteToolchain']=ct;m['concreteToolsUnchanged']=all(sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['hardhatEntry','edrEntry','nativeBinding','viemEntry']) and sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256']
 m['status']='development-physical-passed-no-native-public-credit' if m['inputsUnchanged'] and m['toolsUnchanged'] and m['concreteToolsUnchanged'] and all(j['passed'] for j in m['checks']) else 'development-failed-preserved'
 m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in out.rglob('*') if f.is_file() and f.name!='manifest.json'};save();raise SystemExit(0 if m['status']=='development-physical-passed-no-native-public-credit' else 1)
if __name__=='__main__':main()
