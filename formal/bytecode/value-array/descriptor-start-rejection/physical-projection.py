#!/usr/bin/env python3
"""Project every reached empty-name rejection through complete physical REVERT."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--output',type=Path,required=True);a=ap.parse_args();out=a.output.resolve();assert not out.exists()
 receipt=ROOT/'formal/bytecode/value-array/physical-descriptor-start-errors/development/receipts-v1';m=json.loads((receipt/'manifest.json').read_text());assert m['completedAt']and m['status']=='development-physical-passed-not-retained'and m['concreteFixtures']==8
 assert m['inputsUnchanged']and m['concreteToolsUnchanged']and all(c['passed']and c['exitCode']==0 for c in m['checks'])
 for path,digest in m['sourceSha256'].items():assert sha(ROOT/path)==digest
 for path,digest in m['evidenceSha256'].items():assert sha(receipt/path)==digest
 t=m['concreteToolchain']
 for key in ['hardhatEntry','edrEntry','nativeBinding']:assert sha(Path(t[key]))==t[key+'Sha256']
 assert sha(Path(t['nodeExecutable']))==t['nodeSha256']and sha(ROOT/'pnpm-lock.yaml')==t['lockfileSha256']
 mapping=json.loads((HERE/'PAtLimit.mapping.json').read_text());code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256'];assert sha(ROOT/'artifacts/contracts/Collections.sol/Collections.json')==m['sourceSha256']['artifacts/contracts/Collections.sol/Collections.json'];assert hashlib.sha256(code).hexdigest()==pin
 assert mapping['runtimeSha256']==pin
 for pc,value in mapping['requiredBytes'].items():assert code[int(pc)]==value
 mem=lambda x:bytes.fromhex(''.join(w.removeprefix('0x')for w in x['memory']));stack=lambda x:[int(v,16)for v in x['stack']]
 def store(data,off,value):
  n=max(len(data),((off+32+31)//32)*32);b=bytearray(data+b'\0'*(n-len(data)));b[off:off+32]=value.to_bytes(32,'big');return bytes(b)
 header=int(mapping['errorSelector'],16)<<(28*8);fixtures=[];count=0;instructions=0;operations=set()
 for file in sorted((receipt/'evm-traces').glob('*.json')):
  doc=json.loads(file.read_text())
  if'trace'not in doc:continue
  f=doc['fixture'];trace=doc['trace'];assert doc['runtimeSha256']==pin and trace['failed']and trace['structLogs'][0]['pc']==0;logs=trace['structLogs'];calls=[]
  for i,x in enumerate(logs):
   if x['pc']!=13839:continue
   s=stack(x);fields=s[-5:];prefix=s[:-5];ret,off,length,p,limit=fields
   if p<limit:continue
   assert limit<=length and len(prefix)<=1011
   initial=mem(x);assert len(initial)%32==0;fp=int.from_bytes(initial[64:96],'big');assert fp>=96 and fp+64<2**256
   vals=dict(returnPc=ret,descriptorOffset=off,descriptorLength=length,p=p,limit=limit,fp=fp);first=store(initial,fp,header);complete=store(first,fp+4,p)
   def evaluate(expr):
    if expr.isdecimal():return int(expr)
    if expr in vals:return vals[expr]
    if expr=='fp+4':return fp+4
    if expr=='fp+36':return fp+36
    raise AssertionError(('unexpected generated expression',expr))
   for k,e in enumerate(mapping['states']):
    y=logs[i+k];assert y['depth']==1 and y['pc']==e['pc'],(f['name'],k,'PC')
    assert stack(y)==prefix+[evaluate(v)for v in e['stack']],(f['name'],k,'full stack')
    expected=initial if e['memory']=='mem'else first if e['memory']=='H.First(mem,fp)'else complete if e['memory']=='H.Complete(mem,fp,p)'else None;assert expected is not None and mem(y)==expected,(f['name'],k,'full memory')
   end=i+len(mapping['states']);assert end==len(logs)and logs[-1]['op']=='REVERT'
   packet=bytes.fromhex(mapping['errorSelector'])+p.to_bytes(32,'big');assert complete[fp:fp+36]==packet and trace['returnValue'].removeprefix('0x')==packet.hex()==f['expected']and p==f['position']
   calls.append(dict(startIndex=i,completeInstructions=len(mapping['states']),prefixWords=len(prefix),position=p,freePointer=fp));count+=1;instructions+=len(mapping['states']);operations.add(f['operation'])
  if calls:fixtures.append(dict(name=f['name'],trace=str(file.relative_to(ROOT)),traceSha256=sha(file),calls=calls))
 assert count==8 and operations=={'packArray','unpackArray'}
 out.mkdir(parents=True);j=dict(status='development-physical-complete-p-at-limit-rejections-passed-not-retained',historicalManifest=str((receipt/'manifest.json').relative_to(ROOT)),historicalManifestSha256=sha(receipt/'manifest.json'),runtimeSha256=pin,sourceSha256={str(p.relative_to(ROOT)):sha(p)for p in HERE.iterdir()if p.is_file()},checkedCompleteRejections=count,checkedSpanInstructions=instructions,fixtures=fixtures,scope='Every reached p-at-limit rejection among eight full PC-zero error receipts, complete actual mapped PC and lower stack and physical memory through exact 36-byte REVERT; universal preceding scanner/parser error connection, native closure and retained public admission remain open. No public credit.');(out/'results.json').write_text(json.dumps(j,indent=2)+'\n');print(j['status'],count,instructions)
if __name__=='__main__':main()
