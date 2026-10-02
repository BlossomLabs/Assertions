// SPDX-License-Identifier: MIT
// Physical byte/calldata projections, separate from reached instruction paths.
include "Machine.dfy"
module BytecodeScanRepresentation {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  lemma WindowFits(data: seq<Byte>, offset: nat, width: nat)
    requires offset+width <= |data|
    ensures Window(data,offset,width) == data[offset..offset+width]
  {
    forall i | 0 <= i < width
      ensures Window(data,offset,width)[i] == data[offset..offset+width][i]
    {}
  }
  lemma WordProjection(data: seq<Byte>, offset: Word)
    requires (offset as nat)+32 <= |data|
    ensures DataWord(data,offset) == G.Decode(data[offset..offset+32])
  {
    WindowFits(data,offset,32);
    G.WordPower();
    G.DecodeBound(data[offset..offset+32]);
  }
  lemma EncodedWord(prefix: seq<Byte>, word: Word, suffix: seq<Byte>)
    requires |prefix| < G.Modulus()
    ensures DataWord(prefix+G.Encode(word,32)+suffix,|prefix|) == word
  {
    G.WordPower();
    G.RoundTrip(word,32);
    WordProjection(prefix+G.Encode(word,32)+suffix,|prefix|);
    assert (prefix+G.Encode(word,32)+suffix)[|prefix|..|prefix|+32] == G.Encode(word,32);
  }
  lemma Expansion(mem: seq<Byte>, length: nat)
    requires |mem|%32 == 0
    ensures |Expand(mem,length)|%32 == 0
    ensures |Expand(mem,length)| >= |mem| && |Expand(mem,length)| >= length
    ensures Expand(mem,length)[..|mem|] == mem
    ensures |Expand(mem,length)| == (if |mem| >= Round32(length) then |mem| else Round32(length))
  {
    assert length <= Round32(length);
    assert Round32(length)%32 == 0;
    if |mem| < Round32(length) {
      assert G.Grow(mem,Round32(length))[..|mem|] == mem;
    }
  }
  lemma StoredWord(mem: seq<Byte>, offset: Word, word: Word)
    requires |mem|%32 == 0
    ensures Load(Store(mem,offset,word),offset) == word
    ensures Store(mem,offset,word)[offset..offset+32] == G.Encode(word,32)
    ensures |Store(mem,offset,word)|%32 == 0
    ensures |Store(mem,offset,word)| == (if |mem| >= Round32((offset as nat)+32) then |mem| else Round32((offset as nat)+32))
  {
    Expansion(mem,(offset as nat)+32);
    G.StoreLoad(Expand(mem,(offset as nat)+32),offset,word);
    var expanded := Expand(mem,(offset as nat)+32);
    assert G.Grow(expanded,(offset as nat)+32) == expanded;
    assert |G.Store(expanded,offset,word)| == |expanded|;
  }
  lemma StoredFrame(mem: seq<Byte>, offset: Word, word: Word, other: Word)
    requires (other as nat)+32 <= |mem|
    requires (other as nat)+32 <= offset || (offset as nat)+32 <= other
    ensures Load(Store(mem,offset,word),other) == Load(mem,other)
  {
    var expanded := Expand(mem,(offset as nat)+32);
    assert expanded[..|mem|] == mem;
    assert expanded[other..other+32] == mem[other..other+32];
    G.StoreFrame(expanded,offset,word,other);
    assert G.Grow(expanded,(other as nat)+32) == expanded;
    assert G.Grow(mem,(other as nat)+32) == mem;
  }
}
