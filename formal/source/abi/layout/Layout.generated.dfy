// SPDX-License-Identifier: MIT
// Source-derived tupleLayout; Solidity SHA256: 485f0d49f35528cc4c9be7767c631be6903ff57b5cb95bcbb25d6cd04ce5fed6
include "Spec.dfy"

module AbiLayoutSource {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import AbiParserSource
  import opened AbiLayoutScan
  import opened AbiLayoutCountSource
  import opened AbiLayoutSpec

  ghost method Head(head: nat, words: nat) returns (r: Outcome)
    requires Uint(head) && Uint(words)
    ensures r == (if Uint(head+words*32) then Ok(head+words*32) else Panic(17))
  {
    var next := (head + (words * 32));
    if !Uint(words*32) || !Uint(next) { r := Panic(17); return; }
    r := Ok(next);
  }

  ghost method Layout(t: seq<Byte>) returns (r: LayoutResult)
    requires Uint(|t|)
    ensures r == Reference(t)
  {
    if |t| < 2 || t[0] != 40 || t[|t|-1] != 41 {
      var parsed := AbiParserSource.Shape(t);
      r := if parsed.BadDescriptor? then BadLayout(parsed.at) else
      if parsed.ArithmeticPanic? then LayoutPanic else BadLayout(0);
      return;
    }
    var counted := Count(t);
    if counted.Stray? { r := BadLayout(counted.at); return; }
    var limit := |t|-1;
    var count := counted.count;
    var p: nat := 1;
    var head: nat := 0;
    var starts: seq<nat> := [];
    var ends: seq<nat> := [];
    var dynamics: seq<bool> := [];
    var words: seq<nat> := [];
    var i: nat := 0;
    while true
      invariant 0 <= i < count && p <= limit && Uint(head)
      invariant |starts| == i && |ends| == i && |dynamics| == i && |words| == i
      invariant Reference(t) == Prefix(starts,ends,dynamics,words,AbiLayoutSpec.Fields(t,p,limit,count-i,head))
      decreases count-i
    {
      var parsed := AbiParserSource.TypeShape(t,p,limit);
      if parsed.BadDescriptor? { r := BadLayout(parsed.at); return; }
      if parsed.ArithmeticPanic? { r := LayoutPanic; return; }
      var next := Head(head,parsed.words);
      if !next.Ok? { r := LayoutPanic; return; }
      if i+1 == count {
        if parsed.end != limit { r := BadLayout(parsed.end); return; }
        r := Plan(starts+[p],ends+[parsed.end],dynamics+[parsed.dynamic],words+[parsed.words],next.used);
        return;
      }
      if parsed.end >= limit || t[parsed.end] != 44 { r := BadLayout(parsed.end); return; }
      var remaining := AbiLayoutSpec.Fields(t,parsed.end+1,limit,count-i-1,next.used);
      PrefixStep(starts,ends,dynamics,words,p,parsed,remaining);
      starts := starts+[p]; ends := ends+[parsed.end];
      dynamics := dynamics+[parsed.dynamic]; words := words+[parsed.words];
      head := next.used;
      p := parsed.end+1;
      i := i+1;
    }
  }
}
