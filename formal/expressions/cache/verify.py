#!/usr/bin/env python3
"""Verify cache transition summaries; full recursive evaluation remains separate."""
import argparse
import datetime
import importlib.util
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('constraint_runner',HERE.parents[1]/'constraints/verify.py')
common=importlib.util.module_from_spec(spec);spec.loader.exec_module(common)
sha,run=common.sha,common.run


def closure(path):
    result={path.resolve()}
    for name in re.findall(r'^include "([^"]+)"',path.read_text(),re.M):
        result.update(closure(path.parent/name))
    return result


def inputs():
    dependencies=['contracts/Expressions.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol',
      'formal/navigation/generate.py','formal/abi/shape/generate.py','formal/abi/source/generate.py',
      'formal/constraints/verify.py','formal/resolution/generate.py','formal/abi/toolchain.json']
    return sorted(closure(HERE/'Source.generated.dfy')|{p for p in HERE.iterdir() if p.is_file()}|{ROOT/p for p in dependencies})


def inventory(paths):
    declarations=[]
    for path in sorted(paths):
        text=path.read_text();module=re.search(r'^module (\w+)',text,re.M)[1]
        for m in re.finditer(r'^  (?:(?:ghost|opaque) )?(lemma|method|function|predicate|type)(?: \{:[^}]+\})? (\w+)(?:\(| =)',text,re.M):
            declarations.append({'name':module+'.'+m[2],'kind':m[1],'file':str(path.relative_to(ROOT))})
    return declarations


def check_dependencies(dafny,solc,sources,out):
    paths=['formal/abi/evidence/production-abi-correspondence/manifest.json', 'formal/expressions/admission/evidence/expression-admission/manifest.json', 'formal/resolution/evidence/resolution-judge/manifest.json']
    return common.check_dependencies(dafny, solc, sources, out, root=ROOT, here=HERE,
                                     paths=paths, inventory=inventory, closure=closure, hash_file=sha)


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    dafny,solc=a.dafny.resolve(),a.solc.resolve();solver=dafny.parent/'z3/bin/z3-4.12.1'
    pin=json.loads((HERE.parents[1]/'abi/toolchain.json').read_text())
    versions={n:subprocess.check_output([str(binary),'--version'],text=True).strip() for n,binary in [('dafny',dafny),('z3',solver),('solc',solc),('forge',shutil.which('forge'))]}
    if versions['dafny']!=pin['dafnyVersion'] or '4.12.1' not in versions['z3'] or '0.8.36+commit.8a079791' not in versions['solc']: raise ValueError('Unpinned tool')
    sources=closure(HERE/'Source.generated.dfy')
    if {p for p in HERE.glob('*.dfy') if not p.name.endswith('.template.dfy')} - sources: raise ValueError('Unreachable local proof')
    paths=inputs();hashes={str(p.relative_to(ROOT)):sha(p) for p in paths};snap=out/'source-snapshot'
    for path in paths:
        dest=snap/path.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(path,dest)
    source=snap/'formal/expressions/cache'
    manifest={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),
      'scope':'Selected Expressions cache/auth transitions: admitted cold cache, canonical cache hits, validated stores, successful adoption conditional on an evaluator receipt, failed-attempt discard and exhaustion. Not a complete recursive evaluator theorem.',
      'assumptions':['Pinned solc AST, structural gate, manual control-flow lowering and expression translator are trusted.',
        'Valid typed calldata and Solidity memory projection; physical memory does not wrap or alias unexpectedly.',
        'The hash function is actual keccak256. Admission retains hash comparison exactly; literal bytes type inference additionally excludes a collision with bytes among this graph’s descriptors.',
        'Sufficient local resources; descriptor, node and reference counts and intermediate memory arithmetic are representable. No gas/resource-failure diagnosis is claimed.',
        'Typed error ABI serialization and call ABI selector bytes follow solc; concrete oracle checks exact bytes.',
        'Guard receipts match actual self-call outcomes; calldata-to-memory copy and separate call-frame memory are part of the projection. SuccessfulReceipt must still be established by the recursive evaluator; adoption validity is conditional on it.',
        'Dafny/Boogie/Z3 are trusted. New ExpressionCache declarations are verified; dependency proofs are reused only after source, tool, native-row and retained evidence audits.'],
      'bounds':{'nodes':None,'referencesPerNode':None,'descriptorDepth':None,'wordWidth':256},
      'sourceSha256':hashes,'versions':versions,'executableSha256':{n:sha(binary) for n,binary in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('solc',solc),('z3',solver)]},'checks':[]}
    def save(): (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    def record(name,command,timeout=900):
        job=run(command,out/(name+'.log'),timeout);job.update(name=name,passed=job['exitCode']==0);manifest['checks'].append(job);save();return job
    save()
    gate=record('source-gate',[sys.executable,'-B',source/'generate.py','--solc',solc,'--root',snap,'--output',out/'generated'])
    gate['passed']=gate['passed'] and all((out/'generated'/name).read_bytes()==(source/name).read_bytes() for name in ['Source.generated.dfy'])
    if not gate['passed']: save();raise SystemExit('Source gate/generated drift')
    dependencies = check_dependencies(dafny,solc,sources,out)
    manifest['checks'].append(dependencies);save()
    proof=record('proof',common.proof_command(dafny,source/'Source.generated.dfy',out/'proof.csv')+['--filter-symbol','ExpressionCache'],1200)
    common.check_proof(proof,out/'proof.log',out/'proof.csv',inventory({p for p in sources if p.parent == HERE}))
    audit=record('audit',[dafny,'audit',source/'Source.generated.dfy'])
    audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'audit.log').read_text()
    record('format',[dafny,'format','--check',*[p for p in sorted(source.glob('*.dfy')) if not p.name.endswith('.template.dfy')]])
    record('solidity-format',['forge','fmt','--check',source/'CacheOracle.t.sol'])
    config='[profile.default]\nsrc="contracts"\ntest="formal/expressions/cache"\nsolc='+json.dumps(str(solc))+'\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\n[lint]\nlint_on_build=false\n'
    (snap/'foundry.toml').write_text(config)
    concrete=record('concrete',['forge','test','--root',snap,'--match-contract','CacheOracleTest','-vv'],180)
    expected=re.findall(r'function (test\w+)\(', (source/'CacheOracle.t.sol').read_text());actual=re.findall(r'^\[PASS\] (test\w+)\(', (out/'concrete.log').read_text(),re.M)
    concrete.update(expectedTests=expected,passed=concrete['passed'] and sorted(actual)==sorted(expected) and bool(expected))
    manifest['inputsUnchanged']=hashes=={str(p.relative_to(ROOT)):sha(p) for p in inputs()}
    manifest['status']='passed' if manifest['inputsUnchanged'] and all(c['passed'] for c in manifest['checks']) else 'failed'
    manifest['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    shutil.rmtree(snap/'out',ignore_errors=True);shutil.rmtree(snap/'cache',ignore_errors=True)
    manifest['evidenceSha256']={str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='manifest.json'}
    save();print(manifest['status']);raise SystemExit(0 if manifest['status']=='passed' else 1)


if __name__=='__main__': main()
