#!/usr/bin/env python3
"""Bind every reached successful tuple continuation to its full exact instruction frame."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 modes=['CommaStatic','CommaDynamic','CloseStatic','CloseParentDynamic','CloseChildDynamic'];mappings={name:json.loads((HERE/(name+'.mapping.json')).read_text())for name in modes};code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256'];assert hashlib.sha256(code).hexdigest()==pin
 for mapping in mappings.values():
  assert mapping['runtimeSha256']==pin
  for pc,byte in mapping['requiredBytes'].items():assert code[int(pc)]==byte
 histories=[('physical-tuples/development/receipts-v1',8),('physical-tuple-first-dynamic/development/receipts-v1',2)];manifests=[];fixtures=[];counts={mode:0 for mode in modes};total=0
 for relative,count in histories:
  original=HERE.parent/relative;m=json.loads((original/'manifest.json').read_text());assert m['status']=='development-physical-passed-not-retained' and m['concreteFixtures']==count
  for path,digest in m['sourceSha256'].items():assert sha(ROOT/path)==sha(original/'source-snapshot'/path)==digest
  for path,digest in m['evidenceSha256'].items():assert sha(original/path)==digest
  tools=m['concreteToolchain'];assert m['concreteToolsUnchanged'] and m['inputsUnchanged']
  for name in ['hardhatEntry','edrEntry','nativeBinding']:assert sha(Path(tools[name]))==tools[name+'Sha256']
  assert sha(Path(tools['nodeExecutable']))==tools['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==tools['lockfileSha256']
  manifests.append(dict(manifest=str((original/'manifest.json').relative_to(ROOT)),manifestSha256=sha(original/'manifest.json'),fixtureCount=count))
  files=[path for path in sorted((original/'evm-traces').glob('*.json'))if path.name not in ['results.json','toolchain.json']];assert len(files)==count
  for path in files:
   doc=json.loads(path.read_text());assert doc['runtimeSha256']==pin;logs=doc['trace']['structLogs'];data=bytes.fromhex(doc['fixture']['data'][2:]);assert logs and logs[0]['pc']==0 and all(x['depth']==1 for x in logs);assert not doc['trace']['failed'] and doc['trace']['returnValue'].removeprefix('0x')==doc['fixture']['expected']
   stack=lambda x:[int(v,16)for v in x['stack']];calls=[]
   for i,x in enumerate(logs):
    if x['pc']!=13958:continue
    actual=stack(x);prefix=actual[:-16];ret,offset,length,start,limit,parentEnd,parentDyn,parentWords,q,parentSum,a0,a1,a2,e,childDyn,childWords=actual[-16:];assert parentEnd==parentWords==a0==a1==a2==0
    assert start<q<=e<limit<=length<2**64 and offset<2**64 and parentDyn in [0,1]and childDyn in [0,1]and childWords>=1 and parentSum+childWords<2**256
    b=data[offset+e];assert b in [41,44]
    mode=('CommaDynamic'if childDyn else'CommaStatic')if b==44 else'CloseChildDynamic'if childDyn else'CloseParentDynamic'if parentDyn else'CloseStatic';mapping=mappings[mode]
    fields=dict(returnPc=ret,descriptorOffset=offset,descriptorLength=length,p=start,limit=limit,parentDyn=parentDyn,q=q,sum=parentSum,e=e,childDyn=childDyn,childWords=childWords,b=b)
    word=int.from_bytes((data[offset+e:offset+e+32]+bytes(32))[:32],'big')
    def expr(text):
     text=text.replace('DataWord(data,descriptorOffset+e)',str(word)).replace('G.Modulus()',str(1<<256)).replace('G.BitAnd(255,b)',str(b)).replace('G.BitAnd(b,255)',str(b))
     for name,value in sorted(fields.items(),key=lambda item:-len(item[0])):text=text.replace(name,str(value))
     assert re.fullmatch('[0-9+%() -]+',text),text
     return eval(text,{'__builtins__':{}})
    for k,state in enumerate(mapping['states']):
     observed=logs[i+k];assert observed['pc']==state['pc']and observed['memory']==x['memory']and stack(observed)==prefix+[expr(text)for text in state['stack']],(path.name,mode,i,k)
    y=logs[i+len(mapping['states'])];assert y['pc']==mapping['terminalPc']and y['memory']==x['memory']and stack(y)==prefix+[expr(text)for text in mapping['expectedStack']],(path.name,mode,'final continuation frame')
    counts[mode]+=1;total+=len(mapping['states']);calls.append(dict(mode=mode,startIndex=i,endIndex=i+len(mapping['states']),steps=len(mapping['states']),childEnd=e,childDynamic=childDyn,childWords=childWords,parentDynamic=parentDyn,parentSum=parentSum))
   fixtures.append(dict(name=doc['fixture']['name'],trace=str(path.relative_to(ROOT)),traceSha256=sha(path),calls=calls))
 assert len(fixtures)==10 and all(counts.values()),counts
 result=dict(status='development-physical-tuple-continuations-passed-not-retained',runtimeSha256=pin,historicalManifests=manifests,sourceSha256={str(path.relative_to(ROOT)):sha(path)for path in HERE.iterdir()if path.is_file()},fixtureCount=len(fixtures),checkedContinuations=sum(counts.values()),checkedInstructions=total,byBranch=counts,fixtures=fixtures,scope='All five successful compiled tuple child-return branches, every actual checked addition/character guard/call or close frame, full lower stacks and unchanged memory among ten complete real EVM tuple receipts. Complete universal native tuple recursion/error/codec retention remains open. No public credit.')
 (out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],counts,total,'exact instructions')
if __name__=='__main__':main()
