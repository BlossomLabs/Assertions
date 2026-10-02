// SPDX-License-Identifier: MIT
// Generated from the checked typeShape AST skeleton. Do not edit.
// Source SHA256: 485f0d49f35528cc4c9be7767c631be6903ff57b5cb95bcbb25d6cd04ce5fed6
include "Semantics.dfy"

module AbiShapeSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiWordSemantics
  import opened AbiWordRefinement
  import opened AbiSuffixSemantics
  import opened AbiShapeSemantics

  ghost method {:isolate_assertions} TypeShape(t: seq<Byte>, p: nat, limit: nat) returns (r: ShapeResult)
    requires Uint(|t|) && Uint(p) && Uint(limit)
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
      while true
        invariant p < q <= limit
        invariant sum == WidthSum(fields) && Uint(sum)
        invariant dyn == Dyn(Group(fields))
        invariant forall i :: 0 <= i < |fields| ==> Good(fields[i])
        invariant t[p..q] == [40]+FieldsText(fields)+(if |fields| == 0 then [] else [44])
        decreases limit-q+1
      {
        var child := TypeShape(t,q,limit);
        if !child.Shaped? { r := child; return; }
        var e, d, w := child.end, child.dynamic, child.words;
        if d { dyn := true; }
        if (sum + w) >= Limit() { r := ArithmeticPanic; return; }
        sum := (sum + w);
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
    } else {
      var q := ScanNameMeaning(t,p,limit);
      if q == p { r := BadDescriptor(p); return; }
      var n := q-p;
      syntax := Name(t[p..q]);
      assert forall i :: 0 <= i < q-p ==> NameByte((t[p..q])[i]);
      if n == 5 || n == 6 {
        var name := ReadNat(t[p..q]);
        NameComparison(t[p..q]);
        dyn := name == (if n == 5 then 422944466291 else 126943972912743);
      }
      words := 1;
      end := q;
    }
    Positive(syntax);
    r := ShapeSuffixes(t,p,limit,end,dyn,words,syntax);
  }

  ghost method ReadDigits(t: seq<Byte>, start: nat, limit: nat) returns (q2: nat, k: nat)
    requires Uint(|t|) && start <= limit <= |t|
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
      decreases limit-q2
    {
      var c := t[q2];
      if c < 48 || c > 57 || k > 0xffffffff { break; }
      assert k*10 < Limit() && 0 <= c-48 && k*10+(c-48) < Limit();
      NumberStep(t[start..q2],c);
      assert t[start..q2+1] == t[start..q2]+[c];
      k := ((k * 10) + (c - 48));
      q2 := q2+1;
    }
  }

  ghost method {:isolate_assertions} ShapeSuffixes(t: seq<Byte>, p: nat, limit: nat,
                                                   start: nat, initialDynamic: bool, initialWords: nat, initialSyntax: Descriptor) returns (r: ShapeResult)
    requires Uint(|t|) && p < start <= limit <= |t|
    requires Good(initialSyntax) && Render(initialSyntax) == t[p..start]
    requires initialDynamic == Dyn(initialSyntax) && initialWords == Width(initialSyntax)
    requires 0 < initialWords < Limit()
    ensures r.Shaped? ==> p < r.end <= limit
    ensures r.Shaped? ==> Good(r.syntax) && Render(r.syntax) == t[p..r.end]
    ensures r.Shaped? ==> r.dynamic == Dyn(r.syntax) && r.words == Width(r.syntax)
    ensures r.Shaped? ==> 0 < r.words < Limit()
    ensures r.Shaped? ==> r.end == limit || t[r.end] != 91
  {
    var end, dyn, words, syntax := start, initialDynamic, initialWords, initialSyntax;
    while end < limit && t[end] == 91
      invariant p < end <= limit
      invariant Good(syntax) && Render(syntax) == t[p..end]
      invariant dyn == Dyn(syntax) && words == Width(syntax)
      invariant 0 < words < Limit()
      decreases limit-end
    {
      var opening := end;
      var q2, k := ReadDigits(t,end+1,limit);
      var previous := syntax;
      if q2 == end+1 {
        dyn := true;
        words := 1;
      } else if !dyn {
        if (words * k) >= Limit() { r := ArithmeticPanic; return; }
        words := (words * k);
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
      assert t[opening] == 91 && t[q2] == 93;
      assert t[p..q2+1] == t[p..opening]+t[opening..opening+1]+t[opening+1..q2]+t[q2..q2+1];
      end := q2+1;
      assert t[p..end] == t[p..opening]+[91]+t[opening+1..q2]+[93];
      Positive(syntax);
    }
    r := Shaped(end,dyn,words,syntax);
  }

  ghost method Shape(t: seq<Byte>) returns (r: ShapeResult)
    requires Uint(|t|)
    ensures r.Shaped? ==> r.end == |t| && Good(r.syntax) && Render(r.syntax) == t
    ensures r.Shaped? ==> r.dynamic == Dyn(r.syntax) && r.words == Width(r.syntax)
    ensures r.Shaped? ==> 0 < r.words < Limit()
  {
    r := TypeShape(t,0,|t|);
    if r.Shaped? && r.end != |t| { r := BadDescriptor(r.end); }
  }
}
