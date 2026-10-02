#!/usr/bin/env python3
"""Independently compare all actual allocation/call states with eight preserved EVM traces."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);args=parser.parse_args();out=args.output.resolve();out.mkdir(parents=True,exist_ok=False)
 mapping=json.loads((HERE/'Invocation.mapping.json').read_text());code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(code).hexdigest()==mapping['runtimeSha256']
 original=ROOT/'formal/bytecode/value-array/physical-pack-admission/development/raw-pack-receipts-v1';manifest=json.loads((original/'manifest.json').read_text());assert manifest['status']=='development-physical-passed-not-retained'
 for p,h in manifest['sourceSha256'].items():assert sha(ROOT/p)==sha(original/'source-snapshot'/p)==h
 for p,h in manifest['evidenceSha256'].items():assert sha(original/p)==h
 results=[]
 for path in sorted((original/'evm-traces').glob('unpackArray-*.json')):
  doc=json.loads(path.read_text());fixture=doc['fixture'];assert doc['runtimeSha256']==mapping['runtimeSha256'];assert not doc['trace']['failed'];logs=doc['trace']['structLogs'];start=next(i for i,x in enumerate(logs)if x['pc']==12814)
  def memory(x):return bytes.fromhex(''.join(w.removeprefix('0x')for w in x['memory']))
  initial=memory(logs[start]);stack=[int(x,16)for x in logs[start]['stack']];prefix=stack[:-4];fields=dict(zip(['returnPc','descriptorOffset','descriptorLength','encodedPointer'],stack[-4:]));fields['fp']=int.from_bytes(initial[64:96],'big')
  def expr(text):
   for key,value in sorted(fields.items(),key=lambda x:-len(x[0])):text=text.replace(key,str(value))
   assert re.fullmatch('[0-9+ ]+',text),text
   return sum(map(int,text.split('+')))
  def store(mem,offset,value):
   result=bytearray(mem);result.extend(bytes(max(0,((offset+32+31)//32*32)-len(result))));result[offset:offset+32]=value.to_bytes(32,'big');return bytes(result)
  pointer=store(initial,64,fields['fp']+192);memories={'mem':initial,'H.Pointer(mem,fp)':pointer};nextMem=pointer
  for count in range(1,7):nextMem=store(nextMem,fields['fp']+32*(count-1),0);memories['H.Zero(mem,fp,'+str(count)+')']=nextMem
  errors=[]
  for i,state in enumerate(mapping['states']):
   actual=logs[start+i]
   if actual['pc']!=state['pc']:errors.append('PC differs at step '+str(i));break
   if [int(x,16)for x in actual['stack']]!=prefix+[expr(x)for x in state['stack']]:errors.append('Stack differs at PC '+str(state['pc']));break
   if memory(actual)!=memories[state['memory']]:errors.append('Memory differs at PC '+str(state['pc']));break
  final=logs[start+len(mapping['states'])];expected=prefix+[fields[x]for x in ['returnPc','descriptorOffset','descriptorLength','encodedPointer']]+[96,fields['fp'],12879,fields['descriptorOffset'],fields['descriptorLength']]
  if final['pc']!=9893 or [int(x,16)for x in final['stack']]!=expected or memory(final)!=nextMem:errors.append('Complete terminal shape-call frame differs')
  results.append(dict(name=fixture['name'],passed=not errors,errors=errors,mappedInstructions=len(mapping['states']),statePointer=fields['fp'],trace=str(path.relative_to(ROOT)),traceSha256=sha(path)))
 assert len(results)==8
 record=dict(status='development-physical-projection-passed-not-retained'if all(x['passed']for x in results)else'development-physical-projection-failed',runtimeSha256=mapping['runtimeSha256'],historicalManifest=str((original/'manifest.json').relative_to(ROOT)),historicalManifestSha256=sha(original/'manifest.json'),mappingSha256=sha(HERE/'Invocation.mapping.json'),sourceSha256={str(p.relative_to(ROOT)):sha(p)for p in HERE.iterdir()if p.is_file()},fixtures=results,scope='Eight complete preserved physical receipts and every 50 mapped allocation/call PC/full stack/physical memory state. Universal descriptor parser, codec loops, all errors/serialization and complete native/retained public closure remain open.')
 (out/'results.json').write_text(json.dumps(record,indent=2)+'\n');print(record['status'],len(results),'complete 50-step allocation/call projections');raise SystemExit(0 if all(x['passed']for x in results)else 1)
if __name__=='__main__':main()
