#!/usr/bin/env python3
"""Verify exact admission-error ABI bytes and representable source error fields."""
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
        for m in re.finditer(r'^  (?:(?:ghost|opaque) )?(lemma|method|function|predicate|type)(?: \{:[^}]+\})* (\w+)(?:\(| =)',text,re.M):
            declarations.append({'name':module+'.'+m[2],'kind':m[1],'file':str(path.relative_to(ROOT))})
    return declarations


def check_dependencies(dafny,solc,sources,out):
    paths=['formal/expressions/codec-errors/evidence/codec-receipts/manifest.json', 'formal/abi/evidence/production-abi-correspondence/manifest.json', 'formal/expressions/admission/evidence/expression-admission/manifest.json', 'formal/resolution/evidence/resolution-judge/manifest.json', 'formal/expressions/cache/evidence/cache-transitions/manifest.json', 'formal/expressions/evaluation/evidence/recursive-control/manifest.json', 'formal/expressions/recursive/evidence/recursive-control-source/manifest.json', 'formal/expressions/scalars/evidence/scalar-adapters/manifest.json', 'formal/expressions/calls/evidence/call-control/manifest.json', 'formal/core/evidence/core-raw-primitives/manifest.json', 'formal/arguments/evidence/get-arguments/manifest.json', 'formal/expressions/compound/evidence/compound-adapters/manifest.json']
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


def inputs():
    deps=['contracts/Expressions.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol','formal/constraints/verify.py','formal/navigation/generate.py','formal/abi/shape/generate.py','formal/abi/source/generate.py','formal/abi/toolchain.json']
    return sorted(closure(HERE/'Connection.dfy')|{f for f in HERE.iterdir() if f.is_file()}|{ROOT/p for p in deps})

def main():
    p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    dafny,solc=a.dafny.resolve(),a.solc.resolve();solver=dafny.parent/'z3/bin/z3-4.12.1'
    sources=closure(HERE/'Connection.dfy');files=inputs()
    hashes={str(f.relative_to(ROOT)):sha(f) for f in files};snap=out/'source-snapshot'
    for f in files:
        dest=snap/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dest)
    source=snap/HERE.relative_to(ROOT)
    m={'status':'incomplete','scope':'Exact structured admission rejection encoded as independent ABI argument frames, with derived representability of every error field and parser rejection-offset bounds.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'executableSha256':{k:sha(v) for k,v in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',solver),('solc',solc)]},'checks':[]}
    m['versions']={k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in [('dafny',dafny),('z3',solver),('solc',solc)]}
    m['concreteTool']={'sha256':sha(Path(shutil.which('forge'))),'version':subprocess.check_output(['forge','--version'],text=True).strip()}
    m['assumptions']=['Inherited source admission/parser translation, memory and resource premises remain.', 'Input result index, graph length, reference values and descriptor lengths fit uint256, matching their Solidity representation. Error-field representability is derived, not separately assumed.', 'Solidity custom errors and Panic use standard selector-plus-argument-tuple encoding. Selectors/signatures are checked against the production AST; Panic bytes are checked concretely.', 'The panic EVM test checks standard arithmetic-panic serialization; it does not claim a physically reachable admission overflow example.', 'This composes already proved source admission with error serialization and new parser bounds; no new actual-source fault campaign is claimed.', 'Dafny/Boogie/Z3 trusted; compiler encoder and exact-bytecode verification remain separate.']
    def save(): (out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    def record(name,command,timeout=1200):
        j=run(command,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
    save()
    record('selector-binding',[sys.executable,'-B',source/'check_selectors.py','--solc',solc,'--root',snap])
    m['checks'].append(check_dependencies(dafny,solc,sources,out));save()
    proof=record('proof',common.proof_command(dafny,source/'Connection.dfy',out/'proof.csv')+['--filter-symbol','ExpressionAdmissionError'])
    common.check_proof(proof,out/'proof.log',out/'proof.csv',inventory({f for f in sources if f.parent==HERE}))
    audit=record('audit',[dafny,'audit',source/'Connection.dfy']);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'audit.log').read_text()
    record('format',[dafny,'format','--check',*[f for f in source.glob('*.dfy') if not f.name.endswith('.template.dfy')]])
    record('solidity-format',['forge','fmt','--check',source/'AdmissionErrorOracle.t.sol'])
    (snap/'foundry.toml').write_text('[profile.default]\nsrc="contracts"\ntest="formal/expressions/admission-errors"\nsolc='+json.dumps(str(solc))+'\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\n[lint]\nlint_on_build=false\n')
    evm=record('concrete',['forge','test','--root',snap,'--match-contract','AdmissionErrorOracleTest','-vv'],180)
    expected=re.findall(r'function (test\w+)\(', '\n'.join(f.read_text() for f in source.glob('*.sol')));observed=re.findall(r'^\[PASS\] (test\w+)\(', (out/'concrete.log').read_text(),re.M)
    evm.update(expectedTests=expected,passed=evm['passed'] and bool(expected) and sorted(expected)==sorted(observed))
    m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()}
    m['status']='passed' if m['inputsUnchanged'] and all(c['passed'] for c in m['checks']) else 'failed'
    m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    shutil.rmtree(snap/'out',ignore_errors=True);shutil.rmtree(snap/'cache',ignore_errors=True)
    m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'}
    save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)

if __name__=='__main__':main()
