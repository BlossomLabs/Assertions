#!/usr/bin/env python3
"""Validate current complete admitted getter bytecode evidence and its exact scope."""
import argparse,csv,hashlib,importlib.util,json,re,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,message):
    if not ok:raise SystemExit(message)
def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
p=argparse.ArgumentParser();p.add_argument('--manifest',type=Path);args=p.parse_args()
if args.manifest:
    path=args.manifest.resolve()
    ledger={'nativeObligations':6090,'concreteFixtures':12,'semanticBytecodeFaults':2,
      'sharedTheorems':['DecodeBound','RoundTrip','WordPower','LoadProjection','StoreLoad','StoreFrame'],
      'publicEntries':{f'Assertions.{name}()':{
        'connection':f'BytecodeGetter{name}.Run','signedConstant':f'BytecodeGetter{name}.SignedConstant',
        'instructionStates':states,'maximumStackWords':stack,'selector':selector,
        'returnHex':format(value,'064x')}
        for name,states,stack,selector,value in [('LEN',63,5,'694464da',1<<255),('PAYLOAD',101,11,'268e878d',(1<<255)+1)]}}
else:
    ledger=json.loads((ROOT/'docs/verification/constant-getters-bytecode.json').read_text());path=ROOT/ledger['baseline'];require(sha(path)==ledger['baselineSha256'],'Manifest drift')
m=json.loads(path.read_text());out=path.parent
require(m['status']=='passed' and all(m[k] for k in ['inputsUnchanged','toolsUnchanged','concreteToolsUnchanged']) and all(c['passed'] for c in m['checks']),'Incomplete retained baseline')
for name,digest in m['sourceSha256'].items():require(sha(ROOT/name)==digest,'Current input drift '+name)
for name,digest in m['evidenceSha256'].items():require(sha(out/name)==digest,'Evidence drift '+name)
verify=module('getter_verify',ROOT/'formal/bytecode/getters/verify.py');allrows=[];alldecls=[]
for name in ['Machine','LEN','PAYLOAD']:
    filename='Machine.dfy' if name=='Machine' else name+'.generated.dfy';job=next(c for c in m['checks'] if c['name']=='proof-'+name)
    require(all(flag in job['command'] for flag in ['--verify-included-files','--manual-lemma-induction','--isolate-assertions']) and '--filter-position' not in job['command'],'Incomplete assertion coverage')
    require(job['command'][job['command'].index('--filter-symbol')+1]=='BytecodeGetter'+name,'Wrong proof module filter')
    fresh=dict(job);verify.common.check_proof(fresh,out/('proof-'+name+'.log'),out/('proof-'+name+'.csv'),verify.inventory(ROOT/'formal/bytecode/getters'/filename))
    require(fresh['passed'] and fresh['nativeResults']==job['nativeResults'] and fresh['declarations']==job['declarations'],'Native declaration/CSV drift '+name)
    require('auditor completed with 0 findings' in (out/('audit-'+name+'.log')).read_text(),'Audit findings '+name)
    allrows+=job['nativeResults'];alldecls+=job['declarations']
require(allrows==m['nativeResults'] and len(allrows)==ledger['nativeObligations']==6090 and alldecls==m['declarationResults'],'Aggregate native inventory drift')
proved={d['name'] for d in alldecls if d['status']=='passed'}
for name in ledger['sharedTheorems']:require('BytecodeGetterMachine.'+name in proved,'Unproved memory/word theorem '+name)
traces=json.loads((out/'evm-traces/results.json').read_text());require(len(traces)==ledger['concreteFixtures']==12 and {(t['name'],t['ordinal']) for t in traces}=={(n,i) for n in ['LEN','PAYLOAD'] for i in range(6)},'Fixture inventory drift')
for entry,claim in ledger['publicEntries'].items():
    name=entry.split('.')[1].split('(')[0];require(claim['connection'] in proved and claim['signedConstant'] in proved,'Unproved public connection '+entry)
    mapping=json.loads((ROOT/'formal/bytecode/getters'/(name+'.mapping.json')).read_text());require(len(mapping['states'])==claim['instructionStates'] and max(len(s['stack']) for s in mapping['states'])==mapping['maximumStackWords']==claim['maximumStackWords'],'Path/stack inventory drift')
    require(mapping['selector']==claim['selector'],'Selector drift')
    for result in [t for t in traces if t['name']==name]:
        t=json.loads((out/'evm-traces'/result['trace']).read_text());logs=t['trace']['structLogs'];expected=claim['returnHex']
        require(not t['trace']['failed'] and t['trace']['returnValue'].removeprefix('0x')==t['expected']==expected,'Wrong actual getter return')
        require([r['pc'] for r in logs]==[s['pc'] for s in mapping['states']] and all(r['depth']==1 for r in logs),'Incomplete PC trace')
        require(max(len(r['stack']) for r in logs)==claim['maximumStackWords'],'Concrete stack bound differs')
        ret=logs[-1];require(ret['op']=='RETURN' and int(ret['stack'][-1],16)==128 and int(ret['stack'][-2],16)==32 and ''.join(w.removeprefix('0x') for w in ret['memory'])[256:320]==expected,'Physical RETURN frame drift')
        stores=[r for r in logs if r['op']=='MSTORE'];require(len(stores)==2 and int(stores[0]['stack'][-1],16)==64 and int(stores[0]['stack'][-2],16)==128 and int(stores[1]['stack'][-1],16)==128 and int(stores[1]['stack'][-2],16)==int(expected,16),'Physical MSTORE drift')
faults=json.loads((out/'mutations/results.json').read_text());require({f['name'] for f in faults}=={'len-shift-one-bit','payload-increment-two'} and len(faults)==ledger['semanticBytecodeFaults']==2,'Fault inventory drift')
base=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:])
for fault in faults:
    candidate=out/'candidates'/(fault['name']+'.bin');require(sha(candidate)==fault['candidateSha256'] and fault['baselineCoveredSymbol'] in proved and all(j['passed'] for j in fault['checks']),'Fault closure drift')
    expected=(0x1c6,255,254) if fault['name']=='len-shift-one-bit' else (0x5fa,1,2);mut=candidate.read_bytes();require(len(mut)==len(base) and [(i,a,b) for i,(a,b) in enumerate(zip(base,mut)) if a!=b]==[expected],'Wrong binary fault')
    native=fault['checks'][1];text=(out/native['log']).read_text();rows=list(csv.DictReader((out/'mutations'/fault['name']/'proof.csv').open()))
    require(native['exitCode'] not in [0,None] and any(r['TestResult.Outcome']=='Failed' for r in rows) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in rows) and 'postcondition could not be proved' in text and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error',text,re.I),'Non-semantic fault result')
    require(fault['concreteFailures'],'Missing real EVM counterexample')
    for failure in fault['concreteFailures']:
        t=json.loads((out/failure['trace']).read_text());require(not t['trace']['failed'] and t['expected']==failure['expected'] and t['trace']['returnValue'].removeprefix('0x')==failure['actual']!=failure['expected'],'False concrete counterexample')
dafny=Path(next(c for c in m['checks'] if c['name']=='proof-Machine')['command'][0]);solc=Path(next(c for c in m['checks'] if c['name']=='runtime-identity')['command'][4])
for key,p in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',dafny.parent/'z3/bin/z3-4.12.1'),('solc',solc)]:require(sha(p)==m['executableSha256'][key],'Proof tool drift '+key)
ct=m['concreteToolchain']
for key in ['hardhatEntry','edrEntry','nativeBinding']:require(sha(Path(ct[key]))==ct[key+'Sha256'],'Concrete tool drift '+key)
require(sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'],'Node/lockfile drift')
with tempfile.TemporaryDirectory(prefix='getter-bytecode-check-') as folder:
    dest=Path(folder);subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/getters/generate.py','--output',dest/'generated'],check=True)
    for name in ['LEN','PAYLOAD']:
        for suffix in ['.generated.dfy','.mapping.json']:require((dest/'generated'/(name+suffix)).read_bytes()==(ROOT/'formal/bytecode/getters'/(name+suffix)).read_bytes(),'Current generation drift')
    retained_identity=json.loads((out/'identity/identity.json').read_text())
    subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/dispatch/identity.py','--solc',solc,'--output',dest/'identity',*[v for item in retained_identity for v in ['--contract',item['contract']]]],check=True)
    require((dest/'identity/identity.json').read_bytes()==(out/'identity/identity.json').read_bytes(),'Current exact runtime identity differs')
print('PASS: admitted LEN/PAYLOAD exact bytecode, 6090 native obligations, zero audits, 12 physical return/memory fixtures and two semantic bytecode faults; whole-contract bytecode remains open')
