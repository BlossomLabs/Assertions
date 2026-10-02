// SPDX-License-Identifier: MIT
include "Environment.dfy"
module CollectionsValueUniqueModel {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import S = CollectionsValueUniqueSpec
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import K = CollectionsCodecStateModel
  import ABI = AbiConstructionModel
  import VC = AbiConstructionContext
  import D = AbiDynamicSemantics
  import B = CollectionsBoundCallModel
  import R = CollectionsCallbackResultsModel
  import RM = CollectionsCallResultsModel
  import VM = CollectionsValidationModel
  import Wire = CollectionsWireModel
  datatype Config = Config(subject: S.Config,operation: seq<Byte>,fs: seq<Descriptor>,cb: C.Callback,base: C.Environment)
  function A(k: Config,i: nat,kept: seq<nat>,j: nat): seq<Byte>
    requires i < |k.subject.values| && S.Indices(k.subject,kept,i) && j < |kept|
  { k.subject.values[kept[j]] }
  function BArg(k: Config,i: nat): seq<Byte>
    requires i < |k.subject.values|
  { k.subject.values[i] }
  function Bound(k: Config,i: nat,kept: seq<nat>,j: nat,r1: VC.Result,r2: VC.Result): C.Environment
    requires i < |k.subject.values| && S.Indices(k.subject,kept,i) && j < |kept| && k.cb.first < |k.fs| && k.cb.second < |k.fs|
  { B.Environment(k.base,B.Query(k.fs,k.cb.first,A(k,i,kept,j)),r1,B.Query(k.fs,k.cb.second,BArg(k,i)),r2) }
  ghost predicate CallRoom(k: Config,i: nat,kept: seq<nat>,j: nat,p: P.Prepared,h: seq<C.Event>)
    requires i < |k.subject.values| && S.Indices(k.subject,kept,i) && j < |kept|
  {
    p.plan == K.Plan(k.fs) && Uint(|p.args|) && Admissible(Group(k.fs)) && Uint(|Render(Group(k.fs))|) && Uint(32*WidthSum(k.fs)) &&
    k.cb.descriptor == Render(Group(k.fs)) && k.cb.first < |k.fs| && k.cb.second < |k.fs| && k.cb.first != k.cb.second &&
    K.CanonicalExcept(k.fs,p.args,{k.cb.first,k.cb.second}) &&
    Uint(ABI.TotalBytes(p.args[k.cb.first := A(k,i,kept,j)][k.cb.second := BArg(k,i)])) &&
    (|k.cb.expression| > 0 ==> Wire.ExpressionReady(k.cb.expression,p.args[k.cb.first := A(k,i,kept,j)][k.cb.second := BArg(k,i)])) &&
    |k.operation| == 4 && Uint(i) && Uint(j) && |k.cb.selector| == 4 && k.cb.target < Pow256(20) &&
    Uint(k.cb.first) && Uint(k.cb.second) && Uint(|A(k,i,kept,j)|) && Uint(|BArg(k,i)|) &&
    Uint(32*Width(k.fs[k.cb.first])) && D.CursorRoom(k.fs[k.cb.first],|A(k,i,kept,j)|) &&
    Uint(32*Width(k.fs[k.cb.second])) && D.CursorRoom(k.fs[k.cb.second],|BArg(k,i)|) &&
    (forall r1: VC.Result,r2: VC.Result {:trigger Bound(k,i,kept,j,r1,r2)} ::
       var env := Bound(k,i,kept,j,r1,r2);
       C.Admitted(env) && C.Valid(k.cb,p,true) ==>
         RM.Room(C.Run(k.cb,p,C.Context(k.operation,i,j),A(k,i,kept,j),BArg(k,i),true,h,env),[],R.Context(k.operation,i,j,k.cb.target),true))
  }
  ghost opaque predicate CompareBudget(k: Config,i: nat,kept: seq<nat>,j: nat,p: P.Prepared,h: seq<C.Event>)
    requires i < |k.subject.values| && S.Indices(k.subject,kept,i) && j <= |kept|
    decreases |kept|-j
  {
    j == |kept| ||
    (CallRoom(k,i,kept,j,p,h) &&
     forall r1: VC.Result,r2: VC.Result {:trigger Bound(k,i,kept,j,r1,r2)} ::
       var env := Bound(k,i,kept,j,r1,r2);
       C.Admitted(env) && C.Valid(k.cb,p,true) &&
       r1.Success? == ABI.ValidInput(k.fs[k.cb.first],A(k,i,kept,j)) && r2.Success? == ABI.ValidInput(k.fs[k.cb.second],BArg(k,i)) ==>
         var called := C.Run(k.cb,p,C.Context(k.operation,i,j),A(k,i,kept,j),BArg(k,i),true,h,env);
         called.Returned? && RM.Reply(called,[],R.Context(k.operation,i,j,k.cb.target),true).Ok? && !RM.Reply(called,[],R.Context(k.operation,i,j,k.cb.target),true).truth ==>
           CompareBudget(k,i,kept,j+1,called.prepared,called.history))
  }
  predicate Constants(k: Config,a: seq<seq<Byte>>,b: seq<seq<Byte>>) {
    |a| == |b| && forall j :: 0 <= j < |a| && j != k.cb.first && j != k.cb.second ==> a[j] == b[j]
  }
  // Conservative future-state resources: no validation/predicate acceptance
  // is assumed, but both possible retained-index choices are provisioned.
  ghost opaque predicate Budget(k: Config,i: nat,kept: seq<nat>,p: P.Prepared,h: seq<C.Event>)
    requires S.Indices(k.subject,kept,i)
    decreases |k.subject.values|-i
  {
    i == |k.subject.values| ||
    (VM.Room(k.subject.inputType,k.subject.values[i]) &&
     (VM.Reply(T.Validate(k.subject.inputType,k.subject.values[i]),0,0).Ok? ==>
        CompareBudget(k,i,kept,S.Start(k.subject,kept),p,h) &&
        forall next: P.Prepared,history: seq<C.Event> {:trigger Budget(k,i+1,kept,next,history),Budget(k,i+1,kept+[i],next,history)} ::
          next.plan == K.Plan(k.fs) && K.CanonicalExcept(k.fs,next.args,{k.cb.first,k.cb.second}) && Constants(k,p.args,next.args) ==>
            Budget(k,i+1,kept,next,history) && Budget(k,i+1,kept+[i],next,history)))
  }

}
