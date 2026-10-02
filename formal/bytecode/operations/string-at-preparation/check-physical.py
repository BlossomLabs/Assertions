#!/usr/bin/env python3
"""Independent UTF8 stringAt opcode/complete-stack/expanded-byte-memory replay; no universal proof credit."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];M=1<<256;H=M//2
OPS={0x5a:'GAS',0xfa:'STATICCALL',0x3d:'RETURNDATASIZE',0x05:'SDIV',0x07:'SMOD',0x0a:'EXP',0x5e:'MCOPY',0x20:'KECCAK256',0x37:'CALLDATACOPY',0x02:'MUL',0x06:'MOD',0x08:'ADDMOD',0x09:'MULMOD',0x13:'SGT',0x18:'XOR',0x1d:'SAR',0x01:'ADD',0x03:'SUB',0x04:'DIV',0x10:'LT',0x11:'GT',0x12:'SLT',0x14:'EQ',0x15:'ISZERO',0x16:'AND',0x17:'OR',0x19:'NOT',0x1a:'BYTE',0x1b:'SHL',0x1c:'SHR',0x34:'CALLVALUE',0x35:'CALLDATALOAD',0x36:'CALLDATASIZE',0x50:'POP',0x51:'MLOAD',0x52:'MSTORE',0x53:'MSTORE8',0x56:'JUMP',0x57:'JUMPI',0x5b:'JUMPDEST',0x5f:'PUSH0',0xf3:'RETURN',0xfd:'REVERT'}
OPS.update({0x5f+i:'PUSH'+str(i) for i in range(1,33)});OPS.update({0x7f+i:'DUP'+str(i) for i in range(1,17)});OPS.update({0x8f+i:'SWAP'+str(i) for i in range(1,17)})
def read(p):return json.loads(p.read_text())
def require(ok,msg):
 if not ok:raise RuntimeError(msg)
def invalid_utf8(payload):
 # Unit grammar intervals: (lead low/high, width, second low/high).
 table=[(194,223,2,128,191),(224,224,3,160,191),(225,236,3,128,191),(237,237,3,128,159),(238,239,3,128,191),(240,240,4,144,191),(241,243,4,128,191),(244,244,4,128,143)]
 i=0
 while i<len(payload):
  if payload[i]<128:i+=1;continue
  group=next((g for g in table if g[0]<=payload[i]<=g[1]),None)
  if group is None:return i
  width,low,high=group[2:]
  if i+width>len(payload):return i
  if not low<=payload[i+1]<=high:return i+1
  for j in range(2,width):
   if not 128<=payload[i+j]<=191:return i+j
  i+=width
 return None
def main():
 p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('--runtime',type=Path);p.add_argument('--expected-count',type=int,default=301);p.add_argument('--expect-semantic-fault',action='store_true');args=p.parse_args();out=args.directory
 code=args.runtime.read_bytes() if args.runtime else bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();ins={};pc=0
 while pc<len(code):
  op=code[pc];width=op-0x5f if 0x60<=op<=0x7f else 0;ins[pc]=(op,pc+width+1,int.from_bytes(code[pc+1:pc+width+1].ljust(width,b'\0'),'big'));pc+=width+1
 rows=read(out/'results.json');require(len(rows)==args.expected_count and {r['ordinal'] for r in rows}==set(range(args.expected_count)),'Fixture inventory')
 wrong=[];paths={}
 for r in rows:
  t=read(out/r['trace']);data=bytes.fromhex(t['data'][2:]);value=int(t['value'],0);logs=t['trace']['structLogs'];require(t['runtimeSha256']==digest,'Runtime identity')
  def load(at):return int.from_bytes(data[at:at+32].ljust(32,b'\0'),'big') if at<len(data) else 0
  size=len(data);reason='Nonzero' if value else 'Short' if size<4 else 'Args' if size<68 else None;expected=b''
  if reason is None:
   require(data[:4].hex()=='a1bc2139','Compiler-bound stringAt selector');offset=load(4);word=load(36);signed=word if word<H else word-M
   if offset>=1<<64:reason='OffsetBound'
   elif offset+36>size:reason='LengthWindow'
   else:
    length=load(offset+4)
    if length>=1<<64:reason='LengthBound'
    elif offset+36+length>size:reason='PayloadWindow'
    else:
     payload=data[offset+36:offset+36+length];bad=invalid_utf8(payload)
     if bad is not None:reason='InvalidUtf8';expected=bytes.fromhex('41972036')+bad.to_bytes(32,'big')
     elif not -length<=signed<length:reason='InvalidByteIndex';expected=bytes.fromhex('df75cbae')+word.to_bytes(32,'big')+length.to_bytes(32,'big')
     else:
      position=length+signed if signed<0 else signed;byte=payload[position]
      if byte>=128:reason='InvalidUtf8';expected=bytes.fromhex('41972036')+position.to_bytes(32,'big')
      else:reason='Success';expected=(32).to_bytes(32,'big')+(1).to_bytes(32,'big')+bytes([byte])+bytes(31)
  failed=reason!='Success'
  require(t['model']['expected']==r['expected']==expected.hex() and r['reason']==reason,'Independent byte grammar/raw/index outcome drift')
  pc=0;stack=[];memory=bytearray();terminal=None;returndata=b'';calls=[]
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
   elif op in [0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x0a,0x10,0x11,0x12,0x13,0x14,0x16,0x17,0x18,0x1a,0x1b,0x1c,0x1d]:
    left,right=pop(),pop();signed=lambda x:x if x<H else x-M
    quotient=lambda:0 if right==0 else ((abs(signed(left))//abs(signed(right)))*(1 if (signed(left)<0)==(signed(right)<0) else -1))%M
    result={0x05:quotient,0x07:lambda:0 if right==0 else ((abs(signed(left))%abs(signed(right)))*(-1 if signed(left)<0 else 1))%M,0x0a:lambda:pow(left,right,M),0x02:lambda:(left*right)%M,0x06:lambda:0 if right==0 else left%right,0x13:lambda:int(signed(left)>signed(right)),0x18:lambda:left^right,0x1d:lambda:(signed(right)>>min(left,256))%M,0x01:lambda:(left+right)%M,0x03:lambda:(left-right)%M,0x04:lambda:0 if right==0 else left//right,0x10:lambda:int(left<right),0x11:lambda:int(left>right),0x12:lambda:int(signed(left)<signed(right)),0x14:lambda:int(left==right),0x16:lambda:left&right,0x17:lambda:left|right,0x1a:lambda:0 if left>=32 else (right>>(8*(31-left)))&255,0x1b:lambda:0 if left>=256 else (right<<left)%M,0x1c:lambda:0 if left>=256 else right>>left}[op]();stack.append(result)
   elif op==0x5a:
    require(s['gasCost']==2 and 2<=s['gas']<M,'Reached GAS observation');stack.append(s['gas']-2)
   elif op==0x3d:stack.append(len(returndata))
   elif op==0xfa:
    gas,target,inputAt,inputCount,outputAt,outputCount=pop(),pop(),pop(),pop(),pop(),pop()
    require(target==5 and inputCount==192 and outputCount==32,'Exact MODEXP call packet shape')
    grow(max(inputAt+inputCount,outputAt+outputCount));packet=bytes(memory[inputAt:inputAt+inputCount]);words=[int.from_bytes(packet[i:i+32],'big') for i in range(0,192,32)]
    require(words[:3]==[32,32,32] and words[5]>0,'Exact fitting MODEXP lengths/modulus')
    returndata=pow(words[3],words[4],words[5]).to_bytes(32,'big');memory[outputAt:outputAt+32]=returndata;stack.append(1)
    calls.append({'pc':pc,'base':words[3],'exponent':words[4],'modulus':words[5],'returned':returndata.hex()})
   elif op==0x37:
    at,source,count=pop(),pop(),pop()
    if count:grow(at+count);memory[at:at+count]=data[source:source+count].ljust(count,b'\0')
   elif op==0x5e:
    at,sourceAt,count=pop(),pop(),pop()
    if count:
     grow(max(at+count,sourceAt+count));copied=bytes(memory[sourceAt:sourceAt+count]);memory[at:at+count]=copied
   elif op==0x52:at,v=pop(),pop();grow(at+32);memory[at:at+32]=v.to_bytes(32,'big')
   elif op==0x53:at,v=pop(),pop();grow(at+1);memory[at]=v&255
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
  passed=terminal==(failed,expected);require(r['passed']==passed and (passed or args.expect_semantic_fault) and r['reason']==reason,'Independent intended outcome/physical result drift');require(not calls,'Case-fold unexpectedly reached an external call')
  if not passed:wrong.append((reason,r['ordinal']))
  paths.setdefault(reason,set()).add(tuple(s['pc'] for s in logs))
 if args.expect_semantic_fault:
  require(args.runtime is not None and wrong and all(reason=='Success' for reason,_ in wrong),'Missing complete physical UTF8 stringAt contradiction')
  canonical=bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);changed=[i for i,(a,b) in enumerate(zip(code,canonical)) if a!=b]
  require(len(code)==len(canonical) and changed==[18907] and canonical[changed[0]]==0x5e and code[changed[0]]==0x37,'Not one-byte same-arity MCOPY-to-CALLDATACOPY fault')
 else:require(not wrong,'Unexpected physical outcome contradiction')
 summary={n:[list(path) for path in sorted(v)] for n,v in paths.items()}
 (out/'observed-paths.json').write_text(json.dumps(summary,indent=2)+'\n')
 require({r['reason'] for r in rows}=={'Success','Nonzero','Short','Args','OffsetBound','LengthWindow','LengthBound','PayloadWindow','InvalidUtf8','InvalidByteIndex'},'Finite raw rejection inventory incomplete')
 print('PASS '+str(len(rows))+' complete UTF8 stringAt opcode/stack/expanded-memory paths; '+str(len(wrong))+' intended semantic contradictions. Native/universal/retained public proof remains pending.')
if __name__=='__main__':main()
