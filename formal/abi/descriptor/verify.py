#!/usr/bin/env python3
"""Verify suffix traversal plus the existing recursive ABI proof dependencies."""
import argparse
import datetime
import importlib.util
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ABI = HERE.parent
ROOT = HERE.parents[2]
spec = importlib.util.spec_from_file_location('abi_common', ABI/'source/verify.py')
common = importlib.util.module_from_spec(spec)
spec.loader.exec_module(common)
run,sha = common.run,common.sha


def proof_results(out, inventory, proof):
    native = common.native_results(out/'verification.csv')
    text = (out/'verify.log').read_text()
    timeout = set(re.findall(r"Verification of '([^']+)' timed out",text))
    results=[]
    for d in inventory:
        rows=[r for r in native if r['TestResult.DisplayName'].split(' (')[0]==d['name']]
        status=('incomplete' if d['name'] in timeout else
                'failed' if any(r['TestResult.Outcome']=='Failed' for r in rows) else
                'incomplete' if any(r['TestResult.Outcome']!='Passed' for r in rows) else 'passed') if rows else 'definition-no-separate-batch'
        results.append(dict(d,status=status,batches=len(rows)))
    match=re.search(r'Dafny program verifier finished with (\d+) verified, (\d+) errors',text)
    proof['verifiedBatches']=int(match[1]) if match else 0
    proof['timedOutDeclarations']=sorted(timeout)
    passed=proof['exitCode']==0 and match and match[2]=='0' and len(native)==proof['verifiedBatches']>0 and all(r['TestResult.Outcome']=='Passed' for r in native) and all(d['status']=='passed' for d in results if d['kind'] in ('lemma','method')) and not re.search(r'time.?out|inconclusive|resource limit',text,re.I)
    return native,results,bool(passed)


def evm(source, oracle, compiler, out):
    tests=re.findall(r'function (test\w+)\(',oracle.read_text())
    assert len(tests)==6 and len(set(tests))==6
    with tempfile.TemporaryDirectory(prefix='abi-suffix-oracle-') as temp:
        scratch=Path(temp)
        (scratch/'src').mkdir();(scratch/'test').mkdir()
        shutil.copy2(source,scratch/'src/AbiCodec.sol')
        shutil.copy2(oracle,scratch/'test/SuffixOracle.t.sol')
        config='[profile.default]\nsrc="src"\ntest="test"\nsolc='+json.dumps(str(compiler))+'\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\n[lint]\nlint_on_build=false\n'
        (scratch/'foundry.toml').write_text(config)
        (out/'foundry.toml').write_text(config)
        result=run(['forge','test','--root',scratch,'-vv'],out/'concrete.log',120)
    text=(out/'concrete.log').read_text()
    result['expectedTests']=tests
    result['passedTests']=re.findall(r'^\[PASS\] (test\w+)\(',text,re.M)
    result['failedTests']=sorted(set(re.findall(r'^\[FAIL:.*?\] (test\w+)\(',text,re.M)))
    return result


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--dafny',required=True)
    p.add_argument('--solc',required=True)
    p.add_argument('--word-evidence',required=True,type=Path)
    p.add_argument('--output',required=True,type=Path)
    a=p.parse_args()
    binary,solver,compiler,pin,versions,hashes=common.tools(a.dafny,a.solc)
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    entry=HERE/'Refinement.dfy';sources=set()
    def include(path):
        sources.add(path)
        for name in re.findall(r'^include "([^"]+)"',path.read_text(),re.M):
            child=(path.parent/name).resolve()
            if child not in sources: include(child)
    include(entry)
    expected={*ABI.glob('*.dfy'),*(ABI/'source').glob('*.dfy'),*(ABI/'aggregate').glob('*.dfy'),*(ABI/'words').glob('*.dfy'),*HERE.glob('*.dfy')}
    assert sources==expected,'Uninventoried proof source'
    inventory=[]
    for path in sorted(sources):
        module=re.search(r'^module (\w+)',path.read_text(),re.M)[1]
        for m in re.finditer(r'^  (?:(?:ghost|opaque) )?(lemma|method|function|predicate)(?: \{:[^}]+\})? (\w+)\(',path.read_text(),re.M):
            inventory.append({'name':module+'.'+m[2],'kind':m[1],'file':str(path.relative_to(ROOT))})
    artifacts=sorted(sources|set(HERE.glob('*.py'))|set(HERE.glob('*.sol'))|{ABI/'source/verify.py',ABI/'toolchain.json',ROOT/'contracts/lib/AbiCodec.sol'})
    snap=out/'source-snapshot'
    for path in artifacts:
        dest=snap/path.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(path,dest)
    manifest={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),
      'revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
      'scope':'Source-derived validated static suffix traversal and source-checked non-tuple checkWords composition; unrestricted parser and recursive tuple traversal still open.',
      'sourceSha256':{str(path.relative_to(ROOT)):sha(path) for path in artifacts},'sourceSnapshot':'source-snapshot',
      'versions':versions,'executableSha256':hashes,'toolchain':pin,'inventory':inventory,'checks':[],
      'bounds':{'suffixCount':None,'digitCount':None,'suffixProduct':'1..2^32-1','inputLength':'<2^256','loopUnrolling':None,'solverSecondsPerBatch':30,'suffixMethod':'isolate_assertions; every obligation retained'},
      'assumptions':['Validated nonempty decimal suffixes; positive counts and product below 2^32 are premises, not derived from typeShape.',
       'wordRule result/nameEnd supplied through the separately verified classifier interface; tuple branch and general descriptor traversal remain open.',
       'Valid calldata/memory layout, nonwrapping base pointers and sufficient execution resources; no gas/allocation theorem.',
       'Pinned solc AST, restricted Python translation, Dafny/Boogie/Z3 and memory projection are trusted; no compiler correctness theorem.',
       'Whole-loop AST skeleton is checked; preincrement loop normalization and ghost syntax witnesses are explicit translation steps.']}
    def save(): (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    def add(result,passed):
        result['passed']=bool(passed);manifest['checks'].append(result);save()
    save()
    old=json.loads(a.word_evidence.read_text())
    shutil.copy2(a.word_evidence,out/'word-baseline.json')
    integrity=all(sha(a.word_evidence.parent/n)==h for n,h in old['evidenceSha256'].items())
    old_match=all(sha(path)==old['sourceSnapshotSha256'][str(path.relative_to(ROOT))] for path in sources if HERE not in path.parents)
    old_match=old_match and sha(ROOT/'contracts/lib/AbiCodec.sol')==old['sourceSnapshotSha256']['contracts/lib/AbiCodec.sol']
    add({'name':'prior-word-mask-source-gates','manifestSha256':sha(a.word_evidence),'manifestPath':str(a.word_evidence.resolve()),'evidenceIntegrity':integrity,'matchingDependencies':old_match},old['status']=='passed' and integrity and old_match and len(old['smtResults'])==107 and all(q['status']=='passed' for q in old['smtResults']))
    gen=run([sys.executable,'-B',snap/'formal/abi/descriptor/generate.py','--solc',compiler,'--source',snap/'contracts/lib/AbiCodec.sol','--output',out/'generated'],out/'generate.log')
    gen['freshness']=gen['exitCode']==0 and (out/'generated/Suffixes.generated.dfy').read_bytes()==(snap/'formal/abi/descriptor/Suffixes.generated.dfy').read_bytes()
    add(gen,gen['freshness'])
    if not gen['passed']: return 1
    proof=run(common.proof_command(binary,solver,pin,snap/'formal/abi/descriptor/Refinement.dfy',out/'verification.csv'),out/'verify.log',900)
    native,declarations,passed=proof_results(out,inventory,proof)
    manifest['nativeResults']=native;manifest['declarationResults']=declarations
    manifest['lemmaCount']=sum(d['kind']=='lemma' for d in inventory);manifest['methodCount']=sum(d['kind']=='method' for d in inventory)
    add(proof,passed)
    audit=run([binary,'audit',snap/'formal/abi/descriptor/Refinement.dfy'],out/'audit.log')
    add(audit,audit['exitCode']==0 and 'auditor completed with 0 findings' in (out/'audit.log').read_text())
    concrete=evm(snap/'contracts/lib/AbiCodec.sol',snap/'formal/abi/descriptor/SuffixOracle.t.sol',compiler,out)
    add(concrete,concrete['exitCode']==0 and sorted(concrete['expectedTests'])==sorted(concrete['passedTests']))
    fmt=run([binary,'format','--check',*[snap/path.relative_to(ROOT) for path in sorted(sources)]],out/'format.log')
    add(fmt,fmt['exitCode']==0)
    sfmt=run(['forge','fmt','--check',snap/'formal/abi/descriptor/SuffixOracle.t.sol'],out/'solidity-format.log')
    add(sfmt,sfmt['exitCode']==0)
    manifest['versions']['forge']=subprocess.check_output(['forge','--version'],text=True).strip()
    manifest['sourceDrift']=any(sha(ROOT/n)!=h for n,h in manifest['sourceSha256'].items())
    failure=any(d['status']=='failed' for d in declarations) or bool(concrete['failedTests'])
    manifest['status']='passed' if all(c['passed'] for c in manifest['checks']) and not manifest['sourceDrift'] else 'failed' if failure else 'incomplete'
    manifest['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['evidenceSha256']={str(path.relative_to(out)):sha(path) for path in sorted(out.rglob('*')) if path.is_file() and path.name!='manifest.json'}
    save()
    print(json.dumps({'status':manifest['status'],'lemmas':manifest['lemmaCount'],'methods':manifest['methodCount'],'batches':proof['verifiedBatches'],'EVM':len(concrete['passedTests'])}))
    return 0 if manifest['status']=='passed' else 1


if __name__=='__main__':
    sys.exit(main())
