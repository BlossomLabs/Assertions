#!/usr/bin/env python3
"""One actual BYTE→SHR semantic opcode fault, development only."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
artifact=json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text());code=bytes.fromhex(artifact['deployedBytecode'][2:]);inventory=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(code).hexdigest()==inventory['runtimeSha256']
boundaries={};pc=0
while pc<len(code):
 op=code[pc];width=op-0x5f if 0x60<=op<=0x7f else 0;boundaries[pc]=(op,pc+width+1);pc+=width+1
pc=11109;assert boundaries[pc][0]==0x1a;bits=bytearray(code);bits[pc]=0x1c;name='log2-byte-to-shift';(a.output/(name+'.bin')).write_bytes(bits)
info=dict(baselineSemanticSymbol='OperationsBytecodeLog2Positive.SemanticWitness',name=name,entry='Positive',publicEntry='Operations.log2(uint256)',pc=pc,oldOpcode=0x1a,newOpcode=0x1c,witnessArgument=4,witnessOrdinal=4,sha256=hashlib.sha256(bits).hexdigest(),scope='Candidate only; future baseline-covered native mathematical checkpoint rejection and independent matching physical receipt required before retained credit')
(a.output/'inventory.json').write_text(json.dumps([info],indent=2)+'\n')
