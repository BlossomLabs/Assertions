#!/usr/bin/env python3
"""Freeze and statically inspect prepared analytic work; never launch verification.

Resolve/format/audit do not certify function well-formedness or lemma results.
"""
import argparse,datetime,hashlib,json,re,shutil,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def closure(path):
    path=path.resolve();result={path}
    for name in re.findall(r'^include "([^"]+)"',path.read_text(),re.M):result.update(closure(path.parent/name))
    return result
def inputs():
    baseline=ROOT/'formal/operations/fixed-point/evidence/conditional-source-v1/manifest.json';m=json.loads(baseline.read_text())
    return sorted({p for p in HERE.iterdir() if p.is_file()}|closure(HERE/'Kernel.dfy')|{baseline,ROOT/'formal/operations/fixed-point/rational-oracle.py'}|{ROOT/name for name in m['sourceSha256']})
def main():
    p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False);dafny=a.dafny.resolve();baseline=ROOT/'formal/operations/fixed-point/evidence/conditional-source-v1/manifest.json';old=json.loads(baseline.read_text())
    if old['status']!='passed' or not old['inputsUnchanged']:raise ValueError('Source baseline incomplete')
    if any(sha(ROOT/name)!=value for name,value in old['sourceSha256'].items()):raise ValueError('Retained current-input drift')
    if sha(dafny)!=old['executableSha256']['dafny'] or sha(dafny.parent/'Dafny.dll')!=old['executableSha256']['Dafny.dll']:raise ValueError('Dafny tool drift')
    paths=inputs();hashes={str(p.relative_to(ROOT)):sha(p) for p in paths};snap=out/'source-snapshot'
    for f in paths:
        dest=snap/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dest)
    source=snap/HERE.relative_to(ROOT);dfys=sorted(source.glob('*.dfy'))
    m={'schemaVersion':1,'status':'incomplete','claimStatus':'native-unverified-preparation-only','publicCoverageAdded':0,'nativeVerificationRun':False,'solverLaunched':False,'evmRun':False,'sourceSha256':hashes,'inheritedSourceManifest':str(baseline.relative_to(ROOT)),'inheritedSourceManifestSha256':sha(baseline),'currentRetainedSourceInputsMatched':True,'toolSha256':{'dafny':sha(dafny),'Dafny.dll':sha(dafny.parent/'Dafny.dll')},'startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':[],'scope':'New analytic specification/draft lemma/static preparation. No analytic bound, new native result, public source coverage or bytecode claim.'}
    def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    def run(name,command):
        proc=subprocess.run([str(x) for x in command],capture_output=True,text=True,timeout=60);text=proc.stdout+proc.stderr;(out/(name+'.log')).write_text(text);passed=proc.returncode==0
        if name=='audit':passed=passed and 'auditor completed with 0 findings' in text
        m['checks'].append({'name':name,'command':[str(x) for x in command],'exitCode':proc.returncode,'passed':passed});save()
    save();run('resolve',[dafny,'resolve',source/'Kernel.dfy','--cores','1']);run('format',[dafny,'format','--check',*dfys]);run('audit',[dafny,'audit',source/'Kernel.dfy']);run('fraction-diagnostics',[sys.executable,'-B',source/'enclosures.py','--root',snap,'--output',out/'diagnostics.json'])
    m['inputsUnchanged']=hashes=={str(p.relative_to(ROOT)):sha(p) for p in inputs()};m['status']='static-checks-passed' if m['inputsUnchanged'] and all(x['passed'] for x in m['checks']) else 'static-checks-failed';m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p!=out/'manifest.json'};save();print(m['status']+': zero new native/public coverage');raise SystemExit(0 if m['status']=='static-checks-passed' else 1)
if __name__=='__main__':main()
