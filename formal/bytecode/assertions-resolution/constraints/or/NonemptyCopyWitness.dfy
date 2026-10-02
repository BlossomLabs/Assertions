// SPDX-License-Identifier: MIT
// Actual child decoder copy instruction, with an independent source-word verdict.
include "../../raw/Machine.dfy"
module AssertionsConstraintOrNonemptyCopyWitness {
  import S = BytecodeScanMachine
  import M = AssertionsRawResolveMachine
  import A = AssertionsSignedMachine
  import C = BytecodeCopyMachine
  import B = BytecodeCopyMemory
  type Byte = S.Byte
  lemma Actual(code: seq<Byte>, mem: seq<Byte>)
    requires |code| == 20049 && code[19755] == 0x5e
    requires 352 <= |mem| < 0x10000000000000000
    requires S.Load(mem,320) == 7
    ensures var result := M.Step(code,{},S.Running(19755,[32,320,512],mem),0,[]);
      result.Running? && result.pc == 19756 && result.stack == [] && S.Load(result.memory,512) == 7
  {
    B.Rounded(544);
    B.Rounded(352);
    B.MemoryCopiedWord(mem,512,320);
    reveal M.Step(); reveal C.Step(); reveal A.Step(); reveal S.Step();
  }
}
