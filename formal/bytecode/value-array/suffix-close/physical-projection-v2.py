#!/usr/bin/env python3
"""Check all reached decimal guards and arithmetic continuations exactly."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 names=['Empty','Dynamic','Static'];maps={n:json.loads((HERE/f'{n}.mapping.json').read_text())for n in names};code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert all(x['runtimeSha256']==digest for x in maps.values());counts={n:0 for n in names};fixtures=[]
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
   assert doc['runtimeSha256']==digest;logs=doc['trace']['structLogs'];data=bytes.fromhex(doc['fixture']['data'][2:]);local={n:0 for n in maps}
   def stack(x):return [int(v,16)for v in x['stack']]
   for i,x in enumerate(logs):
    if x['depth']!=1 or x['pc']!=14433:continue
    actual=stack(x);prefix=actual[:-10];fields=dict(zip(['returnPc','descriptorOffset','descriptorLength','p','limit','end','dyn','words','q','k'],actual[-10:]));index=fields['descriptorOffset']+fields['q'];fields['b']=data[index]if index<len(data)else 0
    if fields['q']>=fields['limit']or fields['b']!=93:raise AssertionError('Rejected branch is outside the currently canonical physical fixtures')
    mode='Empty'if fields['q']==fields['end']+1 else'Dynamic'if fields['dyn']else'Static';mapping=maps[mode]
    if mode=='Empty':assert fields['k']==0
    else:assert 1<=fields['k']<=0xffffffff and fields['dyn']in {0,1}
    if mode=='Dynamic':assert fields['words']==1
    if mode=='Static':assert 1<=fields['words']and fields['words']*fields['k']<=0xffffffff
    word=int.from_bytes((data[index:index+32]+bytes(32))[:32],'big')
    def expr(text):
     if text.isdecimal():return int(text)
     if text in fields:return fields[text]
     if text=='descriptorOffset+q':return index
     if text=='DataWord(data,descriptorOffset+q)':return word
     if text=='end+1':return fields['end']+1
     if text=='q+1':return fields['q']+1
     if text=='q-(end+1)':return fields['q']-fields['end']-1
     if text=='words*k':return fields['words']*fields['k']
     if text.startswith('G.BitOr(')and text.endswith(')'):
      a,z=text[len('G.BitOr('):-1].split(',');return expr(a)|expr(z)
     raise AssertionError(text)
    for j,s in enumerate(mapping['states']):
     y=logs[i+j];assert y['pc']==s['pc']and y['depth']==1 and stack(y)==prefix+[expr(t)for t in s['stack']]and y['memory']==x['memory'],(path.name,mode,s['pc'])
    y=logs[i+len(mapping['states'])];assert y['pc']==mapping['terminalPc']and y['depth']==1 and stack(y)==prefix+[expr(t)for t in mapping['expectedStack']]and y['memory']==x['memory'],(path.name,mode,'terminal');counts[mode]+=1;local[mode]+=1
   fixtures.append(dict(name=doc['fixture']['name'],checkedBlocks=local,trace=str(path.relative_to(ROOT)),traceSha256=sha(path)))
 assert len(fixtures)==95 and all(v>0 for v in counts.values())
 result=dict(status='development-physical-suffix-close-passed-not-retained',runtimeSha256=digest,historicalManifests=historical,sourceSha256={str(p.relative_to(ROOT)):sha(p)for p in HERE.iterdir()if p.is_file()},fixtureCount=95,checkedBlocks=counts,unsampledBranches=[n for n,v in counts.items()if v==0],fixtures=fixtures,scope='All reached successful empty/dynamic/static suffix-closing spans among 95 complete EVM receipts including four missing fixed-dynamic geometry cases, with complete actual lower stack and memory. Unsampled branches, complete imported scalar/arithmetic/native graph, arbitrary suffix loop, errors, tuples, codec and public retention remain required.')
 (out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],counts,'unsampled branches',result['unsampledBranches'])
if __name__=='__main__':main()
