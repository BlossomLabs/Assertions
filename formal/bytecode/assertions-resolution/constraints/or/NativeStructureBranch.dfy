// SPDX-License-Identifier: MIT
// Structural branch subtraction is zero exactly for an OR child (kind 6).
include "../../raw/Machine.dfy"
module AssertionsConstraintOrStructureBranch {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = AssertionsRawResolveMachine
  import A = AssertionsSignedMachine
  import C = BytecodeCopyMachine
  type Word = S.Word
  type Byte = S.Byte
  lemma Subtract(code: seq<Byte>, prefix: seq<Word>, kind: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires 7890 <= |code| && code[7889] == 3 && |prefix| <= 1022 && kind <= 8
    ensures M.Step(code,{},S.Running(7889,prefix+[6,kind],mem),value,data) ==
      S.Running(7890,prefix+[((kind as nat)+G.Modulus()-6)%G.Modulus()],mem)
    ensures ((kind as nat)+G.Modulus()-6)%G.Modulus() == 0 <==> kind == 6
  {
    reveal M.Step(); reveal C.Step(); reveal A.Step(); reveal S.Step();
  }
}
