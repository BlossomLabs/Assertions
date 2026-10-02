// SPDX-License-Identifier: MIT
// Arbitrarily many successful physical array suffixes, with independent grammar.
include "ArrayChainSpec.dfy"
include "ArraySuffix.dfy"
module AssertionsNavigationArrayChain {
  import opened BytecodeScanMachine
  import Q = AssertionsNavigationArrayChainSpec
  import A = AssertionsNavigationArraySuffix
  import L = AssertionsNavigationNameLoop
  import E = AssertionsNavigationNameTrace
  import H = AssertionsNavigationNameFrame
  ghost method Run(code: seq<Byte>,destinations: set<nat>,ret: Word,offset: Word,length: Word,p: Word,limit: Word,start: Word,initialDyn: bool,initialWords: Word,closings: seq<nat>,prefix: seq<Word>,mem: seq<Byte>,data: seq<Byte>,value: Word) returns (end: Word,dyn: bool,words: Word,trace: seq<State>)
    requires p <= start <= limit <= length && (offset as nat)+length <= |data| < 0x10000000000000000 && |prefix| <= 950
    requires Q.Valid(data,offset,start,limit,initialDyn,initialWords,closings) && A.Matches(code)
    requires {3175,8882,8902,8919,8923,8955,8969,8980,8991,9005,9015,9027,9036,9047,9066,9081,9084,9105,9121,9147,9151,9184,9195,9204,17853,18062,19262,19279,19901} <= destinations
    ensures Q.Result(data,offset,start,limit,initialDyn,initialWords,closings) == Q.Shape(end,dyn,words)
    ensures start <= end <= limit && 1 <= words <= 4294967295
    ensures dyn ==> words == 1
    ensures end == limit || data[offset+end] != 91
    ensures E.Trace(code,destinations,value,data,trace)
    ensures trace[0] == Running(8882,prefix+[ret,offset,length,p,limit,start,if initialDyn then 1 else 0,initialWords],mem)
    ensures trace[|trace|-1] == Running(8882,prefix+[ret,offset,length,p,limit,end,if dyn then 1 else 0,words],mem)
    ensures forall j {:trigger trace[j]} :: 0 <= j < |trace|-1 ==> H.Local(code,trace[j])
  {
    end := start; dyn := initialDyn; words := initialWords;
    trace := [Running(8882,prefix+[ret,offset,length,p,limit,end,if dyn then 1 else 0,words],mem)];
    var i: nat := 0;
    while i < |closings|
      invariant i <= |closings|
      invariant start <= end <= limit
      invariant Q.Valid(data,offset,end,limit,dyn,words,closings[i..])
      invariant Q.Result(data,offset,start,limit,initialDyn,initialWords,closings) == Q.Result(data,offset,end,limit,dyn,words,closings[i..])
      invariant E.Trace(code,destinations,value,data,trace)
      invariant trace[0] == Running(8882,prefix+[ret,offset,length,p,limit,start,if initialDyn then 1 else 0,initialWords],mem)
      invariant trace[|trace|-1] == Running(8882,prefix+[ret,offset,length,p,limit,end,if dyn then 1 else 0,words],mem)
      invariant forall j {:trigger trace[j]} :: 0 <= j < |trace|-1 ==> H.Local(code,trace[j])
      decreases |closings|-i
    {
      var remaining := closings[i..];
      var stop: Word := remaining[0];
      assert remaining[1..] == closings[i+1..];
      assert A.Admitted(offset,length,p,limit,end,if dyn then 1 else 0,words,stop,prefix,data);
      var count: Word; var nextDyn: bool; var nextWords: Word; var segment: seq<State>;
      count,nextDyn,nextWords,segment := A.Run(code,destinations,ret,offset,length,p,limit,end,if dyn then 1 else 0,words,stop,prefix,mem,data,value);
      assert nextWords == Q.NextWords(data,offset,end,stop,dyn,words);
      assert Q.Result(data,offset,end,limit,dyn,words,remaining) == Q.Result(data,offset,stop+1,limit,nextDyn,nextWords,remaining[1..]);
      E.Join(code,destinations,value,data,trace,segment);
      L.JoinLocal(trace,segment,code);
      trace := trace+segment[1..];
      end := stop+1; dyn := nextDyn; words := nextWords; i := i+1;
    }
  }
}
