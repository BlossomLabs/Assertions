// SPDX-License-Identifier: MIT
// Generated from the checked typeShape AST skeleton. Do not edit.
// Source SHA256: $HASH
include "Spec.dfy"

module AbiParserSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiWordSemantics
  import opened AbiWordRefinement
  import opened AbiWordSource
  import opened AbiSuffixSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec

  ghost method {:isolate_assertions} TypeShape(t: seq<Byte>, p: nat, limit: nat) returns (r: ShapeResult)
    requires Uint(|t|) && Uint(p) && Uint(limit)
    ensures r == Parse(t,p,limit)
    ensures r.Shaped? ==> Admissible(r.syntax)
    ensures r.Shaped? ==> p < r.end <= limit <= |t|
    ensures r.Shaped? ==> Good(r.syntax) && Render(r.syntax) == t[p..r.end]
    ensures r.Shaped? ==> r.dynamic == Dyn(r.syntax) && r.words == Width(r.syntax)
    ensures r.Shaped? ==> 0 < r.words < Limit()
    ensures r.Shaped? ==> r.end == limit || t[r.end] != 91
    decreases if p < limit then limit-p else 0
  {
    if limit > |t| { r := BadDescriptor(limit); return; }
    if p >= limit { r := BadDescriptor(p); return; }
    var end: nat := 0;
    var dyn := false;
    var words: nat := 0;
    var syntax := Name([]);
    if t[p] == 40 {
      var q := p+1;
      var sum: nat := 0;
      var fields: seq<Descriptor> := [];
      var reference := Fields(t,p+1,limit,[],0,false);
      while true
        invariant p < q <= limit
        invariant sum == WidthSum(fields) && Uint(sum)
        invariant dyn == Dyn(Group(fields))
        invariant Fields(t,q,limit,fields,sum,dyn) == reference
        invariant forall i :: 0 <= i < |fields| ==> Admissible(fields[i])
        invariant forall i :: 0 <= i < |fields| ==> Good(fields[i])
        invariant t[p..q] == [40]+FieldsText(fields)+(if |fields| == 0 then [] else [44])
        decreases limit-q+1
      {
        var pending := Fields(t,q,limit,fields,sum,dyn);
        var child := TypeShape(t,q,limit);
        if !child.Shaped? { r := child; return; }
        var e, d, w := child.end, child.dynamic, child.words;
        if d { dyn := $TUPLE_DYNAMIC; }
        if $SUM >= Limit() { r := ArithmeticPanic; return; }
        sum := $SUM;
        AppendFields(fields,child.syntax);
        assert t[p..e] == t[p..q]+t[q..e];
        fields := fields+[child.syntax];
        assert t[p..e] == [40]+FieldsText(fields);
        if e >= limit { r := BadDescriptor(e); return; }
        var c := t[e];
        if c == 44 {
          q := e+1;
          assert t[p..q] == t[p..e]+[44];
          continue;
        }
        if c == 41 {
          end := e+1;
          assert t[p..end] == t[p..e]+[41];
          break;
        }
        r := BadDescriptor(e); return;
      }
      words := if dyn then 1 else sum;
      syntax := Group(fields);
      assert reference == Shaped(end,dyn,words,syntax);
    } else {
      var q := ScanName(t,p,limit);
      NamePrefix(t,p,limit);
      if q == p { r := BadDescriptor(p); return; }
      var n := q-p;
      syntax := Name(t[p..q]);
      assert forall i :: 0 <= i < q-p ==> NameByte((t[p..q])[i]);
      if n == 5 || n == 6 {
        var name := ReadNat(t[p..q]);
        NameComparison(t[p..q]);
        dyn := name == (if n == 5 then $BYTES else $STRING);
      }
      words := 1;
      end := q;
    }
    assert Parse(t,p,limit) == Suffix(t,end,limit,syntax,dyn,words);
    Positive(syntax);
    r := ShapeSuffixes(t,p,limit,end,dyn,words,syntax);
  }

  ghost method Digit(k: nat, c: Byte) returns (next: nat)
    requires k < 0x100000000 && 48 <= c <= 57
    ensures next == 10*k+c-48 && next < 10*0x100000000
  {
    next := $DIGIT;
    if k == 1 && c == 48 { assert next == 10; }
  }

  // Compute the source expression over naturals before the caller applies
  // Solidity's checked-overflow branch. This isolates the arithmetic identity.
  ghost method Product(words: nat, k: nat) returns (value: nat)
    ensures value == words*k
  {
    value := $PRODUCT;
    if words == 3 && k == 2 { assert value == 6; }
  }

  ghost method ReadDigits(t: seq<Byte>, start: nat, limit: nat) returns (q2: nat, k: nat)
    requires Uint(|t|) && start <= limit <= |t|
    ensures (q2,k) == DigitsFrom(t,start,limit,0)
    ensures start <= q2 <= limit
    ensures forall i :: start <= i < q2 ==> 48 <= t[i] <= 57
    ensures k == Number(t[start..q2]) && k < 10*0x100000000
    ensures q2 < limit ==> t[q2] < 48 || t[q2] > 57 || k > 0xffffffff
  {
    q2 := start;
    k := 0;
    while q2 < limit
      invariant start <= q2 <= limit
      invariant forall i :: start <= i < q2 ==> 48 <= t[i] <= 57
      invariant k == Number(t[start..q2]) && k < 10*0x100000000
      invariant DigitsFrom(t,q2,limit,k) == DigitsFrom(t,start,limit,0)
      decreases limit-q2
    {
      var c := t[q2];
      if c < 48 || c > 57 || k > 0xffffffff { break; }
      assert k*10 < Limit() && 0 <= c-48 && k*10+(c-48) < Limit();
      NumberStep(t[start..q2],c);
      assert t[start..q2+1] == t[start..q2]+[c];
      k := Digit(k,c);
      q2 := q2+1;
    }
  }

  ghost method {:isolate_assertions} ShapeSuffixes(t: seq<Byte>, p: nat, limit: nat,
                                                   start: nat, initialDynamic: bool, initialWords: nat, initialSyntax: Descriptor) returns (r: ShapeResult)
    requires Uint(|t|) && p < start <= limit <= |t|
    requires Admissible(initialSyntax)
    requires Good(initialSyntax) && Render(initialSyntax) == t[p..start]
    requires initialDynamic == Dyn(initialSyntax) && initialWords == Width(initialSyntax)
    requires 0 < initialWords < Limit()
    ensures r == Suffix(t,start,limit,initialSyntax,initialDynamic,initialWords)
    ensures r.Shaped? ==> Admissible(r.syntax)
    ensures r.Shaped? ==> p < r.end <= limit
    ensures r.Shaped? ==> Good(r.syntax) && Render(r.syntax) == t[p..r.end]
    ensures r.Shaped? ==> r.dynamic == Dyn(r.syntax) && r.words == Width(r.syntax)
    ensures r.Shaped? ==> 0 < r.words < Limit()
    ensures r.Shaped? ==> r.end == limit || t[r.end] != 91
  {
    var end, dyn, words, syntax := start, initialDynamic, initialWords, initialSyntax;
    while end < limit && t[end] == 91
      invariant p < end <= limit
      invariant Admissible(syntax)
      invariant Good(syntax) && Render(syntax) == t[p..end]
      invariant dyn == Dyn(syntax) && words == Width(syntax)
      invariant 0 < words < Limit()
      invariant Suffix(t,end,limit,syntax,dyn,words) == Suffix(t,start,limit,initialSyntax,initialDynamic,initialWords)
      decreases limit-end
    {
      var pending := Suffix(t,end,limit,syntax,dyn,words);
      var opening := end;
      var q2, k := ReadDigits(t,end+1,limit);
      var previous := syntax;
      if q2 == end+1 {
        dyn := $ARRAY_DYNAMIC;
        words := 1;
      } else if !dyn {
        var product := Product(words,k);
        if product >= Limit() { r := ArithmeticPanic; return; }
        words := product;
      }
      // (k | words) > uint32.max iff either operand exceeds it: separate
      // bitvector gate, not an unproved arithmetic replacement.
      if q2 >= limit || t[q2] != 93 || k > 0xffffffff || words > 0xffffffff || (k == 0 && q2 != end+1) {
        r := BadDescriptor(q2); return;
      }
      if q2 == end+1 { syntax := Dynamic(previous); }
      else {
        assert Digits(t[end+1..q2]);
        syntax := Fixed(previous,t[end+1..q2]);
      }
      // State the shape transition locally before downstream grammar checks.
      // These remain proved assertions, including in mutation runs.
      assert dyn == Dyn(syntax) && words == Width(syntax);
      end := q2+1;
      assert t[p..end] == t[p..opening]+[91]+t[opening+1..q2]+[93];
      Positive(syntax);
    }
    r := Shaped(end,dyn,words,syntax);
  }

  ghost method Shape(t: seq<Byte>) returns (r: ShapeResult)
    requires Uint(|t|)
    ensures r == Whole(t)
    ensures r.Shaped? ==> Admissible(r.syntax)
    ensures r.Shaped? ==> r.end == |t| && Good(r.syntax) && Render(r.syntax) == t
    ensures r.Shaped? ==> r.dynamic == Dyn(r.syntax) && r.words == Width(r.syntax)
    ensures r.Shaped? ==> 0 < r.words < Limit()
  {
    r := TypeShape(t,0,|t|);
    if r.Shaped? && r.end != |t| { r := BadDescriptor(r.end); }
  }
}
