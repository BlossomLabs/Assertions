#!/usr/bin/env python3
"""Verify callback invocation with prepared-state and history composition."""
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
        for m in re.finditer(r'^  (?:(?:ghost|opaque) )?(lemma|method|function|predicate|type)(?: \{:[^}]+\})* (\w+)(?:\(| =)',text,re.M):
            declarations.append({'name':module+'.'+m[2],'kind':m[1],'file':str(path.relative_to(ROOT))})
    return declarations


def check_dependencies(dafny,solc,sources,out):
    paths=['formal/abi/evidence/production-abi-correspondence/manifest.json', 'formal/collections/traversal/evidence/abstract-value-traversals/manifest.json', 'formal/collections/preparation/evidence/preparation-and-binding/manifest.json', 'formal/collections/callback-results/evidence/predicate-and-exhaustion/manifest.json']
    return common.check_dependencies(dafny, solc, sources, out, root=ROOT, here=HERE,
                                     paths=paths, inventory=inventory, closure=closure, hash_file=sha)


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
    m={'status':'incomplete','scope':'Source-gated _callValue and _checkTarget composition with proved binding and exhaustion adapters. Ordered contextual events, cached target checks, first/second slot flow, direct/expression encoding selection, raw success and exact structured failures. Concrete encoding and codec/external observations remain explicit premises.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'executableSha256':{k:sha(v) for k,v in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',solver),('solc',solc)]},'checks':[]}
    m['versions']={k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in [('dafny',dafny),('z3',solver),('solc',solc)]}
    m['concreteTool']={'sha256':sha(Path(shutil.which('forge'))),'version':subprocess.check_output(['forge','--version'],text=True).strip()}
    m['assumptions']=['Pinned complete function ASTs, restricted slot translator and reviewed manual lowering are trusted.', 'Prepared state satisfies the proved layout/slot invariant. Its first/second slots and descriptor faithfully project the callback. Initialized, disjoint representable memory and adequate local resources exclude local panics.', 'Codec environments match actual validation outcomes. Each binding receives an environment indexed by the complete prior event history; internal codec request histories are appended back to that history. Concrete codec instantiation remains pending.', 'Code lengths, direct assemble outcomes, evaluateEncoded ABI bytes, external return/revert bytes and gas samples faithfully match the source context. Encoding construction itself and error serialization remain open connections.', 'A cached target check remains valid during the enclosing static operation. External observations may depend on the full history, caller, gas and context; equal requests need not produce equal results.', 'Failed prepared state/history is a ghost execution receipt, not memory committed by a reverted call. Success retains the checked flag and updated argument slots.', 'Dafny/Boogie/Z3 trusted. Reused dependencies require identical source/tool/artifact hashes and native results. No exact compiled-bytecode, deployment or gas/performance claim.']

    def save(): (out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    def record(name,command,timeout=1200):
        j=run(command,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
    save()
    gate=record('source-gate',[sys.executable,'-B',source/'generate.py','--solc',solc,'--root',snap,'--output',out/'generated'])
    gate['passed']=gate['passed'] and (out/'generated/Source.generated.dfy').read_bytes()==(source/'Source.generated.dfy').read_bytes()
    if not gate['passed']:save();raise SystemExit('Source gate/generated drift')
    m['checks'].append(check_dependencies(dafny,solc,sources,out));save()
    proof=record('proof',common.proof_command(dafny,source/'Connection.dfy',out/'proof.csv')+['--filter-symbol','CollectionsCalls'])
    common.check_proof(proof,out/'proof.log',out/'proof.csv',inventory({f for f in sources if f.parent==HERE}))
    audit=record('audit',[dafny,'audit',source/'Connection.dfy']);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'audit.log').read_text()
    record('format',[dafny,'format','--check',*[f for f in source.glob('*.dfy') if not f.name.endswith('.template.dfy')]])
    record('solidity-format',['forge','fmt','--check',source/'CallsOracle.t.sol'])
    (snap/'foundry.toml').write_text('[profile.default]\nsrc="contracts"\ntest="formal/collections/calls"\nsolc='+json.dumps(str(solc))+'\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\n[lint]\nlint_on_build=false\n')
    concrete=record('concrete',['forge','test','--root',snap,'--match-contract','CallsOracleTest','-vv'],180)
    expected=re.findall(r'function (test\w+)\(', (source/'CallsOracle.t.sol').read_text());actual=re.findall(r'^\[PASS\] (test\w+)\(', (out/'concrete.log').read_text(),re.M)
    concrete.update(expectedTests=expected,passed=concrete['passed'] and sorted(actual)==sorted(expected) and bool(expected))
    m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()}
    m['status']='passed' if m['inputsUnchanged'] and all(c['passed'] for c in m['checks']) else 'failed'
    m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    shutil.rmtree(snap/'out',ignore_errors=True);shutil.rmtree(snap/'cache',ignore_errors=True)
    m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'}
    save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)

if __name__=='__main__':main()
