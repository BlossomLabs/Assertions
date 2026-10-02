// SPDX-License-Identifier: MIT
include "Layout.generated.dfy"

module AbiLayoutCanonical {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiParserCompleteness
  import opened AbiTupleSemantics
  import opened AbiLayoutScan
  import opened AbiLayoutSpec
  import opened AbiLayoutSource

  function PlanFor(ts: nat, fs: seq<Descriptor>, i: nat): LayoutResult
    requires i <= |fs|
    ensures PlanFor(ts,fs,i).Plan?
    ensures |PlanFor(ts,fs,i).starts| == |fs|-i
    ensures |PlanFor(ts,fs,i).ends| == |fs|-i
    ensures |PlanFor(ts,fs,i).dynamics| == |fs|-i
    ensures |PlanFor(ts,fs,i).words| == |fs|-i
    ensures PlanFor(ts,fs,i).head == 32*WidthSum(fs)
    decreases |fs|-i
  {
    if i == |fs| then Plan([],[],[],[],32*WidthSum(fs)) else
    var rest := PlanFor(ts,fs,i+1);
    var start := FieldStart(ts,fs,i);
    Plan([start]+rest.starts,[start+|Render(fs[i])|]+rest.ends,
         [Dyn(fs[i])]+rest.dynamics,[Width(fs[i])]+rest.words,rest.head)
  }

  lemma PlanIndex(ts: nat, fs: seq<Descriptor>, i: nat)
    requires i <= |fs|
    ensures forall j :: 0 <= j < |fs|-i ==>
                          PlanFor(ts,fs,i).starts[j] == FieldStart(ts,fs,i+j) &&
                          PlanFor(ts,fs,i).ends[j] == FieldStart(ts,fs,i+j)+|Render(fs[i+j])| &&
                          PlanFor(ts,fs,i).dynamics[j] == Dyn(fs[i+j]) && PlanFor(ts,fs,i).words[j] == Width(fs[i+j])
    decreases |fs|-i
  { if i < |fs| { PlanIndex(ts,fs,i+1); } }

  lemma CanonicalFields(t: seq<Byte>, ts: nat, te: nat, fs: seq<Descriptor>, i: nat)
    requires Uint(|t|) && Admissible(Group(fs)) && Uint(32*WidthSum(fs))
    requires ts <= te <= |t| && t[ts..te] == Render(Group(fs))
    requires i < |fs|
    ensures FieldStart(ts,fs,i) <= te-1
    ensures AbiLayoutSpec.Fields(t,FieldStart(ts,fs,i),te-1,|fs|-i,32*WidthSum(fs[..i])) == PlanFor(ts,fs,i)
    decreases |fs|-i
  {
    LocateField(t,ts,te,fs,i);
    var p := FieldStart(ts,fs,i);
    Accept(t,p,te-1,fs[i]);
    var parsed := Parse(t,p,te-1);
    assert parsed.Shaped? && parsed.syntax == fs[i] && parsed.words == Width(fs[i]);
    AppendFields(fs[..i],fs[i]);
    assert fs[..i+1] == fs[..i]+[fs[i]];
    assert fs == fs[..i+1]+fs[i+1..];
    WidthConcat(fs[..i+1],fs[i+1..]);
    assert 32*WidthSum(fs[..i])+parsed.words*32 == 32*WidthSum(fs[..i+1]);
    assert Uint(parsed.words*32) && Uint(32*WidthSum(fs[..i+1]));
    if i+1 < |fs| { CanonicalFields(t,ts,te,fs,i+1); }
    else { assert i+1 == |fs| && fs[..i+1] == fs; }
  }

  ghost method CanonicalLayout(t: seq<Byte>, fs: seq<Descriptor>) returns (r: LayoutResult)
    requires Uint(|t|) && Admissible(Group(fs)) && Uint(32*WidthSum(fs))
    requires t == Render(Group(fs))
    ensures r == Reference(t)
    ensures r == PlanFor(0,fs,0)
  {
    CountTuple(fs);
    CanonicalFields(t,0,|t|,fs,0);
    r := Layout(t);
  }
}
