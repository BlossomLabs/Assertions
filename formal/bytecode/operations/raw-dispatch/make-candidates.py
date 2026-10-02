#!/usr/bin/env python3
"""Real one-byte reached REVERT-to-RETURN semantic fault, no native claim."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();mapping=json.loads((HERE/'Operations.mapping.json').read_text());baseline=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(baseline).hexdigest()==mapping['runtimeSha256'];boundaries=set();pc=0
while pc<len(baseline):boundaries.add(pc);op=baseline[pc];pc+=1+(op-95 if 96<=op<=127 else 0)
terminals={n['pc'] for n in mapping['states'] if n.get('terminal')=='rejected' and n['stack']==['Selector(word)','0','0']};assert len(terminals)==16;pc=max(terminals);assert pc in boundaries and baseline[pc]==0xfd
candidate=bytearray(baseline);candidate[pc]=0xf3;a.output.mkdir(parents=True,exist_ok=True);name='unknown-revert-to-return';(a.output/(name+'.bin')).write_bytes(candidate)
(a.output/'inventory.json').write_text(json.dumps([{'name':name,'pc':pc,'oldOpcode':0xfd,'newOpcode':0xf3,'runtimeSha256':hashlib.sha256(candidate).hexdigest(),'semanticSymbol':'OperationsRawUnknownTerminal.End'+str(pc),'physicalWitness':'unknown-0','scope':'Empty rejection changed to empty success; same actual reached prefix and fixed physical terminal stack/memory.'}],indent=2)+'\n')
