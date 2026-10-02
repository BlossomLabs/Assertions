#!/usr/bin/env python3
"""One genuine opcode semantic fault preserving all runtime lengths/boundaries."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
 inventory=json.loads((HERE.parent/'inventory.json').read_text());raw=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(raw).hexdigest()==inventory['runtimeSha256'] and raw[7593]==0x20
 candidate=raw[:7593]+bytes([0x01])+raw[7594:];assert len(candidate)==len(raw) and sum(x!=y for x,y in zip(candidate,raw))==1
 name='hash-keccak-to-add';(a.output/(name+'.bin')).write_bytes(candidate)
 entry={'name':name,'entry':'Entry','publicEntry':'Operations.hash(bytes)','pc':7593,'baselineOpcode':0x20,'candidateOpcode':0x01,'baselineRuntimeSha256':inventory['runtimeSha256'],'runtimeSha256':hashlib.sha256(candidate).hexdigest(),'baselineSemanticSymbol':'OperationsHashSuccessEntry.SemanticWitness','witnessOrdinal':4,'inputLength':2,'witnessBytes':[165,165],'expected':'bc07f95faa953d0c799ffc75a8afda081bafda1396ac3ec9ba52784dccf67316','actual':hex(130)[2:].zfill(64)}
 (a.output/'inventory.json').write_text(json.dumps([entry],indent=2)+'\n');print('Prepared one actual SHA3-to-ADD semantic fault, physical witness ordinal4')
if __name__=='__main__':main()
