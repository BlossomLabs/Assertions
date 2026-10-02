#!/usr/bin/env python3
"""Independent complete exact integer-power retained evidence checker."""
import argparse, csv, hashlib, importlib.util, json, re, shutil, subprocess, sys, tempfile
from pathlib import Path
if not __debug__: raise RuntimeError('Run without Python -O')
OWNER = Path(__file__).resolve().parent
ROOT = OWNER.parents[2]
def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module); return module
def read(path): return json.loads(path.read_text())
def require(value, message):
    if not value: raise RuntimeError(message)
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
PUBLIC = ['Operations.exp(uint256,uint256)', 'Operations.exp(int256,uint256)']
CONFIGS = [dict(name='unsigned-exp-to-mul', folder='power-mutation-preparation', pc=21115, old=10, new=2, symbol='OperationsPowerSemanticCheckpoint.IntendedResult', ordinal=10), dict(name='signed-mul-to-add', folder='power-signed-mutation-preparation', pc=20148, old=2, new=1, symbol='OperationsPowerSignedMutationWitness.IntendedResult', ordinal=51)]
def check_frontier(config,trace,generated):
    steps=trace['trace']['structLogs']; at=next(i for i,s in enumerate(steps) if s['pc']==config['pc'])
    before,after=steps[at:at+2]
    pre=([0xf5f565f8,1329,3,31,0,3085,31,3,0,3085,31,3,31,3] if config['name']=='unsigned-exp-to-mul' else [0x185af0ad,1329,3,31,1,3275,3,1,1,3])
    intended=617673396283947 if config['name']=='unsigned-exp-to-mul' else 3
    changed=93 if config['name']=='unsigned-exp-to-mul' else 4
    memory=b'\0'*64+(128).to_bytes(32,'big')
    require(before['pc']==config['pc'] and after['pc']==config['pc']+1 and [int(x,16) for x in before['stack']]==pre and [int(x,16) for x in after['stack']]==pre[:-2]+[changed] and all(bytes.fromhex(''.join(w.removeprefix('0x') for w in step['memory']))==memory for step in [before,after]), 'Native and physical instruction-frontier witnesses disagree')
    compact=re.sub(r'\s+','',generated)
    if config['name']=='unsigned-exp-to-mul':
        require('M.Running(21115,'+str(pre).replace(' ','')+',M.Store([],64,128))' in compact and 'M.Running(21116,'+str(pre[:-2]+[intended]).replace(' ','')+',M.Store([],64,128))' in compact, 'Native unsigned frontier differs from physical witness')
    else:
        require('functionPrefix():seq<M.Word>{[0x185af0ad,1329,3,31,1,3275,3,1]}' in compact and 'M.Running(20148,Prefix()+[1,3],M.Store([],64,128))' in compact and 'M.Running(20149,Prefix()+[3],M.Store([],64,128))' in compact, 'Native signed frontier differs from physical witness')
def main():
    parser = argparse.ArgumentParser(); parser.add_argument('--manifest', type=Path); parser.add_argument('--ledger', type=Path); args = parser.parse_args()
    ledger = read(args.ledger) if args.ledger else None
    if args.manifest is None:
        if ledger is None: ledger = read(ROOT/'docs/verification/operations-power-bytecode.json')
        args.manifest = ROOT/ledger['baseline']
    out = args.manifest.resolve().parent; manifest = read(out/'manifest.json'); snapshot = out/'source-snapshot'
    v = load('power_retainer', OWNER/'power-retention/verify.py'); common = v.common
    require(manifest['status']=='passed' and manifest['publicEntries']==PUBLIC, 'Incomplete exact public evidence')
    require(manifest['nativeWholeModuleWatchdogSeconds']==7200 and manifest['nativeObligationTimeLimitSeconds']==30, 'Native limit drift')
    require(all(manifest[k] for k in ['inputsUnchanged','toolsUnchanged','concreteToolsUnchanged']) and all(j['passed'] for j in manifest['checks']), 'Required gate failed')
    if ledger:
        require(ledger['baselineSha256']==sha(out/'manifest.json') and ledger['publicEntries']==PUBLIC and ledger['assumptions']==manifest['assumptions'], 'Ledger scope/provenance drift')
    current = {str(f.relative_to(ROOT)):sha(f) for f in v.inputs()}
    require(current==manifest['sourceSha256'] and all(sha(snapshot/p)==h for p,h in current.items()), 'Current input or frozen source drift')
    require(manifest['evidenceSha256']=={str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='manifest.json'}, 'Whole evidence closure drift')
    checks = {j['name']:j for j in manifest['checks']}
    require(len(checks)==len(manifest['checks']), 'Duplicate gate names')
    dafny = Path(checks['format-before']['command'][0]); solc = Path(checks['runtime-identity']['command'][checks['runtime-identity']['command'].index('--solc')+1])
    tools = {'dafny':dafny, 'Dafny.dll':dafny.parent/'Dafny.dll', 'z3':dafny.parent/'z3/bin/z3-4.12.1', 'solc':solc}
    require(manifest['executableSha256']=={k:sha(p) for k,p in tools.items()}, 'Native executable drift')
    versions = {k:subprocess.check_output([str(tools[k]),'--version'],text=True).strip() for k in ['dafny','z3','solc']}
    require(manifest['versions']==versions and versions['dafny']==read(ROOT/'formal/abi/toolchain.json')['dafnyVersion'] and '4.12.1' in versions['z3'] and '0.8.36+commit.8a079791' in versions['solc'], 'Pinned version drift')
    require(len(v.PROOFS)==55 and manifest['proofFiles']==[str(f.relative_to(ROOT)) for f in v.PROOFS], 'Complete proof inventory drift')
    closed = set()
    def visit(file):
        file = file.resolve(); require(file in v.PROOFS, 'Uninventoried included owner')
        if file in closed: return
        closed.add(file)
        for name in re.findall(r'^include "([^"]+)"',file.read_text(),re.M): visit(file.parent/name)
    for file in v.PROOFS: visit(file)
    require(closed==set(v.PROOFS), 'Incomplete native dependency closure')
    rows=[]; declarations=[]
    for file in v.PROOFS:
        symbol=re.search(r'^module (\w+)',file.read_text(),re.M)[1]; frozen=snapshot/file.relative_to(ROOT); csvpath=out/(symbol+'.csv'); job=checks['proof-'+symbol]
        expected=[str(x) for x in common.proof_command(dafny,frozen,csvpath)]+['--filter-symbol',symbol,'--filter-position',str(frozen),'--progress','Symbol']
        require(job['command']==expected and job['exitCode']==0, 'Native command/source/scope drift')
        fresh=dict(job); common.check_proof(fresh,out/('proof-'+symbol+'.log'),csvpath,v.inventory(file))
        require(fresh['passed'] and fresh['nativeResults']==job['nativeResults'] and fresh['declarations']==job['declarations'], 'Native CSV/declaration mismatch')
        rows+=fresh['nativeResults']; declarations+=fresh['declarations']; audit=checks['audit-'+symbol]
        require(audit['command']==[str(dafny),'audit',str(frozen)] and audit['exitCode']==0 and 'auditor completed with 0 findings' in (out/('audit-'+symbol+'.log')).read_text(), 'Native audit gap')
    require(rows==manifest['nativeResults'] and declarations==manifest['declarationResults'], 'Aggregate native evidence drift')
    proved={d['name'] for d in declarations if d['status']=='passed'}; connections=['OperationsPowerFull.RunUnsigned','OperationsPowerFull.RunSigned']
    require(all(name in proved for name in connections), 'Missing full raw public connection')
    if ledger:
        require(ledger['connections']==connections and ledger['nativeObligations']==len(rows) and ledger['nativeDeclarations']==len(declarations), 'Ledger native scope/count drift')
    code=bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]); digest=hashlib.sha256(code).hexdigest(); identity=read(out/'identity/identity.json')[0]
    require(identity['runtimeSha256']==digest and identity['methodIdentifiers']['exp(uint256,uint256)']=='f5f565f8' and identity['methodIdentifiers']['exp(int256,uint256)']=='185af0ad', 'Current compiler/runtime/selector drift')
    if ledger: require(ledger['runtimeSha256']==digest, 'Ledger runtime drift')
    baseline=read(out/'evm-traces/results.json'); require(len(baseline)==67 and all(r['passed'] for r in baseline) and {r['ordinal'] for r in baseline}==set(range(67)), 'Physical baseline gap')
    ct=manifest['concreteToolchain']; require(sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and all(sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['hardhatEntry','edrEntry','nativeBinding']) and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'], 'Physical tool dependency drift')
    faults=read(out/'mutations/results.json'); require(len(faults)==2 and faults==manifest['semanticFaults'], 'Matching mutation inventory drift')
    require(read(out/'candidates/inventory.json')==CONFIGS, 'Actual mutation configuration drift')
    for fault,config in zip(faults,CONFIGS):
        require(all(fault[k]==value for k,value in config.items()) and fault['passed'] and fault['baselineDeclaration']==config['symbol'] and config['symbol'] in proved, 'Fault is not baseline-covered')
        original=next(d for d in declarations if d['name']==config['symbol']); require(fault['baselineObligations']==original['batches'], 'Mutation baseline inventory drift')
        name=config['name']; candidate=out/'candidates'/(name+'.bin'); mutant=candidate.read_bytes(); folder=out/'mutations'/name
        require(len(mutant)==len(code) and [i for i,(a,b) in enumerate(zip(code,mutant)) if a!=b]==[config['pc']] and code[config['pc']]==config['old'] and mutant[config['pc']]==config['new'] and sha(candidate)==fault['candidateSha256'], 'Not the intended single-byte opcode fault')
        file=folder/'source-snapshot'/OWNER.relative_to(ROOT)/config['folder']/'Witness.generated.dfy'; native=checks[name+'-native']
        expected=[str(x) for x in common.proof_command(dafny,file,folder/'proof.csv')]+['--filter-symbol',config['symbol'],'--filter-position',str(file),'--progress','Symbol']
        require(native['command']==expected and native['exitCode'] not in [0,None], 'Wrong native fault scope')
        failure_rows=list(csv.DictReader((folder/'proof.csv').open())); log=(out/(name+'-native.log')).read_text()
        require(failure_rows==fault['nativeResults'] and any(r['TestResult.Outcome']=='Failed' for r in failure_rows) and all(r['TestResult.Outcome'] in ['Passed','Failed'] for r in failure_rows) and 'a postcondition could not be proved' in log and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',log,re.I), 'Mutation did not contradict the ordinary semantic postcondition')
        mutable={str((OWNER/config['folder']/n).relative_to(ROOT)) for n in ['Witness.generated.dfy','witness.mapping.json']}
        require(all(p in mutable or sha(folder/'source-snapshot'/p)==h for p,h in current.items()), 'Fault changed unrelated trusted input')
        physical=read(folder/'evm-traces/results.json'); witness=next(r for r in physical if r['ordinal']==config['ordinal'])
        require(len(physical)==fault['physicalReceipts']==67 and not witness['passed'] and witness['actual']!=witness['expected'] and sum(not r['passed'] for r in physical)==fault['physicalIntendedOutcomeContradictions'], 'Missing matching complete physical contradiction')
        check_frontier(config,read(folder/'evm-traces'/witness['trace']),(snapshot/OWNER.relative_to(ROOT)/config['folder']/'Witness.generated.dfy').read_text())
    subprocess.run([sys.executable,'-B',OWNER/'power-retention/check-physical.py',out/'evm-traces'],check=True,cwd=ROOT)
    for fault in faults:
        subprocess.run([sys.executable,'-B',OWNER/fault['folder']/'check-physical.py',out/'mutations'/fault['name']/'evm-traces','--runtime',out/'candidates'/(fault['name']+'.bin')],check=True,cwd=ROOT)
    with tempfile.TemporaryDirectory(prefix='operations-power-independent-') as directory:
        dest=Path(directory)
        def record(name,command,timeout=180):
            job=common.run(command,dest/(name+'.log'),timeout); job.update(name=name,passed=job['exitCode']==0); return job
        require(v.regenerate(OWNER,dest,record), 'Fresh owner/control generation drift')
        subprocess.run([sys.executable,'-B',OWNER/'identity.py','--solc',solc,'--output',dest/'identity'],check=True,cwd=ROOT,stdout=subprocess.DEVNULL)
        require(read(dest/'identity/identity.json')==read(out/'identity/identity.json'), 'Fresh exact compiler/runtime drift')
        subprocess.run([ct['nodeExecutable'],OWNER/'power-retention/evm-traces.mjs',dest/'baseline'],check=True,cwd=ROOT,stdout=subprocess.DEVNULL)
        subprocess.run([sys.executable,'-B',OWNER/'power-retention/check-physical.py',dest/'baseline'],check=True,cwd=ROOT)
        for fault in faults:
            name=fault['name']; candidate=out/'candidates'/(name+'.bin'); clone=dest/(name+'-source'); shutil.copytree(snapshot,clone); owner=clone/OWNER.relative_to(ROOT)/fault['folder']
            subprocess.run([sys.executable,'-B',owner/'generate.py','--runtime',candidate,'--output',owner],check=True,cwd=ROOT,stdout=subprocess.DEVNULL)
            subprocess.run([sys.executable,'-B',owner/'format-generated.py','--output',owner,'--include-root',owner],check=True,cwd=ROOT,stdout=subprocess.DEVNULL)
            retained=out/'mutations'/name/'source-snapshot'/OWNER.relative_to(ROOT)/fault['folder']
            require(all((retained/file.name).read_bytes()==file.read_bytes() for file in owner.iterdir() if file.is_file()), 'Fresh semantic candidate extraction drift')
            subprocess.run([ct['nodeExecutable'],OWNER/fault['folder']/'evm-traces.mjs',dest/name,candidate],check=True,cwd=ROOT,stdout=subprocess.DEVNULL)
            subprocess.run([sys.executable,'-B',OWNER/fault['folder']/'check-physical.py',dest/name,'--runtime',candidate],check=True,cwd=ROOT)
    print('PASS exact integer-power entries: '+str(len(rows))+' native obligations/'+str(len(declarations))+' declarations/55 zero audits/67 independently replayed physical receipts/two matching native and physical opcode faults; explicit representation/interpreter/resources remain.')
if __name__=='__main__': main()
