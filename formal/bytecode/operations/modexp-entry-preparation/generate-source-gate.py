#!/usr/bin/env python3
"""Complete AST fingerprint for all modular-power entries and reached source helpers."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def read(p):return json.loads(p.read_text())
def normalize(n):
 if isinstance(n,dict):return {k:normalize(v) for k,v in n.items() if k not in ['id','src','referencedDeclaration','scope','typeDescriptions']}
 if isinstance(n,list):return [normalize(v) for v in n]
 return n
def generate(out):
 artifact=read(ROOT/'artifacts/contracts/Operations.sol/Operations.json');build=read(ROOT/'artifacts/build-info'/(artifact['buildInfoId']+'.output.json'));inputJob=read(ROOT/'artifacts/build-info'/(artifact['buildInfoId']+'.json'))
 content=(ROOT/'contracts/Operations.sol').read_bytes();assert inputJob['input']['sources'][artifact['inputSourceName']]['content'].encode()==content
 ast=build['output']['sources'][artifact['inputSourceName']]['ast'];contracts=[n for n in ast['nodes'] if n.get('nodeType')=='ContractDefinition' and n.get('name')=='Operations'];assert len(contracts)==1
 entries=[];errorSelectors={}
 for n in contracts[0]['nodes']:
  if n.get('nodeType')=='ErrorDefinition' and n.get('name')=='ModularInverseDoesNotExist':errorSelectors[n['name']]=n['errorSelector']
  if n.get('nodeType')=='FunctionDefinition' and n.get('name') in ['powMod','_powMod','_inverseMod','_magnitude','_signedMagnitude','_panic']:
   types=[p['typeDescriptions']['typeString'] for p in n['parameters']['parameters']];sig=n['name']+'('+','.join(types)+')';body=normalize(n);digest=hashlib.sha256(json.dumps(body,sort_keys=True,separators=(',',':')).encode()).hexdigest();entries.append({'signature':sig,'selector':read(HERE.parent/'inventory.json')['compilerIdentity']['methodIdentifiers'].get(sig),'completeFunctionAstSha256':digest,'normalizedFunction':body})

 assert {e['signature'] for e in entries if e['signature'].startswith('powMod(')}=={'powMod(uint256,uint256,uint256)','powMod(int256,uint256,int256)','powMod(uint256,int256,uint256)','powMod(int256,int256,int256)'}
 assert len(entries)==9 and errorSelectors=={'ModularInverseDoesNotExist':'1bba72ee'}

 out.mkdir(parents=True,exist_ok=True);(out/'source-gate.json').write_text(json.dumps({'schemaVersion':1,'status':'preparation-source-gate-not-proof','sourceSha256':hashlib.sha256(content).hexdigest(),'buildInfoId':artifact['buildInfoId'],'entries':entries,'errorSelectors':errorSelectors,'scope':'Complete current public powMod and helper function AST fingerprints, including parameters/visibility/mutability/return declarations and entire bodies. Stable compiler identity/exact instruction generation/native correspondence remain separately required; no public claim.'},indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
