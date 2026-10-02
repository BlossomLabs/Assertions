// SPDX-License-Identifier: MIT
// Source-derived connection helpers; Solidity SHA256: 485f0d49f35528cc4c9be7767c631be6903ff57b5cb95bcbb25d6cd04ce5fed6
include "Descriptor.dfy"

module AbiConnectionSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiBytesSource
  import opened AbiWordSemantics
  import opened AbiCursorSemantics
  import opened AbiCursorSource
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiParserCompleteness
  import AbiParserSource
  import opened AbiTupleWords
  import opened AbiTupleSemantics
  import AbiTupleSource
  import opened AbiConnectionModel
  import opened AbiConnectionStatic
  import opened AbiConnectionDescriptor

  ghost method LastCandidate(te: nat) returns (j: nat)
    requires te >= 2
    ensures j == te-2
  { j := (te - 2); }

  ghost method IsDigit(c: Byte) returns (yes: bool)
    ensures yes == DecimalByte(c)
  { yes := ((c >= 48) && (c <= 57)); }

  ghost method IsOpening(c: Byte) returns (yes: bool)
    ensures yes == (c == 91)
  { yes := (c == 91); }

  ghost method SuffixStart(t: seq<Byte>, ts: nat, te: nat) returns (r: SuffixResult)
    requires Uint(|t|) && ts+2 <= te <= |t|
    ensures r == SuffixSpec(t,ts,te)
  {
    var j := LastCandidate(te);
    while j > ts
      invariant ts <= j <= te-2
      invariant Back(t,ts,j) == Back(t,ts,te-2)
      decreases j-ts
    {
      var digit := IsDigit(t[j]);
      if !digit { break; }
      j := j-1;
    }
    var opening := IsOpening(t[j]);
    r := if opening then Found(j) else Malformed(j);
  }

  ghost method CountDigit(count: nat, c: Byte) returns (next: nat)
    requires DecimalByte(c)
    ensures next == count*10+c-48
  { next := (((count * 10) + c) - 48); }

  ghost method FixedCount(t: seq<Byte>, opening: nat, te: nat, ds: seq<Byte>) returns (count: nat)
    requires opening+1 <= te-1 < |t| && Uint(|t|)
    requires t[opening+1..te-1] == ds
    requires forall i :: 0 <= i < |ds| ==> DecimalByte(ds[i])
    requires Number(ds) < 0x100000000
    ensures count == Number(ds)
  {
    count := 0;
    var k := opening+1;
    while k < te-1
      invariant opening+1 <= k <= te-1
      invariant count == Number(ds[..k-opening-1])
      invariant count <= Number(ds)
      decreases te-1-k
    {
      var i := k-opening-1;
      assert t[k] == ds[i];
      DigitPrefix(ds,i+1); NumberStep(ds[..i],ds[i]);
      assert ds[..i+1] == ds[..i]+[ds[i]];
      var next := CountDigit(count,t[k]);
      assert next == Number(ds[..i+1]) && Uint(next);
      assert Uint(count*10) && Uint(count*10+t[k]);
      count := next;
      k := k+1;
    }
    assert k == te-1;
    assert |ds| == te-opening-2;
    assert ds[..k-opening-1] == ds;
  }

  lemma ExactWordLength(length: nat, words: nat)
    ensures (length % 32 == 0 && words == length / 32) == (length == 32*words)
  { assert length == (length/32)*32+length%32; }

  ghost method LengthGuard(length: nat, words: nat) returns (ok: bool)
    ensures ok == (length == 32*words)
  { ExactWordLength(length,words); ok := (((length % 32) == 0) && (words == (length / 32))); }

  ghost method ValidateStatic(t: seq<Byte>, v: seq<Byte>, words: nat, s: Descriptor) returns (r: Outcome)
    requires Uint(|t|) && Uint(|v|)
    requires Good(s) && !Dyn(s) && Render(s) == t && words == Width(s)
    ensures WellFormed(TypeOf(s))
    ensures !r.Panic?
    ensures r.Ok? == Validate(TypeOf(s),v).Parsed?
    ensures r.Ok? <==> exists value :: WellTyped(TypeOf(s),value) &&
                                       Fits(TypeOf(s),value) && Encode(TypeOf(s),value) == v
    ensures r.Ok? ==> r == Ok(0)
    ensures |v| != 32*words ==> r == Invalid(0)
  {
    ModelType(s);
    var fits := LengthGuard(|v|,words);
    if !fits {
      if Validate(TypeOf(s),v).Parsed? { StaticExtent(TypeOf(s),v); }
      AcceptedIffCanonical(TypeOf(s),v);
      r := Invalid(0); return;
    }
    assert Uint(32*Width(s));
    assert Located(t,0,|t|,s);
    var end: nat; var width: nat;
    end,width,r := AbiTupleSource.CheckWords(t,0,|t|,1,v,0,s);
    RepeatOne(Rules(s));
    StaticValidation(s,v);
  }

  // Same body array prelude: find the last constructor, obtain its count,
  // parse its element, then run the actual bounded-head kernel.
  ghost method ArrayHead(t: seq<Byte>, ts: nat, te: nat, v: seq<Byte>, p: nat, s: Descriptor)
    returns (j: nat, base: nat, count: nat, dynamic: bool, words: nat, r: Outcome)
    requires Uint(|t|) && Uint(|v|) && Uint(p)
    requires Admissible(s) && (s.Fixed? || s.Dynamic?)
    requires ts <= te <= |t| && t[ts..te] == Render(s)
    ensures r == ArrayPrelude(v,p,s)
    ensures !r.Panic?
    ensures r.Ok? ==> j == ts+|Render(s.element)| &&
                      base == p+(if s.Dynamic? then 32 else 0) && dynamic == Dyn(s.element) && words == Width(s.element)
    ensures r.Ok? ==> base <= |v| && count*words*32 <= |v|-base && r == Ok(count*words*32)
    ensures r.Ok? && s.Fixed? ==> count == Number(s.digits)
    ensures r.Ok? && s.Dynamic? ==> p+32 <= |v| && count == ReadNat(v[p..p+32])
    ensures r.Ok? && count > 0 ==> Uint(base+32*words)
  {
    j,base,count,dynamic,words := 0,p,0,false,0;
    if p > |v| { r := Invalid(p); return; }
    ArraySpan(t,ts,te,s);
    var found := SuffixStart(t,ts,te);
    assert found.Found?;
    j := found.at;
    if j+1 == te-1 {
      var read := ReadWord(v,p);
      if !read.Ok? { r := read; return; }
      count := read.used;
      base := base+32;
    } else {
      count := FixedCount(t,j,te,s.digits);
    }
    Accept(t,ts,j,s.element);
    var element := AbiParserSource.TypeShape(t,ts,j);
    assert element.Shaped? && element.syntax == s.element;
    dynamic,words := element.dynamic,element.words;
    r := AbiCursorSource.ArrayHead(v,base,count,words);
    if r.Ok? && count > 0 {
      CursorArithmetic(base,words,count);
      CopyBounds(base,words,count,0,|v|);
    }
  }

  ghost method TupleNext(next: nat) returns (j: nat)
    ensures j == next+1
  { j := (next + 1); }

  ghost method TupleHead(t: seq<Byte>, ts: nat, te: nat, v: seq<Byte>, p: nat, fs: seq<Descriptor>)
    returns (r: Outcome)
    requires Uint(|t|) && Uint(|v|) && p <= |v|
    requires Admissible(Group(fs))
    requires ts <= te <= |t| && t[ts..te] == Render(Group(fs))
    ensures r == (if 32*WidthSum(fs) > |v|-p then Invalid(p) else Ok(32*WidthSum(fs)))
  {
    var j := ts+1;
    var tail: nat := 0;
    var index: nat := 0;
    FieldRoom(t,ts,te,fs,0);
    while j < te-1
      invariant index <= |fs|
      invariant j == (if index < |fs| then FieldStart(ts,fs,index) else te)
      invariant index < |fs| ==> j < te-1
      invariant tail == 32*WidthSum(fs[..index]) && p+tail <= |v|
      invariant WidthSum(fs) == WidthSum(fs[..index])+WidthSum(fs[index..])
      decreases |fs|-index
    {
      assert index < |fs|;
      LocateField(t,ts,te,fs,index);
      Accept(t,j,te-1,fs[index]);
      var field := AbiParserSource.TypeShape(t,j,te-1);
      assert field.Shaped? && field.syntax == fs[index];
      var next,w := field.end,field.words;
      var checked := TupleHeadStep(v,p,tail,w);
      if !checked.Ok? { r := checked; return; }
      tail := checked.used;
      j := TupleNext(next);
      AppendFields(fs[..index],fs[index]);
      assert fs[..index+1] == fs[..index]+[fs[index]];
      index := index+1;
      if index < |fs| { FieldRoom(t,ts,te,fs,index); }
      assert fs == fs[..index]+fs[index..];
      WidthConcat(fs[..index],fs[index..]);
    }
    assert index == |fs|;
    r := Ok(tail);
  }
}
