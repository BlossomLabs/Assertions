#!/usr/bin/env python3
"""Independent lexical shape and exact full physical typeShape base-class receipts."""
from pathlib import Path
import json,hashlib,sys
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];out=Path(sys.argv[1]);out.mkdir(parents=True,exist_ok=True)
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
versions={'prefix':'base-prefix-v1','character':'name-character-v3','nameExit':'name-exit-v1','nameLimit':'name-limit-v1','five':'base-five-v2','six':'base-six-v2','other':'base-other-v1','byteReturn':'base-byte-return-v1','limitReturn':'base-limit-return-v1'}
sequences={};bindings={}
for kind,version in versions.items():
 folder=HERE/'development'/version;inv=json.loads((folder/'inventory.json').read_text());assert inv['runtimeSha256']==digest
 sequences[kind]=inv['pcSequence'];bindings[version]={'inventorySha256':hashlib.sha256((folder/'inventory.json').read_bytes()).hexdigest()}
destinations=set();pc=0
while pc<len(code):
 op=code[pc]
 if op==91:destinations.add(pc)
 pc+=1+(op-95 if 96<=op<=127 else 0)
def character(c):return 97<=c<=122 or 48<=c<=57
cases=[];total=0
for directory in map(Path,sys.argv[2:]):
 for result in json.loads((directory/'results.json').read_text()):
  file=directory/result['trace'];case=json.loads(file.read_text());assert case['runtimeSha256']==digest;data=bytes.fromhex(case['data'][2:]);rows=case['trace']['structLogs'];calls=[];excluded=[]
  for i,row in enumerate(rows):
   if row['pc']!=8442 or row['depth']!=1:continue
   stack=[int(w,16) for w in row['stack']];ret,offset,length,p,limit=stack[-5:];prefix=stack[:-5]
   if not(p<limit<=length and offset+length<=len(data)<1<<64 and len(prefix)<=950 and character(data[offset+p])):
    excluded.append({'entryRow':i,'reason':'Outside nonempty fitting base-name admission'});continue
   q=p
   while q<limit and character(data[offset+q]):q+=1
   if q<limit and data[offset+q]==91:
    excluded.append({'entryRow':i,'reason':'Array suffix is outside this helper class'});continue
   assert ret in destinations
   j=next(k for k in range(i+1,len(rows)) if rows[k]['depth']==1 and rows[k]['pc']==ret)
   name=data[offset+p:offset+q];dyn=name in [b'bytes',b'string'];n=q-p
   expected=sequences['prefix']+[12520,12521]+sequences['character']*n+sequences['nameExit' if q<limit else 'nameLimit']+sequences['five' if n==5 else 'six' if n==6 else 'other']+sequences['byteReturn' if q<limit else 'limitReturn']
   actual=[r['pc'] for r in rows[i:j]];assert actual==expected,(case['descriptor'],p,limit,q)
   assert [int(w,16) for w in rows[j]['stack']]==prefix+[q,int(dyn),1]
   assert all(r['memory']==row['memory'] for r in rows[i:j+1])
   calls.append({'entryRow':i,'ret':ret,'offset':offset,'length':length,'p':p,'limit':limit,'q':q,'nameHex':name.hex(),'dynamic':dyn,'words':1,'instructionCount':len(actual),'passed':True});total+=1
  cases.append({'trace':str(file),'traceSha256':hashlib.sha256(file.read_bytes()).hexdigest(),'descriptor':case['descriptor'],'admittedCalls':calls,'excludedCalls':excluded})
assert total>0
(out/'base-plain-admission.json').write_text(json.dumps({'runtimeSha256':digest,'scope':'Finite public receipts for exact admitted full physical typeShape base-name classes; excluded tuple, array and invalid-name calls explicitly recorded. Native arbitrary-length proof and complete public-entry coverage remain separate.','bindings':bindings,'cases':cases,'admittedCallCount':total},indent=2)+'\n')
print('PASS:',len(cases),'public fixtures;',total,'complete admitted base-type parser executions')
