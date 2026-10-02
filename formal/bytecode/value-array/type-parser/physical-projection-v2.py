#!/usr/bin/env python3
"""Check complete named and recursive tuple parser spans against independent syntax."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256'];code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(code).hexdigest()==pin
 histories=[('physical-pack-admission/development/raw-pack-receipts-v1',91),('physical-fixed-dynamic/development/receipts-v1',4),('physical-suffix-chains/development/receipts-v1',6),('physical-tuples/development/receipts-v1',8),('physical-tuple-first-dynamic/development/receipts-v1',2)];manifests=[];fixtures=[];counts={'named':0,'tuple':0};steps=0;max_depth=0
 for relative,count in histories:
  original=HERE.parent/relative;m=json.loads((original/'manifest.json').read_text());assert m['status']=='development-physical-passed-not-retained' and m['concreteFixtures']==count
  for path,digest in m['sourceSha256'].items():assert sha(ROOT/path)==sha(original/'source-snapshot'/path)==digest
  for path,digest in m['evidenceSha256'].items():assert sha(original/path)==digest
  tools=m['concreteToolchain'];assert m['concreteToolsUnchanged'] and m['inputsUnchanged']
  for name in ['hardhatEntry','edrEntry','nativeBinding']:assert sha(Path(tools[name]))==tools[name+'Sha256']
  assert sha(Path(tools['nodeExecutable']))==tools['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==tools['lockfileSha256']
  manifests.append(dict(manifest=str((original/'manifest.json').relative_to(ROOT)),manifestSha256=sha(original/'manifest.json'),fixtureCount=count));files=[path for path in sorted((original/'evm-traces').glob('*.json'))if path.name not in ['results.json','toolchain.json']];assert len(files)==count
  for path in files:
   doc=json.loads(path.read_text());assert doc['runtimeSha256']==pin;logs=doc['trace']['structLogs'];data=bytes.fromhex(doc['fixture']['data'][2:]);assert logs and logs[0]['pc']==0 and all(x['depth']==1 for x in logs);assert doc['trace']['failed']==doc['fixture']['failed'] and doc['trace']['returnValue'].removeprefix('0x')==doc['fixture']['expected'];calls=[]
   def stack(x):return [int(v,16)for v in x['stack']]
   for i,x in enumerate(logs):
    if x['pc']!=13839:continue
    actual=stack(x);prefix=actual[:-5];ret,offset,length,start,limit=actual[-5:];assert start<limit<=length<2**64 and offset<2**64 and code[ret]==91
    def byte(q):return data[offset+q]if offset+q<len(data)else 0
    def allowed(c):return 48<=c<=57 or 97<=c<=122
    def parse(q):
     assert q<limit
     if byte(q)==40:
      child=q+1;total=0;dyn=0;depth=1;nodes=[]
      while True:
       end,child_dyn,words,child_depth,tree=parse(child);assert 1<=words<=0xffffffff*(end-child);nodes.append(tree);total+=words;assert total<=0xffffffff*(end-q-len(nodes));assert total<2**256;dyn|=child_dyn;depth=max(depth,1+child_depth)
       assert end<limit
       if byte(end)==44:child=end+1;continue
       assert byte(end)==41;end+=1;words=1 if dyn else total;tree=dict(kind='tuple',children=nodes);break
     else:
      end=q
      while end<limit and allowed(byte(end)):end+=1
      assert end>q
      name=data[offset+q:offset+end];dyn=int(name in [b'bytes',b'string']);words=1;depth=0;tree=dict(kind='named',name=name.decode('ascii'),baseEnd=end)
     suffixes=[]
     while end<limit and byte(end)==91:
      opening=end;close=end+1;k=0
      while close<limit and 48<=byte(close)<=57 and k<=0xffffffff:k=10*k+byte(close)-48;close+=1
      empty=close==end+1
      if empty:dyn,words=1,1
      elif not dyn:words*=k;assert words<2**256
      assert close<limit and byte(close)==93 and (k|words)<=0xffffffff and(empty or k>0)
      suffixes.append(dict(opening=opening,close=close,number=k));end=close+1
     assert 1<=words<=0xffffffff*(end-q);tree.update(start=q,end=end,dynamic=dyn,words=words,suffixes=suffixes);return end,dyn,words,depth,tree
    end,dyn,words,depth,tree=parse(start);assert len(prefix)+13*depth<=1004
    terminal=prefix+[end,dyn,words];j=i+1
    while True:
     assert j<len(logs),(path.name,'missing exact parser return');y=logs[j];assert y['depth']==1 and y['memory']==x['memory'],(path.name,j,'parser memory')
     if y['pc']==ret and stack(y)==terminal:break
     j+=1
    counts[tree['kind']]+=1;steps+=j-i;max_depth=max(max_depth,depth);calls.append(dict(startIndex=i,endIndex=j,steps=j-i,parentPrefixWords=len(prefix),tupleDepth=depth,shape=tree))
   fixtures.append(dict(name=doc['fixture']['name'],trace=str(path.relative_to(ROOT)),traceSha256=sha(path),calls=calls))
 assert len(fixtures)==111 and all(counts.values())and max_depth>=2
 result=dict(status='development-physical-complete-recursive-type-parser-passed-not-retained',runtimeSha256=pin,historicalManifests=manifests,sourceSha256={str(path.relative_to(ROOT)):sha(path)for path in HERE.iterdir()if path.is_file()},fixtureCount=len(fixtures),checkedCompleteParsers=sum(counts.values()),byKind=counts,maximumTupleDepth=max_depth,checkedSpanInstructions=steps,fixtures=fixtures,scope='Every reached successful full named/tuple parser span, independent recursive ASCII/bracket/digit/comma/closing and static/dynamic footprint semantics, exact final caller stack, unchanged physical memory, derived observed stack and arithmetic bounds, among 111 complete PC-zero EVM receipts. Universal native closure, complete universal native descriptor-size bound, rejecting branches and complete codec retention remain open. No public credit.')
 (out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],counts,steps,'complete span instructions')
if __name__=='__main__':main()
