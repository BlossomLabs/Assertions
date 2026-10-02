#!/usr/bin/env python3
"""Independent finite physical byte-copy mutation receipts; native fault evidence remains open."""
import argparse,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
s=importlib.util.spec_from_file_location('baseline_physical',HERE/'check-development-receipts.py');b=importlib.util.module_from_spec(s);s.loader.exec_module(b)
def main():
 p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('candidate',type=Path);a=p.parse_args();bits=a.candidate.read_bytes();base=bytes.fromhex(b.read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);b.require(len(bits)==len(base) and [(i,x,y) for i,(x,y) in enumerate(zip(base,bits)) if x!=y]==[(18907,0x5e,0x37)],'Wrong actual one-byte candidate')
 boundary={};pc=0
 while pc<len(bits):
  op=bits[pc];width=op-0x5f if 0x60<=op<=0x7f else 0;boundary[pc]=(op,pc+1+width,int.from_bytes(bits[pc+1:pc+1+width],'big'));pc+=1+width
 rows=b.read(a.directory/'results.json');b.require(len(rows)==80,'Wrong fixture count');wrong=[]
 for r in rows:
  t=b.read(a.directory/r['trace']);reason,expected,at=b.intended(t);b.require(t['candidate'] and t['runtimeSha256']==hashlib.sha256(bits).hexdigest(),'Wrong candidate identity');logs=t['trace']['structLogs'];b.require(logs[0]['pc']==0 and all(s['depth']==1 for s in logs),'Incomplete actual frame')
  nat=lambda x:int(x.removeprefix('0x'),16);mem=lambda s:bytes.fromhex(''.join(x.removeprefix('0x') for x in s['memory']));data=bytes.fromhex(t['data'][2:]);copies=[]
  for i,step in enumerate(logs):
   op,nextpc,imm=boundary[step['pc']];b.require(step['op']==b.OPS.get(op),'Actual opcode mismatch')
   if i+1<len(logs):
    nxt=logs[i+1];dest=nat(step['stack'][-1]) if op==0x56 or op==0x57 and nat(step['stack'][-2]) else nextpc;b.require(nxt['pc']==dest,'Instruction omitted');
    if op in [0x56,0x57] and dest!=nextpc:b.require(boundary[dest][0]==0x5b,'Wrong destination')
    if op==0x5f or 0x60<=op<=0x7f:b.require(nat(nxt['stack'][-1])==imm,'Wrong PUSH')
    if op==0x37:
     dest,source,count=map(nat,step['stack'][-1:-4:-1]);copied=data[source:source+count].ljust(count,b'\0');b.require(count==1 and mem(nxt)[dest:dest+count]==copied,'Wrong actual raw byte-copy semantics');copies.append((step['pc'],dest,source,count))
  last=logs[-1];off,size=map(nat,last['stack'][-1:-3:-1]);actual=bytes.fromhex(t['trace']['returnValue'].removeprefix('0x'));b.require(mem(last)[off:off+size]==actual and size==len(actual),'Wrong actual physical slice')
  if reason=='Success':
   b.require(last['op']=='RETURN' and not t['trace']['failed'] and (off,size)==(192,96) and copies==[(7225,160,at,1),(18907,256,160,1)],'Wrong actual changed copy path')
   b.require(actual==b.word(32)+b.word(1)+(data[160:161] or b'\0')+b'\0'*31,'Wrong independently reconstructed changed byte envelope')
   if actual!=expected:wrong.append(r['ordinal'])
  else:b.require(last['op']=='REVERT' and t['trace']['failed'] and actual==expected,'Noncopy rejection changed')
 b.require(6 in wrong,'Missing intended semantic witness');w=b.read(a.directory/rows[6]['trace']);reason,expected,at=b.intended(w);b.require(at==100 and expected[64]==0xa5 and len(bytes.fromhex(w['data'][2:]))<160,'Wrong fixed witness')
 print('PASS development physical fault:'+str(len(wrong))+' wrong byteAt receipts including ordinal6 original0xa5→0; exact candidate opcode paths and input/physical envelopes independently checked. Native matching postcondition contradiction remains open.')
if __name__=='__main__':main()
