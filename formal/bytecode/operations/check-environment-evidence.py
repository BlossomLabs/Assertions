#!/usr/bin/env python3
"""Independently recheck retained Operations environment receipts and proof closure."""
import csv, hashlib, importlib.util, json, re, subprocess, sys, tempfile
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
OWNER = Path(__file__).resolve().parent
LEDGER = ROOT / 'docs/verification/operations-environment-bytecode.json'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok, message):
    if not ok: raise SystemExit(message)
def load(name, p):
    spec = importlib.util.spec_from_file_location(name, p)
    m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m); return m
def read(p): return json.loads(p.read_text())
def physical(t, expected, failed, mapping=None):
    trace=t['trace']; logs=trace['structLogs']; last=logs[-1]
    require(logs[0]['pc']==0 and all(s['depth']==1 for s in logs), 'Incomplete physical trace')
    require(trace['failed']==failed and trace['returnValue'].removeprefix('0x')==expected, 'Wrong actual receipt')
    require(last['op']==('REVERT' if failed else 'RETURN'), 'Wrong physical halt')
    off,size=int(last['stack'][-1],16),int(last['stack'][-2],16)
    memory=''.join(w.removeprefix('0x') for w in last['memory'])
    require((off,size)==((0,0) if failed else (128,32)) and memory[off*2:(off+size)*2]==expected, 'Wrong physical byte slice')
    if mapping is not None:
        require([s['pc'] for s in logs]==[s['pc'] for s in mapping['states']], 'Physical full PC path differs')
def main():
    ledger=read(LEDGER); out=(ROOT/ledger['baseline']).parent; manifest=out/'manifest.json'; m=read(manifest)
    v=load('operations_environment_verify', OWNER/'environment-retention/verify.py')
    require(sha(manifest)==ledger['baselineSha256'], 'Manifest drift')
    require(m['status']=='passed' and all(m[k] for k in ['inputsUnchanged','toolsUnchanged','concreteToolsUnchanged']) and all(j['passed'] for j in m['checks']), 'Incomplete retained evidence')
    require(m['publicEntries']==ledger['publicEntries'] and m['assumptions']==ledger['assumptions'], 'Scope drift')
    require(m['proofFiles']==[str(p.relative_to(ROOT)) for p in v.PROOFS], 'Native file inventory drift')
    require({str(p.relative_to(ROOT)):sha(p) for p in v.inputs()}==m['sourceSha256'], 'Current input inventory drift')
    for name,digest in m['sourceSha256'].items(): require(sha(out/'source-snapshot'/name)==digest, 'Snapshot drift '+name)
    actual={str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='manifest.json'}
    require(actual==m['evidenceSha256'], 'Complete evidence closure drift')
    closed=set()
    def visit(p):
        p=p.resolve(); require(p in v.PROOFS, 'Uninventoried native dependency')
        if p in closed:return
        closed.add(p)
        for inc in re.findall(r'^include "([^"]+)"',p.read_text(),re.M):visit(p.parent/inc)
    for p in v.PROOFS:visit(p)
    require(closed==set(v.PROOFS), 'Incomplete native graph')
    jobs={j['name']:j for j in m['checks']}; rows=[]; declarations=[]
    for p in v.PROOFS:
        mod=re.search(r'^module (\w+)',p.read_text(),re.M)[1]; job=jobs['proof-'+mod]; command=job['command']
        require(job['exitCode']==0 and '--filter-position' not in command and command[command.index('--filter-symbol')+1]==mod, 'Partial native filter')
        require(all(flag in command for flag in ['--verify-included-files','--manual-lemma-induction','--isolate-assertions']) and command[command.index('--verification-time-limit')+1]=='30', 'Native flag drift')
        fresh=dict(job); v.common.check_proof(fresh,out/('proof-'+mod+'.log'),out/(mod+'.csv'),v.v.inventory(p))
        require(fresh['passed'] and fresh['nativeResults']==job['nativeResults'] and fresh['declarations']==job['declarations'], 'Native inventory drift '+mod)
        rows+=fresh['nativeResults'];declarations+=fresh['declarations']
        require(jobs['audit-'+mod]['exitCode']==0 and 'auditor completed with 0 findings' in (out/('audit-'+mod+'.log')).read_text(), 'Audit findings '+mod)
    require(rows==m['nativeResults'] and declarations==m['declarationResults'] and len(rows)==ledger['nativeObligations'] and len(declarations)==ledger['nativeDeclarations'], 'Native aggregate drift')
    proved={d['name'] for d in declarations if d['status']=='passed'}
    require(all(n in proved for n in ledger['connections']), 'Unproved public raw connection')
    base=bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]); runtime_sha=hashlib.sha256(base).hexdigest()
    require(runtime_sha==ledger['runtimeSha256']==read(out/'identity/identity.json')[0]['runtimeSha256'], 'Runtime drift')
    receipts=read(out/'evm-traces/results.json');context=read(out/'evm-traces/context.json')
    require(len(receipts)==24 and {(r['name'],r['ordinal']) for r in receipts}=={(n,i) for n in v.NAMES for i in range(3)}, 'Successful receipt inventory drift')
    for r in receipts:
        t=read(out/'evm-traces'/r['trace']);mapping=read(OWNER/'environment'/(r['name']+'.mapping.json'))
        expected=format(int(context['worldValues'][r['name']]),'064x')
        require(r['passed'] and not t['candidate'] and t['runtimeSha256']==runtime_sha and t['expected']==expected and t['data']==r['data'] and t['data'][2:10]==mapping['selector'], 'Receipt context/selector drift')
        physical(t,expected,False,mapping)
        stores=[s for s in t['trace']['structLogs'] if s['op']=='MSTORE']
        require(len(stores)==2 and int(stores[-1]['stack'][-1],16)==128 and int(stores[-1]['stack'][-2],16)==int(expected,16), 'Wrong actual output word store')
    rejected=read(out/'rejection-traces/results.json')
    require(len(rejected)==8 and {(r['name'],r['ordinal']) for r in rejected}=={(n,i) for n in v.REJECTIONS for i in range(4)}, 'Rejection inventory drift')
    for r in rejected:
        require(r['passed'] and (int(r['value'],16)>0 if r['name']=='Nonzero' else int(r['value'],16)==0 and len(bytes.fromhex(r['data'][2:]))<4), 'Wrong raw rejection admission')
        physical(read(out/'rejection-traces'/r['trace']),'',True,read(OWNER/'environment/rejections'/(r['name']+'.mapping.json')))
    faults=read(out/'mutations/results.json'); candidates=read(out/'candidates/inventory.json')
    require(len(faults)==ledger['semanticBytecodeFaults']==8 and {f['entry'] for f in faults}==set(v.NAMES), 'Fault inventory drift')
    for f,c in zip(faults,candidates):
        require(all(f[k]==val for k,val in c.items()) and all(j['passed'] for j in f['checks']) and c['baselineFinalSymbol'] in proved, 'Fault baseline closure drift')
        candidate=(out/'candidates'/(c['name']+'.bin')).read_bytes()
        require(len(candidate)==len(base) and sha(out/'candidates'/(c['name']+'.bin'))==c['sha256'] and [(i,a,b) for i,(a,b) in enumerate(zip(base,candidate)) if a!=b]==[(c['pc'],c['oldOpcode'],c['newOpcode'])], 'Wrong one-byte semantic fault')
        mapping=read(OWNER/'environment'/(c['entry']+'.mapping.json'));require(any(s['pc']==c['pc'] and s['opcode']==c['oldOpcode'] for s in mapping['states']), 'Fault not reached on instruction boundary')
        native=f['checks'][2];text=(out/native['log']).read_text();nr=list(csv.DictReader((out/'mutations'/c['name']/'proof.csv').open()))
        require(native['exitCode'] not in [0,None] and any(r['TestResult.Outcome']=='Failed' for r in nr) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in nr) and 'postcondition could not be proved' in text and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',text,re.I), 'Nonsemantic native fault failure')
        source=(out/'mutations'/c['name']/(c['entry']+'.generated.dfy')).read_text().splitlines()
        require(source[f['semanticAssertion']['line']-1]==f['semanticAssertion']['text'] and 'next == Returned(Encode(Result(world),32))' in f['semanticAssertion']['text'], 'Semantic target drift')
        require(f['concreteFailures'], 'Missing contradictory physical receipt')
        for r in f['concreteFailures']:
            t=read(out/'mutations'/c['name']/'evm-traces'/r['trace'])
            require(t['candidate'] and t['runtimeSha256']==c['sha256'] and r['name']==c['entry'] and r['actual']!=r['expected'] and r['actual']==t['trace']['returnValue'].removeprefix('0x'), 'False concrete counterexample')
            physical(t,r['actual'],False,mapping)
    dafny=Path(jobs['proof-OperationsEnvironmentMachine']['command'][0]);solc=Path(jobs['runtime-identity']['command'][4])
    for k,p in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',dafny.parent/'z3/bin/z3-4.12.1'),('solc',solc)]:require(sha(p)==m['executableSha256'][k], 'Native tool drift')
    ct=m['concreteToolchain']
    for k in ['hardhatEntry','edrEntry','nativeBinding']:require(sha(Path(ct[k]))==ct[k+'Sha256'], 'EVM tool drift')
    require(sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'], 'Node/lockfile drift')
    with tempfile.TemporaryDirectory(prefix='operations-environment-check-') as tmp:
        dest=Path(tmp)
        for folder,names in [('environment',v.NAMES),('environment/rejections',v.REJECTIONS)]:
            generated=dest/folder
            subprocess.run([sys.executable,'-B',OWNER/folder/'generate.py','--output',generated],check=True,stdout=subprocess.DEVNULL)
            subprocess.run([sys.executable,'-B',OWNER/'environment/format-generated.py','--output',generated,'--include-root',OWNER/folder],check=True,stdout=subprocess.DEVNULL)
            for n in names:
                for suffix in ['.generated.dfy','.mapping.json']:require((generated/(n+suffix)).read_bytes()==(OWNER/folder/(n+suffix)).read_bytes(), 'Regeneration drift')
        subprocess.run([sys.executable,'-B',OWNER/'environment-retention/make-candidates.py','--output',dest/'candidates'],check=True,stdout=subprocess.DEVNULL)
        require((dest/'candidates/inventory.json').read_bytes()==(out/'candidates/inventory.json').read_bytes(), 'Candidate inventory drift')
        for c in candidates:require((dest/'candidates'/(c['name']+'.bin')).read_bytes()==(out/'candidates'/(c['name']+'.bin')).read_bytes(), 'Candidate generation drift')
        subprocess.run([sys.executable,'-B',OWNER/'identity.py','--solc',solc,'--output',dest/'identity'],check=True,stdout=subprocess.DEVNULL)
        require((dest/'identity/identity.json').read_bytes()==(out/'identity/identity.json').read_bytes(), 'Current exact compiler identity differs')
        subprocess.run([ct['nodeExecutable'],OWNER/'check-selectors.mjs',dest/'selectors'],check=True,cwd=ROOT,stdout=subprocess.DEVNULL)
        for script,subdir in [('evm-traces.mjs','success'),('rejection-traces.mjs','reject')]:subprocess.run([ct['nodeExecutable'],OWNER/'environment-retention'/script,dest/subdir],check=True,cwd=ROOT,stdout=subprocess.DEVNULL)
        require(len(read(dest/'success/results.json'))==24 and len(read(dest/'reject/results.json'))==8, 'Fresh EVM fixture inventory differs')
    print('PASS: 8 Operations raw environment entries; 21422 native obligations, 726 declarations, 12 zero audits, 24 success + 8 rejection receipts, 8 semantic bytecode faults. Remaining Operations entries stay open.')
if __name__=='__main__':main()
