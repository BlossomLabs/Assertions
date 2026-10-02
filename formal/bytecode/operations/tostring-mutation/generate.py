#!/usr/bin/env python3
"""Extract two reached decimal MOD semantic checkpoints; no proof credit."""
import argparse,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def generate(out,runtime=None):
 baseline=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(baseline).hexdigest()==inv['runtimeSha256'];code=runtime.read_bytes() if runtime else baseline;diff=[i for i,(a,b) in enumerate(zip(code,baseline)) if a!=b];assert len(code)==len(baseline) and baseline[20305]==6 and (not diff or diff==[20305] and code[20305]==4)
 body='// SPDX-License-Identifier: MIT\n// Generated complete reached decimal remainder prefixes; native pending.\ninclude "../casefold-machine/Machine.dfy"\ninclude "../tostring-inputs/Inputs.dfy"\nmodule OperationsToStringSemanticWitness {\n  import S = BytecodeScanMachine\n  import M = BytecodeExternalMachine\n  import F = OperationsCaseFoldMachine\n  import I = OperationsToStringInputs\n'
 rows=[]
 for mode,selector,ordinal in [('Unsigned',0x6900a3ae,2),('Signed',0xa322c40e,116)]:
  if mode=='Unsigned':
   pre=[selector,1362,1,96,0,128,1,5680,10,1]
   mem=b'\0'*64+(192).to_bytes(32,'big')+b'\0'*32+(1).to_bytes(32,'big')+b'\0'*32
  else:
   pre=[selector,1362,(1<<256)-1,96,128,7455,1,96,0,192,1,5680,10,1]
   mem=b'\0'*64+(256).to_bytes(32,'big')+b'\0'*32+(1).to_bytes(32,'big')+bytes([45])+b'\0'*31+(1).to_bytes(32,'big')+b'\0'*32
  post=pre[:-2]+[1]
  body+='  function Memory'+mode+'():seq<S.Byte> { ['+','.join(map(str,mem))+'] }\n'
  body+=f'  lemma Witness{mode}(code:seq<S.Byte>,destinations:set<nat>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>)\n    requires |code|=={len(code)} && code[20305]=={code[20305]}\n    ensures F.Step(code,destinations,M.Frame(S.Running(20305,['+','.join(map(str,pre))+f'],Memory{mode}()),[],0),self,value,data,observations)==M.Frame(S.Running(20306,['+','.join(map(str,post))+f'],Memory{mode}()),[],0)\n  {{\n    assert I.Digit(1)==49;\n    assert S.Fetch(code,20305)==S.Op({code[20305]},20306,0);\n    reveal F.Step();reveal M.Step();reveal BytecodeCopyMachine.Step();reveal S.Step();\n  }}\n'
  rows.append(dict(mode=mode.lower(),ordinal=ordinal,pc=20305,next=20306,pre=pre,intendedPost=post,memorySha256=hashlib.sha256(mem).hexdigest(),memoryHex=mem.hex(),intendedRemainder=1,intendedDigit=49,candidateRemainder=0,candidateDigit=48))
 body+='}\n';body=body.replace('  import F = OperationsCaseFoldMachine\n','  import F = OperationsCaseFoldMachine\n  import C = BytecodeCopyMachine\n').replace('reveal BytecodeCopyMachine.Step();','reveal C.Step();');r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=body.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,r.stderr;out.mkdir(parents=True,exist_ok=True);(out/'Witness.generated.dfy').write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'));(out/'witness.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(code).hexdigest(),candidate=bool(diff),opcode=code[20305],paths=rows),indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime)
