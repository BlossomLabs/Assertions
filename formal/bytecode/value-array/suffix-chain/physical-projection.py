#!/usr/bin/env python3
"""Bind complete successful suffix loops to independent digit/shape semantics."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);args=parser.parse_args();out=args.output.resolve();out.mkdir(parents=True,exist_ok=False)
 pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']
 histories=[('physical-pack-admission/development/raw-pack-receipts-v1',91),('physical-fixed-dynamic/development/receipts-v1',4),('physical-suffix-chains/development/receipts-v1',6)]
 manifests=[];fixtures=[];total=0;steps=0;suffixes=0;repeated=0;leading_zero=0
 for relative,count in histories:
  original=ROOT/'formal/bytecode/value-array'/relative;m=json.loads((original/'manifest.json').read_text());assert m['status']=='development-physical-passed-not-retained' and m['concreteFixtures']==count
  for path,digest in m['sourceSha256'].items():assert sha(ROOT/path)==sha(original/'source-snapshot'/path)==digest
  for path,digest in m['evidenceSha256'].items():assert sha(original/path)==digest
  tools=m['concreteToolchain'];assert m['concreteToolsUnchanged'] and m['inputsUnchanged']
  for tool in ['hardhatEntry','edrEntry','nativeBinding']:assert sha(Path(tools[tool]))==tools[tool+'Sha256']
  assert sha(Path(tools['nodeExecutable']))==tools['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==tools['lockfileSha256']
  manifests.append(dict(manifest=str((original/'manifest.json').relative_to(ROOT)),manifestSha256=sha(original/'manifest.json'),fixtureCount=count))
  files=[path for path in sorted((original/'evm-traces').glob('*.json')) if path.name not in ['results.json','toolchain.json']];assert len(files)==count
  for path in files:
   doc=json.loads(path.read_text());assert doc['runtimeSha256']==pin
   logs=doc['trace']['structLogs'];data=bytes.fromhex(doc['fixture']['data'][2:]);assert logs and logs[0]['pc']==0 and all(x['depth']==1 for x in logs)
   assert doc['trace']['failed']==doc['fixture']['failed'] and doc['trace']['returnValue'].removeprefix('0x')==doc['fixture']['expected']
   def stack(x):return [int(v,16) for v in x['stack']]
   calls=[];covered=-1
   for i,x in enumerate(logs):
    if i<=covered or x['pc']!=14279:continue
    actual=stack(x);prefix=actual[:-8];ret,offset,length,p,limit,end,dyn,words=actual[-8:]
    assert end<=limit<=length<2**64 and offset<2**64 and dyn in [0,1] and words>=1 and (not dyn or words==1)
    def byte(q):return data[offset+q] if offset+q<len(data) else 0
    expected=[(end,dyn,words)];spans=[]
    while end<limit and byte(end)==91:
     start=end;q=end+1;k=0
     while q<limit and 48<=byte(q)<=57 and k<=0xffffffff:k=10*k+byte(q)-48;q+=1
     assert q<limit and byte(q)==93 and k<=0xffffffff
     empty=q==end+1;assert empty or k>=1
     if empty:dyn,words=1,1
     elif not dyn:words*=k
     assert (k|words)<=0xffffffff
     if q>end+2 and byte(end+1)==48:leading_zero+=1
     spans.append(dict(start=start,close=q,number=k,digits=q-start-1,dynamic=dyn,words=words));end=q+1;expected.append((end,dyn,words));suffixes+=1
    terminal=prefix+[end,dyn,words];j=i+1;seen=1
    while True:
     assert j<len(logs),(path.name,'missing exact return')
     y=logs[j];assert y['depth']==1 and y['memory']==x['memory'],(path.name,j,'memory')
     if y['pc']==ret and stack(y)==terminal:break
     if y['pc']==14279:
      assert seen<len(expected),(path.name,'unexpected suffix iteration')
      next_end,next_dyn,next_words=expected[seen];assert stack(y)==prefix+[ret,offset,length,p,limit,next_end,next_dyn,next_words],(path.name,j,'exact suffix frame');seen+=1
     j+=1
    assert seen==len(expected),(path.name,'missing suffix iteration')
    covered=j;total+=1;steps+=j-i;repeated+=len(spans)>=2
    calls.append(dict(startIndex=i,endIndex=j,steps=j-i,startShape=expected[0],finalShape=expected[-1],suffixes=spans))
   fixtures.append(dict(name=doc['fixture']['name'],trace=str(path.relative_to(ROOT)),traceSha256=sha(path),calls=calls))
 assert len(fixtures)==101 and total>0 and repeated>0 and leading_zero>0
 result=dict(status='development-physical-arbitrary-suffix-chain-passed-not-retained',runtimeSha256=pin,historicalManifests=manifests,sourceSha256={str(path.relative_to(ROOT)):sha(path)for path in HERE.iterdir()if path.is_file()},fixtureCount=len(fixtures),checkedCompleteLoops=total,checkedSuffixes=suffixes,completeSpanSteps=steps,repeatedSuffixLoops=repeated,leadingZeroLengths=leading_zero,fixtures=fixtures,scope='Full reached suffix loops including exact terminal returns, independent bracket/digit/footprint semantics, all actual lower stacks and unchanged memory among 101 complete PC-zero canonical or exact rejecting receipts. Includes fresh repeated-static/dynamic and leading-zero geometries. Native closure, errors, tuples and codec retention remain open. No public credit.')
 (out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],total,'full suffix loops,',suffixes,'suffixes,',steps,'instructions')
if __name__=='__main__':main()
