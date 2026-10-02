#!/usr/bin/env python3
"""Verify concrete finite map/filter/fold iteration chains."""
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
    paths=['formal/abi/evidence/production-abi-correspondence/manifest.json', 'formal/collections/traversal/evidence/abstract-value-traversals/manifest.json', 'formal/collections/preparation/evidence/preparation-and-binding/manifest.json', 'formal/collections/callback-results/evidence/predicate-and-exhaustion/manifest.json', 'formal/collections/calls/evidence/callback-invocation-v2/manifest.json', 'formal/collections/wire/evidence/concrete-callback-wire/manifest.json', 'formal/collections/codec-state/evidence/canonical-prepared-state/manifest.json', 'formal/collections/constants/evidence/actual-constant-receipts/manifest.json', 'formal/collections/admission/evidence/arbitrary-descriptor-admission/manifest.json', 'formal/collections/codec-errors/evidence/concrete-codec-errors/manifest.json', 'formal/abi/outcomes/evidence/exact-recursive-outcomes/manifest.json', 'formal/collections/validation/evidence/validation-receipts/manifest.json', 'formal/collections/bound-call/evidence/concrete-bound-callback/manifest.json', 'formal/collections/repeated-call/evidence/repeated-source-callbacks/manifest.json', 'formal/collections/call-results/evidence/callback-result-observations/manifest.json', 'formal/collections/iteration/evidence/concrete-interleaved-step/manifest.json', 'formal/collections/environment/evidence/history-scoped-assembly-v2/manifest.json']
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
    m={'status':'incomplete','scope':'Finite concrete map/filter/fold iteration chains constructed from actual helper receipts, with persistent prepared state, low-level callback history, fold feedback and first combined failure; assembled exact traversal Tail with per-row source callback records. Public admission and source-loop application remain open.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'executableSha256':{k:sha(v) for k,v in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',solver),('solc',solc)]},'checks':[]}
    m['versions']={k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in [('dafny',dafny),('z3',solver),('solc',solc)]}
    m['concreteTool']={'sha256':sha(Path(shutil.which('forge'))),'version':subprocess.check_output(['forge','--version'],text=True).strip()}
    m['assumptions']=['Nonempty tails begin with an admitted tuple, valid binding slots and canonical constants outside substitution slots. Empty tails need none of these conditions. Raw preparation and public traversal admission remain separate.', 'Budget is a finite recursive condition on continuing receipt-guarded callback executions. LocalRoom retains existing typed size/width/CursorRoom/packet bounds and prepared-state invariants. Receipt acceptance guards use independent canonicality; Budget does not assume input acceptance, callback success, canonical return values or a successful traversal. Input/callback/predicate/result failure imposes no recursive budget on the unreachable suffix.', 'AfterRoom still overapproximates possible typed helper receipts within each reached iteration; resources may be required for work skipped inside that iteration. This is an explicit sufficient resource premise, not a completeness theorem for resource-limited execution.', 'The strengthened Step repeats the prior source-helper construction and adds concrete receipt/environment and successful continuation postconditions. It is independently verified; frozen dependencies are unchanged.', 'One fixed low-level external environment supplies full-history code/call/gas observations. It must faithfully represent the actual execution, including relevant context; no gas, history or caller independence is inferred.', 'Environment assembly preserves every reached high-level history window. The generated logical state token is distinct from the threaded concrete prepared state and callback history. Unmatched default observations remain unreachable.', 'Source translation, compiler ABI, context/offset projections, physical memory and execution resources, Dafny/Boogie/Z3 and explicit Uint/CursorRoom/packet bounds remain trusted. Full public map/filter/fold admission and source-loop application, other public families, sorting and exact bytecode remain open. No new EVM/source-fault, deployment or performance claim.']

    def save(): (out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    def record(name,command,timeout=1200):
        j=run(command,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
    save()
    m['checks'].append(check_dependencies(dafny,solc,sources,out));save()
    proof=record('proof',common.proof_command(dafny,source/'Connection.dfy',out/'proof.csv')+['--filter-symbol','CollectionsIterationChain'])
    common.check_proof(proof,out/'proof.log',out/'proof.csv',inventory({f for f in sources if f.parent==HERE}))
    audit=record('audit',[dafny,'audit',source/'Connection.dfy']);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'audit.log').read_text()
    record('format',[dafny,'format','--check',*[f for f in source.glob('*.dfy') if not f.name.endswith('.template.dfy')]])
    m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()}
    m['status']='passed' if m['inputsUnchanged'] and all(c['passed'] for c in m['checks']) else 'failed'
    m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    shutil.rmtree(snap/'out',ignore_errors=True);shutil.rmtree(snap/'cache',ignore_errors=True)
    m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'}
    save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)

if __name__=='__main__':main()
