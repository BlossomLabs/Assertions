#!/usr/bin/env python3
"""Single-byte semantic faults; the iota/output/RETURN oracles stay fixed."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);sha=lambda b:hashlib.sha256(b).hexdigest();assert sha(code)==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']
body=json.loads((ROOT/'formal/bytecode/iota-loop/Body.mapping.json').read_text())['states'];inc=next(n for n in body if n['op']==0x60 and n['immediate']==1)
faults=[
 ('skip-one-output-word',inc['pc']+1,1,2,'formal/bytecode/iota-loop/generate.py','formal/bytecode/iota-loop','Body.generated.dfy','BytecodeIotaLoopBody.Advance'+str(body[-1]['id']),'two'),
 ('wrong-abi-head',21213,32,33,'formal/bytecode/iota-return/generate.py','formal/bytecode/iota-return','Control.generated.dfy','BytecodeIotaReturnControl.Advance11','empty'),
 ('return-to-revert',498,0xf3,0xfd,'formal/bytecode/iota-return/generate.py','formal/bytecode/iota-return','Control.generated.dfy','BytecodeIotaReturnControl.Advance74','empty')]
results=[]
for name,pc,old,new,generator,package,source,symbol,fixture in faults:
 assert code[pc]==old
 candidate=bytearray(code);candidate[pc]=new;(out/(name+'.bin')).write_bytes(candidate)
 results.append({'name':name,'runtime':name+'.bin','runtimeSha256':sha(candidate),'baselineRuntimeSha256':sha(code),'byteOffset':pc,'before':old,'after':new,'generator':generator,'package':package,'source':source,'nativeSymbol':symbol,'evmFixture':fixture,'oracle':'Unchanged original-index, ABI head, and successful RETURN postconditions and independent complete EVM receipts. Only runtime bytes and the candidate identity pin change.'})
(out/'candidates.json').write_text(json.dumps(results,indent=2)+'\n');print('Prepared',len(results),'semantic single-byte faults')
