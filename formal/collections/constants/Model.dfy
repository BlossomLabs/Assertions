// SPDX-License-Identifier: MIT
include "../codec-state/Connection.dfy"

module CollectionsConstantsModel {
  import opened AbiFrames
  import P = CollectionsPreparationModel
  import V = AbiConstructionContext

  function Reply(cb: P.Callback, plan: P.Layout, checks: seq<V.Result>, error: V.Result -> seq<Byte>, q: P.Request): P.Reply
    requires P.ValidLayout(plan,cb.descriptor) && |plan.parts| == |cb.constants| && |checks| == |cb.constants|
  {
    if q.Tuple? && q.descriptor == cb.descriptor then P.Planned(plan) else
    if q.Validate? && q.slot < |checks| && q == P.CheckRequest(cb.descriptor,plan,cb.constants,q.slot) then
      if checks[q.slot].Success? then P.Ok else P.Error(error(checks[q.slot]))
    else P.Error([])
  }
  function Environment(cb: P.Callback, plan: P.Layout, checks: seq<V.Result>, error: V.Result -> seq<Byte>): P.Environment
    requires P.ValidLayout(plan,cb.descriptor) && |plan.parts| == |cb.constants| && |checks| == |cb.constants|
  { P.Environment((h,q) => Reply(cb,plan,checks,error,q)) }
  lemma Admitted(cb: P.Callback, plan: P.Layout, checks: seq<V.Result>, error: V.Result -> seq<Byte>)
    requires P.ValidLayout(plan,cb.descriptor) && |plan.parts| == |cb.constants| && |checks| == |cb.constants|
    ensures P.Admitted(Environment(cb,plan,checks,error))
  {}
  lemma Entry(cb: P.Callback, binary: bool, plan: P.Layout, env: P.Environment)
    requires P.Admitted(env) && P.Slots(cb,binary) && P.Parenthesized(cb.descriptor)
    requires P.ValidLayout(plan,cb.descriptor) && |plan.parts| == |cb.constants|
    requires env.step([],P.Tuple(cb.descriptor)) == P.Planned(plan)
    ensures P.Prepare(cb,binary,[],env) == P.Constants(cb,binary,plan,0,[P.Tuple(cb.descriptor)],env)
  {
    reveal P.Prepare();
    assert []+[P.Tuple(cb.descriptor)] == [P.Tuple(cb.descriptor)];
    assert env.step([],P.Tuple(cb.descriptor)).plan == plan;
  }
  predicate AllPassed(cb: P.Callback, binary: bool, checks: seq<V.Result>, start: nat)
    requires |checks| == |cb.constants|
  {
    forall i :: start <= i < |checks| && !P.Substituted(cb,binary,i) ==> checks[i].Success?
  }
  ghost method Tail(cb: P.Callback, binary: bool, plan: P.Layout, checks: seq<V.Result>, error: V.Result -> seq<Byte>, i: nat, h: seq<P.Request>) returns (out: P.Outcome, failure: nat)
    requires P.ValidLayout(plan,cb.descriptor) && |plan.parts| == |cb.constants| && |checks| == |cb.constants| && i <= |checks|
    ensures out == P.Constants(cb,binary,plan,i,h,Environment(cb,plan,checks,error))
    ensures i <= failure <= |checks|
    ensures out.Ready? ==> out.prepared == P.Prepared(plan,cb.constants,false)
    ensures out.Ready? == AllPassed(cb,binary,checks,i)
    ensures out.Ready? ==> failure == |checks|
    ensures out.Failed? ==> i <= failure < |checks| && !P.Substituted(cb,binary,failure) && !checks[failure].Success? && out.reason == error(checks[failure])
    ensures forall j :: i <= j < failure && !P.Substituted(cb,binary,j) ==> checks[j].Success?
    ensures out.Ready? || out.Failed?
    decreases |checks|-i
  {
    Admitted(cb,plan,checks,error);
    if i == |checks| { out := P.Ready(P.Prepared(plan,cb.constants,false),h); failure := i; return; }
    if P.Substituted(cb,binary,i) { out,failure := Tail(cb,binary,plan,checks,error,i+1,h); return; }
    var q := P.CheckRequest(cb.descriptor,plan,cb.constants,i);
    if !checks[i].Success? { out := P.Failed(error(checks[i]),h+[q]); failure := i; return; }
    out,failure := Tail(cb,binary,plan,checks,error,i+1,h+[q]);
  }
}
