// SPDX-License-Identifier: MIT
// The allocator writes outside the original ABI child-array source image.
include "NonemptyAllocationHeap.dfy"
module AssertionsConstraintOrNonemptyAllocationFrame {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import W = AssertionsConstraintOrNonemptyWire
  import P = AssertionsConstraintOrNonemptyStart
  import H = AssertionsConstraintOrNonemptyAllocationHeap
  import X = SharedFoundationStoreExtent
  import R = BytecodeScanRepresentation
  type Word = S.Word
  type Byte = S.Byte
  lemma Read(mem: seq<Byte>, free: Word, count: Word, location: Word)
    requires (free as nat)+32+count*32 < G.Modulus()
    requires 128 <= free && 96 <= location && location+32 <= |mem| && location+32 <= free
    ensures S.Load(P.Construct(mem,free,count),location) == S.Load(mem,location)
  {
    hide S.Store(); hide S.Load();
    var reserved := free+32+count*32;
    var m0 := S.Store(mem,64,reserved);
    R.StoredFrame(mem,64,reserved,location);
    X.Length(mem,64,reserved);
    R.StoredFrame(m0,free,count,location);
  }
  lemma {:isolate_assertions} Layout(mem: seq<Byte>, start: Word, end: Word, relative: Word, children: seq<W.Child>, free: Word)
    requires W.Layout(mem,start,end,relative,children) && end <= free && 128 <= free
    requires (free as nat)+32+|children|*32 < G.Modulus()
    ensures W.Layout(P.Construct(mem,free,|children|),start,end,relative,children)
  {
    hide P.Construct(); hide S.Store(); hide S.Load();
    var reserved := free+32+|children|*32;
    var m0 := S.Store(mem,64,reserved);
    var image := P.Construct(mem,free,|children|);
    reveal P.Construct();
    X.Length(mem,64,reserved);
    X.Length(m0,free,|children|);
    var body := W.Body(start,relative);
    assert body == start+relative;
    Read(mem,free,|children|,start);
    Read(mem,free,|children|,body);
    forall i {:trigger children[i]} | 0 <= i < |children|
      ensures S.Load(image,body+32+i*32) == children[i].position
      ensures S.Load(image,W.Offset(body,children[i])+32) == children[i].kind
      ensures S.Load(image,W.Offset(body,children[i])+64) == children[i].referenceRelative
      ensures S.Load(image,W.Offset(body,children[i])+children[i].referenceRelative+32) == children[i].length
    {
      W.Item(mem,start,end,relative,children,i);
      Read(mem,free,|children|,body+32+i*32);
      Read(mem,free,|children|,W.Offset(body,children[i])+32);
      Read(mem,free,|children|,W.Offset(body,children[i])+64);
      Read(mem,free,|children|,W.Offset(body,children[i])+children[i].referenceRelative+32);
    }
  }
}
