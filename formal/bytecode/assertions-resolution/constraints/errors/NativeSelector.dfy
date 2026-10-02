// SPDX-License-Identifier: MIT
// Directed native sensitivity witness for the physical InvalidConstraintData selector.
include "../../Execution.dfy"
include "../../Fetch.dfy"
module AssertionsConstraintErrorSelector {
  import S = BytecodeScanMachine
  import M = AssertionsSignedMachine
  import F = AssertionsConstraintFetch
  type Word = S.Word
  type Byte = S.Byte
  lemma PushSelector(code: seq<Byte>, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires |code| == 20049 && |prefix| < 1024
    requires code[11083] == 0x63 && code[11084] == 0x73 && code[11085] == 0x86 && code[11086] == 0x73 && code[11087] == 0xb3
    ensures M.Step(code,{},S.Running(11083,prefix,mem),value,data) == S.Running(11088,prefix+[0x738673b3],mem)
  {
    F.Push4(code,11083);
    reveal M.Step(); reveal S.Step();
  }
}
