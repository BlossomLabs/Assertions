#!/usr/bin/env python3
"""Verify graph/tree outcome equivalence under explicit source-observation determinism."""
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
    paths=['formal/expressions/public/evidence/public-entrypoints/manifest.json', 'formal/expressions/rejections/evidence/whole-trace-validation/manifest.json', 'formal/expressions/self-call/evidence/inner-result-composition/manifest.json', 'formal/abi/outcomes/evidence/exact-recursive-outcomes/manifest.json', 'formal/expressions/validation/evidence/cold-node-completion/manifest.json', 'formal/expressions/guard-receipts/evidence/reached-guard-receipts/manifest.json', 'formal/expressions/trace-bounds/evidence/recursive-receipt-windows/manifest.json', 'formal/expressions/context/evidence/history-sensitive-composition/manifest.json', 'formal/expressions/frames/evidence/recursive-cache-provenance/manifest.json', 'formal/expressions/guarded/evidence/guarded-entry-complete/manifest.json', 'formal/expressions/entry/evidence/canonical-admission/manifest.json', 'formal/expressions/admission-errors/evidence/admission-error-bytes/manifest.json', 'formal/expressions/encoded/evidence/encoded-entry-complete/manifest.json', 'formal/expressions/returns/evidence/raw-returns/manifest.json', 'formal/expressions/execution/evidence/generated-traces/manifest.json', 'formal/expressions/oracle-stability/evidence/trace-extension/manifest.json', 'formal/expressions/oracle/evidence/trace-composition/manifest.json', 'formal/expressions/primitives/evidence/primitive-dispatch/manifest.json', 'formal/abi/evidence/production-abi-correspondence/manifest.json', 'formal/expressions/admission/evidence/expression-admission/manifest.json', 'formal/resolution/evidence/resolution-judge/manifest.json', 'formal/expressions/cache/evidence/cache-transitions/manifest.json', 'formal/expressions/evaluation/evidence/recursive-control/manifest.json', 'formal/expressions/recursive/evidence/recursive-control-source/manifest.json', 'formal/expressions/scalars/evidence/scalar-adapters/manifest.json', 'formal/expressions/calls/evidence/call-control/manifest.json', 'formal/core/evidence/core-raw-primitives/manifest.json', 'formal/arguments/evidence/get-arguments/manifest.json', 'formal/expressions/receipts/evidence/encoded-receipts-complete/manifest.json', 'formal/expressions/compound/evidence/compound-adapters/manifest.json', 'formal/expressions/codec-errors/evidence/codec-receipts/manifest.json', 'formal/expressions/resolve/evidence/resolve-adapter-complete/manifest.json', 'formal/expressions/requests/evidence/request-contracts-complete/manifest.json', 'formal/expressions/probe-input/evidence/probe-decoding/manifest.json']
    return common.check_dependencies(dafny, solc, sources, out, root=ROOT, here=HERE,
                                     paths=paths, inventory=inventory, closure=closure, hash_file=sha)


def inputs():
    deps=['formal/expressions/validation/Connection.dfy','formal/expressions/codec-errors/Connection.dfy','contracts/Expressions.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol','formal/constraints/verify.py','formal/navigation/generate.py','formal/abi/shape/generate.py','formal/abi/source/generate.py','formal/abi/toolchain.json']
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
    m={'status':'incomplete','scope':'Prove memoized graph outcomes equal reference-unfolding tree outcomes, preserve memo consistency, and connect the theorem to complete public source evidence under explicit StableConfig.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'executableSha256':{k:sha(v) for k,v in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',solver),('solc',solc)]},'checks':[]}
    m['versions']={k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in [('dafny',dafny),('z3',solver),('solc',solc)]}
    m['concreteTool']={'sha256':sha(Path(shutil.which('forge'))),'version':subprocess.check_output(['forge','--version'],text=True).strip()}
    m['assumptions']=['All inherited public source translation, ABI/memory/resource and coverage premises remain explicit.', 'The independent tree evaluator unfolds each reference occurrence without memoization, retaining original node identities in primitive requests and errors.', 'The memo-consistency invariant states that every stored entry equals a successful tree evaluation; it holds initially for the public empty memo and is proved preserved on all branches, including discarded failed attempts.', 'StableConfig universally constrains eligible source primitive receipts to a history-independent request function. It includes caller/static context, gas-sensitive outcomes and guard classification; the Solidity view modifier does not establish it.', 'The source connection reuses exact trace agreement and complete public evaluation evidence. Outcome equality includes errors with original node identities. It does not claim equal call counts, traces, gas, or error indices after arbitrary physical graph renumbering.', 'No new EVM or production source-fault campaign. Exact compiled bytecode remains separate. Dafny/Boogie/Z3 trusted.']
    def save(): (out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    def record(name,command,timeout=1200):
        j=run(command,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
    save()
    m['checks'].append(check_dependencies(dafny,solc,sources,out));save()
    proof=record('proof',common.proof_command(dafny,source/'Connection.dfy',out/'proof.csv')+['--filter-symbol','ExpressionTree'])
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
