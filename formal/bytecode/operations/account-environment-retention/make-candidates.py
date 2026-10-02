#!/usr/bin/env python3
"""Mutate a reached environment opcode to a distinct context field, same geometry."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
TABLE={'Balance':0x31,'CodeHash':0x3f}
def generate(out):
 out.mkdir(parents=True,exist_ok=True);code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);records=[]
 for name,op in TABLE.items():
  mapping=json.loads((HERE.parent/'account-environment'/(name+'.mapping.json')).read_text());assert mapping['runtimeSha256']==hashlib.sha256(code).hexdigest()
  reached=[n for n in mapping['states'] if n['opcode'] in TABLE.values()];assert len(reached)==1 and reached[0]['opcode']==op
  pc=reached[0]['pc'];new=0x3f if op==0x31 else 0x31;mut=bytearray(code);assert mut[pc]==op;mut[pc]=new
  file=out/(name+'-opcode.bin');file.write_bytes(mut)
  records.append({'name':name+'-opcode','entry':name,'pc':pc,'oldOpcode':op,'newOpcode':new,'sha256':hashlib.sha256(mut).hexdigest(),'baselineSemanticSymbol':'OperationsAccountEnvironment'+name+'.SemanticWitness','witnessAccount':123,'witnessOrdinal':0,'witnessTailOrdinal':0,'worldWitness':'Balance(world,a) != CodeHash(world,a)'})
 (out/'inventory.json').write_text(json.dumps(records,indent=2)+'\n');print('PASS: two account observation semantic opcode candidates')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
