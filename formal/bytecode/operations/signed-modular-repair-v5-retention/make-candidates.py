#!/usr/bin/env python3
"""Make exact one-byte reached modular opcode faults; native campaign pending."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def read(p):return json.loads(p.read_text())
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
 code=bytes.fromhex(read(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);frozen=read(HERE.parent/'inventory.json');assert hashlib.sha256(code).hexdigest()==frozen['runtimeSha256']
 result=[]
 for family,old,new,pc in [('AddModS',8,9,3512),('MulModS',9,8,4107)]:
  entry=family+'Case1';mapping=read(HERE.parent/'signed-modular-repair-v5'/(entry+'.mapping.json'));nodes=[s for s in mapping['states'] if s['pc']==pc]
  assert len(nodes)==1 and nodes[0]['opcode']==old and nodes[0]['stack'][-3:]==['c','b','a'] and code[pc]==old
  candidate=bytearray(code);candidate[pc]=new;name=family+'-modular-opcode';file=a.output/(name+'.bin');file.write_bytes(candidate)
  result.append(dict(name=name,entry=entry,publicFamily=family,pc=pc,oldOpcode=old,newOpcode=new,sha256=hashlib.sha256(candidate).hexdigest(),baselineSemanticSymbol='OperationsSignedModularOpcode'+entry+'.SemanticWitness',witnessArguments=[123,456,7],witnessOrdinal=514))
 (a.output/'inventory.json').write_text(json.dumps(result,indent=2)+'\n')
 print('Prepared two genuine reached one-byte opcode candidates; matching native and independently replayed physical rejection remains required')
if __name__=='__main__':main()
