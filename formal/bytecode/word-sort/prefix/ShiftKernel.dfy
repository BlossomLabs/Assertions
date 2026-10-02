// SPDX-License-Identifier: MIT
// Actual PC29 SHR without expanding calldata representation in the instruction proof.
include "../../scans/Machine.dfy"
module BytecodeSortPrefixShift {
  import opened BytecodeScanMachine
  lemma At(code: seq<Byte>, destinations: set<nat>, word: Word, prefix: seq<Word>,
           mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires |code| > 29 && code[29] == 0x1c && |prefix| <= 1022
    ensures Step(code,destinations,Running(29,prefix+[word,224],mem),value,data) ==
            Running(30,prefix+[ShiftRight(word,224)],mem)
  {
    reveal Step();
    assert Fetch(code,29) == Op(28,30,0);
  }
  lemma Loaded(code: seq<Byte>, destinations: set<nat>, state: State,
               mem: seq<Byte>, value: Word, data: seq<Byte>, selector: Word)
    requires |code| > 29 && code[29] == 0x1c
    requires state == Running(29,[DataWord(data,0),224],mem)
    requires ShiftRight(DataWord(data,0),224) == selector
    ensures Step(code,destinations,state,value,data) == Running(30,[selector],mem)
  {
    hide ShiftRight(); hide DataWord();
    At(code,destinations,DataWord(data,0),[],mem,value,data);
    assert state == Running(29,[]+[DataWord(data,0),224],mem);
  }
}
