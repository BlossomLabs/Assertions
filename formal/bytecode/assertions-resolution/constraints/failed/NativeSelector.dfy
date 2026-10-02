// SPDX-License-Identifier: MIT
// Physical mutation witness for the independently specified ConstraintFailed selector.
include "../../raw/Machine.dfy"
include "../../Fetch.dfy"
module AssertionsConstraintFailedSelectorWitness {
  import S = BytecodeScanMachine
  import M = AssertionsRawResolveMachine
  import A = AssertionsSignedMachine
  import C = BytecodeCopyMachine
  import F = AssertionsConstraintFetch
  type Word = S.Word
  type Byte = S.Byte
  lemma Push(code: seq<Byte>, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires |code| == 20049 && |prefix| < 1024
    requires code[8054] == 0x63 && code[8055] == 0xde && code[8056] == 0xb9 && code[8057] == 0xf2 && code[8058] == 0xaf
    ensures M.Step(code,{},S.Running(8054,prefix,mem),value,data) == S.Running(8059,prefix+[0xdeb9f2af],mem)
  {
    F.Push4(code,8054);
    reveal M.Step(); reveal C.Step(); reveal A.Step(); reveal S.Step();
  }
}
