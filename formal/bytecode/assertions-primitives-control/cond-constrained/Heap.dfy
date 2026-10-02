// SPDX-License-Identifier: MIT
// The constrained resolver's allocated heap retains the original condition word.
include "../../assertions-resolution/constrained-raw/Connection.dfy"
include "../cond-class/FirstWord.dfy"
module AssertionsCondConstrainedHeap {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import L = AssertionsConstraintLoopSpec
  import W = AssertionsCondFirstWord
  import D = AssertionsGatherCallerSpec
  type Word = S.Word
  type Byte = S.Byte

  function First(bytes: seq<Byte>): Word {
    if |bytes| < 32 then 0 else L.Actual(bytes,0)
  }

  lemma FirstWordHeap(code: seq<Byte>, ret: Word, prefix: seq<Word>, mem: seq<Byte>,
                      pointer: Word, bytes: seq<Byte>, free: Word)
    requires L.Heap(mem,pointer,bytes,free)
    requires free+96 < G.Modulus() && |prefix| <= 960
    requires ret in D.RuntimeDestinations() && ret < |code| && code[ret] == 0x5b
    ensures W.Heap(code,ret,prefix,mem,pointer,|bytes|,First(bytes),free)
  {
    if |bytes| >= 32 { L.PhysicalWord(mem,pointer,bytes,free,0); }
  }
}
