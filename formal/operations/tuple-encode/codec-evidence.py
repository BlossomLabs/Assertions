#!/usr/bin/env python3
"""Independently recheck immutable codec proof receipts and exact transitive current inputs."""
import argparse,csv,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
BASELINE='formal/abi/evidence/production-abi-correspondence/manifest.json'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def closure(p):
    result={p}
    for name in re.findall(r'^include "([^"]+)"',p.read_text(),re.M):result.update(closure((p.parent/name).resolve()))
    return result

def verify(root,dafny,solc):
    root=root.resolve();path=root/BASELINE;out=path.parent;m=json.loads(path.read_text())
    if m['status']!='passed' or m['sourceDrift'] or not all(c['passed'] for c in m['checks']):raise ValueError('Codec baseline incomplete')
    for name,value in m['sourceSha256'].items():
        if sha(root/name)!=value or sha(out/'source-snapshot'/name)!=value:raise ValueError('Codec transitive source drift '+name)
    for name,value in m['evidenceSha256'].items():
        if sha(out/name)!=value:raise ValueError('Codec retained receipt drift '+name)
    tools={'dafnyLauncher':dafny,'dafnyAssembly':dafny.parent/'Dafny.dll','solver':dafny.parent/'z3/bin/z3-4.12.1','solc':solc}
    if {k:sha(p) for k,p in tools.items()}!=m['executableSha256']:raise ValueError('Codec tool drift')
    job=next(c for c in m['checks'] if c.get('name')=='all-proof-modules');executions=job['moduleExecutions'];needed={str(p.relative_to(root)) for p in closure(root/'formal/abi/construction/Endpoints.dfy')}
    if not needed<={j['moduleFile'] for j in executions} or job['reportedErrors']!=0 or job['timedOutDeclarations']:raise ValueError('Codec module coverage')
    rows=[]
    for j in executions:
        module=root/j['moduleFile'];stem=j['moduleFile'].removeprefix('formal/abi/').replace('/','_').removesuffix('.dfy');log=out/'modules'/(stem+'.log');csvpath=out/'modules'/(stem+'.csv');text=log.read_text();rs=list(csv.DictReader(csvpath.open(newline='')))
        summary=re.search(r'Dafny program verifier finished with (\d+) verified, (\d+) errors',text)
        if j['exitCode']!=0 or not j['summaryPresent'] or j['reportedErrors']!=0 or not summary or int(summary[1])!=len(rs) or int(summary[2])!=0 or sha(log)!=j['logSha256'] or re.search(r'time out|timed out|inconclusive',text,re.I) or any(r['TestResult.Outcome']!='Passed' for r in rs):raise ValueError('Codec native receipt '+j['moduleFile'])
        if '--manual-lemma-induction' not in j['command'] or j['command'][j['command'].index('--verification-time-limit')+1]!='30' or j['command'][j['command'].index('--cores')+1]!='2':raise ValueError('Codec verifier settings')
        if 'reusedFrom' in j:
            reuse=j['reusedFrom'];transitive={str(p.relative_to(root)):sha(p) for p in closure(module)}
            if not reuse['matchingVerifierArguments'] or reuse['transitiveInputSha256']!=transitive or reuse['moduleLogSha256']!=sha(log):raise ValueError('Codec native reuse dependency drift')
        rows.extend(rs)
    if rows!=m['nativeResults'] or len(rows)!=job['verifiedBatches']:raise ValueError('Codec native inventory drift')
    declarations=[]
    for d in m['inventory']:
        batches=[r for r in rows if r['TestResult.DisplayName'].split(' (')[0]==d['name']];status='passed' if batches else 'definition-no-separate-batch';declarations.append(dict(d,status=status,batches=len(batches)))
        if d['kind'] in ['lemma','method'] and not batches:raise ValueError('Unproved codec helper '+d['name'])
    if declarations!=m['declarationResults']:raise ValueError('Codec declaration inventory drift')
    return {'manifest':BASELINE,'manifestSha256':sha(path),'nativeObligations':len(rows),'declarations':len(declarations),'requiredModules':sorted(needed),'reusedModules':len(executions),'scope':'Existing immutable codec native proofs reused only after exact current transitive input/tool/receipt checks. No new codec verification or bytecode claim.'}
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path);a=p.parse_args();r=verify(a.root,a.dafny.resolve(),a.solc.resolve())
    if a.output:a.output.write_text(json.dumps(r,indent=2)+'\n')
    print('PASS: complete codec retained graph '+str(r['nativeObligations'])+' native obligations, all reached modules/input hashes/tools/receipts checked')
