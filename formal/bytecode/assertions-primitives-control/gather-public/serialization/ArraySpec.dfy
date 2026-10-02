// SPDX-License-Identifier: MIT
// Independent physical ABI arrayBase-encoder layout, separate from its instructions.
include "Spec.dfy"
module AssertionsGatherArraySpec {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import W = AssertionsNavigationShift
  import N = BytecodeScanScalar
  import R = BytecodeScanRepresentation
  type Word = S.Word
  type Byte = S.Byte
  predicate StartHeap(mem: seq<Byte>, arrayBase: Word, base: Word, count: Word) {
    |mem|%32 == 0 && 96 <= |mem| <= base+32 && 128 <= base && base%32 == 0 &&
    count < 0x10000000000000000 && arrayBase+32 <= |mem| && arrayBase+32+count*32 <= base &&
    base+128+count*32 < 0x10000000000000000 && S.Load(mem,arrayBase) == count
  }
  predicate LoopHeap(mem: seq<Byte>, arrayBase: Word, base: Word, tail: Word, head: Word,
                     count: Word, source: Word, index: Word) {
    |mem|%32 == 0 && 96 <= |mem| <= tail+32 && 128 <= base && base%32 == 0 &&
    count < 0x10000000000000000 && index <= count &&
    arrayBase+32+count*32 <= base && arrayBase+32+count*32 <= |mem| && base+64+count*32 <= tail &&
    tail+64 < 0x10000000000000000 && tail%32 == 0 &&
    head == base+64+index*32 && source == arrayBase+32+index*32
  }
  function Header1(mem: seq<Byte>, base: Word): seq<Byte> { S.Store(mem,base,32) }
  function Header2(mem: seq<Byte>, base: Word, count: Word): seq<Byte>
    requires base+32 < G.Modulus()
  { S.Store(Header1(mem,base),base+32,count) }
  function Offset(base: Word, tail: Word): Word
    requires base+64 <= tail
  { tail-base-64 }
  function Slot(mem: seq<Byte>, base: Word, tail: Word, head: Word): seq<Byte>
    requires base+64 <= tail
  { S.Store(mem,head,Offset(base,tail)) }
  lemma StartWords(mem: seq<Byte>, arrayBase: Word, base: Word, count: Word)
    requires StartHeap(mem,arrayBase,base,count)
    ensures S.Load(Header1(mem,base),arrayBase) == count
    ensures S.ShiftLeft(count,5) == count*32
    ensures |Header2(mem,base,count)|%32 == 0 && |Header2(mem,base,count)| == base+64
  {
    Remainder(base); W.Scalar(count);
    var first := Header1(mem,base);
    R.StoredWord(mem,base,32);
    R.StoredFrame(mem,base,32,arrayBase);
    R.StoredWord(first,base+32,count);
  }
  lemma Remainder(base: Word)
    requires base%32 == 0
    ensures S.Round32((base as nat)+32) == base+32 && S.Round32((base as nat)+64) == base+64
  {}
  lemma Complement63()
    ensures S.BitNot(63) == G.Modulus()-64
  {
    N.Narrow(63);
    assert !(63 as bv256) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc0;
  }
  lemma LoopWords(mem: seq<Byte>, arrayBase: Word, base: Word, tail: Word, head: Word, count: Word, source: Word, index: Word)
    requires LoopHeap(mem,arrayBase,base,tail,head,count,source,index)
    ensures S.BitNot(63) == G.Modulus()-64
    ensures ((tail as nat)+G.Modulus()-base)%G.Modulus() == tail-base
    ensures ((G.Modulus()-64)+(tail-base))%G.Modulus() == Offset(base,tail)
    ensures source < G.Modulus() && head < G.Modulus()
    ensures index < count ==> head+32 <= tail && source+32 <= base
    ensures index+1 < G.Modulus() && source+32 < G.Modulus() && head+32 < G.Modulus()
  { Complement63(); }
}
