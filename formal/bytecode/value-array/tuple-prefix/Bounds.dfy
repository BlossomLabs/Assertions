// SPDX-License-Identifier: MIT
// Exact partial tuple widths derive from accepted children and disjoint input spans.
include "../type-parser/Bounds.dfy"
module BytecodeCollectionsTuplePrefixBounds {
  import G = BytecodeGetterMachine
  import D = BytecodeCollectionsDecimalLoop
  import T = BytecodeCollectionsTypeSemantics
  import B = BytecodeCollectionsTypeBounds
  import S = BytecodeCollectionsSuffixSemantics
  predicate Children(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,children: seq<T.Descriptor>) {
    p < limit && D.DataByte(data,offset,p) == 40 &&
    (forall i :: 0 <= i < |children| ==>
                   T.Start(p,children,i) < limit && B.Syntax(data,offset,T.Start(p,children,i),limit,children[i]) &&
                   children[i].shape.pos < limit && D.DataByte(data,offset,children[i].shape.pos) == 44)
  }
  function Next(p: G.Word,children: seq<T.Descriptor>): nat {
    if |children| == 0 then p+1 else children[|children|-1].shape.pos+1
  }
  lemma Admission(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,children: seq<T.Descriptor>)
    requires Children(data,offset,p,limit,children) && limit < 0x10000000000000000
    ensures forall i :: 0 <= i < |children| ==> T.Valid(data,offset,T.Start(p,children,i),limit,children[i])
    ensures forall i :: 0 <= i < |children| ==> children[i].shape.span >= 1
    ensures 0 <= T.Sum(children) < G.Modulus()
    ensures p < Next(p,children) <= limit
    ensures T.Sum(children) <= 0xffffffff*(Next(p,children)-p)

  {
    var index: nat := 0;var cursor: nat := p;
    while index < |children|
      invariant 0 <= index <= |children|
      invariant cursor == (if index == 0 then p else children[index-1].shape.pos)
      invariant p <= cursor <= limit
      invariant index < |children| ==> T.Start(p,children,index) == cursor+1
      invariant 0 <= T.Sum(children[..index]) <= 0xffffffff*(cursor-p-index)
      invariant forall j :: 0 <= j < index ==> T.Valid(data,offset,T.Start(p,children,j),limit,children[j])
      invariant forall j :: 0 <= j < |children| ==> children[j].shape.span >= 1
      decreases |children|-index
    {
      var start: G.Word := T.Start(p,children,index);
      B.Admission(data,offset,start,limit,children[index]);T.Extend(children,index);
      assert children[index].shape.pos > cursor;
      assert T.Sum(children[..index+1]) <= 0xffffffff*(children[index].shape.pos-p-(index+1));
      cursor := children[index].shape.pos;index := index+1;
    }
    assert T.Sum(children) <= 0xffffffff*limit < G.Modulus();
    assert p < Next(p,children) <= limit;
    assert T.Sum(children) <= 0xffffffff*(Next(p,children)-p);
  }
}
