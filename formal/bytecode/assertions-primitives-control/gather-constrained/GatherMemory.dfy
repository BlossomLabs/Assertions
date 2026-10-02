// SPDX-License-Identifier: MIT
// Byte-window interfaces for retaining filled gather slots and earlier bytes objects.
include "../gather-composition/Memory.dfy"
include "../../assertions-resolution/constraints/Sequences.dfy"
module AssertionsGatherConstrainedMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import P = AssertionsPrimitivePreparation
  import H = AssertionsGatherLoopMemory
  import Q = AssertionsConstraintSequences
  type Word = S.Word
  type Byte = S.Byte
  function End(mem: seq<Byte>, free: Word): nat { if free <= |mem| then free else |mem| }
  lemma PreparedWindow(mem: seq<Byte>, free: Word, start: Word, size: nat)
    requires |mem|%32 == 0 && 96 <= |mem| <= free+32 && free%32 == 0 && 128 <= free && free+64 < 0x10000000000000000
    requires 128 <= start && (start as nat)+size <= free && (start as nat)+size <= |mem|
    ensures (start as nat)+size <= |P.EmptyAssertion(mem,free)|
    ensures P.EmptyAssertion(mem,free)[start..start+size] == mem[start..start+size]
  {
    var first := S.Store(mem,64,free+32);
    H.StoredRegion(mem,64,free+32,start,size);
    H.StoredRegion(first,free,0,start,size);
  }
  lemma WindowWord(left: seq<Byte>, right: seq<Byte>, start: Word, size: nat, other: Word)
    requires (start as nat)+size <= |left| && (start as nat)+size <= |right|
    requires left[start..start+size] == right[start..start+size]
    requires start <= other && (other as nat)+32 <= (start as nat)+size
    ensures S.Load(left,other) == S.Load(right,other)
  {
    forall i {:trigger left[other+i], right[other+i]} | 0 <= i < 32
      ensures left[other+i] == right[other+i]
    {
      var relative := (other as nat)-start+i;
      assert left[start..start+size][relative] == left[other+i];
      assert right[start..start+size][relative] == right[other+i];
    }
    Q.Span(left,right,other,other,32);
    assert G.Grow(left,(other as nat)+32) == left;
    assert G.Grow(right,(other as nat)+32) == right;
  }
  lemma WindowBytes(left: seq<Byte>, right: seq<Byte>, start: Word, size: nat, other: Word, length: nat)
    requires (start as nat)+size <= |left| && (start as nat)+size <= |right|
    requires left[start..start+size] == right[start..start+size]
    requires start <= other && (other as nat)+length <= (start as nat)+size
    ensures left[other..other+length] == right[other..other+length]
  {
    forall i {:trigger left[other+i], right[other+i]} | 0 <= i < length
      ensures left[other+i] == right[other+i]
    {
      var relative := (other as nat)-start+i;
      assert left[start..start+size][relative] == left[other+i];
      assert right[start..start+size][relative] == right[other+i];
    }
    Q.Span(left,right,other,other,length);
  }
}
