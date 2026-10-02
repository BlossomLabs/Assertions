#!/usr/bin/env python3
"""Single-byte semantic faults; original-byte reversal and ABI/RETURN oracles stay fixed."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);sha=lambda b:hashlib.sha256(b).hexdigest();assert sha(code)==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']
tail=json.loads((ROOT/'formal/bytecode/word-reverse/loop/Tail.mapping.json').read_text())['states'];store=next(n for n in tail if n['pc']==5927)
faults=[
 ('wrong-reverse-index',5920,0x03,0x01,'formal/bytecode/word-reverse/loop/generate-segments.py','formal/bytecode/word-reverse/loop','Tail.generated.dfy','BytecodeReverseSegmentTail.Advance'+str(store['id']),'three'),
 ('wrong-abi-head',21213,32,33,'formal/bytecode/bytes-return/generate.py','formal/bytecode/bytes-return','Control.generated.dfy','BytecodeAlignedBytesReturnControl.Advance11','empty'),
 ('return-to-revert',498,0xf3,0xfd,'formal/bytecode/bytes-return/generate.py','formal/bytecode/bytes-return','Control.generated.dfy','BytecodeAlignedBytesReturnControl.Advance74','empty')]
results=[]
for name,pc,old,new,generator,package,source,symbol,fixture in faults:
 assert code[pc]==old
 candidate=bytearray(code);candidate[pc]=new;(out/(name+'.bin')).write_bytes(candidate)
 results.append({'name':name,'runtime':name+'.bin','runtimeSha256':sha(candidate),'baselineRuntimeSha256':sha(code),'byteOffset':pc,'before':old,'after':new,'generator':generator,'package':package,'source':source,'nativeSymbol':symbol,'evmFixture':fixture,'oracle':'Unchanged original-byte reversal, ABI head, and successful RETURN postconditions and independent complete EVM receipts. Only runtime bytes and the candidate identity pin change.'})
(out/'candidates.json').write_text(json.dumps(results,indent=2)+'\n');print('Prepared',len(results),'semantic single-byte faults')
