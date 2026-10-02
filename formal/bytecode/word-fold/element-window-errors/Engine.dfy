// SPDX-License-Identifier: MIT
// Actual finite fold element-window loop to the first failed offset after accumulator admission.
include "Invalid.generated.dfy"
include "../element-windows/Entry.generated.dfy"
include "../element-windows/Iteration.generated.dfy"
module BytecodeFoldElementWindowRejection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import W = BytecodeFoldElementWindowInputs
  import E = BytecodeScanExecution
  import P = BytecodeFoldElementWindowsEntry
  import I = BytecodeFoldElementWindowsIteration
  import EI = BytecodeFoldElementWindowErrorInvalid
  predicate Matches(code: seq<Byte>) { P.Matches(code) && I.Matches(code) && EI.Matches(code) }
  function Destinations(): set<nat> { P.Destinations()+I.Destinations()+EI.Destinations() }
  ghost method Bad(code: seq<Byte>,data: seq<Byte>,prefix: seq<Word>,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,bad: Word,value: Word)
    returns (state: State,trace: seq<State>)
    requires Matches(code) && W.Represented(templateLength,arrayOffset,count,data) && templateLength >= 32 && |prefix| <= 1010
    requires bad < count && W.At(arrayOffset,bad,data) > templateLength-32
    requires forall j: nat :: j < bad ==> W.At(arrayOffset,j,data) <= templateLength-32
    ensures state == Reverted(G.Encode(0x1a0d83de,4)+G.Encode(W.At(arrayOffset,bad,data),32)+G.Encode(templateLength,32))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(16683,prefix+[16419,templateOffset,templateLength,arrayOffset,count],Store([],64,128)) && trace[|trace|-1] == state
    ensures |trace| == 106+53*(bad as nat)
  {
    var index: Word := 0;
    state,trace := P.Run(code,data,Store([],64,128),prefix,16419,templateOffset,templateLength,arrayOffset,count,index,value);
    E.WidenTrace(code,P.Destinations(),Destinations(),value,data,trace);
    while index < bad
      invariant index <= bad < count
      invariant W.Represented(templateLength,arrayOffset,count,data) && templateLength >= 32
      invariant forall j: nat :: j < bad ==> W.At(arrayOffset,j,data) <= templateLength-32
      invariant W.At(arrayOffset,bad,data) > templateLength-32
      invariant E.Trace(code,Destinations(),value,data,trace)
      invariant trace[0] == Running(16683,prefix+[16419,templateOffset,templateLength,arrayOffset,count],Store([],64,128))
      invariant trace[|trace|-1] == state && |trace| == 10+53*(index as nat)
      invariant state == Running(16728,prefix+[16419,templateOffset,templateLength,arrayOffset,count,index],Store([],64,128))
      decreases bad-index
    {
      W.Index(templateLength,arrayOffset,count,data,index);
      var part: seq<State>;
      state,part := I.Run(code,data,Store([],64,128),prefix,16419,templateOffset,templateLength,arrayOffset,count,index,value);
      E.WidenTrace(code,I.Destinations(),Destinations(),value,data,part);
      E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
      index := index+1;
    }
    var part: seq<State>;
    state,part := EI.Run(code,prefix,16419,templateOffset,templateLength,arrayOffset,count,bad,value,data);
    E.WidenTrace(code,EI.Destinations(),Destinations(),value,data,part);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
