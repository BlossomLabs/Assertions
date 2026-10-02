#!/usr/bin/env python3
"""One complete-runtime opcode mutation with a matching actual seed/update input."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
 inv=json.loads((HERE.parent/'inventory.json').read_text());raw=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(raw).hexdigest()==inv['runtimeSha256'] and raw[11298]==4
 candidate=raw[:11298]+bytes([2])+raw[11299:];assert len(candidate)==len(raw) and sum(x!=y for x,y in zip(raw,candidate))==1
 name='sqrt-first-div-to-mul';(a.output/(name+'.bin')).write_bytes(candidate)
 record={'name':name,'entry':'Newton0','publicEntry':'Operations.sqrt(uint256)','pc':11298,'baselineOpcode':4,'candidateOpcode':2,'baselineRuntimeSha256':inv['runtimeSha256'],'runtimeSha256':hashlib.sha256(candidate).hexdigest(),'baselineSemanticSymbol':'OperationsSquareRootNewton0.SemanticWitness','witnessOrdinal':20,'input':123,'actualInitialEstimate':12,'baselineNextEstimate':11,'candidateNextEstimate':744,'expected':(11).to_bytes(32,'big').hex(),'actual':(23).to_bytes(32,'big').hex()}
 (a.output/'inventory.json').write_text(json.dumps([record],indent=2)+'\n');print('Prepared exact one-byte first-Newton DIV-to-MUL mutation, physical witness20')
if __name__=='__main__':main()
