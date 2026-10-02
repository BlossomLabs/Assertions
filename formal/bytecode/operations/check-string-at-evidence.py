#!/usr/bin/env python3
"""Independent complete exact string-at retained evidence checker."""
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
PUBLIC = ['Operations.stringAt(bytes,int256)']
CONFIGS = [dict(name='mcopy-to-calldata',folder='string-at-mutation',pc=18907,old=94,new=55,symbol='OperationsStringAtSemanticWitness.SemanticWitness',ordinal=5)]
def main():
    parser = argparse.ArgumentParser(); parser.add_argument('--manifest', type=Path); parser.add_argument('--ledger', type=Path); args = parser.parse_args()
    ledger = read(args.ledger) if args.ledger else None
    if args.manifest is None:
        if ledger is None: ledger = read(ROOT/'docs/verification/operations-string-at-bytecode.json')
        args.manifest = ROOT/ledger['baseline']
    out = args.manifest.resolve().parent; manifest = read(out/'manifest.json'); snapshot = out/'source-snapshot'
    v = load('string-at_retainer', OWNER/'string-at-retention/verify.py'); common = v.common
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
    require(len(v.PROOFS)==109 and manifest['proofFiles']==[str(f.relative_to(ROOT)) for f in v.PROOFS], 'Complete proof inventory drift')
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
    proved={d['name'] for d in declarations if d['status']=='passed'}; connections=['OperationsStringAtFull.Run']
    require(all(name in proved for name in connections), 'Missing full raw public connection')
    if ledger:
        require(ledger['connections']==connections and ledger['nativeObligations']==len(rows) and ledger['nativeDeclarations']==len(declarations), 'Ledger native scope/count drift')
    code=bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();identity=read(out/'identity/identity.json')[0]
    require(identity['runtimeSha256']==digest and identity['methodIdentifiers']['stringAt(bytes,int256)']=='a1bc2139','Current exact compiler/runtime/selector drift')
    if ledger:require(ledger['runtimeSha256']==digest,'Ledger runtime drift')
    baseline=read(out/'evm-traces/results.json');partition={reason:sum(r['reason']==reason for r in baseline) for reason in sorted({r['reason'] for r in baseline})}
    expected_partition={'Args':5,'InvalidByteIndex':132,'InvalidUtf8':220,'LengthBound':1,'LengthWindow':2,'Nonzero':2,'OffsetBound':1,'PayloadWindow':1,'Short':4,'Success':37}
    require(len(baseline)==405 and all(r['passed'] for r in baseline) and {r['ordinal'] for r in baseline}==set(range(405)) and partition==manifest['physicalPartition']==expected_partition,'Complete physical baseline/raw/error/success inventory drift')
    ct=manifest['concreteToolchain'];require(sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and all(sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['hardhatEntry','edrEntry','nativeBinding']) and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'],'Physical tool dependency drift')
    faults=read(out/'mutations/results.json');require(len(faults)==1 and faults==manifest['semanticFaults'] and read(out/'candidates/inventory.json')==CONFIGS,'Selected same-PC fault inventory drift')
    fault=faults[0];config=CONFIGS[0];name=config['name'];candidate=out/'candidates'/(name+'.bin');mutant=candidate.read_bytes();folder=out/'mutations'/name
    require(all(fault[k]==value for k,value in config.items()) and fault['passed'] and fault['baselineDeclaration']==config['symbol'] and config['symbol'] in proved,'Semantic fault is not baseline-covered')
    original=next(d for d in declarations if d['name']==config['symbol']);require(fault['baselineObligations']==original['batches'],'Mutation baseline declaration drift')
    require(len(mutant)==len(code) and [i for i,(a,b) in enumerate(zip(code,mutant)) if a!=b]==[18907] and code[18907]==94 and mutant[18907]==55 and sha(candidate)==fault['candidateSha256'],'Not the exact selected single-byte MCOPY/CALLDATACOPY fault')
    file=folder/'source-snapshot'/OWNER.relative_to(ROOT)/config['folder']/'Witness.generated.dfy';native=checks[name+'-native'];expected=[str(x) for x in common.proof_command(dafny,file,folder/'proof.csv')]+['--filter-symbol',config['symbol'],'--filter-position',str(file),'--progress','Symbol']
    require(native['command']==expected and native['exitCode'] not in [0,None],'Wrong native fault scope/terminal')
    faultrows=list(csv.DictReader((folder/'proof.csv').open()));log=(out/(name+'-native.log')).read_text()
    require(faultrows==fault['nativeResults'] and any(r['TestResult.Outcome']=='Failed' for r in faultrows) and all(r['TestResult.Outcome'] in ['Passed','Failed'] for r in faultrows) and 'a postcondition could not be proved' in log and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',log,re.I),'Candidate did not contradict the ordinary semantic postcondition')
    mutable={str((OWNER/config['folder']/n).relative_to(ROOT)) for n in ['Witness.generated.dfy','witness.mapping.json']}
    require(all(p in mutable or sha(folder/'source-snapshot'/p)==h for p,h in current.items()),'Fault changed unrelated trusted inputs')
    original_file=snapshot/OWNER.relative_to(ROOT)/config['folder']/'Witness.generated.dfy'
    require(file.read_text()==original_file.read_text().replace('S.Op(0x5e,18908,0)','S.Op(0x37,18908,0)'),'Fault altered the original semantic postcondition or witness state')
    wm=read(folder/'source-snapshot'/OWNER.relative_to(ROOT)/config['folder']/'witness.mapping.json');bm=read(snapshot/OWNER.relative_to(ROOT)/config['folder']/'witness.mapping.json')
    require(wm==dict(bm,runtimeSha256=sha(candidate),opcode=55) and bm['canonicalRuntimeSha256']==bm['runtimeSha256']==digest and bm['opcode']==94 and bm['witnessOrdinal']==5 and bm['semanticPostUnchanged'],'Witness extraction/runtime binding drift')
    physical=read(folder/'evm-traces/results.json');witness=physical[5]
    require(len(physical)==fault['physicalReceipts']==405 and {r['ordinal'] for r in physical}==set(range(405)) and witness['ordinal']==5 and not witness['passed'] and witness['actual']!=witness['expected'] and sum(not r['passed'] for r in physical)==fault['physicalIntendedOutcomeContradictions']==27 and all(r['reason']=='Success' for r in physical if not r['passed']),'Missing matching complete physical contradiction')
    def run(command):subprocess.run([str(x) for x in command],check=True,cwd=ROOT)
    def replay(directory,reportroot):
        run([sys.executable,'-B',OWNER/'string-at-preparation/check-physical.py',directory,'--expected-count','405'])
        run([sys.executable,'-B',OWNER/'string-at-raw/check-mapping.py',directory])
        for owner in ['string-at-entry-controls','string-at-index-controls','string-at-body-controls']:
            run([sys.executable,'-B',OWNER/owner/'check-mapping.py',directory,'--report',reportroot/(owner+'.json')])
        run([sys.executable,'-B',OWNER/'utf8-shared/check-controls.py',OWNER/'utf8-shared/controls.mapping.json',directory,'--report',reportroot/'utf8.json'])
    with tempfile.TemporaryDirectory(prefix='operations-string-at-independent-') as directory:
        dest=Path(directory)
        replay(out/'evm-traces',dest)
        run([sys.executable,'-B',OWNER/'string-at-preparation/check-physical.py',folder/'evm-traces','--runtime',candidate,'--expected-count','405','--expect-semantic-fault'])
        run([sys.executable,'-B',OWNER/'string-at-preparation/check-frontier.py',out/'evm-traces',folder/'evm-traces','--runtime',candidate,'--report',dest/'retained-frontier.json'])
        require(read(dest/'retained-frontier.json')==read(folder/'frontier.json'),'Retained complete native/physical frontier drift')
        require(bm['preStack']==read(dest/'retained-frontier.json')['preStack'] and bm['postStack']==read(dest/'retained-frontier.json')['postStack'],'Native and physical full witness stack drift')
        def record(name,command,timeout=240):
            job=common.run(command,dest/(name+'.log'),timeout);job.update(name=name,passed=job['exitCode']==0);return job
        require(v.regenerate(OWNER,dest,record),'Fresh generated bytecode/control/native source drift')
        run([sys.executable,'-B',OWNER/'identity.py','--solc',solc,'--output',dest/'identity']);require(read(dest/'identity/identity.json')==read(out/'identity/identity.json'),'Fresh exact compiler/runtime drift')
        fixtures=OWNER/'string-at-preparation/utf8-profile-fixtures.json'
        run([ct['nodeExecutable'],OWNER/'string-at-preparation/evm-traces.mjs',dest/'baseline','-',fixtures]);replay(dest/'baseline',dest)
        clone=dest/'mutant-source';shutil.copytree(snapshot,clone);owner=clone/OWNER.relative_to(ROOT)/config['folder']
        run([sys.executable,'-B',owner/'generate.py','--runtime',candidate,'--output',owner]);run([dafny,'format','--check',owner/'Witness.generated.dfy'])
        retained=folder/'source-snapshot'/OWNER.relative_to(ROOT)/config['folder'];require(all((retained/file.name).read_bytes()==file.read_bytes() for file in owner.iterdir() if file.is_file()),'Fresh faithful semantic fault extraction drift')
        run([ct['nodeExecutable'],OWNER/'string-at-preparation/evm-traces.mjs',dest/name,candidate,fixtures])
        run([sys.executable,'-B',OWNER/'string-at-preparation/check-physical.py',dest/name,'--runtime',candidate,'--expected-count','405','--expect-semantic-fault'])
        run([sys.executable,'-B',OWNER/'string-at-preparation/check-frontier.py',dest/'baseline',dest/name,'--runtime',candidate,'--report',dest/'fresh-frontier.json'])
        require(read(dest/'fresh-frontier.json')==read(folder/'frontier.json'),'Fresh complete fault frontier/RETURN packet drift')
    require(current=={str(f.relative_to(ROOT)):sha(f) for f in v.inputs()} and manifest['evidenceSha256']=={str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='manifest.json'},'Independent replay changed the frozen closure')
    print('PASS exact stringAt public entry: '+str(len(rows))+' native obligations/'+str(len(declarations))+' declarations/109 zero audits/405 retained and fresh independently replayed physical receipts/matching whole-state native and physical memory-copy fault; explicit representation/resources/interpreter premises remain.')
if __name__=='__main__':main()
