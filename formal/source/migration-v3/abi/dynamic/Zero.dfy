// SPDX-License-Identifier: MIT
include "../connection/Refinement.dfy"

module AbiDynamicZero {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiWordSemantics
  import opened AbiShapeSemantics
  import opened AbiShapeRefinement
  import opened AbiParserSpec
  import opened AbiParserCompleteness
  import opened AbiSuffixSemantics
  import opened AbiSuffixSource
  import opened AbiTupleSemantics
  import opened AbiTupleNames
  import AbiTupleSource

  // Exact arithmetic condition for the source's zero-copy traversal. Fixed
  // suffixes change the returned width, but no repeated copy is visited.
  predicate ZeroFits(s: Descriptor, p: nat)
    decreases s, 1
  {
    match s
    case Name(_) => true
    case Fixed(e,_) => ZeroFits(e,p)
    case Dynamic(_) => false
    case Group(fs) => ZeroFields(fs,p)
  }

  predicate ZeroFields(fs: seq<Descriptor>, p: nat)
    decreases fs, 0
  {
    forall i :: 0 <= i < |fs| ==>
                  Uint(p+32*WidthSum(fs[..i])) && ZeroFits(fs[i],p+32*WidthSum(fs[..i]))
  }

  lemma ZeroStem(s: Descriptor, p: nat)
    requires Good(s) && !Dyn(s)
    ensures ZeroFits(s,p) == ZeroFits(Stem(s),p)
    decreases s
  { if s.Fixed? { ZeroStem(s.element,p); } }

  // Same source program as checkWords specialized to count=0. Its complete
  // source AST and all called arithmetic expressions are gated by the tuple
  // generator; overflow at a first-pass cursor is retained instead of assumed
  // away. No value data is read on either result.
  ghost method ZeroWords(t: seq<Byte>, ts: nat, limit: nat, v: seq<Byte>, p: nat, syntax: Descriptor)
    returns (end: nat, words: nat, r: Outcome)
    requires Uint(|t|) && Uint(|v|) && Uint(p)
    requires Good(syntax) && !Dyn(syntax) && Located(t,ts,limit,syntax)
    ensures r == (if ZeroFits(syntax,p) then Ok(0) else Panic(17))
    ensures r.Ok? ==> end == ts+|Render(syntax)| && words == Width(syntax)
    decreases syntax, 1
  {
    StaticDecompose(syntax); LocateStem(t,ts,limit,syntax); ZeroStem(syntax,p);
    var base := Stem(syntax);
    var ss := SuffixesOf(syntax);
    end,words,r := 0,0,Ok(0);
    if t[ts] == 40 {
      assert base.Group?;
      end,words,r := ZeroTuple(t,ts,limit,v,p,base.fields);
      if !r.Ok? { return; }
      end := end+1;
      var copies: nat;
      end,copies := Suffixes(t,end,limit,ss);
      var i := AbiTupleSource.CopyStart();
      assert copies*0 == 0 && !(i < copies*0);
      words := AbiTupleSource.FinalWords(words,copies);
      assert Uint(words);
    } else {
      assert base.Name?;
      var nameEnd := ts+|base.text|;
      NameKnown(t,ts,nameEnd,limit);
      end := NameEnd(t,ts,limit);
      var rule := Rule(t[ts..end]);
      words := 1;
      if end < limit { end,words := Suffixes(t,end,limit,ss); }
      else {
        assert |Text(ss)| == 0;
        if |ss| > 0 { assert |Text(ss)| >= 2; }
        assert ss == [];
      }
      assert words*0 == 0;
      if !rule.Opaque? { r := AbiTupleSource.ZeroRule(v,p); }
    }
  }

  ghost method ZeroTuple(t: seq<Byte>, ts: nat, limit: nat, v: seq<Byte>, p: nat, fs: seq<Descriptor>)
    returns (end: nat, words: nat, r: Outcome)
    requires Uint(|t|) && Uint(|v|) && Uint(p)
    requires Good(Group(fs)) && !Dyn(Group(fs))
    requires ts+|Render(Group(fs))| <= limit <= |t| && t[ts..ts+|Render(Group(fs))|] == Render(Group(fs))
    ensures r == (if ZeroFields(fs,p) then Ok(0) else Panic(17))
    ensures r.Ok? ==> end == ts+|Render(Group(fs))|-1 && words == Width(Group(fs))
    decreases Group(fs), 0
  {
    end,words,r := ts,0,Ok(0);
    var index: nat := 0;
    while true
      invariant index < |fs| && end+1 == FieldStart(ts,fs,index)
      invariant words == WidthSum(fs[..index])
      invariant forall k :: 0 <= k < index ==> Uint(p+32*WidthSum(fs[..k])) && ZeroFits(fs[k],p+32*WidthSum(fs[..k]))
      decreases |fs|-index
    {
      LocateField(t,ts,limit,fs,index);
      var first := AbiTupleSource.FirstCount(0);
      assert first == 0;
      var position := AbiTupleSource.FirstCursor(p,words);
      if !Uint(position) { r := Panic(17); return; }
      assert Uint(words*32);
      var next: nat; var w: nat;
      next,w,r := ZeroWords(t,end+1,limit,v,position,fs[index]);
      if !r.Ok? { return; }
      assert ZeroFits(fs[index],position);
      AppendFields(fs[..index],fs[index]);
      assert fs[..index+1] == fs[..index]+[fs[index]];
      words := words+w;
      assert Uint(words) by {
        WidthConcat(fs[..index+1],fs[index+1..]);
        assert fs == fs[..index+1]+fs[index+1..];
      }
      end := next;
      index := index+1;
      if t[end] != 44 { break; }
    }
    assert index == |fs| && fs[..index] == fs;
  }
}
