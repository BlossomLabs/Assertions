// SPDX-License-Identifier: MIT
include "Environment.dfy"
module CollectionsValueSearchModel {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import S = CollectionsValueSearchSpec
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import K = CollectionsCodecStateModel
  import ABI = AbiConstructionModel
  import D = AbiDynamicSemantics
  import VC = AbiConstructionContext
  import VM = CollectionsValidationModel
  import B = CollectionsBoundCallModel
  import R = CollectionsCallbackResultsModel
  import RM = CollectionsCallResultsModel
  import Wire = CollectionsWireModel
  import M = CollectionsIterationModel
  datatype Config = Config(subject: S.Config,operation: seq<Byte>,fs: seq<Descriptor>,cb: C.Callback,base: C.Environment)
  ghost predicate AfterRoom(k: Config,index: nat,p: P.Prepared,h: seq<C.Event>)
    requires index < |k.subject.values| && k.cb.first < |k.fs| && (S.Binary(k.subject) ==> k.cb.second < |k.fs|)
  {
    forall r1: VC.Result,r2: VC.Result {:trigger B.Environment(k.base,B.Query(k.fs,k.cb.first,k.subject.values[index]),r1,B.Query(k.fs,if S.Binary(k.subject) then k.cb.second else k.cb.first,if S.Binary(k.subject) then k.subject.needle else k.subject.values[index]),r2)} ::
      var env := B.Environment(k.base,B.Query(k.fs,k.cb.first,k.subject.values[index]),r1,B.Query(k.fs,if S.Binary(k.subject) then k.cb.second else k.cb.first,if S.Binary(k.subject) then k.subject.needle else k.subject.values[index]),r2);
      C.Admitted(env) && C.Valid(k.cb,p,S.Binary(k.subject)) ==>
        RM.Room(C.Run(k.cb,p,C.Context(k.operation,index,0),k.subject.values[index],if S.Binary(k.subject) then k.subject.needle else [],S.Binary(k.subject),h,env),[],R.Context(k.operation,index,0,k.cb.target),true)
  }
  ghost predicate LocalRoom(k: Config, index: nat, p: P.Prepared, h: seq<C.Event>)
    requires index < |k.subject.values|
  {
    p.plan == K.Plan(k.fs) &&
    (Admissible(Group(k.fs)) && Uint(|Render(Group(k.fs))|) && Uint(32*WidthSum(k.fs))) &&
    (k.cb.descriptor == Render(Group(k.fs)) && k.cb.first < |k.fs| && (S.Binary(k.subject) ==> k.cb.second < |k.fs| && k.cb.first != k.cb.second)) &&
    (K.CanonicalExcept(k.fs,p.args,if S.Binary(k.subject) then {k.cb.first,k.cb.second} else {k.cb.first})) &&
    (VM.Room(k.subject.inputType,k.subject.values[index])) &&
    (Uint(|p.args|) && Uint(ABI.TotalBytes(if S.Binary(k.subject) then p.args[k.cb.first := k.subject.values[index]][k.cb.second := k.subject.needle] else p.args[k.cb.first := k.subject.values[index]]))) &&
    (|k.cb.expression| > 0 ==> Wire.ExpressionReady(k.cb.expression,if S.Binary(k.subject) then p.args[k.cb.first := k.subject.values[index]][k.cb.second := k.subject.needle] else p.args[k.cb.first := k.subject.values[index]])) &&
    (|k.operation| == 4 && Uint(index) && |k.cb.selector| == 4 && k.cb.target < Pow256(20)) &&
    (Uint(k.cb.first) && Uint(|k.subject.values[index]|) && Uint(32*Width(k.fs[k.cb.first])) && D.CursorRoom(k.fs[k.cb.first],|k.subject.values[index]|)) &&
    (S.Binary(k.subject) ==> Uint(k.cb.second) && Uint(|k.subject.needle|) && Uint(32*Width(k.fs[k.cb.second])) && D.CursorRoom(k.fs[k.cb.second],|k.subject.needle|)) &&
    (AfterRoom(k,index,p,h))
  }
  // Resources only along continuing executions; no success is assumed.
  // Receipt guards rule out accepting noncanonical substituted operands.
  ghost opaque predicate Budget(k: Config, index: nat, p: P.Prepared, h: seq<C.Event>)
    requires index <= |k.subject.values|
    decreases |k.subject.values|-index
  {
    index == |k.subject.values| ||
    (LocalRoom(k,index,p,h) &&
     forall r1: VC.Result, r2: VC.Result {:trigger B.Environment(k.base,B.Query(k.fs,k.cb.first,k.subject.values[index]),r1,B.Query(k.fs,if S.Binary(k.subject) then k.cb.second else k.cb.first,if S.Binary(k.subject) then k.subject.needle else k.subject.values[index]),r2)} ::
       var env := B.Environment(k.base,B.Query(k.fs,k.cb.first,k.subject.values[index]),r1,B.Query(k.fs,if S.Binary(k.subject) then k.cb.second else k.cb.first,if S.Binary(k.subject) then k.subject.needle else k.subject.values[index]),r2);
       C.Admitted(env) && C.Valid(k.cb,p,S.Binary(k.subject)) &&
       VM.Reply(T.Validate(k.subject.inputType,k.subject.values[index]),0,0).Ok? &&
       r1.Success? == ABI.ValidInput(k.fs[k.cb.first],k.subject.values[index]) &&
       (S.Binary(k.subject) ==> r2.Success? == ABI.ValidInput(k.fs[k.cb.second],k.subject.needle)) ==>
         var out := C.Run(k.cb,p,C.Context(k.operation,index,0),k.subject.values[index],(if S.Binary(k.subject) then k.subject.needle else []),S.Binary(k.subject),h,env);
         out.Returned? && RM.Reply(out,[],R.Context(k.operation,index,0,k.cb.target),true).Ok? &&
         RM.Reply(out,[],R.Context(k.operation,index,0,k.cb.target),true).truth != S.Wanted(k.subject) ==>
           Budget(k,index+1,out.prepared,out.history))
  }

}
