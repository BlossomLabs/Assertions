#!/usr/bin/env python3
"""Selected raw connection repair; no retained public coverage."""
import argparse, importlib.util, json, shutil
from pathlib import Path

OWNER = Path(__file__).resolve().parent
ROOT = OWNER.parents[2]
spec = importlib.util.spec_from_file_location('bitwise_retainer',OWNER/'bitwise-retention/verify.py')
v = importlib.util.module_from_spec(spec)
spec.loader.exec_module(v)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--dafny',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True,exist_ok=False)
    files = sorted(set(v.inputs()+[Path(__file__).resolve()]))
    hashes = {str(p.relative_to(ROOT)):v.sha(p) for p in files}
    for file in files:
        target=out/'source-snapshot'/file.relative_to(ROOT)
        target.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(file,target)
    dafny=args.dafny.resolve()
    tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':dafny.parent/'z3/bin/z3-4.12.1'}
    manifest={'status':'development-running-not-retained','scope':'Complete raw bitwise connection module with checked opaque-definition bridge; full public retained graph remains open.','sourceSha256':hashes,'executableSha256':{n:v.sha(p) for n,p in tools.items()},'checks':[]}
    def save():
        (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    def record(name,command,timeout=300):
        job=v.common.run(command,out/(name+'.log'),timeout)
        job.update(name=name,passed=job['exitCode']==0)
        manifest['checks'].append(job)
        save()
        return job
    save()
    owner=OWNER/'bitwise-repair/Connection.dfy'
    source=out/'source-snapshot'/owner.relative_to(ROOT)
    module='OperationsBitwiseRepairConnection'
    csvfile=out/(module+'.csv')
    job=record('proof-'+module,v.common.proof_command(dafny,source,csvfile)+['--filter-symbol',module,'--progress','Symbol'])
    v.common.check_proof(job,out/('proof-'+module+'.log'),csvfile,v.v.inventory(owner))
    save()
    audit=record('audit',[dafny,'audit',source],180)
    audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'audit.log').read_text()
    manifest['inputsUnchanged']=hashes=={str(p.relative_to(ROOT)):v.sha(p) for p in sorted(set(v.inputs()+[Path(__file__).resolve()]))}
    manifest['toolsUnchanged']=manifest['executableSha256']=={n:v.sha(p) for n,p in tools.items()}
    manifest['status']='development-selected-passed-not-retained' if manifest['inputsUnchanged'] and manifest['toolsUnchanged'] and all(j['passed'] for j in manifest['checks']) else 'development-selected-failed-preserved'
    save()
    raise SystemExit(0 if manifest['status']=='development-selected-passed-not-retained' else 1)

if __name__=='__main__':
    main()
