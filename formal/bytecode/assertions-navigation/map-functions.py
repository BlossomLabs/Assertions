#!/usr/bin/env python3
"""Locate remaining Assertions/AbiCodec instruction ranges; source maps are discovery only."""
from pathlib import Path
import json,hashlib
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
artifact=json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text());code=bytes.fromhex(artifact['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
outputs=list((ROOT/'artifacts/build-info').glob('*.output.json'));matches=[]
for path in outputs:
 output=json.loads(path.read_text())['output']
 for source,contracts in output['contracts'].items():
  if 'Assertions' in contracts and contracts['Assertions']['evm']['deployedBytecode']['object']==code.hex():matches.append((path,output,contracts['Assertions']))
assert len(matches)==1
path,output,contract=matches[0]
functions=[]
def visit(node,source,sourceId):
 if isinstance(node,dict):
  if node.get('nodeType')=='FunctionDefinition' and node.get('body'):
   start,length,_=map(int,node['src'].split(':'));functions.append({'source':source,'sourceId':sourceId,'name':node.get('name',''),'visibility':node.get('visibility'),'start':start,'length':length,'pcs':[],'jumpdestinations':[],'fullSpanJumpdestinations':[]})
  for value in node.values():visit(value,source,sourceId)
 elif isinstance(node,list):
  for value in node:visit(value,source,sourceId)
for source,item in output['sources'].items():
 if source.endswith('/Assertions.sol') or source.endswith('/AbiCodec.sol') or source.endswith('/ERC8211.sol'):visit(item['ast'],source,item['id'])
rows=contract['evm']['deployedBytecode']['sourceMap'].split(';');current=['','','','',''];pc=0
for row in rows:
 fields=row.split(':');current=[fields[i] if i<len(fields) and fields[i] else current[i] for i in range(5)]
 start,length,sourceId=map(int,current[:3]);op=code[pc]
 for f in functions:
  if sourceId==f['sourceId'] and f['start']<=start and start+length<=f['start']+f['length']:
   f['pcs'].append(pc)
   if op==91:
    f['jumpdestinations'].append(pc)
    if (start,length)==(f['start'],f['length']):f['fullSpanJumpdestinations'].append(pc)
 pc+=1+(op-95 if 96<=op<=127 else 0)
out=HERE/'development/codec-map-v1.json';out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps({'runtimeSha256':digest,'compilerOutputSha256':hashlib.sha256(path.read_bytes()).hexdigest(),'scope':'Source-map discovery only. No compiler correctness or native proof claim. Every candidate helper boundary needs physical opcode/stack witnesses and universal native execution proofs.','functions':functions},indent=2)+'\n')
for f in functions:
 if f['name'] in ['byteAt','typeShape','suffixStart','_navigate','_navArrayStep','_navTupleStep']:
  print(f['name'],'instructions',len(f['pcs']),'full-span labels',f['fullSpanJumpdestinations'])
