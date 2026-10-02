#!/usr/bin/env python3
"""Verify gated recursive source control with explicit primitive receipts."""
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
    paths=['formal/abi/evidence/production-abi-correspondence/manifest.json', 'formal/expressions/admission/evidence/expression-admission/manifest.json', 'formal/resolution/evidence/resolution-judge/manifest.json', 'formal/expressions/cache/evidence/cache-transitions/manifest.json', 'formal/expressions/evaluation/evidence/recursive-control/manifest.json']
    return common.check_dependencies(dafny, solc, sources, out, root=ROOT, here=HERE,
                                     paths=paths, inventory=inventory, closure=closure, hash_file=sha)


def inputs():
    deps=['contracts/Expressions.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol','formal/constraints/verify.py','formal/navigation/generate.py','formal/abi/shape/generate.py','formal/abi/source/generate.py','formal/expressions/cache/CacheOracle.t.sol']
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
    m={'status':'incomplete','scope':'Source recursive control, functional refinement and canonical/cache invariant, under faithful primitive/error/truth receipts. Full helper payload semantics and raw judge entrypoint remain separate.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'executableSha256':{k:sha(v) for k,v in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',solver),('solc',solc)]},'checks':[]}
    m['versions']={k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in [('dafny',dafny),('z3',solver),('solc',solc)]}
    m['assumptions']=['Pinned compiler AST, restricted generator and manually reviewed recursive lowering are trusted.','Faithful Solidity memory projection, separate call frames and ABI copying; admitted graph and valid parsed cache.','Primitive oracle retains actual node data, parameters, caller and chain context. Address/encoding/call/probe/guard receipts match the concrete source subcomputations; their full payload proofs remain open.','Truth is the actual first-word-nonzero predicate, and reject is the actual failed validation payload. Their adapters are separate obligations.','All encountered byte lengths and arithmetic are representable; cached validation has CursorRoom and sufficient local memory/gas. External outcomes are explicit receipts, not assumed successful or context independent.','Dafny/Boogie/Z3 trusted. Identical complete dependency results audited before reuse.']
    def save(): (out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    def record(name,command,timeout=1200):
        j=run(command,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
    save()
    gate=record('source-gate',[sys.executable,'-B',source/'generate.py','--solc',solc,'--root',snap,'--output',out/'generated'])
    gate['passed']=gate['passed'] and (out/'generated/Source.generated.dfy').read_bytes()==(source/'Source.generated.dfy').read_bytes()
    if not gate['passed']:save();raise SystemExit('Source gate drift')
    m['checks'].append(check_dependencies(dafny,solc,sources,out));save()
    proof=record('proof',common.proof_command(dafny,source/'Connection.dfy',out/'proof.csv')+['--filter-symbol','ExpressionRecursive'])
    common.check_proof(proof,out/'proof.log',out/'proof.csv',inventory({f for f in sources if f.parent==HERE}))
    audit=record('audit',[dafny,'audit',source/'Connection.dfy']);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'audit.log').read_text()
    record('format',[dafny,'format','--check',*[f for f in source.glob('*.dfy') if not f.name.endswith('.template.dfy')]])
    record('solidity-format',['forge','fmt','--check',source/'RecursiveOracle.t.sol'])
    # Copy the existing cache oracles into this isolated test directory.
    shutil.copy2(snap/'formal/expressions/cache/CacheOracle.t.sol',source/'CacheOracle.t.sol')
    (snap/'foundry.toml').write_text('[profile.default]\nsrc="contracts"\ntest="formal/expressions/recursive"\nsolc='+json.dumps(str(solc))+'\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\n[lint]\nlint_on_build=false\n')
    evm=record('concrete',['forge','test','--root',snap,'--match-contract','RecursiveOracleTest|CacheOracleTest','-vv'],180)
    expected=re.findall(r'function (test\w+)\(', '\n'.join(f.read_text() for f in source.glob('*.sol')));observed=re.findall(r'^\[PASS\] (test\w+)\(', (out/'concrete.log').read_text(),re.M)
    evm.update(expectedTests=expected,passed=evm['passed'] and bool(expected) and sorted(expected)==sorted(observed))
    m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()}
    m['status']='passed' if m['inputsUnchanged'] and all(c['passed'] for c in m['checks']) else 'failed'
    m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    shutil.rmtree(snap/'out',ignore_errors=True);shutil.rmtree(snap/'cache',ignore_errors=True)
    m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'}
    save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)

if __name__=='__main__':main()
