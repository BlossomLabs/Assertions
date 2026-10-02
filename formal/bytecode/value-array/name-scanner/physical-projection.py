#!/usr/bin/env python3
"""Independently compare every reached scanName iteration against byte-array calldata."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);a=parser.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 original=ROOT/'formal/bytecode/value-array/physical-pack-admission/development/raw-pack-receipts-v1';m=json.loads((original/'manifest.json').read_text());assert m['status']=='development-physical-passed-not-retained'
 for p,h in m['sourceSha256'].items():assert sha(ROOT/p)==sha(original/'source-snapshot'/p)==h
 for p,h in m['evidenceSha256'].items():assert sha(original/p)==h
 maps={name:json.loads((HERE/(name+'.mapping.json')).read_text())for name in ['End','Digit','Lower','Other']};code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);runtime=hashlib.sha256(code).hexdigest();assert all(x['runtimeSha256']==runtime for x in maps.values())
 counts={name:0 for name in maps};fixtures=[];total=0;entryCount=0
 for path in sorted((original/'evm-traces').glob('*.json')):
  doc=json.loads(path.read_text())
  if path.name=='results.json':assert isinstance(doc,list)and len(doc)==91;continue
  if path.name=='toolchain.json':assert 'nodeSha256'in doc;continue
  assert doc['runtimeSha256']==runtime;data=bytes.fromhex(doc['fixture']['data'][2:]);logs=doc['trace']['structLogs'];checked=[]
  def stack(x):return [int(v,16)for v in x['stack']]
  for i,x in enumerate(logs):
   if x['depth']!=1:continue
   if x['pc']==19245:
    assert logs[i+1]['pc']==19246 and logs[i+2]['pc']==19247
    assert stack(logs[i+1])==stack(x) and stack(logs[i+2])==stack(x)+[stack(x)[-2]]
    assert logs[i+1]['memory']==logs[i+2]['memory']==x['memory'];entryCount+=1
   if x['pc']!=19247:continue
   initial=stack(x);prefix=initial[:-6];fields=dict(zip(['returnPc','descriptorOffset','descriptorLength','p','limit','q'],initial[-6:]));index=fields['descriptorOffset']+fields['q'];byte=data[index]if index<len(data)else 0;fields['b']=byte
   name='End'if fields['q']>=fields['limit']else'Digit'if 48<=byte<58 else'Lower'if 97<=byte<123 else'Other';mapping=maps[name]
   def expr(text):
    if text=='DataWord(data,descriptorOffset+q)':return int.from_bytes((data[index:index+32]+bytes(32))[:32],'big')
    for k,v in sorted(fields.items(),key=lambda x:-len(x[0])):text=text.replace(k,str(v))
    assert re.fullmatch('[0-9+ ]+',text),text
    return sum(map(int,text.split('+')))
   for j,s in enumerate(mapping['states']):
    actual=logs[i+j];assert actual['pc']==s['pc']and actual['depth']==1,(path.name,name,j,s['pc'],actual['pc'])
    assert stack(actual)==prefix+[expr(t)for t in s['stack']],(path.name,name,s['pc'])
    assert actual['memory']==x['memory'],(path.name,name,'memory',s['pc'])
   final=logs[i+len(mapping['states'])];advance=1if name in {'Digit','Lower'}else 0
   assert final['pc']==mapping['terminalPc']and stack(final)==initial[:-1]+[fields['q']+advance]and final['memory']==x['memory']and final['depth']==1
   checked.append(dict(branch=name,startIndex=fields['q'],byte=byte,instructionCount=len(mapping['states']),terminalPc=final['pc']));counts[name]+=1;total+=1
  fixtures.append(dict(name=doc['fixture']['name'],checkedIterations=len(checked),iterations=checked,trace=str(path.relative_to(ROOT)),traceSha256=sha(path)))
 assert len(fixtures)==91 and total>0 and entryCount>0
 record=dict(status='development-physical-name-scanner-projection-passed-not-retained',runtimeSha256=runtime,historicalManifest=str((original/'manifest.json').relative_to(ROOT)),historicalManifestSha256=sha(original/'manifest.json'),sourceSha256={str(p.relative_to(ROOT)):sha(p)for p in HERE.iterdir()if p.is_file()},fixtureCount=len(fixtures),checkedEntries=entryCount,checkedIterations=total,branchCounts=counts,fixtures=fixtures,scope='Every reached scanName entry and exact iteration PC/full lower stack/physical memory/terminal in 91 preserved complete receipts, independently reconstructing calldata bytes and classification. Universal native scanner/parser/codec and retained gates remain open; no public coverage.')
 (out/'results.json').write_text(json.dumps(record,indent=2)+'\n');print(record['status'],entryCount,'entries',total,'iterations',counts)
if __name__=='__main__':main()
