// SPDX-License-Identifier: MIT
include "Model.dfy"

module CollectionsConstantsConnection {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import opened CollectionsConstantsModel
  import P = CollectionsPreparationModel
  import PS = CollectionsPreparationSource
  import K = CollectionsCodecStateModel
  import KS = CollectionsCodecStateConnection
  import C = AbiConstructionModel
  import V = AbiConstructionContext
  import Component = AbiConstructionComponent
  import D = AbiDynamicSemantics
  import LS = AbiLayoutSpec
  import W = CollectionsWireModel

  // A ghost table of pure codec receipts. Later entries are not claims that
  // the source visits them after an earlier failure; Tail selects that prefix.
  ghost method Receipts(fs: seq<Descriptor>, cb: P.Callback, binary: bool) returns (plan: P.Layout, checks: seq<V.Result>)
    requires Admissible(Group(fs)) && cb.descriptor == Render(Group(fs)) && |cb.constants| == |fs|
    requires Uint(|cb.descriptor|) && Uint(32*WidthSum(fs)) && Uint(|fs|)
    requires forall i :: 0 <= i < |fs| && !P.Substituted(cb,binary,i) ==> Uint(|cb.constants[i]|) && D.CursorRoom(fs[i],|cb.constants[i]|) && Uint(32*Width(fs[i]))
    ensures plan == K.Plan(fs) && P.ValidLayout(plan,cb.descriptor) && |plan.parts| == |fs|
    ensures |checks| == |fs|
    ensures forall i :: 0 <= i < |fs| && !P.Substituted(cb,binary,i) ==> !checks[i].Panic? && (checks[i].Success? == C.ValidInput(fs[i],cb.constants[i]))
  {
    var raw: LS.LayoutResult;
    raw,plan := KS.Layout(fs);
    checks := seq(|fs|,i => V.Success);
    var i: nat := 0;
    while i < |fs|
      invariant i <= |fs| && |checks| == |fs|
      invariant forall j :: 0 <= j < i && !P.Substituted(cb,binary,j) ==> !checks[j].Panic? && (checks[j].Success? == C.ValidInput(fs[j],cb.constants[j]))
      decreases |fs|-i
    {
      if !P.Substituted(cb,binary,i) {
        var part := plan.parts[i];
        assert |Render(fs[i])| <= |cb.descriptor|;
        var result := Component.Component(cb.descriptor[part.start..part.end],cb.constants[i],i,part.dynamic,part.words,fs[i]);
        checks := checks[i := result];
      }
      i := i+1;
    }
  }

  ghost method Prepare(fs: seq<Descriptor>, cb: P.Callback, binary: bool, error: V.Result -> seq<Byte>) returns (out: P.Outcome, checks: seq<V.Result>, failure: nat)
    requires Admissible(Group(fs)) && cb.descriptor == Render(Group(fs)) && |cb.constants| == |fs|
    requires P.Slots(cb,binary)
    requires Uint(|cb.descriptor|) && Uint(32*WidthSum(fs)) && Uint(|fs|)
    requires forall i :: 0 <= i < |fs| && !P.Substituted(cb,binary,i) ==> Uint(|cb.constants[i]|) && D.CursorRoom(fs[i],|cb.constants[i]|) && Uint(32*Width(fs[i]))
    ensures |checks| == |fs|
    ensures P.ValidLayout(K.Plan(fs),cb.descriptor)
    ensures out == P.Prepare(cb,binary,[],Environment(cb,K.Plan(fs),checks,error))
    ensures out.Ready? == K.CanonicalExcept(fs,cb.constants,if binary then {cb.first,cb.second} else {cb.first})
    ensures out.Ready? ==> out.prepared == P.Prepared(K.Plan(fs),cb.constants,false) && failure == |fs|
    ensures out.Failed? ==> failure < |fs| && !P.Substituted(cb,binary,failure) && !C.ValidInput(fs[failure],cb.constants[failure]) && out.reason == error(checks[failure])
    ensures out.Failed? ==> (forall j :: 0 <= j < failure && !P.Substituted(cb,binary,j) ==> C.ValidInput(fs[j],cb.constants[j]))
    ensures out.Ready? || out.Failed?
  {
    var plan: P.Layout;
    plan,checks := Receipts(fs,cb,binary);
    Admitted(cb,plan,checks,error);
    assert P.Parenthesized(cb.descriptor);
    var env := Environment(cb,plan,checks,error);
    assert env.step([],P.Tuple(cb.descriptor)) == P.Planned(plan);
    Entry(cb,binary,plan,env);
    out := PS.PrepareCallback(cb,binary,[],env);
    var reference: P.Outcome;
    reference,failure := Tail(cb,binary,plan,checks,error,0,[P.Tuple(cb.descriptor)]);
    assert reference == out;
    assert (forall i :: 0 <= i < |fs| ==> (P.Substituted(cb,binary,i) == (i in (if binary then {cb.first,cb.second} else {cb.first}))));
  }
  ghost method PrepareAndBind(fs: seq<Descriptor>, cb: P.Callback, binary: bool, a: seq<Byte>, b: seq<Byte>, error: V.Result -> seq<Byte>) returns (out: P.Outcome)
    requires Admissible(Group(fs)) && cb.descriptor == Render(Group(fs)) && |cb.constants| == |fs| && P.Slots(cb,binary)
    requires Uint(|cb.descriptor|) && Uint(32*WidthSum(fs)) && Uint(|fs|)
    requires forall i :: 0 <= i < |fs| && !P.Substituted(cb,binary,i) ==> Uint(|cb.constants[i]|) && D.CursorRoom(fs[i],|cb.constants[i]|) && Uint(32*Width(fs[i]))
    requires Uint(|a|) && D.CursorRoom(fs[cb.first],|a|) && Uint(32*Width(fs[cb.first]))
    requires binary ==> Uint(|b|) && D.CursorRoom(fs[cb.second],|b|) && Uint(32*Width(fs[cb.second]))
    requires Uint(C.TotalBytes(if binary then cb.constants[cb.first := a][cb.second := b] else cb.constants[cb.first := a]))
    ensures out.Ready? == (K.CanonicalExcept(fs,cb.constants,if binary then {cb.first,cb.second} else {cb.first}) && C.ValidInput(fs[cb.first],a) && (!binary || C.ValidInput(fs[cb.second],b)))
    ensures out.Ready? ==> out.prepared == P.Prepared(K.Plan(fs),if binary then cb.constants[cb.first := a][cb.second := b] else cb.constants[cb.first := a],false)
    ensures out.Ready? ==> C.ValidInputs(fs,out.prepared.args) && W.DirectReady(out.prepared)
    ensures out.Ready? || out.Failed?
  {
    var checks: seq<V.Result>;
    var failure: nat;
    out,checks,failure := Prepare(fs,cb,binary,error);
    if out.Failed? { return; }
    var history := out.history;
    var unbound := if binary then {cb.first,cb.second} else {cb.first};
    var checked: V.Result;
    checked,out := KS.Binding(fs,out.prepared.args,false,unbound,cb.first,a,error);
    out := if out.Ready? then P.Ready(out.prepared,history+out.history) else P.Failed(out.reason,history+out.history);
    if out.Failed? { return; }
    if binary {
      history := out.history;
      checked,out := KS.Binding(fs,out.prepared.args,false,unbound-{cb.first},cb.second,b,error);
      out := if out.Ready? then P.Ready(out.prepared,history+out.history) else P.Failed(out.reason,history+out.history);
      if out.Failed? { return; }
      assert (unbound-{cb.first})-{cb.second} == {};
    } else { assert unbound-{cb.first} == {}; }
    assert C.ValidInputs(fs,out.prepared.args);
    KS.Ready(fs,out.prepared.args,false);
  }

}
