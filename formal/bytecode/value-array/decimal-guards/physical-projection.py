#!/usr/bin/env python3
"""Check all reached decimal guards and arithmetic continuations exactly."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 original=ROOT/'formal/bytecode/value-array/physical-pack-admission/development/raw-pack-receipts-v1';m=json.loads((original/'manifest.json').read_text());assert m['status']=='development-physical-passed-not-retained'
 for p,h in m['sourceSha256'].items():assert sha(ROOT/p)==sha(original/'source-snapshot'/p)==h
 for p,h in m['evidenceSha256'].items():assert sha(original/p)==h
 names=['End','Low','High','Large','DigitCall','ByteToMultiply','MultiplyToAdd','AddToIncrement','IncrementBack'];maps={n:json.loads((HERE/f'{n}.mapping.json').read_text())for n in names};code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert all(x['runtimeSha256']==digest for x in maps.values());counts={n:0 for n in names};fixtures=[]
 for path in sorted((original/'evm-traces').glob('*.json')):
  doc=json.loads(path.read_text())
  if path.name=='results.json':assert isinstance(doc,list)and len(doc)==91;continue
  if path.name=='toolchain.json':assert 'nodeSha256'in doc;continue
  assert doc['runtimeSha256']==digest;logs=doc['trace']['structLogs'];data=bytes.fromhex(doc['fixture']['data'][2:]);local={n:0 for n in maps}
  def stack(x):return [int(v,16)for v in x['stack']]
  for i,x in enumerate(logs):
   if x['depth']!=1 or x['pc']not in {14320,14388,14402,14412,14424}:continue
   actual=stack(x)
   if x['pc']==14320:
    prefix=actual[:-10];fields=dict(zip(['returnPc','descriptorOffset','descriptorLength','p','limit','end','dyn','words','q','k'],actual[-10:]));index=fields['descriptorOffset']+fields['q'];fields['b']=data[index]if index<len(data)else 0;b=fields['b'];mode='End'if fields['q']>=fields['limit']else'Low'if b<48 else'High'if b>57 else'Large'if fields['k']>0xffffffff else'DigitCall';mapping=maps[mode]
   else:
    mode={14388:'ByteToMultiply',14402:'MultiplyToAdd',14412:'AddToIncrement',14424:'IncrementBack'}[x['pc']];mapping=maps[mode];texts=mapping['initialStack'];prefix=actual[:-len(texts)];values=actual[-len(texts):];fields={}
    for t,v in zip(texts,values):
     if t in ['returnPc','descriptorOffset','descriptorLength','p','limit','end','dyn','words','q','k','b']:
      if t in fields:assert fields[t]==v
      fields[t]=v
    if mode=='IncrementBack':
     value=values[texts.index('k*10+b-48')];digit=fields['b']-48;assert value>=digit and(value-digit)%10==0;fields['k']=(value-digit)//10
    index=fields['descriptorOffset']+fields['q'];assert fields['b']==(data[index]if index<len(data)else 0)and 48<=fields['b']<=57 and fields['k']<=0xffffffff
   word=int.from_bytes((data[index:index+32]+bytes(32))[:32],'big')
   def expr(text):
    if text.isdecimal():return int(text)
    if text in fields:return fields[text]
    if text=='descriptorOffset+q':return index
    if text=='DataWord(data,descriptorOffset+q)':return word
    if text=='b-48':return fields['b']-48
    if text=='k*10':return fields['k']*10
    if text=='k*10+b-48':return fields['k']*10+fields['b']-48
    if text=='q+1':return fields['q']+1
    raise AssertionError(text)
   for j,s in enumerate(mapping['states']):
    y=logs[i+j];assert y['pc']==s['pc']and y['depth']==1 and stack(y)==prefix+[expr(t)for t in s['stack']]and y['memory']==x['memory'],(path.name,mode,s['pc'])
   y=logs[i+len(mapping['states'])];assert y['pc']==mapping['terminalPc']and y['depth']==1 and stack(y)==prefix+[expr(t)for t in mapping['expectedStack']]and y['memory']==x['memory'],(path.name,mode,'terminal');counts[mode]+=1;local[mode]+=1
  fixtures.append(dict(name=doc['fixture']['name'],checkedBlocks=local,trace=str(path.relative_to(ROOT)),traceSha256=sha(path)))
 assert len(fixtures)==91 and counts['DigitCall']>0 and all(counts[n]>0 for n in ['ByteToMultiply','MultiplyToAdd','AddToIncrement','IncrementBack'])
 result=dict(status='development-physical-decimal-guards-passed-not-retained',runtimeSha256=digest,historicalManifest=str((original/'manifest.json').relative_to(ROOT)),historicalManifestSha256=sha(original/'manifest.json'),sourceSha256={str(p.relative_to(ROOT)):sha(p)for p in HERE.iterdir()if p.is_file()},fixtureCount=91,checkedBlocks=counts,unsampledBranches=[n for n,v in counts.items()if v==0],fixtures=fixtures,scope='All reached generic decimal guards and arithmetic call continuations among 91 complete EVM receipts, with complete actual lower stack and memory. Unsampled branches, complete imported arithmetic/native graph, arbitrary loop, errors, tuples, codec and public retention remain required.')
 (out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],counts,'unsampled branches',result['unsampledBranches'])
if __name__=='__main__':main()
