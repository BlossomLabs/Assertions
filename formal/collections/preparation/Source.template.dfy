// SPDX-License-Identifier: MIT
// Collections.sol SHA256: $HASH
include "Model.dfy"

module CollectionsPreparationSource {
  import opened AbiFrames
  import opened CollectionsPreparationModel

  ghost method PrepareCallback(cb: Callback, binary: bool, h: seq<Request>, env: Environment) returns (out: Outcome)
    requires Admitted(env)
    ensures out == Prepare(cb,binary,h,env)
  {
    if $SLOTS { out := InvalidCallback(h); return; }
    var descriptor := cb.descriptor;
    if $PARENTHESES {
      var q := Shape(descriptor);
      var r := env.step(h,q);
      if r.Error? { out := Failed(r.reason,h+[q]); return; }
      out := InvalidCallback(h+[q]); return;
    }
    var q := Tuple(descriptor);
    var r := env.step(h,q);
    if r.Error? { out := Failed(r.reason,h+[q]); return; }
    var plan := r.plan;
    if $COUNT { out := InvalidCallback(h+[q]); return; }
    var args := cb.constants;
    var current := h+[q];
    var i: nat := 0;
    while $LOOP
      invariant i <= |cb.constants|
      invariant args == cb.constants
      invariant Prepare(cb,binary,h,env) == Constants(cb,binary,plan,i,current,env)
      decreases |cb.constants|-i
    {
      if $VISIT {
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
    var request := Validate(descriptor[part.start..part.end],value,$BIND_INDEX,part.dynamic,part.words);
    var reply := env.step(h,request);
    if reply.Error? { out := Failed(reply.reason,h+[request]); return; }
    var args := prepared.args;
    args := args[$WRITE_SLOT := value];
    out := Ready(Prepared(prepared.plan,args,prepared.targetChecked),h+[request]);
  }
}
