#!/usr/bin/env python3
"""Independent exact-byte dispatcher replay, no known-body or native credit."""
import argparse,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
OPS={0x10:'LT',0x11:'GT',0x14:'EQ',0x15:'ISZERO',0x1c:'SHR',0x34:'CALLVALUE',0x35:'CALLDATALOAD',0x36:'CALLDATASIZE',0x50:'POP',0x52:'MSTORE',0x57:'JUMPI',0x5b:'JUMPDEST',0x5f:'PUSH0',0xf3:'RETURN',0xfd:'REVERT'}
for i in range(1,33):OPS[0x5f+i]='PUSH'+str(i)
for i in range(1,17):OPS[0x7f+i]='DUP'+str(i)
def require(ok,msg):
 if not ok:raise SystemExit(msg)
def read(p):return json.loads(p.read_text())
def main():
 p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('--runtime',type=Path);p.add_argument('--expect-unknown-faults',action='store_true');a=p.parse_args();folder=a.directory
 inv=read(ROOT/'formal/bytecode/operations/inventory.json');methods=inv['compilerIdentity']['methodIdentifiers'];known={int(s,16):signature for signature,s in methods.items()}
 code=a.runtime.read_bytes() if a.runtime else bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);sha=hashlib.sha256(code).hexdigest()
 require(len(code)==inv['runtimeBytes'],'Runtime length drift')
 if not a.runtime:require(sha==inv['runtimeSha256'],'Canonical runtime drift')
 bounds={};pc=0
 while pc<len(code):
  op=code[pc];width=op-95 if 96<=op<=127 else 0;bounds[pc]=(op,pc+1+width,int.from_bytes(code[pc+1:pc+1+width].ljust(width,b'\0'),'big'));pc+=1+width
 changes=[i for i,(x,y) in enumerate(zip(code,bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]))) if x!=y] if a.runtime else [];require(not a.runtime or len(changes)==1 and code[changes[0]]==0xf3 and bounds[changes[0]][0]==0xf3,'Unexpected candidate');mutationPc=changes[0] if changes else None
 rows=read(folder/'results.json');require(len(rows)==116,'Wrong fixture inventory');counts={};seen=set();unknownLeaves=set();faults=0
 for row in rows:
  t=read(folder/row['trace']);require(t['runtimeSha256']==sha and t['candidate']==bool(a.runtime),'Runtime identity mismatch');data=bytes.fromhex(t['data'][2:]);value=int(t['value'],16);logs=t['trace']['structLogs'];prefix=logs[:t['prefixLength']];require(prefix and prefix[0]['pc']==0 and all(s['depth']==1 for s in logs),'Incomplete/nonlocal trace');kind=t['kind'];counts[kind]=counts.get(kind,0)+1
  selector=int.from_bytes(data[:4],'big') if len(data)>=4 else None
  if kind=='known':
   require(value==0 and len(data)>=4 and selector in known and t['signature']==known[selector],'Known ABI signature mismatch');require(selector not in seen,'Duplicate known selector');seen.add(selector);wrapper=inv['selectorToDeclaredEntryPc'][str(selector)];require(t['wrapper']==wrapper and prefix[-1]['pc']==wrapper,'Wrong actual wrapper destination')
  elif kind=='unknown':
   require(value==0 and len(data)>=4 and selector not in known,'Known selector mislabeled unknown');unknownLeaves.add(logs[-1]['pc'])
  elif kind=='short':require(value==0 and len(data)<4,'Wrong short admission')
  elif kind=='nonzero':require(value>0,'Wrong nonpayable admission')
  else:raise SystemExit('Unknown fixture kind')
  pc=0;stack=[];memory=bytearray();terminal=None
  for i,log in enumerate(prefix):
   require(log['pc']==pc and pc in bounds,'Missing/non-boundary instruction');op,nxt,imm=bounds[pc];require(log['op']==OPS.get(op),'Wrong runtime opcode');actualStack=[int(s.removeprefix('0x'),16) for s in log['stack']];actualMemory=bytes.fromhex(''.join(s.removeprefix('0x') for s in log['memory']));require(actualStack==stack and actualMemory==memory,'Physical dispatcher state differs from independent replay');require(len(stack)<=3 and len(memory)<=96,'Reached resource-bound drift')
   if kind=='known' and i==len(prefix)-1:
    require(op==0x5b and stack==[selector] and memory==bytes(95)+b'\x80','Wrong physical wrapper frame');break
   if op==0x5f or 0x60<=op<=0x7f:stack.append(imm)
   elif op==0x34:stack.append(value)
   elif op==0x36:stack.append(len(data))
   elif op==0x35:
    off=stack.pop();stack.append(int.from_bytes(data[off:off+32].ljust(32,b'\0'),'big'))
   elif op==0x1c:
    amount=stack.pop();x=stack.pop();stack.append(0 if amount>=256 else x>>amount)
   elif op==0x80:stack.append(stack[-1])
   elif op==0x50:stack.pop()
   elif op==0x15:stack.append(int(stack.pop()==0))
   elif op in [0x10,0x11,0x14]:
    x,y=stack.pop(),stack.pop();stack.append(int(x<y if op==0x10 else x>y if op==0x11 else x==y))
   elif op==0x52:
    off,x=stack.pop(),stack.pop();extent=((off+32+31)//32)*32;memory.extend(bytes(max(0,extent-len(memory))));memory[off:off+32]=x.to_bytes(32,'big')
   elif op==0x57:
    dest,condition=stack.pop(),stack.pop()
    if condition:require(bounds.get(dest,(None,))[0]==0x5b,'Invalid taken destination');nxt=dest
   elif op==0x5b:pass
   elif op in [0xfd,0xf3]:
    off,length=stack.pop(),stack.pop();require((off,length)==(0,0) and i==len(prefix)-1,'Wrong raw terminal');terminal=op
   else:raise SystemExit('Unsupported reached dispatcher opcode')
   pc=nxt
  if kind!='known':
   require(t['prefixLength']==len(logs) and memory==bytes(95)+b'\x80','Raw rejection trace incomplete');actual=bytes.fromhex(t['trace']['returnValue'].removeprefix('0x'));require(actual==b'' and t['trace']['failed']==(terminal==0xfd),'Wrong physical terminal receipt')
   wrong=terminal!=0xfd
   if wrong:faults+=1
   require(wrong==(a.expect_unknown_faults and logs[-1]['pc']==mutationPc),'Unexpected raw rejection outcome');require(row['passed']==(not wrong),'Recorded pass mismatch')
  else:require(row['passed'],'Known prefix unexpectedly failed')
 require(counts=={'known':92,'unknown':16,'short':4,'nonzero':4} and seen==set(known),'Routing scope mismatch')
 require(len(unknownLeaves)==16,'Missing actual fallback leaf');require(faults==(5 if a.expect_unknown_faults else 0),'Semantic fault inventory mismatch')
 print('PASS development only:92 independent physical exact-wrapper prefixes,24 raw rejection receipts'+(' including5 intended fallback/short receipt faults' if faults else '')+'; no known-body or native coverage claim')
if __name__=='__main__':main()
