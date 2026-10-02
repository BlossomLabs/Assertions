// SPDX-License-Identifier: MIT
// Collections.sol SHA256: 0fb54250a53bceb5c8d1e530144ae5c46eb499ce4456051914b5ff95af9d9ba4
include "Model.dfy"

module CollectionsPreparationSource {
  import opened AbiFrames
  import opened CollectionsPreparationModel

  ghost method PrepareCallback(cb: Callback, binary: bool, h: seq<Request>, env: Environment) returns (out: Outcome)
    requires Admitted(env)
    ensures out == Prepare(cb,binary,h,env)
  {
    if ((cb.first >= |cb.constants|) || ((binary && (((cb.second >= |cb.constants|) || (cb.first == cb.second)))))) { out := InvalidCallback(h); return; }
    var descriptor := cb.descriptor;
    if ((|descriptor| != 0) && (((descriptor[0] != 40) || (descriptor[(|descriptor| - 1)] != 41)))) {
      var q := Shape(descriptor);
      var r := env.step(h,q);
      if r.Error? { out := Failed(r.reason,h+[q]); return; }
      out := InvalidCallback(h+[q]); return;
    }
    var q := Tuple(descriptor);
    var r := env.step(h,q);
    if r.Error? { out := Failed(r.reason,h+[q]); return; }
    var plan := r.plan;
    if (|plan.parts| != |cb.constants|) { out := InvalidCallback(h+[q]); return; }
    var args := cb.constants;
    var current := h+[q];
    var i: nat := 0;
    while (i < |cb.constants|)
      invariant i <= |cb.constants|
      invariant args == cb.constants
      invariant Prepare(cb,binary,h,env) == Constants(cb,binary,plan,i,current,env)
      decreases |cb.constants|-i
    {
      if ((i != cb.first) && ((!(binary) || (i != cb.second)))) {
        var request := CheckRequest(descriptor,plan,args,i);
        var reply := env.step(current,request);
        if reply.Error? { out := Failed(reply.reason,current+[request]); return; }
        current := current+[request];
      }
      i := i+1;
    }
    out := Ready(Prepared(plan,args,false),current);
  }

  ghost method BindValue(descriptor: seq<Byte>, prepared: Prepared, slot: nat, value: seq<Byte>, h: seq<Request>, env: Environment) returns (out: Outcome)
    requires Admitted(env) && ValidLayout(prepared.plan,descriptor) && |prepared.plan.parts| == |prepared.args| && slot < |prepared.args|
    ensures out == Bind(descriptor,prepared,slot,value,h,env)
    ensures out.Ready? ==> out.prepared.plan == prepared.plan && out.prepared.targetChecked == prepared.targetChecked
    ensures out.Ready? ==> out.prepared.args[slot] == value
    ensures out.Ready? ==> (forall j :: 0 <= j < |prepared.args| && j != slot ==> out.prepared.args[j] == prepared.args[j])
  {
    var part := prepared.plan.parts[slot];
    var request := Validate(descriptor[part.start..part.end],value,slot,part.dynamic,part.words);
    var reply := env.step(h,request);
    if reply.Error? { out := Failed(reply.reason,h+[request]); return; }
    var args := prepared.args;
    args := args[slot := value];
    out := Ready(Prepared(prepared.plan,args,prepared.targetChecked),h+[request]);
  }
}
