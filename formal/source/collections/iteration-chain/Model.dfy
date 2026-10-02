// SPDX-License-Identifier: MIT
include "../iteration/Connection.dfy"
include "../environment/Connection.dfy"
module CollectionsIterationChainModel {
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
  import M = CollectionsIterationModel


  datatype Config = Config(mode: T.Mode, inputType: seq<Byte>, outputType: seq<Byte>, values: seq<seq<Byte>>, operation: seq<Byte>, fs: seq<Descriptor>, cb: C.Callback, base: C.Environment)
  ghost predicate LocalRoom(k: Config, index: nat, acc: seq<Byte>, p: P.Prepared, h: seq<C.Event>)
    requires index < |k.values|
  {
    p.plan == K.Plan(k.fs) && Uint(|k.outputType|) &&
    (Admissible(Group(k.fs)) && Uint(|Render(Group(k.fs))|) && Uint(32*WidthSum(k.fs))) &&
    (k.cb.descriptor == Render(Group(k.fs)) && k.cb.first < |k.fs| && (k.mode == T.Fold ==> k.cb.second < |k.fs| && k.cb.first != k.cb.second)) &&
    (K.CanonicalExcept(k.fs,p.args,if k.mode == T.Fold then {k.cb.first,k.cb.second} else {k.cb.first})) &&
    (VM.Room(k.inputType,k.values[index])) &&
    (Uint(|p.args|) && Uint(ABI.TotalBytes(if k.mode == T.Fold then p.args[k.cb.first := acc][k.cb.second := k.values[index]] else p.args[k.cb.first := k.values[index]]))) &&
    (|k.cb.expression| > 0 ==> Wire.ExpressionReady(k.cb.expression,if k.mode == T.Fold then p.args[k.cb.first := acc][k.cb.second := k.values[index]] else p.args[k.cb.first := k.values[index]])) &&
    (|k.operation| == 4 && Uint(index) && |k.cb.selector| == 4 && k.cb.target < Pow256(20)) &&
    (Uint(k.cb.first) && Uint(|M.A(k.mode,k.values[index],acc)|) && Uint(32*Width(k.fs[k.cb.first])) && D.CursorRoom(k.fs[k.cb.first],|M.A(k.mode,k.values[index],acc)|)) &&
    (k.mode == T.Fold ==> Uint(k.cb.second) && Uint(|k.values[index]|) && Uint(32*Width(k.fs[k.cb.second])) && D.CursorRoom(k.fs[k.cb.second],|k.values[index]|)) &&
    (M.AfterRoom(k.fs,p.args,p.targetChecked,k.cb,C.Context(k.operation,index,0),M.A(k.mode,k.values[index],acc),M.BArg(k.mode,k.values[index]),k.mode == T.Fold,h,k.base,k.outputType,k.mode == T.Filter))
  }
  // Resources only along continuing executions; no success is assumed.
  // Receipt guards rule out accepting noncanonical substituted operands.
  ghost opaque predicate Budget(k: Config, index: nat, acc: seq<Byte>, p: P.Prepared, h: seq<C.Event>)
    requires index <= |k.values|
    decreases |k.values|-index
  {
    index == |k.values| ||
    (LocalRoom(k,index,acc,p,h) &&
     forall r1: VC.Result, r2: VC.Result {:trigger B.Environment(k.base,B.Query(k.fs,k.cb.first,M.A(k.mode,k.values[index],acc)),r1,B.Query(k.fs,if k.mode == T.Fold then k.cb.second else k.cb.first,if k.mode == T.Fold then k.values[index] else M.A(k.mode,k.values[index],acc)),r2)} ::
       var env := B.Environment(k.base,B.Query(k.fs,k.cb.first,M.A(k.mode,k.values[index],acc)),r1,B.Query(k.fs,if k.mode == T.Fold then k.cb.second else k.cb.first,if k.mode == T.Fold then k.values[index] else M.A(k.mode,k.values[index],acc)),r2);
       C.Admitted(env) && C.Valid(k.cb,p,k.mode == T.Fold) &&
       VM.Reply(T.Validate(k.inputType,k.values[index]),0,0).Ok? &&
       r1.Success? == ABI.ValidInput(k.fs[k.cb.first],M.A(k.mode,k.values[index],acc)) &&
       (k.mode == T.Fold ==> r2.Success? == ABI.ValidInput(k.fs[k.cb.second],k.values[index])) ==>
         var out := C.Run(k.cb,p,C.Context(k.operation,index,0),M.A(k.mode,k.values[index],acc),M.BArg(k.mode,k.values[index]),k.mode == T.Fold,h,env);
         out.Returned? && RM.Reply(out,k.outputType,R.Context(k.operation,index,0,k.cb.target),k.mode == T.Filter).Ok? ==>
           Budget(k,index+1,if k.mode == T.Fold then out.value else acc,out.prepared,out.history))
  }

  ghost function Environment(mode: T.Mode, inputType: seq<Byte>, outputType: seq<Byte>, value: seq<Byte>, index: nat, acc: seq<Byte>, operation: seq<Byte>, target: nat, c: T.Context, calls: seq<C.Outcome>): T.Environment
    requires Uint(|inputType|) && Uint(|outputType|) && |calls| <= 1
  {
    var input := T.Validate(inputType,value);
    var inputReply := VM.Reply(input,0,0);
    var call := M.CallRequest(mode,value,index,acc);
    if |calls| == 0 then M.Environment(c,input,inputReply,call,T.Error([]),T.ValidateResult(outputType,[],index),T.Error([])) else
    var context := R.Context(operation,index,0,target);
    var callReply := RM.CallReply(calls[0],context,mode == T.Filter);
    var checks := RM.Checks(calls[0],outputType,context,mode == T.Filter);
    var result := T.ValidateResult(outputType,if callReply.Ok? then callReply.value else [],index);
    M.Environment(c,input,inputReply,call,callReply,result,if |checks| > 0 then checks[0] else T.Error([]))
  }

  datatype Record = Record(before: P.Prepared, history: seq<C.Event>, prepared: P.Prepared, lowHistory: seq<C.Event>, calls: seq<C.Outcome>, env: C.Environment, first: VC.Result, second: VC.Result)
  ghost opaque predicate RecordAt(k: Config, index: nat, acc: seq<Byte>, p: P.Prepared, h: seq<C.Event>, r: Record)
    requires index < |k.values|
  {
    LocalRoom(k,index,acc,p,h) && r.before == p && r.history == h && |r.calls| <= 1 &&
    (|r.calls| == 0) == VM.Reply(T.Validate(k.inputType,k.values[index]),0,0).Error? &&
    r.prepared == (if |r.calls| == 0 then p else r.calls[0].prepared) &&
    r.lowHistory == (if |r.calls| == 0 then h else r.calls[0].history) &&
    (|r.calls| == 1 ==>
       C.Admitted(r.env) && C.Valid(k.cb,p,k.mode == T.Fold) &&
       r.env == B.Environment(k.base,B.Query(k.fs,k.cb.first,M.A(k.mode,k.values[index],acc)),r.first,B.Query(k.fs,if k.mode == T.Fold then k.cb.second else k.cb.first,if k.mode == T.Fold then k.values[index] else M.A(k.mode,k.values[index],acc)),r.second) &&
       r.first.Success? == ABI.ValidInput(k.fs[k.cb.first],M.A(k.mode,k.values[index],acc)) &&
       (k.mode == T.Fold ==> r.second.Success? == ABI.ValidInput(k.fs[k.cb.second],k.values[index])) &&
       r.calls[0] == C.Run(k.cb,p,C.Context(k.operation,index,0),M.A(k.mode,k.values[index],acc),M.BArg(k.mode,k.values[index]),k.mode == T.Fold,h,r.env))
  }
  import E = CollectionsEnvironmentModel
  ghost predicate Trace(k: Config, index: nat, acc: seq<Byte>, c: T.Context, p: P.Prepared, h: seq<C.Event>, rows: seq<E.Row>, records: seq<Record>)
    requires index <= |k.values|
    decreases |k.values|-index
  {
    E.Chain(k.mode,k.inputType,k.outputType,k.values,index,acc,c,rows) && |records| == |rows| &&
    (index < |k.values| ==>
       RecordAt(k,index,acc,p,h,records[0]) &&
       Uint(|k.inputType|) && Uint(|k.outputType|) && |records[0].calls| <= 1 &&
       rows[0].env == Environment(k.mode,k.inputType,k.outputType,k.values[index],index,acc,k.operation,k.cb.target,c,records[0].calls) &&
       (rows[0].out.Success? ==>
          |records[0].calls| == 1 && records[0].calls[0].Returned? &&
          ABI.ValidInputs(k.fs,records[0].prepared.args) && records[0].prepared.targetChecked &&
          rows[0].out.accumulator == (if k.mode == T.Fold then records[0].calls[0].value else acc) &&
          Trace(k,index+1,rows[0].out.accumulator,rows[0].out.context,records[0].prepared,records[0].lowHistory,rows[1..],records[1..])))
  }
  function FinalPrepared(p: P.Prepared, records: seq<Record>): P.Prepared {
    if |records| == 0 then p else records[|records|-1].prepared
  }
  function FinalHistory(h: seq<C.Event>, records: seq<Record>): seq<C.Event> {
    if |records| == 0 then h else records[|records|-1].lowHistory
  }
}
