#!/usr/bin/env python3
"""Bind retained full native decoder proof to reproduced runtime and an opcode mutant."""
import argparse,csv,datetime,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def load(name,path):
    spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
base=load('raw_binding',ROOT/'formal/bytecode/assertions-resolution/raw/verify.py');common,identity,sha=base.common,base.identity,base.sha
def inputs():
    files=set(base.closure(HERE/'Decoder.generated.dfy'))|{HERE/n for n in ['CopyCase.dfy','Decoder.mapping.json','generate-decoder.py','evm-decoder.mjs','verify-decoder.py']}|{ROOT/p for p in ['formal/constraints/verify.py','formal/abi/toolchain.json','formal/bytecode/dispatch/identity.py','formal/bytecode/dispatch/inventory.json','formal/bytecode/format-generated.py','formal/bytecode/assertions-resolution/raw/verify.py','hardhat.config.ts','package.json','pnpm-lock.yaml']}
    artifact=ROOT/'artifacts/contracts/Assertions.sol/Assertions.json';a=json.loads(artifact.read_text());build=ROOT/'artifacts/build-info'/(a['buildInfoId']+'.json');files|={artifact,build}
    for key in json.loads(build.read_text())['input']['sources']:
        files.add(identity.source_path(key))
        if key.startswith('npm/'):files.add(ROOT/'node_modules'/re.fullmatch(r'npm/(@[^/]+/[^/@]+)@([^/]+)/(.+)',key)[1]/'package.json')
    return sorted(files)
def main():
    p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--node',type=Path,required=True);p.add_argument('--native-evidence',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False);native=a.native_evidence.resolve();nm=json.loads((native/'manifest.json').read_text());assert nm['status']=='passed' and nm['inputsUnchanged'] and nm['toolsUnchanged']
    dafny,solc,node=a.dafny.resolve(),a.solc.resolve(),a.node.resolve();z3=dafny.parent/'z3/bin/z3-4.12.1';tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':z3,'solc':solc,'node':node}
    assert all(nm['executableSha256'][k]==sha(v) for k,v in tools.items() if k in nm['executableSha256'])
    proof_files=base.closure(HERE/'Decoder.generated.dfy');assert set(nm['includeClosure'])=={str(f.relative_to(ROOT)) for f in proof_files}
    assert all(nm['sourceSha256'][str(f.relative_to(ROOT))]==sha(f) for f in proof_files)
    assert nm['nativeResults'] and all(r['TestResult.Outcome']=='Passed' for r in nm['nativeResults'])
    assert all(j['passed'] for j in nm['checks'])
    files=inputs();hashes={str(f.relative_to(ROOT)):sha(f) for f in files};snapshot=out/'source-snapshot'
    for f in files:
        dest=snapshot/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dest)
    retained=out/'retained-native';shutil.copytree(native,retained)
    source=snapshot/HERE.relative_to(ROOT)
    m={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Complete exact internal Constraint decoder success PC19377 to its physical caller continuation, arbitrary admitted enum0..8 and reference bytes/length. No validator-loop or whole public-entry completion claim. Native full closure is reused from the supplied immutable evidence, with exact source/tool and retained-evidence hashes checked.','internalEntryPc':19377,'publicEntries':[],'nativeEvidence':{'manifestSha256':sha(native/'manifest.json'),'nativeCheckCount':len(nm['nativeResults']),'source':'retained-native/manifest.json'},'sourceSha256':hashes,'executableSha256':{k:sha(v) for k,v in tools.items()},'checks':[],'assumptions':['Reviewed EVM opcode/memory interpretation, pinned Dafny/Boogie/Z3 and native EVM runtime are trusted boundaries. Runtime reproduction and 72 fixtures corroborate, and do not replace, the arbitrary-input native proof.','Caller admission states complete ABI spans, legal enum, aligned memory/free pointer, explicit 64-bit allocation bounds and fitting stack. Actual supplied jump destinations must be PUSH-aware runtime instruction boundaries; malformed admission classes remain open.','The independent heap model fixes kind, reference pointer/header, bytes, allocation pointer and zero footer. The CALDATACOPY-to-MCOPY actual opcode mutant retains this specification and must fail native proof and independent EVM heap comparisons. Resources sufficient to execute the reached path are assumed; no gas theorem.']}
    def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    def record(name,command,timeout=600):
        job=common.run(command,out/(name+'.log'),timeout);job.update(name=name,passed=job['exitCode']==0);m['checks'].append(job);save();print(name,'passed' if job['passed'] else 'failed',flush=True);return job
    save()
    record('runtime-identity',[sys.executable,'-B',snapshot/'formal/bytecode/dispatch/identity.py','--solc',solc,'--output',out/'identity','--contract','Assertions'],240)
    generation=record('generation',[sys.executable,'-B',source/'generate-decoder.py','--output',out/'generated','--dafny',dafny])
    generation['passed']=generation['passed'] and all((HERE/n).read_bytes()==(out/'generated'/n).read_bytes() for n in ['Decoder.generated.dfy','Decoder.mapping.json']);save()
    concrete=record('concrete',[node,HERE/'evm-decoder.mjs',out/'evm-traces'],180)
    traces=json.loads((out/'evm-traces/results.json').read_text());concrete['passed']=concrete['passed'] and len(traces)==72 and len({x['name'] for x in traces})==72 and all(x['passed'] for x in traces);save()
    witness=record('copy-witness-baseline',[dafny,'verify',source/'CopyCase.dfy','--manual-lemma-induction','--cores','1','--verification-time-limit','30','--solver-path',z3,'--filter-symbol','AssertionsConstraintCopyCase','--log-format','csv;LogFileName='+str(out/'copy-witness-baseline.csv')],180)
    wr=list(csv.DictReader((out/'copy-witness-baseline.csv').open()));witness['passed']=witness['passed'] and bool(wr) and all(r['TestResult.Outcome']=='Passed' for r in wr);save()
    audit=record('copy-witness-audit',[dafny,'audit',source/'CopyCase.dfy']);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'copy-witness-audit.log').read_text();save()
    mutant_root=out/'mutant-source';shutil.copytree(snapshot,mutant_root);mutant_source=mutant_root/HERE.relative_to(ROOT)
    runtime=bytearray.fromhex(json.loads((snapshot/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);assert runtime[18492]==0x37;runtime[18492]=0x5e;candidate=out/'calldatacopy-to-mcopy.bin';candidate.write_bytes(runtime)
    record('mutant-generation',[sys.executable,'-B',mutant_source/'generate-decoder.py','--output',mutant_source,'--dafny',dafny,'--runtime',candidate])
    copycase=mutant_source/'CopyCase.dfy';copycase.write_text(copycase.read_text().replace('0x37','0x5e').replace(',1,false',',1,true'))
    proof=record('mutant-native',[dafny,'verify',copycase,'--manual-lemma-induction','--cores','1','--verification-time-limit','30','--solver-path',z3,'--filter-symbol','AssertionsConstraintCopyCase','--log-format','csv;LogFileName='+str(out/'mutant-native.csv')],180)
    rows=list(csv.DictReader((out/'mutant-native.csv').open()));log=(out/'mutant-native.log').read_text();proof['passed']=proof['exitCode']!=0 and any(r['TestResult.Outcome']=='Failed' for r in rows) and bool(re.search(r'[1-9][0-9]* errors?',log)) and 'timed out' not in log.lower() and 'resolution/type errors' not in log.lower();proof['nativeResults']=rows;save()
    mutation=record('mutant-concrete',[node,HERE/'evm-decoder.mjs',out/'mutant-traces',candidate],180)
    mt=json.loads((out/'mutant-traces/results.json').read_text());mutation['passed']=mutation['exitCode']!=0 and len(mt)==72 and any('Independent complete decoder heap differs' in x['errors'] for x in mt);save()
    m['concreteToolchain']=json.loads((out/'evm-traces/toolchain.json').read_text());ct=m['concreteToolchain']
    m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()};m['toolsUnchanged']=m['executableSha256']=={k:sha(v) for k,v in tools.items()}
    m['retainedNativeUnchanged']=sha(retained/'manifest.json')==m['nativeEvidence']['manifestSha256'] and all(sha(retained/name)==digest for name,digest in nm['evidenceSha256'].items())
    m['concreteToolsUnchanged']=all(sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['hardhatEntry','edrEntry','nativeBinding']) and sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256']
    m['status']='passed' if m['inputsUnchanged'] and m['toolsUnchanged'] and m['retainedNativeUnchanged'] and m['concreteToolsUnchanged'] and all(j['passed'] for j in m['checks']) else 'failed';m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)
if __name__=='__main__':main()
