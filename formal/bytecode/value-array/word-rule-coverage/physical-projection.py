#!/usr/bin/env python3
"""Independently reconstruct all reached wordRule calls across expanded canonical-word receipts."""
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
def classify(data,offset,p,limit):
 """Independent finite grammar classifier; never reads EVM logs or expected errors."""
 assert 0<=p<=limit<2**64
 byte=lambda pos:data[offset+pos]if offset+pos<len(data)else 0
 allowed=lambda b:48<=b<=57 or 97<=b<=122
 if p==limit:return dict(rejected=True,position=p,problem=dict(kind='AtLimit'))
 if byte(p)==40:
  previous=[];cursor=p+1;total=dynamic=0;depth=1
  while True:
   child=classify(data,offset,cursor,limit)
   if child['rejected']:return dict(rejected=True,position=child['position'],problem=dict(kind='Child',previous=previous,inner=child['problem']))
   total+=child['words'];dynamic|=child['dynamic'];depth=max(depth,1+child['tupleDepth']);assert total<=0xffffffff*(child['end']-p-len(previous)-1)and total<MOD
   end=child['end']
   if end==limit or byte(end)not in[44,41]:return dict(rejected=True,position=end,problem=dict(kind='Separator',previous=previous,last=child))
   previous.append(child)
   if byte(end)==44:cursor=end+1;continue
   end+=1;words=1 if dynamic else total;base=dict(kind='tuple',children=previous,tupleDepth=depth);break
 else:
  end=p
  while end<limit and allowed(byte(end)):end+=1
  if end==p:return dict(rejected=True,position=p,problem=dict(kind='BadName'))
  dynamic=int(data[offset+p:offset+end]in[b'bytes',b'string']);words=1;depth=0;base=dict(kind='named',nameEnd=end,tupleDepth=0)
 baseShape=[end,dynamic,words];closings=[]
 while end<limit and byte(end)==91:
  q=end+1;k=0
  while q<limit and allowed(byte(q))and 48<=byte(q)<=57 and k<=0xffffffff:k=10*k+byte(q)-48;q+=1
  assert k<=0xffffffff*10+9 and words*k<MOD
  nextDyn=1 if q==end+1 else dynamic;nextWords=1 if q==end+1 else words if dynamic else words*k
  reason='atLimit'if q==limit else'wrongClose'if byte(q)!=93 else'wide'if k>0xffffffff or nextWords>0xffffffff else'zero'if k==0 and q!=end+1 else None
  if reason:return dict(rejected=True,position=q,problem=dict(kind='NamedSuffix'if base['kind']=='named'else'TupleSuffix',base=base,baseShape=baseShape,closings=closings,opening=end,decimalStop=q,decimal=k,reason=reason))
  closings.append(q);end=q+1;dynamic=nextDyn;words=nextWords
 assert p<end<=limit and 1<=words<=0xffffffff*(end-p)and words<MOD
 return dict(rejected=False,start=p,end=end,dynamic=dynamic,words=words,tupleDepth=depth,base=base,suffixes=closings)
def witness_budget(prefix,problem):
 assert prefix<=1004
 kind=problem['kind']
 if kind=='Child':
  for child in problem['previous']:assert prefix+13*(1+child['tupleDepth'])<=1004
  return max(prefix,witness_budget(prefix+13,problem['inner']))
 if kind=='Separator':
  for child in problem['previous']+[problem['last']]:assert prefix+13*(1+child['tupleDepth'])<=1004
  return prefix+13*(1+max(c['tupleDepth']for c in problem['previous']+[problem['last']]))
 if kind=='TupleSuffix':
  for child in problem['base']['children']:assert prefix+13*(1+child['tupleDepth'])<=1004
  return prefix+13*problem['base']['tupleDepth']
 return prefix
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
  elif op in(1,2,3,4,6,0x10,0x11,0x14,0x16,0x17):
   a,z=s.pop(),s.pop()
   if op==1:value=(a+z)%MOD
   elif op==2:value=(a*z)%MOD
   elif op==3:value=(a-z)%MOD
   elif op==4:value=0 if z==0 else a//z
   elif op==6:value=0 if z==0 else a%z
   elif op==0x10:value=int(a<z)
   elif op==0x11:value=int(a>z)
   elif op==0x14:value=int(a==z)
   elif op==0x16:value=a&z
   else:value=a|z
   s.append(value)
  elif op==0x15:s.append(int(s.pop()==0))
  elif op==0x19:s.append(MOD-1-s.pop())
  elif op==0x1a:a,z=s.pop(),s.pop();s.append(0 if a>=32 else(z>>(248-8*a))&255)
  elif op==0x1b:a,z=s.pop(),s.pop();s.append(0 if a>=256 else(z<<a)%MOD)
  elif op==0x1c:a,z=s.pop(),s.pop();s.append(0 if a>=256 else z>>a)
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
def replay_success(code,data,logs,start,end,prefix,expected,starts,terminal_pc):
 """Concrete opcode rules; no generated state mappings supply expected states."""
 pc=logs[start]['pc'];s=stack(logs[start]);mem=memory(logs[start]);peak=len(s)
 for index in range(start,end):
  row=logs[index];assert row['depth']==1 and row['pc']==pc and stack(row)==s and memory(row)==mem,(index,'full reconstructed physical state');assert s[:len(prefix)]==prefix and len(s)<=1024 and all(0<=v<MOD for v in s)
  op=code[pc];width=op-95 if 96<=op<=127 else 0;nxt=pc+1+width
  if op==91:pass
  elif op==95:s.append(0)
  elif 96<=op<=127:s.append(int.from_bytes(code[pc+1:nxt],'big'))
  elif 128<=op<=143:assert len(s)>=op-127;s.append(s[-(op-127)])
  elif 144<=op<=159:k=op-143;assert len(s)>=k+1;s[-1],s[-1-k]=s[-1-k],s[-1]
  elif op==80:s.pop()
  elif op in(1,2,3,4,6,0x10,0x11,0x14,0x16,0x17):
   a,z=s.pop(),s.pop()
   if op==1:value=(a+z)%MOD
   elif op==2:value=(a*z)%MOD
   elif op==3:value=(a-z)%MOD
   elif op==4:value=0 if z==0 else a//z
   elif op==6:value=0 if z==0 else a%z
   elif op==0x10:value=int(a<z)
   elif op==0x11:value=int(a>z)
   elif op==0x14:value=int(a==z)
   elif op==0x16:value=a&z
   else:value=a|z
   s.append(value)
  elif op==0x15:s.append(int(s.pop()==0))
  elif op==0x19:s.append(MOD-1-s.pop())
  elif op==0x1a:a,z=s.pop(),s.pop();s.append(0 if a>=32 else(z>>(248-8*a))&255)
  elif op==0x1b:a,z=s.pop(),s.pop();s.append(0 if a>=256 else(z<<a)%MOD)
  elif op==0x1c:a,z=s.pop(),s.pop();s.append(0 if a>=256 else z>>a)
  elif op==0x35:off=s.pop();s.append(int.from_bytes((data[off:off+32]+b'\0'*32)[:32],'big'))
  elif op==0x51:off=s.pop();mem=expand(mem,off+32);s.append(int.from_bytes(mem[off:off+32],'big'))
  elif op==0x52:off,value=s.pop(),s.pop();mem=expand(mem,off+32);mem=mem[:off]+value.to_bytes(32,'big')+mem[off+32:]
  elif op in(0x56,0x57):
   dest=s.pop();taken=True if op==0x56 else s.pop()!=0
   if taken:assert dest in starts and code[dest]==91;nxt=dest
  elif op==0xfd:raise AssertionError('Admitted tuple child rejected during concrete replay')
  else:raise AssertionError(('unsupported reached concrete opcode',pc,op))
  assert len(s)<=1024;peak=max(peak,len(s));pc=nxt
 assert logs[end]['pc']==pc==terminal_pc and stack(logs[end])==s==expected and memory(logs[end])==mem==memory(logs[start]);return end-start,peak

def reference_rule(name):
 if name==b'address':return 1,160
 if name==b'bool':return 1,1
 if name==b'function':return 3,192
 m=re.fullmatch(rb'(uint|int)([1-9][0-9]*)',name)
 if m:
  width=int(m[2])
  if 8<=width<=248 and width%8==0:return (1 if m[1]==b'uint'else 2),width
 m=re.fullmatch(rb'bytes([1-9][0-9]*)',name)
 if m and 1<=int(m[1])<=31:return 3,int(m[1])*8
 return 0,0

def classify_word_rule(data,offset,start,limit):
 byte=lambda pos:data[offset+pos]if offset+pos<len(data)else 0
 allowed=lambda c:48<=c<=57 or 97<=c<=122
 nameEnd=start
 while nameEnd<limit and allowed(byte(nameEnd)):nameEnd+=1
 assert nameEnd>start and offset+nameEnd<=len(data)
 word=int.from_bytes((data[offset+start:offset+start+32]+b'\0'*32)[:32],'big')
 prefix=kind=bits=0
 if limit-start>6 and word>>200 in [int.from_bytes(b'uint256','big'),int.from_bytes(b'bytes32','big')]:prefix=7
 if word>>208==int.from_bytes(b'int256','big'):prefix=6
 if not prefix:
  if word>>200==int.from_bytes(b'address','big'):prefix=7;kind=1;bits=160
  if word>>192==int.from_bytes(b'function','big'):prefix=8;kind=3;bits=192
  if word>>224==int.from_bytes(b'bool','big'):prefix=4;kind=1;bits=1
 if not prefix:
  if word>>224==int.from_bytes(b'uint','big'):prefix=4;kind=1
  if word>>232==int.from_bytes(b'int','big'):prefix=3;kind=2
  if word>>216==int.from_bytes(b'bytes','big'):prefix=5;kind=3
 end=start+prefix
 if end>limit:end=start;kind=0
 if kind>0 and bits==0:
  while end<limit:
   digit=(byte(end)-48)%MOD
   if digit>9 or bits>99 or bits|digit==0:break
   bits=bits*10+digit;end+=1
  if kind==3:bits*=8
  if bits==0 or bits>248 or bits%8!=0:kind=0
 if end<limit and allowed(byte(end)):end=start
 if end==start:kind=0;end=nameEnd
 assert end==nameEnd and 0<=bits<MOD
 ruleKind,ruleBits=reference_rule(data[offset+start:offset+end]);assert kind==ruleKind and(kind==0 or bits==ruleBits)
 return end,kind,bits,data[offset+start:offset+end].decode('ascii')

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--output',type=Path,required=True);args=ap.parse_args();out=args.output.resolve();assert not out.exists()
 scope=json.loads((HERE/'scope.json').read_text());closed=graph([ROOT/p for p in scope['selectedSources']]);sources=closed|{p for folder in {p.parent for p in closed}|{HERE}for p in folder.iterdir()if p.is_file()};hashes={str(p.relative_to(ROOT)):sha(p)for p in sorted(sources)}
 histories=[('physical-pack-admission/development/raw-pack-receipts-v1',91),('physical-fixed-dynamic/development/receipts-v1',4),('physical-suffix-chains/development/receipts-v1',6),('physical-tuples/development/receipts-v1',8),('physical-tuple-first-dynamic/development/receipts-v1',2),('physical-descriptor-errors/development/receipts-v2',60),('physical-descriptor-start-errors/development/receipts-v1',8),('physical-canonical-words/development/receipts-v2',470)]
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);pin=hashlib.sha256(code).hexdigest();assert pin==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256'];starts=set();pc=0
 while pc<len(code):starts.add(pc);op=code[pc];pc+=1+(op-95 if 96<=op<=127 else 0)
 fixtures=[];manifests=[];count=total=peak=full=narrow=0;kinds={};names={}
 for relative,num in histories:
  receipt=HERE.parent/relative;m=json.loads((receipt/'manifest.json').read_text());assert m['completedAt']and m['status']=='development-physical-passed-not-retained'and m['concreteFixtures']==num and m['inputsUnchanged']and m['concreteToolsUnchanged']and all(c['passed']and c['exitCode']==0 for c in m['checks'])
  for p,h in m['sourceSha256'].items():assert sha(ROOT/p)==sha(receipt/'source-snapshot'/p)==h
  for p,h in m['evidenceSha256'].items():assert sha(receipt/p)==h
  tools=m['concreteToolchain']
  for key in ['hardhatEntry','edrEntry','nativeBinding']:assert sha(Path(tools[key]))==tools[key+'Sha256']
  assert sha(Path(tools['nodeExecutable']))==tools['nodeSha256']and sha(ROOT/'pnpm-lock.yaml')==tools['lockfileSha256'];manifests.append(dict(manifest=str((receipt/'manifest.json').relative_to(ROOT)),manifestSha256=sha(receipt/'manifest.json'),fixtureCount=num));files=[p for p in sorted((receipt/'evm-traces').glob('*.json'))if p.name not in ['results.json','toolchain.json']];assert len(files)==num
  for file in files:
   doc=json.loads(file.read_text());f=doc['fixture'];trace=doc['trace'];logs=trace['structLogs'];data=bytes.fromhex(f['data'][2:]);assert doc['runtimeSha256']==pin and logs[0]['pc']==0 and trace['failed']==f['failed']and trace['returnValue'].removeprefix('0x')==f['expected'];rows=[]
   for i,row in enumerate(logs):
    if row['pc']!=19564:continue
    actual=stack(row);lower=actual[:-5];ret,off,length,p,limit=actual[-5:]
    assert off<2**64 and p<limit<=length<2**64 and ret in starts and code[ret]==91
    end,kind,bits,name=classify_word_rule(data,off,p,limit)
    expected=lower+[end,kind,bits];j=i+1
    while j<len(logs)and not(logs[j]['pc']==ret and stack(logs[j])==expected):j+=1
    assert j<len(logs),(f['name'],'missing full independently classified wordRule return',name,kind,bits)
    steps,maxStack=replay_success(code,data,logs,i,j,lower,expected,starts,ret);count+=1;total+=steps;peak=max(peak,maxStack);full+=int(kind==0);narrow+=int(kind!=0);kinds[str(kind)]=kinds.get(str(kind),0)+1;names[name]=names.get(name,0)+1
    rows.append(dict(startIndex=i,terminalIndex=j,completeInstructions=steps,prefixWords=len(lower),maximumActualStack=maxStack,independentName=name,independentNameEnd=end,actualReturnedKind=kind,actualReturnedBits=bits,referenceRuleKind=reference_rule(name.encode())[0],referenceRuleBits=reference_rule(name.encode())[1]))
   fixtures.append(dict(name=f['name'],trace=str(file.relative_to(ROOT)),traceSha256=sha(file),calls=rows))
 assert len(fixtures)==649 and count>0 and full>0 and narrow>0 and all(sha(ROOT/p)==h for p,h in hashes.items())
 out.mkdir(parents=True)
 result=dict(status='development-physical-complete-word-rule-passed-not-retained',completedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),runtimeSha256=pin,historicalManifests=manifests,sourceSha256=hashes,inputsUnchanged=True,fixtureCount=len(fixtures),checkedCompleteWordRuleCalls=count,fullWidthCalls=full,narrowCalls=narrow,returnedKinds=kinds,independentNames=names,checkedSpanInstructions=total,maximumActualStack=peak,fixtures=fixtures,scope='Every reached complete wordRule call in649 fullPCzero baselines: derive base name and canonicality reference from original input, independently compute the actual returned end/kind/bits including unused bits for kind0, then reconstruct every reached opcode/full lower stack/memory through the exact actual return PC. No compiled state map supplies expectations. Finite represented names include every96 narrow canonical name and twelve full-width/fallback names. Universal native wordRule/checkWords/public codec, arbitrary other fallback variants, retained faults and independent acceptance remain open. No public credit.',assumptions=['Reviewed independent procedural wordRule classification, mathematical ASCII canonicality reference and concrete opcode replay/EDR tools.','Original reached valid named descriptor and fitting represented lower stack/positions below2^64; full actual memory stays unchanged.'])
 (out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],count,total,full,narrow,names)
if __name__=='__main__':main()
