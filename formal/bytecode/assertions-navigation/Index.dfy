// SPDX-License-Identifier: MIT
include "../scans/ErrorBytes.dfy"
module AssertionsNavigationIndex {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanErrorBytes
  import R = BytecodeScanRepresentation
  type Word = S.Word
  type Byte = S.Byte
  predicate Valid(index: Word, count: Word) {
    if G.Signed(index) < 0 then -G.Signed(index) <= count else index < count
  }
  function Normalized(index: Word, count: Word): Word {
    if G.Signed(index) < 0 then (count+G.Signed(index))%G.Modulus() else index
  }
  lemma Bounds(index: Word, count: Word)
    requires count < G.Modulus()/2 && Valid(index,count)
    ensures Normalized(index,count) < count
  {}
  lemma Classes(index: Word, count: Word)
    ensures (G.Signed(index) < 0 && Valid(index,count)) ||
            (G.Signed(index) < 0 && !Valid(index,count)) ||
            (G.Signed(index) >= 0 && Valid(index,count)) ||
            (G.Signed(index) >= 0 && !Valid(index,count))
  {}
  lemma ExpansionIdentity(mem: seq<Byte>, length: nat)
    requires |mem|%32 == 0 && length <= |mem|
    ensures S.Expand(mem,length) == mem
  {
    assert length <= (|mem|/32)*32;
    assert (length+31)/32 <= |mem|/32;
  }
  function ErrorMemory(mem: seq<Byte>, free: Word, index: Word, count: Word): seq<Byte>
    requires (free as nat)+68 < G.Modulus()
  {
    S.Store(S.Store(S.Store(mem,free,268501358*0x100000000000000000000000000000000000000000000000000000000),free+4,index),free+36,count)
  }
  lemma ErrorBytes(mem: seq<Byte>, free: Word, index: Word, count: Word)
    requires |mem|%32 == 0 && (free as nat)+96 < G.Modulus()
    ensures ErrorMemory(mem,free,index,count)[free..free+68] ==
            G.Encode(268501358,4)+G.Encode(index,32)+G.Encode(count,32)
    ensures |ErrorMemory(mem,free,index,count)|%32 == 0
  {
    var header: Word := 268501358*0x100000000000000000000000000000000000000000000000000000000;
    E.PhysicalError(mem,free,268501358,header,index);
    var first := S.Store(S.Store(mem,free,header),free+4,index);
    R.StoredWord(mem,free,header);
    R.StoredWord(S.Store(mem,free,header),free+4,index);
    R.StoredWord(first,free+36,count);
    var expanded := S.Expand(first,(free as nat)+68);
    assert expanded[..|first|] == first;
    assert expanded[free..free+36] == first[free..free+36];
    assert S.Store(first,free+36,count)[free..free+68] ==
           S.Store(first,free+36,count)[free..free+36]+S.Store(first,free+36,count)[free+36..free+68];
  }
}
