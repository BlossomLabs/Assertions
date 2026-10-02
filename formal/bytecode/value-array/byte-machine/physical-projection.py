#!/usr/bin/env python3
"""Validate every actual BYTE step independently with big-endian byte-array indexing."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);a=parser.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 original=ROOT/'formal/bytecode/value-array/physical-pack-admission/development/raw-pack-receipts-v1';m=json.loads((original/'manifest.json').read_text());assert m['status']=='development-physical-passed-not-retained'
 for p,h in m['sourceSha256'].items():assert sha(ROOT/p)==sha(original/'source-snapshot'/p)==h
 for p,h in m['evidenceSha256'].items():assert sha(original/p)==h
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);runtimeSha256=hashlib.sha256(code).hexdigest();fixtures=[];count=0
 for path in sorted((original/'evm-traces').glob('*.json')):
  doc=json.loads(path.read_text())
  if path.name=='results.json':assert isinstance(doc,list) and len(doc)==91;continue
  if path.name=='toolchain.json':assert isinstance(doc,dict) and 'nodeSha256' in doc;continue
  assert isinstance(doc,dict) and doc['runtimeSha256']==runtimeSha256;logs=doc['trace']['structLogs'];checked=[]
  for i,x in enumerate(logs):
   if x['op']!='BYTE':continue
   assert code[x['pc']]==0x1a and len(x['stack'])>=2 and i+1<len(logs)
   stack=[int(v,16)for v in x['stack']];index,word=stack[-1],stack[-2];value=word.to_bytes(32,'big')[index]if index<32 else 0;y=logs[i+1]
   assert y['pc']==x['pc']+1 and [int(v,16)for v in y['stack']]==stack[:-2]+[value]
   assert y['memory']==x['memory'] and y['depth']==x['depth']
   checked.append(dict(pc=x['pc'],index=index,word=hex(word),value=value));count+=1
  fixtures.append(dict(name=doc['fixture']['name'],checkedSteps=len(checked),steps=checked,trace=str(path.relative_to(ROOT)),traceSha256=sha(path)))
 assert len(fixtures)==91 and count>0
 record=dict(status='development-physical-byte-projection-passed-not-retained',runtimeSha256=runtimeSha256,historicalManifest=str((original/'manifest.json').relative_to(ROOT)),historicalManifestSha256=sha(original/'manifest.json'),sourceSha256={str(p.relative_to(ROOT)):sha(p)for p in HERE.iterdir()if p.is_file()},fixtureCount=len(fixtures),checkedByteSteps=count,fixtures=fixtures,scope='All actual BYTE instructions in 91 preserved complete physical receipts: independent big-endian byte indexing, full lower stack, PC, depth and unchanged memory. Universal native BYTE/parser/codec/retained gates remain open; no public coverage.')
 (out/'results.json').write_text(json.dumps(record,indent=2)+'\n');print(record['status'],count,'actual BYTE steps in',len(fixtures),'complete receipts')
if __name__=='__main__':main()
