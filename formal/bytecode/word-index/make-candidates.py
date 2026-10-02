#!/usr/bin/env python3
"""Semantic one-byte faults with unchanged least-index/admission oracles."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);sha=lambda b:hashlib.sha256(b).hexdigest();assert sha(code)==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']
load=lambda n:json.loads((HERE/(n+'.mapping.json')).read_text())['states']
miss=load('Miss');hit=load('Hit');decoder=load('IndexDecoder');inc=next(n for n in miss if n['op']==0x60 and n['immediate']==1);swap=next(n for n in hit if n['pc']==0x20b1);tail=[n for n in decoder if n['op']==0x11][-1]
faults=[
 ('skip-two-words',inc['pc']+1,1,2,'generate-segments.py','Miss.generated.dfy','BytecodeIndexMiss.Advance'+str(miss[-1]['id']),'middle'),
 ('wrong-hit-result',swap['pc'],0x91,0x90,'generate-segments.py','Hit.generated.dfy','BytecodeIndexHit.Advance'+str(hit[-1]['id']),'middle'),
 ('tail-gt-to-lt',tail['pc'],0x11,0x10,'generate-decoder.py','IndexDecoder.generated.dfy','BytecodeScanIndexDecoder.Advance'+str(tail['id']),'loose-offset')]
results=[]
for name,pc,old,new,generator,source,symbol,fixture in faults:
 assert code[pc]==old
 candidate=bytearray(code);candidate[pc]=new;(out/(name+'.bin')).write_bytes(candidate)
 results.append({'name':name,'runtime':name+'.bin','runtimeSha256':sha(candidate),'baselineRuntimeSha256':sha(code),'byteOffset':pc,'before':old,'after':new,'generator':generator,'source':source,'nativeSymbol':symbol,'evmFixture':fixture,'oracle':'Unchanged declared least-index/admission postcondition and independently fixed EVM receipt. Only runtime bytes and identity hashes change.'})
(out/'candidates.json').write_text(json.dumps(results,indent=2)+'\n');print('Prepared',len(results),'semantic one-byte faults')
