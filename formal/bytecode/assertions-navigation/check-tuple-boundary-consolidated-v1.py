#!/usr/bin/env python3
"""Independent concrete tuple boundary checks; receipts supplement native proofs."""
from pathlib import Path
import hashlib,json,re
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:])
digest=hashlib.sha256(code).hexdigest()
assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
base=HERE/'development/tuple-shape-consolidated-v1/evm'
counts={'prefix':0,'child':0,'comma':0,'close':0,'dynamic-close':0,'dynamic-comma':0,'mixed-close':0}
inventories={name:json.loads((HERE/f'development/tuple-{name}-v1/inventory.json').read_text()) for name in counts}
for name,inventory in inventories.items():
 source=(HERE/f'development/tuple-{name}-v1/Character.dfy').read_text()
 guard=re.search(r'opaque predicate Matches\(code: seq<Byte>\) \{([^}]+)\}',source).group(1)
 clauses=guard.split(' && ')
 assert clauses[0].strip()==f'|code| == {len(code)}'
 facts={}
 for clause in clauses[1:]:
  match=re.fullmatch(r'code\[(\d+)\] == (\d+)',clause.strip());assert match,clause
  pc,value=map(int,match.groups());assert code[pc]==value;facts[pc]=value
 for pc in inventory['pcSequence']:
  width=code[pc]-95 if 96<=code[pc]<=127 else 0
  assert all(at in facts for at in range(pc,pc+1+width))
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
   if ce>=limit:continue
   assert (a,b,c)==(0,0,0) and total+cw<2**256
   if calldata[offset+ce]==44 and cd==0:
    name='comma';expected=pre+[ret,offset,length,p,limit,end,dyn,words,ce+1,total+cw];terminal=8546
   elif calldata[offset+ce]==44 and cd==1:
    name='dynamic-comma';expected=pre+[ret,offset,length,p,limit,end,1,words,ce+1,total+cw];terminal=8546
   elif calldata[offset+ce]==41 and dyn==1 and cd==0:
    name='mixed-close';expected=pre+[ret,offset,length,p,limit,ce+1,1,1];terminal=8882
   elif calldata[offset+ce]==41 and dyn==0 and cd==0:
    name='close';expected=pre+[ret,offset,length,p,limit,ce+1,0,total+cw];terminal=8882
   elif calldata[offset+ce]==41 and cd==1:
    name='dynamic-close';expected=pre+[ret,offset,length,p,limit,ce+1,1,1];terminal=8882
   else:continue
  else:continue
  pcs=inventories[name]['pcSequence'];endrow=rows[i+len(pcs)]
  assert [x['pc'] for x in rows[i:i+len(pcs)]]==pcs
  assert endrow['pc']==terminal and stack(endrow)==expected
  assert all(x.get('memory',[])==row.get('memory',[]) for x in rows[i:i+len(pcs)+1])
  counts[name]+=1
assert all(counts.values())
print(json.dumps({'scope':'Concrete independent tuple boundary receipt checks only; no whole entry claim','runtimeSha256':digest,'receipts':7,'admittedExecutions':counts},indent=2))
