#!/usr/bin/env python3
"""Generate the baseline-covered actual one-byte MCOPY-to-CALLDATACOPY fault."""
import argparse,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);args=p.parse_args();out=args.output;out.mkdir(parents=True,exist_ok=False)
a=json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text());base=bytes.fromhex(a['deployedBytecode'][2:]);inv=json.loads((ROOT/'formal/bytecode/operations/inventory.json').read_text())
assert hashlib.sha256(base).hexdigest()==inv['runtimeSha256'] and inv['compilerIdentity']['methodIdentifiers']['byteAt(bytes,int256)']=='9ae8e8ea'
pcs=set();pc=0
while pc<len(base):
 pcs.add(pc);op=base[pc];pc+=1+(op-0x5f if 0x60<=op<=0x7f else 0)
assert 18907 in pcs and base[18907]==0x5e
bits=bytearray(base);bits[18907]=0x37;(out/'serializer-mcopy-to-calldatacopy.bin').write_bytes(bits)
(out/'inventory.json').write_text(json.dumps([{'name':'serializer-mcopy-to-calldatacopy','pc':18907,'oldOpcode':0x5e,'newOpcode':0x37,'baselineRuntimeSha256':inv['runtimeSha256'],'sha256':hashlib.sha256(bits).hexdigest(),'witnessOrdinal':6,'baselineSemanticSymbol':'OperationsByteAtSerialization.SemanticWitness','source':100,'originalByte':165,'changedByte':0,'expected':(32).to_bytes(32,'big').hex()+(1).to_bytes(32,'big').hex()+'a5'+'00'*31,'actual':(32).to_bytes(32,'big').hex()+(1).to_bytes(32,'big').hex()+'00'*32,'scope':'Native original-byte preservation postcondition and full physical output use the same admitted witness.'}],indent=2)+'\n')
