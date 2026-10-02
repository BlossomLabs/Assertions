#!/usr/bin/env python3
"""Independent concrete name specification against the entire reached decimal suffix scan."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 original=ROOT/'formal/bytecode/value-array/physical-pack-admission/development/raw-pack-receipts-v1';m=json.loads((original/'manifest.json').read_text());assert m['status']=='development-physical-passed-not-retained'
 for p,h in m['sourceSha256'].items():assert sha(ROOT/p)==sha(original/'source-snapshot'/p)==h
 for p,h in m['evidenceSha256'].items():assert sha(original/p)==h
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();fixtures=[];total=0;steps=0;other=0
 def allowed(b):return 48<=b<58 or 97<=b<123
 for path in sorted((original/'evm-traces').glob('*.json')):
  doc=json.loads(path.read_text())
  if path.name=='results.json':assert isinstance(doc,list)and len(doc)==91;continue
  if path.name=='toolchain.json':assert 'nodeSha256'in doc;continue
  assert doc['runtimeSha256']==digest;logs=doc['trace']['structLogs'];data=bytes.fromhex(doc['fixture']['data'][2:]);calls=[]
  def stack(x):return [int(v,16)for v in x['stack']]
  for i,x in enumerate(logs):
   if x['pc']!=14320 or x['depth']!=1:continue
   initial=stack(x);prefix=initial[:-10];ret,offset,length,p,limit,end,dyn,words,q0,k0=initial[-10:]
   if q0!=end+1 or k0!=0:continue
   def byte(q):return data[offset+q]if offset+q<len(data)else 0
   q=q0;k=0;iterations=[]
   while q<limit and 48<=byte(q)<=57 and k<=0xffffffff:
    iterations.append((q,k));k=k*10+byte(q)-48;q+=1
   checkpoints=iterations+[(q,k)];j=i;seen=[]
   while logs[j]['pc']!=14433:
    y=logs[j];assert y['depth']==1 and y['memory']==x['memory'],(path.name,j)
    if y['pc']==14320:seen.append(tuple(stack(y)[-2:]))
    j+=1;assert j<len(logs)
   assert seen==checkpoints,(path.name,'iteration checkpoints',seen,checkpoints)
   final=logs[j];assert stack(final)==prefix+[ret,offset,length,p,limit,end,dyn,words,q,k]and final['memory']==x['memory'],(path.name,'decimal final');calls.append(dict(startIndex=i,endIndex=j,steps=j-i,start=q0,stop=q,decimal=k,iterations=len(iterations)));total+=1;steps+=j-i
  fixtures.append(dict(name=doc['fixture']['name'],calls=calls,trace=str(path.relative_to(ROOT)),traceSha256=sha(path)))
 assert len(fixtures)==91 and total>0
 result=dict(status='development-physical-decimal-loop-passed-not-retained',runtimeSha256=digest,historicalManifest=str((original/'manifest.json').relative_to(ROOT)),historicalManifestSha256=sha(original/'manifest.json'),sourceSha256={str(p.relative_to(ROOT)):sha(p)for p in HERE.iterdir()if p.is_file()},fixtureCount=91,checkedCalls=total,completeSpanSteps=steps,otherInitialBranchesOutsideOwner=other,fixtures=fixtures,scope='Full reached decimal scan from PC14320 to exit PC14433 across 91 complete EVM receipts, compared to an independent digit-by-digit base-10 accumulation including the actual uint32 accumulator stop, with complete original lower stack and memory. Universal decimal/native proof, all other parser paths, native and public retention remain open.')
 (out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],total,'complete decimal scans,',steps,'instructions')
if __name__=='__main__':main()
