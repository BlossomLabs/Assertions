// SPDX-License-Identifier: MIT
// Unverified complete raw dispatcher connection to actual calldata bytes.
// Routing ends at the compiler-bound wrapper; all body claims are separate.
include "OperationsKnown.generated.dfy"
include "OperationsUnknown.generated.dfy"
include "OperationsEarly.generated.dfy"
module OperationsRawDispatchConnection {
  import G = OperationsRawDispatchPhysical
  import C = OperationsRawDispatchOperations
  import K = OperationsRawKnownOperations
  import U = OperationsRawUnknownOperations
  import R = OperationsRawEarlyOperations
  import E = OperationsRawDispatchExecution
  function DataWord(data: seq<G.Byte>): G.Word { G.Load(data,0) }
  predicate Frame(data: seq<G.Byte>) { |data| < 0x10000000000000000 }
  opaque predicate Matches(code: seq<G.Byte>) {
    |code| == 21346 && (forall i: nat | i < |C.Code()| :: code[i] == C.Code()[i])
  }
  lemma MatchConnections(code: seq<G.Byte>)
    requires Matches(code)
    ensures K.Matches(code) && U.Matches(code) && R.Matches(code)
  { reveal Matches(); reveal K.Matches(); reveal U.Matches(); reveal R.Matches(); }
  lemma SelectorRange(selector: G.Word)
    ensures C.ExpectedSelector(selector) == -1 || C.ExpectedSelector(selector) >= 0
  {}
  function RawStep(code: seq<G.Byte>,destinations: set<nat>,state: G.State,value: G.Word,data: seq<G.Byte>): G.State
    requires Frame(data)
  { G.Step(code,destinations,state,value,|data|,DataWord(data)) }
  predicate RawTrace(code: seq<G.Byte>,destinations: set<nat>,value: G.Word,data: seq<G.Byte>,trace: seq<G.State>)
    requires Frame(data)
  {
    |trace| > 0 && (forall i: nat | i < |trace| :: trace[i] != G.Bad) &&
    (forall i: nat | i+1 < |trace| :: RawStep(code,destinations,trace[i],value,data) == trace[i+1])
  }
  ghost method Run(code: seq<G.Byte>,value: G.Word,data: seq<G.Byte>) returns (state: G.State,trace: seq<G.State>)
    requires Matches(code) && Frame(data)
    ensures value != 0 || |data| < 4 || C.ExpectedSelector(G.Selector(DataWord(data))) == -1 ==> state == G.Reverted([])
    ensures value == 0 && |data| >= 4 && C.ExpectedSelector(G.Selector(DataWord(data))) >= 0 ==>
              state == G.Running(C.ExpectedSelector(G.Selector(DataWord(data))) as nat,[G.Selector(DataWord(data))],G.Store([],64,128))
    ensures RawTrace(code,C.Destinations(),value,data,trace)
    ensures trace[0] == G.Running(0,[],[]) && trace[|trace|-1] == state
    ensures forall i: nat | i < |trace| && trace[i].Running? :: |trace[i].stack| <= 3 && |trace[i].memory| <= 96
  {
    MatchConnections(code); SelectorRange(G.Selector(DataWord(data)));
    if value != 0 || |data| < 4 {
      state,trace := R.Run(code,value,|data|,DataWord(data));
    } else if C.ExpectedSelector(G.Selector(DataWord(data))) == -1 {
      state,trace := U.Run(code,value,|data|,DataWord(data));
    } else {
      state,trace := K.Run(code,value,|data|,DataWord(data));
    }
  }
}
