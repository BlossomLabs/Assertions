#!/usr/bin/env python3
"""Verify source-connected core primitives, with complete closure."""
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
ROOT=HERE.parents[1]
spec=importlib.util.spec_from_file_location('constraint_runner',HERE.parent/'constraints/verify.py')
common=importlib.util.module_from_spec(spec);spec.loader.exec_module(common)
sha,run=common.sha,common.run


def closure(path):
    result={path.resolve()}
    for name in re.findall(r'^include "([^"]+)"',path.read_text(),re.M):
        result.update(closure(path.parent/name))
    return result


def inputs():
    dependencies=['contracts/Assertions.sol','contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol',
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


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    dafny,solc=a.dafny.resolve(),a.solc.resolve();solver=dafny.parent/'z3/bin/z3-4.12.1'
    pin=json.loads((HERE.parent/'abi/toolchain.json').read_text())
    versions={n:subprocess.check_output([str(binary),'--version'],text=True).strip() for n,binary in [('dafny',dafny),('z3',solver),('solc',solc),('forge',shutil.which('forge'))]}
    if versions['dafny']!=pin['dafnyVersion'] or '4.12.1' not in versions['z3'] or '0.8.36+commit.8a079791' not in versions['solc']: raise ValueError('Unpinned tool')
    sources=closure(HERE/'Source.generated.dfy')
    if {p for p in HERE.glob('*.dfy') if not p.name.endswith('.template.dfy')} - sources: raise ValueError('Unreachable local proof')
    paths=inputs();hashes={str(p.relative_to(ROOT)):sha(p) for p in paths};snap=out/'source-snapshot'
    for path in paths:
        dest=snap/path.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(path,dest)
    source=snap/'formal/core'
    manifest={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),
      'scope':'Source correspondence for resolve, gather, pick, read, chain and cond with arbitrary finite operand/hop lists, reusing the resolver and constraint proofs. get, nav composition and guarded probes remain separate.',
      'assumptions':['Pinned solc AST, structural gate, manual control-flow lowering and expression translator are trusted.',
        'Valid typed calldata and Solidity memory projection; physical memory does not wrap or alias unexpectedly.',
        'decodeCall and decodeOr return the actual solc decoder outcomes, including bare rejection. Decoder correctness is not proved.',
        'History-indexed external observations match code presence, staticcall outcome, returndata, sampled gas and native balance. Equal calls need not be deterministic.',
        'Sufficient local resources; all intermediate byte lengths and physical memory arithmetic are representable. Gas classification follows sampled values; no universal gas-exhaustion diagnosis is claimed.',
        'Typed error ABI serialization and call ABI selector bytes follow solc; concrete oracle checks exact bytes.',
        'Dafny/Boogie/Z3 are trusted; all included proof modules are verified afresh.'],
      'bounds':{'operands':None,'hops':None,'constraints':None,'orLeaves':None,'wordWidth':256},
      'sourceSha256':hashes,'versions':versions,'executableSha256':{n:sha(binary) for n,binary in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('solc',solc),('z3',solver)]},'checks':[]}
    def save(): (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    def record(name,command,timeout=900):
        job=run(command,out/(name+'.log'),timeout);job.update(name=name,passed=job['exitCode']==0);manifest['checks'].append(job);save();return job
    save()
    gate=record('source-gate',[sys.executable,'-B',source/'generate.py','--solc',solc,'--root',snap,'--output',out/'generated'])
    gate['passed']=gate['passed'] and (out/'generated/Source.generated.dfy').read_bytes()==(source/'Source.generated.dfy').read_bytes()
    if not gate['passed']: save();raise SystemExit('Source gate/generated drift')
    proof=record('proof',common.proof_command(dafny,source/'Source.generated.dfy',out/'proof.csv'),1200)
    common.check_proof(proof,out/'proof.log',out/'proof.csv',inventory(sources))
    audit=record('audit',[dafny,'audit',source/'Source.generated.dfy'])
    audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'audit.log').read_text()
    record('format',[dafny,'format','--check',source/'Words.dfy',source/'Model.dfy',source/'Source.generated.dfy'])
    record('solidity-format',['forge','fmt','--check',source/'CoreOracle.t.sol'])
    config='[profile.default]\nsrc="contracts"\ntest="formal/core"\nsolc='+json.dumps(str(solc))+'\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\n[lint]\nlint_on_build=false\n'
    (snap/'foundry.toml').write_text(config)
    concrete=record('concrete',['forge','test','--root',snap,'--match-contract','CoreOracleTest','-vv'],180)
    expected=re.findall(r'function (test\w+)\(', (source/'CoreOracle.t.sol').read_text());actual=re.findall(r'^\[PASS\] (test\w+)\(', (out/'concrete.log').read_text(),re.M)
    concrete.update(expectedTests=expected,passed=concrete['passed'] and sorted(actual)==sorted(expected) and bool(expected))
    manifest['inputsUnchanged']=hashes=={str(p.relative_to(ROOT)):sha(p) for p in inputs()}
    manifest['status']='passed' if manifest['inputsUnchanged'] and all(c['passed'] for c in manifest['checks']) else 'failed'
    manifest['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    shutil.rmtree(snap/'out',ignore_errors=True);shutil.rmtree(snap/'cache',ignore_errors=True)
    manifest['evidenceSha256']={str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='manifest.json'}
    save();print(manifest['status']);raise SystemExit(0 if manifest['status']=='passed' else 1)


if __name__=='__main__': main()
