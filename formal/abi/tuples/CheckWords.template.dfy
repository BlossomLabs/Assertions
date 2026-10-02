// SPDX-License-Identifier: MIT
// Generated from the complete checkWords AST skeleton; source SHA256: $HASH
include "Semantics.dfy"

module AbiTupleSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiWordSemantics
  import opened AbiWordRefinement
  import opened AbiWordSource
  import opened AbiSuffixSemantics
  import opened AbiSuffixSource
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiParserCompleteness
  import opened AbiTupleWords
  import opened AbiTupleNames
  import opened AbiTupleSemantics

  // Source expressions are isolated arithmetic obligations. Call-site span
  // proofs still establish representability before recursive execution.
  ghost method FirstCount(count: nat) returns (first: nat)
    ensures first == (if count == 0 then 0 else 1)
  { first := $FIRST_COUNT; }

  ghost method CopyStart() returns (i: nat)
    ensures i == 1
  { i := $COPY_START; }

  ghost method CopyCursor(p: nat, words: nat, i: nat) returns (position: nat)
    ensures position == p+32*words*i
  { CursorArithmetic(p,words,i); position := $COPY_CURSOR; }

  ghost method FirstCursor(p: nat, words: nat) returns (position: nat)
    ensures position == p+32*words
  { position := $FIRST_CURSOR; }

  ghost method FinalWords(words: nat, copies: nat) returns (result: nat)
    ensures result == words*copies
  { result := $FINAL_WORDS; }

  // Specialization of the source-checked checkRule loop at n=0. Its MLOAD
  // body is unreachable, including when p is outside v's allocation.
  ghost method ZeroRule(v: seq<Byte>, p: nat) returns (r: Outcome)
    requires Uint(p)
    ensures r == Ok(0)
  {
    var n: nat := 0;
    var bad := n;
    var i: nat := 0;
    while i < n
      invariant n == 0 && bad == 0 && i == 0
    { assert false; }
    assert Uint(p+bad*32);
    if bad != n { r := Invalid(p+bad*32); return; }
    r := Ok(0);
  }

  ghost method RuleRun(rule: WordRule, v: seq<Byte>, p: nat, n: nat) returns (r: Outcome)
    requires ClassifiedRule(rule) && Uint(p) && Uint(|v|)
    requires n == 0 || p+32*n <= |v|
    ensures RulesValid(Repeat([rule],n))
    ensures r == Scan(Repeat([rule],n),v,p)
  {
    RepeatValid([rule],n);
    if n == 0 { r := ZeroRule(v,p); }
    else {
      r := CheckRun(rule,v,p,n);
      UniformFirstBad(rule,v,p,n,0);
    }
  }

  ghost method {:isolate_assertions} CheckWords(t: seq<Byte>, ts: nat, limit: nat,
                                                count: nat, v: seq<Byte>, p: nat, syntax: Descriptor)
    returns (end: nat, words: nat, r: Outcome)
    requires Uint(|t|) && Uint(|v|) && Uint(count)
    requires Good(syntax) && !Dyn(syntax) && Located(t,ts,limit,syntax)
    requires Uint(p+32*Width(syntax))
    requires count == 0 || p+32*Width(syntax)*count <= |v|
    ensures |Rules(syntax)| == Width(syntax)
    ensures count == 0 || p+32*|Repeat(Rules(syntax),count)| <= |v|
    ensures RulesValid(Repeat(Rules(syntax),count))
    ensures r == Scan(Repeat(Rules(syntax),count),v,p)
    ensures r.Ok? ==> end == ts+|Render(syntax)| && words == Width(syntax)
    decreases syntax, count, 1
  {
    StaticDecompose(syntax); LocateStem(t,ts,limit,syntax); Span(syntax,v,p,count);
    var base := Stem(syntax);
    var ss := SuffixesOf(syntax);
    var copiesExpected := Product(ss);
    var total := copiesExpected*count;
    StaticRules(base); RepeatOne(Rules(base));
    assert RulesValid(Repeat(Rules(base),total));
    RepeatMultiply(Rules(base),copiesExpected,count);
    assert Repeat(Rules(syntax),count) == Repeat(Rules(base),total);
    assert Width(syntax) == Width(base)*copiesExpected;
    ExpandCopies(p,Width(base),copiesExpected,count,|v|);
    assert p+32*Width(base) <= p+32*Width(syntax);
    end, words, r := 0,0,Ok(0);
    if t[ts] == 40 {
      assert base.Group?;
      end, words, r := TupleOnce(t,ts,limit,count,v,p,base.fields);
      if !r.Ok? {
        assert count > 0 && total > 0;
        CopyBounds(p,Width(base),total,0,|v|);
        Advance(Rules(base),total,0,v,p);
        return;
      }
      var close := end+1;
      end := close;
      var copies: nat;
      end, copies := Suffixes(t,end,limit,ss);
      assert close == ts+|Render(base)|;
      assert Located(t,ts,close,base);
      assert copies == copiesExpected;
      assert base == syntax ==> copies == 1;
      if count > 0 {
        CopyBounds(p,Width(base),total,0,|v|);
        Advance(Rules(base),total,0,v,p);
      }
      var i: nat := CopyStart();
      while i < copies*count
        invariant 1 <= i && (i <= total || total == 0)
        invariant end == ts+|Render(syntax)| && words == Width(base)
        invariant copies == copiesExpected && close == ts+|Render(base)|
        invariant count == 0 || p+32*Width(base)*i <= |v|
        invariant count == 0 || p+32*|Repeat(Rules(base),i)| <= |v|
        invariant count == 0 || Scan(Repeat(Rules(base),i),v,p) == Ok(0)
        decreases if i < total then total-i else 0
      {
        assert count > 0;
        CopyBounds(p,Width(base),total,i,|v|);
        CursorArithmetic(p,words,i);
        var position: nat := CopyCursor(p,words,i);
        assert position == p+32*words*i;
        assert base < syntax || (base == syntax && 1 < count);
        var e: nat; var w: nat; var checked: Outcome;
        e,w,checked := CheckWords(t,ts,close,1,v,position,base);
        Advance(Rules(base),total,i,v,p);
        if !checked.Ok? { r := checked; return; }
        i := i+1;
        CursorArithmetic(p,words,i);
      }
      words := FinalWords(words,copies);
    } else {
      assert base.Name?;
      var nameEnd := ts+|base.text|;
      assert forall j :: ts <= j < nameEnd ==> NameByte(t[j]);
      if |ss| > 0 {
        assert Text(ss) == [91]+ss[0]+[93]+Text(ss[1..]);
        assert t[nameEnd] == 91;
      }
      NameKnown(t,ts,nameEnd,limit);
      // Source wordRule normalization: the retained exhaustive SMT gate maps
      // the maximal name and its surrounding calldata to this exact whitelist.
      end := NameEnd(t,ts,limit);
      var rule := Rule(t[ts..end]);
      RuleClassified(t[ts..end]);
      words := 1;
      if end < limit { end,words := Suffixes(t,end,limit,ss); }
      else {
        assert |Text(ss)| == 0;
        if |ss| > 0 { assert |Text(ss)| >= 2; }
        assert ss == [];
      }
      RepeatMultiply([rule],words,count);
      if !rule.Opaque? { r := RuleRun(rule,v,p,words*count); }
      else {
        if count > 0 { OpaqueWords(v,p,words*count); UniformFirstBad(rule,v,p,words*count,0); }
        r := Ok(0);
      }
    }
  }

  ghost method {:isolate_assertions} TupleOnce(t: seq<Byte>, ts: nat, limit: nat,
                                               count: nat, v: seq<Byte>, p: nat, fs: seq<Descriptor>)
    returns (end: nat, words: nat, r: Outcome)
    requires Uint(|t|) && Uint(|v|) && Uint(count)
    requires Good(Group(fs)) && !Dyn(Group(fs))
    requires ts+|Render(Group(fs))| <= limit <= |t| && t[ts..ts+|Render(Group(fs))|] == Render(Group(fs))
    requires Uint(p+32*Width(Group(fs)))
    requires count == 0 || p+32*Width(Group(fs)) <= |v|
    ensures |FieldRules(fs)| == Width(Group(fs))
    ensures RulesValid(Repeat(FieldRules(fs),if count == 0 then 0 else 1))
    ensures r == Scan(Repeat(FieldRules(fs),if count == 0 then 0 else 1),v,p)
    ensures r.Ok? ==> end == ts+|Render(Group(fs))|-1 && words == Width(Group(fs))
    decreases Group(fs), count, 0
  {
    StaticRules(Group(fs)); StaticFields(fs); RepeatOne(FieldRules(fs));
    RepeatValid(FieldRules(fs),if count == 0 then 0 else 1);
    end, words, r := ts,0,Ok(0);
    var index: nat := 0;
    while true
      invariant index < |fs| && end+1 == FieldStart(ts,fs,index)
      invariant words == WidthSum(fs[..index])
      invariant RulesValid(FieldRules(fs[..index]))
      invariant |FieldRules(fs[..index])| == words
      invariant count == 0 || p+32*words <= |v|
      invariant count == 0 || Scan(FieldRules(fs[..index]),v,p) == Ok(0)
      decreases |fs|-index
    {
      LocateField(t,ts,limit,fs,index);
      StaticFields(fs[..index]); StaticFields(fs[index+1..]); StaticRules(fs[index]);
      WidthConcat(fs[..index],fs[index..]);
      WidthConcat(fs[..index+1],fs[index+1..]);
      AppendFields(fs[..index],fs[index]);
      assert fs[..index+1] == fs[..index]+[fs[index]];
      FieldAppend(fs[..index],[fs[index]]);
      FieldAppend(fs[..index+1],fs[index+1..]);
      assert fs == fs[..index+1]+fs[index+1..];
      var first: nat := FirstCount(count);
      var position: nat := FirstCursor(p,words);
      var next: nat; var w: nat;
      next,w,r := CheckWords(t,end+1,limit,first,v,position,fs[index]);
      if count == 0 { assert first == 0 && r == Ok(0); }
      if count > 0 {
        assert first == 1;
        assert Repeat(Rules(fs[index]),1) == Rules(fs[index]);
        assert r == Scan(Rules(fs[index]),v,p+32*words);
        assert FieldRules(fs) == FieldRules(fs[..index])+Rules(fs[index])+FieldRules(fs[index+1..]);
        ScanSegment(FieldRules(fs[..index]),Rules(fs[index]),FieldRules(fs[index+1..]),v,p);
      }
      if !r.Ok? {
        assert count > 0;
        assert r == Scan(FieldRules(fs),v,p);
        return;
      }
      assert r == Ok(0);
      words := words+w;
      end := next;
      index := index+1;
      StaticFields(fs[..index]);
      assert count == 0 || Scan(FieldRules(fs[..index]),v,p) == Ok(0);
      if t[end] != 44 { break; }
    }
    assert index == |fs|;
    assert fs[..index] == fs;
    assert r == Ok(0);
    if count == 0 { assert Repeat(FieldRules(fs),0) == []; }
    else { assert Scan(FieldRules(fs),v,p) == Ok(0); }
  }
}
