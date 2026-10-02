#!/usr/bin/env python3
"""Independent concrete tuple boundary checks; receipts supplement native proofs."""
from pathlib import Path
import hashlib,json
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:])
digest=hashlib.sha256(code).hexdigest()
assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
base=HERE/'development/tuple-shape-gates-v1/evm'
counts={'prefix':0,'child':0,'comma':0}
inventories={name:json.loads((HERE/f'development/tuple-{name}-v1/inventory.json').read_text()) for name in counts}
def stack(r):return [int(x,16) for x in r['stack']]
for file in sorted(base.glob('case-*.json')):
 receipt=json.loads(file.read_text());assert receipt['runtimeSha256']==digest
 assert not receipt['trace']['failed'] and receipt['actual']==receipt['expected']
 rows=receipt['trace']['structLogs']
 for i,row in enumerate(rows):
  st=stack(row)
  if row['pc']==8442:
   pre=st[:-5];ret,offset,length,p,limit=st[-5:]
   calldata=bytes.fromhex(receipt['data'][2:])
   if p>=limit or calldata[offset+p]!=40:continue
   name='prefix';expected=pre+[ret,offset,length,p,limit,0,0,0,p+1,0,0,0,0,8561,offset,length,p+1,limit];terminal=8442
  elif row['pc']==8546:
   name='child';pre=st[:-10];ret,offset,length,p,limit,end,dyn,words,q,total=st[-10:]
   expected=pre+[ret,offset,length,p,limit,end,dyn,words,q,total,0,0,0,8561,offset,length,q,limit];terminal=8442
  elif row['pc']==8561:
   pre=st[:-16];ret,offset,length,p,limit,end,dyn,words,q,total,a,b,c,ce,cd,cw=st[-16:]
   calldata=bytes.fromhex(receipt['data'][2:])
   if cd!=0 or ce>=limit or calldata[offset+ce]!=44:continue
   assert (a,b,c)==(0,0,0) and total+cw<2**256
   name='comma';expected=pre+[ret,offset,length,p,limit,end,dyn,words,ce+1,total+cw];terminal=8546
  else:continue
  pcs=inventories[name]['pcSequence'];endrow=rows[i+len(pcs)]
  assert [x['pc'] for x in rows[i:i+len(pcs)]]==pcs
  assert endrow['pc']==terminal and stack(endrow)==expected
  assert all(x.get('memory',[])==row.get('memory',[]) for x in rows[i:i+len(pcs)+1])
  counts[name]+=1
assert all(counts.values())
print(json.dumps({'scope':'Concrete independent tuple boundary receipt checks only; no whole entry claim','runtimeSha256':digest,'receipts':5,'admittedExecutions':counts},indent=2))
