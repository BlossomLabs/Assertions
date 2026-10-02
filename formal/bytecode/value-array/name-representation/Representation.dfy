// SPDX-License-Identifier: MIT
// Connect both compiled name word shifts to independent complete literal bytes.
include "Five.generated.dfy"
include "Six.generated.dfy"
include "../byte-machine/Scalar.dfy"
module BytecodeCollectionsNameRepresentation {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import Z = BytecodeCollectionsArrayByteScalar
  import Five = BytecodeCollectionsNameShiftFive
  import Six = BytecodeCollectionsNameShiftSix
  lemma PowerAdd(a: nat,b: nat)
    ensures G.Pow256(a+b) == G.Pow256(a)*G.Pow256(b)
    decreases b
  { if b > 0 { PowerAdd(a,b-1); } }
  lemma Distribute(a: nat,b: nat,c: nat,d: nat)
    ensures (a*b+c)*d == a*(b*d)+c*d
  { }
  lemma Concat(first: seq<Byte>,last: seq<Byte>)
    ensures G.Decode(first+last) == G.Decode(first)*G.Pow256(|last|)+G.Decode(last)
    decreases |last|
  {
    if |last| > 0 {
      var tail := last[..|last|-1]; var end := last[|last|-1];
      Concat(first,tail);
      assert (first+last)[..|first|+|last|-1] == first+tail;
      assert (first+last)[|first|+|last|-1] == end;
      assert G.Decode(first+last) == G.Decode(first+tail)*256+end;
      assert G.Decode(last) == G.Decode(tail)*256+end;
      assert G.Pow256(|last|) == G.Pow256(|tail|)*256;
      hide G.Decode();hide G.Pow256();
      Distribute(G.Decode(first),G.Pow256(|tail|),G.Decode(tail),256);
      calc {
         G.Decode(first+last);
      == G.Decode(first+tail)*256+end;
      == (G.Decode(first)*G.Pow256(|tail|)+G.Decode(tail))*256+end;
      == G.Decode(first)*(G.Pow256(|tail|)*256)+G.Decode(tail)*256+end;
      == G.Decode(first)*G.Pow256(|last|)+G.Decode(last);
      }
    } else {
      assert last == [];
      assert first+last == first && G.Pow256(0) == 1 && G.Decode(last) == 0;
    }
  }
  lemma Encoding(bytes: seq<Byte>)
    ensures G.Encode(G.Decode(bytes),|bytes|) == bytes
    decreases |bytes|
  {
    if |bytes| > 0 {
      Encoding(bytes[..|bytes|-1]);
      var head := G.Decode(bytes[..|bytes|-1]); var last := bytes[|bytes|-1];
      Z.Quotient(head,last,256);
      assert (head*256+last)%256 == last;
      assert bytes[..|bytes|-1]+[last] == bytes;
    }
  }
  lemma Prefix(data: seq<Byte>,offset: Word,width: nat)
    requires width == 5 || width == 6
    ensures DataWord(data,offset)/G.Pow256(32-width) == G.Decode(Window(data,offset,width))
  {
    var bytes := Window(data,offset,32);
    G.DecodeBound(bytes);G.WordPower();
    var first := bytes[..width];var last := bytes[width..];
    assert bytes == first+last;
    Concat(first,last);G.DecodeBound(last);
    Z.Quotient(G.Decode(first),G.Decode(last),G.Pow256(32-width));
    assert first == Window(data,offset,width);
  }
  lemma GenericRight(word: Word,amount: Word)
    ensures ShiftRight(word,amount) == (if amount >= 256 then 0 else (((word as bv256) >> (amount as nat)) as nat))
  {}
  lemma NineLiteral(amount: nat)
    requires amount == 216 || amount == 208
    ensures (amount as bv9) == (if amount == 216 then (216 as bv9) else (208 as bv9))
  {}
  lemma RightFiveLiteral(word: Word,amount: Word)
    requires amount == 216
    ensures (((word as bv256) >> (amount as nat)) as nat) == (((word as bv256) >> 216) as nat)
  { NineLiteral(amount); }
  lemma RightSixLiteral(word: Word,amount: Word)
    requires amount == 208
    ensures (((word as bv256) >> (amount as nat)) as nat) == (((word as bv256) >> 208) as nat)
  {
    RightSixBits(word as bv256, amount);
  }
  lemma RightSixBits(word: bv256,amount: nat)
    requires amount == 208
    ensures word >> amount == word >> 208
  {
    NineLiteral(amount);
    assert (amount as bv9) == (208 as bv9);
    assert word >> amount == word >> 208;
  }
  lemma {:autoRevealDependencies false} FiveWord(word: Word)
    ensures ShiftRight(word,216) == word/0x1000000000000000000000000000000000000000000000000000000
  {
    hide ShiftRight();
    GenericRight(word,216);RightFiveLiteral(word,216);
    Five.Natural256(word);
  }
  lemma {:autoRevealDependencies false} SixWord(word: Word)
    ensures ShiftRight(word,208) == word/0x10000000000000000000000000000000000000000000000000000
  {
    hide ShiftRight();
    GenericRight(word,208);RightSixLiteral(word,208);
    Six.Natural256(word);
  }
  lemma Literal(bytes: seq<Byte>,literal: seq<Byte>)
    requires |bytes| == |literal|
    ensures G.Decode(bytes) == G.Decode(literal) <==> bytes == literal
  {
    if G.Decode(bytes) == G.Decode(literal) { Encoding(bytes);Encoding(literal); }
  }
  lemma BytesName(data: seq<Byte>,offset: Word)
    ensures ShiftRight(DataWord(data,offset),216) == 422944466291 <==> Window(data,offset,5) == [98,121,116,101,115]
  {
    Prefix(data,offset,5);FiveWord(DataWord(data,offset));Z.WordPowers();
    assert G.Pow256(27) == 0x1000000000000000000000000000000000000000000000000000000;
    var literal: seq<Byte> := [98,121,116,101,115];
    assert G.Decode([]) == 0;
    assert [98][..0] == [];
    assert G.Decode([98]) == 98;
    assert [98,121][..1] == [98];
    assert G.Decode([98,121]) == 25209;
    assert [98,121,116][..2] == [98,121];
    assert G.Decode([98,121,116]) == 6453620;
    assert [98,121,116,101][..3] == [98,121,116];
    assert G.Decode([98,121,116,101]) == 1652126821;
    assert [98,121,116,101,115][..4] == [98,121,116,101];
    assert G.Decode([98,121,116,101,115]) == 422944466291;
    assert G.Decode(literal) == 422944466291;
    Literal(Window(data,offset,5),literal);
  }
  lemma StringName(data: seq<Byte>,offset: Word)
    ensures ShiftRight(DataWord(data,offset),208) == 126943972912743 <==> Window(data,offset,6) == [115,116,114,105,110,103]
  {
    Prefix(data,offset,6);SixWord(DataWord(data,offset));Z.WordPowers();
    assert G.Pow256(26) == 0x10000000000000000000000000000000000000000000000000000;
    var literal: seq<Byte> := [115,116,114,105,110,103];
    assert G.Decode([]) == 0;
    assert [115][..0] == [];
    assert G.Decode([115]) == 115;
    assert [115,116][..1] == [115];
    assert G.Decode([115,116]) == 29556;
    assert [115,116,114][..2] == [115,116];
    assert G.Decode([115,116,114]) == 7566450;
    assert [115,116,114,105][..3] == [115,116,114];
    assert G.Decode([115,116,114,105]) == 1937011305;
    assert [115,116,114,105,110][..4] == [115,116,114,105];
    assert G.Decode([115,116,114,105,110]) == 495874894190;
    assert [115,116,114,105,110,103][..5] == [115,116,114,105,110];
    assert G.Decode([115,116,114,105,110,103]) == 126943972912743;
    assert G.Decode(literal) == 126943972912743;
    Literal(Window(data,offset,6),literal);
  }
}
