// SPDX-License-Identifier: MIT
// Inductive decoded table prefix for the actual nonempty child constructor.
include "NonemptyWireFrame.dfy"
module AssertionsConstraintOrNonemptyFillHeap {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import W = AssertionsConstraintOrNonemptyWire
  import N = AssertionsConstraintOrNonemptyMemory
  import B = AssertionsConstraintOrNonemptyBounds
  import R = AssertionsConstraintOrNonemptyWireFrame
  type Word = S.Word
  type Byte = S.Byte
  function Image(mem: seq<Byte>, arrayptr: Word, initial: Word, children: seq<W.Child>, i: nat, source: Word): seq<Byte>
    requires i < |children| && (initial as nat)+W.Cost(children)+160 < 0x10000000000000000
    requires (arrayptr as nat)+32+|children|*32 <= initial
  {
    W.FreeStep(initial,children,i);
    N.Construct(mem,W.Free(initial,children,i),children[i].kind,source,children[i].length,arrayptr+32+i*32)
  }
  predicate Partial(mem: seq<Byte>, arrayptr: Word, initial: Word, children: seq<W.Child>, i: nat)
    requires i <= |children| && (initial as nat)+W.Cost(children)+160 < 0x10000000000000000
  {
    var free := W.Free(initial,children,i);
    0 < |children| && 96 <= arrayptr && arrayptr+32+|children|*32 <= initial && 128 <= initial && initial%32 == 0 &&
    |mem|%32 == 0 && 96 <= |mem| <= free+32 && free%32 == 0 &&
    arrayptr+32+i*32 <= |mem| && S.Load(mem,arrayptr) == |children| && S.Load(mem,64) == free &&
    forall j {:trigger children[j]} :: 0 <= j < i ==>
      children[j].kind <= 8 && W.Free(initial,children,j)+32 <= |mem| &&
      W.Free(initial,children,j)+32 <= free &&
      S.Load(mem,arrayptr+32+j*32) == W.Free(initial,children,j) &&
      S.Load(mem,W.Free(initial,children,j)) == children[j].kind
  }
  lemma {:isolate_assertions} Step(mem: seq<Byte>, arrayptr: Word, initial: Word, children: seq<W.Child>, i: nat, source: Word)
    requires i < |children| && (initial as nat)+W.Cost(children)+160 < 0x10000000000000000
    requires Partial(mem,arrayptr,initial,children,i)
    requires children[i].kind <= 8 && source+children[i].length <= W.Free(initial,children,i)
    ensures Partial(Image(mem,arrayptr,initial,children,i,source),arrayptr,initial,children,i+1)
  {
    hide S.Store(); hide S.Load(); hide N.Construct();
    var free := W.Free(initial,children,i);
    var slot := arrayptr+32+i*32;
    var c := children[i];
    W.FreeStep(initial,children,i);
    var image := N.Construct(mem,free,c.kind,source,c.length,slot);
    N.Fields(mem,free,c.kind,source,c.length,slot);
    B.Size(mem,free,c.kind,source,c.length,slot);
    R.Read(mem,free,c.kind,source,c.length,slot,arrayptr);
    assert W.Free(initial,children,i+1) == N.NextFree(free,c.length);
    assert initial <= free;
    assert free <= W.Free(initial,children,i+1);
    assert free+32 <= |image|;
    forall j {:trigger children[j]} | 0 <= j < i
      ensures S.Load(image,arrayptr+32+j*32) == W.Free(initial,children,j)
      ensures S.Load(image,W.Free(initial,children,j)) == children[j].kind
      ensures W.Free(initial,children,j)+32 <= |image| && W.Free(initial,children,j)+32 <= W.Free(initial,children,i+1)
    {
      W.PrefixCost(children,j);
      var priorChild := children[j];
      assert priorChild.kind <= 8;
      assert W.Free(initial,children,j)+32 <= |mem|;
      assert W.Free(initial,children,j)+32 <= free;
      assert initial <= W.Free(initial,children,j);
      R.Read(mem,free,c.kind,source,c.length,slot,arrayptr+32+j*32);
      R.Read(mem,free,c.kind,source,c.length,slot,W.Free(initial,children,j));
    }
    assert W.Free(initial,children,i)+32 <= |image|;
  }
}
