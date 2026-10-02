// SPDX-License-Identifier: MIT
// Complete physical unknown-selector rejection for each exact runtime family.
include "Assertions.generated.dfy"
include "Expressions.generated.dfy"
include "Collections.generated.dfy"
include "AssertionsTerminal.generated.dfy"
include "ExpressionsTerminal.generated.dfy"
include "CollectionsTerminal.generated.dfy"
module BytecodeUnknownConnection {
  import G = BytecodeGetterMachine
  import E = BytecodeUnknownExecution
  import A = BytecodeUnknownAssertions
  import X = BytecodeUnknownExpressions
  import C = BytecodeUnknownCollections
  import DA = BytecodeDispatchAssertions
  import DX = BytecodeDispatchExpressions
  import DC = BytecodeDispatchCollections
  predicate Matches(id: nat, code: seq<G.Byte>) {
    id < 3 && (if id == 0 then A.Matches(code) else if id == 1 then X.Matches(code) else C.Matches(code))
  }
  predicate Admitted(id: nat, value: G.Word, size: G.Word, word: G.Word) {
    id < 3 && (if id == 0 then A.Admitted(value,size,word) else if id == 1 then X.Admitted(value,size,word) else C.Admitted(value,size,word))
  }
  function Destinations(id: nat): set<nat> {
    if id == 0 then DA.Destinations() else if id == 1 then DX.Destinations() else DC.Destinations()
  }
  ghost method Run(id: nat, code: seq<G.Byte>, value: G.Word, size: G.Word, word: G.Word) returns (state: G.State, trace: seq<G.State>)
    requires Matches(id,code) && Admitted(id,value,size,word)
    ensures state == G.Reverted([])
    ensures E.Trace(code,Destinations(id),value,size,word,trace)
    ensures trace[0] == G.Running(0,[],[]) && trace[|trace|-1] == state
    ensures forall i: nat | i < |trace| && trace[i].Running? :: |trace[i].stack| <= 3 && |trace[i].memory| <= 96
  {
    if id == 0 { state,trace := A.Run(code,value,size,word); }
    else if id == 1 { state,trace := X.Run(code,value,size,word); }
    else { state,trace := C.Run(code,value,size,word); }
  }
}
