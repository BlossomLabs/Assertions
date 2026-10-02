// SPDX-License-Identifier: MIT
// Exact tuple base width derives from accepted children and disjoint input spans.
include "../type-parser/Bounds.dfy"
module BytecodeCollectionsTupleBaseBounds {
  import G = BytecodeGetterMachine
  import D = BytecodeCollectionsDecimalLoop
  import T = BytecodeCollectionsTypeSemantics
  import B = BytecodeCollectionsTypeBounds
  import S = BytecodeCollectionsSuffixSemantics
  predicate Children(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,children: seq<T.Descriptor>) {
    p < limit && |children| > 0 && D.DataByte(data,offset,p) == 40 &&
    (forall i :: 0 <= i < |children| ==>
                   T.Start(p,children,i) < limit && B.Syntax(data,offset,T.Start(p,children,i),limit,children[i]) &&
                   children[i].shape.pos < limit && D.DataByte(data,offset,children[i].shape.pos) == (if i+1 < |children| then 44 else 41))
  }
  function Base(p: G.Word,children: seq<T.Descriptor>): S.Shape
    requires |children| > 0
  {
    S.Shape(children[|children|-1].shape.pos+1,T.Flags(children),if T.Flags(children) == 1 then 1 else T.Sum(children))
  }
  lemma {:autoRevealDependencies false} Admission(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,children: seq<T.Descriptor>)
    requires Children(data,offset,p,limit,children) && limit < 0x10000000000000000
    ensures forall i :: 0 <= i < |children| ==> T.Valid(data,offset,T.Start(p,children,i),limit,children[i])
    ensures forall i :: 0 <= i < |children| ==> children[i].shape.span >= 1
    ensures 1 <= T.Sum(children) < G.Modulus()
    ensures p < Base(p,children).pos <= limit
    ensures 1 <= Base(p,children).span < G.Modulus()
    ensures Base(p,children).span <= 0xffffffff*(Base(p,children).pos-p)
  {
    reveal Children();reveal B.Syntax();reveal B.MathematicalFits();reveal T.Start();
    reveal Base();reveal T.Sum();reveal G.Modulus();
    assert p < limit && |children| > 0;
    assert forall j :: 0 <= j < |children| ==>
                         T.Start(p,children,j) < limit && B.Syntax(data,offset,T.Start(p,children,j),limit,children[j]) &&
                         children[j].shape.pos < limit;
    assert forall j :: 0 <= j < |children| ==> children[j].shape.span >= 1;
    hide Children();hide B.Syntax();hide T.Valid();
    var index: nat := 0;var cursor: nat := p;
    while index < |children|
      invariant 0 <= index <= |children| && |children| > 0
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
      assert start == cursor+1;
      assert children[index].shape.span <= 0xffffffff*(children[index].shape.pos-start);
      assert T.Sum(children[..index+1]) == T.Sum(children[..index])+children[index].shape.span;
      assert children[index].shape.pos > cursor;
      assert T.Sum(children[..index+1]) <= 0xffffffff*(children[index].shape.pos-p-(index+1));
      cursor := children[index].shape.pos;index := index+1;
    }
    assert index == |children|;
    assert children[..index] == children;
    assert T.Sum(children) <= 0xffffffff*(cursor-p-index);
    assert cursor-p-index <= limit;
    assert T.Sum(children) <= 0xffffffff*limit < G.Modulus();
    T.SumNonnegative(children[..|children|-1]);T.Extend(children,|children|-1);
    assert T.Sum(children) >= 1;
    assert T.Sum(children) <= 0xffffffff*(Base(p,children).pos-p);
  }
}
