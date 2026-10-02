#!/usr/bin/env python3
"""Checked-source intended multiply result at the actual signed-power checkpoint."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
def generate(out,runtime):
 baseline=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(baseline).hexdigest()==inv['runtimeSha256'];code=runtime.read_bytes() if runtime else baseline
 changes=[i for i in range(len(baseline)) if code[i]!=baseline[i]];assert len(code)==len(baseline) and (not changes or changes==[20148] and baseline[20148]==2 and code[20148]==1);op=code[20148];assert op in [1,2];out.mkdir(parents=True,exist_ok=True)
 text=f'''// SPDX-License-Identifier: MIT
// Generated fixed intended-result checkpoint; never edit directly.
include "../power-opcode-kernel/Execution.dfy"
module OperationsPowerSignedMutationWitness {{
  import M = OperationsSignedMultiplyMachine
  import E = OperationsPowerExecution
  import P = OperationsCheckedPowerModel
  function Prefix():seq<M.Word> {{ [0x185af0ad,1329,3,31,1,3275,3,1] }}
  // From source accumulator1, factor3, exponent31; the checked loop invokes
  // continuation3275 and the first two helper DUPs push1 then3.
  lemma IntendedResult(code:seq<M.Byte>,destinations:set<nat>,
                       value:M.Word,size:M.Word,word:M.Word,a:M.Word,b:M.Word)
    requires |code|=={len(code)} && code[20148]=={op}
    ensures E.Execute(code,destinations,
              M.Running(20148,Prefix()+[1,3],M.Store([],64,128)),value,size,word,a,b)==
              M.Running(20149,Prefix()+[3],M.Store([],64,128))
  {{
    assert P.Power(3,1)==3 && 1*3==3;
    assert M.Fetch(code,20148)==M.Op({op},20149,0);
    E.Ordinary(code,destinations,M.Running(20148,Prefix()+[1,3],M.Store([],64,128)),value,size,word,a,b);
    reveal M.Step();
  }}
}}
''';(out/'Witness.generated.dfy').write_text(text);(out/'witness.mapping.json').write_text(json.dumps(dict(baselineRuntimeSha256=hashlib.sha256(baseline).hexdigest(),runtimeSha256=hashlib.sha256(code).hexdigest(),changedBytes=changes,pc=20148,opcode=op,physicalOrdinal=51,intendedResult=3,preStack=[0x185af0ad,1329,3,31,1,3275,3,1,1,3],scope='Intended fixed checked product; baseline native and candidate ordinary-postcondition contradiction are queued, full53-module retention remains open'),indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime)
