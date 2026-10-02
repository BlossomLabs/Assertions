#!/usr/bin/env python3
"""Semantic exact-runtime bitwise opcode mutations, preserving instruction geometry."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
def generate(out):
 out.mkdir(parents=True,exist_ok=True)
 art=json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text());code=bytes.fromhex(art['deployedBytecode'][2:]);mutations=[]
 for name,old,new in [('And',0x16,0x17),('Or',0x17,0x18),('Xor',0x18,0x16)]:
  mapping=json.loads((HERE.parent/'bitwise-repair'/(name+'.mapping.json')).read_text());assert hashlib.sha256(code).hexdigest()==mapping['runtimeSha256']
  nodes=[n for n in mapping['states'] if n['opcode']==old and sorted(n['stack'][-2:])==['a','b']]
  assert len(nodes)==1;pc=nodes[0]['pc'];assert code[pc]==old
  mutant=bytearray(code);mutant[pc]=new;file=out/(name+'-opcode.bin');file.write_bytes(mutant)
  mutations.append({'name':name+'-opcode','entry':name,'pc':pc,'oldOpcode':old,'newOpcode':new,'sha256':hashlib.sha256(mutant).hexdigest(),'witnessArguments':[123,456],'witnessOrdinal':4,'baselineSemanticSymbol':'OperationsBitwiseRepair'+name+'.SemanticWitness'})
 (out/'inventory.json').write_text(json.dumps(mutations,indent=2)+'\n');print('PASS: 3 semantic bitwise opcode candidates')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
