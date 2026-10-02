#!/usr/bin/env python3
"""Independent finite development receipt checks; no public native coverage."""
import argparse,hashlib,json
from pathlib import Path
from Crypto.Hash import keccak
ROOT=Path(__file__).resolve().parents[4]
M=1<<256;H=M//2;U64=1<<64
OPS={0x01:'ADD',0x02:'MUL',0x03:'SUB',0x04:'DIV',0x10:'LT',0x11:'GT',0x12:'SLT',0x14:'EQ',0x15:'ISZERO',0x16:'AND',0x17:'OR',0x19:'NOT',0x1b:'SHL',0x1c:'SHR',0x34:'CALLVALUE',0x35:'CALLDATALOAD',0x36:'CALLDATASIZE',0x37:'CALLDATACOPY',0x50:'POP',0x51:'MLOAD',0x52:'MSTORE',0x56:'JUMP',0x57:'JUMPI',0x5b:'JUMPDEST',0x5e:'MCOPY',0x5f:'PUSH0',0xf3:'RETURN',0xfd:'REVERT'}
for i in range(1,33):OPS[0x5f+i]='PUSH'+str(i)
for i in range(1,17):OPS[0x7f+i]='DUP'+str(i);OPS[0x8f+i]='SWAP'+str(i)
def require(ok,msg):
 if not ok:raise SystemExit(msg)
def read(p):return json.loads(p.read_text())
def word(x):return (x%M).to_bytes(32,'big')
def intended(t):
 data=bytes.fromhex(t['data'][2:]);value=int(t['value']);size=len(data)
 load=lambda offset:int.from_bytes(data[offset:offset+32].ljust(32,b'\0'),'big') if offset<size else 0
 if value or size<4:return 'Nonzero' if value else 'Short',b'',None
 require(data[:4].hex()=='9ae8e8ea','Selector drift')
 if size<68:return 'Args',b'',None
 offset=load(4);indexWord=load(36);index=indexWord if indexWord<H else indexWord-M
 if offset>=U64:return 'OffsetBound',b'',None
 if offset+36>size:return 'LengthWindow',b'',None
 length=load(offset+4)
 if length>=U64:return 'LengthBound',b'',None
 if offset+36+length>size:return 'PayloadWindow',b'',None
 if index>=length or index < -length:
  h=keccak.new(digest_bits=256);h.update(b'InvalidByteIndex(int256,uint256)')
  return 'InvalidByteIndex',h.digest()[:4]+word(indexWord)+word(length),None
 position=length+index if index<0 else index;at=offset+36+position
 return 'Success',word(32)+word(1)+data[at:at+1]+b'\0'*31,at

def main():
 parser=argparse.ArgumentParser();parser.add_argument('directory',type=Path);args=parser.parse_args();folder=args.directory
 runtime=bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);sha=hashlib.sha256(runtime).hexdigest()
 boundaries={};pc=0
 while pc<len(runtime):
  op=runtime[pc];width=op-0x5f if 0x60<=op<=0x7f else 0;boundaries[pc]=(op,pc+width+1,int.from_bytes(runtime[pc+1:pc+width+1],'big'));pc+=width+1
 rows=read(folder/'results.json');require(len(rows)==80,'Fixture inventory drift');counts={}
 for r in rows:
  t=read(folder/r['trace']);reason,expected,at=intended(t);require(reason==r['reason'] and r['passed'] and t['runtimeSha256']==sha and not t['candidate'],'Fixture identity/result drift')
  trace=t['trace'];logs=trace['structLogs'];require(logs[0]['pc']==0 and all(s['depth']==1 for s in logs),'Incomplete physical call frame')
  counts[reason]=counts.get(reason,0)+1
  nat=lambda x:int(x.removeprefix('0x'),16)
  memory=lambda s:bytes.fromhex(''.join(w.removeprefix('0x') for w in s['memory']))
  for i,s in enumerate(logs):
   require(s['pc'] in boundaries,'Executed non-boundary');op,nxt,imm=boundaries[s['pc']];require(s['op']==OPS.get(op),'Actual opcode differs from compiler-bound instruction')
   if i+1<len(logs):
    after=logs[i+1]
    dest=nat(s['stack'][-1]) if op==0x56 or op==0x57 and nat(s['stack'][-2]) else nxt
    require(after['pc']==dest,'Missing instruction/actual branch')
    if op in [0x56,0x57] and dest!=nxt:require(boundaries.get(dest,(None,))[0]==0x5b,'Invalid actual destination')
    if op==0x5f or 0x60<=op<=0x7f:require(nat(after['stack'][-1])==imm,'Wrong actual PUSH immediate')
    if op==0x37:
     dest,source,count=map(nat,s['stack'][-1:-4:-1]);require(reason=='Success' and count==1 and source==at,'Wrong actual selected input-byte copy')
     require(memory(after)[dest:dest+count]==bytes.fromhex(t['data'][2:])[at:at+1],'Wrong selected physical byte')
    if op==0x5e:
     dest,source,count=map(nat,s['stack'][-1:-4:-1]);require(reason=='Success' and count==1 and memory(after)[dest:dest+count]==memory(s)[source:source+count],'Wrong physical memory copy')
  last=logs[-1];offset,length=nat(last['stack'][-1]),nat(last['stack'][-2]);actual=bytes.fromhex(trace['returnValue'].removeprefix('0x'))
  require(last['op']==('RETURN' if reason=='Success' else 'REVERT') and trace['failed']==(reason!='Success') and actual==expected and memory(last)[offset:offset+length]==expected and length==len(expected),'Wrong independent exact byte receipt')
  if reason=='Success':require((offset,length)==(192,96),'Wrong compiled bytes envelope location')
 require(counts=={'InvalidByteIndex':36,'Success':28,'Short':4,'Args':5,'Nonzero':2,'OffsetBound':1,'LengthWindow':2,'LengthBound':1,'PayloadWindow':1},'Scope inventory drift')
 print('PASS development only:80 complete compiler-bound byteAt physical receipts, independent signed-index/error/byte-envelope outcomes; native public coverage remains open')
if __name__=='__main__':main()
