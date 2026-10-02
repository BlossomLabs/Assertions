#!/usr/bin/env python3
"""Exact physical serializer witness, shared PC18907 control; native pending."""
import argparse,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];DAFNY='/tmp/assertions-dafny-4.11.0/dafny/dafny'
def generate(out,runtime=None):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inventory=json.loads((ROOT/'formal/bytecode/operations/inventory.json').read_text());assert hashlib.sha256(code).hexdigest()==inventory['runtimeSha256'] and code[18907]==0x5e
 canonical=code
 if runtime is not None:
  code=runtime.read_bytes();assert len(code)==len(canonical) and [i for i,(a,b) in enumerate(zip(canonical,code)) if a!=b]==[18907] and code[18907]==0x37
 opcode=code[18907]
 text='''// SPDX-License-Identifier: MIT
// Actual stringAt valid1-index0 physical frontier; native verification pending.
include "../../external-calls/Machine.dfy"
module OperationsStringAtSemanticWitness {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import C = BytecodeCopyMachine
  import CM = BytecodeCopyMemory
  function Zeros(n:nat):seq<S.Byte> { seq(n,i=>0) }
  function Data():seq<S.Byte> {
    [0xa1,0xbc,0x21,0x39]+G.Encode(64,32)+G.Encode(0,32)+G.Encode(1,32)+[65,0xa5,0xff]
  }
  function Before():seq<S.Byte> {
    Zeros(64)+G.Encode(192,32)+Zeros(32)+G.Encode(1,32)+[65]+Zeros(31)+G.Encode(32,32)+G.Encode(1,32)
  }
  function After():seq<S.Byte> { Before()+[65]+Zeros(31) }
  function PreStack():seq<S.Word> { [2713461049,1301,128,192,0,3085,224,128,0,1,1,160,256] }
  function PostStack():seq<S.Word> { [2713461049,1301,128,192,0,3085,224,128,0,1] }
  lemma Shape()
    ensures |Data()|==103 && |Before()|==256 && Before()[160]==65
    ensures |After()|==288 && After()[256]==65
  {}
  lemma SemanticWitness(code:seq<S.Byte>,self:S.Word)
    requires |code|==21346 && S.Fetch(code,18907)==S.Op(0x5e,18908,0)
    ensures M.Step(code,{},M.Frame(S.Running(18907,PreStack(),Before()),[],0),self,0,Data(),[])==M.Frame(S.Running(18908,PostStack(),After()),[],0)
  {
    Shape();reveal M.Step();reveal C.Step();reveal S.Step();
    assert S.Expand(Before(),257)==Before()+Zeros(32);
    assert CM.Memory(Before(),256,160,1)==After();
  }
}
'''
 if opcode!=0x5e:text=text.replace('S.Op(0x5e,18908,0)','S.Op(0x37,18908,0)')
 r=subprocess.run([DAFNY,'format','--stdin','--print'],input=text.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,r.stdout+r.stderr
 out.mkdir(parents=True,exist_ok=True);(out/'Witness.generated.dfy').write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'));mapping=dict(canonicalRuntimeSha256=hashlib.sha256(canonical).hexdigest(),runtimeSha256=hashlib.sha256(code).hexdigest(),pc=18907,opcode=opcode,nextPc=18908,witnessOrdinal=5,preStack=[2713461049,1301,128,192,0,3085,224,128,0,1,1,160,256],postStack=[2713461049,1301,128,192,0,3085,224,128,0,1],semanticPostUnchanged=True);(out/'witness.mapping.json').write_text(json.dumps(mapping,indent=2)+'\n');print('Prepared PC18907 whole-state witness matching physical ordinal5; native pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime)
