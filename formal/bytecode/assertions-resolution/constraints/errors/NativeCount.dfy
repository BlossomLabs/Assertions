// SPDX-License-Identifier: MIT
// Directed native sensitivity of the word-count precheck's actual LT opcode.
include "../../Execution.dfy"
module AssertionsConstraintCountWitness {
  import S = BytecodeScanMachine
  import M = AssertionsSignedMachine
  type Word = S.Word
  type Byte = S.Byte
  lemma CountCheck(code: seq<Byte>, prefix: seq<Word>, mem: seq<Byte>, words: Word, count: Word,
                   value: Word, data: seq<Byte>)
    requires |code| == 20049 && code[7615] == 0x10 && |prefix| <= 1022 && words < count
    ensures M.Step(code,{},S.Running(7615,prefix+[count,words],mem),value,data) == S.Running(7616,prefix+[1],mem)
  { reveal M.Step(); reveal S.Step(); }
}
