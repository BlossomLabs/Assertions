#!/usr/bin/env python3
"""Semantic comparison opcode faults selected only from actual operand-body states."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
NAMES=['Eq','Ne','LtU','GtU','LeU','GeU','LtS','GtS','LeS','GeS']
SWAP={0x14:0x10,0x10:0x11,0x11:0x10,0x12:0x13,0x13:0x12}
def generate(out):
 out.mkdir(parents=True,exist_ok=True);code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);records=[]
 for name in NAMES:
  mapping=json.loads((HERE.parent/'comparison'/(name+'.mapping.json')).read_text());assert hashlib.sha256(code).hexdigest()==mapping['runtimeSha256']
  candidates=[s for s in mapping['states'] if s['opcode'] in SWAP and sorted(s['stack'][-2:])==['a','b']]
  assert len(candidates)==1;state=candidates[0];pc=state['pc'];old=state['opcode'];new=SWAP[old];assert code[pc]==old
  mutant=bytearray(code);mutant[pc]=new;file=out/(name+'-opcode.bin');file.write_bytes(mutant)
  records.append({'name':name+'-opcode','entry':name,'pc':pc,'oldOpcode':old,'newOpcode':new,'sha256':hashlib.sha256(mutant).hexdigest(),'baselineFinalSymbol':'OperationsComparison'+name+'.Advance'+str(len(mapping['states'])-1)})
 (out/'inventory.json').write_text(json.dumps(records,indent=2)+'\n');print('PASS: ten semantic operand-body comparison opcode faults')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
