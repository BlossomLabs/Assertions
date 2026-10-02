// SPDX-License-Identifier: MIT
include "Source.generated.dfy"

module CollectionsCallsConnection {
  import opened AbiFrames
  import opened CollectionsCallsModel
  import P = CollectionsPreparationModel
  import S = CollectionsCallsSource

  function Targets(h: seq<Event>): seq<nat>
    decreases |h|
  { if |h| == 0 then [] else Targets(h[..|h|-1])+(if h[|h|-1].Target? then [h[|h|-1].target] else []) }
  function Calls(h: seq<Event>): seq<Event>
    decreases |h|
  { if |h| == 0 then [] else Calls(h[..|h|-1])+(if h[|h|-1].External? then [h[|h|-1]] else []) }
  lemma Append(h: seq<Event>, e: Event)
    ensures Targets(h+[e]) == Targets(h)+(if e.Target? then [e.target] else [])
    ensures Calls(h+[e]) == Calls(h)+(if e.External? then [e] else [])
  {}
  lemma BoundFacts(cb: Callback, p: P.Prepared, slot: nat, value: seq<Byte>, h: seq<Event>, env: Environment)
    requires Admitted(env) && P.ValidLayout(p.plan,cb.descriptor) && |p.args| == |p.plan.parts| && slot < |p.args|
    ensures h <= Bound(cb,p,slot,value,h,env).history
    ensures Targets(Bound(cb,p,slot,value,h,env).history) == Targets(h)
    ensures Calls(Bound(cb,p,slot,value,h,env).history) == Calls(h)
    ensures Bound(cb,p,slot,value,h,env).Returned? ==> Bound(cb,p,slot,value,h,env).prepared.args == p.args[slot := value]
  {
    var part := p.plan.parts[slot];
    var q := P.Validate(cb.descriptor[part.start..part.end],value,slot,part.dynamic,part.words);
    assert P.Bind(cb.descriptor,p,slot,value,[],env.codec(h)).history == [q];
    assert CodecEvents([q]) == [Codec(q)];
    assert Bound(cb,p,slot,value,h,env).history == h+[Codec(q)];
    Append(h,Codec(q));
  }
  lemma InvokeFacts(cb: Callback, p: P.Prepared, c: Context, data: seq<Byte>, h: seq<Event>, env: Environment)
    ensures h <= Invoke(cb,p,c,data,h,env).history
    ensures Targets(Invoke(cb,p,c,data,h,env).history) == Targets(h)
    ensures |Calls(Invoke(cb,p,c,data,h,env).history)| == |Calls(h)|+1
    ensures Invoke(cb,p,c,data,h,env).prepared == p
  { Append(h,External(cb.target,data)); }
  lemma EncodeFacts(cb: Callback, p: P.Prepared, c: Context, h: seq<Event>, env: Environment)
    ensures h <= Encode(cb,p,c,h,env).history
    ensures Targets(Encode(cb,p,c,h,env).history) == Targets(h)
    ensures |Calls(h)| <= |Calls(Encode(cb,p,c,h,env).history)| <= |Calls(h)|+1
    ensures Encode(cb,p,c,h,env).Returned? ==> |Calls(Encode(cb,p,c,h,env).history)| == |Calls(h)|+1
    ensures Encode(cb,p,c,h,env).prepared == p
  {
    if |cb.expression| == 0 {
      var r := env.direct(h,p.plan,p.args,false);
      var after := h+[Direct(p.plan,p.args,false)];
      Append(h,Direct(p.plan,p.args,false));
      if r.Data? { InvokeFacts(cb,p,c,cb.selector+r.data,after,env); }
    } else {
      var data := env.expression(h,cb.expression,p.args);
      Append(h,Expression(cb.expression,p.args));
      InvokeFacts(cb,p,c,data,h+[Expression(cb.expression,p.args)],env);
    }
  }
  lemma BindingFacts(cb: Callback, p: P.Prepared, c: Context, a: seq<Byte>, b: seq<Byte>, binary: bool, h: seq<Event>, env: Environment)
    requires Admitted(env) && Valid(cb,p,binary)
    ensures h <= Bindings(cb,p,c,a,b,binary,h,env).history
    ensures Targets(Bindings(cb,p,c,a,b,binary,h,env).history) == Targets(h)
    ensures |Calls(h)| <= |Calls(Bindings(cb,p,c,a,b,binary,h,env).history)| <= |Calls(h)|+1
    ensures Bindings(cb,p,c,a,b,binary,h,env).prepared.plan == p.plan
    ensures Bindings(cb,p,c,a,b,binary,h,env).prepared.targetChecked == p.targetChecked
    ensures Bindings(cb,p,c,a,b,binary,h,env).Returned? ==>
              Bindings(cb,p,c,a,b,binary,h,env).prepared.args == (if binary then p.args[cb.first := a][cb.second := b] else p.args[cb.first := a]) &&
              |Calls(Bindings(cb,p,c,a,b,binary,h,env).history)| == |Calls(h)|+1
  {
    BoundFacts(cb,p,cb.first,a,h,env);
    var first := Bound(cb,p,cb.first,a,h,env);
    if first.Failed? { return; }
    if !binary { EncodeFacts(cb,first.prepared,c,first.history,env); return; }
    BoundFacts(cb,first.prepared,cb.second,b,first.history,env);
    var second := Bound(cb,first.prepared,cb.second,b,first.history,env);
    if second.Returned? { EncodeFacts(cb,second.prepared,c,second.history,env); }
  }
  ghost method Run(cb: Callback, p: P.Prepared, c: Context, a: seq<Byte>, b: seq<Byte>, binary: bool, h: seq<Event>, env: Environment) returns (out: Outcome)
    requires Admitted(env) && Valid(cb,p,binary)
    ensures out == CollectionsCallsModel.Run(cb,p,c,a,b,binary,h,env)
    ensures h <= out.history
    ensures Targets(out.history) == Targets(h)+(if p.targetChecked then [] else [cb.target])
    ensures |Calls(h)| <= |Calls(out.history)| <= |Calls(h)|+1
    ensures out.prepared.plan == p.plan
    ensures out.Returned? ==> out.prepared.targetChecked && |Calls(out.history)| == |Calls(h)|+1
    ensures out.Returned? ==> out.prepared.args == (if binary then p.args[cb.first := a][cb.second := b] else p.args[cb.first := a])
  {
    out := S.CallValue(cb,p,c,a,b,binary,h,env);
    if p.targetChecked { BindingFacts(cb,p,c,a,b,binary,h,env); }
    else {
      Append(h,Target(cb.target));
      if env.code(h,cb.target) != 0 {
        BindingFacts(cb,P.Prepared(p.plan,p.args,true),c,a,b,binary,h+[Target(cb.target)],env);
      }
    }
  }
}
