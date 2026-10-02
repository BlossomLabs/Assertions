// SPDX-License-Identifier: MIT
// Finite actual window-check loop from the shared map/filter call site.
include "Entry.generated.dfy"
include "Iteration.generated.dfy"
include "Exit.generated.dfy"
module BytecodeApplyWindowEngine {
  import opened BytecodeScanMachine
  import W = BytecodeApplyWindowInputs
  import E = BytecodeScanExecution
  import P = BytecodeApplyWindowsEntry
  import I = BytecodeApplyWindowsIteration
  import X = BytecodeApplyWindowsExit
  predicate Matches(code: seq<Byte>) { P.Matches(code) && I.Matches(code) && X.Matches(code) }
  function Destinations(): set<nat> { P.Destinations()+I.Destinations()+X.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,value: Word)
    returns (state: State,trace: seq<State>)
    requires Matches(code) && W.Valid(templateLength,arrayOffset,count,data) && |prefix| <= 1012
    ensures state == Running(12235,prefix,mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(16683,prefix+[12235,templateOffset,templateLength,arrayOffset,count],mem)
    ensures trace[|trace|-1] == state && |trace| == 10+53*(count as nat)+14
  {
    var index: Word := 0;
    state,trace := P.Run(code,data,mem,prefix,12235,templateOffset,templateLength,arrayOffset,count,index,value);
    E.WidenTrace(code,P.Destinations(),Destinations(),value,data,trace);
    while index < count
      invariant index <= count
      invariant W.Valid(templateLength,arrayOffset,count,data)
      invariant E.Trace(code,Destinations(),value,data,trace)
      invariant trace[0] == Running(16683,prefix+[12235,templateOffset,templateLength,arrayOffset,count],mem)
      invariant trace[|trace|-1] == state && |trace| == 10+53*(index as nat)
      invariant state == Running(16728,prefix+[12235,templateOffset,templateLength,arrayOffset,count,index],mem)
      decreases count-index
    {
      W.Index(templateLength,arrayOffset,count,data,index);
      var part: seq<State>;
      var next: State;
      next,part := I.Run(code,data,mem,prefix,12235,templateOffset,templateLength,arrayOffset,count,index,value);
      E.WidenTrace(code,I.Destinations(),Destinations(),value,data,part);
      E.Join(code,Destinations(),value,data,trace,part);
      trace := trace+part[1..];
      state := next; index := index+1;
    }
    var part: seq<State>;
    var next: State;
    next,part := X.Run(code,data,mem,prefix,12235,templateOffset,templateLength,arrayOffset,count,index,value);
    E.WidenTrace(code,X.Destinations(),Destinations(),value,data,part);
    E.Join(code,Destinations(),value,data,trace,part);
    trace := trace+part[1..]; state := next;
  }
}
