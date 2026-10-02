#!/usr/bin/env python3
"""Check every reached admitted shape suffix boundary against full EVM states."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 original=ROOT/'formal/bytecode/value-array/physical-pack-admission/development/raw-pack-receipts-v1';m=json.loads((original/'manifest.json').read_text());assert m['status']=='development-physical-passed-not-retained'
 for p,h in m['sourceSha256'].items():assert sha(ROOT/p)==sha(original/'source-snapshot'/p)==h
 for p,h in m['evidenceSha256'].items():assert sha(original/p)==h
 maps={n:json.loads((HERE/f'{n}.mapping.json').read_text())for n in ['Open','End','Other']};code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert all(x['runtimeSha256']==digest for x in maps.values());counts={n:0 for n in maps};excluded=0;fixtures=[]
 for path in sorted((original/'evm-traces').glob('*.json')):
  doc=json.loads(path.read_text())
  if path.name=='results.json':assert isinstance(doc,list)and len(doc)==91;continue
  if path.name=='toolchain.json':assert 'nodeSha256'in doc;continue
  assert doc['runtimeSha256']==digest;logs=doc['trace']['structLogs'];data=bytes.fromhex(doc['fixture']['data'][2:]);local={n:0 for n in maps}
  def stack(x):return [int(v,16)for v in x['stack']]
  for i,x in enumerate(logs):
   if x['depth']!=1 or x['pc']!=14279:continue
   actual=stack(x);prefix=actual[:-8];fields=dict(zip(['returnPc','descriptorOffset','descriptorLength','p','limit','end','dyn','words'],actual[-8:]));index=fields['descriptorOffset']+fields['end'];fields['b']=data[index]if index<len(data)else 0;word=int.from_bytes((data[index:index+32]+bytes(32))[:32],'big');mode='End'if fields['end']>=fields['limit']else'Open'if fields['b']==91 else'Other';mapping=maps[mode]
   def expr(text):
    if text.isdecimal():return int(text)
    if text in fields:return fields[text]
    if text=='end+1':return fields['end']+1
    if text=='descriptorOffset+end':return index
    if text=='DataWord(data,descriptorOffset+end)':return word
    raise AssertionError(text)
   for j,s in enumerate(mapping['states']):
    y=logs[i+j];assert y['pc']==s['pc']and y['depth']==1 and stack(y)==prefix+[expr(t)for t in s['stack']]and y['memory']==x['memory'],(path.name,mode,s['pc'],stack(y),prefix+[expr(t)for t in s['stack']])
   y=logs[i+len(mapping['states'])];terminal=fields['returnPc']if mapping['terminalPc']=='returnPc'else mapping['terminalPc'];assert y['pc']==terminal and y['depth']==1 and stack(y)==prefix+[expr(t)for t in mapping['expectedStack']]and y['memory']==x['memory'],(path.name,mode,'terminal');counts[mode]+=1;local[mode]+=1
  fixtures.append(dict(name=doc['fixture']['name'],checkedBlocks=local,trace=str(path.relative_to(ROOT)),traceSha256=sha(path)))
 assert len(fixtures)==91 and counts['Open']>0 and counts['End']>0
 result=dict(status='development-physical-shape-suffix-boundary-passed-not-retained',runtimeSha256=digest,historicalManifest=str((original/'manifest.json').relative_to(ROOT)),historicalManifestSha256=sha(original/'manifest.json'),sourceSha256={str(p.relative_to(ROOT)):sha(p)for p in HERE.iterdir()if p.is_file()},fixtureCount=91,checkedBlocks=counts,unsampledBranches=[n for n,v in counts.items()if v==0],fixtures=fixtures,scope='All reached admitted typeShape suffix-entry/return blocks among 91 complete PC-zero receipts, with exact full lower stack and unchanged physical memory at every step. These projections do not establish arbitrary proof, complete parser or public retention.')
 (out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],counts,'unsampled branches',[n for n,v in counts.items()if v==0])
if __name__=='__main__':main()
