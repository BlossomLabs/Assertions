#!/usr/bin/env python3
"""Independently compare each reached nonoverflowing checked-increment routine."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False);original=ROOT/'formal/bytecode/value-array/physical-pack-admission/development/raw-pack-receipts-v1';m=json.loads((original/'manifest.json').read_text());assert m['status']=='development-physical-passed-not-retained'
 for p,h in m['sourceSha256'].items():assert sha(ROOT/p)==sha(original/'source-snapshot'/p)==h
 for p,h in m['evidenceSha256'].items():assert sha(original/p)==h
 mapping=json.loads((HERE/'Increment.mapping.json').read_text());code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(code).hexdigest()==mapping['runtimeSha256'];fixtures=[];total=0;outside=0
 for path in sorted((original/'evm-traces').glob('*.json')):
  doc=json.loads(path.read_text())
  if path.name=='results.json':assert isinstance(doc,list)and len(doc)==91;continue
  if path.name=='toolchain.json':assert 'nodeSha256'in doc;continue
  assert doc['runtimeSha256']==mapping['runtimeSha256'];logs=doc['trace']['structLogs'];count=0
  def stack(x):return [int(v,16)for v in x['stack']]
  for i,x in enumerate(logs):
   if x['pc']!=23760 or x['depth']!=1:continue
   initial=stack(x);prefix=initial[:-2];fields=dict(zip(['returnPc','word'],initial[-2:]));value=fields['word']+1
   if value>=MOD:outside+=1;continue
   assert fields['returnPc']<len(code)and code[fields['returnPc']]==91
   expr=lambda text:value if text=='word+1'else int(text)if text.isdecimal()else fields[text]
   for j,s in enumerate(mapping['states']):
    y=logs[i+j];assert y['pc']==s['pc']and y['depth']==1 and stack(y)==prefix+[expr(t)for t in s['stack']]and y['memory']==x['memory'],(path.name,s['pc'])
   y=logs[i+len(mapping['states'])];assert y['pc']==fields['returnPc']and y['depth']==1 and stack(y)==prefix+[value]and y['memory']==x['memory'];count+=1;total+=1
  fixtures.append(dict(name=doc['fixture']['name'],checkedCalls=count,trace=str(path.relative_to(ROOT)),traceSha256=sha(path)))
 assert len(fixtures)==91 and total>0
 result=dict(status='development-physical-checked-increment-projection-passed-not-retained',runtimeSha256=mapping['runtimeSha256'],historicalManifest=str((original/'manifest.json').relative_to(ROOT)),historicalManifestSha256=sha(original/'manifest.json'),sourceSha256={str(p.relative_to(ROOT)):sha(p)for p in HERE.iterdir()if p.is_file()},fixtureCount=91,checkedCalls=total,reachedOverflowBranchesOutsideOwner=outside,fixtures=fixtures,scope='Every reached nonoverflowing checked-increment actual PC/full lower stack/physical memory/caller return among 91 complete preserved receipts. Overflow/panic and full native parser/codec/retained public gates remain open.')
 (out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],total,'exact checked-increment calls')
if __name__=='__main__':main()
