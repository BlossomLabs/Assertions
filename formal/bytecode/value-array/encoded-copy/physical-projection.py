#!/usr/bin/env python3
"""Compare all55 actual copy states with preserved complete EVM receipts.

Finite physical development only; it does not establish universal native proof.
"""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);args=parser.parse_args();out=args.output.resolve();out.mkdir(parents=True,exist_ok=False)
 mapping=json.loads((HERE/'Copy.mapping.json').read_text());artifact=json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text());code=bytes.fromhex(artifact['deployedBytecode'][2:]);assert hashlib.sha256(code).hexdigest()==mapping['runtimeSha256']
 original=ROOT/'formal/bytecode/value-array/physical-pack-admission/development/raw-pack-receipts-v1';manifest=json.loads((original/'manifest.json').read_text());assert manifest['status']=='development-physical-passed-not-retained'
 for p,h in manifest['sourceSha256'].items():assert sha(ROOT/p)==sha(original/'source-snapshot'/p)==h
 for p,h in manifest['evidenceSha256'].items():assert sha(original/p)==h
 results=[]
 for path in sorted((original/'evm-traces').glob('unpackArray-*.json')):
  doc=json.loads(path.read_text());fixture=doc['fixture'];assert doc['runtimeSha256']==mapping['runtimeSha256'];assert not doc['trace']['failed'];data=bytes.fromhex(fixture['data'][2:]);logs=doc['trace']['structLogs'];start=next(i for i,x in enumerate(logs)if x['pc']==7262)
  word=lambda off:int.from_bytes((data[off:off+32]+bytes(32))[:32],'big')
  fields=dict(descriptorOffset=word(4)+36,descriptorLength=word(word(4)+4),encodedOffset=word(36)+36,encodedLength=word(word(36)+4),fp=128)
  length=fields['encodedLength'];rounded=(length+31)//32*32;free=128+rounded+32
  def expr(text):
   values=dict(fields);values.update({'H.Quot(encodedLength)':(length+31)//32,'H.Rounded(encodedLength)':rounded,'H.Free(fp,encodedLength)':free})
   for key,value in sorted(values.items(),key=lambda x:-len(x[0])):text=text.replace(key,str(value))
   assert re.fullmatch('[0-9+ ]+',text),text
   return sum(map(int,text.split('+')))
  def store(mem,off,value):
   mem=bytearray(mem);size=max(len(mem),(off+32+31)//32*32);mem.extend(bytes(size-len(mem)));mem[off:off+32]=value.to_bytes(32,'big');return bytes(mem)
  initial=bytes.fromhex(''.join(x.removeprefix('0x') for x in logs[start]['memory']));pointer=store(initial,64,free);head=store(pointer,128,length);copied=bytearray(head);size=max(len(copied),(160+length+31)//32*32);copied.extend(bytes(size-len(copied)));copied[160:160+length]=data[fields['encodedOffset']:fields['encodedOffset']+length];complete=store(copied,160+length,0)
  memories={'mem':initial,'H.Pointer(mem,fp,encodedLength)':pointer,'H.Head(mem,fp,encodedLength)':head,'H.Copied(mem,fp,encodedOffset,encodedLength,data)':bytes(copied),'H.Complete(mem,fp,encodedOffset,encodedLength,data)':complete}
  prefix=[int(x,16)for x in logs[start]['stack'][:2]];errors=[]
  for i,state in enumerate(mapping['states']):
   actual=logs[start+i]
   if actual['pc']!=state['pc']:errors.append('PC differs at step'+str(i));break
   if [int(x,16)for x in actual['stack']]!=prefix+[expr(x)for x in state['stack']]:errors.append('Stack differs at PC'+str(state['pc']));break
   if bytes.fromhex(''.join(x.removeprefix('0x') for x in actual['memory']))!=memories[state['memory']]:errors.append('Memory differs at PC'+str(state['pc']));break
  final=logs[start+len(mapping['states'])];expected=prefix+[fields[x]for x in ['descriptorOffset','descriptorLength','encodedOffset','encodedLength']]+[96,5704,fields['descriptorOffset'],fields['descriptorLength'],128]
  if final['pc']!=12814 or [int(x,16)for x in final['stack']]!=expected or bytes.fromhex(''.join(x.removeprefix('0x') for x in final['memory']))!=complete:errors.append('Complete terminal copy frame differs')
  results.append(dict(name=fixture['name'],passed=not errors,errors=errors,mappedInstructions=len(mapping['states']),encodedLength=length,trace=str(path.relative_to(ROOT)),traceSha256=sha(path)))
 assert len(results)==8
 record=dict(status='development-physical-projection-passed-not-retained'if all(x['passed']for x in results)else'development-physical-projection-failed',runtimeSha256=mapping['runtimeSha256'],historicalManifest=str((original/'manifest.json').relative_to(ROOT)),historicalManifestSha256=sha(original/'manifest.json'),mappingSha256=sha(HERE/'Copy.mapping.json'),sourceSha256={str(p.relative_to(ROOT)):sha(p)for p in HERE.iterdir()if p.is_file()},fixtures=results,scope='Eight complete physical receipts and all55 mapped copy instructions/terminal stacks/memory. Full parser/value/library semantics, universal native closure and retained public evidence remain open.')
 (out/'results.json').write_text(json.dumps(record,indent=2)+'\n');print(record['status'],len(results),'complete55-step copy projections');raise SystemExit(0 if all(x['passed']for x in results)else 1)
if __name__=='__main__':main()
