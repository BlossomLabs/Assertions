#!/usr/bin/env python3
"""Extract two reached case-fold XOR semantic checkpoints; no proof credit."""
import argparse,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def generate(out,runtime=None):
 baseline=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(baseline).hexdigest()==inv['runtimeSha256'];code=runtime.read_bytes() if runtime else baseline;diff=[i for i,(a,b) in enumerate(zip(code,baseline)) if a!=b];assert len(code)==len(baseline) and baseline[12297]==24 and (not diff or diff==[12297] and code[12297]==22)
 body='// SPDX-License-Identifier: MIT\n// Generated complete XOR checkpoint prefixes; native pending.\ninclude "../casefold-machine/Machine.dfy"\ninclude "../casefold-inputs/Inputs.dfy"\nmodule OperationsCaseFoldSemanticWitness {\n  import S = BytecodeScanMachine\n  import M = BytecodeExternalMachine\n  import F = OperationsCaseFoldMachine\n  import I = OperationsCaseFoldInputs\n'
 rows=[]
 for mode,selector,cell,high,intended,ordinal in [('Lower',0xc1459c04,65,90,97,37),('Upper',0xfeec0cff,97,122,65,109)]:
  pre=[selector,1362,68,1,96,3085,68,1,cell<<248,high<<248,128,0,cell<<248,cell<<248,32<<248];post=pre[:-2]+[intended<<248];mem=b'\0'*64+(192).to_bytes(32,'big')+b'\0'*32+(1).to_bytes(32,'big')+bytes([cell])+b'\0'*63
  body+='  function Memory'+mode+'():seq<S.Byte> { ['+','.join(map(str,mem))+'] }\n'
  body+=f'  lemma Witness{mode}(code:seq<S.Byte>,destinations:set<nat>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>)\n    requires |code|=={len(code)} && code[12297]=={code[12297]}\n    ensures F.Step(code,destinations,M.Frame(S.Running(12297,['+','.join(map(str,pre))+f'],Memory{mode}()),[],0),self,value,data,observations)==M.Frame(S.Running(12298,['+','.join(map(str,post))+f'],Memory{mode}()),[],0)\n  {{\n    assert I.Fold({str(mode=="Lower").lower()},{cell})=={intended};\n    assert S.Fetch(code,12297)==S.Op({code[12297]},12298,0);\n    reveal F.Step();reveal M.Step();reveal BytecodeCopyMachine.Step();reveal S.Step();\n  }}\n'
  rows.append(dict(mode=mode.lower(),ordinal=ordinal,pc=12297,next=12298,pre=pre,intendedPost=post,memorySha256=hashlib.sha256(mem).hexdigest(),memoryHex=mem.hex(),cell=cell,intendedCell=intended))
 body+='}\n';body=body.replace('  import F = OperationsCaseFoldMachine\n','  import F = OperationsCaseFoldMachine\n  import C = BytecodeCopyMachine\n').replace('reveal BytecodeCopyMachine.Step();','reveal C.Step();');r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=body.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,r.stderr;out.mkdir(parents=True,exist_ok=True);(out/'Witness.generated.dfy').write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'));(out/'witness.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(code).hexdigest(),candidate=bool(diff),opcode=code[12297],paths=rows),indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime)
