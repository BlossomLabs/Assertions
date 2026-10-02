#!/usr/bin/env python3
"""Retain exact complete internal leaf helper evidence, never public-entry coverage."""
import argparse,csv,datetime,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
if not __debug__:raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
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
        text=file.read_text();mod=re.search(r'^module (\w+)',text,re.M)[1]
        for m in re.finditer(r'^  (?:(?:ghost|opaque) )*(lemma|method|function|predicate|type)(?: \{:[^}]+\})* (\w+)(?:\(| =)',text,re.M):
            records.append({'name':mod+'.'+m[2],'kind':m[1],'file':str(file.relative_to(ROOT))})
    return records
def inputs():
    files=set(closure(HERE/'Connection.generated.dfy'))|{p for p in HERE.iterdir() if p.is_file()}|{ROOT/p for p in ['formal/constraints/verify.py','formal/abi/toolchain.json','formal/bytecode/dispatch/identity.py','formal/bytecode/dispatch/inventory.json','formal/bytecode/format-generated.py','hardhat.config.ts','package.json','pnpm-lock.yaml']}
    ap=ROOT/'artifacts/contracts/Assertions.sol/Assertions.json';a=json.loads(ap.read_text());bp=ROOT/'artifacts/build-info'/(a['buildInfoId']+'.json');files|={ap,bp}
    for key in json.loads(bp.read_text())['input']['sources']:
        files.add(identity.source_path(key))
        if key.startswith('npm/'):files.add(ROOT/'node_modules'/re.fullmatch(r'npm/(@[^/]+/[^/@]+)@([^/]+)/(.+)',key)[1]/'package.json')
    return sorted(files)
def main():
    p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--node',type=Path,required=True);p.add_argument('--cores',type=int,default=4);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    assert 1<=a.cores<=16
    dafny,solc,node=a.dafny.resolve(),a.solc.resolve(),a.node.resolve();z3=dafny.parent/'z3/bin/z3-4.12.1';out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    versions={k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in [('dafny',dafny),('z3',z3),('solc',solc),('node',node)]}
    assert versions['dafny']==json.loads((ROOT/'formal/abi/toolchain.json').read_text())['dafnyVersion'] and '4.12.1' in versions['z3'] and '0.8.36+commit.8a079791' in versions['solc']
    tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':z3,'solc':solc,'node':node};files=inputs();hashes={str(f.relative_to(ROOT)):sha(f) for f in files};snap=out/'source-snapshot'
    for f in files:
        dest=snap/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dest)
    source=snap/HERE.relative_to(ROOT);root=source/'Connection.generated.dfy';proof_files=closure(HERE/'Connection.generated.dfy');decls=declarations(proof_files)
    m={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Complete exact Assertions internal _checkConstraint non-OR leaf helper from PC10646 through actual caller return or exact physical InvalidConstraintData/InvalidConstraintRange REVERT. All8 wire kinds, arbitrary256bit operands,22 exhaustive symbolic partitions. Caller representation premises explicit; no complete public entry or whole-contract claim.','publicEntries':[],'internalEntryPc':10646,'sourceSha256':hashes,'versions':versions,'executableSha256':{k:sha(v) for k,v in tools.items()},'checks':[],'assumptions':[
      'Pinned Dafny/Boogie/Z3, nativeEVM/Node/Hardhat/EDR, runtime-byte extraction, canonical current-input compiler reproduction and reviewed opcode/memory models are trusted boundaries. Compilation and tests are not the semantic proof.',
      'The caller must discharge actual byte-memory representation, kind0..8 excludingOR6, header/ref/data word projections,32byte aligned allocated memory, true freepointer, stackprefix bounds and actual continuation7993 or8035. Caller ABI decoding, OR structure, outer constraints, resolver and judge are not assumed proven by this package.',
      'When instantiating the generic reached-opcode machine on the canonical runtime, every supplied destination must be a real instruction boundary from full-runtime PUSH-aware scanning. All executed opcode/immediate/target bytes are constrained; adequate reached execution resources and truthful call inputs are explicit. No gas theorem.',
      'The independent leaf specification fixes semantic predicates and exact error bytes before candidate generation. Concrete samples choose finite paths but are absent from theorem premises. Twenty-two partitions cover every nonOR case; natively verified decreasing certificate index gives finite complete physical traces without bounded symbolic cutoffs.',
      'The entire proof include closure is verified and audited in this snapshot.28 real EVM fixtures corroborate actual helper stacks, memory, complete instruction paths and exact return/error bytes. Three semantic bytecode faults must fail both native expected semantics and concrete EVM receipts.'
    ]}
    def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    def record(name,command,timeout=7200):
        j=common.run(command,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();print(name,'passed' if j['passed'] else 'failed',flush=True);return j
    def command(file,csvpath):
        return [dafny,'verify',file,'--verify-included-files','--manual-lemma-induction','--cores',str(a.cores),'--verification-time-limit','30','--solver-path',z3,'--log-format','csv;LogFileName='+str(csvpath),'--progress','Symbol']
    save();record('runtime-identity',[sys.executable,'-B',snap/'formal/bytecode/dispatch/identity.py','--solc',solc,'--output',out/'identity','--contract','Assertions'],240)
    generation=record('generation',[sys.executable,'-B',source/'generate.py','--output',out/'generated','--dafny',dafny],600)
    generated=list(HERE.glob('*.generated.dfy'))+list(HERE.glob('*.mapping.json'))+[HERE/'inventory.json']
    generation['passed']=generation['passed'] and all(f.read_bytes()==(out/'generated'/f.name).read_bytes() for f in generated);save()
    if not all(c['passed'] for c in m['checks']):raise SystemExit('Identity/generation failed')
    proof=record('proof-full-closure',command(root,out/'proof-full-closure.csv'),14400)
    common.check_proof(proof,out/'proof-full-closure.log',out/'proof-full-closure.csv',decls);save()
    audit=record('audit-full-closure',[dafny,'audit',root],600);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'audit-full-closure.log').read_text();save()
    record('format-full-closure',[dafny,'format','--check',*[snap/f.relative_to(ROOT) for f in proof_files]],600)
    concrete=record('concrete',[node,HERE/'evm-traces.mjs',out/'evm-traces'],180)
    traces=json.loads((out/'evm-traces/results.json').read_text()) if (out/'evm-traces/results.json').is_file() else []
    concrete['passed']=concrete['passed'] and len(traces)==28 and len({t['name'] for t in traces})==28 and all(t['passed'] for t in traces)
    if (out/'evm-traces/toolchain.json').is_file():m['concreteToolchain']=json.loads((out/'evm-traces/toolchain.json').read_text())
    save();record('candidate-generation',[sys.executable,'-B',source/'make-candidates.py','--output',out/'candidates'],180);faults=[]
    for candidate in json.loads((out/'candidates/inventory.json').read_text()):
        name=candidate['name'];folder=out/'mutations'/name;folder.mkdir(parents=True);runtime=out/'candidates'/(name+'.bin');
        for f in HERE.glob('*.dfy'):
            if not f.name.endswith('.generated.dfy'):shutil.copy2(source/f.name,folder/f.name)
        # Restore the complete dependency tree for identical relative includes.
        target=folder/'source-snapshot';shutil.copytree(snap,target);target_source=target/HERE.relative_to(ROOT)
        translated=record(name+'-translation',[sys.executable,'-B',source/'generate.py','--runtime',runtime,'--output',target_source,'--dafny',dafny],600)
        file=target_source/(candidate['module']+'.generated.dfy');csvpath=folder/'proof.csv';prefix='AssertionsConstraint'+candidate['module']
        baseline=[d for d in proof['declarations'] if d['name'].startswith(prefix+'.')]
        if not baseline or not all(d['status']=='passed' for d in baseline if d['kind'] in {'lemma','method'}):
            skipped={'name':name+'-baseline-certification','passed':False,'reason':'Candidate gate cannot be certified because its matching baseline module did not pass all native obligations.'}
            m['checks'].append(skipped);faults.append(dict(candidate,checks=[translated,skipped]));save();continue
        native=record(name+'-native',command(file,csvpath)+['--filter-symbol',prefix],1800)
        text=(out/(name+'-native.log')).read_text();rows=list(csv.DictReader(csvpath.open())) if csvpath.is_file() else []
        native['passed']=native['exitCode'] not in [0,None] and bool(rows) and any(r['TestResult.Outcome']=='Failed' for r in rows) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in rows) and bool(re.search(r'postcondition could not be proved|assertion might not hold',text)) and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error',text,re.I)
        evm=record(name+'-concrete',[node,HERE/'evm-traces.mjs',folder/'evm-traces',runtime],180)
        results=json.loads((folder/'evm-traces/results.json').read_text()) if (folder/'evm-traces/results.json').is_file() else []
        semantic=[r for r in results if 'Exact physical public receipt differs' in r.get('errors',[])]
        evm['passed']=evm['exitCode'] not in [0,None] and bool(semantic)
        faults.append(dict(candidate,checks=[translated,native,evm],failedNativeRows=[r for r in rows if r['TestResult.Outcome']=='Failed'],semanticConcreteFailures=semantic));save()
    (out/'mutations/results.json').write_text(json.dumps(faults,indent=2)+'\n')
    m['nativeResults']=proof['nativeResults'];m['declarationResults']=proof['declarations'];m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()};m['toolsUnchanged']=m['executableSha256']=={k:sha(v) for k,v in tools.items()};ct=m.get('concreteToolchain',{})
    m['concreteToolsUnchanged']=bool(ct) and all(sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['hardhatEntry','edrEntry','nativeBinding']) and sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256']
    m['status']='passed' if m['inputsUnchanged'] and m['toolsUnchanged'] and m['concreteToolsUnchanged'] and all(c['passed'] for c in m['checks']) else 'failed';m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)
if __name__=='__main__':main()
