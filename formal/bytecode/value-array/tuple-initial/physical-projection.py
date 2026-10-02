#!/usr/bin/env python3
"""Check all tuple-opening guards, arithmetic, and exact recursive call frames."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 original=HERE.parent/'physical-tuples/development/receipts-v1';m=json.loads((original/'manifest.json').read_text());assert m['status']=='development-physical-passed-not-retained' and m['concreteFixtures']==8
 for path,digest in m['sourceSha256'].items():assert sha(ROOT/path)==sha(original/'source-snapshot'/path)==digest
 for path,digest in m['evidenceSha256'].items():assert sha(original/path)==digest
 tools=m['concreteToolchain'];assert m['concreteToolsUnchanged'] and m['inputsUnchanged']
 for name in ['hardhatEntry','edrEntry','nativeBinding']:assert sha(Path(tools[name]))==tools[name+'Sha256']
 assert sha(Path(tools['nodeExecutable']))==tools['nodeSha256'] and sha(ROOT/'pnpm-lock.yaml')==tools['lockfileSha256']
 mapping=json.loads((HERE/'Initial.mapping.json').read_text());code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256'];assert sha(ROOT/'artifacts/contracts/Collections.sol/Collections.json')==m['sourceSha256']['artifacts/contracts/Collections.sol/Collections.json'];assert hashlib.sha256(code).hexdigest()==mapping['runtimeSha256']==pin
 for pc,byte in mapping['requiredBytes'].items():assert code[int(pc)]==byte
 fixtures=[];total=0
 for path in sorted((original/'evm-traces').glob('*.json')):
  if path.name in ['results.json','toolchain.json']:continue
  d=json.loads(path.read_text());assert d['runtimeSha256']==pin;logs=d['trace']['structLogs'];data=bytes.fromhex(d['fixture']['data'][2:]);assert logs and logs[0]['pc']==0 and all(x['depth']==1 for x in logs);assert not d['trace']['failed'] and d['trace']['returnValue'].removeprefix('0x')==d['fixture']['expected']
  stack=lambda x:[int(v,16)for v in x['stack']];calls=[]
  for i,x in enumerate(logs):
   if x['pc']!=13839:continue
   actual=stack(x);prefix=actual[:-5];ret,offset,length,start,limit=actual[-5:]
   if start>=limit or offset+start>=len(data)or data[offset+start]!=40:continue
   fields=dict(returnPc=ret,descriptorOffset=offset,descriptorLength=length,p=start,limit=limit,b=40)
   word=int.from_bytes((data[offset+start:offset+start+32]+bytes(32))[:32],'big')
   def expr(text):
    text=text.replace('DataWord(data,descriptorOffset+p)',str(word)).replace('G.Modulus()',str(1<<256))
    for name,value in sorted(fields.items(),key=lambda item:-len(item[0])):text=text.replace(name,str(value))
    assert re.fullmatch('[0-9+%() -]+',text),text
    return eval(text,{'__builtins__':{}})
   assert start<limit<=length<2**64 and offset<2**64
   for k,state in enumerate(mapping['states']):
    observed=logs[i+k];assert observed['pc']==state['pc']and observed['memory']==x['memory']and stack(observed)==prefix+[expr(t)for t in state['stack']],(path.name,i,k)
   y=logs[i+len(mapping['states'])];assert y['pc']==mapping['terminalPc']and y['memory']==x['memory']and stack(y)==prefix+[expr(t)for t in mapping['expectedStack']],(path.name,'recursive frame')
   calls.append(dict(startIndex=i,endIndex=i+len(mapping['states']),steps=len(mapping['states']),parentPosition=start,firstChildPosition=start+1,parentPrefixWords=len(prefix)));total+=1
  fixtures.append(dict(name=d['fixture']['name'],trace=str(path.relative_to(ROOT)),traceSha256=sha(path),calls=calls))
 assert len(fixtures)==8 and total>0
 result=dict(status='development-physical-tuple-opening-passed-not-retained',runtimeSha256=pin,historicalManifest=str((original/'manifest.json').relative_to(ROOT)),historicalManifestSha256=sha(original/'manifest.json'),sourceSha256={str(path.relative_to(ROOT)):sha(path)for path in HERE.iterdir()if path.is_file()},fixtureCount=8,checkedCalls=total,checkedInstructions=total*len(mapping['states']),fixtures=fixtures,scope='Every actual full 65-instruction tuple opening path and first recursive child full-stack/memory frame among eight complete real EVM receipts. Universal whole native owners, later tuple recursion/errors and codec retention remain required. No public credit.')
 (out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],total,'complete65-instruction recursive call frames')
if __name__=='__main__':main()
