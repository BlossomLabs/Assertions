#!/usr/bin/env python3
"""Verify source-connected static ABI validation and recursive descriptor head preludes."""
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
    match=re.search(r'Dafny program verifier finished with (\d+) verified, (\d+) errors?',text)
    proof['verifiedBatches']=int(match[1]) if match else 0
    proof['reportedErrors']=int(match[2]) if match else None
    proof['timedOutDeclarations']=sorted(timeout)
    passed=proof['exitCode']==0 and match and match[2]=='0' and len(native)==proof['verifiedBatches']>0 and all(r['TestResult.Outcome']=='Passed' for r in native) and all(d['status']=='passed' for d in results if d['kind'] in ('lemma','method')) and not re.search(r'time.?out|inconclusive|resource limit',text,re.I)
    return native,results,bool(passed)


def verify_modules(binary, solver, pin, sources, snap, out):
    """Verify every source module once; included dependencies are separate jobs.

    Dafny's modular contracts are unchanged. Keeping unrelated successor modules
    out of an older module's SMT context avoids cross-module trigger sensitivity.
    A single 900-second outer budget and the pinned per-batch limit still apply.
    """
    import csv
    import time
    started=time.monotonic(); jobs=[]; rows=[]; logs=[]; verified=0; errors=0
    directory=out/'modules';directory.mkdir()
    for path in sorted(sources):
        name=str(path.relative_to(ABI)).replace('/','_').removesuffix('.dfy')
        log=directory/(name+'.log'); data=directory/(name+'.csv')
        command=common.proof_command(binary,solver,pin,snap/path.relative_to(ROOT),data)
        command.remove('--verify-included-files')
        remaining=900-(time.monotonic()-started)
        if remaining<=0:
            log.write_text('Outer proof-graph budget exhausted; module incomplete.\n')
            job={'command':list(map(str,command)),'exitCode':None,'timeout':True}
        else: job=run(command,log,max(1,int(remaining)))
        text=log.read_text(); match=re.search(r'Dafny program verifier finished with (\d+) verified, (\d+) errors?',text)
        job['moduleFile']=str(path.relative_to(ROOT));job['summaryPresent']=bool(match)
        job['verifiedBatches']=int(match[1]) if match else 0
        job['reportedErrors']=int(match[2]) if match else None
        verified+=job['verifiedBatches'];errors+=job['reportedErrors'] or 0
        jobs.append(job);rows.extend(common.native_results(data))
        logs.append('MODULE '+str(path.relative_to(ROOT))+'\n'+re.sub(r'Dafny program verifier finished with[^\n]*','',text))
    with (out/'verification.csv').open('w',newline='') as stream:
        if rows:
            writer=csv.DictWriter(stream,fieldnames=list(rows[0]));writer.writeheader();writer.writerows(rows)
    logs.append(f'Dafny program verifier finished with {verified} verified, {errors} errors\n')
    (out/'verify.log').write_text('\n'.join(logs))
    return {'name':'all-proof-modules','exitCode':0 if all(j['exitCode']==0 and j['summaryPresent'] for j in jobs) else 1,
            'moduleExecutions':jobs,'moduleCount':len(jobs),'outerBudgetSeconds':900,
            'verificationMode':'Every dependency module verified once at its own entrypoint; no excluded declarations.'}


def evm(source, oracle, compiler, out):
    tests=re.findall(r'function (test\w+)\(',oracle.read_text())
    assert len(tests)==12 and len(set(tests))==12
    with tempfile.TemporaryDirectory(prefix='abi-connection-oracle-') as temp:
        scratch=Path(temp)
        (scratch/'src').mkdir();(scratch/'test').mkdir()
        shutil.copy2(source,scratch/'src/AbiCodec.sol')
        shutil.copy2(oracle,scratch/'test/ConnectionOracle.t.sol')
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
    p.add_argument('--tuple-evidence',required=True,type=Path)
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
    expected={*ABI.glob('*.dfy'),*(ABI/'source').glob('*.dfy'),*(ABI/'aggregate').glob('*.dfy'),*(ABI/'words').glob('*.dfy'),*(ABI/'descriptor').glob('*.dfy'),*(ABI/'shape').glob('*.dfy'),*(ABI/'parser').glob('*.dfy'),*(ABI/'tuples').glob('*.dfy'),*HERE.glob('*.dfy')} - {ABI/'shape/TypeShape.template.dfy',ABI/'parser/Parser.template.dfy',ABI/'tuples/CheckWords.template.dfy',HERE/'Bridge.template.dfy'}
    assert sources==expected,'Uninventoried proof source'
    inventory=[]
    for path in sorted(sources):
        module=re.search(r'^module (\w+)',path.read_text(),re.M)[1]
        for m in re.finditer(r'^  (?:(?:ghost|opaque) )?(lemma|method|function|predicate)(?: \{:[^}]+\})? (\w+)\(',path.read_text(),re.M):
            inventory.append({'name':module+'.'+m[2],'kind':m[1],'file':str(path.relative_to(ROOT))})
    artifacts=sorted(sources|set(HERE.glob('*.py'))|set(HERE.glob('*.sol'))|{ABI/'tuples/CheckWords.template.dfy',HERE/'Bridge.template.dfy',HERE/'structure.json',ABI/'tuples/structure.json',*list((ABI/'tuples').glob('*.py')),ABI/'parser/Parser.template.dfy',*list((ABI/'parser').glob('*.py')),ABI/'words/generate.py',ABI/'shape/structure.json',ABI/'shape/TypeShape.template.dfy',ABI/'shape/gates.smt2',*list((ABI/'shape').glob('*.py')),ABI/'descriptor/verify.py',ABI/'source/verify.py',ABI/'toolchain.json',ROOT/'contracts/lib/AbiCodec.sol'})
    snap=out/'source-snapshot'
    for path in artifacts:
        dest=snap/path.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(path,dest)
    manifest={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),
      'revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
      'scope':'Source-derived static validate branch accepts exactly canonical encodings in the independent recursive ABI model, including narrow-word rules. No assumed data-span bound. Source-derived suffixStart, array descriptor/count/head prelude and tuple first head-sizing pass are connected to accepted parser syntax. Complete dynamic body integration remains separate.',
      'sourceSha256':{str(path.relative_to(ROOT)):sha(path) for path in artifacts},'sourceSnapshot':'source-snapshot',
      'versions':versions,'executableSha256':hashes,'toolchain':pin,'inventory':inventory,'checks':[],
      'bounds':{'tupleDepth':None,'tupleArity':None,'suffixCount':None,'copyCount':'uint256 subject to checked data-span guards; zero accepted','loopUnrolling':None,'solverSecondsPerBatch':30},
      'assumptions':['Static descriptors are accepted by the proved source-derived parser. Value lengths and caller offsets fit uint256; the static length guard establishes the complete data span.',
       'Array and tuple head preludes require a descriptor prefix accepted at the specified end. They do not establish correctness of the recursive dynamic body or its second tuple pass.',
       'The exhaustive source-SMT whitelist maps to Dafny rule constructors. Opaque names admit every word. Error offsets model ContextKind.Value; other error contexts remain separate.',
       'Valid nonwrapping calldata/memory layout and sufficient gas, stack and allocation resources; no unbounded-resource or compiler-correctness theorem.',
       'Pinned solc AST, restricted Python translation, loop/recursion factoring and memory projection, Dafny/Boogie/Z3 are trusted.',
       'Full suffixStart, validateStatic and body AST skeletons are gated. Only the stated body preludes are proved here; AST gating alone is not a body proof.']}
    def save(): (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    def add(result,passed):
        result['passed']=bool(passed);manifest['checks'].append(result);save()
    save()
    old=json.loads(a.tuple_evidence.read_text())
    shutil.copy2(a.tuple_evidence,out/'tuple-baseline.json')
    integrity=all(sha(a.tuple_evidence.parent/n)==h for n,h in old['evidenceSha256'].items())
    old_match=all(sha(path)==old['sourceSha256'][str(path.relative_to(ROOT))] for path in sources if HERE not in path.parents)
    old_match=old_match and sha(ROOT/'contracts/lib/AbiCodec.sol')==old['sourceSha256']['contracts/lib/AbiCodec.sol']
    add({'name':'prior-tuple-parser-and-shape-gates','manifestSha256':sha(a.tuple_evidence),'manifestPath':str(a.tuple_evidence.resolve()),'evidenceIntegrity':integrity,'matchingDependencies':old_match},old['status']=='passed' and integrity and old_match)
    word=json.loads(a.word_evidence.read_text())
    shutil.copy2(a.word_evidence,out/'word-baseline.json')
    word_integrity=all(sha(a.word_evidence.parent/n)==h for n,h in word['evidenceSha256'].items())
    word_match=all(sha(ROOT/n)==word['sourceSnapshotSha256'][n] for n in ['contracts/lib/AbiCodec.sol','formal/abi/words/generate.py'])
    add({'name':'word-classifier-interface','manifestSha256':sha(a.word_evidence),'manifestPath':str(a.word_evidence.resolve()),'evidenceIntegrity':word_integrity,'matchingDependencies':word_match,'SMTCount':len(word['smtResults'])},word['status']=='passed' and word_integrity and word_match and len(word['smtResults'])==107 and all(q['status']=='passed' for q in word['smtResults']))
    names_spec=importlib.util.spec_from_file_location('tuple_names',snap/'formal/abi/tuples/names.py')
    names=importlib.util.module_from_spec(names_spec);names_spec.loader.exec_module(names)
    rendered,whitelist=names.render()
    (out/'whitelist.json').write_text(json.dumps(whitelist,indent=2)+'\n')
    add({'name':'classifier-name-mapping','count':len(whitelist)},len(whitelist)==96 and rendered==(snap/'formal/abi/tuples/Names.generated.dfy').read_text())
    gates=run([solver,'-smt2',snap/'formal/abi/shape/gates.smt2'],out/'gates.log',60)
    gates['properties']=['uint32-or-bound','five-byte-name-extraction','six-byte-name-extraction']
    gates['outcomes']=(out/'gates.log').read_text().splitlines()
    add(gates,gates['exitCode']==0 and gates['outcomes']==['unsat']*3)
    gen=run([sys.executable,'-B',snap/'formal/abi/connection/generate.py','--solc',compiler,'--source',snap/'contracts/lib/AbiCodec.sol','--output',out/'generated'],out/'generate.log')
    gen['freshness']=gen['exitCode']==0 and (out/'generated/Bridge.generated.dfy').read_bytes()==(snap/'formal/abi/connection/Bridge.generated.dfy').read_bytes()
    add(gen,gen['freshness'])
    if not gen['passed']: return 1
    proof=verify_modules(binary,solver,pin,sources,snap,out)
    native,declarations,passed=proof_results(out,inventory,proof)
    manifest['nativeResults']=native;manifest['declarationResults']=declarations
    manifest['lemmaCount']=sum(d['kind']=='lemma' for d in inventory);manifest['methodCount']=sum(d['kind']=='method' for d in inventory)
    add(proof,passed)
    audit=run([binary,'audit',snap/'formal/abi/connection/Refinement.dfy'],out/'audit.log')
    add(audit,audit['exitCode']==0 and 'auditor completed with 0 findings' in (out/'audit.log').read_text())
    concrete=evm(snap/'contracts/lib/AbiCodec.sol',snap/'formal/abi/connection/ConnectionOracle.t.sol',compiler,out)
    add(concrete,concrete['exitCode']==0 and sorted(concrete['expectedTests'])==sorted(concrete['passedTests']))
    fmt=run([binary,'format','--check',*[snap/path.relative_to(ROOT) for path in sorted(sources)]],out/'format.log')
    add(fmt,fmt['exitCode']==0)
    sfmt=run(['forge','fmt','--check',snap/'formal/abi/connection/ConnectionOracle.t.sol'],out/'solidity-format.log')
    add(sfmt,sfmt['exitCode']==0)
    manifest['versions']['forge']=subprocess.check_output(['forge','--version'],text=True).strip()
    manifest['sourceDrift']=any(sha(ROOT/n)!=h for n,h in manifest['sourceSha256'].items())
    failure=bool(proof.get('reportedErrors')) or any(d['status']=='failed' for d in declarations) or bool(concrete['failedTests'])
    manifest['status']='passed' if all(c['passed'] for c in manifest['checks']) and not manifest['sourceDrift'] else 'failed' if failure else 'incomplete'
    manifest['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['evidenceSha256']={str(path.relative_to(out)):sha(path) for path in sorted(out.rglob('*')) if path.is_file() and path.name!='manifest.json'}
    save()
    print(json.dumps({'status':manifest['status'],'lemmas':manifest['lemmaCount'],'methods':manifest['methodCount'],'batches':proof['verifiedBatches'],'EVM':len(concrete['passedTests'])}))
    return 0 if manifest['status']=='passed' else 1


if __name__=='__main__':
    sys.exit(main())
