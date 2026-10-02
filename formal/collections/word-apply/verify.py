#!/usr/bin/env python3
"""Verify complete public word map/filter admission, traversal, output and trace composition."""
import argparse,datetime,functools,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('common',ROOT/'formal/constraints/verify.py')
common=importlib.util.module_from_spec(spec);spec.loader.exec_module(common)
sha,run=common.sha,common.run
def closure(path):
    return cached_closure(path.resolve())

@functools.cache
def cached_closure(path):
    result={path}
    for name in re.findall(r'^include "([^"]+)"',path.read_text(),re.M):
        result.update(closure(path.parent/name))
    return result


def inventory(paths):
    declarations=[]
    for path in sorted(paths):
        text=path.read_text();module=re.search(r'^module (\w+)',text,re.M)[1]
        for m in re.finditer(r'^  (?:(?:ghost|opaque) )*(lemma|method|function|predicate|type)(?: \{:[^}]+\})* (\w+)(?:\(| =)',text,re.M):
            declarations.append({'name':module+'.'+m[2],'kind':m[1],'file':str(path.relative_to(ROOT))})
    return declarations


def check_dependencies(dafny,solc,sources,out):
    paths=['formal/abi/evidence/production-abi-correspondence/manifest.json', 'formal/collections/traversal/evidence/abstract-value-traversals/manifest.json', 'formal/collections/preparation/evidence/preparation-and-binding/manifest.json', 'formal/collections/callback-results/evidence/predicate-and-exhaustion/manifest.json', 'formal/collections/calls/evidence/callback-invocation-v2/manifest.json', 'formal/collections/wire/evidence/concrete-callback-wire/manifest.json', 'formal/collections/codec-state/evidence/canonical-prepared-state/manifest.json', 'formal/collections/constants/evidence/actual-constant-receipts/manifest.json', 'formal/collections/admission/evidence/arbitrary-descriptor-admission/manifest.json', 'formal/collections/codec-errors/evidence/concrete-codec-errors/manifest.json', 'formal/collections/bound-call/evidence/concrete-bound-callback/manifest.json', 'formal/collections/word-memory/evidence/actual-word-helpers-v2/manifest.json', 'formal/collections/word-windows/evidence/ordered-template-writes/manifest.json', 'formal/collections/word-call/evidence/domain-and-call-source-v2/manifest.json']
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
    deps=['contracts/Collections.sol','contracts/lib/AbiCodec.sol','formal/constraints/verify.py','formal/abi/toolchain.json']
    return sorted(closure(HERE/'Connection.dfy')|{f for f in HERE.iterdir() if f.is_file()}|{ROOT/p for p in deps})

def main():
    p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    dafny,solc=a.dafny.resolve(),a.solc.resolve();solver=dafny.parent/'z3/bin/z3-4.12.1'
    pin=json.loads((ROOT/'formal/abi/toolchain.json').read_text())
    if subprocess.check_output([str(dafny),'--version'],text=True).strip()!=pin['dafnyVersion']:raise ValueError('Unpinned Dafny')
    sources=closure(HERE/'Connection.dfy');files=inputs()
    if {p for p in HERE.glob('*.dfy') if not p.name.endswith('.template.dfy')}-sources:raise ValueError('Unreachable local proof')
    hashes={str(f.relative_to(ROOT)):sha(f) for f in files};snap=out/'source-snapshot'
    for f in files:
        dest=snap/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dest)
    source=snap/HERE.relative_to(ROOT)
    m={'status':'incomplete','scope':'Complete public mapWords/filterWords conditional source composition at the decoded ABI boundary: compiler-bound selectors and controls; alignment/window/allocation/empty/target/copy order; concrete persistent-memory traversal; exact callback/predicate failures, trace, map results, stable original-word filter output and successful output-header shrink. Exact bytecode is separate.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'executableSha256':{k:sha(v) for k,v in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',solver),('solc',solc)]},'checks':[]}
    m['versions']={k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in [('dafny',dafny),('z3',solver),('solc',solc)]}
    m['concreteTool']={'sha256':sha(Path(shutil.which('forge'))),'version':subprocess.check_output(['forge','--version'],text=True).strip()}
    m['assumptions']=['The complete _applyWords/mapWords/filterWords ASTs are structurally gated. Compiler controls for alignment/count/nonempty/loop/filter/invalid/keep/output writes/header shrink and wrapper modes are generated from Control.template.dfy. Public operation and UnalignedWords selectors are compiler-derived. Fixed helper calls, arguments and source order follow the complete gated body.', 'Basic represents successfully decoded ABI fields: uint256 lengths/offsets and address160 target, finite bytes and offset lists. Malformed external ABI decoding is outside this decoded-boundary source theorem.', 'Static loop bounds follow from aligned input and complete element-window admission. Admission rejects template lengths below 32 even with zero elements or offsets. Output allocation is reached after alignment/windows, including empty and code-less target paths. It has a faithful zero-filled bytes frame of subject length. Allocation/finite memory/execution resources remain premises at that stage.', 'Only admitted nonempty positive-code paths require a faithful template copy into a disjoint call frame and callback/error-packet resources. Budget does not assume acceptance or successful callbacks. Rejected/empty/code-less paths require no call copy or callback budget; early admission failures require no output frame.', 'Actual _stampElements/_callWord/_setWord proofs connect persistent memory to fresh logical patches of the original template, exact word values and disjoint output/call frames. The final physical output frame equals the concatenated successful values after actual filter header shrink. Faithful compiler source/context/memory/copy/allocation and outer ABI return/error projections remain premises.', 'One explicit faithful environment supplies full-history code/staticcall/gas observations. It may depend on history/caller/gas. Successful calls return exactly one unsigned 256-bit word; callback failure precedes canonical 0/1 predicate validation. Failure exposes no successful output and omits all later callbacks.', 'The loop/entry connection proves exact reached indices, template data, answers, history links and first failure. Success consumes all elements; map preserves returned words/position, filter emits exactly selected original words with strictly increasing original indices, preserving duplicates.', 'All local native declarations are freshly verified and escape-audited. Fourteen real EVM fixtures are replayed. Four isolated semantic source mutations must pass generation and fail native verification and EVM fixtures. Complete retained dependencies are checked by source/tool/artifact/native/declaration hashes. No exact compiled-bytecode, gas, deployment or performance claim.']

    def save(): (out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    def record(name,command,timeout=1200):
        j=run(command,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
    save()
    gate=record('source-gate',[sys.executable,'-B',source/'generate.py','--solc',solc,'--root',snap,'--output',out/'generated'])
    gate['passed']=gate['passed'] and all((out/'generated'/file).read_bytes()==(source/file).read_bytes() for file in ['Control.generated.dfy'])
    if not gate['passed']:save();raise SystemExit('Source gate/generated drift')
    m['checks'].append(check_dependencies(dafny,solc,sources,out));save()
    proof=record('proof',common.proof_command(dafny,source/'Connection.dfy',out/'proof.csv')+['--filter-symbol','CollectionsWordApply','--progress','Symbol'])
    common.check_proof(proof,out/'proof.log',out/'proof.csv',inventory({f for f in sources if f.parent==HERE}))
    audit=record('audit',[dafny,'audit',source/'Connection.dfy']);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'audit.log').read_text()
    record('format',[dafny,'format','--check',*[f for f in source.glob('*.dfy') if not f.name.endswith('.template.dfy')]])
    fixtures=[source/'WordApplyOracle.t.sol']
    record('solidity-format',['forge','fmt','--check',*fixtures])
    (snap/'foundry.toml').write_text('[profile.default]\nsrc="contracts"\ntest="formal/collections"\nsolc='+json.dumps(str(solc))+'\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\n[lint]\nlint_on_build=false\n')
    concrete=record('concrete',['forge','test','--root',snap,'--match-contract','^WordApplyOracleTest$','-vv'],180)
    expected=[name for f in fixtures for name in re.findall(r'function (test\w+)\(',f.read_text())];actual=re.findall(r'^\[PASS\] (test\w+)\(', (out/'concrete.log').read_text(),re.M)
    concrete.update(expectedTests=expected,passed=concrete['passed'] and sorted(actual)==sorted(expected) and len(expected)==14)
    record('source-faults',[sys.executable,'-B',source/'source-fault-audit.py','--snapshot',snap,'--output',out/'source-faults','--dafny',dafny,'--solc',solc],1000)
    m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()}
    m['status']='passed' if m['inputsUnchanged'] and all(c['passed'] for c in m['checks']) else 'failed'
    m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    shutil.rmtree(snap/'out',ignore_errors=True);shutil.rmtree(snap/'cache',ignore_errors=True)
    m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'}
    save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)

if __name__=='__main__':main()
