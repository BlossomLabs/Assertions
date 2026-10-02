// SPDX-License-Identifier: MIT
// Collections.sol SHA256: 0fb54250a53bceb5c8d1e530144ae5c46eb499ce4456051914b5ff95af9d9ba4
include "Model.dfy"

module CollectionsCallsSource {
  import opened AbiFrames
  import opened CollectionsCallsModel
  import P = CollectionsPreparationModel
  import B = CollectionsPreparationSource
  import R = CollectionsCallbackResultsSource

  ghost method Bind(cb: Callback, p: P.Prepared, slot: nat, value: seq<Byte>, h: seq<Event>, env: Environment) returns (out: Outcome)
    requires Admitted(env) && P.ValidLayout(p.plan,cb.descriptor) && |p.args| == |p.plan.parts| && slot < |p.args|
    ensures out == Bound(cb,p,slot,value,h,env)
  {
    var r := B.BindValue(cb.descriptor,p,slot,value,[],env.codec(h));
    if r.Failed? { out := Failed(Helper(r.reason),p,h+CodecEvents(r.history)); }
    else { out := Returned([],r.prepared,h+CodecEvents(r.history)); }
  }

  ghost method CallValue(cb: Callback, initial: P.Prepared, c: Context, a: seq<Byte>, b: seq<Byte>, binary: bool, h: seq<Event>, env: Environment) returns (out: Outcome)
    requires Admitted(env) && Valid(cb,initial,binary)
    ensures out == Run(cb,initial,c,a,b,binary,h,env)
  {
    var prepared := initial;
    var current := h;
    if !(prepared.targetChecked) {
      var codeLength := env.code(current,cb.target);
      current := current+[Target(cb.target)];
      if (codeLength == 0) { out := Failed(InvalidTarget(cb.target),prepared,current); return; }
      prepared := P.Prepared(prepared.plan,prepared.args,true);
    }
    var first := Bind(cb,prepared,cb.first,a,current,env);
    if first.Failed? { out := first; return; }
    prepared := first.prepared;
    current := first.history;
    if binary {
      var second := Bind(cb,prepared,cb.second,b,current,env);
      if second.Failed? { out := second; return; }
      prepared := second.prepared;
      current := second.history;
    }
    var data: seq<Byte>;
    if (|cb.expression| == 0) {
      var encoded := env.direct(current,prepared.plan,prepared.args,false);
      current := current+[Direct(prepared.plan,prepared.args,false)];
      if encoded.EncodeFailure? { out := Failed(Helper(encoded.reason),prepared,current); return; }
      data := cb.selector+encoded.data;
    } else {
      data := env.expression(current,cb.expression,prepared.args);
      current := current+[Expression(cb.expression,prepared.args)];
    }
    var observed := env.call(current,cb.target,data);
    current := current+[External(cb.target,data)];
    if !observed.success {
      var rejected := R.RejectOutOfGas(observed.gasBefore,observed.gasAfter,observed.data);
      if rejected { out := Failed(OutOfGas,prepared,current); return; }
      out := Failed(CallbackFailed(c.operation,c.index,c.other,cb.target,data,observed.data),prepared,current);
      return;
    }
    out := Returned(observed.data,prepared,current);
  }
}
