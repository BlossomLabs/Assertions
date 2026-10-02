#!/usr/bin/env python3
"""Fixed real reached EXP/MUL checkpoint. Generation is not verification."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def generate(out,runtime=None):
 baseline=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);code=runtime.read_bytes() if runtime else baseline
 inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(baseline).hexdigest()==inv['runtimeSha256'];differences=[i for i,(a,b) in enumerate(zip(baseline,code)) if a!=b];assert len(code)==len(baseline) and (not differences or differences==[21115] and code[21115]==2) and baseline[21115]==10
 out.mkdir(parents=True,exist_ok=True);opcode=code[21115]
 stack=[0xf5f565f8,1329,3,31,0,3085,31,3,0,3085,31,3,31,3]
 body='// SPDX-License-Identifier: MIT\n// Generated fixed compiled EXP outcome checkpoint. Never edit directly.\ninclude "../power-opcode-kernel/Execution.dfy"\nmodule OperationsPowerSemanticCheckpoint {\n  import M = OperationsSignedMultiplyMachine\n  import E = OperationsPowerExecution\n  import P = OperationsCheckedPowerModel\n  lemma PowerValue()\n    ensures P.Power(3,31)==617673396283947\n  {\n    assert P.Power(3,1)==3;\n    P.PowerAdd(3,1,1);P.PowerAdd(3,2,2);P.PowerAdd(3,4,4);P.PowerAdd(3,8,8);\n    P.PowerAdd(3,16,8);P.PowerAdd(3,24,4);P.PowerAdd(3,28,2);P.PowerAdd(3,30,1);\n  }\n  lemma IntendedResult(code:seq<M.Byte>,destinations:set<nat>)\n    requires |code|==@LENGTH@ && code[21115]==@OPCODE@\n    ensures var next:=E.Execute(code,destinations,M.Running(21115,@STACK@,M.Store([],64,128)),0,68,0xf5f565f800000000000000000000000000000000000000000000000000000000,3,31);\n      next==M.Running(21116,@POSTSTACK@,M.Store([],64,128))\n  {\n    PowerValue();\n    assert M.Fetch(code,21115)==M.Op(@OPCODE@,21116,0);\n    if @OPCODE@==10 {\n      E.ExpInstruction(code,destinations,21115,@STACK@,M.Store([],64,128),0,68,0xf5f565f800000000000000000000000000000000000000000000000000000000,3,31);\n    } else { reveal E.Execute();reveal M.Step(); }\n  }\n}\n'
 body=body.replace('@LENGTH@',str(len(code))).replace('@OPCODE@',str(opcode)).replace('@STACK@','['+','.join(map(str,stack))+']').replace('@POSTSTACK@','['+','.join(map(str,stack[:-2]+[617673396283947]))+']');(out/'Witness.generated.dfy').write_text(body)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime)
