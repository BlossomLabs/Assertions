#!/usr/bin/env python3
"""Check all reached decimal guards and arithmetic continuations exactly."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 fixtures=[];total=0;steps=0
 histories=[(ROOT/'formal/bytecode/value-array/physical-pack-admission/development/raw-pack-receipts-v1',91),(ROOT/'formal/bytecode/value-array/physical-fixed-dynamic/development/receipts-v1',4)];historical=[]
 for original,count in histories:
  m=json.loads((original/'manifest.json').read_text());assert m['status']=='development-physical-passed-not-retained'
  for p,h in m['sourceSha256'].items():assert sha(ROOT/p)==sha(original/'source-snapshot'/p)==h
  for p,h in m['evidenceSha256'].items():assert sha(original/p)==h
  historical.append(dict(manifest=str((original/'manifest.json').relative_to(ROOT)),manifestSha256=sha(original/'manifest.json'),fixtureCount=count))
  for path in sorted((original/'evm-traces').glob('*.json')):
   doc=json.loads(path.read_text())
   if path.name=='results.json':assert isinstance(doc,list)and len(doc)==count;continue
   if path.name=='toolchain.json':assert 'nodeSha256'in doc;continue
   logs=doc['trace']['structLogs'];data=bytes.fromhex(doc['fixture']['data'][2:]);calls=[]
   def stack(x):return [int(v,16)for v in x['stack']]
   for i,x in enumerate(logs):
    if x['depth']!=1 or x['pc']!=14279:continue
    actual=stack(x);prefix=actual[:-8];ret,offset,length,p,limit,end,dyn,words=actual[-8:]
    def byte(q):return data[offset+q]if offset+q<len(data)else 0
    if end>=limit or byte(end)!=91:continue
    q=end+1;k=0
    while q<limit and 48<=byte(q)<=57 and k<=0xffffffff:k=k*10+byte(q)-48;q+=1
    assert q<limit and byte(q)==93 and k<=0xffffffff
    empty=q==end+1;assert empty or k>=1
    final_dyn=1 if empty else dyn;final_words=1 if empty else words if dyn else words*k
    assert (k|final_words)<=0xffffffff
    j=i+1
    while logs[j]['pc']!=14279:
     assert logs[j]['depth']==1 and logs[j]['memory']==x['memory'],(path.name,j)
     j+=1;assert j<len(logs)
    y=logs[j];assert stack(y)==prefix+[ret,offset,length,p,limit,q+1,final_dyn,final_words]and y['memory']==x['memory'],(path.name,'suffix final')
    calls.append(dict(startIndex=i,endIndex=j,steps=j-i,start=end,end=q+1,digits=q-end-1,number=k,dynamic=final_dyn,words=final_words));total+=1;steps+=j-i
   fixtures.append(dict(name=doc['fixture']['name'],calls=calls,trace=str(path.relative_to(ROOT)),traceSha256=sha(path)))
 assert len(fixtures)==95 and total>0
 result=dict(status='development-physical-one-suffix-connection-passed-not-retained',runtimeSha256=doc['runtimeSha256'],historicalManifests=historical,sourceSha256={str(p.relative_to(ROOT)):sha(p)for p in HERE.iterdir()if p.is_file()},fixtureCount=95,checkedSuffixes=total,completeSpanSteps=steps,fixtures=fixtures,scope='Full reached opening/digit-scan/closing suffix spans against independent digit and footprint semantics among 95 complete EVM receipts including four missing fixed-dynamic geometry cases, with complete actual lower stack and memory. Unsampled branches, complete imported scalar/arithmetic/native graph, arbitrary suffix loop, errors, tuples, codec and public retention remain required.')
 (out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],total,'complete arbitrary-success-shape suffix spans,',steps,'instructions')
if __name__=='__main__':main()
