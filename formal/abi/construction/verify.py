#!/usr/bin/env python3
"""Retain a complete modular proof baseline for production ABI correspondence."""
import argparse
import csv
import datetime
import importlib.util
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import time

HERE=Path(__file__).resolve().parent
ABI=HERE.parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('dynamic_verify',ABI/'dynamic/verify.py')
base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)
common=base.common
run,sha=base.run,base.sha
DIRECTORIES=['source','aggregate','words','descriptor','shape','parser','tuples','connection','dynamic','layout','construction']


def verify_modules(binary,solver,pin,sources,snap,out,reuse,hashes):
    """Reuse only completed modules with byte-identical transitive inputs.

    A failed/incomplete aggregate run may contain independently successful
    modules. Its aggregate status is never promoted: each reused module must
    itself have a successful command, complete native results and matching
    dependency hashes, tools and solver settings. Failed modules are rerun.
    """
    if reuse is None:return base.verify_modules(binary,solver,pin,sources,snap,out)
    old=json.loads(reuse.read_text())
    assert old.get('completedAt') and old.get('evidenceSha256')
    assert old['executableSha256']==hashes and old['toolchain']==pin
    assert all(sha(reuse.parent/n)==h for n,h in old['evidenceSha256'].items())
    previous=next(c for c in old['checks'] if c.get('name')=='all-proof-modules')
    candidates={j['moduleFile']:j for j in previous['moduleExecutions']}
    shutil.copy2(reuse,out/'reuse-baseline.json')
    started=time.monotonic();jobs=[];rows=[];logs=[];verified=0;errors=0
    directory=out/'modules';directory.mkdir()
    def closure(path):
        result={path}
        for name in re.findall(r'^include "([^"]+)"',path.read_text(),re.M):result.update(closure((path.parent/name).resolve()))
        return result
    for path in sorted(sources):
        name=str(path.relative_to(ABI)).replace('/','_').removesuffix('.dfy')
        key=str(path.relative_to(ROOT));log=directory/(name+'.log');data=directory/(name+'.csv')
        old_job=candidates.get(key);old_log=reuse.parent/'modules'/(name+'.log');old_data=reuse.parent/'modules'/(name+'.csv')
        dependency_hashes={str(p.relative_to(ROOT)):sha(snap/p.relative_to(ROOT)) for p in closure(path)}
        matching=all(old['sourceSha256'].get(n)==h for n,h in dependency_hashes.items())
        command=list(map(str,common.proof_command(binary,solver,pin,snap/path.relative_to(ROOT),data)));command.remove('--verify-included-files')
        prior_command=list(map(str,old_job['command'])) if old_job else []
        if len(prior_command)==len(command) and prior_command[2].endswith('/'+key) and prior_command[-1].startswith('csv;LogFileName='):
            prior_command[2]=command[2];prior_command[-1]=command[-1]
        matching=matching and prior_command==command
        prior_rows=common.native_results(old_data) if old_data.exists() else []
        reusable=matching and old_job and old_job['exitCode']==0 and old_job['summaryPresent'] and old_job['reportedErrors']==0 and old_log.exists()
        reusable=reusable and len(prior_rows)==old_job['verifiedBatches'] and all(r['TestResult.Outcome']=='Passed' for r in prior_rows)
        reusable=reusable and not re.search(r'Error:|time.?out|inconclusive|resource limit',old_log.read_text(),re.I)
        if reusable:
            shutil.copy2(old_log,log)
            if old_data.exists():shutil.copy2(old_data,data)
            job=dict(old_job)
            job['reusedFrom']={'manifestPath':str(reuse.resolve()),'manifestSha256':sha(reuse),'moduleLogSha256':sha(old_log),'transitiveInputSha256':dependency_hashes,'matchingVerifierArguments':True}
        else:
            command=common.proof_command(binary,solver,pin,snap/path.relative_to(ROOT),data);command.remove('--verify-included-files')
            remaining=900-(time.monotonic()-started)
            if remaining<=0:
                log.write_text('Outer proof-graph budget exhausted; module incomplete.\n');job={'command':list(map(str,command)),'exitCode':None,'timeout':True}
            else:job=run(command,log,max(1,int(remaining)))
        text=log.read_text();match=re.search(r'Dafny program verifier finished with (\d+) verified, (\d+) errors?',text)
        job.update(moduleFile=key,summaryPresent=bool(match),verifiedBatches=int(match[1]) if match else 0,reportedErrors=int(match[2]) if match else None)
        verified+=job['verifiedBatches'];errors+=job['reportedErrors'] or 0
        jobs.append(job);rows.extend(common.native_results(data));logs.append('MODULE '+key+'\n'+re.sub(r'Dafny program verifier finished with[^\n]*','',text))
    with (out/'verification.csv').open('w',newline='') as stream:
        if rows:
            writer=csv.DictWriter(stream,fieldnames=list(rows[0]));writer.writeheader();writer.writerows(rows)
    logs.append(f'Dafny program verifier finished with {verified} verified, {errors} errors\n');(out/'verify.log').write_text('\n'.join(logs))
    return {'name':'all-proof-modules','exitCode':0 if all(j['exitCode']==0 and j['summaryPresent'] for j in jobs) else 1,
      'moduleExecutions':jobs,'moduleCount':len(jobs),'outerBudgetSeconds':900,'reusedModules':sum('reusedFrom' in j for j in jobs),
      'verificationMode':'Every module accounted for. Reuse requires a completed successful module, identical complete transitive Dafny inputs, tool hashes and solver settings; changed or unsuccessful modules are executed anew.'}


def evm(source, oracles, compiler, out):
    tests=[name for oracle in oracles for name in re.findall(r'function (test\w+)\(',oracle.read_text())]
    assert len(tests)>0 and len(set(tests))==len(tests)
    with tempfile.TemporaryDirectory(prefix='abi-complete-oracle-') as temp:
        scratch=Path(temp);(scratch/'src').mkdir();(scratch/'test').mkdir()
        shutil.copy2(source,scratch/'src/AbiCodec.sol')
        for oracle in oracles:shutil.copy2(oracle,scratch/'test'/oracle.name)
        config='[profile.default]\nsrc="src"\ntest="test"\nsolc='+json.dumps(str(compiler))+'\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\n[lint]\nlint_on_build=false\n'
        (scratch/'foundry.toml').write_text(config);(out/'foundry.toml').write_text(config)
        result=run(['forge','test','--root',scratch,'-vv'],out/'concrete.log',120)
    text=(out/'concrete.log').read_text()
    result.update(expectedTests=tests,passedTests=re.findall(r'^\[PASS\] (test\w+)\(',text,re.M),
                  failedTests=sorted(set(re.findall(r'^\[FAIL:.*?\] (test\w+)\(',text,re.M))))
    return result


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--dafny',required=True);p.add_argument('--solc',required=True)
    p.add_argument('--dynamic-evidence',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
    p.add_argument('--reuse-evidence',type=Path,help='Completed baseline whose independently successful, unchanged modules may be reused with full provenance')
    a=p.parse_args();binary,solver,compiler,pin,versions,hashes=common.tools(a.dafny,a.solc)
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    entry=HERE/'Inverses.dfy';sources=set()
    def include(path):
        sources.add(path)
        for name in re.findall(r'^include "([^"]+)"',path.read_text(),re.M):
            child=(path.parent/name).resolve()
            if child not in sources:include(child)
    include(entry)
    expected={*ABI.glob('*.dfy')}
    for name in DIRECTORIES:expected.update((ABI/name).glob('*.dfy'))
    expected={p for p in expected if not p.name.endswith('.template.dfy')}
    assert sources==expected, 'Uninventoried proof source: '+str(sources^expected)
    inventory=[]
    for path in sorted(sources):
        module=re.search(r'^module (\w+)',path.read_text(),re.M)[1]
        for m in re.finditer(r'^  (?:(?:ghost|opaque) )?(lemma|method|function|predicate)(?: \{:[^}]+\})? (\w+)\(',path.read_text(),re.M):
            inventory.append({'name':module+'.'+m[2],'kind':m[1],'file':str(path.relative_to(ROOT))})
    artifacts=set(sources)|{ABI/'toolchain.json',ROOT/'contracts/lib/AbiCodec.sol'}
    for name in DIRECTORIES:
        artifacts.update(p for p in (ABI/name).iterdir() if p.is_file() and (p.suffix in ('.py','.json','.smt2','.sol') or p.name.endswith('.template.dfy')))
    snap=out/'source-snapshot'
    for path in sorted(artifacts):
        dest=snap/path.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(path,dest)
    manifest={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),
      'revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
      'scope':'Complete source-level recursive ABI correspondence: descriptor parsing, word rules, static and dynamic validation, cached validation, tuple layout, context routing, component validation, memory projection, assembly, tuple and array construction, unpacking, both inverse directions.',
      'sourceSha256':{str(path.relative_to(ROOT)):sha(path) for path in sorted(artifacts)},'sourceSnapshot':'source-snapshot',
      'versions':versions,'executableSha256':hashes,'toolchain':pin,'inventory':inventory,'checks':[],
      'bounds':{'depth':None,'arity':None,'count':'uint256 and proved span guards','loopUnrolling':None,'solverSecondsPerBatch':30},
      'assumptions':[
        'Lengths and offsets fit uint256. Checked arithmetic outcomes are explicit. Construction output sizes fit uint256; adequate gas, stack, allocation and nonwrapping physical calldata/memory layout are environmental contracts.',
        'Cached shapes and tuple plans must match their descriptors. Actual parser/layout entrypoints discharge those premises; forged internal cache objects are outside the caller contract.',
        'CursorRoom is sufficient to exclude the characterized zero-copy cursor panic. The inverse theorems derive it from the stated descriptor/value arithmetic budget, without finite nesting or loop bounds.',
        'Pinned solc AST, restricted Python translation, loop factoring, byte-object projection of calldata and MSTORE/MCOPY, Dafny/Boogie/Z3 are trusted. Compiler correctness and universal arbitrary-geometry bytecode correspondence are not claimed.',
        'The source-SMT word classifier is linked through the unchanged, hash-checked prior baseline. Every Dafny module body is accounted for by execution or a successful result with identical transitive inputs, tool hashes and verifier arguments; dependency contracts are never silently left unchecked.'
      ]}
    def save():(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    def add(result,passed):result['passed']=bool(passed);manifest['checks'].append(result);save()
    save()
    old=json.loads(a.dynamic_evidence.read_text());shutil.copy2(a.dynamic_evidence,out/'dynamic-baseline.json')
    integrity=all(sha(a.dynamic_evidence.parent/n)==h for n,h in old['evidenceSha256'].items())
    inherited=[p for p in sources if not any(ABI/name in p.parents for name in ('layout','construction'))]
    matching=all(sha(path)==old['sourceSha256'][str(path.relative_to(ROOT))] for path in inherited)
    matching=matching and sha(ROOT/'contracts/lib/AbiCodec.sol')==old['sourceSha256']['contracts/lib/AbiCodec.sol']
    add({'name':'inherited-source-SMT-and-translator-gates','manifestSha256':sha(a.dynamic_evidence),'manifestPath':str(a.dynamic_evidence.resolve()),'evidenceIntegrity':integrity,'matchingDependencies':matching},old['status']=='passed' and integrity and matching)
    for name,files in [('dynamic',['Body','Validation']),('layout',['Count','Layout']),('construction',['Assembly','Context','Component','Tuple','Pack','Unpack'])]:
        generated=out/('generated-'+name)
        result=run([sys.executable,'-B',snap/'formal/abi'/name/'generate.py','--solc',compiler,'--source',snap/'contracts/lib/AbiCodec.sol','--output',generated],out/(name+'-generate.log'))
        result['freshness']=result['exitCode']==0 and all((generated/(n+'.generated.dfy')).read_bytes()==(snap/'formal/abi'/name/(n+'.generated.dfy')).read_bytes() for n in files)
        add(result,result['freshness'])
    if not all(c['passed'] for c in manifest['checks']):return 1
    proof=verify_modules(binary,solver,pin,sources,snap,out,a.reuse_evidence,hashes)
    native,declarations,passed=base.proof_results(out,inventory,proof)
    manifest.update(nativeResults=native,declarationResults=declarations,lemmaCount=sum(d['kind']=='lemma' for d in inventory),methodCount=sum(d['kind']=='method' for d in inventory))
    add(proof,passed)
    audit=run([binary,'audit',snap/entry.relative_to(ROOT)],out/'audit.log')
    add(audit,audit['exitCode']==0 and 'auditor completed with 0 findings' in (out/'audit.log').read_text())
    concrete=evm(snap/'contracts/lib/AbiCodec.sol',[snap/'formal/abi/dynamic/DynamicOracle.t.sol',snap/'formal/abi/construction/ConstructionOracle.t.sol'],compiler,out)
    add(concrete,concrete['exitCode']==0 and len(concrete['expectedTests'])==40 and sorted(concrete['expectedTests'])==sorted(concrete['passedTests']))
    fmt=run([binary,'format','--check',*[snap/path.relative_to(ROOT) for path in sorted(sources)]],out/'format.log');add(fmt,fmt['exitCode']==0)
    sfmt=run(['forge','fmt','--check',snap/'formal/abi/construction/ConstructionOracle.t.sol'],out/'solidity-format.log');add(sfmt,sfmt['exitCode']==0)
    manifest['versions']['forge']=subprocess.check_output(['forge','--version'],text=True).strip()
    manifest['sourceDrift']=any(sha(ROOT/n)!=h for n,h in manifest['sourceSha256'].items())
    failure=bool(proof.get('reportedErrors')) or any(d['status']=='failed' for d in declarations) or bool(concrete['failedTests'])
    manifest['status']='passed' if all(c['passed'] for c in manifest['checks']) and not manifest['sourceDrift'] else 'failed' if failure else 'incomplete'
    manifest['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    manifest['evidenceSha256']={str(path.relative_to(out)):sha(path) for path in sorted(out.rglob('*')) if path.is_file() and path.name!='manifest.json'}
    save();print(json.dumps({'status':manifest['status'],'lemmas':manifest['lemmaCount'],'methods':manifest['methodCount'],'batches':proof['verifiedBatches'],'EVM':len(concrete['passedTests'])}))
    return 0 if manifest['status']=='passed' else 1

if __name__=='__main__':sys.exit(main())
