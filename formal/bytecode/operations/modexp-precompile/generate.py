#!/usr/bin/env python3
"""Bind the actual MODEXP STATICCALL instruction and complete source AST gate."""
import argparse,hashlib,importlib.util,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def generate(out):
 spec=importlib.util.spec_from_file_location('gate',HERE.parent/'modexp-entry-preparation/generate-source-gate.py');g=importlib.util.module_from_spec(spec);spec.loader.exec_module(g);g.generate(out)
 assert (out/'source-gate.json').read_bytes()==(HERE.parent/'modexp-entry-preparation/source-gate.json').read_bytes()
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(code).hexdigest()==json.loads((HERE.parent/'inventory.json').read_text())['runtimeSha256']
 pc=0;boundaries=set()
 while pc<len(code):
  boundaries.add(pc);op=code[pc];pc+=1+(op-95 if 96<=op<=127 else 0)
 assert 9331 in boundaries and code[9331]==0xfa
 out.mkdir(parents=True,exist_ok=True)
 (out/'Site.generated.dfy').write_text('// SPDX-License-Identifier: MIT\n// Generated compiler-bound MODEXP instruction. Never edit directly.\ninclude "../modexp-execution/Execution.dfy"\nmodule OperationsModularPowerPrecompileSite {\n  import S = BytecodeScanMachine\n  const Pc:nat:=9331\n  predicate Matches(code:seq<S.Byte>) { Pc<|code| && S.Fetch(code,Pc)==S.Op(0xfa,Pc+1,0) }\n}\n')
 (out/'site.mapping.json').write_text(json.dumps({'runtimeSha256':hashlib.sha256(code).hexdigest(),'pc':9331,'opcode':250,'next':9332,'immediate':0,'scope':'One actual MODEXP STATICCALL instruction; surrounding paths remain open.'},indent=2)+'\n')
 for f in out.glob('*.generated.dfy'):
  result=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=f.read_text().replace('include "','//FORMAT_INCLUDE "'),text=True,capture_output=True);assert result.returncode==0;f.write_text(result.stdout.replace('//FORMAT_INCLUDE "','include "'))
 print('Generated compiler-bound MODEXP STATICCALL at9331')
if __name__=='__main__':
 a=argparse.ArgumentParser();a.add_argument('--output',type=Path,required=True);generate(a.parse_args().output)
