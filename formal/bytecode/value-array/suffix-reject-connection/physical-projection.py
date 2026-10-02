#!/usr/bin/env python3
"""Independently replay every exact full invalid suffix execution to error bytes."""
import argparse,datetime,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def graph(paths):
 closed=set()
 def visit(p):
  p=p.resolve();assert p.is_relative_to(ROOT)and p.is_file()
  if p in closed:return
  closed.add(p)
  for inc in re.findall(r'^include "([^"]+)"',p.read_text(),re.M):visit(p.parent/inc)
 for p in paths:visit(p)
 return closed
def stack(row):return [int(v,16)for v in row['stack']]
def memory(row):return bytes.fromhex(''.join(v.removeprefix('0x')for v in row['memory']))
def expand(mem,end):return mem+b'\0'*max(0,((end+31)//32)*32-len(mem))
def replay(code,data,logs,start,prefix,packet,starts):
 """Concrete opcode rules; no generated state mappings supply expected states."""
 pc=logs[start]['pc'];s=stack(logs[start]);mem=memory(logs[start]);peak=len(s)
 for index in range(start,len(logs)):
  row=logs[index];assert row['depth']==1 and row['pc']==pc and stack(row)==s and memory(row)==mem,(index,'full reconstructed physical state');assert s[:len(prefix)]==prefix and len(s)<=1024 and all(0<=v<MOD for v in s)
  op=code[pc];width=op-95 if 96<=op<=127 else 0;nxt=pc+1+width
  if op==91:pass
  elif op==95:s.append(0)
  elif 96<=op<=127:s.append(int.from_bytes(code[pc+1:nxt],'big'))
  elif 128<=op<=143:assert len(s)>=op-127;s.append(s[-(op-127)])
  elif 144<=op<=159:k=op-143;assert len(s)>=k+1;s[-1],s[-1-k]=s[-1-k],s[-1]
  elif op==80:s.pop()
  elif op in(1,2,3,4,0x10,0x11,0x14,0x16,0x17):
   a,z=s.pop(),s.pop()
   if op==1:value=(a+z)%MOD
   elif op==2:value=(a*z)%MOD
   elif op==3:value=(a-z)%MOD
   elif op==4:value=0 if z==0 else a//z
   elif op==0x10:value=int(a<z)
   elif op==0x11:value=int(a>z)
   elif op==0x14:value=int(a==z)
   elif op==0x16:value=a&z
   else:value=a|z
   s.append(value)
  elif op==0x15:s.append(int(s.pop()==0))
  elif op==0x1a:a,z=s.pop(),s.pop();s.append(0 if a>=32 else(z>>(248-8*a))&255)
  elif op==0x1b:a,z=s.pop(),s.pop();s.append(0 if a>=256 else(z<<a)%MOD)
  elif op==0x35:off=s.pop();s.append(int.from_bytes((data[off:off+32]+b'\0'*32)[:32],'big'))
  elif op==0x51:off=s.pop();mem=expand(mem,off+32);s.append(int.from_bytes(mem[off:off+32],'big'))
  elif op==0x52:off,value=s.pop(),s.pop();mem=expand(mem,off+32);mem=mem[:off]+value.to_bytes(32,'big')+mem[off+32:]
  elif op in(0x56,0x57):
   dest=s.pop();taken=True if op==0x56 else s.pop()!=0
   if taken:assert dest in starts and code[dest]==91;nxt=dest
  elif op==0xfd:
   off,size=s.pop(),s.pop();assert index==len(logs)-1 and row['op']=='REVERT';mem=expand(mem,off+size);assert mem[off:off+size]==packet;return index-start+1,peak
  else:raise AssertionError(('unsupported reached concrete opcode',pc,op))
  assert len(s)<=1024;peak=max(peak,len(s));pc=nxt
 raise AssertionError('No complete terminal error')
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--output',type=Path,required=True);args=ap.parse_args();out=args.output.resolve();assert not out.exists()
 scope=json.loads((HERE/'scope.json').read_text());closed=graph([ROOT/p for p in scope['selectedSources']]);sources=closed|{p for folder in {p.parent for p in closed}|{HERE}for p in folder.iterdir()if p.is_file()};hashes={str(p.relative_to(ROOT)):sha(p)for p in sorted(sources)}
 receipt=HERE.parent/'physical-descriptor-errors/development/receipts-v2';m=json.loads((receipt/'manifest.json').read_text());assert m['completedAt']and m['status']=='development-physical-passed-not-retained'and m['concreteFixtures']==60 and m['inputsUnchanged']and m['concreteToolsUnchanged']and all(c['passed']and c['exitCode']==0 for c in m['checks'])
 for p,h in m['sourceSha256'].items():assert sha(ROOT/p)==sha(receipt/'source-snapshot'/p)==h
 for p,h in m['evidenceSha256'].items():assert sha(receipt/p)==h
 tools=m['concreteToolchain']
 for key in ['hardhatEntry','edrEntry','nativeBinding']:assert sha(Path(tools[key]))==tools[key+'Sha256']
 assert sha(Path(tools['nodeExecutable']))==tools['nodeSha256']and sha(ROOT/'pnpm-lock.yaml')==tools['lockfileSha256']
 pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256'];code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(code).hexdigest()==pin;starts=set();pc=0
 while pc<len(code):starts.add(pc);op=code[pc];pc+=1+(op-95 if 96<=op<=127 else 0)
 fixtures=[];count=total=peak=0;reasons={name:0 for name in ['atLimit','wrongClose','wide','zero']};operations=set()
 for file in sorted((receipt/'evm-traces').glob('*.json')):
  doc=json.loads(file.read_text())
  if 'trace'not in doc:continue
  f=doc['fixture'];trace=doc['trace'];logs=trace['structLogs'];data=bytes.fromhex(f['data'][2:]);assert doc['runtimeSha256']==pin and logs[0]['pc']==0 and trace['failed']and trace['returnValue'].removeprefix('0x')==f['expected'];rows=[]
  for i,row in enumerate(logs):
   if row['pc']!=14279:continue
   actual=stack(row);prefix=actual[:-8];ret,off,length,p,limit,end,dyn,words=actual[-8:];assert off<2**64 and end<=limit<=length<2**64
   byte=lambda pos:data[off+pos]if off+pos<len(data)else 0
   if end==limit or byte(end)!=91:continue
   assert p<end<limit and dyn<=1 and words>=1 and (dyn==0 or words==1)and words<=0xffffffff*(end-p)and len(prefix)<=1004
   q=end+1;k=0;iterations=[]
   while q<limit and 48<=byte(q)<=57 and k<=0xffffffff:iterations.append(dict(position=q,before=k,digit=byte(q)-48));k=10*k+byte(q)-48;q+=1
   assert k<=0xffffffff*10+9 and words*k<MOD;nextDyn=1 if q==end+1 else dyn;nextWords=1 if q==end+1 else words if dyn else words*k
   reason='atLimit'if q==limit else'wrongClose'if byte(q)!=93 else'wide'if k>0xffffffff or nextWords>0xffffffff else'zero'if k==0 and q!=end+1 else None
   if reason is None:continue
   packet=bytes.fromhex('9a67d126')+q.to_bytes(32,'big');assert packet.hex()==f['expected']and f['position']==q
   steps,maxStack=replay(code,data,logs,i,prefix,packet,starts);count+=1;total+=steps;peak=max(peak,maxStack);reasons[reason]+=1;operations.add(f['operation']);rows.append(dict(startIndex=i,terminalIndex=len(logs)-1,completeInstructions=steps,prefixWords=len(prefix),maximumActualStack=maxStack,opening=end,decimalStop=q,decimal=k,updatedDynamic=nextDyn,updatedWords=nextWords,independentReason=reason,iterations=iterations))
  fixtures.append(dict(name=f['name'],trace=str(file.relative_to(ROOT)),traceSha256=sha(file),calls=rows))
 assert len(fixtures)==60 and count==24 and reasons==dict(atLimit=4,wrongClose=6,wide=8,zero=6)and operations=={'packArray','unpackArray'}and all(sha(ROOT/p)==h for p,h in hashes.items());out.mkdir(parents=True);result=dict(status='development-physical-complete-invalid-suffix-connections-passed-not-retained',completedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),historicalManifest=str((receipt/'manifest.json').relative_to(ROOT)),historicalManifestSha256=sha(receipt/'manifest.json'),runtimeSha256=pin,sourceSha256=hashes,inputsUnchanged=True,fixtureCount=len(fixtures),checkedCompleteConnections=count,checkedSpanInstructions=total,maximumActualStack=peak,byIndependentReason=reasons,fixtures=fixtures,scope='Every independently invalid suffix among 60 complete PC-zero error receipts: exact opening, independently constructed earliest decimal stop and fitting footprint, independently reconstructed actual opcode/PC/full stack/full physical memory at every instruction through exact InvalidTypeDescriptor(q) REVERT. No generated state map supplies the replay expectations. All other recursive rejecting grammar, public prefix/caller admission, codecs, universal native/fault/final retention remain open. No public credit.',assumptions=['The concrete opcode replay and physical EDR interpreter/toolchain are reviewed interpretation assumptions; they are pinned and checked but are not native universal proofs.','Complete raw calldata fixtures start at PC zero; the replay itself starts at the admitted suffix frame whose lower stack and original span/resource bounds are checked. Public prefix/codec composition remains open.']);(out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],count,total,reasons)
if __name__=='__main__':main()
