#!/usr/bin/env python3
"""Inventory exact ABI/source-AST admission obligations; never a verified ledger."""
import argparse,gzip,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def walk(v):
 if isinstance(v,dict):
  yield v
  for x in v.values():yield from walk(x)
 elif isinstance(v,list):
  for x in v:yield from walk(x)
def canonical(t):
 return '('+','.join(canonical(x) for x in t['components'])+')'+t['type'][5:] if t['type'].startswith('tuple') else t['type']
def main():
 p=argparse.ArgumentParser();p.add_argument('--identity',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();identity=a.identity.resolve()
 inv=json.loads((HERE/'inventory.json').read_text());artifact=ROOT/'artifacts/contracts/Operations.sol/Operations.json';abi=json.loads(artifact.read_text());source=ROOT/'contracts/Operations.sol'
 runtime=bytes.fromhex(abi['deployedBytecode'][2:]);assert len(runtime)==inv['runtimeBytes'] and hashlib.sha256(runtime).hexdigest()==inv['runtimeSha256']
 assert runtime==(identity/'Operations.runtime.bin').read_bytes()
 compiled=list(identity.glob('*-output.json.gz'));assert len(compiled)==1;job=json.loads(gzip.decompress(compiled[0].read_bytes()));key='project/contracts/Operations.sol';ast=job['sources'][key]['ast'];contract=next(n for n in ast['nodes'] if n.get('nodeType')=='ContractDefinition' and n.get('name')=='Operations')
 methods=job['contracts'][key]['Operations']['evm']['methodIdentifiers'];assert methods=={p['signature']:p['selector'] for p in inv['publicEntries']}
 public={n['functionSelector']:n for n in contract['nodes'] if n.get('nodeType')=='FunctionDefinition' and n.get('visibility') in ['external','public'] and n.get('kind')=='function'}
 assert len(public)==92 and set(public)==set(methods.values())
 enums={n['id']:[m['name'] for m in n['members']] for n in walk(ast) if n.get('nodeType')=='EnumDefinition'}
 entries=[]
 for item in inv['publicEntries']:
  sig=item['signature'];fn=public[item['selector']];f=next(f for f in abi['abi'] if f['type']=='function' and f['name']+'('+','.join(canonical(i) for i in f['inputs'])+')'==sig)
  assert len(f['inputs'])==len(fn['parameters']['parameters'])
  args=[]
  for ordinal,(x,node) in enumerate(zip(f['inputs'],fn['parameters']['parameters'])):
   t=x['type'];record={'ordinal':ordinal,'name':x['name'],'abiType':t,'internalType':x['internalType'],'headOffset':4+32*ordinal}
   if t in ['uint256','int256','bytes32']:record.update(kind='unrestricted-word',rawWordAdmission='All 256-bit patterns; int256 uses exact two’s-complement interpretation.')
   elif t=='address':record.update(kind='address160',rawWordAdmission='Upper 96 bits must be zero; exact dirty-word physical rejection remains to be proved.')
   elif x['internalType'].startswith('enum '):
    e=node['typeName']['referencedDeclaration'];values=enums[e];record.update(kind='source-enum',members=values,minimum=0,maximum=len(values)-1,rawWordAdmission='Exact compiler clean-width and enum-domain admission/rejection, including physical error receipts, remains to be proved.')
   elif t=='bytes[]':record.update(kind='nested-dynamic-bytes-array',rawWordAdmission='Raw relative offsets, array length, element offsets/lengths, windows and fitting allocation must all be checked from actual calldata.')
   elif t in ['bytes','string']:record.update(kind='dynamic-byte-window',rawWordAdmission='Raw relative offset, length and complete window checks must be proved; alignment/padding behavior follows actual compiler instructions, with no assumed canonical ABI restriction.')
   else:raise AssertionError(('Uninventoried ABI type',sig,t))
   args.append(record)
  dynamic=any(r['kind'].startswith('dynamic') or r['kind'].startswith('nested') for r in args)
  returns=[x['type'] for x in f['outputs']]
  entry={**item,'status':'admission-obligations-open','minimumAbiHeadBytes':4+32*len(args),'minimumHeadNote':'ABI head layout inventory only; this value does not prove compiler admission or complete dynamic payloads.','arguments':args,'hasDynamicInput':dynamic,'outputs':returns,'physicalOutputObligations':'Raw direct-return typed ABI envelope, per intentional source encode function.' if fn['name']=='encode' else 'Actual offset/length/header/payload/padding physical serialization and RETURN.' if any(t in ['bytes','string','bytes[]'] for t in returns) else 'Actual scalar ABI word physical serialization and RETURN.','sourceFunctionAstSha256':hashlib.sha256(json.dumps(fn,sort_keys=True,separators=(',',':')).encode()).hexdigest(),'sourceFunctionId':fn['id'],'requiredProofs':['Full PC-zero nonpayable and selector admission.','Assigned entry raw head and every input-domain/window check; all malformed reached rejection receipts.','Actual body instructions and branches/loops to independently specified source/math/world outcome.','Actual physical memory/output or source-error serialization.','Fresh complete retained native/CSV/audit/regeneration/tool/input graph, exact EVM receipts, semantic byte faults and independent evidence check.']}
  entries.append(entry)
 assert len(entries)==92
 result={'schemaVersion':1,'status':'generated-obligation-inventory-not-verified','sourceSha256':sha(source),'runtimeSha256':inv['runtimeSha256'],'runtimeBytes':len(runtime),'abiArtifactSha256':sha(artifact),'compilerOutputSha256':sha(compiled[0]),'entryCount':92,'staticInputEntries':sum(not x['hasDynamicInput'] for x in entries),'dynamicInputEntries':sum(x['hasDynamicInput'] for x in entries),'entries':entries,'assumptions':['Exact compiler input/runtime and source AST identity are checked inputs, not whole-compiler correctness.','Finite fitting representations and sufficient reached execution resources remain explicit.','External observations bind actual execution context and history, including self/caller when reached; no fixed deployment address premise.','MODEXP faithful successful exact 32-byte mathematical reply remains explicit. Real exp/log approximation accuracy remains open.','No source-only, fixture-only, gas, deployment, complexity or performance claim.']}
 a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(result,indent=2)+'\n');print('PASS: 92 compiler ABI/source-AST bound admission obligations, not verified coverage')
if __name__=='__main__':main()
