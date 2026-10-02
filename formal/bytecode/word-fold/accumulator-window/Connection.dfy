// SPDX-License-Identifier: MIT
// Exact ordered fold accumulator/element admission and complete shared cleanup.
include "Gate.generated.dfy"
include "Short.generated.dfy"
include "Invalid.generated.dfy"
include "Exit.generated.dfy"
include "../element-windows/Engine.dfy"
include "../element-window-errors/Engine.dfy"
module BytecodeFoldWindowConnection {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import W = BytecodeFoldElementWindowInputs
  import E = BytecodeScanExecution
  import A = BytecodeFoldAccumulatorWindowGate
  import AS = BytecodeFoldAccumulatorWindowShort
  import AI = BytecodeFoldAccumulatorWindowInvalid
  import X = BytecodeFoldAccumulatorWindowExit
  import L = BytecodeFoldElementWindowEngine
  import B = BytecodeFoldElementWindowRejection
  predicate Matches(code: seq<Byte>) {
    A.Matches(code) && AS.Matches(code) && AI.Matches(code) && X.Matches(code) && L.Matches(code) && B.Matches(code)
  }
  function Destinations(): set<nat> {
    A.Destinations()+AS.Destinations()+AI.Destinations()+X.Destinations()+L.Destinations()+B.Destinations()
  }
  function Error(offset: Word,length: Word): State {
    Reverted(G.Encode(0x1a0d83de,4)+G.Encode(offset,32)+G.Encode(length,32))
  }
  ghost method FirstBad(templateLength: Word,arrayOffset: Word,count: Word,data: seq<Byte>) returns (bad: Word)
    requires W.Represented(templateLength,arrayOffset,count,data) && templateLength >= 32
    requires !W.Valid(templateLength,arrayOffset,count,data)
    ensures bad < count && W.At(arrayOffset,bad,data) > templateLength-32
    ensures forall j: nat :: j < bad ==> W.At(arrayOffset,j,data) <= templateLength-32
  {
    var failingIndex: nat :| failingIndex < count && W.At(arrayOffset,failingIndex,data) > templateLength-32;
    var index: nat := 0;
    while W.At(arrayOffset,index,data) <= templateLength-32
      invariant index <= failingIndex < count
      invariant W.At(arrayOffset,failingIndex,data) > templateLength-32
      invariant forall j: nat :: j < index ==> W.At(arrayOffset,j,data) <= templateLength-32
      decreases failingIndex-index
    {
      assert index < failingIndex;
      index := index+1;
    }
    bad := index;
  }
  ghost method Valid(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,templateOffset: Word,templateLength: Word,accOffset: Word,arrayOffset: Word,count: Word,value: Word)
    returns (state: State,trace: seq<State>)
    requires Matches(code) && W.Valid(templateLength,arrayOffset,count,data) && accOffset <= templateLength-32 && |prefix| <= 1000
    ensures state == Running(12029,prefix,mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(16343,prefix+[12029,templateOffset,templateLength,accOffset,arrayOffset,count],mem)
    ensures trace[|trace|-1] == state && |trace| == 75+53*(count as nat)
  {
    state,trace := A.Run(code,data,mem,prefix,12029,templateOffset,templateLength,accOffset,arrayOffset,count,value);
    E.WidenTrace(code,A.Destinations(),Destinations(),value,data,trace);
    var outer := prefix+[12029,templateOffset,templateLength,accOffset,arrayOffset,count];
    var part: seq<State>;
    state,part := L.Run(code,data,mem,outer,templateOffset,templateLength,arrayOffset,count,value);
    E.WidenTrace(code,L.Destinations(),Destinations(),value,data,part);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := X.Run(code,data,mem,prefix,12029,templateOffset,templateLength,accOffset,arrayOffset,count,value);
    E.WidenTrace(code,X.Destinations(),Destinations(),value,data,part);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,prefix: seq<Word>,templateOffset: Word,templateLength: Word,accOffset: Word,arrayOffset: Word,count: Word,value: Word)
    returns (state: State,trace: seq<State>)
    requires Matches(code) && W.Represented(templateLength,arrayOffset,count,data) && |prefix| <= 1000
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(16343,prefix+[12029,templateOffset,templateLength,accOffset,arrayOffset,count],Store([],64,128)) && trace[|trace|-1] == state
    ensures templateLength < 32 ==> state == Error(accOffset,templateLength)
    ensures templateLength >= 32 && accOffset > templateLength-32 ==> state == Error(accOffset,templateLength)
    ensures templateLength >= 32 && accOffset <= templateLength-32 && W.Valid(templateLength,arrayOffset,count,data) ==> state == Running(12029,prefix,Store([],64,128))
    ensures templateLength >= 32 && accOffset <= templateLength-32 && !W.Valid(templateLength,arrayOffset,count,data) ==>
              exists bad: Word :: bad < count && W.At(arrayOffset,bad,data) > templateLength-32 &&
                                  (forall j: nat :: j < bad ==> W.At(arrayOffset,j,data) <= templateLength-32) && state == Error(W.At(arrayOffset,bad,data),templateLength)
  {
    if templateLength < 32 {
      state,trace := AS.Run(code,data,Store([],64,128),prefix,12029,templateOffset,templateLength,accOffset,arrayOffset,count,value);
      E.WidenTrace(code,AS.Destinations(),Destinations(),value,data,trace);
    } else if accOffset > templateLength-32 {
      state,trace := AI.Run(code,data,Store([],64,128),prefix,12029,templateOffset,templateLength,accOffset,arrayOffset,count,value);
      E.WidenTrace(code,AI.Destinations(),Destinations(),value,data,trace);
    } else if W.Valid(templateLength,arrayOffset,count,data) {
      state,trace := Valid(code,data,Store([],64,128),prefix,templateOffset,templateLength,accOffset,arrayOffset,count,value);
    } else {
      var bad := FirstBad(templateLength,arrayOffset,count,data);
      state,trace := A.Run(code,data,Store([],64,128),prefix,12029,templateOffset,templateLength,accOffset,arrayOffset,count,value);
      E.WidenTrace(code,A.Destinations(),Destinations(),value,data,trace);
      var outer := prefix+[12029,templateOffset,templateLength,accOffset,arrayOffset,count];
      var part: seq<State>;
      state,part := B.Bad(code,data,outer,templateOffset,templateLength,arrayOffset,count,bad,value);
      E.WidenTrace(code,B.Destinations(),Destinations(),value,data,part);
      E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
      assert state == Error(W.At(arrayOffset,bad,data),templateLength);
    }
  }
}
