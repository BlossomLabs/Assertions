// SPDX-License-Identifier: MIT
include "Bridge.dfy"
module OperationsRawDispatchExecution {
  import G = OperationsRawDispatchPhysical
  predicate Trace(code: seq<G.Byte>, destinations: set<nat>, value: G.Word, size: G.Word, word: G.Word, trace: seq<G.State>) {
    |trace| > 0 &&
    (forall i: nat | i < |trace| :: trace[i] != G.Bad) &&
    (forall i: nat | i+1 < |trace| :: G.Step(code,destinations,trace[i],value,size,word) == trace[i+1])
  }
  lemma Extend(code: seq<G.Byte>, destinations: set<nat>, value: G.Word, size: G.Word, word: G.Word, trace: seq<G.State>, next: G.State)
    requires Trace(code,destinations,value,size,word,trace)
    requires G.Step(code,destinations,trace[|trace|-1],value,size,word) == next && next != G.Bad
    ensures Trace(code,destinations,value,size,word,trace+[next])
  {
    forall i: nat | i < |trace+[next]|
      ensures (trace+[next])[i] != G.Bad
    {
      if i < |trace| { assert (trace+[next])[i] == trace[i]; }
    }
    forall i: nat | i+1 < |trace+[next]|
      ensures G.Step(code,destinations,(trace+[next])[i],value,size,word) == (trace+[next])[i+1]
    {
      if i+1 < |trace| {
        assert (trace+[next])[i] == trace[i];
        assert (trace+[next])[i+1] == trace[i+1];
      } else { assert i == |trace|-1; }
    }
  }
}
