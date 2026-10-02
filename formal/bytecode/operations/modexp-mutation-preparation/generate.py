#!/usr/bin/env python3
"""Generate baseline/candidate semantic checkpoint from exact runtime bytes."""
import argparse,hashlib,importlib.util,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
CANDIDATE='89264416208120dd3eeab87a7670ee339815b38b779f85b191d485a94b0109c7'
def generate(out,runtime=None):
 canonical=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:])
 inventory=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(canonical).hexdigest()==inventory['runtimeSha256']
 code=runtime.read_bytes() if runtime else canonical
 assert (code==canonical if runtime is None else hashlib.sha256(code).hexdigest()==CANDIDATE and [i for i,(a,b) in enumerate(zip(canonical,code)) if a!=b]==[9399] and len(code)==len(canonical))
 assert canonical[9399]==9 and code[9399] in [8,9]
 pc=0;boundaries=set()
 while pc<len(code):
  boundaries.add(pc);op=code[pc];pc+=1+(op-95 if 96<=op<=127 else 0)
 assert 9399 in boundaries
 out.mkdir(parents=True,exist_ok=True)
 spec=importlib.util.spec_from_file_location('source_gate',HERE.parent/'modexp-entry-preparation/generate-source-gate.py');gate=importlib.util.module_from_spec(spec);spec.loader.exec_module(gate);gate.generate(out)
 assert (out/'source-gate.json').read_bytes()==(HERE.parent/'modexp-entry-preparation/source-gate.json').read_bytes()
 text=f'''// SPDX-License-Identifier: MIT
// Generated baseline-covered semantic result checkpoint. Never edit directly.
include "../modexp-execution/Execution.dfy"
module OperationsModularPowerSemanticWitness {{
  import S = BytecodeScanMachine
  import M = BytecodeExternalMachine
  import E = OperationsModularPowerExecution
  function Prefix():seq<S.Word> {{ [0x44852766,1329,2,1,17,0,3390,2,1,17,1] }}
  predicate Matches(code:seq<S.Byte>) {{ 9399<|code| && S.Fetch(code,9399)==S.Op({code[9399]},9400,0) }}
  lemma Witness(code:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<E.Observation>)
    requires Matches(code)
    ensures E.Execute(code,{{}},M.Frame(S.Running(9399,Prefix()+[17,2,1],S.Store([],64,128)),[],0),self,value,data,observations)==M.Frame(S.Running(9400,Prefix()+[2],S.Store([],64,128)),[],0)
  {{
    if code[9399]==0x08 {{ E.AddModStep(code,{{}},9399,Prefix(),S.Store([],64,128),1,2,17,[],0,self,value,data,observations); }}
    else {{ E.MultiplyModStep(code,{{}},9399,Prefix(),S.Store([],64,128),1,2,17,[],0,self,value,data,observations); }}
  }}
}}
'''
 r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=text.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,r.stderr
 (out/'Witness.generated.dfy').write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'))
 (out/'mutation.mapping.json').write_text(json.dumps({'runtimeSha256':hashlib.sha256(code).hexdigest(),'canonicalRuntimeSha256':inventory['runtimeSha256'],'pc':9399,'opcode':code[9399],'baselineFixture':'UU-5','ordinal':5,'expectedResult':2,'candidateResult':3,'scope':'Baseline-covered actual MULMOD result checkpoint. Native baseline/mutation checks and retained public proofs remain required.'},indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime)
