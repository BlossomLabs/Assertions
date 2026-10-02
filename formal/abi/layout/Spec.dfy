// SPDX-License-Identifier: MIT
include "Count.generated.dfy"

module AbiLayoutSpec {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiLayoutScan

  datatype LayoutResult = Plan(starts: seq<nat>, ends: seq<nat>, dynamics: seq<bool>, words: seq<nat>, head: nat)
                        | BadLayout(at: nat) | LayoutPanic

  function Prepend(p: nat, shape: ShapeResult, rest: LayoutResult): LayoutResult
    requires shape.Shaped?
  {
    if !rest.Plan? then rest else
    Plan([p]+rest.starts,[shape.end]+rest.ends,[shape.dynamic]+rest.dynamics,[shape.words]+rest.words,rest.head)
  }

  function Fields(t: seq<Byte>, p: nat, limit: nat, count: nat, head: nat): LayoutResult
    requires Uint(|t|)
    requires p <= limit <= |t| && count > 0
    decreases count
  {
    var parsed := Parse(t,p,limit);
    if parsed.BadDescriptor? then BadLayout(parsed.at) else
    if parsed.ArithmeticPanic? then LayoutPanic else
    var nextHead := head+parsed.words*32;
    if !Uint(parsed.words*32) || !Uint(nextHead) then LayoutPanic else
    if count == 1 then
      if parsed.end != limit then BadLayout(parsed.end) else
      Plan([p],[parsed.end],[parsed.dynamic],[parsed.words],nextHead)
    else if parsed.end >= limit || t[parsed.end] != 44 then BadLayout(parsed.end) else
    Prepend(p,parsed,Fields(t,parsed.end+1,limit,count-1,nextHead))
  }

  function Reference(t: seq<Byte>): LayoutResult
    requires Uint(|t|)
  {
    if |t| < 2 || t[0] != 40 || t[|t|-1] != 41 then
      var parsed := Whole(t);
      if parsed.BadDescriptor? then BadLayout(parsed.at) else
      if parsed.ArithmeticPanic? then LayoutPanic else BadLayout(0)
    else
      var counted := Scan(t,1,|t|-1,0,1);
      if counted.Stray? then BadLayout(counted.at) else
      if counted.count == 0 then LayoutPanic else Fields(t,1,|t|-1,counted.count,0)
  }

  function Prefix(starts: seq<nat>, ends: seq<nat>, dynamics: seq<bool>, words: seq<nat>, rest: LayoutResult): LayoutResult
  {
    if !rest.Plan? then rest else
    Plan(starts+rest.starts,ends+rest.ends,dynamics+rest.dynamics,words+rest.words,rest.head)
  }

  lemma PrefixStep(starts: seq<nat>, ends: seq<nat>, dynamics: seq<bool>, words: seq<nat>, p: nat,
                   shape: ShapeResult, rest: LayoutResult)
    requires shape.Shaped?
    ensures Prefix(starts,ends,dynamics,words,Prepend(p,shape,rest)) ==
            Prefix(starts+[p],ends+[shape.end],dynamics+[shape.dynamic],words+[shape.words],rest)
  {}
}
