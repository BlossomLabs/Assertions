#!/usr/bin/env python3
"""Semantic bytecode faults; Solidity and all independent expected results stay fixed."""
import argparse,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:])
cases=[('eq-to-strict-gt',11171,0x14,0x11,'Kind0Valid'),('signed-range-order-unsigned',10918,0x13,0x11,'Kind8BadRange'),('invalid-length-argument-kind',10727,0x82,0x83,'Kind7BadData')]
records=[]
for name,pc,before,after,module in cases:
 assert code[pc]==before
 changed=bytearray(code);changed[pc]=after;(a.output/(name+'.bin')).write_bytes(changed)
 records.append({'name':name,'pc':pc,'before':before,'after':after,'module':module,'runtimeSha256':hashlib.sha256(changed).hexdigest()})
(a.output/'inventory.json').write_text(json.dumps(records,indent=2)+'\n')
