// SPDX-License-Identifier: MIT
include "Source.generated.dfy"

module CollectionsPreparationConnection {
  import opened AbiFrames
  import opened CollectionsPreparationModel
  import S = CollectionsPreparationSource

  function ValidationSlots(h: seq<Request>): seq<nat>
    decreases |h|
  {
    if |h| == 0 then [] else ValidationSlots(h[..|h|-1]) + (if h[|h|-1].Validate? then [h[|h|-1].slot] else [])
  }
  function Selected(cb: Callback, binary: bool, start: nat, end: nat): seq<nat>
    requires start <= end
    decreases end-start
  {
    if start == end then [] else (if Substituted(cb,binary,start) then [] else [start])+Selected(cb,binary,start+1,end)
  }
  lemma Append(h: seq<Request>, q: Request)
    ensures ValidationSlots(h+[q]) == ValidationSlots(h)+(if q.Validate? then [q.slot] else [])
  {}

  ghost method ConstantsFacts(cb: Callback, binary: bool, plan: Layout, i: nat, h: seq<Request>, env: Environment)
    returns (out: Outcome, stop: nat)
    requires Admitted(env) && ValidLayout(plan,cb.descriptor) && |plan.parts| == |cb.constants| && i <= |cb.constants|
    ensures out == Constants(cb,binary,plan,i,h,env)
    ensures i <= stop <= |cb.constants|
    ensures h <= out.history
    ensures ValidationSlots(out.history) == ValidationSlots(h)+Selected(cb,binary,i,stop)
    ensures out.Ready? ==> stop == |cb.constants| && out.prepared == Prepared(plan,cb.constants,false)
    decreases |cb.constants|-i
  {
    if i == |cb.constants| { stop := i; out := Ready(Prepared(plan,cb.constants,false),h); return; }
    if Substituted(cb,binary,i) { out,stop := ConstantsFacts(cb,binary,plan,i+1,h,env); return; }
    var q := CheckRequest(cb.descriptor,plan,cb.constants,i);
    var r := env.step(h,q);
    Append(h,q);
    if r.Error? { out := Failed(r.reason,h+[q]); stop := i+1; return; }
    out,stop := ConstantsFacts(cb,binary,plan,i+1,h+[q],env);
  }

  ghost method Prepare(cb: Callback, binary: bool, h: seq<Request>, env: Environment) returns (out: Outcome, stop: nat)
    requires Admitted(env)
    ensures out == CollectionsPreparationModel.Prepare(cb,binary,h,env)
    ensures stop <= |cb.constants| && h <= out.history
    ensures ValidationSlots(out.history) == ValidationSlots(h)+Selected(cb,binary,0,stop)
    ensures out.Ready? ==> stop == |cb.constants| && Slots(cb,binary) && out.prepared.args == cb.constants && !out.prepared.targetChecked
    ensures out.Ready? ==> ValidLayout(out.prepared.plan,cb.descriptor) && |out.prepared.plan.parts| == |cb.constants|
  {
    out := S.PrepareCallback(cb,binary,h,env);
    stop := 0;
    if !Slots(cb,binary) { return; }
    if |cb.descriptor| > 0 && !Parenthesized(cb.descriptor) { Append(h,Shape(cb.descriptor)); return; }
    var q := Tuple(cb.descriptor);
    var r := env.step(h,q);
    Append(h,q);
    if r.Error? || |r.plan.parts| != |cb.constants| { return; }
    var reference: Outcome;
    reference,stop := ConstantsFacts(cb,binary,r.plan,0,h+[q],env);
  }
}
