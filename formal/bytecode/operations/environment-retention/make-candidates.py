#!/usr/bin/env python3
"""Mutate a reached environment opcode to a distinct context field, same geometry."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
TABLE={'BaseFee':0x48,'BlobBaseFee':0x4a,'BlockNumber':0x43,'ChainId':0x46,'GasLimit':0x45,'GasPrice':0x3a,'PrevRandao':0x44,'Timestamp':0x42}
def generate(out):
 out.mkdir(parents=True,exist_ok=True);code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);records=[]
 for name,op in TABLE.items():
  mapping=json.loads((HERE.parent/'environment'/(name+'.mapping.json')).read_text());assert mapping['runtimeSha256']==hashlib.sha256(code).hexdigest()
  reached=[n for n in mapping['states'] if n['opcode'] in TABLE.values()];assert len(reached)==1 and reached[0]['opcode']==op
  pc=reached[0]['pc'];new=0x43 if op in [0x3a,0x45,0x46,0x42] else 0x3a;mut=bytearray(code);assert mut[pc]==op;mut[pc]=new
  file=out/(name+'-opcode.bin');file.write_bytes(mut)
  records.append({'name':name+'-opcode','entry':name,'pc':pc,'oldOpcode':op,'newOpcode':new,'sha256':hashlib.sha256(mut).hexdigest(),'baselineFinalSymbol':'OperationsEnvironment'+name+'.Advance'+str(len(mapping['states'])-1)})
 (out/'inventory.json').write_text(json.dumps(records,indent=2)+'\n');print('PASS: eight distinct-field semantic environment opcode candidates')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
