// SPDX-License-Identifier: MIT
include "Encoding.dfy"

module CollectionsCodecErrorConnection {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import P = CollectionsPreparationModel
  import V = AbiConstructionContext
  import K = CollectionsCodecStateModel
  import Admission = CollectionsAdmissionModel
  import Source = CollectionsAdmissionConnection
  import CM = CollectionsConstantsModel
  import C = AbiConstructionModel
  import CS = CollectionsConstantsConnection
  import KS = CollectionsCodecStateConnection
  import D = AbiDynamicSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import W = CollectionsCodecErrorEncoding

  ghost method Prepare(cb: P.Callback, binary: bool) returns (out: P.Outcome, fs: seq<Descriptor>, checks: seq<V.Result>, env: P.Environment)
    requires Admission.Room(cb,binary)
    ensures P.Admitted(env) && out == P.Prepare(cb,binary,[],env)
    ensures Admission.Admission(cb,binary).Stop? ==> out == Admission.Admission(cb,binary).out
    ensures out.Ready? ==> K.CanonicalExcept(fs,cb.constants,if binary then {cb.first,cb.second} else {cb.first}) && out.prepared == P.Prepared(K.Plan(fs),cb.constants,false)
    ensures Admission.Admission(cb,binary).Continue? ==> (out.Ready? == K.CanonicalExcept(fs,cb.constants,if binary then {cb.first,cb.second} else {cb.first}))
  {
    out,fs,checks,env := Source.Prepare(cb,binary,W.Encode);
  }
  ghost method Constants(fs: seq<Descriptor>, cb: P.Callback, binary: bool) returns (out: P.Outcome, checks: seq<V.Result>, failure: nat)
    requires Admissible(Group(fs)) && cb.descriptor == Render(Group(fs)) && |cb.constants| == |fs|
    requires P.Slots(cb,binary)
    requires Uint(|cb.descriptor|) && Uint(32*WidthSum(fs)) && Uint(|fs|)
    requires forall i :: 0 <= i < |fs| && !P.Substituted(cb,binary,i) ==> Uint(|cb.constants[i]|) && D.CursorRoom(fs[i],|cb.constants[i]|) && Uint(32*Width(fs[i]))
    ensures |checks| == |fs|
    ensures P.ValidLayout(K.Plan(fs),cb.descriptor)
    ensures out == P.Prepare(cb,binary,[],CM.Environment(cb,K.Plan(fs),checks,W.Encode))
    ensures out.Ready? == K.CanonicalExcept(fs,cb.constants,if binary then {cb.first,cb.second} else {cb.first})
    ensures out.Ready? ==> out.prepared == P.Prepared(K.Plan(fs),cb.constants,false) && failure == |fs|
    ensures out.Failed? ==> failure < |fs| && !P.Substituted(cb,binary,failure) && !C.ValidInput(fs[failure],cb.constants[failure]) && out.reason == W.Encode(checks[failure])
    ensures out.Failed? ==> (forall j :: 0 <= j < failure && !P.Substituted(cb,binary,j) ==> C.ValidInput(fs[j],cb.constants[j]))
    ensures out.Ready? || out.Failed?
    ensures out.Failed? ==> out.reason == W.Selector(checks[failure])+Frame(W.Pieces(W.Args(checks[failure])))
  {
    out,checks,failure := CS.Prepare(fs,cb,binary,W.Encode);
    if out.Failed? { W.Error(checks[failure]); }
  }
  ghost method Binding(fs: seq<Descriptor>, args: seq<seq<Byte>>, flag: bool, unbound: set<nat>, slot: nat, value: seq<Byte>) returns (checked: V.Result, out: P.Outcome)
    requires Admissible(Group(fs)) && Uint(|Render(Group(fs))|) && Uint(32*WidthSum(fs))
    requires K.CanonicalExcept(fs,args,unbound) && slot < |fs| && Uint(slot) && Uint(|value|)
    requires D.CursorRoom(fs[slot],|value|) && Uint(32*Width(fs[slot]))
    ensures !checked.Panic?
    ensures out.Ready? == checked.Success?
    ensures checked.Success? == C.ValidInput(fs[slot],value)
    ensures out.Ready? ==> out.prepared == P.Prepared(K.Plan(fs),args[slot := value],flag)
    ensures out.Ready? ==> K.CanonicalExcept(fs,out.prepared.args,unbound-{slot})
    ensures out.Failed? ==> out.reason == W.Encode(checked)
    ensures out.Ready? || out.Failed?
    ensures |out.history| == 1
    ensures out.Failed? ==> out.reason == W.Selector(checked)+Frame(W.Pieces(W.Args(checked)))
  {
    checked,out := KS.Binding(fs,args,flag,unbound,slot,value,W.Encode);
    W.Error(checked);
  }
}
