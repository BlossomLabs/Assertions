// SPDX-License-Identifier: MIT
// Independent finite named/tuple descriptor trees and exact suffix semantics.
include "../named-parser/Parser.dfy"
include "../../../foundations/v1/SequenceTotals.dfy"
module BytecodeCollectionsTypeSemantics {
  import G = BytecodeGetterMachine
  import D = BytecodeCollectionsDecimalLoop
  import N = BytecodeCollectionsNamedParser
  import S = BytecodeCollectionsSuffixSemantics
  import Q = SharedFoundationSequenceTotals
  datatype Descriptor = Named(nameEnd: G.Word,shape: S.Shape,suffixes: seq<nat>)
                      | Tuple(children: seq<Descriptor>,shape: S.Shape,suffixes: seq<nat>)
  function Sum(children: seq<Descriptor>): int
    decreases |children|
  { if |children| == 0 then 0 else Sum(children[..|children|-1])+children[|children|-1].shape.span }
  function Spans(children: seq<Descriptor>): seq<int>
  { seq(|children|, i requires 0 <= i < |children| => children[i].shape.span) }
  lemma SumProjection(children: seq<Descriptor>,count: nat)
    requires count <= |children|
    ensures Sum(children[..count]) == Q.Sum(Spans(children),count)
    decreases count
  {
    if count > 0 {
      SumProjection(children,count-1);
      assert children[..count][..count-1] == children[..count-1];
      assert children[..count][count-1] == children[count-1];
      assert Spans(children)[count-1] == children[count-1].shape.span;
    } else {
      assert children[..count] == [];
    }
  }
  function Flags(children: seq<Descriptor>): nat
    ensures Flags(children) <= 1
    decreases |children|
  { if |children| == 0 then 0 else if children[|children|-1].shape.dynamic == 1 then 1 else Flags(children[..|children|-1]) }
  function Start(p: G.Word,children: seq<Descriptor>,index: nat): nat
    requires index < |children|
  { if index == 0 then p+1 else children[index-1].shape.pos+1 }
  function Base(data: seq<G.Byte>,offset: G.Word,p: G.Word,tree: Descriptor): S.Shape {
    if tree.Named? then S.Shape(tree.nameEnd,N.Dynamic(data,offset,p,tree.nameEnd),1)
    else if |tree.children| == 0 then S.Shape(p,0,0)
    else S.Shape(tree.children[|tree.children|-1].shape.pos+1,Flags(tree.children),if Flags(tree.children) == 1 then 1 else Sum(tree.children))
  }
  predicate Valid(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,tree: Descriptor)
    decreases tree
  {
    p < limit && S.Fits(tree.shape,limit) &&
    (if tree.Named? then N.Name(data,offset,p,limit,tree.nameEnd)
     else |tree.children| > 0 && D.DataByte(data,offset,p) == 40 && Sum(tree.children) < G.Modulus() &&
          (forall i :: 0 <= i < |tree.children| ==>
                         Start(p,tree.children,i) < limit &&
                         Valid(data,offset,Start(p,tree.children,i),limit,tree.children[i]) &&
                         tree.children[i].shape.pos < limit &&
                         D.DataByte(data,offset,tree.children[i].shape.pos) == (if i+1 < |tree.children| then 44 else 41))) &&
    S.Valid(data,offset,limit,Base(data,offset,p,tree),tree.suffixes) &&
    tree.shape == S.Final(data,offset,limit,Base(data,offset,p,tree),tree.suffixes)
  }
  predicate StackFits(prefixWords: nat,tree: Descriptor)
    decreases tree
  {
    prefixWords <= 1004 &&
    (tree.Named? || forall i :: 0 <= i < |tree.children| ==> StackFits(prefixWords+13,tree.children[i]))
  }
  lemma SumNonnegative(children: seq<Descriptor>)
    requires forall i :: 0 <= i < |children| ==> children[i].shape.span >= 1
    ensures Sum(children) >= 0
  {
    var spans := Spans(children);
    assert forall i :: 0 <= i < |spans| ==> spans[i] >= 0;
    SumProjection(children,|children|);
    Q.Nonnegative(spans,|children|);
    assert children[..|children|] == children;
  }
  lemma SumPrefix(children: seq<Descriptor>,index: nat)
    requires index <= |children|
    requires forall i :: 0 <= i < |children| ==> children[i].shape.span >= 1
    ensures 0 <= Sum(children[..index]) <= Sum(children)
  {
    var spans := Spans(children);
    assert forall i :: 0 <= i < |spans| ==> spans[i] >= 0;
    SumProjection(children,index);SumProjection(children,|children|);
    Q.Nonnegative(spans,index);Q.Monotone(spans,index,|children|);
    assert children[..|children|] == children;
  }
  lemma Extend(children: seq<Descriptor>,index: nat)
    requires index < |children|
    ensures Sum(children[..index+1]) == Sum(children[..index])+children[index].shape.span
    ensures Flags(children[..index+1]) == (if children[index].shape.dynamic == 1 then 1 else Flags(children[..index]))
  {
    assert children[..index+1][..index] == children[..index];
    assert children[..index+1][index] == children[index];
  }
  lemma SuffixForward(data: seq<G.Byte>,offset: G.Word,limit: G.Word,shape: S.Shape,closings: seq<nat>)
    requires S.Valid(data,offset,limit,shape,closings)
    ensures S.Final(data,offset,limit,shape,closings).pos >= shape.pos
    decreases |closings|
  {
    if |closings| > 0 {
      var next := S.Next(data,offset,shape,closings[0]);
      SuffixForward(data,offset,limit,next,closings[1..]);
      assert next.pos > shape.pos;
    }
  }
  lemma {:autoRevealDependencies false} Forward(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,tree: Descriptor)
    requires Valid(data,offset,p,limit,tree)
    ensures tree.shape.pos > p
    decreases tree
  {
    reveal Valid();reveal Base();reveal Start();
    assert S.Valid(data,offset,limit,Base(data,offset,p,tree),tree.suffixes);
    assert tree.shape == S.Final(data,offset,limit,Base(data,offset,p,tree),tree.suffixes);
    if tree.Tuple? {
      var children := tree.children;var index: nat := 0;
      assert |children| > 0;
      assert forall j :: 0 <= j < |children| ==>
                           Start(p,children,j) < limit &&
                           Valid(data,offset,Start(p,children,j),limit,children[j]);
      hide Valid();
      while index < |children|
        invariant 0 <= index <= |children|
        invariant forall j :: 0 <= j < index ==> Start(p,children,j) > p && children[j].shape.pos > p
        decreases |children|-index
      {
        assert Start(p,children,index) > p;
        Forward(data,offset,Start(p,children,index),limit,children[index]);
        index := index+1;
      }
      assert children[|children|-1].shape.pos > p;
    } else {
      reveal N.Name();
      assert tree.nameEnd > p;
    }
    SuffixForward(data,offset,limit,Base(data,offset,p,tree),tree.suffixes);
    assert Base(data,offset,p,tree).pos > p;
  }
}
