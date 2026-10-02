// SPDX-License-Identifier: MIT
// Actual accumulator-first store, unbounded finite element stamp loop and physical fold return.
include "../stamp-outer-repair-v2/Entry.generated.dfy"
include "../stamp-outer-repair-v2/Exit.generated.dfy"
include "../stamp-loop/Iteration.generated.dfy"
include "../stamp-loop/Exit.generated.dfy"
include "Memory.dfy"
module BytecodeFoldStampEngineV2 {
  import opened BytecodeScanMachine
  import M = BytecodeFoldStampMemoryV2
  import H = BytecodeApplyStampMemory
  import P = BytecodeFoldStampOuterEntryV2
  import Q = BytecodeFoldStampOuterExitV2
  import I = BytecodeFoldStampIteration
  import X = BytecodeFoldStampExit
  import E = BytecodeScanExecution
  predicate Matches(code: seq<Byte>) { P.Matches(code) && Q.Matches(code) && I.Matches(code) && X.Matches(code) }
  function Destinations(): set<nat> { P.Destinations()+Q.Destinations()+I.Destinations()+X.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,templateLength: Word,accOffset: Word,acc: Word,arrayOffset: Word,count: Word,word: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && M.Fits(mem,ptr,templateLength,accOffset,arrayOffset,count,data) && |prefix| <= 990
    ensures state == Running(16536,prefix,M.Stamped(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,count))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| > 0 && trace[0] == Running(19449,prefix+[16536,ptr,accOffset,acc,arrayOffset,count,word],mem) && trace[|trace|-1] == state
    ensures |M.Stamped(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,count)| == |mem|
    ensures forall j: nat :: j < |mem| ==> M.Stamped(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,count)[j] == M.LastByte(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,count,j)
  {
    M.AccExtent(mem,ptr,templateLength,accOffset,arrayOffset,count,data,acc);
    state,trace := P.Run(code,data,mem,prefix,16536,ptr,accOffset,acc,arrayOffset,count,word,templateLength,value);
    E.WidenTrace(code,P.Destinations(),Destinations(),value,data,trace);
    var inner := prefix+[16536,ptr,accOffset,acc,arrayOffset,count,word];
    var index: Word := 0;
    while index < count
      invariant index <= count
      invariant E.Trace(code,Destinations(),value,data,trace)
      invariant trace[0] == Running(19449,prefix+[16536,ptr,accOffset,acc,arrayOffset,count,word],mem) && trace[|trace|-1] == state
      invariant state == Running(16850,inner+[11291,ptr,arrayOffset,count,word,index],M.Stamped(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,index))
      decreases count-index
    {
      M.Extent(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,index);
      var part: seq<State>;
      state,part := I.Run(code,data,M.Stamped(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,index),inner,11291,ptr,arrayOffset,count,word,index,templateLength,value);
      E.WidenTrace(code,I.Destinations(),Destinations(),value,data,part);
      E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];index := index+1;
    }
    M.Extent(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,count);
    var finalMemory := M.Stamped(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,count);
    var part: seq<State>;
    state,part := X.Run(code,data,finalMemory,inner,11291,ptr,arrayOffset,count,word,count,templateLength,value);
    E.WidenTrace(code,X.Destinations(),Destinations(),value,data,part);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    state,part := Q.Run(code,data,finalMemory,prefix,16536,ptr,accOffset,acc,arrayOffset,count,word,templateLength,value);
    E.WidenTrace(code,Q.Destinations(),Destinations(),value,data,part);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    forall j: nat {:trigger M.Stamped(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,count)[j]} | j < |mem|
      ensures M.Stamped(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,count)[j] == M.LastByte(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,count,j)
    { M.OrderedBytes(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,count,j); }
  }
}
