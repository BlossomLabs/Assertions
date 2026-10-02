#!/usr/bin/env python3
"""Check complete successful and rejecting suffix footprint calculation frames."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
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
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--output',type=Path,required=True);a=ap.parse_args();out=a.output.resolve();assert not out.exists()
 scope=json.loads((HERE/'scope.json').read_text());closed=graph([ROOT/p for p in scope['selectedSources']]);paths=closed|{p for folder in {p.parent for p in closed}|{HERE}for p in folder.iterdir()if p.is_file()};hashes={str(p.relative_to(ROOT)):sha(p)for p in sorted(paths)}
 histories=[('physical-pack-admission/development/raw-pack-receipts-v1',91),('physical-fixed-dynamic/development/receipts-v1',4),('physical-suffix-chains/development/receipts-v1',6),('physical-tuples/development/receipts-v1',8),('physical-tuple-first-dynamic/development/receipts-v1',2),('physical-descriptor-errors/development/receipts-v2',60),('physical-descriptor-start-errors/development/receipts-v1',8)]
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256'];names=['Empty','Dynamic','Static'];maps={n:json.loads((HERE/(n+'.mapping.json')).read_text())for n in names}
 for m in maps.values():assert m['runtimeSha256']==digest and all(code[int(pc)]==value for pc,value in m['requiredBytes'].items())
 counts={n:0 for n in names};steps=0;fixtures=[];manifests=[];zero=large=atLimit=wrongClose=0
 for relative,count in histories:
  original=HERE.parent/relative;m=json.loads((original/'manifest.json').read_text());assert m['status']=='development-physical-passed-not-retained'and m['completedAt']and m['concreteFixtures']==count and m['inputsUnchanged']and m['concreteToolsUnchanged']and all(c['passed']and c['exitCode']==0 for c in m['checks'])
  for p,h in m['sourceSha256'].items():assert sha(ROOT/p)==sha(original/'source-snapshot'/p)==h
  for p,h in m['evidenceSha256'].items():assert sha(original/p)==h
  t=m['concreteToolchain']
  for key in ['hardhatEntry','edrEntry','nativeBinding']:assert sha(Path(t[key]))==t[key+'Sha256']
  assert sha(Path(t['nodeExecutable']))==t['nodeSha256']and sha(ROOT/'pnpm-lock.yaml')==t['lockfileSha256'];manifests.append(dict(manifest=str((original/'manifest.json').relative_to(ROOT)),manifestSha256=sha(original/'manifest.json'),fixtureCount=count));files=[p for p in sorted((original/'evm-traces').glob('*.json'))if p.name not in ['results.json','toolchain.json']];assert len(files)==count
  for file in files:
   doc=json.loads(file.read_text());assert doc['runtimeSha256']==digest;logs=doc['trace']['structLogs'];data=bytes.fromhex(doc['fixture']['data'][2:]);assert logs[0]['pc']==0 and doc['trace']['failed']==doc['fixture']['failed']and doc['trace']['returnValue'].removeprefix('0x')==doc['fixture']['expected'];calls=[]
   stack=lambda x:[int(v,16)for v in x['stack']]
   for i,x in enumerate(logs):
    if x['pc']!=14433:continue
    actual=stack(x);prefix=actual[:-10];fields=dict(zip(['returnPc','descriptorOffset','descriptorLength','p','limit','end','dyn','words','q','k'],actual[-10:]));ret,off,length,p,limit,end,dyn,words,q,k=actual[-10:];assert x['depth']==1 and off<2**64 and p<end<q<=limit<=length<2**64 and dyn<=1 and words>=1 and (dyn==0 or words==1)
    assert words<=0xffffffff*(end-p)and k<=0xffffffff*10+9
    number=0
    for pos in range(end+1,q):
     byte=data[off+pos]if off+pos<len(data)else 0;assert 48<=byte<=57 and number<=0xffffffff;number=10*number+byte-48
    assert number==k
    byte=data[off+q]if off+q<len(data)else 0;assert q==limit or not 48<=byte<=57 or k>0xffffffff
    mode='Empty'if q==end+1 else'Dynamic'if dyn else'Static';mapping=maps[mode]
    if mode=='Empty':assert k==0
    if mode=='Static':assert words*k<2**256
    def expr(text):
     if text.isdecimal():return int(text)
     if text in fields:return fields[text]
     if text=='end+1':return end+1
     if text=='q-(end+1)':return q-end-1
     if text=='words*k':return words*k
     if text.startswith('G.BitOr(')and text.endswith(')'):
      a,z=text[len('G.BitOr('):-1].split(',');return expr(a)|expr(z)
     raise AssertionError(text)
    for j,s in enumerate(mapping['states']):
     y=logs[i+j];assert y['pc']==s['pc']and y['depth']==1 and stack(y)==prefix+[expr(v)for v in s['stack']]and y['memory']==x['memory'],(file.name,mode,j)
    y=logs[i+len(mapping['states'])];assert y['pc']==14481==mapping['terminalPc']and y['depth']==1 and stack(y)==prefix+[expr(v)for v in mapping['expectedStack']]and y['memory']==x['memory'];counts[mode]+=1;steps+=len(mapping['states']);zero+=int(q>end+1 and k==0);large+=int(k>0xffffffff);atLimit+=int(q==limit);wrongClose+=int(q<limit and byte!=93);calls.append(dict(mode=mode,startIndex=i,terminalIndex=i+len(mapping['states']),completeInstructions=len(mapping['states']),prefixWords=len(prefix),opening=end,decimalStop=q,number=k,initialWords=words))
   fixtures.append(dict(name=doc['fixture']['name'],trace=str(file.relative_to(ROOT)),traceSha256=sha(file),calls=calls))
 assert len(fixtures)==179 and all(counts.values())and zero and large and atLimit and wrongClose and all(sha(ROOT/p)==h for p,h in hashes.items());out.mkdir(parents=True);result=dict(status='development-physical-complete-suffix-footprints-passed-not-retained',runtimeSha256=digest,historicalManifests=manifests,sourceSha256=hashes,inputsUnchanged=True,fixtureCount=len(fixtures),checkedCompleteFootprints=sum(counts.values()),byKind=counts,checkedSpanInstructions=steps,edgeCases=dict(nonemptyZero=zero,decimalOverflow=large,atLimit=atLimit,wrongClosingByte=wrongClose),fixtures=fixtures,scope='All complete empty/dynamic/static suffix footprint spans among 179 complete PC-zero receipts, independent decimal accumulation and earliest-stop checks, mathematical original prefix span and product fitting, full lower stack and unchanged physical memory through actual guard entry 14481, retaining zero/overflow/missing-close/wrong-close cases. Universal preceding prefix parser connection, all native/fault/codec/retention gates remain open. No public credit.');(out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],counts,steps,result['edgeCases'])
if __name__=='__main__':main()
