#!/usr/bin/env python3
"""Preserve fixed physical empty-revert oracles while faulting terminal opcodes."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
results=[]
for name,pc in [('Assertions',265),('Expressions',66),('Collections',457)]:
 code=bytes.fromhex(json.loads((ROOT/f'artifacts/contracts/{name}.sol/{name}.json').read_text())['deployedBytecode'][2:]);base=hashlib.sha256(code).hexdigest();assert base==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())[name]['runtimeSha256'] and code[pc]==0xfd
 fault=name.lower()+'-revert-to-return';candidate=bytearray(code);candidate[pc]=0xf3;(out/(fault+'.bin')).write_bytes(candidate)
 results.append({'name':fault,'contract':name,'runtime':fault+'.bin','runtimeSha256':hashlib.sha256(candidate).hexdigest(),'baselineRuntimeSha256':base,'byteOffset':pc,'before':0xfd,'after':0xf3,'nativeSymbol':f'BytecodeUnknown{name}Terminal.End','source':name+'Terminal.generated.dfy','evmFixture':'0','oracle':'Fixed empty-revert status under actual terminal physical Step; full PC-zero unknown-selector EVM receipt must contradict status. No expected result changes.'})
(out/'candidates.json').write_text(json.dumps(results,indent=2)+'\n')
