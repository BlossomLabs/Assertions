// SPDX-License-Identifier: MIT
// Connect positive-count physical allocation to the zero-child induction heap.
include "NonemptyFillHeap.dfy"
include "NonemptyStart.generated.dfy"
module AssertionsConstraintOrNonemptyAllocationHeap {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import W = AssertionsConstraintOrNonemptyWire
  import P = AssertionsConstraintOrNonemptyStart
  import H = AssertionsConstraintOrNonemptyFillHeap
  import X = SharedFoundationStoreExtent
  import R = BytecodeScanRepresentation
  type Word = S.Word
  type Byte = S.Byte
  function Reserved(free: Word, children: seq<W.Child>): Word
    requires (free as nat)+32+|children|*32 < G.Modulus()
  { free+32+|children|*32 }
  lemma {:isolate_assertions} Allocate(mem: seq<Byte>, free: Word, children: seq<W.Child>)
    requires 0 < |children| && 128 <= free && free%32 == 0
    requires |mem|%32 == 0 && 96 <= |mem| <= free+32
    requires (free as nat)+32+|children|*32+W.Cost(children)+160 < 0x10000000000000000
    ensures H.Partial(P.Construct(mem,free,|children|),free,Reserved(free,children),children,0)
  {
    hide S.Store(); hide S.Load();
    var reserved := Reserved(free,children);
    var m0 := S.Store(mem,64,reserved);
    var image := S.Store(m0,free,|children|);
    X.Length(mem,64,reserved);
    X.Aligned(mem,64,reserved);
    X.Length(m0,free,|children|);
    X.Aligned(m0,free,|children|);
    R.StoredWord(mem,64,reserved);
    R.StoredWord(m0,free,|children|);
    R.StoredFrame(m0,free,|children|,64);
    assert W.Cost(children[..0]) == 0;
    assert W.Free(reserved,children,0) == reserved;
    assert reserved%32 == 0;
    assert |image| == free+32;
  }
}
