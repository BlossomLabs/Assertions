// SPDX-License-Identifier: MIT
include "Source.generated.dfy"
module CollectionsSortComparatorConnection {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import P = CollectionsPreparationModel
  import C = CollectionsCallsModel
  import Calls = CollectionsCallsConnection
  import A = AbiConstructionModel
  import V = AbiConstructionContext
  import D = AbiDynamicSemantics
  import K = CollectionsCodecStateModel
  import W = CollectionsCodecErrorEncoding
  import Wire = CollectionsWireModel
  import B = CollectionsBoundCallModel
  import Bound = CollectionsBoundCallConnection
  import R = CollectionsCallbackResultsModel
  import Source = CollectionsSortComparatorSource
  import M = CollectionsSortComparatorModel
  import T = CollectionsTraversalModel
  ghost method Run(fs: seq<Descriptor>, args: seq<seq<Byte>>, flag: bool, cb: C.Callback, c: C.Context, a: seq<Byte>, b: seq<Byte>, h: seq<C.Event>, base: C.Environment) returns (r1: V.Result, r2: V.Result, env: C.Environment, out: C.Outcome, decision: M.Decision)
    requires Admissible(Group(fs)) && Uint(|Render(Group(fs))|) && Uint(32*WidthSum(fs))
    requires cb.descriptor == Render(Group(fs)) && cb.first < |fs| && cb.second < |fs| && cb.first != cb.second
    requires K.CanonicalExcept(fs,args,{cb.first,cb.second})
    requires Uint(|args|) && Uint(A.TotalBytes(args[cb.first := a][cb.second := b]))
    requires |cb.expression| > 0 ==> Wire.ExpressionReady(cb.expression,args[cb.first := a][cb.second := b])
    requires |cb.selector| == 4 && cb.target < Pow256(20) && |c.operation| == 4 && Uint(c.index) && Uint(c.other)
    requires Uint(cb.first) && Uint(|a|) && Uint(32*Width(fs[cb.first])) && D.CursorRoom(fs[cb.first],|a|)
    requires Uint(cb.second) && Uint(|b|) && Uint(32*Width(fs[cb.second])) && D.CursorRoom(fs[cb.second],|b|)
    requires M.AfterRoom(fs,args,flag,cb,c,a,b,h,base)
    ensures C.Admitted(env) && P.ValidLayout(K.Plan(fs),cb.descriptor)
    ensures env == B.Environment(base,B.Query(fs,cb.first,a),r1,B.Query(fs,cb.second,b),r2)
    ensures out == C.Run(cb,P.Prepared(K.Plan(fs),args,flag),c,a,b,true,h,env)
    ensures !r1.Panic? && (r1.Success? == A.ValidInput(fs[cb.first],a))
    ensures !r2.Panic? && (r2.Success? == A.ValidInput(fs[cb.second],b))
    ensures !flag && base.code(h,cb.target) == 0 ==> out == C.Failed(C.InvalidTarget(cb.target),P.Prepared(K.Plan(fs),args,flag),h+[C.Target(cb.target)])
    ensures (flag || base.code(h,cb.target) != 0) && !r1.Success? ==> out.Failed? && out.error == C.Helper(W.Encode(r1)) && out.prepared.args == args
    ensures (flag || base.code(h,cb.target) != 0) && r1.Success? && !r2.Success? ==> out.Failed? && out.error == C.Helper(W.Encode(r2)) && out.prepared.args == args[cb.first := a]
    ensures out.Returned? ==> A.ValidInputs(fs,out.prepared.args) && Wire.DirectReady(out.prepared) && out.prepared.targetChecked
    ensures out.Returned? ==> out.prepared.args == (args[cb.first := a][cb.second := b])
    ensures out.prepared.plan == K.Plan(fs)
    ensures out.prepared.targetChecked == (flag || base.code(h,cb.target) != 0)
    ensures Calls.Targets(out.history) == Calls.Targets(h)+(if flag then [] else [cb.target])
    ensures |Calls.Calls(h)| <= |Calls.Calls(out.history)| <= |Calls.Calls(h)|+1
    ensures decision == M.Judge(out,R.Context(c.operation,c.index,c.other,cb.target))
    ensures decision.TakeLeft? == (out.Returned? && |out.value| == 32)
    ensures out.Failed? ==> decision == M.Failure(Wire.ErrorBytes(out.error))
    ensures out.Returned? && |out.value| != 32 ==> decision == M.Failure(R.InvalidBytes(R.Context(c.operation,c.index,c.other,cb.target)))
    ensures decision.TakeLeft? ==> decision.value == M.NonPositive(out.value)
  {
    r1,r2,env,out := Bound.Run(fs,args,flag,cb,c,a,b,true,h,base);
    assert C.Valid(cb,P.Prepared(K.Plan(fs),args,flag),true);
    decision := Source.Process(out,c.operation,c.index,c.other,cb.target);
  }
  ghost method FromIndices(fs: seq<Descriptor>, args: seq<seq<Byte>>, flag: bool, cb: C.Callback, values: seq<seq<Byte>>, index: nat, other: nat, h: seq<C.Event>, base: C.Environment) returns (r1: V.Result, r2: V.Result, env: C.Environment, out: C.Outcome, decision: M.Decision)
    requires index < |values| && other < |values|
    requires Admissible(Group(fs)) && Uint(|Render(Group(fs))|) && Uint(32*WidthSum(fs))
    requires cb.descriptor == Render(Group(fs)) && cb.first < |fs| && cb.second < |fs| && cb.first != cb.second
    requires K.CanonicalExcept(fs,args,{cb.first,cb.second})
    requires Uint(|args|) && Uint(A.TotalBytes(args[cb.first := values[index]][cb.second := values[other]]))
    requires |cb.expression| > 0 ==> Wire.ExpressionReady(cb.expression,args[cb.first := values[index]][cb.second := values[other]])
    requires |cb.selector| == 4 && cb.target < Pow256(20) && Uint(index) && Uint(other)
    requires Uint(cb.first) && Uint(|values[index]|) && Uint(32*Width(fs[cb.first])) && D.CursorRoom(fs[cb.first],|values[index]|)
    requires Uint(cb.second) && Uint(|values[other]|) && Uint(32*Width(fs[cb.second])) && D.CursorRoom(fs[cb.second],|values[other]|)
    requires M.AfterRoom(fs,args,flag,cb,C.Context(Source.Operation(),index,other),values[index],values[other],h,base)
    ensures C.Admitted(env) && P.ValidLayout(K.Plan(fs),cb.descriptor)
    ensures env == B.Environment(base,B.Query(fs,cb.first,values[index]),r1,B.Query(fs,cb.second,values[other]),r2)
    ensures out == C.Run(cb,P.Prepared(K.Plan(fs),args,flag),C.Context(Source.Operation(),index,other),values[index],values[other],true,h,env)
    ensures !r1.Panic? && (r1.Success? == A.ValidInput(fs[cb.first],values[index]))
    ensures !r2.Panic? && (r2.Success? == A.ValidInput(fs[cb.second],values[other]))
    ensures !flag && base.code(h,cb.target) == 0 ==> out == C.Failed(C.InvalidTarget(cb.target),P.Prepared(K.Plan(fs),args,flag),h+[C.Target(cb.target)])
    ensures (flag || base.code(h,cb.target) != 0) && !r1.Success? ==> out.Failed? && out.error == C.Helper(W.Encode(r1)) && out.prepared.args == args
    ensures (flag || base.code(h,cb.target) != 0) && r1.Success? && !r2.Success? ==> out.Failed? && out.error == C.Helper(W.Encode(r2)) && out.prepared.args == args[cb.first := values[index]]
    ensures out.Returned? ==> A.ValidInputs(fs,out.prepared.args) && Wire.DirectReady(out.prepared) && out.prepared.targetChecked
    ensures out.Returned? ==> out.prepared.args == (args[cb.first := values[index]][cb.second := values[other]])
    ensures out.prepared.plan == K.Plan(fs)
    ensures out.prepared.targetChecked == (flag || base.code(h,cb.target) != 0)
    ensures Calls.Targets(out.history) == Calls.Targets(h)+(if flag then [] else [cb.target])
    ensures |Calls.Calls(h)| <= |Calls.Calls(out.history)| <= |Calls.Calls(h)|+1
    ensures decision == M.Judge(out,R.Context(C.Context(Source.Operation(),index,other).operation,C.Context(Source.Operation(),index,other).index,C.Context(Source.Operation(),index,other).other,cb.target))
    ensures decision.TakeLeft? == (out.Returned? && |out.value| == 32)
    ensures out.Failed? ==> decision == M.Failure(Wire.ErrorBytes(out.error))
    ensures out.Returned? && |out.value| != 32 ==> decision == M.Failure(R.InvalidBytes(R.Context(C.Context(Source.Operation(),index,other).operation,C.Context(Source.Operation(),index,other).index,C.Context(Source.Operation(),index,other).other,cb.target)))
    ensures decision.TakeLeft? ==> decision.value == M.NonPositive(out.value)
    ensures Source.Request(values,index,other) == T.Call(values[index],values[other],true,index,other)
  {
    var request := Source.Request(values,index,other);
    r1,r2,env,out,decision := Run(fs,args,flag,cb,C.Context(Source.Operation(),request.index,request.other),request.a,request.b,h,base);
  }
}
