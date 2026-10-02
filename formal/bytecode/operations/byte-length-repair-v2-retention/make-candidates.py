#!/usr/bin/env python3
"""Replace the actual scalar-result SWAP1 with DUP1, preserving instruction width."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def generate(out):
 out.mkdir(parents=True,exist_ok=True)
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:])
 mapping=json.loads((HERE.parent/'byte-length-repair-v2/Ok.mapping.json').read_text());assert mapping['runtimeSha256']==hashlib.sha256(code).hexdigest()
 stores=[s for s in mapping['states'] if s.get('store',[None])[0]==128];assert len(stores)==1
 store=stores[0];node=mapping['states'][store['id']-2];assert node['opcode']==0x90 and node['stack'][-1]=='128' and node['stack'][-2]=='b'
 pc=node['pc'];assert code[pc]==0x90;mut=bytearray(code);mut[pc]=0x80;name='Ok-return-value';(out/(name+'.bin')).write_bytes(mut)
 record={'name':name,'entry':'Ok','publicFamily':'ByteLen','pc':pc,'oldOpcode':0x90,'newOpcode':0x80,'sha256':hashlib.sha256(mut).hexdigest(),'baselineSemanticSymbol':'OperationsByteLengthOk.SemanticWitness','witnessArguments':[32,3],'witnessOrdinal':6}
 (out/'inventory.json').write_text(json.dumps([record],indent=2)+'\n');print('PASS: one actual return-value instruction mutation')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
