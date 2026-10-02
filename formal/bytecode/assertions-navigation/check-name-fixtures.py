#!/usr/bin/env python3
"""Check actual scanName call admissions, maximal prefixes and all physical PCs."""
from pathlib import Path
import json,sys,hashlib
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];out=Path(sys.argv[1])
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest()
assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
sequences={kind:json.loads((HERE/'development'/version/'inventory.json').read_text())['pcSequence'] for kind,version in [('character','name-character-v3'),('exit','name-exit-v1'),('limit','name-limit-v1')]}
reports=[]
for result in json.loads((out/'results.json').read_text()):
 case=json.loads((out/result['trace']).read_text());assert case['runtimeSha256']==digest
 data=bytes.fromhex(case['data'][2:]);rows=case['trace']['structLogs'];calls=[]
 for i,row in enumerate(rows):
  if row['pc']!=12520 or row['depth']!=1:continue
  stack=[int(w,16) for w in row['stack']];ret,offset,length,p,limit=stack[-5:];prefix=stack[:-5]
  assert p<=limit<=length and offset+length<=len(data)<1<<64 and len(prefix)<=980
  assert ret<len(code) and code[ret]==91
  q=p
  while q<limit and (97<=data[offset+q]<=122 or 48<=data[offset+q]<=57):q+=1
  j=next(k for k in range(i+1,len(rows)) if rows[k]['depth']==1 and rows[k]['pc']==ret)
  expected=[12520,12521]+sequences['character']*(q-p)+sequences['exit' if q<limit else 'limit']
  actual=[r['pc'] for r in rows[i:j]];assert actual==expected,(case['descriptor'],p,q)
  assert [int(w,16) for w in rows[j]['stack']]==prefix+[q]
  assert all(r['memory']==row['memory'] for r in rows[i:j+1])
  calls.append({'ret':ret,'offset':offset,'length':length,'p':p,'limit':limit,'q':q,'instructionCount':len(actual),'exit':'character' if q<limit else 'limit','passed':True})
 assert calls
 reports.append({'trace':result['trace'],'descriptor':case['descriptor'],'calls':calls,'passed':True})
(out/'scanner-admission.json').write_text(json.dumps({'runtimeSha256':digest,'scope':'Finite complete public fixtures; actual admitted helper calls with exact physical PCs and complete stack/memory preservation. Native unbounded scanner proof is separate.','cases':reports},indent=2)+'\n')
print('PASS:',len(reports),'public receipts and',sum(len(r['calls']) for r in reports),'exact scanner segments')
