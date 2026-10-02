#!/usr/bin/env python3
"""Flip the actual unsigned sort comparison GT to LT, preserving byte geometry."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def generate(out):
 out.mkdir(parents=True,exist_ok=True);code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:])
 mapping=json.loads((HERE.parent/'hash-pair-sorted/Swap.mapping.json').read_text());assert mapping['runtimeSha256']==hashlib.sha256(code).hexdigest()
 nodes=[x for x in mapping['states'] if x['opcode']==0x11 and sorted(x['stack'][-2:])==['a','b']];assert len(nodes)==1
 pc=nodes[0]['pc'];assert code[pc]==0x11;mut=bytearray(code);mut[pc]=0x10;name='Swap-sort-comparison';(out/(name+'.bin')).write_bytes(mut)
 info={'name':name,'entry':'Swap','publicFamily':'HashPairSorted','pc':pc,'oldOpcode':0x11,'newOpcode':0x10,'sha256':hashlib.sha256(mut).hexdigest(),'baselineSemanticSymbol':'OperationsHashPairSortedSwap.SemanticWitness','witnessArguments':[456,123],'witnessOrdinal':4}
 (out/'inventory.json').write_text(json.dumps([info],indent=2)+'\n');print('PASS: one actual unsigned sorted-pair comparison mutation')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
