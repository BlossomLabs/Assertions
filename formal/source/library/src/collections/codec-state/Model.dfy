// SPDX-License-Identifier: MIT
include "../wire/Connection.dfy"
include "../../abi/construction/Model.dfy"
include "../../abi/layout/Canonical.dfy"

module CollectionsCodecStateModel {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import L = AbiLayoutCanonical
  import P = CollectionsPreparationModel
  import C = AbiConstructionModel
  import V = AbiConstructionContext

  function Plan(fs: seq<Descriptor>): P.Layout {
    var plan := L.PlanFor(0,fs,0);
    P.Layout(seq(|fs|,i requires 0 <= i < |fs| => P.Component(plan.starts[i],plan.ends[i],plan.dynamics[i],plan.words[i])),plan.head)
  }
  ghost predicate CanonicalExcept(fs: seq<Descriptor>, args: seq<seq<Byte>>, unbound: set<nat>) {
    |fs| == |args| && forall i :: 0 <= i < |fs| && i !in unbound ==> C.ValidInput(fs[i],args[i])
  }
  function SingleEnvironment(q: P.Request, result: V.Result, error: V.Result -> seq<Byte>): P.Environment
    requires q.Validate?
  {
    P.Environment((history,request) => if request == q && result.Success? then P.Ok else P.Error(if request == q then error(result) else []))
  }
  lemma SingleAdmitted(q: P.Request, result: V.Result, error: V.Result -> seq<Byte>)
    requires q.Validate?
    ensures P.Admitted(SingleEnvironment(q,result,error))
  {}
}
