// SPDX-License-Identifier: MIT
include "Canonical.dfy"

module AbiLayoutSoundness {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import AbiParserSource
  import opened AbiLayoutSpec
  import opened AbiLayoutCanonical

  ghost method FieldWitness(t: seq<Byte>, p: nat, limit: nat, count: nat, head: nat)
    returns (fs: seq<Descriptor>)
    requires Uint(|t|) && p <= limit <= |t| && count > 0 && Uint(head)
    requires AbiLayoutSpec.Fields(t,p,limit,count,head).Plan?
    ensures |fs| == count
    ensures forall i :: 0 <= i < |fs| ==> Admissible(fs[i])
    ensures t[p..limit] == FieldsText(fs)
    ensures head+32*WidthSum(fs) == AbiLayoutSpec.Fields(t,p,limit,count,head).head
    ensures Uint(head+32*WidthSum(fs))
    decreases count
  {
    var parsed := AbiParserSource.TypeShape(t,p,limit);
    assert parsed.Shaped?;
    assert t[p..parsed.end] == Render(parsed.syntax);
    var nextHead := head+parsed.words*32;
    assert Uint(nextHead);
    if count == 1 {
      fs := [parsed.syntax];
      assert parsed.end == limit;
    } else {
      assert parsed.end < limit && t[parsed.end] == 44;
      var rest := FieldWitness(t,parsed.end+1,limit,count-1,nextHead);
      fs := [parsed.syntax]+rest;
      assert |rest| > 0;
      assert t[p..limit] == t[p..parsed.end]+[44]+t[parsed.end+1..limit];
    }
  }

  ghost method LayoutWitness(t: seq<Byte>) returns (fs: seq<Descriptor>)
    requires Uint(|t|) && Reference(t).Plan?
    ensures Admissible(Group(fs)) && Uint(32*WidthSum(fs))
    ensures t == Render(Group(fs))
    ensures Reference(t) == PlanFor(0,fs,0)
  {
    assert |t| >= 2 && t[0] == 40 && t[|t|-1] == 41;
    var counted := AbiLayoutScan.Scan(t,1,|t|-1,0,1);
    assert counted.Counted? && counted.count > 0;
    fs := FieldWitness(t,1,|t|-1,counted.count,0);
    assert |fs| > 0 && Uint(WidthSum(fs));
    assert Good(Group(fs)) && Admissible(Group(fs));
    assert t == [40]+t[1..|t|-1]+[41];
    var r := CanonicalLayout(t,fs);
  }
}
