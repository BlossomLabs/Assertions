#!/usr/bin/env python3
"""Create a pending-parent ledger only from a complete passing retained manifest.

Does not modify coverage plans or imply an independent evidence check passed.
"""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def read(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--manifest',type=Path,required=True);p.add_argument('--ledger',type=Path,required=True);p.add_argument('--checker',type=Path,required=True);a=p.parse_args();manifest=a.manifest.resolve();ledger=a.ledger.resolve();checker=a.checker.resolve();m=read(manifest);out=manifest.parent
 assert manifest.is_relative_to(HERE) and ledger.is_relative_to(ROOT/'docs/verification') and checker.is_relative_to(HERE)
 assert m['status']=='passed' and all(m[k] for k in ['inputsUnchanged','toolsUnchanged','concreteToolsUnchanged']) and all(c['passed'] for c in m['checks'])
 assert all(sha(ROOT/name)==digest and sha(out/'source-snapshot'/name)==digest for name,digest in m['sourceSha256'].items())
 assert {str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'}==m['evidenceSha256']
 assert all(r['TestResult.Outcome']=='Passed' for r in m['nativeResults']) and all(d['status'] in {'passed','definition-only'} for d in m['declarationResults'])
 connections=[d['name'] for d in m['declarationResults'] if 'Connection.' in d['name'] and d['kind']=='method' and d['status']=='passed'];assert connections
 rows=read(out/'evm-traces/results.json');raw=read(out/'rejection-traces/results.json') if (out/'rejection-traces/results.json').is_file() else []
 assert all(r['passed'] for r in rows+raw)
 def trace(r):return read(out/'evm-traces'/r['trace'])
 success=sum(not trace(r)['trace']['failed'] for r in rows)
 panic=sum(trace(r)['trace']['failed'] and trace(r)['trace']['returnValue'].removeprefix('0x').startswith('4e487b71') for r in rows)
 custom=sum(trace(r)['trace']['failed'] and bool(trace(r)['trace']['returnValue'].removeprefix('0x')) and not trace(r)['trace']['returnValue'].removeprefix('0x').startswith('4e487b71') for r in rows)
 rawCount=len(raw)+sum(trace(r)['trace']['failed'] and not trace(r)['trace']['returnValue'].removeprefix('0x') for r in rows)
 faults=read(out/'mutations/results.json');assert all(all(c['passed'] for c in f['checks']) for f in faults)
 identity=read(out/'identity/identity.json')[0]
 data=dict(schemaVersion=1,status='retained-owner-check-pending-parent',package=str(out.parent.parent.relative_to(ROOT)),baseline=str(manifest.relative_to(ROOT)),baselineSha256=sha(manifest),checker=str(checker.relative_to(ROOT)),publicEntries=m['publicEntries'],runtimeSha256=identity['runtimeSha256'],nativeObligations=len(m['nativeResults']),nativeDeclarations=len(m['declarationResults']),connections=connections,concreteSuccessReceipts=success,concretePanicReceipts=panic,concreteCustomErrorReceipts=custom,concreteRejectionReceipts=rawCount,semanticBytecodeFaults=len(faults),assumptions=m['assumptions'])
 assert not ledger.exists(),'Preserve existing ledger; do not overwrite blindly'
 ledger.write_text(json.dumps(data,indent=2)+'\n');print(json.dumps(data,indent=2))
if __name__=='__main__':main()
