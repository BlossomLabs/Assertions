#!/usr/bin/env python3
"""Retain exact canonical dispatcher control proofs and concrete/mutation checks."""
import argparse,csv,datetime,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
if not __debug__:raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('common',ROOT/'formal/constraints/verify.py');common=importlib.util.module_from_spec(spec);spec.loader.exec_module(common)
spec=importlib.util.spec_from_file_location('identity',HERE/'identity.py');identity=importlib.util.module_from_spec(spec);spec.loader.exec_module(identity)
sha,run=common.sha,common.run
NAMES=['Assertions','Expressions','Collections']
def inputs():
    files={f for f in HERE.iterdir() if f.is_file()}|{ROOT/'formal/constraints/verify.py',ROOT/'formal/abi/toolchain.json',ROOT/'hardhat.config.ts',ROOT/'pnpm-lock.yaml',ROOT/'package.json'}
    for name in NAMES:
        ap=ROOT/'artifacts/contracts'/f'{name}.sol'/f'{name}.json';a=json.loads(ap.read_text());bp=ROOT/'artifacts/build-info'/(a['buildInfoId']+'.json');files|={ap,bp}
        for key in json.loads(bp.read_text())['input']['sources']:
            f=identity.source_path(key);files.add(f)
            if key.startswith('npm/'):
                base=ROOT/'node_modules'/re.fullmatch(r'npm/(@[^/]+/[^/@]+)@([^/]+)/(.+)',key)[1];files.add(base/'package.json')
    return sorted(files)
def inventory(paths):
    result=[]
    for path in paths:
        text=path.read_text();module=re.search(r'^module (\w+)',text,re.M)[1]
        for m in re.finditer(r'^  (?:(?:ghost|opaque) )*(lemma|method|function|predicate|type)(?: \{:[^}]+\})* (\w+)(?:\(| =)',text,re.M):result.append({'name':module+'.'+m[2],'kind':m[1],'file':str(path.relative_to(ROOT))})
    return result

def main():
    global NAMES
    p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--contract',choices=['Assertions']);a=p.parse_args()
    if a.contract:NAMES=[a.contract]
    dafny,solc=a.dafny.resolve(),a.solc.resolve();solver=dafny.parent/'z3/bin/z3-4.12.1';out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    files=inputs();hashes={str(f.relative_to(ROOT)):sha(f) for f in files};snap=out/'source-snapshot'
    for f in files:
        dest=snap/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dest)
    source=snap/HERE.relative_to(ROOT)
    selector_count=sum(len(json.loads((HERE/'inventory.json').read_text())[n]['methodIdentifiers']) for n in NAMES)
    trace_count=selector_count*3+len(NAMES)*7
    m={'status':'incomplete','contracts':NAMES,'scope':f'Exact current canonical runtime dispatcher control for {selector_count} selectors of {", ".join(NAMES)}, arbitrary 256-bit environment words and all prefix paths under explicit EVM/resource/projection premises. Stops before wrapper decoding/function bodies; no whole-contract source/bytecode equivalence claim.','sourceSha256':hashes,'startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'executableSha256':{k:sha(v) for k,v in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',solver),('solc',solc)]},'checks':[]}
    m['versions']={k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in [('dafny',dafny),('z3',solver),('solc',solc)]};assert m['versions']['dafny']==json.loads((ROOT/'formal/abi/toolchain.json').read_text())['dafnyVersion']
    assert '4.12.1' in m['versions']['z3'] and '0.8.36+commit.8a079791' in m['versions']['solc'],'Unpinned proof/compiler tools'
    assert {f.name for f in HERE.glob('*.dfy')} <= {'Machine.dfy',*[n+'.generated.dfy' for n in ['Assertions','Expressions','Collections']]},'Uninventoried proof source'
    assert all((HERE/(n+'.generated.dfy')).is_file() for n in NAMES),'Missing selected proof source'
    for file in HERE.glob('*.dfy'):
        assert set(re.findall(r'^include "([^"]+)"',file.read_text(),re.M)) <= {'Machine.dfy'},'Uninventoried proof dependency'
    m['assumptions']=[
      'Trusted boundaries: exact artifact/input/byte extraction, reviewed instruction-boundary scanning, reviewed reached EVM opcode control/stack interpretation, truthful CALLVALUE/CALLDATASIZE/CALLDATALOAD observations, successful physical MSTORE(64,128) projection and adequate reached execution resources. No gas cost or physical resource availability theorem.',
      'All baseline expected selector/entry addresses are frozen independently of candidate generation. They are the declared equality-branch destinations, not a proof that the subsequent wrapper/decoder/body implements the named source entry. Public source proof results cannot fill that bytecode gap.',
      'Every modeled continuing step increases PC within the exact prefix; a well-founded PC rank proves termination without dropping paths at a loop or fuel bound. Arbitrary 256-bit loaded words/calldata sizes/call values overapproximate real inputs, including infeasible huge sizes; no successful body/allocation is assumed or proved.',
      'The initial physical memory write is recorded as an initialization flag in the control projection. This package does not model full byte memory, ABI argument decoding, body/callback behavior, returned success bytes, physical allocation/serialization or metadata reachability after entry.',
      f'Dafny/Boogie/Z3, solc ABI extraction and reproduction, Node/Hardhat/EDR tooling and reviewed evidence scripts are trusted. All native declarations, zero audit, input/tool/runtime identity, {trace_count} real EVM prefix traces and two semantic bytecode mutations must pass; no deployment, gas, complexity, performance or whole-contract verification claim.'
    ]
    def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    def record(name,command,timeout=3600):
        j=run(command,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
    save()
    record('runtime-identity',[sys.executable,'-B',source/'identity.py','--solc',solc,'--output',out/'identity',*[v for n in NAMES for v in ['--contract',n]]],240)
    for name in NAMES:
        gate=record('source-gate-'+name,[sys.executable,'-B',source/'generate.py','--solc',solc,'--contract',name,'--output',out/'generated'],240)
        gate['passed']=gate['passed'] and all((out/'generated'/(name+suffix)).read_bytes()==(source/(name+suffix)).read_bytes() for suffix in ['.generated.dfy','.mapping.json']);save()
    if not all(c['passed'] for c in m['checks']):raise SystemExit('Runtime identity/generation gate failed')
    proofjobs=[]
    for name,prefix in [('Machine','BytecodeDispatchMachine')]+[(n,'BytecodeDispatch'+n) for n in NAMES]:
        file=source/('Machine.dfy' if name=='Machine' else name+'.generated.dfy');local=HERE/file.name;csvpath=out/('proof-'+name+'.csv')
        proof=record('proof-'+name,common.proof_command(dafny,file,csvpath)+['--filter-symbol',prefix,'--progress','Symbol'],3600)
        common.check_proof(proof,out/('proof-'+name+'.log'),csvpath,inventory([local]));proofjobs.append(proof);save()
        audit=record('audit-'+name,[dafny,'audit',file],180);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/('audit-'+name+'.log')).read_text();save()
    record('format',[dafny,'format','--check',source/'Machine.dfy',*[source/(n+'.generated.dfy') for n in NAMES]],180)
    # The in-process EDR installation is the existing local dependency runtime.
    # Its live inputs must match the frozen snapshot and remain unchanged at completion.
    concrete=record('concrete',[shutil.which('node'),HERE/'evm-traces.mjs',out/'evm-traces',*([a.contract] if a.contract else [])],180)
    traces=json.loads((out/'evm-traces/results.json').read_text()) if (out/'evm-traces/results.json').is_file() else []
    frozen=json.loads((source/'inventory.json').read_text());expected={(n,k+suffix) for n in NAMES for k in frozen[n]['methodIdentifiers'] for suffix in ['','-tail','-nonzero-value']}|{(n,'short-'+str(i)) for n in NAMES for i in range(4)}|{(n,'unknown-'+k) for n in NAMES for k in ['00000000','ffffffff','12345678']}
    concrete.update(passed=concrete['passed'] and len(traces)==trace_count and {(t['contract'],t['name']) for t in traces}==expected and all(t['passed'] for t in traces),expectedTraces=trace_count)
    if (out/'evm-traces/toolchain.json').is_file():m['concreteToolchain']=json.loads((out/'evm-traces/toolchain.json').read_text())
    save()
    record('candidate-generation',[sys.executable,'-B',source/'make-candidates.py','--output',out/'candidates'],180)
    faults=[];assertions=next(j for j in proofjobs if j['name']=='proof-Assertions');baseline={d['name']:d for d in assertions['declarations']}
    for fault,symbol in [('getter-entry-redirect','Advance107'),('short-frame-admission-bypass','Advance8')]:
        folder=out/'mutations'/fault;folder.mkdir(parents=True);candidate=out/'candidates'/(fault+'.bin');shutil.copy2(source/'Machine.dfy',folder/'Machine.dfy')
        generated=record(fault+'-translation',[sys.executable,'-B',source/'generate.py','--solc',solc,'--contract','Assertions','--runtime',candidate,'--output',folder],240)
        sourcefile=folder/'Assertions.generated.dfy';lines=sourcefile.read_text().splitlines();begin=next(i for i,line in enumerate(lines) if 'lemma '+symbol+'(' in line);anchor=next(i for i in range(begin,len(lines)) if '!next.Running? ==> next != Bad && Result(next) == Expected(value,size,word)' in lines[i]);position=str(sourcefile)+':'+str(anchor+1)
        name='BytecodeDispatchAssertions.'+symbol;assert baseline[name]['status']=='passed'
        native=record(fault+'-native',common.proof_command(dafny,sourcefile,folder/'proof.csv')+['--filter-symbol',name,'--filter-position',position,'--progress','Symbol'],180)
        text=(out/(fault+'-native.log')).read_text();rows=list(csv.DictReader((folder/'proof.csv').open())) if (folder/'proof.csv').is_file() else []
        native['passed']=native['exitCode'] not in [0,None] and bool(rows) and any(r['TestResult.Outcome']=='Failed' for r in rows) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in rows) and 'postcondition could not be proved' in text and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error',text,re.I)
        evm=record(fault+'-concrete',[shutil.which('node'),HERE/'evm-traces.mjs',folder/'evm-traces','Assertions',candidate],180)
        evmtext=(out/(fault+'-concrete.log')).read_text();evm['passed']=evm['exitCode'] not in [0,None] and 'Wrong EVM entry' in evmtext
        failures=[]
        for f in (folder/'evm-traces').glob('Assertions-*.json'):
            t=json.loads(f.read_text());es=set(json.loads((source/'inventory.json').read_text())['Assertions']['selectorToDeclaredEntryPc'].values());actual=next((r['pc'] for r in t['prefix'] if r['pc'] in es),-1)
            if actual!=t['case']['expected']:failures.append({'trace':str(f.relative_to(out)),'expected':t['case']['expected'],'actual':actual,'case':t['case']['name']})
        evm['passed']=evm['passed'] and bool(failures)
        faults.append({'name':fault,'candidateSha256':sha(candidate),'baselineCoveredSymbol':name,'semanticAssertion':{'line':anchor+1,'text':lines[anchor]},'checks':[generated,native,evm],'concreteFailures':failures});save()
    (out/'mutations/results.json').write_text(json.dumps(faults,indent=2)+'\n')
    m['nativeResults']=[r for j in proofjobs for r in j['nativeResults']];m['declarationResults']=[d for j in proofjobs for d in j['declarations']]
    m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()}
    tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':solver,'solc':solc};m['toolsUnchanged']=m['executableSha256']=={k:sha(v) for k,v in tools.items()}
    ct=m.get('concreteToolchain',{});m['concreteToolsUnchanged']=bool(ct) and all(sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['nodeExecutable','hardhatEntry','edrEntry','nativeBinding'] if k!='nodeExecutable') and bool(ct) and sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256']
    m['status']='passed' if m['inputsUnchanged'] and m['toolsUnchanged'] and m['concreteToolsUnchanged'] and all(c['passed'] for c in m['checks']) else 'failed';m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'}
    save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)
if __name__=='__main__':main()
