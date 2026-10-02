// SPDX-License-Identifier: MIT
include "../stamp-loop/Iteration.generated.dfy"
include "../stamp-loop/Exit.generated.dfy"
include "Memory.dfy"
module BytecodeApplyStampEngine {
  import opened BytecodeScanMachine
  import W = BytecodeApplyWindowInputs
  import M = BytecodeApplyStampMemory
  import I = BytecodeApplyStampIteration
  import X = BytecodeApplyStampExit
  import E = BytecodeScanExecution
  predicate Matches(code: seq<Byte>) { I.Matches(code) && X.Matches(code) }
  function Destinations(): set<nat> { I.Destinations()+X.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,arrayOffset: Word,count: Word,word: Word,templateLength: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && M.Fits(mem,ptr,templateLength,arrayOffset,count,data) && |prefix| <= 1010
    ensures state == Running(12472,prefix,M.Stamped(mem,ptr,templateLength,arrayOffset,count,data,word,count))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(16850,prefix+[12472,ptr,arrayOffset,count,word,0],mem) && trace[|trace|-1] == state
    ensures |trace| == 15+40*(count as nat)
  {
    var index: Word := 0;
    state := Running(16850,prefix+[12472,ptr,arrayOffset,count,word,0],mem);trace := [state];
    while index < count
      invariant index <= count
      invariant E.Trace(code,Destinations(),value,data,trace)
      invariant trace[0] == Running(16850,prefix+[12472,ptr,arrayOffset,count,word,0],mem) && trace[|trace|-1] == state
      invariant |trace| == 1+40*(index as nat)
      invariant state == Running(16850,prefix+[12472,ptr,arrayOffset,count,word,index],M.Stamped(mem,ptr,templateLength,arrayOffset,count,data,word,index))
      decreases count-index
    {
      M.Extent(mem,ptr,templateLength,arrayOffset,count,data,word,index);
      var part: seq<State>;
      state,part := I.Run(code,data,M.Stamped(mem,ptr,templateLength,arrayOffset,count,data,word,index),prefix,12472,ptr,arrayOffset,count,word,index,templateLength,value);
      E.WidenTrace(code,I.Destinations(),Destinations(),value,data,part);
      E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];index := index+1;
    }
    var part: seq<State>;
    state,part := X.Run(code,data,M.Stamped(mem,ptr,templateLength,arrayOffset,count,data,word,count),prefix,12472,ptr,arrayOffset,count,word,count,templateLength,value);
    E.WidenTrace(code,X.Destinations(),Destinations(),value,data,part);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
  }
}
