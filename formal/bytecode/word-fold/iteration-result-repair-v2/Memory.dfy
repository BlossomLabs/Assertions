// SPDX-License-Identifier: MIT
// Exact current fold accumulator update and unchanged neighboring run fields.
include "../../scans/Representation.dfy"
module BytecodeFoldResultMemoryV2 {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  predicate Fits(mem: seq<Byte>) { 320 <= |mem| < 0x80000000000000000 && |mem|%32 == 0 }
  function Updated(mem: seq<Byte>,nextWord: Word): seq<Byte> { Store(mem,256,nextWord) }
  lemma Fields(mem: seq<Byte>,nextWord: Word)
    requires Fits(mem)
    ensures Fits(Updated(mem,nextWord)) && |Updated(mem,nextWord)| == |mem|
    ensures Load(Updated(mem,nextWord),256) == nextWord
    ensures Load(Updated(mem,nextWord),288) == Load(mem,288)
  { R.StoredWord(mem,256,nextWord); R.StoredFrame(mem,256,nextWord,288); }
  lemma Frame(mem: seq<Byte>,nextWord: Word,slot: Word)
    requires Fits(mem) && ((slot as nat)+32 <= 256 || 288 <= slot)
    ensures Load(Updated(mem,nextWord),slot) == Load(mem,slot)
  {
    R.StoredWord(mem,256,nextWord);
    var changed := Updated(mem,nextWord);
    assert |changed| == |mem|;
    var before := G.Grow(mem,(slot as nat)+32);
    var after := G.Grow(changed,(slot as nat)+32);
    forall j: nat | j < 32
      ensures after[slot+j] == before[slot+j]
    {
      if slot+j < |mem| {
        assert slot+j < 256 || 288 <= slot+j;
        assert changed[slot+j] == mem[slot+j];
      } else {
        assert after[slot+j] == 0 && before[slot+j] == 0;
      }
    }
    assert after[slot..slot+32] == before[slot..slot+32];
    G.LoadProjection(changed,slot); G.LoadProjection(mem,slot);
  }
}
