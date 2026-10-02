// SPDX-License-Identifier: MIT
include "../preparation/Source.generated.dfy"
include "../callback-results/Source.generated.dfy"

module CollectionsCallsModel {
  import opened AbiFrames
  import P = CollectionsPreparationModel
  import R = CollectionsCallbackResultsModel

  datatype Callback = Callback(descriptor: seq<Byte>, first: nat, second: nat, target: nat, selector: seq<Byte>, expression: seq<Byte>)
  datatype Context = Context(operation: seq<Byte>, index: nat, other: nat)
  datatype Event = Target(target: nat) | Codec(request: P.Request)
                 | Direct(plan: P.Layout, args: seq<seq<Byte>>, envelope: bool)
                 | Expression(expression: seq<Byte>, args: seq<seq<Byte>>)
                 | External(target: nat, data: seq<Byte>)
  datatype Encoded = Data(data: seq<Byte>) | EncodeFailure(reason: seq<Byte>)
  datatype Observation = Observation(success: bool, data: seq<Byte>, gasBefore: nat, gasAfter: nat)
  datatype Environment = Environment(codec: seq<Event> -> P.Environment,
                                     code: (seq<Event>,nat) -> nat, direct: (seq<Event>,P.Layout,seq<seq<Byte>>,bool) -> Encoded,
                                     expression: (seq<Event>,seq<Byte>,seq<seq<Byte>>) -> seq<Byte>,
                                     call: (seq<Event>,nat,seq<Byte>) -> Observation)
  datatype Error = Helper(reason: seq<Byte>) | InvalidTarget(target: nat) | OutOfGas
                 | CallbackFailed(operation: seq<Byte>, index: nat, other: nat, target: nat, data: seq<Byte>, reason: seq<Byte>)
  datatype Outcome = Returned(value: seq<Byte>, prepared: P.Prepared, history: seq<Event>)
                   | Failed(error: Error, prepared: P.Prepared, history: seq<Event>)
  ghost predicate Admitted(env: Environment) { forall h: seq<Event> :: P.Admitted(env.codec(h)) }
  predicate Valid(cb: Callback, p: P.Prepared, binary: bool) {
    P.ValidLayout(p.plan,cb.descriptor) && |p.args| == |p.plan.parts| && cb.first < |p.args| &&
    (!binary || (cb.second < |p.args| && cb.first != cb.second))
  }
  function CodecEvents(h: seq<P.Request>): seq<Event>
    decreases |h|
  { if |h| == 0 then [] else [Codec(h[0])]+CodecEvents(h[1..]) }

  function Bound(cb: Callback, p: P.Prepared, slot: nat, value: seq<Byte>, h: seq<Event>, env: Environment): Outcome
    requires Admitted(env) && P.ValidLayout(p.plan,cb.descriptor) && |p.args| == |p.plan.parts| && slot < |p.args|
    ensures P.ValidLayout(Bound(cb,p,slot,value,h,env).prepared.plan,cb.descriptor)
    ensures |Bound(cb,p,slot,value,h,env).prepared.args| == |p.args|
    ensures Bound(cb,p,slot,value,h,env).prepared.plan == p.plan
    ensures Bound(cb,p,slot,value,h,env).prepared.targetChecked == p.targetChecked
  {
    var r := P.Bind(cb.descriptor,p,slot,value,[],env.codec(h));
    if r.Failed? then Failed(Helper(r.reason),p,h+CodecEvents(r.history))
    else Returned([],r.prepared,h+CodecEvents(r.history))
  }
  function Invoke(cb: Callback, p: P.Prepared, c: Context, data: seq<Byte>, h: seq<Event>, env: Environment): Outcome {
    var observed := env.call(h,cb.target,data);
    var after := h+[External(cb.target,data)];
    if observed.success then Returned(observed.data,p,after) else
    if R.Reject(observed.gasBefore,observed.gasAfter,observed.data) then Failed(OutOfGas,p,after) else
    Failed(CallbackFailed(c.operation,c.index,c.other,cb.target,data,observed.data),p,after)
  }
  function Encode(cb: Callback, p: P.Prepared, c: Context, h: seq<Event>, env: Environment): Outcome {
    if |cb.expression| == 0 then
      var r := env.direct(h,p.plan,p.args,false);
      var after := h+[Direct(p.plan,p.args,false)];
      if r.EncodeFailure? then Failed(Helper(r.reason),p,after) else Invoke(cb,p,c,cb.selector+r.data,after,env)
    else
      var data := env.expression(h,cb.expression,p.args);
      Invoke(cb,p,c,data,h+[Expression(cb.expression,p.args)],env)
  }
  function Bindings(cb: Callback, p: P.Prepared, c: Context, a: seq<Byte>, b: seq<Byte>, binary: bool, h: seq<Event>, env: Environment): Outcome
    requires Admitted(env) && Valid(cb,p,binary)
  {
    var first := Bound(cb,p,cb.first,a,h,env);
    if first.Failed? then first else
    if !binary then Encode(cb,first.prepared,c,first.history,env) else
    var second := Bound(cb,first.prepared,cb.second,b,first.history,env);
    if second.Failed? then second else Encode(cb,second.prepared,c,second.history,env)
  }
  function Run(cb: Callback, p: P.Prepared, c: Context, a: seq<Byte>, b: seq<Byte>, binary: bool, h: seq<Event>, env: Environment): Outcome
    requires Admitted(env) && Valid(cb,p,binary)
  {
    if p.targetChecked then Bindings(cb,p,c,a,b,binary,h,env) else
    var after := h+[Target(cb.target)];
    if env.code(h,cb.target) == 0 then Failed(InvalidTarget(cb.target),p,after) else
    Bindings(cb,P.Prepared(p.plan,p.args,true),c,a,b,binary,after,env)
  }
}
