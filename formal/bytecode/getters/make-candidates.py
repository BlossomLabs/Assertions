#!/usr/bin/env python3
"""Two instruction-immediate faults; immutable independent expected constants."""
import argparse, hashlib, json
from pathlib import Path
if not __debug__:raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def main():
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
    code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);frozen=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Assertions'];assert hashlib.sha256(code).hexdigest()==frozen['runtimeSha256']
    results=[]
    for name,offset,before,after in [('len-shift-one-bit',0x1c6,255,254),('payload-increment-two',0x5fa,1,2)]:
        assert code[offset-1]==0x60 and code[offset]==before
        b=bytearray(code);b[offset]=after;(a.output/(name+'.bin')).write_bytes(b)
        results.append({'name':name,'offset':offset,'before':before,'after':after,'sha256':hashlib.sha256(b).hexdigest()})
    (a.output/'inventory.json').write_text(json.dumps(results,indent=2)+'\n')
if __name__=='__main__':main()
