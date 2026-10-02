// SPDX-License-Identifier: MIT
// Mathematical descriptor admission; tuple sums derive from disjoint input spans.
include "Semantics.dfy"
module BytecodeCollectionsTypeBounds {
  import G = BytecodeGetterMachine
  import D = BytecodeCollectionsDecimalLoop
  import N = BytecodeCollectionsNamedParser
  import S = BytecodeCollectionsSuffixSemantics
  import T = BytecodeCollectionsTypeSemantics
  function Max(): nat { 0xffffffff }
  predicate MathematicalFits(shape: S.Shape,limit: G.Word) {
    shape.pos <= limit && shape.dynamic <= 1 && shape.span >= 1 &&
    (shape.dynamic == 0 || shape.span == 1)
  }
  predicate SuffixSyntax(data: seq<G.Byte>,offset: G.Word,limit: G.Word,shape: S.Shape,closings: seq<nat>)
    decreases |closings|
  {
    MathematicalFits(shape,limit) &&
    if |closings| == 0 then shape.pos >= limit || D.DataByte(data,offset,shape.pos) != 91
    else
      var close := closings[0];
      shape.pos+1 <= close < limit &&
      D.DataByte(data,offset,shape.pos) == 91 && D.DataByte(data,offset,close) == 93 &&
      (forall i {:trigger D.DataByte(data,offset,i)} :: shape.pos+1 <= i < close ==> D.Digit(D.DataByte(data,offset,i))) &&
      0 <= D.Number(data,offset,shape.pos+1,close) <= Max() &&
      (close > shape.pos+1 ==> D.Number(data,offset,shape.pos+1,close) >= 1) &&
      (shape.dynamic == 0 && close > shape.pos+1 ==> shape.span*D.Number(data,offset,shape.pos+1,close) <= Max()) &&
      SuffixSyntax(data,offset,limit,S.Next(data,offset,shape,close),closings[1..])
  }
  function SuffixResult(data: seq<G.Byte>,offset: G.Word,limit: G.Word,shape: S.Shape,closings: seq<nat>): S.Shape
    requires SuffixSyntax(data,offset,limit,shape,closings)
    ensures MathematicalFits(SuffixResult(data,offset,limit,shape,closings),limit)
    decreases |closings|
  {
    if |closings| == 0 then shape
    else SuffixResult(data,offset,limit,S.Next(data,offset,shape,closings[0]),closings[1..])
  }
  predicate Syntax(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,tree: T.Descriptor)
    decreases tree
  {
    p < limit && MathematicalFits(tree.shape,limit) &&
    (if tree.Named? then N.Name(data,offset,p,limit,tree.nameEnd)
     else |tree.children| > 0 && D.DataByte(data,offset,p) == 40 &&
          (forall i :: 0 <= i < |tree.children| ==>
                         T.Start(p,tree.children,i) < limit &&
                         Syntax(data,offset,T.Start(p,tree.children,i),limit,tree.children[i]) &&
                         tree.children[i].shape.pos < limit &&
                         D.DataByte(data,offset,tree.children[i].shape.pos) == (if i+1 < |tree.children| then 44 else 41))) &&
    SuffixSyntax(data,offset,limit,T.Base(data,offset,p,tree),tree.suffixes) &&
    tree.shape == SuffixResult(data,offset,limit,T.Base(data,offset,p,tree),tree.suffixes)
  }
  lemma SuffixAdmission(data: seq<G.Byte>,offset: G.Word,limit: G.Word,shape: S.Shape,closings: seq<nat>)
    requires SuffixSyntax(data,offset,limit,shape,closings) && shape.span < G.Modulus()
    ensures S.Valid(data,offset,limit,shape,closings)
    ensures S.Final(data,offset,limit,shape,closings) == SuffixResult(data,offset,limit,shape,closings)
    ensures SuffixResult(data,offset,limit,shape,closings).pos >= shape.pos
    ensures |closings| > 0 ==> SuffixResult(data,offset,limit,shape,closings).span <= Max()
    decreases |closings|
  {
    if |closings| > 0 {
      var close := closings[0];var next := S.Next(data,offset,shape,close);
      assert next.span <= Max();
      assert next.span < G.Modulus();
      SuffixAdmission(data,offset,limit,next,closings[1..]);
      assert next.pos > shape.pos;
    }
  }
  lemma {:autoRevealDependencies false} Admission(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,tree: T.Descriptor)
    requires Syntax(data,offset,p,limit,tree) && limit < 0x10000000000000000
    ensures T.Valid(data,offset,p,limit,tree)
    ensures tree.shape.pos > p
    ensures tree.shape.span <= Max()*(tree.shape.pos-p)
    decreases tree
  {
    reveal Syntax();reveal MathematicalFits();reveal T.Base();reveal T.Start();
    reveal Max();reveal G.Modulus();
    assert p < limit;
    assert SuffixSyntax(data,offset,limit,T.Base(data,offset,p,tree),tree.suffixes);
    assert tree.shape == SuffixResult(data,offset,limit,T.Base(data,offset,p,tree),tree.suffixes);
    var base := T.Base(data,offset,p,tree);
    if tree.Tuple? {
      var children := tree.children;var index: nat := 0;var cursor: nat := p;
      assert |children| > 0;
      assert forall j :: 0 <= j < |children| ==>
                           T.Start(p,children,j) < limit &&
                           Syntax(data,offset,T.Start(p,children,j),limit,children[j]) &&
                           children[j].shape.pos < limit;
      assert forall j :: 0 <= j < |children| ==> children[j].shape.span >= 1;
      hide Syntax();hide T.Valid();
      while index < |children|
        invariant 0 <= index <= |children| && |children| > 0
        invariant cursor == (if index == 0 then p else children[index-1].shape.pos)
        invariant p <= cursor <= limit
        invariant index < |children| ==> T.Start(p,children,index) == cursor+1
        invariant 0 <= T.Sum(children[..index]) <= Max()*(cursor-p-index)
        invariant forall j :: 0 <= j < index ==> T.Valid(data,offset,T.Start(p,children,j),limit,children[j])
        invariant forall j :: 0 <= j < |children| ==> children[j].shape.span >= 1
        decreases |children|-index
      {
        var start: G.Word := T.Start(p,children,index);
        Admission(data,offset,start,limit,children[index]);
        T.Extend(children,index);
        assert start == cursor+1;
        assert children[index].shape.span <= Max()*(children[index].shape.pos-start);
        assert T.Sum(children[..index+1]) == T.Sum(children[..index])+children[index].shape.span;
        assert children[index].shape.pos > cursor;
        assert T.Sum(children[..index+1]) <= Max()*(children[index].shape.pos-p-(index+1));
        cursor := children[index].shape.pos;index := index+1;
      }
      assert index == |children|;
      assert children[..index] == children;
      assert T.Sum(children) <= Max()*(cursor-p-index);
      assert cursor-p-index <= limit;
      assert T.Sum(children) <= Max()*limit;
      assert Max()*limit < G.Modulus();
      T.SumNonnegative(children[..|children|-1]);T.Extend(children,|children|-1);
      assert T.Sum(children) >= 1;
      assert base.pos > p;
      assert base.span <= Max()*(base.pos-p);
      assert base.span < G.Modulus();
    } else {
      assert base.pos > p && base.span == 1;
      assert base.span <= Max()*(base.pos-p);
    }
    SuffixAdmission(data,offset,limit,base,tree.suffixes);
    if |tree.suffixes| == 0 { assert tree.shape == base; }
    else { assert tree.shape.span <= Max(); }
    assert tree.shape.pos >= base.pos > p;
    reveal T.Valid();
  }
  lemma OriginalSuffixSyntax(data: seq<G.Byte>,offset: G.Word,limit: G.Word,shape: S.Shape,closings: seq<nat>)
    requires S.Valid(data,offset,limit,shape,closings)
    ensures SuffixSyntax(data,offset,limit,shape,closings)
    ensures S.Final(data,offset,limit,shape,closings) == SuffixResult(data,offset,limit,shape,closings)
    decreases |closings|
  {
    if |closings| > 0 {
      OriginalSuffixSyntax(data,offset,limit,S.Next(data,offset,shape,closings[0]),closings[1..]);
    }
  }
  lemma OriginalAdmission(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,tree: T.Descriptor)
    requires T.Valid(data,offset,p,limit,tree)
    ensures Syntax(data,offset,p,limit,tree)
    decreases tree
  {
    if tree.Tuple? {
      forall index | 0 <= index < |tree.children|
        ensures Syntax(data,offset,T.Start(p,tree.children,index),limit,tree.children[index])
      {
        OriginalAdmission(data,offset,T.Start(p,tree.children,index),limit,tree.children[index]);
      }
    }
    OriginalSuffixSyntax(data,offset,limit,T.Base(data,offset,p,tree),tree.suffixes);
  }
}
