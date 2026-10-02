// SPDX-License-Identifier: MIT
// Exact byte SHR instruction kept separate from raw byte representation.
include "../../scans/Machine.dfy"
module BytecodeFoldDomainShift {
  import opened BytecodeScanMachine
  lemma At(code: seq<Byte>,destinations: set<nat>,word: Word,prefix: seq<Word>,mem: seq<Byte>,value: Word,data: seq<Byte>)
    requires |code| > 19382 && code[19382] == 0x1c && |prefix| <= 1022
    ensures Step(code,destinations,Running(19382,prefix+[word,248],mem),value,data) == Running(19383,prefix+[ShiftRight(word,248)],mem)
  {
    reveal Step();
    assert Fetch(code,19382) == Op(28,19383,0);
  }
}
