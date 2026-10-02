#!/usr/bin/env python3
"""Independent complete physical signed modular stack/byte-memory replay; no native credit."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];M=1<<256;H=M//2
OPS={0x02:'MUL',0x06:'MOD',0x08:'ADDMOD',0x09:'MULMOD',0x13:'SGT',0x18:'XOR',0x1d:'SAR',0x01:'ADD',0x03:'SUB',0x04:'DIV',0x10:'LT',0x11:'GT',0x12:'SLT',0x14:'EQ',0x15:'ISZERO',0x16:'AND',0x17:'OR',0x19:'NOT',0x1a:'BYTE',0x1b:'SHL',0x1c:'SHR',0x34:'CALLVALUE',0x35:'CALLDATALOAD',0x36:'CALLDATASIZE',0x50:'POP',0x51:'MLOAD',0x52:'MSTORE',0x56:'JUMP',0x57:'JUMPI',0x5b:'JUMPDEST',0x5f:'PUSH0',0xf3:'RETURN',0xfd:'REVERT'}
OPS.update({0x5f+i:'PUSH'+str(i) for i in range(1,33)});OPS.update({0x7f+i:'DUP'+str(i) for i in range(1,17)});OPS.update({0x8f+i:'SWAP'+str(i) for i in range(1,17)})
def read(p):return json.loads(p.read_text())
def require(ok,msg):
 if not ok:raise RuntimeError(msg)
def main():
 p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('--runtime',type=Path);p.add_argument('--expect-fault',action='store_true');a=p.parse_args();out=a.directory
 code=a.runtime.read_bytes() if a.runtime else bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();ins={};pc=0
 while pc<len(code):
  op=code[pc];width=op-0x5f if 0x60<=op<=0x7f else 0;ins[pc]=(op,pc+width+1,int.from_bytes(code[pc+1:pc+width+1].ljust(width,b'\0'),'big'));pc+=width+1
 panic=bytes.fromhex('4e487b71')+(18).to_bytes(32,'big');rows=read(out/'results.json');require(len(rows)==1476 and len({(r['name'],r['ordinal']) for r in rows})==1476,'Fixture inventory')
 wrong=[];paths={}
 for r in rows:
  t=read(out/r['trace']);data=bytes.fromhex(t['data'][2:]);value=int(t['value'],16);logs=t['trace']['structLogs'];require(t['runtimeSha256']==digest and t['candidate']==bool(a.runtime),'Runtime identity')
  def load(at):return int.from_bytes(data[at:at+32].ljust(32,b'\0'),'big') if at<len(data) else 0
  family=next(n for n in ['AddModS','MulModS'] if r['name'].startswith(n))
  selector={'AddModS':'289b860c','MulModS':'3daa08a5'}[family]
  if value or len(data)<100:expected=b'';failed=True
  else:
   require(data[:4].hex()==selector,'Selector');signed=lambda x:x if x<H else x-M
   x,y,d=signed(load(4)),signed(load(36)),signed(load(68));failed=d==0
   intermediate=x+y if family=='AddModS' else x*y
   remainder=0 if failed else (abs(intermediate)%abs(d))*(-1 if intermediate<0 else 1)
   expected=panic if failed else (remainder%M).to_bytes(32,'big')
   require([str(x),str(y),str(d)]==[t['a'],t['b'],t['modulus']],'Mathematical operand drift')
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
   elif op in [0x08,0x09]:
    left,right,modulus=pop(),pop(),pop();stack.append(0 if modulus==0 else ((left+right) if op==0x08 else (left*right))%modulus)
   elif op in [0x01,0x02,0x03,0x04,0x06,0x10,0x11,0x12,0x13,0x14,0x16,0x17,0x18,0x1a,0x1b,0x1c,0x1d]:
    left,right=pop(),pop();signed=lambda x:x if x<H else x-M
    result={0x02:lambda:(left*right)%M,0x06:lambda:0 if right==0 else left%right,0x13:lambda:int(signed(left)>signed(right)),0x18:lambda:left^right,0x1d:lambda:(signed(right)>>min(left,256))%M,0x01:lambda:(left+right)%M,0x03:lambda:(left-right)%M,0x04:lambda:0 if right==0 else left//right,0x10:lambda:int(left<right),0x11:lambda:int(left>right),0x12:lambda:int(signed(left)<signed(right)),0x14:lambda:int(left==right),0x16:lambda:left&right,0x17:lambda:left|right,0x1a:lambda:0 if left>=32 else (right>>(8*(31-left)))&255,0x1b:lambda:0 if left>=256 else (right<<left)%M,0x1c:lambda:0 if left>=256 else right>>left}[op]();stack.append(result)
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
  if not passed:wrong.append((r['name'],r['ordinal']))
  paths.setdefault(r['name'],set()).add(tuple(s['pc'] for s in logs))
 if a.expect_fault:
  baseline=bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:])
  diff=[(i,x,y) for i,(x,y) in enumerate(zip(baseline,code)) if x!=y]
  require(len(code)==len(baseline) and diff in [[(3512,8,9)],[(4107,9,8)]],'Wrong exact one-byte opcode candidate')
  affected='AddModS' if diff[0][0]==3512 else 'MulModS'
  require((affected,514) in wrong and all(n==affected for n,i in wrong),'No matching123/456/7 witness or unrelated false failure')
 else:require(not wrong,'Wrong baseline outcome')
 summary={n:[list(path) for path in sorted(v)] for n,v in paths.items()}
 (out/'observed-paths.json').write_text(json.dumps(summary,indent=2)+'\n')
 print('PASS development only:1476 complete independently replayed physical signed modular stack/byte-memory paths; observed path counts='+str({n:len(v) for n,v in paths.items()})+'; wrong receipts='+str(len(wrong))+'; native coverage remains open')
if __name__=='__main__':main()
