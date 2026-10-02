#!/usr/bin/env python3
"""Replace each retained empty REVERT instruction by a successful empty RETURN."""
import argparse,hashlib,json
from pathlib import Path
if not __debug__:raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);result=[]
 for contract in ['Assertions','Expressions','Collections']:
  code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts'/f'{contract}.sol'/f'{contract}.json').read_text())['deployedBytecode'][2:])
  for kind in ['Nonzero','Short']:
   name=contract+kind;mapping=json.loads((HERE/(name+'.mapping.json')).read_text());assert hashlib.sha256(code).hexdigest()==mapping['runtimeSha256'];pc=mapping['states'][-1]['pc'];assert code[pc]==0xfd
   candidate=bytearray(code);candidate[pc]=0xf3;(a.output/(name+'.bin')).write_bytes(candidate)
   result.append({'name':name,'contract':contract,'kind':kind,'offset':pc,'before':0xfd,'after':0xf3,'sha256':hashlib.sha256(candidate).hexdigest()})
 (a.output/'inventory.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
