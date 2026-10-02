// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsBoundCallConnection {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import P = CollectionsPreparationModel
  import PS = CollectionsPreparationSource
  import C = CollectionsCallsModel
  import Calls = CollectionsCallsConnection
  import A = AbiConstructionModel
  import V = AbiConstructionContext
  import Component = AbiConstructionComponent
  import D = AbiDynamicSemantics
  import K = CollectionsCodecStateModel
  import KS = CollectionsCodecStateConnection
  import W = CollectionsCodecErrorEncoding
  import Wire = CollectionsWireModel
  import WS = CollectionsWireConnection
  import M = CollectionsBoundCallModel

  ghost method Receipt(fs: seq<Descriptor>, slot: nat, value: seq<Byte>) returns (r: V.Result)
    requires Admissible(Group(fs)) && slot < |fs|
    requires Uint(|Render(Group(fs))|) && Uint(32*WidthSum(fs)) && Uint(slot) && Uint(|value|)
    requires Uint(32*Width(fs[slot])) && D.CursorRoom(fs[slot],|value|)
    ensures !r.Panic? && (r.Success? == A.ValidInput(fs[slot],value))
  {
    var raw; var plan;
    raw,plan := KS.Layout(fs);
    assert |Render(fs[slot])| <= |Render(Group(fs))|;
    r := Component.Component(Render(fs[slot]),value,slot,Dyn(fs[slot]),Width(fs[slot]),fs[slot]);
  }

  ghost method Bound(fs: seq<Descriptor>, args: seq<seq<Byte>>, flag: bool, unbound: set<nat>, cb: C.Callback, slot: nat, value: seq<Byte>, receipt: V.Result, h: seq<C.Event>, env: C.Environment) returns (out: C.Outcome)
    requires Admissible(Group(fs)) && Uint(|Render(Group(fs))|) && Uint(32*WidthSum(fs))
    requires cb.descriptor == Render(Group(fs)) && K.CanonicalExcept(fs,args,unbound) && slot < |fs|
    requires C.Admitted(env)
    requires env.codec(h).step([],M.Query(fs,slot,value)) == (if receipt.Success? then P.Ok else P.Error(W.Encode(receipt)))
    requires receipt.Success? == A.ValidInput(fs[slot],value)
    ensures P.ValidLayout(K.Plan(fs),cb.descriptor)
    ensures out == C.Bound(cb,P.Prepared(K.Plan(fs),args,flag),slot,value,h,env)
    ensures out.Returned? == receipt.Success?
    ensures out.Returned? ==> out.prepared == P.Prepared(K.Plan(fs),args[slot := value],flag) && K.CanonicalExcept(fs,out.prepared.args,unbound-{slot})
    ensures out.Failed? ==> out.error == C.Helper(W.Encode(receipt)) && out.prepared == P.Prepared(K.Plan(fs),args,flag)
    ensures out.history == h+[C.Codec(M.Query(fs,slot,value))]
  {
    var raw; var plan;
    raw,plan := KS.Layout(fs);
    var p := P.Prepared(plan,args,flag);
    var checked := PS.BindValue(cb.descriptor,p,slot,value,[],env.codec(h));
    out := C.Bound(cb,p,slot,value,h,env);
    assert P.Bind(cb.descriptor,p,slot,value,[],env.codec(h)).history == [M.Query(fs,slot,value)];
    assert C.CodecEvents([M.Query(fs,slot,value)]) == [C.Codec(M.Query(fs,slot,value))];
  }

  ghost method Encode(fs: seq<Descriptor>, args: seq<seq<Byte>>, flag: bool, cb: C.Callback, c: C.Context, h: seq<C.Event>, env: C.Environment) returns (out: C.Outcome, data: seq<Byte>)
    requires Admissible(Group(fs)) && A.ValidInputs(fs,args) && Uint(|args|) && Uint(A.TotalBytes(args))
    requires env.direct == Wire.Environment(env).direct && env.expression == Wire.Environment(env).expression
    ensures Wire.DirectReady(P.Prepared(K.Plan(fs),args,flag))
    ensures out == C.Encode(cb,P.Prepared(K.Plan(fs),args,flag),c,h,env)
    ensures data == (if |cb.expression| == 0 then cb.selector+Frame(A.Pieces(fs,args)) else Wire.Expression(cb.expression,args))
    ensures out == C.Invoke(cb,P.Prepared(K.Plan(fs),args,flag),c,data,h+[if |cb.expression| == 0 then C.Direct(K.Plan(fs),args,false) else C.Expression(cb.expression,args)],env)
    ensures out.Failed? ==> !out.error.Helper?
    ensures out.prepared == P.Prepared(K.Plan(fs),args,flag)
  {
    KS.Ready(fs,args,flag);
    if |cb.expression| == 0 {
      var tuple := KS.Encode(fs,args,flag);
      data := cb.selector+tuple;
    } else {
      WS.ExpressionCanonical(cb.expression,args);
      data := Wire.Expression(cb.expression,args);
    }
    out := C.Encode(cb,P.Prepared(K.Plan(fs),args,flag),c,h,env);
  }

  ghost method Bindings(fs: seq<Descriptor>, args: seq<seq<Byte>>, flag: bool, cb: C.Callback, c: C.Context, a: seq<Byte>, b: seq<Byte>, binary: bool, h: seq<C.Event>, r1: V.Result, r2: V.Result, base: C.Environment) returns (out: C.Outcome)
    requires Admissible(Group(fs)) && Uint(|Render(Group(fs))|) && Uint(32*WidthSum(fs))
    requires cb.descriptor == Render(Group(fs)) && cb.first < |fs| && (binary ==> cb.second < |fs| && cb.first != cb.second)
    requires K.CanonicalExcept(fs,args,if binary then {cb.first,cb.second} else {cb.first})
    requires r1.Success? == A.ValidInput(fs[cb.first],a)
    requires binary ==> r2.Success? == A.ValidInput(fs[cb.second],b)
    requires Uint(|args|) && Uint(A.TotalBytes(if binary then args[cb.first := a][cb.second := b] else args[cb.first := a]))
    ensures P.ValidLayout(K.Plan(fs),cb.descriptor)
    ensures C.Admitted(M.Environment(base,M.Query(fs,cb.first,a),r1,M.Query(fs,if binary then cb.second else cb.first,if binary then b else a),r2))
    ensures out == C.Bindings(cb,P.Prepared(K.Plan(fs),args,flag),c,a,b,binary,h,M.Environment(base,M.Query(fs,cb.first,a),r1,M.Query(fs,if binary then cb.second else cb.first,if binary then b else a),r2))
    ensures !r1.Success? ==> out.Failed? && out.error == C.Helper(W.Encode(r1)) && out.prepared.args == args
    ensures r1.Success? && binary && !r2.Success? ==> out.Failed? && out.error == C.Helper(W.Encode(r2)) && out.prepared.args == args[cb.first := a]
    ensures r1.Success? && (!binary || r2.Success?) ==> A.ValidInputs(fs,out.prepared.args) && Wire.DirectReady(out.prepared)
    ensures out.Returned? ==> A.ValidInputs(fs,out.prepared.args) && Wire.DirectReady(out.prepared)
    ensures out.Returned? ==> out.prepared.args == (if binary then args[cb.first := a][cb.second := b] else args[cb.first := a])
    ensures r1.Success? && (!binary || r2.Success?) && out.Failed? ==> !out.error.Helper?
    ensures out.prepared.plan == K.Plan(fs) && out.prepared.targetChecked == flag
  {
    var q1 := M.Query(fs,cb.first,a);
    var q2 := M.Query(fs,if binary then cb.second else cb.first,if binary then b else a);
    M.Admitted(base,q1,r1,q2,r2);
    var env := M.Environment(base,q1,r1,q2,r2);
    var unbound := if binary then {cb.first,cb.second} else {cb.first};
    var first := Bound(fs,args,flag,unbound,cb,cb.first,a,r1,h,env);
    out := first;
    if first.Failed? { return; }
    if binary {
      assert q1 != q2;
      out := Bound(fs,first.prepared.args,flag,unbound-{cb.first},cb,cb.second,b,r2,first.history,env);
      if out.Failed? { return; }
      assert (unbound-{cb.first})-{cb.second} == {};
    } else { assert unbound-{cb.first} == {}; }
    assert A.ValidInputs(fs,out.prepared.args);
    KS.Ready(fs,out.prepared.args,flag);
    var data;
    out,data := Encode(fs,out.prepared.args,flag,cb,c,out.history,env);
  }
  ghost method Run(fs: seq<Descriptor>, args: seq<seq<Byte>>, flag: bool, cb: C.Callback, c: C.Context, a: seq<Byte>, b: seq<Byte>, binary: bool, h: seq<C.Event>, base: C.Environment) returns (r1: V.Result, r2: V.Result, env: C.Environment, out: C.Outcome)
    requires Admissible(Group(fs)) && Uint(|Render(Group(fs))|) && Uint(32*WidthSum(fs))
    requires cb.descriptor == Render(Group(fs)) && cb.first < |fs| && (binary ==> cb.second < |fs| && cb.first != cb.second)
    requires K.CanonicalExcept(fs,args,if binary then {cb.first,cb.second} else {cb.first})
    requires Uint(|args|) && Uint(A.TotalBytes(if binary then args[cb.first := a][cb.second := b] else args[cb.first := a]))
    requires |cb.expression| > 0 ==> Wire.ExpressionReady(cb.expression,if binary then args[cb.first := a][cb.second := b] else args[cb.first := a])
    requires |cb.selector| == 4 && cb.target < Pow256(20) && |c.operation| == 4 && Uint(c.index) && Uint(c.other)
    requires Uint(cb.first) && Uint(|a|) && Uint(32*Width(fs[cb.first])) && D.CursorRoom(fs[cb.first],|a|)
    requires binary ==> Uint(cb.second) && Uint(|b|) && Uint(32*Width(fs[cb.second])) && D.CursorRoom(fs[cb.second],|b|)
    ensures C.Admitted(env) && P.ValidLayout(K.Plan(fs),cb.descriptor)
    ensures env == M.Environment(base,M.Query(fs,cb.first,a),r1,M.Query(fs,if binary then cb.second else cb.first,if binary then b else a),r2)
    ensures out == C.Run(cb,P.Prepared(K.Plan(fs),args,flag),c,a,b,binary,h,env)
    ensures !r1.Panic? && (r1.Success? == A.ValidInput(fs[cb.first],a))
    ensures binary ==> !r2.Panic? && (r2.Success? == A.ValidInput(fs[cb.second],b))
    ensures !flag && base.code(h,cb.target) == 0 ==> out == C.Failed(C.InvalidTarget(cb.target),P.Prepared(K.Plan(fs),args,flag),h+[C.Target(cb.target)])
    ensures (flag || base.code(h,cb.target) != 0) && !r1.Success? ==> out.Failed? && out.error == C.Helper(W.Encode(r1)) && out.prepared.args == args
    ensures (flag || base.code(h,cb.target) != 0) && r1.Success? && binary && !r2.Success? ==> out.Failed? && out.error == C.Helper(W.Encode(r2)) && out.prepared.args == args[cb.first := a]
    ensures out.Returned? ==> A.ValidInputs(fs,out.prepared.args) && Wire.DirectReady(out.prepared) && out.prepared.targetChecked
    ensures out.Returned? ==> out.prepared.args == (if binary then args[cb.first := a][cb.second := b] else args[cb.first := a])
    ensures out.prepared.plan == K.Plan(fs)
    ensures out.prepared.targetChecked == (flag || base.code(h,cb.target) != 0)
    ensures Calls.Targets(out.history) == Calls.Targets(h)+(if flag then [] else [cb.target])
    ensures |Calls.Calls(h)| <= |Calls.Calls(out.history)| <= |Calls.Calls(h)|+1
  {
    r1 := Receipt(fs,cb.first,a);
    r2 := V.Success;
    if binary { r2 := Receipt(fs,cb.second,b); }
    var q1 := M.Query(fs,cb.first,a);
    var q2 := M.Query(fs,if binary then cb.second else cb.first,if binary then b else a);
    M.Admitted(base,q1,r1,q2,r2);
    env := M.Environment(base,q1,r1,q2,r2);
    var raw; var plan;
    raw,plan := KS.Layout(fs);
    out := Calls.Run(cb,P.Prepared(plan,args,flag),c,a,b,binary,h,env);
    if flag || base.code(h,cb.target) != 0 {
      var actual := Bindings(fs,args,true,cb,c,a,b,binary,if flag then h else h+[C.Target(cb.target)],r1,r2,base);
      assert actual == out;
    }
  }

}
