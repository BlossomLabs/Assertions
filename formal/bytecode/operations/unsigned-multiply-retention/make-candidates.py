#!/usr/bin/env python3
"""Swap the reached MUL operand opcode with ADD; preserve byte geometry."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def generate(out):
 out.mkdir(parents=True,exist_ok=True);code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);records=[]
 for family in ['MulU']:
  name=family+'Ok';mapping=json.loads((HERE.parent/'unsigned-multiply'/(name+'.mapping.json')).read_text());assert mapping['runtimeSha256']==hashlib.sha256(code).hexdigest()
  nodes=[n for n in mapping['states'] if n['opcode'] ==0x02 and sorted(n['stack'][-2:])==['a','b']];assert len(nodes)==1
  node=nodes[0];pc=node['pc'];old=node['opcode'];new=0x01;mut=bytearray(code);assert mut[pc]==old;mut[pc]=new
  file=out/(name+'-opcode.bin');file.write_bytes(mut);records.append({'name':name+'-opcode','entry':name,'publicFamily':family,'pc':pc,'oldOpcode':old,'newOpcode':new,'sha256':hashlib.sha256(mut).hexdigest(),'baselineSemanticSymbol':'OperationsUnsignedMultiply'+name+'.SemanticWitness','witnessArguments':[456,1],'witnessOrdinal':14})
 (out/'inventory.json').write_text(json.dumps(records,indent=2)+'\n');print('PASS: one checked unsigned multiplication semantic operand candidates')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
