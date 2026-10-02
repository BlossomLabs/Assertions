#!/usr/bin/env python3
"""Independently reconstruct complete tuple base executions before any suffix."""
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
def parse(data, offset, start, limit):
    """Finite ASCII descriptor parser independent of proof mappings/EVM states."""
    assert start < limit

    def byte(pos):
        return data[offset + pos] if offset + pos < len(data) else 0

    def allowed(c):
        return 48 <= c <= 57 or 97 <= c <= 122

    if byte(start) == 40:
        cursor = start + 1
        dynamic = total = 0
        depth = 1
        children = []
        while True:
            child = parse(data, offset, cursor, limit)
            children.append(child)
            total += child['words']
            assert total <= 0xffffffff * (child['end'] - start - len(children))
            assert total < 2**256
            dynamic |= child['dynamic']
            depth = max(depth, 1 + child['tupleDepth'])
            cursor = child['end']
            assert cursor < limit
            if byte(cursor) == 44:
                cursor += 1
                continue
            assert byte(cursor) == 41
            end = cursor + 1
            words = 1 if dynamic else total
            tree = dict(kind='tuple', children=children)
            break
    else:
        end = start
        while end < limit and allowed(byte(end)):
            end += 1
        assert end > start
        name = data[offset + start:offset + end]
        dynamic = int(name in [b'bytes', b'string'])
        words = 1
        depth = 0
        tree = dict(kind='named', name=name.decode('ascii'))
    suffixes = []
    while end < limit and byte(end) == 91:
        opening = end
        close = end + 1
        number = 0
        while close < limit and 48 <= byte(close) <= 57 and number <= 0xffffffff:
            number = 10 * number + byte(close) - 48
            close += 1
        empty = close == opening + 1
        assert close < limit and byte(close) == 93
        assert empty or number > 0
        if empty:
            dynamic, words = 1, 1
        elif not dynamic:
            words *= number
            assert words < 2**256
        assert (number | words) <= 0xffffffff
        suffixes.append(dict(opening=opening, close=close, number=number))
        end = close + 1
    assert 1 <= words <= 0xffffffff * (end - start)
    tree.update(start=start, end=end, dynamic=dynamic, words=words,
                tupleDepth=depth, suffixes=suffixes)
    return tree


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
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--output',type=Path,required=True);args=ap.parse_args();out=args.output.resolve();assert not out.exists()
 scope=json.loads((HERE/'scope.json').read_text());closed=graph([ROOT/p for p in scope['selectedSources']]);sources=closed|{p for folder in {p.parent for p in closed}|{HERE}for p in folder.iterdir()if p.is_file()};hashes={str(p.relative_to(ROOT)):sha(p)for p in sorted(sources)}
 histories=[('physical-pack-admission/development/raw-pack-receipts-v1',91),('physical-fixed-dynamic/development/receipts-v1',4),('physical-suffix-chains/development/receipts-v1',6),('physical-tuples/development/receipts-v1',8),('physical-tuple-first-dynamic/development/receipts-v1',2),('physical-descriptor-errors/development/receipts-v2',60),('physical-descriptor-start-errors/development/receipts-v1',8)]
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);pin=hashlib.sha256(code).hexdigest();assert pin==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256'];starts=set();pc=0
 while pc<len(code):starts.add(pc);op=code[pc];pc+=1+(op-95 if 96<=op<=127 else 0)
 fixtures=[];manifests=[];count=total=peak=unconnectedFailures=0;named=tuples=acceptedBeforeError=0;reasons={name:0 for name in ['atLimit','wrongClose','wide','zero']}
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
    if row['pc']!=13839:continue
    actual=stack(row);prefix=actual[:-5];ret,off,length,p,limit=actual[-5:];assert off<2**64 and limit<=length<2**64
    byte=lambda pos:data[off+pos]if off+pos<len(data)else 0
    if p>=limit or not trace['failed']:continue
    if byte(p)==40:
     cursor=p+1;children=[];dynamic=words=0;depth=1;valid=True
     while True:
      try:child=parse(data,off,cursor,limit)
      except AssertionError:valid=False;break
      children.append(child);words+=child['words'];dynamic|=child['dynamic'];depth=max(depth,1+child['tupleDepth']);assert words<=0xffffffff*(child['end']-p-len(children))and words<MOD;cursor=child['end']
      if cursor>=limit:valid=False;break
      if byte(cursor)==44:cursor+=1;continue
      if byte(cursor)!=41:valid=False;break
      end=cursor+1;words=1 if dynamic else words;break
     if not valid:unconnectedFailures+=1;continue
    else:
     end=p
     while end<limit and(48<=byte(end)<=57 or 97<=byte(end)<=122):end+=1
     if end==p:unconnectedFailures+=1;continue
     dynamic=int(data[off+p:off+end]in[b'bytes',b'string']);words=1;depth=0
    assert len(prefix)+13*depth<=1004 and 1<=words<=0xffffffff*(end-p)
    initial=[end,dynamic,words];closings=[]
    while end<limit and byte(end)==91:
     opening=end;q=end+1;k=0
     while q<limit and 48<=byte(q)<=57 and k<=0xffffffff:k=10*k+byte(q)-48;q+=1
     nextDynamic=1 if q==opening+1 else dynamic;nextWords=1 if q==opening+1 else words if dynamic else words*k
     assert nextWords<MOD
     if q>=limit or byte(q)!=93 or k>0xffffffff or nextWords>0xffffffff or(q!=opening+1 and k==0):break
     closings.append(dict(opening=opening,close=q,number=k,span=nextWords,dynamic=nextDynamic));end=q+1;dynamic=nextDynamic;words=nextWords
    if end==limit or byte(end)!=91:continue
    q=end+1;k=0
    while q<limit and 48<=byte(q)<=57 and k<=0xffffffff:k=10*k+byte(q)-48;q+=1
    nextDyn=1 if q==end+1 else dynamic;nextWords=1 if q==end+1 else words if dynamic else words*k
    reason='atLimit'if q==limit else'wrongClose'if byte(q)!=93 else'wide'if k>0xffffffff or nextWords>0xffffffff else'zero'if k==0 and q!=end+1 else None
    if reason is None:continue
    assert k<=0xffffffff*10+9 and words*k<MOD
    packet=bytes.fromhex('9a67d126')+q.to_bytes(32,'big');assert packet.hex()==f['expected']and f['position']==q
    steps,maxStack=replay(code,data,logs,i,prefix,packet,starts);count+=1;total+=steps;peak=max(peak,maxStack);reasons[reason]+=1;named+=int(byte(p)!=40);tuples+=int(byte(p)==40);acceptedBeforeError+=int(bool(closings));rows.append(dict(startIndex=i,terminalIndex=len(logs)-1,completeInstructions=steps,prefixWords=len(prefix),maximumActualStack=maxStack,baseKind='tuple'if byte(p)==40 else'named',baseShape=initial,acceptedClosings=closings,errorOpening=end,decimalStop=q,decimal=k,independentReason=reason,errorPacket=packet.hex()))
   fixtures.append(dict(name=f['name'],trace=str(file.relative_to(ROOT)),traceSha256=sha(file),calls=rows))
 assert len(fixtures)==179 and count==24 and tuples>0 and named>0 and acceptedBeforeError>0 and reasons==dict(atLimit=4,wrongClose=6,wide=8,zero=6)and all(sha(ROOT/p)==h for p,h in hashes.items());out.mkdir(parents=True);result=dict(status='development-physical-complete-parser-suffix-rejections-passed-not-retained',completedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),runtimeSha256=pin,historicalManifests=manifests,sourceSha256=hashes,inputsUnchanged=True,fixtureCount=len(fixtures),checkedCompleteParserRejections=count,namedBases=named,tupleBases=tuples,acceptedPrefixesBeforeRejection=acceptedBeforeError,byIndependentReason=reasons,checkedSpanInstructions=total,maximumActualStack=peak,unconnectedRejectingBases=unconnectedFailures,fixtures=fixtures,scope='All complete named/accepted-child tuple base suffix rejection type calls among 179 complete PC-zero receipts. Independent base/recursive child grammar, finite accepted prefixes, and earliest decimal stop derive the exact packet. Every actual opcode, PC, full stack and memory independently reconstructed from type entry PC 13839 through terminal REVERT. No internal error frame or packet expectation comes from generated mappings. Recursive rejecting children/tuple separators, native, arbitrary public codecs, mutation/retained closure remain open. No public credit.',assumptions=['Reviewed concrete opcode replay and physical EDR interpreter/tools remain interpretation assumptions.','Original represented type frame, positions below 2^64, lower/recursive stack budget and fitting free memory are explicitly checked; exact compiler/runtime bytes are pinned.']);(out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],count,total,named,tuples,acceptedBeforeError,reasons)
if __name__=='__main__':main()
