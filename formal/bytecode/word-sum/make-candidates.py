#!/usr/bin/env python3
"""One-byte semantic faults; expected sum, admission and error oracles stay fixed."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];SCANS=ROOT/'formal/bytecode/scans'
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);sha=lambda b:hashlib.sha256(b).hexdigest();assert sha(code)==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']
load=lambda n:json.loads((SCANS/(n+'.mapping.json')).read_text())['states']
add=load('Add');decoder=load('SumDecoder');panic=load('Overflow')
addop=next(n for n in add if n['op']==1)
tailop=[n for n in decoder if n['op']==0x11][-1]
argument=next(n for n in panic if n['op']==0x60 and n['immediate']==17)
faults=[
 ('checked-add-to-sub',addop['pc'],1,3,'generate-kernels.py','Add.generated.dfy','BytecodeScanAdd.Advance'+str(add[-1]['id']),'three'),
 ('tail-gt-to-lt',tailop['pc'],0x11,0x10,'generate.py','SumDecoder.generated.dfy','BytecodeScanSumDecoder.Advance'+str(tailop['id']),'loose-offset'),
 ('panic-code-17-to-18',argument['pc']+1,17,18,'generate-errors.py','Overflow.generated.dfy','BytecodeSumOverflow.Advance'+str(panic[-1]['id']),'overflow')]
results=[]
for name,pc,old,new,generator,source,symbol,fixture in faults:
 assert code[pc]==old
 candidate=bytearray(code);candidate[pc]=new;(out/(name+'.bin')).write_bytes(candidate)
 results.append({'name':name,'runtime':name+'.bin','runtimeSha256':sha(candidate),'baselineRuntimeSha256':sha(code),'byteOffset':pc,'before':old,'after':new,'generator':generator,'source':source,'nativeSymbol':symbol,'evmFixture':fixture,'oracle':'Unchanged declared sum/admission/error postcondition and independently fixed EVM expected receipt. Only runtime bytes and their identity hashes change.'})
(out/'candidates.json').write_text(json.dumps(results,indent=2)+'\n');print('Prepared',len(results),'one-byte semantic faults')
