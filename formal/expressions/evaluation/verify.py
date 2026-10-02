#!/usr/bin/env python3
"""Verify recursive control and its ABI/cache bridge; source lowering is still open."""
import argparse,datetime,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('common',ROOT/'formal/constraints/verify.py')
common=importlib.util.module_from_spec(spec);spec.loader.exec_module(common)
sha,run=common.sha,common.run
def closure(path):
    result={path.resolve()}
    for name in re.findall(r'^include "([^"]+)"',path.read_text(),re.M):
        result.update(closure(path.parent/name))
    return result


def inventory(paths):
    declarations=[]
    for path in sorted(paths):
        text=path.read_text();module=re.search(r'^module (\w+)',text,re.M)[1]
        for m in re.finditer(r'^  (?:(?:ghost|opaque) )?(lemma|method|function|predicate|type)(?: \{:[^}]+\})? (\w+)(?:\(| =)',text,re.M):
            declarations.append({'name':module+'.'+m[2],'kind':m[1],'file':str(path.relative_to(ROOT))})
    return declarations


def check_dependencies(dafny,solc,sources,out):
    paths=['formal/abi/evidence/production-abi-correspondence/manifest.json', 'formal/expressions/admission/evidence/expression-admission/manifest.json', 'formal/resolution/evidence/resolution-judge/manifest.json', 'formal/expressions/cache/evidence/cache-transitions/manifest.json']
    tools={'dafny':sha(dafny),'Dafny.dll':sha(dafny.parent/'Dafny.dll'),
           'z3':sha(dafny.parent/'z3/bin/z3-4.12.1'),'solc':sha(solc)}
    checked=[]; candidates=[]
    for relative in paths:
        path=ROOT/relative; prior=json.loads(path.read_text())
        if prior['status']!='passed':raise ValueError('Unproved dependency '+relative)
        native=prior.get('nativeResults')
        declarations=prior.get('declarationResults')
        if native is None:
            proof=next(c for c in prior['checks'] if c.get('name')=='proof')
            native=proof['nativeResults'];declarations=proof['declarations']
            if not proof['passed']:raise ValueError('Dependency proof not passed')
        if not native or any(r['TestResult.Outcome']!='Passed' for r in native):raise ValueError('Dependency native failures')
        previous=prior['executableSha256']
        if 'dafnyLauncher' in previous:
            previous={new:previous[old] for new,old in [('dafny','dafnyLauncher'),('Dafny.dll','dafnyAssembly'),('z3','solver'),('solc','solc')]}
        if tools!=previous:raise ValueError('Dependency tool drift')
        for artifact,digest in prior['evidenceSha256'].items():
            if sha(path.parent/artifact)!=digest:raise ValueError('Dependency artifact drift '+artifact)
        for source,digest in prior['sourceSha256'].items():
            if sha(ROOT/source)!=digest:raise ValueError('Dependency source drift '+source)
        rows={}
        for row in native:rows.setdefault(row['TestResult.DisplayName'].split(' (')[0],[]).append(row)
        for declaration in declarations:
            if declaration['kind'] in {'lemma','method'} and (declaration['status']!='passed' or not rows.get(declaration['name'])):
                raise ValueError('Unproved dependency declaration '+declaration['name'])
        retained='dependency-'+path.parent.name+'.json';shutil.copy2(path,out/retained)
        checked.append({'manifest':relative,'sha256':sha(path),'retainedManifest':retained,'nativeRows':len(native)})
        candidates.append((prior,{d['name']:d for d in declarations}))
    reused=[]
    for source in sorted(sources):
        if source.parent==HERE:continue
        key=str(source.relative_to(ROOT)); required=inventory({source})
        for prior,declarations in candidates:
            if not all(prior['sourceSha256'].get(str(p.relative_to(ROOT)))==sha(p) for p in closure(source)):continue
            if not all(d['name'] in declarations and declarations[d['name']]['file']==key for d in required if d['kind']!='type'):continue
            if not all(declarations[d['name']]['status']=='passed' for d in required if d['kind'] in {'method','lemma'}):continue
            reused.append(key);break
        else:raise ValueError('No complete identical dependency proof '+key)
    return {'name':'dependency-closure','passed':True,'dependencies':checked,'reusedModules':reused,
            'policy':'Identical transitive source/tool hashes; all retained artifact hashes and successful native/declaration results checked. Original proof arguments and logs retained in linked baseline manifests.'}


def main():
    p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    dafny,solc=a.dafny.resolve(),a.solc.resolve();solver=dafny.parent/'z3/bin/z3-4.12.1'
    sources=closure(HERE/'CacheBridge.dfy')
    files=sources|{f for f in HERE.iterdir() if f.is_file()}|{ROOT/'formal/constraints/verify.py'}
    hashes={str(f.relative_to(ROOT)):sha(f) for f in sorted(files)}
    snap=out/'source-snapshot'
    for f in files:
        dest=snap/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dest)
    source=snap/HERE.relative_to(ROOT)
    m={'status':'incomplete','scope':'Recursive abstract control plus admitted-graph and ABI/cache bridges. Not yet a source-correspondence or exact-error theorem.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'executableSha256':{k:sha(v) for k,v in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',solver),('solc',solc)]},'checks':[]}
    m['versions']={k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in [('dafny',dafny),('z3',solver),('solc',solc)]}
    m['checks'].append(check_dependencies(dafny,solc,sources,out))
    def record(name,command):
        j=run(command,out/(name+'.log'),1200);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);return j
    j=record('proof',common.proof_command(dafny,source/'CacheBridge.dfy',out/'proof.csv')+['--filter-symbol','ExpressionEvaluation'])
    common.check_proof(j,out/'proof.log',out/'proof.csv',inventory({f for f in sources if f.parent==HERE}))
    audit=record('audit',[dafny,'audit',source/'CacheBridge.dfy']);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'audit.log').read_text()
    record('format',[dafny,'format','--check',source/'Control.dfy',source/'CacheBridge.dfy'])
    mutations=[
      ('skip-validation','if !valid(index,value) {','if false {','ExpressionEvaluationControl.Run'),
      ('adopt-failed-cache','if attempted.Success? { working := attempted.memo; }','if true { working := attempted.memo; }','ExpressionEvaluationControl.GuardCache'),
      ('wrong-select','selected := refs[if truth(condition) then 1 else 2];','selected := refs[if truth(condition) then 2 else 1];','ExpressionEvaluationControl.Choose')]
    m['modelFaults']=[]
    for name,before,after,theorem in mutations:
        dest=out/name;dest.mkdir();text=(source/'Control.dfy').read_text()
        if text.count(before)!=1:raise ValueError('Fault site drift '+name)
        f=dest/'Control.dfy';f.write_text(text.replace(before,after))
        proof=run(common.proof_command(dafny,f,dest/'proof.csv'),dest/'proof.log',600)
        common.check_proof(proof,dest/'proof.log',dest/'proof.csv',inventory({HERE/'Control.dfy'}))
        log=(dest/'proof.log').read_text()
        killed=proof['exitCode']==4 and any(r['TestResult.DisplayName'].split(' (')[0]==theorem and r['TestResult.Outcome']=='Failed' for r in proof['nativeResults']) and not re.search(r'parse errors|resolution/type errors|time.?out|inconclusive|resource limit',log,re.I)
        m['modelFaults'].append({'name':name,'expectedTheorem':theorem,'killed':killed,'proof':proof})
    m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in files}
    m['status']='passed' if m['inputsUnchanged'] and all(c['passed'] for c in m['checks']) and all(f['killed'] for f in m['modelFaults']) else 'failed'
    m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file()}
    (out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)

if __name__=='__main__':main()
