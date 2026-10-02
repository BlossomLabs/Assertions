#!/usr/bin/env python3
"""Independent concrete validation of the OR child memory image and full iteration."""
import argparse,hashlib,json,runpy
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
interpreter=runpy.run_path(str(HERE.parent.parent/'constrained-raw/public/check-false-replay-consolidated-v1.py'));step,stack,memory=interpreter['step'],interpreter['stack'],interpreter['memory']
def load(m,p):return int.from_bytes(m[p:p+32],'big')
def store(m,p,w):
 m=bytearray(m);n=((p+63)//32)*32
 if n>len(m):m.extend(bytes(n-len(m)))
 m[p:p+32]=w.to_bytes(32,'big');return m
def copy(m,dst,src,n):
 m=bytearray(m)
 if n:
  size=((max(dst,src)+n+31)//32)*32
  if size>len(m):m.extend(bytes(size-len(m)))
  m[dst:dst+n]=bytes(m[src:src+n])
 return m
def main():
 p=argparse.ArgumentParser();p.add_argument('--receipts',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();code=bytes.fromhex(json.load(open(ROOT/'artifacts/contracts/Assertions.sol/Assertions.json'))['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();checks=[];mapping=json.load(open(HERE/'NonemptyItem.mapping.json'));assert mapping['runtimeSha256']==digest
 for pos,value in mapping['requiredBytes'].items():assert code[int(pos)]==value
 for path in sorted(a.receipts.glob('or-*.json')):
  if path.name.endswith('-boundaries.json'):continue
  j=json.load(open(path));assert j['runtimeSha256']==digest;logs=[r for r in j['trace']['structLogs'] if r['depth']==1];begins=[i for i,r in enumerate(logs) if r['pc']==19590]
  for begin,end in zip(begins,begins[1:]):
   assert logs[end]['pc']==19590
   assert [r['pc'] for r in logs[begin:end]]==[r['pc'] for r in mapping['states']]
   s=stack(logs[begin]);old=memory(logs[begin]);body,headend,slot,dstslot,arrayptr=s[-5:];position=load(old,slot);record=body+32+position;kind=load(old,record);relative=load(old,record+32);length=load(old,record+relative);source=record+relative+32;free=load(old,64);nextfree=free+96+((length+31)//32)*32
   image=store(old,64,free+64);image=store(image,free,kind);image=store(image,64,nextfree);image=store(image,free+64,length);image=copy(image,free+96,source,length);image=store(image,free+96+length,0);image=store(image,free+32,free+64);image=store(image,dstslot,free)
   assert image==memory(logs[end]),(path.name,begin,'constructor')
   assert stack(logs[end])==s[:-3]+[slot+32,dstslot+32,arrayptr]
   for i in range(begin,end):
    nxt,st,mem,terminal=step(code,logs[i],bytes.fromhex(j['data'][2:]));following=logs[i+1];assert terminal is None and (nxt,st,mem)==(following['pc'],stack(following),memory(following)),(path.name,i,logs[i]['pc'])
   checks.append({'fixture':path.name,'kind':kind,'length':length,'instructionCount':end-begin,'fullStackMemoryReplay':True,'compoundConstructorEquality':True})
 assert len(checks)==16;result={'status':'passed','scope':'Concrete child decoder iterations and independently implemented compound memory image; universal opcode/loop/table binding remains open.','runtimeSha256':digest,'mappingSha256':hashlib.sha256((HERE/'NonemptyItem.mapping.json').read_bytes()).hexdigest(),'instructionCount':sum(r['instructionCount'] for r in checks),'checks':checks};a.output.write_text(json.dumps(result,indent=2)+'\n');print('PASS',result['instructionCount'],'instructions',len(checks),'iterations')
if __name__=='__main__':main()
