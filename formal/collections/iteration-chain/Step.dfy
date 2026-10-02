// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsIterationChainStep {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import K = CollectionsCodecStateModel
  import ABI = AbiConstructionModel
  import D = AbiDynamicSemantics
  import VC = AbiConstructionContext
  import V = CollectionsValidationConnection
  import VM = CollectionsValidationModel
  import Call = CollectionsBoundCallConnection
  import B = CollectionsBoundCallModel
  import R = CollectionsCallbackResultsModel
  import Result = CollectionsCallResultsConnection
  import RM = CollectionsCallResultsModel
  import Wire = CollectionsWireModel
  import N = CollectionsIterationChainModel
  import M = CollectionsIterationModel

  ghost method Step(mode: T.Mode, inputType: seq<Byte>, outputType: seq<Byte>, value: seq<Byte>, index: nat, acc: seq<Byte>, operation: seq<Byte>, c: T.Context, fs: seq<Descriptor>, cb: C.Callback, args: seq<seq<Byte>>, flag: bool, h: seq<C.Event>, base: C.Environment)
    returns (env: T.Environment, out: T.Outcome, prepared: P.Prepared, calls: seq<C.Outcome>, lowHistory: seq<C.Event>, callEnv: C.Environment, firstReceipt: VC.Result, secondReceipt: VC.Result)
    requires Admissible(Group(fs)) && Uint(|Render(Group(fs))|) && Uint(32*WidthSum(fs))
    requires cb.descriptor == Render(Group(fs)) && cb.first < |fs| && (mode == T.Fold ==> cb.second < |fs| && cb.first != cb.second)
    requires K.CanonicalExcept(fs,args,if mode == T.Fold then {cb.first,cb.second} else {cb.first})
    requires Uint(|outputType|)
    requires VM.Room(inputType,value)
    requires Uint(|args|) && Uint(ABI.TotalBytes(if mode == T.Fold then args[cb.first := acc][cb.second := value] else args[cb.first := value]))
    requires |cb.expression| > 0 ==> Wire.ExpressionReady(cb.expression,if mode == T.Fold then args[cb.first := acc][cb.second := value] else args[cb.first := value])
    requires |operation| == 4 && Uint(index) && |cb.selector| == 4 && cb.target < Pow256(20)
    requires Uint(cb.first) && Uint(|M.A(mode,value,acc)|) && Uint(32*Width(fs[cb.first])) && D.CursorRoom(fs[cb.first],|M.A(mode,value,acc)|)
    requires mode == T.Fold ==> Uint(cb.second) && Uint(|value|) && Uint(32*Width(fs[cb.second])) && D.CursorRoom(fs[cb.second],|value|)
    requires M.AfterRoom(fs,args,flag,cb,C.Context(operation,index,0),M.A(mode,value,acc),M.BArg(mode,value),mode == T.Fold,h,base,outputType,mode == T.Filter)
    ensures |calls| == 1 ==> callEnv == B.Environment(base,B.Query(fs,cb.first,M.A(mode,value,acc)),firstReceipt,B.Query(fs,if mode == T.Fold then cb.second else cb.first,if mode == T.Fold then value else M.A(mode,value,acc)),secondReceipt)
    ensures |calls| == 1 ==> firstReceipt.Success? == ABI.ValidInput(fs[cb.first],M.A(mode,value,acc))
    ensures |calls| == 1 && mode == T.Fold ==> secondReceipt.Success? == ABI.ValidInput(fs[cb.second],value)
    ensures out.Success? ==> |calls| == 1 && RM.Reply(calls[0],outputType,R.Context(operation,index,0,cb.target),mode == T.Filter).Ok?
    ensures prepared.plan == K.Plan(fs)
    ensures |calls| <= 1
    ensures env == N.Environment(mode,inputType,outputType,value,index,acc,operation,cb.target,c,calls)
    ensures out == T.Step(mode,inputType,outputType,value,index,acc,c,env)
    ensures |calls| == 1 ==> C.Admitted(callEnv) && C.Valid(cb,P.Prepared(K.Plan(fs),args,flag),mode == T.Fold)
    ensures |calls| == 1 ==> calls[0] == C.Run(cb,P.Prepared(K.Plan(fs),args,flag),C.Context(operation,index,0),M.A(mode,value,acc),M.BArg(mode,value),mode == T.Fold,h,callEnv)
    ensures |calls| == 1 ==> callEnv.code == base.code && callEnv.call == base.call
    ensures prepared == (if |calls| == 0 then P.Prepared(K.Plan(fs),args,flag) else calls[0].prepared)
    ensures lowHistory == (if |calls| == 0 then h else calls[0].history)
    ensures (|calls| == 0) == VM.Reply(T.Validate(inputType,value),0,0).Error?
    ensures |out.context.history| == |c.history|+(if |calls| == 0 then 1 else if mode == T.Filter || RM.CallReply(calls[0],R.Context(operation,index,0,cb.target),mode == T.Filter).Error? then 2 else 3)
    ensures c.history <= out.context.history
    ensures out.context.history[|c.history|] == T.Validate(inputType,value)
    ensures |calls| == 0 ==> out.Failure? && |out.context.history| == |c.history|+1 && out.context.state == c.state
    ensures |calls| == 1 ==> out.context.history[|c.history|+1] == M.CallRequest(mode,value,index,acc) && out.context.state == c.state+1
    ensures out.Success? ==> |calls| == 1 && calls[0].Returned? && ABI.ValidInputs(fs,prepared.args) && prepared.targetChecked
    ensures out.Success? && mode != T.Filter ==> Uint(|outputType|)
    ensures out.Success? && mode != T.Filter ==> VM.Reply(T.ValidateResult(outputType,calls[0].value,index),ReadNat(operation),cb.target).Ok?
    ensures out.Success? && mode == T.Map ==> out.values == [calls[0].value] && out.accumulator == acc
    ensures out.Success? && mode == T.Fold ==> out.values == [] && out.accumulator == calls[0].value
    ensures out.Success? && mode == T.Filter ==> (out.values == [] || out.values == [value]) && out.accumulator == acc
  {
    var input := T.Validate(inputType,value);
    var call := M.CallRequest(mode,value,index,acc);
    var result := T.ValidateResult(outputType,[],index);
    var checked: VC.Result; var inputReply: T.Reply;
    checked,inputReply := V.Input(inputType,value);
    prepared := P.Prepared(K.Plan(fs),args,flag);
    calls := []; lowHistory := h; callEnv := base; firstReceipt := VC.Success; secondReceipt := VC.Success;
    env := M.Environment(c,input,inputReply,call,T.Error([]),result,T.Error([]));
    if inputReply.Error? {
      out := T.Failure(inputReply.reason,T.Context(c.state,c.history+[input]));
      return;
    }
    var r1; var r2; var called;
    r1,r2,callEnv,called := Call.Run(fs,args,flag,cb,C.Context(operation,index,0),M.A(mode,value,acc),M.BArg(mode,value),mode == T.Fold,h,base);
    firstReceipt := r1; secondReceipt := r2;
    calls := [called]; prepared := called.prepared; lowHistory := called.history;
    var context := R.Context(operation,index,0,cb.target);
    assert RM.Room(called,outputType,context,mode == T.Filter);
    var callReply; var checks; var reply;
    callReply,checks,reply := Result.Complete(called,outputType,context,mode == T.Filter);
    var resultReply := if |checks| > 0 then checks[0] else T.Error([]);
    if callReply.Ok? { result := T.ValidateResult(outputType,callReply.value,index); }
    env := M.Environment(c,input,inputReply,call,callReply,result,resultReply);
    var afterCall := T.Context(c.state+1,c.history+[input,call]);
    if callReply.Error? { out := T.Failure(callReply.reason,afterCall); return; }
    if mode == T.Filter {
      out := T.Success(if callReply.truth then [value] else [],acc,afterCall);
      return;
    }
    var afterResult := T.Context(c.state+1,c.history+[input,call,result]);
    if resultReply.Error? { out := T.Failure(resultReply.reason,afterResult); return; }
    out := if mode == T.Map then T.Success([callReply.value],acc,afterResult) else T.Success([],callReply.value,afterResult);
  }
}
