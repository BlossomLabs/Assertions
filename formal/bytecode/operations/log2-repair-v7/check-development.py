#!/usr/bin/env python3
"""Independent complete physical log2 stack/byte-memory replay; no native credit."""
import argparse,hashlib,json
from pathlib import Path
from Crypto.Hash import keccak
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];M=1<<256;H=M//2
OPS={0x01:'ADD',0x03:'SUB',0x04:'DIV',0x10:'LT',0x11:'GT',0x12:'SLT',0x14:'EQ',0x15:'ISZERO',0x16:'AND',0x17:'OR',0x19:'NOT',0x1a:'BYTE',0x1b:'SHL',0x1c:'SHR',0x34:'CALLVALUE',0x35:'CALLDATALOAD',0x36:'CALLDATASIZE',0x50:'POP',0x51:'MLOAD',0x52:'MSTORE',0x56:'JUMP',0x57:'JUMPI',0x5b:'JUMPDEST',0x5f:'PUSH0',0xf3:'RETURN',0xfd:'REVERT'}
OPS.update({0x5f+i:'PUSH'+str(i) for i in range(1,33)});OPS.update({0x7f+i:'DUP'+str(i) for i in range(1,17)});OPS.update({0x8f+i:'SWAP'+str(i) for i in range(1,17)})
def read(p):return json.loads(p.read_text())
def require(ok,msg):
 if not ok:raise RuntimeError(msg)
def main():
 p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('--runtime',type=Path);p.add_argument('--expect-fault',action='store_true');a=p.parse_args();out=a.directory
 code=a.runtime.read_bytes() if a.runtime else bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();ins={};pc=0
 while pc<len(code):
  op=code[pc];width=op-0x5f if 0x60<=op<=0x7f else 0;ins[pc]=(op,pc+width+1,int.from_bytes(code[pc+1:pc+width+1].ljust(width,b'\0'),'big'));pc+=width+1
 h=keccak.new(digest_bits=256);h.update(b'LogarithmUndefined(int256)');error=h.digest()[:4]+b'\0'*32;rows=read(out/'results.json');require(len(rows)==31 and {r['ordinal'] for r in rows}==set(range(31)),'Fixture inventory')
 wrong=[];paths={}
 for r in rows:
  t=read(out/r['trace']);data=bytes.fromhex(t['data'][2:]);value=int(t['value'],16);logs=t['trace']['structLogs'];require(t['runtimeSha256']==digest and t['candidate']==bool(a.runtime),'Runtime identity')
  def load(at):return int.from_bytes(data[at:at+32].ljust(32,b'\0'),'big') if at<len(data) else 0
  if value or len(data)<36:expected=b'';failed=True
  else:
   require(data[:4].hex()=='5456bf13','Selector');x=load(4);failed=x==0;expected=error if failed else (x.bit_length()-1).to_bytes(32,'big')
  require(t['expected']==expected.hex() and r['expected']==expected.hex(),'Independent mathematical/error outcome')
  pc=0;stack=[];memory=bytearray();terminal=None
  def grow(end):memory.extend(b'\0'*max(0,((end+31)//32)*32-len(memory)))
  def pop():return stack.pop()
  for index,s in enumerate(logs):
   require(s['depth']==1 and s['pc']==pc and pc in ins,'Complete actual path');op,nxt,imm=ins[pc];require(s['op']==OPS.get(op),'Reached opcode')
   require([int(x,16) for x in s['stack']]==stack and bytes.fromhex(''.join(x.removeprefix('0x') for x in s['memory']))==memory,'Complete pre-state stack/memory')
   if op==0x5f or 0x60<=op<=0x7f:stack.append(imm)
   elif op==0x34:stack.append(value)
   elif op==0x36:stack.append(len(data))
   elif op==0x35:stack.append(load(pop()))
   elif 0x80<=op<=0x8f:stack.append(stack[-(op-0x7f)])
   elif 0x90<=op<=0x9f:k=op-0x8f;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
   elif op==0x50:pop()
   elif op==0x15:stack.append(int(pop()==0))
   elif op==0x19:stack.append(M-1-pop())
   elif op in [0x01,0x03,0x04,0x10,0x11,0x12,0x14,0x16,0x17,0x1a,0x1b,0x1c]:
    left,right=pop(),pop();signed=lambda x:x if x<H else x-M
    result={0x01:lambda:(left+right)%M,0x03:lambda:(left-right)%M,0x04:lambda:0 if right==0 else left//right,0x10:lambda:int(left<right),0x11:lambda:int(left>right),0x12:lambda:int(signed(left)<signed(right)),0x14:lambda:int(left==right),0x16:lambda:left&right,0x17:lambda:left|right,0x1a:lambda:0 if left>=32 else (right>>(8*(31-left)))&255,0x1b:lambda:0 if left>=256 else (right<<left)%M,0x1c:lambda:0 if left>=256 else right>>left}[op]();stack.append(result)
   elif op==0x52:at,v=pop(),pop();grow(at+32);memory[at:at+32]=v.to_bytes(32,'big')
   elif op==0x51:at=pop();grow(at+32);stack.append(int.from_bytes(memory[at:at+32],'big'))
   elif op in [0x56,0x57]:
    dest=pop();take=op==0x56 or pop()!=0
    if take:require(ins.get(dest,(None,))[0]==0x5b,'Actual destination');nxt=dest
   elif op==0x5b:pass
   elif op in [0xf3,0xfd]:
    at,count=pop(),pop()
    if count:grow(at+count)
    terminal=(op==0xfd,bytes(memory[at:at+count]));require(index==len(logs)-1,'Physical terminal not last')
   else:raise RuntimeError(('Unmodeled reached opcode',pc,op))
   pc=nxt
  require(terminal is not None,'Missing actual terminal');require(terminal==(t['trace']['failed'],bytes.fromhex(t['trace']['returnValue'].removeprefix('0x'))),'Wrong physical terminal bytes')
  passed=terminal==(failed,expected);require(r['passed']==passed,'Reported result drift')
  if not passed:wrong.append(r['ordinal'])
  paths.setdefault(r['name'],set()).add(tuple(s['pc'] for s in logs))
 if a.expect_fault:require(4 in wrong and all(rows[i]['name']=='Positive' for i in wrong),'Matching fixed positive semantic witness')
 else:require(not wrong,'Wrong baseline outcome')
 require(all(len(v)==1 for v in paths.values()),'Changed constant control branch inventory')
 print('PASS development only:31 complete independently replayed physical log2 stack/byte-memory paths; wrong semantic receipts='+str(len(wrong))+'; native coverage remains open')
if __name__=='__main__':main()
