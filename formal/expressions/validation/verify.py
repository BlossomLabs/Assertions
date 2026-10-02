#!/usr/bin/env python3
"""Verify pre-validation byte flow and source-backed cold-node completion receipts."""
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
    paths=['formal/expressions/guard-receipts/evidence/reached-guard-receipts/manifest.json', 'formal/expressions/trace-bounds/evidence/recursive-receipt-windows/manifest.json', 'formal/expressions/context/evidence/history-sensitive-composition/manifest.json', 'formal/expressions/frames/evidence/recursive-cache-provenance/manifest.json', 'formal/expressions/guarded/evidence/guarded-entry-complete/manifest.json', 'formal/expressions/entry/evidence/canonical-admission/manifest.json', 'formal/expressions/admission-errors/evidence/admission-error-bytes/manifest.json', 'formal/expressions/encoded/evidence/encoded-entry-complete/manifest.json', 'formal/expressions/returns/evidence/raw-returns/manifest.json', 'formal/expressions/execution/evidence/generated-traces/manifest.json', 'formal/expressions/oracle-stability/evidence/trace-extension/manifest.json', 'formal/expressions/oracle/evidence/trace-composition/manifest.json', 'formal/expressions/primitives/evidence/primitive-dispatch/manifest.json', 'formal/abi/evidence/production-abi-correspondence/manifest.json', 'formal/expressions/admission/evidence/expression-admission/manifest.json', 'formal/resolution/evidence/resolution-judge/manifest.json', 'formal/expressions/cache/evidence/cache-transitions/manifest.json', 'formal/expressions/evaluation/evidence/recursive-control/manifest.json', 'formal/expressions/recursive/evidence/recursive-control-source/manifest.json', 'formal/expressions/scalars/evidence/scalar-adapters/manifest.json', 'formal/expressions/calls/evidence/call-control/manifest.json', 'formal/core/evidence/core-raw-primitives/manifest.json', 'formal/arguments/evidence/get-arguments/manifest.json', 'formal/expressions/receipts/evidence/encoded-receipts-complete/manifest.json', 'formal/expressions/compound/evidence/compound-adapters/manifest.json', 'formal/expressions/codec-errors/evidence/codec-receipts/manifest.json', 'formal/expressions/resolve/evidence/resolve-adapter-complete/manifest.json', 'formal/expressions/requests/evidence/request-contracts-complete/manifest.json', 'formal/expressions/probe-input/evidence/probe-decoding/manifest.json']
    return common.check_dependencies(dafny, solc, sources, out, root=ROOT, here=HERE,
                                     paths=paths, inventory=inventory, closure=closure, hash_file=sha)


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
    m={'status':'incomplete','scope':'Prove byte-valued primitive replies and pre-validation bodies, strengthen unchanged source control with cold-body cache invariants, and compose actual source validator receipts with node completion and canonical cache storage.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'executableSha256':{k:sha(v) for k,v in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',solver),('solc',solc)]},'checks':[]}
    m['versions']={k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in [('dafny',dafny),('z3',solver),('solc',solc)]}
    m['concreteTool']={'sha256':sha(Path(shutil.which('forge'))),'version':subprocess.check_output(['forge','--version'],text=True).strip()}
    m['assumptions']=['Inherited source/ABI/decoder/memory translation and sufficient-resource assumptions remain explicit.', 'Covered/ValidTrace supplies source-backed primitive replies; their values and error payloads are proved byte sequences. Recursive byte flow includes node bodies before canonical validation, lazy branches and failed attempts.', 'The source-control body is unchanged: removing the declared contract/include/module edits recovers the audited recursive source adapter exactly. Cold-body memo validity, extension and current-node absence are established by the strengthened source theorem.', 'Cold completion executes the cached source validator receipt adapter with matching descriptor metadata. Descriptor/value length representability and CursorRoom exclude arithmetic panic; they are explicit resource premises, not a physical gas theorem.', 'Actual error bytes are propagated from the source receipt. No new independent all-input rejection-offset function or offset-bound theorem is claimed.', 'Completion supplies a rejection-function instance for this one checked node/value. Equality with a previously supplied rejection function is conditional only at that actual rejected pair. Constructing compatible actual validation receipts for a whole recursive run remains open.', 'Child rejection payloads in the input body retain their existing abstraction until whole-run validation composition is completed. EVM caller/static projections, graph/tree determinism and compiled bytecode remain separate.', 'No new EVM or production source fault campaign is claimed. Dafny/Boogie/Z3 trusted.']
    def save(): (out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    def record(name,command,timeout=1200):
        j=run(command,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
    save()
    gate=record('control-erasure',[sys.executable,'-B',source/'generate.py','--root',snap,'--output',out/'generated'])
    gate['passed']=gate['passed'] and (out/'generated/Body.generated.dfy').read_bytes()==(source/'Body.generated.dfy').read_bytes()
    if not gate['passed']: save(); raise SystemExit('Source contract drift')
    m['checks'].append(check_dependencies(dafny,solc,sources,out));save()
    proof=record('proof',common.proof_command(dafny,source/'Connection.dfy',out/'proof.csv')+['--filter-symbol','ExpressionValidation'])
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
