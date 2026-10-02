#!/usr/bin/env python3
"""Bind a signed magnitude comparison witness to exact baseline/candidate bytes."""
import argparse,hashlib,importlib.util,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
CANDIDATE='b114dbef3d70789e695a8bfdb1ffd01ade8449a87abb07f050d93a70637763d9'
def generate(out,runtime=None):
 canonical=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(canonical).hexdigest()==inv['runtimeSha256'];code=runtime.read_bytes() if runtime else canonical
 assert code==canonical if runtime is None else hashlib.sha256(code).hexdigest()==CANDIDATE and len(code)==len(canonical) and [i for i,(a,b) in enumerate(zip(code,canonical)) if a!=b]==[9152]
 assert canonical[9152]==0x12 and code[9152] in [0x10,0x12];pc=0;boundaries=set()
 while pc<len(code):boundaries.add(pc);op=code[pc];pc+=1+(op-95 if 96<=op<=127 else 0)
 assert 9152 in boundaries;out.mkdir(parents=True,exist_ok=True)
 spec=importlib.util.spec_from_file_location('source_gate',HERE.parent/'modexp-entry-preparation/generate-source-gate.py');gate=importlib.util.module_from_spec(spec);spec.loader.exec_module(gate);gate.generate(out)
 assert (out/'source-gate.json').read_bytes()==(HERE.parent/'modexp-entry-preparation/source-gate.json').read_bytes()
 text=f'''// SPDX-License-Identifier: MIT
// Generated signed magnitude comparison witness. Never edit directly.
include "../modexp-execution/Execution.dfy"
module OperationsModularPowerSignedSemanticWitness {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMachine
  import M = BytecodeExternalMachine
  import E = OperationsModularPowerExecution
  function NegativeThree():S.Word {{ G.Modulus()-3 }}
  function Prefix():seq<S.Word> {{ [0x640c3e5a,1329,NegativeThree(),3,G.Modulus()-17,0,3390,5241,5226,NegativeThree(),0] }}
  predicate Matches(code:seq<S.Byte>) {{ 9152<|code| && S.Fetch(code,9152)==S.Op({code[9152]},9153,0) }}
  lemma Witness(code:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<E.Observation>)
    requires Matches(code)
    ensures E.Execute(code,{{}},M.Frame(S.Running(9152,Prefix()+[0,NegativeThree()],S.Store([],64,128)),[],0),self,value,data,observations)==M.Frame(S.Running(9153,Prefix()+[1],S.Store([],64,128)),[],0)
  {{ reveal E.Execute();reveal M.Step();reveal C.Step();reveal S.Step();reveal G.Step(); }}
}}
'''
 r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=text.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,r.stderr
 (out/'Witness.generated.dfy').write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'))
 (out/'mutation.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(code).hexdigest(),canonicalRuntimeSha256=inv['runtimeSha256'],pc=9152,opcode=code[9152],baselineFixture='SU-15',ordinal=41,expectedFlag=1,candidateFlag=0,expectedResult=-10,candidateResult=-2744,scope='Baseline-covered signed magnitude SLT checkpoint. Complete native graph and retained matching physical fault are pending.'),indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime)
