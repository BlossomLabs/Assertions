#!/usr/bin/env python3
"""Retain arbitrary-length exact internal RAW/zero-constraints resolver proof."""
import argparse,datetime,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
common=module('common',ROOT/'formal/constraints/verify.py');identity=module('identity',ROOT/'formal/bytecode/dispatch/identity.py');sha=common.sha
def closure(file):
    seen=set()
    def visit(path):
        path=path.resolve()
        if path in seen:return
        seen.add(path)
        for include in re.findall(r'^include "([^"]+)"',path.read_text(),re.M):visit(path.parent/include)
    visit(file);return sorted(seen)
def declarations(files):
    records=[]
    for file in files:
        mod=re.search(r'^module (\w+)',file.read_text(),re.M)[1]
        for m in re.finditer(r'^  (?:(?:ghost|opaque) )*(lemma|method|function|predicate|type)(?: \{:[^}]+\})* (\w+)(?:\(| =)',file.read_text(),re.M):
            records.append({'name':mod+'.'+m[2],'kind':m[1],'file':str(file.relative_to(ROOT))})
    return records
def inputs():
    files=set(closure(HERE/'Connection.dfy'))|{p for p in HERE.iterdir() if p.is_file()}|{ROOT/p for p in ['formal/constraints/verify.py','formal/abi/toolchain.json','formal/bytecode/dispatch/identity.py','formal/bytecode/dispatch/inventory.json','formal/bytecode/format-generated.py','hardhat.config.ts','package.json','pnpm-lock.yaml']}
    artifact=ROOT/'artifacts/contracts/Assertions.sol/Assertions.json';a=json.loads(artifact.read_text());build=ROOT/'artifacts/build-info'/(a['buildInfoId']+'.json');files|={artifact,build}
    for key in json.loads(build.read_text())['input']['sources']:
        files.add(identity.source_path(key))
        if key.startswith('npm/'):files.add(ROOT/'node_modules'/re.fullmatch(r'npm/(@[^/]+/[^/@]+)@([^/]+)/(.+)',key)[1]/'package.json')
    return sorted(files)
def main():
    p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--node',type=Path,required=True);p.add_argument('--cores',type=int,default=1);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    assert 1<=a.cores<=16
    dafny,solc,node=a.dafny.resolve(),a.solc.resolve(),a.node.resolve();z3=dafny.parent/'z3/bin/z3-4.12.1';out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    versions={k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in [('dafny',dafny),('z3',z3),('solc',solc),('node',node)]}
    assert versions['dafny']==json.loads((ROOT/'formal/abi/toolchain.json').read_text())['dafnyVersion'] and '4.12.1' in versions['z3'] and '0.8.36+commit.8a079791' in versions['solc']
    tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':z3,'solc':solc,'node':node};files=inputs();hashes={str(f.relative_to(ROOT)):sha(f) for f in files};snapshot=out/'source-snapshot'
    for f in files:
        destination=snapshot/f.relative_to(ROOT);destination.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,destination)
    source=snapshot/HERE.relative_to(ROOT);root=source/'Connection.dfy';proof_files=closure(HERE/'Connection.dfy');decls=declarations(proof_files)
    m={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Complete exact Assertions internal _resolve RAW_BYTES/zero-constraints path from PC3393 through actual continuation, arbitrary calldata bytes and admitted arbitrary length; includes actual decoder bounds, allocation, copy, zero footer, empty validator and return. No complete public entry, other fetcher or nonempty constraints claim.','publicEntries':[],'internalEntryPc':3393,'sourceSha256':hashes,'versions':versions,'executableSha256':{k:sha(v) for k,v in tools.items()},'checks':[],'assumptions':[
      'Pinned Dafny/Boogie/Z3, runtime-byte extraction, canonical current-input compilation, native EVM/Node/Hardhat/EDR and reviewed opcode/memory semantics remain trusted boundaries. Compiler output and fixtures do not replace the native semantic proof.',
      'Caller premises state an actual RAW fetcher word, dynamic calldata offsets and complete payload/empty-constraints spans; aligned allocated memory and true free pointer; length and allocation within the explicit 64-bit implementation bounds; at most980 caller stack words. Other malformed input classes are open.',
      'Generic destination sets must contain certified helper destinations, and every supplied target must be a real instruction boundary from PUSH-aware full-runtime scanning. The actual return continuation is in the canonical full-runtime scanned destination inventory.',
      'The independent memory specification constructs exactly the returned bytes header, calldata payload, allocation pointer and zero footer. Representative samples select the fixed266-instruction path but never constrain arbitrary theorem bytes or length. A decreasing certificate index yields a complete physical trace.',
      'The full native include closure is verified and audited, with retained source/tool/compiler hashes. Eight actual EVM fixtures corroborate helper stack, allocation memory, complete physical instruction sequence and exact public receipt. Resource availability is explicit; no gas theorem.'
    ]}
    def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    def record(name,command,timeout=7200):
        job=common.run(command,out/(name+'.log'),timeout);job.update(name=name,passed=job['exitCode']==0);m['checks'].append(job);save();print(name,'passed' if job['passed'] else 'failed',flush=True);return job
    save();record('runtime-identity',[sys.executable,'-B',snapshot/'formal/bytecode/dispatch/identity.py','--solc',solc,'--output',out/'identity','--contract','Assertions'],240)
    generation=record('generation',[sys.executable,'-B',source/'generate.py','--output',out/'generated','--dafny',dafny],600)
    generation['passed']=generation['passed'] and all((HERE/name).read_bytes()==(out/'generated'/name).read_bytes() for name in ['Raw.generated.dfy','Raw.mapping.json']);save()
    if not all(c['passed'] for c in m['checks']):raise SystemExit('Identity/generation failed')
    proof=record('proof-full-closure',[dafny,'verify',root,'--verify-included-files','--manual-lemma-induction','--cores',str(a.cores),'--verification-time-limit','30','--solver-path',z3,'--log-format','csv;LogFileName='+str(out/'proof-full-closure.csv'),'--progress','Symbol'],14400)
    common.check_proof(proof,out/'proof-full-closure.log',out/'proof-full-closure.csv',decls);save()
    audit=record('audit-full-closure',[dafny,'audit',root],600);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'audit-full-closure.log').read_text();save()
    record('format-full-closure',[dafny,'format','--check',*[snapshot/f.relative_to(ROOT) for f in proof_files]],600)
    concrete=record('concrete',[node,HERE/'evm-traces.mjs',out/'evm-traces'],180)
    traces=json.loads((out/'evm-traces/results.json').read_text()) if (out/'evm-traces/results.json').is_file() else []
    concrete['passed']=concrete['passed'] and len(traces)==8 and len({t['name'] for t in traces})==8 and all(t['passed'] for t in traces)
    if (out/'evm-traces/toolchain.json').is_file():m['concreteToolchain']=json.loads((out/'evm-traces/toolchain.json').read_text())
    m['nativeResults']=proof['nativeResults'];m['declarationResults']=proof['declarations'];m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()};m['toolsUnchanged']=m['executableSha256']=={k:sha(v) for k,v in tools.items()};ct=m.get('concreteToolchain',{})
    m['concreteToolsUnchanged']=bool(ct) and all(sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['hardhatEntry','edrEntry','nativeBinding']) and sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256']
    m['status']='passed' if m['inputsUnchanged'] and m['toolsUnchanged'] and m['concreteToolsUnchanged'] and all(c['passed'] for c in m['checks']) else 'failed';m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)
if __name__=='__main__':main()
