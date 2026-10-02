#!/usr/bin/env python3
"""Retain exact runtime binding and native semantic mutation for empty OR helper."""
import argparse,csv,datetime,hashlib,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
def load(name,path):
    spec=importlib.util.spec_from_file_location(name,path);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);return module
public=load('empty_public_binding',HERE.parent.parent/'constrained-raw/public/verify.py')
base=public.base;common=public.common;sha=public.sha

def inputs(entry):
    files=set(public.inputs(entry))|set(base.closure(HERE/'OrPrepare.generated.dfy'))|set(base.closure(HERE/'NativeSelector.dfy'))
    files|={HERE/name for name in ['verify-empty.py','generate-empty.py','generate-abort.py','generate-prepare.py','evm-discovery.mjs','EmptyDecoder.mapping.json','EmptyAbort.mapping.json','OrPrepare.mapping.json']}
    return sorted(files)

def main():
    parser=argparse.ArgumentParser()
    for name in ['dafny','solc','node','native-evidence','output']:parser.add_argument('--'+name,type=Path,required=True)
    a=parser.parse_args();entry=HERE/'EmptyConnection.dfy';native=a.native_evidence.resolve();nm=json.loads((native/'manifest.json').read_text())
    assert nm['status']=='passed' and nm['coverageComplete'] and nm['inputsUnchanged'] and nm['toolsUnchanged']
    closure=base.closure(entry);expected={str(p.relative_to(ROOT)) for p in closure}
    assert set(nm['entryIncludeClosures'][str(entry.relative_to(ROOT))])==expected
    assert all(m['proof']['passed'] and m['audit']['passed'] for m in nm['moduleProofs'])
    assert all(nm['sourceSha256'][str(p.relative_to(ROOT))]==sha(p) for p in closure)
    assert nm['nativeResults'] and all(r['TestResult.Outcome']=='Passed' for r in nm['nativeResults'])
    assert all(job['passed'] for job in nm['checks']) and all(sha(native/name)==h for name,h in nm['evidenceSha256'].items())
    dafny,solc,node=a.dafny.resolve(),a.solc.resolve(),a.node.resolve();z3=dafny.parent/'z3/bin/z3-4.12.1'
    tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':z3,'solc':solc,'node':node}
    versions={k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in tools.items() if k!='Dafny.dll'}
    assert versions['dafny']==json.loads((ROOT/'formal/abi/toolchain.json').read_text())['dafnyVersion'] and '4.12.1' in versions['z3'] and '0.8.36+commit.8a079791' in versions['solc']
    assert all(nm['executableSha256'][k]==sha(v) for k,v in tools.items() if k in nm['executableSha256'])
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False);snapshot=out/'source-snapshot';files=inputs(entry);hashes={str(p.relative_to(ROOT)):sha(p) for p in files}
    for p in files:
        dst=snapshot/p.relative_to(ROOT);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst)
    shutil.copytree(native,out/'retained-native')
    m={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),
       'scope':'Exact physical in-memory empty OR decoder PC19462 to physical InvalidOrConstraint REVERT, preserving world frame. Separate OR preparation PC7723 to19462 is also natively checked. Arbitrary symbolic admitted memory, stack and context words. No public admission or whole-entry completion claim; nonempty/nested OR branches remain open.',
       'publicEntries':[],'nativeEvidence':{'manifestSha256':sha(native/'manifest.json'),'nativeCheckCount':len(nm['nativeResults']),'source':'retained-native/manifest.json'},
       'sourceSha256':hashes,'versions':versions,'executableSha256':{k:sha(v) for k,v in tools.items()},'checks':[],
       'assumptions':['Reviewed EVM memory/frame/opcode semantics and pinned native proof tools are trust boundaries. Runtime compilation and receipts corroborate the universal native proof.',
                      'Explicit helper memory bounds and scanned continuations are admitted here; no claim of public ABI admission. Sufficient reached execution resources are assumed.']}
    def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    def record(name,cmd,timeout=600):
        job=common.run(cmd,out/(name+'.log'),timeout);job.update(name=name,passed=job['exitCode']==0);m['checks'].append(job);save();print(name,flush=True);return job
    save();record('runtime-identity',[sys.executable,'-B',snapshot/'formal/bytecode/dispatch/identity.py','--solc',solc,'--output',out/'identity','--contract','Assertions'],240)
    code=bytes.fromhex(json.loads((snapshot/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);dests=set();pc=0
    while pc<len(code):
        op=code[pc]
        if op==91:dests.add(pc)
        pc+=1+(op-95 if 96<=op<=127 else 0)
    guards=0
    for p in sorted(set(closure)|set(base.closure(HERE/'OrPrepare.generated.dfy'))):
        for r in re.finditer(r'code\[(\d+)\]\s*==\s*(0x[0-9a-fA-F]+|[0-9]+)',p.read_text()):
            assert code[int(r[1])]==int(r[2],0),(p,r[1]);guards+=1
    assert {7777,19462}<=dests
    m['runtimeBinding']={'runtimeSha256':hashlib.sha256(code).hexdigest(),'runtimeBytes':len(code),'constantGuardCount':guards,'certifiedContinuations':[7777,19462],'pushAwareDestinationCount':len(dests)};save()
    for stem,gen in [('EmptyDecoder','generate-empty.py'),('EmptyAbort','generate-abort.py'),('OrPrepare','generate-prepare.py')]:
        generated=out/('generated-'+stem);job=record('generation-'+stem,[sys.executable,'-B',snapshot/HERE.relative_to(ROOT)/gen,'--output',generated,'--dafny',dafny]);job['passed']=job['passed'] and all((HERE/(stem+suffix)).read_bytes()==(generated/(stem+suffix)).read_bytes() for suffix in ['.generated.dfy','.mapping.json']);save()
    script=HERE/'evm-discovery.mjs';job=record('concrete',[node,script,out/'evm-traces'],240);rows=json.loads((out/'evm-traces/results.json').read_text());job['passed']=job['passed'] and len(rows)==6 and all(r['passed'] for r in rows)
    fixture=json.loads((out/'evm-traces/empty.json').read_text());logs=[r for r in fixture['trace']['structLogs'] if r['depth']==1];start=next(i for i,r in enumerate(logs) if r['pc']==19462)
    maps=[json.loads((HERE/(stem+'.mapping.json')).read_text()) for stem in ['EmptyDecoder','EmptyAbort']];pcs=[r['pc'] for mapping in maps for r in mapping['states']]
    assert [r['pc'] for r in logs[start:]]==pcs and fixture['trace']['failed']
    m['corroboratedInstructionCount']=len(pcs);m['otherFixtures']='Five additional discovery policies are corroboration only and carry no native completion claim.';save()
    witness=snapshot/HERE.relative_to(ROOT)/'NativeSelector.dfy';symbol='AssertionsConstraintOrSelectorWitness';cmd=[dafny,'verify',witness,'--manual-lemma-induction','--cores','1','--verification-time-limit','30','--solver-path',z3,'--filter-symbol',symbol]
    job=record('witness-baseline',cmd+['--log-format','csv;LogFileName='+str(out/'witness-baseline.csv')],300);rows=list(csv.DictReader((out/'witness-baseline.csv').open()));job['passed']=job['passed'] and bool(rows) and all(r['TestResult.Outcome']=='Passed' for r in rows)
    audit=record('witness-audit',[dafny,'audit',witness]);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'witness-audit.log').read_text();save()
    mutant=out/'mutant-source';shutil.copytree(snapshot,mutant);candidate=mutant/witness.relative_to(snapshot);candidate.write_text(candidate.read_text().replace('code[7795] == 0x3b','code[7795] == 0x3a'))
    mutable=bytearray(code);assert mutable[7791:7796]==bytes.fromhex('633f9bbb3b');mutable[7795]=0x3a;binary=out/'invalid-or-selector.bin';binary.write_bytes(mutable)
    negative=record('mutant-native',[dafny,'verify',candidate,'--manual-lemma-induction','--cores','1','--verification-time-limit','30','--solver-path',z3,'--filter-symbol',symbol,'--log-format','csv;LogFileName='+str(out/'mutant-native.csv')],300)
    rows=list(csv.DictReader((out/'mutant-native.csv').open()));log=(out/'mutant-native.log').read_text();negative['passed']=negative['exitCode'] not in [0,None] and bool(rows) and any(r['TestResult.Outcome']=='Failed' for r in rows) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in rows) and bool(re.search(r'postcondition could not be proved|assertion might not hold',log)) and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error',log,re.I);negative['nativeResults']=rows
    job=record('mutant-concrete',[node,script,out/'mutant-traces',binary],240);receipts=json.loads((out/'mutant-traces/results.json').read_text());job['passed']=job['exitCode'] not in [0,None] and len(receipts)==6 and any(r['name']=='empty' and 'Independent flat OR receipt differs' in r['errors'] for r in receipts)
    m['mutation']={'name':'invalid-or-selector','runtimeSha256':sha(binary),'failedNativeCount':sum(r['TestResult.Outcome']=='Failed' for r in rows),'emptyReceiptKilled':job['passed']}
    ct=json.loads((out/'evm-traces/toolchain.json').read_text());m['concreteToolchain']=ct
    m['inputsUnchanged']=hashes=={str(p.relative_to(ROOT)):sha(p) for p in inputs(entry)};m['toolsUnchanged']=m['executableSha256']=={k:sha(v) for k,v in tools.items()}
    retained=out/'retained-native';m['retainedNativeUnchanged']=sha(retained/'manifest.json')==m['nativeEvidence']['manifestSha256'] and all(sha(retained/name)==h for name,h in nm['evidenceSha256'].items())
    m['concreteToolsUnchanged']=all(sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['hardhatEntry','edrEntry','nativeBinding']) and sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256']
    m['status']='passed' if all(m[k] for k in ['inputsUnchanged','toolsUnchanged','retainedNativeUnchanged','concreteToolsUnchanged']) and all(j['passed'] for j in m['checks']) else 'failed';m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p!=out/'manifest.json'};save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)
if __name__=='__main__':main()
