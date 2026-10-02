#!/usr/bin/env python3
"""Verify the Assertions final judge connection and source coverage."""
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
    paths=['formal/core/serialization/evidence/concrete-wire/manifest.json','formal/core/public-boundary/evidence/seventeen-entrypoints/manifest.json','formal/core/raw-tree/evidence/raw-calldata-frames/manifest.json','formal/core/frame-tree/evidence/finite-source-receipts/manifest.json','formal/core/recursive/evidence/all-entrypoint-dispatch/manifest.json','formal/abi/evidence/production-abi-correspondence/manifest.json','formal/navigation/evidence/navigation-correspondence/manifest.json','formal/constraints/evidence/constraint-engine/manifest.json','formal/resolution/evidence/resolution-judge/manifest.json','formal/core/evidence/core-raw-primitives/manifest.json','formal/control/evidence/guarded-control/manifest.json','formal/composition/evidence/resolved-navigation/manifest.json','formal/arguments/evidence/get-arguments/manifest.json']
    return common.check_dependencies(dafny, solc, sources, out, root=ROOT, here=HERE,
                                     paths=paths, inventory=inventory, closure=closure, hash_file=sha)


def inputs():
    deps=['contracts/Assertions.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol','formal/constraints/verify.py','formal/navigation/generate.py','formal/abi/shape/generate.py','formal/abi/source/generate.py','formal/abi/toolchain.json']
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
    m={'status':'incomplete','scope':'Final parameter/batch judge verdicts and exact failure bytes through completed recursive concrete-wire source receipts, with complete Assertions source coverage audit.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'executableSha256':{k:sha(v) for k,v in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',solver),('solc',solc)]},'checks':[]}
    m['versions']={k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in [('dafny',dafny),('z3',solver),('solc',solc)]}
    m['concreteTool']={'sha256':sha(Path(shutil.which('forge'))),'version':subprocess.check_output(['forge','--version'],text=True).strip()}
    m['assumptions']=['This theorem is conditional source correspondence for admitted zero-value frames executing the modeled Assertions code in matching static/caller contexts; it is not a compiler or deployed-bytecode theorem.', 'Trusted boundaries: reviewed Solidity AST/template translation, solc ABI decoder/getter/encoder projections, nonwrapping disjoint memory and truthful history-indexed external/code/balance/gas observations. Calls may vary with history and frame context.', 'Certification requires finite actual self-call coverage, unique sites, readiness at every frame and TreeFits for all serialized fields/returns. Adequate local gas/stack/allocation and all documented intermediate arithmetic premises remain required. Unready, incomplete or nonrepresentable trees are not certified.', 'Getter lowering is only a proven observation-preserving proof representation; deployed getters do not invoke resolve. Decoder-rejected leaves return empty data under the faithful decoder premise.', 'Get/navigation recursive codec invalid-byte offsets remain actual source receipts; this summary does not invent a second independent offset oracle for their callers.', 'No new EVM/source-fault campaign or gas/deployment/performance evidence; other contracts and exact compiled-bytecode verification remain separate. Dafny/Boogie/Z3 trusted.']
    def save(): (out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    def record(name,command,timeout=1200):
        j=run(command,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
    save()
    record('coverage',[sys.executable,HERE/'audit.py','--solc',solc,'--output',out/'coverage.json'])
    m['checks'].append(check_dependencies(dafny,solc,sources,out));save()
    proof=record('proof',common.proof_command(dafny,source/'Connection.dfy',out/'proof.csv')+['--filter-symbol','AssertionsCompletion'])
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
