#!/usr/bin/env python3
"""Swap only a reached min/max operand comparison; preserve instruction geometry."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def generate(out):
 out.mkdir(parents=True,exist_ok=True);code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);records=[]
 for family in ['MinU','MinS','MaxU','MaxS']:
  name=family+'T';mapping=json.loads((HERE.parent/'minmax'/(name+'.mapping.json')).read_text());assert mapping['runtimeSha256']==hashlib.sha256(code).hexdigest()
  nodes=[n for n in mapping['states'] if n['opcode'] in [0x10,0x11,0x12,0x13] and sorted(n['stack'][-2:])==['a','b']];assert len(nodes)==1
  node=nodes[0];pc=node['pc'];old=node['opcode'];new={0x10:0x11,0x11:0x10,0x12:0x13,0x13:0x12}[old];mut=bytearray(code);assert mut[pc]==old;mut[pc]=new
  file=out/(name+'-opcode.bin');file.write_bytes(mut);records.append({'name':name+'-opcode','entry':name,'publicFamily':family,'pc':pc,'oldOpcode':old,'newOpcode':new,'sha256':hashlib.sha256(mut).hexdigest(),'baselineSemanticSymbol':'OperationsMinMax'+name+'.SemanticWitness','witnessArguments':[123,456] if family.startswith('Min') else [456,123],'witnessOrdinal':3 if family.startswith('Min') else 4})
 (out/'inventory.json').write_text(json.dumps(records,indent=2)+'\n');print('PASS: four min/max semantic operand comparison candidates')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
