#!/usr/bin/env python3
"""Semantic word-shift faults selected only from actual operand body states."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
SWAPS={'Shl':(0x1b,0x1c),'ShrU':(0x1c,0x1b),'ShrS':(0x1d,0x1c),'BitSet':(0x16,0x17)}
def generate(out):
 out.mkdir(parents=True,exist_ok=True);code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);records=[]
 for name,(old,new) in SWAPS.items():
  mapping=json.loads((HERE.parent/'shifts'/(name+'.mapping.json')).read_text());assert hashlib.sha256(code).hexdigest()==mapping['runtimeSha256']
  states=[s for s in mapping['states'] if s['opcode']==old and (sorted(s['stack'][-2:])==['a','b'] if name!='BitSet' else 'Right(a,b)' in s['stack'][-2:])]
  assert len(states)==1,(name,states);state=states[0];pc=state['pc'];assert code[pc]==old
  mutant=bytearray(code);mutant[pc]=new;file=out/(name+'-opcode.bin');file.write_bytes(mutant)
  records.append({'name':name+'-opcode','entry':name,'pc':pc,'oldOpcode':old,'newOpcode':new,'sha256':hashlib.sha256(mutant).hexdigest(),'baselineSemanticSymbol':'OperationsShift'+name+'.SemanticWitness','witnessArguments':[(1<<255),256] if name=='ShrS' else [1,1],'witnessOrdinal':10 if name=='ShrS' else 2})
 (out/'inventory.json').write_text(json.dumps(records,indent=2)+'\n');print('PASS: four semantic shift operand-body opcode faults')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
