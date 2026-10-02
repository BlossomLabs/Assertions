// SPDX-License-Identifier: MIT
// Physical mutation witness for the independently specified InvalidOrConstraint selector.
include "../../raw/Machine.dfy"
include "../../Fetch.dfy"
module AssertionsConstraintOrSelectorWitness {
  import S = BytecodeScanMachine
  import M = AssertionsRawResolveMachine
  import A = AssertionsSignedMachine
  import C = BytecodeCopyMachine
  import F = AssertionsConstraintFetch
  type Word = S.Word
  type Byte = S.Byte
  lemma Push(code: seq<Byte>, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires |code| == 20049 && |prefix| < 1024
    requires code[7791] == 0x63 && code[7792] == 0x3f && code[7793] == 0x9b && code[7794] == 0xbb && code[7795] == 0x3b
    ensures M.Step(code,{},S.Running(7791,prefix,mem),value,data) == S.Running(7796,prefix+[0x3f9bbb3b],mem)
  {
    F.Push4(code,7791);
    reveal M.Step(); reveal C.Step(); reveal A.Step(); reveal S.Step();
  }
}
