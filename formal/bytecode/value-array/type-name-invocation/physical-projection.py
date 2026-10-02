#!/usr/bin/env python3
"""Independently compare all reached valid-bounds non-tuple typeShape prefixes."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 original=ROOT/'formal/bytecode/value-array/physical-pack-admission/development/raw-pack-receipts-v1';m=json.loads((original/'manifest.json').read_text());assert m['status']=='development-physical-passed-not-retained'
 for p,h in m['sourceSha256'].items():assert sha(ROOT/p)==sha(original/'source-snapshot'/p)==h
 for p,h in m['evidenceSha256'].items():assert sha(original/p)==h
 mapping=json.loads((HERE/'Invocation.mapping.json').read_text());code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(code).hexdigest()==mapping['runtimeSha256'];fixtures=[];total=0;excluded=0
 for path in sorted((original/'evm-traces').glob('*.json')):
  doc=json.loads(path.read_text())
  if path.name=='results.json':assert isinstance(doc,list)and len(doc)==91;continue
  if path.name=='toolchain.json':assert 'nodeSha256'in doc;continue
  assert doc['runtimeSha256']==mapping['runtimeSha256'];logs=doc['trace']['structLogs'];data=bytes.fromhex(doc['fixture']['data'][2:]);count=0
  def stack(x):return [int(v,16)for v in x['stack']]
  for i,x in enumerate(logs):
   if x['pc']!=13839 or x['depth']!=1:continue
   initial=stack(x);prefix=initial[:-5];fields=dict(zip(['returnPc','descriptorOffset','descriptorLength','p','limit'],initial[-5:]));index=fields['descriptorOffset']+fields['p'];fields['b']=data[index]if index<len(data)else 0
   if not fields['p']<fields['limit']<=fields['descriptorLength']or fields['b']==40:excluded+=1;continue
   def expr(text):
    if text=='DataWord(data,descriptorOffset+p)':return int.from_bytes((data[index:index+32]+bytes(32))[:32],'big')
    if text=='G.Modulus()-40':return MOD-40
    if text=='((G.Modulus()-40+b)%G.Modulus())':return (MOD-40+fields['b'])%MOD
    if text=='descriptorOffset+p':return index
    return int(text)if text.isdecimal()else fields[text]
   for j,s in enumerate(mapping['states']):
    y=logs[i+j];assert y['pc']==s['pc']and y['depth']==1 and stack(y)==prefix+[expr(t)for t in s['stack']]and y['memory']==x['memory'],(path.name,s['pc'])
   y=logs[i+len(mapping['states'])];assert y['pc']==mapping['terminalPc']and y['depth']==1 and stack(y)==prefix+[expr(t)for t in mapping['expectedStack']]and y['memory']==x['memory'];count+=1;total+=1
  fixtures.append(dict(name=doc['fixture']['name'],checkedPrefixes=count,trace=str(path.relative_to(ROOT)),traceSha256=sha(path)))
 assert len(fixtures)==91 and total>0
 result=dict(status='development-physical-type-name-prefix-projection-passed-not-retained',runtimeSha256=mapping['runtimeSha256'],historicalManifest=str((original/'manifest.json').relative_to(ROOT)),historicalManifestSha256=sha(original/'manifest.json'),sourceSha256={str(p.relative_to(ROOT)):sha(p)for p in HERE.iterdir()if p.is_file()},fixtureCount=91,checkedPrefixes=total,otherBranchesOutsideOwner=excluded,fixtures=fixtures,scope='Every reached admitted valid-bounds non-LPAREN typeShape prefix through scanName call, with exact PC/full lower stack/physical memory among 91 preserved complete receipts. Other bound/error/tuple/suffix/codec branches and native/public retained gates remain open.')
 (out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],total,'exact 37-instruction prefixes;',excluded,'reached branches outside this owner; full parser remains open')
if __name__=='__main__':main()
