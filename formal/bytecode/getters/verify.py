#!/usr/bin/env python3
"""Retain complete LEN/PAYLOAD bytecode certificates, physical traces and faults."""
import argparse,csv,datetime,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
if not __debug__:raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
common=module('common',ROOT/'formal/constraints/verify.py')
identity=module('identity',ROOT/'formal/bytecode/dispatch/identity.py')
sha=common.sha
NAMES=['LEN','PAYLOAD']
def inputs():
    files={f for f in HERE.iterdir() if f.is_file()}|{ROOT/p for p in ['formal/constraints/verify.py','formal/abi/toolchain.json','formal/bytecode/dispatch/identity.py','formal/bytecode/dispatch/inventory.json','hardhat.config.ts','pnpm-lock.yaml','package.json']}
    for name in ['Assertions']:
        ap=ROOT/'artifacts/contracts'/f'{name}.sol'/f'{name}.json';a=json.loads(ap.read_text());bp=ROOT/'artifacts/build-info'/(a['buildInfoId']+'.json');files|={ap,bp}
        for key in json.loads(bp.read_text())['input']['sources']:
            files.add(identity.source_path(key))
            if key.startswith('npm/'):files.add(ROOT/'node_modules'/re.fullmatch(r'npm/(@[^/]+/[^/@]+)@([^/]+)/(.+)',key)[1]/'package.json')
    return sorted(files)
def inventory(path):
    s=path.read_text();mod=re.search(r'^module (\w+)',s,re.M)[1]
    return [{'name':mod+'.'+m[2],'kind':m[1],'file':str(path.relative_to(ROOT))} for m in re.finditer(r'^  (?:(?:ghost|opaque) )*(lemma|method|function|predicate|type)(?: \{:[^}]+\})* (\w+)(?:\(| =)',s,re.M)]
def main():
    p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    dafny,solc=a.dafny.resolve(),a.solc.resolve();z3=dafny.parent/'z3/bin/z3-4.12.1';out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    assert {f.name for f in HERE.glob('*.dfy')}=={'Machine.dfy',*[n+'.generated.dfy' for n in NAMES]},'Uninventoried proof source'
    for f in HERE.glob('*.dfy'):assert set(re.findall(r'^include "([^"]+)"',f.read_text(),re.M)) <= {'Machine.dfy'},'Uninventoried dependency'
    versions={k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in [('dafny',dafny),('z3',z3),('solc',solc)]};assert versions['dafny']==json.loads((ROOT/'formal/abi/toolchain.json').read_text())['dafnyVersion'] and '4.12.1' in versions['z3'] and '0.8.36+commit.8a079791' in versions['solc']
    tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':z3,'solc':solc};files=inputs();hashes={str(f.relative_to(ROOT)):sha(f) for f in files};snap=out/'source-snapshot'
    for f in files:
        dest=snap/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dest)
    source=snap/HERE.relative_to(ROOT)
    m={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Exact current Assertions LEN/PAYLOAD successful runtime semantics from PC zero through final physical byte RETURN under admitted symbolic environment and explicit sufficient reached-resource/EVM/tool premises. Two entries only; no whole-contract verification claim.','publicEntries':['Assertions.LEN()','Assertions.PAYLOAD()'],'sourceSha256':hashes,'versions':versions,'executableSha256':{k:sha(v) for k,v in tools.items()},'checks':[],'assumptions':[
      'Trusted boundaries: exact canonical artifact/input/runtime-byte extraction, reviewed full-runtime instruction-boundary scanning, reviewed reached EVM opcode interpretation, faithful fresh zero call memory and truthful CALLVALUE/CALLDATASIZE/CALLDATALOAD observations. Adequate reached execution resources remain explicit; no gas cost or unconditional resource availability theorem.',
      'Admitted getter environments have zero call value, calldata length at least four and the assigned selector in the first loaded word. All lower 224 bits and all other calldata bytes/lengths are arbitrary. Rejection of other frames is the separate dispatcher scope.',
      'Generated Matches certificates constrain every executed instruction/immediate/jump destination byte of the full canonical runtime. Every other byte remains arbitrary in the native theorem. The complete admitted path is verified instruction by instruction; its decreasing certificate index proves termination without a dropped path or execution cut-off.',
      'Physical byte memory, fixed-width big-endian stores/loads, disjoint frames, actual stack arithmetic including the signed helper guards and exact 32-byte RETURN are modeled and proved. Reached memory stays within 160 bytes and stack within the derived per-entry maximum (five LEN / eleven PAYLOAD words). No compiler, logical allocator or outer serializer correctness premise substitutes for these instructions.',
      'Dafny/Boogie/Z3, solc current-input runtime reproduction, Node/Hardhat/EDR and reviewed scripts are trusted. Full native/declaration/audit/input/tool/artifact closure, twelve real EVM complete-return/memory fixtures and two semantic bytecode faults are required. No source-to-whole-bytecode, gas, deployment, performance or complexity claim.'
    ]}
    def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    def record(name,command,timeout=3600):
        j=common.run(command,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
    save();record('runtime-identity',[sys.executable,'-B',snap/'formal/bytecode/dispatch/identity.py','--solc',solc,'--output',out/'identity','--contract','Assertions'],240)
    gate=record('generation',[sys.executable,'-B',source/'generate.py','--output',out/'generated'],180)
    gate['passed']=gate['passed'] and all((source/(n+s)).read_bytes()==(out/'generated'/(n+s)).read_bytes() for n in NAMES for s in ['.generated.dfy','.mapping.json']);save()
    if not all(c['passed'] for c in m['checks']):raise SystemExit('Identity/generation gate failed')
    proofjobs=[]
    for n in ['Machine',*NAMES]:
        filename='Machine.dfy' if n=='Machine' else n+'.generated.dfy';prefix='BytecodeGetter'+n;csvpath=out/('proof-'+n+'.csv')
        j=record('proof-'+n,common.proof_command(dafny,source/filename,csvpath)+['--filter-symbol',prefix,'--progress','Symbol']);common.check_proof(j,out/('proof-'+n+'.log'),csvpath,inventory(HERE/filename));proofjobs.append(j);save()
        audit=record('audit-'+n,[dafny,'audit',source/filename],180);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/('audit-'+n+'.log')).read_text();save()
    record('format',[dafny,'format','--check',source/'Machine.dfy',*[source/(n+'.generated.dfy') for n in NAMES]],180)
    concrete=record('concrete',[shutil.which('node'),HERE/'evm-traces.mjs',out/'evm-traces'],180)
    traces=json.loads((out/'evm-traces/results.json').read_text()) if (out/'evm-traces/results.json').is_file() else []
    concrete['passed']=concrete['passed'] and len(traces)==12 and {(t['name'],t['ordinal']) for t in traces}=={(n,i) for n in NAMES for i in range(6)} and all(t['passed'] for t in traces)
    if (out/'evm-traces/toolchain.json').is_file():m['concreteToolchain']=json.loads((out/'evm-traces/toolchain.json').read_text())
    save();record('candidate-generation',[sys.executable,'-B',source/'make-candidates.py','--output',out/'candidates'],180);faults=[]
    for fault,n,symbol in [('len-shift-one-bit','LEN','Advance62'),('payload-increment-two','PAYLOAD','Advance100')]:
        folder=out/'mutations'/fault;folder.mkdir(parents=True);candidate=out/'candidates'/(fault+'.bin');shutil.copy2(source/'Machine.dfy',folder/'Machine.dfy')
        translated=record(fault+'-translation',[sys.executable,'-B',source/'generate.py','--runtime',candidate,'--output',folder],180)
        file=folder/(n+'.generated.dfy');lines=file.read_text().splitlines();begin=next(i for i,l in enumerate(lines) if 'lemma '+symbol+'(' in l);anchor=next(i for i in range(begin,len(lines)) if 'next == Returned(Encode(Constant(),32))' in lines[i]);name='BytecodeGetter'+n+'.'+symbol
        baseline=next(j for j in proofjobs if j['name']=='proof-'+n);assert next(d for d in baseline['declarations'] if d['name']==name)['status']=='passed'
        native=record(fault+'-native',common.proof_command(dafny,file,folder/'proof.csv')+['--filter-symbol',name,'--filter-position',str(file)+':'+str(anchor+1),'--progress','Symbol'],180)
        text=(out/(fault+'-native.log')).read_text();rows=list(csv.DictReader((folder/'proof.csv').open())) if (folder/'proof.csv').is_file() else []
        native['passed']=native['exitCode'] not in [0,None] and bool(rows) and any(r['TestResult.Outcome']=='Failed' for r in rows) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in rows) and 'postcondition could not be proved' in text and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error',text,re.I)
        evm=record(fault+'-concrete',[shutil.which('node'),HERE/'evm-traces.mjs',folder/'evm-traces',candidate],180);text=(out/(fault+'-concrete.log')).read_text();failures=[]
        for f in (folder/'evm-traces').glob(n+'-*.json'):
            t=json.loads(f.read_text());actual=t['trace']['returnValue'].removeprefix('0x')
            if not t['trace']['failed'] and actual!=t['expected']:failures.append({'trace':str(f.relative_to(out)),'expected':t['expected'],'actual':actual})
        evm['passed']=evm['exitCode'] not in [0,None] and 'Wrong EVM getter return '+n+'/' in text and bool(failures)
        faults.append({'name':fault,'publicEntry':n,'candidateSha256':sha(candidate),'baselineCoveredSymbol':name,'semanticAssertion':{'line':anchor+1,'text':lines[anchor]},'checks':[translated,native,evm],'concreteFailures':failures});save()
    (out/'mutations/results.json').write_text(json.dumps(faults,indent=2)+'\n')
    m['nativeResults']=[r for j in proofjobs for r in j['nativeResults']];m['declarationResults']=[d for j in proofjobs for d in j['declarations']]
    m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()};m['toolsUnchanged']=m['executableSha256']=={k:sha(v) for k,v in tools.items()};ct=m.get('concreteToolchain',{})
    m['concreteToolsUnchanged']=bool(ct) and all(sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['hardhatEntry','edrEntry','nativeBinding']) and sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256']
    m['status']='passed' if m['inputsUnchanged'] and m['toolsUnchanged'] and m['concreteToolsUnchanged'] and all(c['passed'] for c in m['checks']) else 'failed';m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)
if __name__=='__main__':main()
