// SPDX-License-Identifier: MIT
include "../dynamic/Validation.generated.dfy"

module AbiLayoutScan {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiWordSemantics
  import opened AbiShapeSemantics

  datatype ScanResult = Counted(depth: nat, count: nat) | Stray(at: nat)

  // Reference semantics of the layout pre-scan. The closing parenthesis of
  // the enclosing tuple is outside this span. A zero-depth ')' is reported
  // before any component parsing, matching the documented error precedence.
  function Scan(bs: seq<Byte>, start: nat, end: nat, depth: nat, count: nat): ScanResult
    requires start <= end <= |bs|
    decreases end-start
  {
    if start == end then Counted(depth,count) else
    if bs[start] == 41 && depth == 0 then Stray(start) else
    var d := if bs[start] == 40 then depth+1 else if bs[start] == 41 then depth-1 else depth;
    var c := count+(if bs[start] == 44 && depth == 0 then 1 else 0);
    Scan(bs,start+1,end,d,c)
  }

  lemma Step(bs: seq<Byte>, start: nat, end: nat, depth: nat, count: nat)
    requires start < end <= |bs|
    ensures Scan(bs,start,end,depth,count) ==
            (if bs[start] == 41 && depth == 0 then Stray(start) else
             Scan(bs,start+1,end,
                  if bs[start] == 40 then depth+1 else if bs[start] == 41 then depth-1 else depth,
                  count+(if bs[start] == 44 && depth == 0 then 1 else 0)))
  {}

  lemma Empty(bs: seq<Byte>, end: nat, depth: nat, count: nat)
    requires end <= |bs|
    ensures Scan(bs,end,end,depth,count) == Counted(depth,count)
  {}

  lemma ScanConcat(a: seq<Byte>, b: seq<Byte>, depth: nat, count: nat)
    ensures var first := Scan(a,0,|a|,depth,count);
            first.Counted? ==> Scan(a+b,0,|a+b|,depth,count) ==
                               Shift(Scan(b,0,|b|,first.depth,first.count),|a|)
    ensures var first := Scan(a,0,|a|,depth,count);
            first.Stray? ==> Scan(a+b,0,|a+b|,depth,count) == first
    decreases |a|
  {
    if |a| == 0 { assert a == [] && a+b == b; }
    else if a[0] != 41 || depth > 0 {
      var d := if a[0] == 40 then depth+1 else if a[0] == 41 then depth-1 else depth;
      var c := count+(if a[0] == 44 && depth == 0 then 1 else 0);
      ScanConcat(a[1..],b,d,c);
      ScanSlice(a,1,|a|,d,c);
      ScanSlice(a+b,1,|a+b|,d,c);
      assert (a+b)[1..|a+b|] == a[1..]+b;
      assert a[1..|a|] == a[1..];
      Step(a,0,|a|,depth,count); Step(a+b,0,|a+b|,depth,count);
      var first := Scan(a[1..],0,|a|-1,d,c);
      if first.Counted? { ShiftAdd(Scan(b,0,|b|,first.depth,first.count),|a|-1,1); }
    }
  }

  function Shift(r: ScanResult, offset: nat): ScanResult
  { if r.Stray? then Stray(offset+r.at) else r }

  lemma ShiftAdd(r: ScanResult, a: nat, b: nat)
    ensures Shift(Shift(r,a),b) == Shift(r,a+b)
  {}

  lemma ScanSlice(bs: seq<Byte>, start: nat, end: nat, depth: nat, count: nat)
    requires start <= end <= |bs|
    ensures Scan(bs,start,end,depth,count) == Shift(Scan(bs[start..end],0,end-start,depth,count),start)
    decreases end-start
  {
    if start < end && (bs[start] != 41 || depth > 0) {
      var d := if bs[start] == 40 then depth+1 else if bs[start] == 41 then depth-1 else depth;
      var c := count+(if bs[start] == 44 && depth == 0 then 1 else 0);
      Step(bs,start,end,depth,count); Step(bs[start..end],0,end-start,depth,count);
      ScanSlice(bs,start+1,end,d,c);
      ScanSlice(bs[start..end],1,end-start,d,c);
      assert bs[start..end][1..end-start] == bs[start+1..end];
      var child := Scan(bs[start+1..end],0,end-start-1,d,c);
      assert Scan(bs,start+1,end,d,c) == Shift(child,start+1);
      assert Scan(bs[start..end],1,end-start,d,c) == Shift(child,1);
      ShiftAdd(Scan(bs[start+1..end],0,end-start-1,d,c),1,start);
    }
  }

  lemma Plain(bs: seq<Byte>, depth: nat, count: nat)
    requires forall i :: 0 <= i < |bs| ==> bs[i] != 40 && bs[i] != 41 && bs[i] != 44
    ensures Scan(bs,0,|bs|,depth,count) == Counted(depth,count)
    decreases |bs|
  {
    if |bs| > 0 {
      Step(bs,0,|bs|,depth,count);
      assert bs[0] != 40 && bs[0] != 41 && bs[0] != 44;
      Plain(bs[1..],depth,count);
      ScanSlice(bs,1,|bs|,depth,count);
      assert bs[1..|bs|] == bs[1..];
      assert Scan(bs[1..|bs|],0,|bs|-1,depth,count) == Counted(depth,count);
      assert Scan(bs,1,|bs|,depth,count) == Shift(Counted(depth,count),1);
      assert Scan(bs,0,|bs|,depth,count) == Scan(bs,1,|bs|,depth,count);
    }
  }

  lemma DescriptorBalanced(s: Descriptor, depth: nat, count: nat)
    requires Good(s)
    ensures Scan(Render(s),0,|Render(s)|,depth,count) == Counted(depth,count)
    decreases s, 1
  {
    match s
    case Name(n) =>
      assert forall i :: 0 <= i < |n| ==> n[i] != 40 && n[i] != 41 && n[i] != 44;
      Plain(n,depth,count);
    case Group(fs) =>
      Step([40],0,1,depth,count); Empty([40],1,depth+1,count);
      Step([41],0,1,depth+1,count); Empty([41],1,depth,count);
      FieldsBalanced(fs,depth+1,count);
      ScanConcat([40],FieldsText(fs)+[41],depth,count);
      ScanConcat(FieldsText(fs),[41],depth+1,count);
      assert Render(s) == [40]+(FieldsText(fs)+[41]);
    case Fixed(e,ds) =>
      DescriptorBalanced(e,depth,count);
      var suffix := [91]+ds+[93];
      assert forall i :: 0 <= i < |suffix| ==> suffix[i] != 40 && suffix[i] != 41 && suffix[i] != 44;
      Plain(suffix,depth,count);
      ScanConcat(Render(e),suffix,depth,count);
      assert Render(s) == Render(e)+suffix;
    case Dynamic(e) =>
      DescriptorBalanced(e,depth,count);
      Plain([91,93],depth,count);
      ScanConcat(Render(e),[91,93],depth,count);
  }

  lemma FieldsBalanced(fs: seq<Descriptor>, depth: nat, count: nat)
    requires forall i :: 0 <= i < |fs| ==> Good(fs[i])
    ensures Scan(FieldsText(fs),0,|FieldsText(fs)|,depth,count) ==
            Counted(depth,count+(if depth == 0 && |fs| > 0 then |fs|-1 else 0))
    decreases fs, 0
  {
    if |fs| > 0 {
      DescriptorBalanced(fs[0],depth,count);
      if |fs| == 1 { assert fs[1..] == []; assert FieldsText(fs) == Render(fs[0]); }
      else {
        var next := count+(if depth == 0 then 1 else 0);
        Step([44],0,1,depth,count); Empty([44],1,depth,next);
        FieldsBalanced(fs[1..],depth,next);
        ScanConcat([44],FieldsText(fs[1..]),depth,count);
        ScanConcat(Render(fs[0]),[44]+FieldsText(fs[1..]),depth,count);
      }
    }
  }

  lemma CountTuple(fs: seq<Descriptor>)
    requires Good(Group(fs))
    ensures Scan(Render(Group(fs)),1,|Render(Group(fs))|-1,0,1) == Counted(0,|fs|)
  {
    FieldsBalanced(fs,0,1);
    ScanSlice(Render(Group(fs)),1,|Render(Group(fs))|-1,0,1);
    assert Render(Group(fs))[1..|Render(Group(fs))|-1] == FieldsText(fs);
  }
}
