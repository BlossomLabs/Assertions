// SPDX-License-Identifier: MIT
// Physical byte-memory correspondence for already-proved dispatcher steps.
include "Machine.dfy"
include "Physical.dfy"
module OperationsRawDispatchBridge {
  import D = OperationsRawDispatchMachine
  import G = OperationsRawDispatchPhysical
  function Memory(initialized: bool): seq<G.Byte> {
    if initialized then G.Store([],64,128) else []
  }
  function Project(state: D.State): G.State {
    if state.Running? then G.Running(state.pc,state.stack,Memory(state.initialized))
    else if state.Rejected? then G.Reverted([])
    else G.Bad
  }
  predicate FetchAgrees(abstractCode: seq<D.Byte>, physicalCode: seq<G.Byte>, pc: nat)
    requires pc < |abstractCode| && pc < |physicalCode|
  {
    var a := D.Fetch(abstractCode,pc);
    var p := G.Fetch(physicalCode,pc);
    a.op == p.op && a.next == p.next && a.immediate == p.immediate
  }
  lemma PrefixFetch(abstractCode: seq<D.Byte>, physicalCode: seq<G.Byte>, pc: nat)
    requires pc+4 < |abstractCode| <= |physicalCode|
    requires forall i: nat | i < |abstractCode| :: abstractCode[i] == physicalCode[i]
    ensures FetchAgrees(abstractCode,physicalCode,pc)
  {}
  lemma Step(abstractCode: seq<D.Byte>, physicalCode: seq<G.Byte>, destinations: set<nat>, entries: set<nat>, state: D.State, value: D.Word, size: D.Word, word: D.Word)
    requires state.Running? && state.pc < |abstractCode| && state.pc < |physicalCode| && state.pc !in entries
    requires |state.stack| <= 3
    requires FetchAgrees(abstractCode,physicalCode,state.pc)
    requires forall d: nat | d in destinations :: d < |abstractCode| && d < |physicalCode| && abstractCode[d] == physicalCode[d]
    requires D.Fetch(abstractCode,state.pc).op == 0x52 ==> !state.initialized
    requires D.Step(abstractCode,destinations,entries,state,value,size,word) != D.Bad
    requires !D.Step(abstractCode,destinations,entries,state,value,size,word).Chosen?
    ensures G.Step(physicalCode,destinations,Project(state),value,size,word) == Project(D.Step(abstractCode,destinations,entries,state,value,size,word))
    ensures G.Step(physicalCode,destinations,Project(state),value,size,word) != G.Bad
    ensures |Memory(state.initialized)| <= 96
  {
    reveal G.Step();
    assert |G.Store([],64,128)| == 96;
  }
}
