// SPDX-License-Identifier: MIT
include "../sort-comparator/Connection.dfy"
include "../value-sort-trace/Connection.dfy"
module CollectionsValueSortExecutionModel {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import Calls = CollectionsCallsConnection
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import K = CollectionsCodecStateModel
  import A = AbiConstructionModel
  import D = AbiDynamicSemantics
  import V = AbiConstructionContext
  import B = CollectionsBoundCallModel
  import Wire = CollectionsWireModel
  import R = CollectionsCallbackResultsModel
  import M = CollectionsSortComparatorModel
  import S = CollectionsSortComparatorSource
  import T = CollectionsValueSortTraceModel

  datatype Config = Config(values: seq<seq<Byte>>, fs: seq<Descriptor>, cb: C.Callback, base: C.Environment)
  predicate RequestIn(k: Config, q: T.Request) {
    q.a < |k.values| && q.b < |k.values| && q.left < |k.values| && q.right < |k.values|
  }
  function Context(q: T.Request): C.Context { C.Context(S.Operation(),q.a,q.b) }
  function Choice(d: M.Decision): T.Choice {
    if d.TakeLeft? then T.Chosen(d.value) else T.Rejected(d.reason)
  }
  ghost predicate LocalRoom(k: Config, p: P.Prepared, h: seq<C.Event>, q: T.Request)
    requires RequestIn(k,q)
  {
    p.plan == K.Plan(k.fs) &&
    Admissible(Group(k.fs)) && Uint(|Render(Group(k.fs))|) && Uint(32*WidthSum(k.fs)) &&
    k.cb.descriptor == Render(Group(k.fs)) && k.cb.first < |k.fs| && k.cb.second < |k.fs| && k.cb.first != k.cb.second &&
    K.CanonicalExcept(k.fs,p.args,{k.cb.first,k.cb.second}) &&
    Uint(|p.args|) && Uint(A.TotalBytes(p.args[k.cb.first := k.values[q.left]][k.cb.second := k.values[q.right]])) &&
    (|k.cb.expression| > 0 ==> Wire.ExpressionReady(k.cb.expression,p.args[k.cb.first := k.values[q.left]][k.cb.second := k.values[q.right]])) &&
    |k.cb.selector| == 4 && k.cb.target < Pow256(20) && Uint(q.a) && Uint(q.b) &&
    Uint(k.cb.first) && Uint(|k.values[q.left]|) && Uint(32*Width(k.fs[k.cb.first])) && D.CursorRoom(k.fs[k.cb.first],|k.values[q.left]|) &&
    Uint(k.cb.second) && Uint(|k.values[q.right]|) && Uint(32*Width(k.fs[k.cb.second])) && D.CursorRoom(k.fs[k.cb.second],|k.values[q.right]|) &&
    M.AfterRoom(k.fs,p.args,p.targetChecked,k.cb,Context(q),k.values[q.left],k.values[q.right],h,k.base)
  }
  // A finite resource envelope, for every possible bounded comparison request.
  // Neither canonical operands nor successful callbacks are assumed.
  ghost opaque predicate Budget(k: Config, fuel: nat, p: P.Prepared, h: seq<C.Event>)
    decreases fuel
  {
    fuel == 0 ||
    (forall q: T.Request :: RequestIn(k,q) ==>
                              LocalRoom(k,p,h,q) &&
                              forall r1: V.Result,r2: V.Result {:trigger B.Environment(k.base,B.Query(k.fs,k.cb.first,k.values[q.left]),r1,B.Query(k.fs,k.cb.second,k.values[q.right]),r2)} ::
                                var env := B.Environment(k.base,B.Query(k.fs,k.cb.first,k.values[q.left]),r1,B.Query(k.fs,k.cb.second,k.values[q.right]),r2);
                                C.Admitted(env) && C.Valid(k.cb,p,true) &&
                                (r1.Success? == A.ValidInput(k.fs[k.cb.first],k.values[q.left])) &&
                                (r2.Success? == A.ValidInput(k.fs[k.cb.second],k.values[q.right])) ==>
                                  var out := C.Run(k.cb,p,Context(q),k.values[q.left],k.values[q.right],true,h,env);
                                  var d := M.Judge(out,R.Context(S.Operation(),q.a,q.b,k.cb.target));
                                  d.TakeLeft? ==> Budget(k,fuel-1,out.prepared,out.history))
  }
  datatype Record = Record(request: T.Request, before: P.Prepared, history: seq<C.Event>, first: V.Result, second: V.Result, env: C.Environment, out: C.Outcome, decision: M.Decision)
  ghost opaque predicate Receipt(k: Config,r: Record) {
    RequestIn(k,r.request) && LocalRoom(k,r.before,r.history,r.request) &&
    C.Admitted(r.env) && C.Valid(k.cb,r.before,true) &&
    r.env == B.Environment(k.base,B.Query(k.fs,k.cb.first,k.values[r.request.left]),r.first,B.Query(k.fs,k.cb.second,k.values[r.request.right]),r.second) &&
    !r.first.Panic? && !r.second.Panic? &&
    (r.first.Success? == A.ValidInput(k.fs[k.cb.first],k.values[r.request.left])) &&
    (r.second.Success? == A.ValidInput(k.fs[k.cb.second],k.values[r.request.right])) &&
    r.out == C.Run(k.cb,r.before,Context(r.request),k.values[r.request.left],k.values[r.request.right],true,r.history,r.env) &&
    r.decision == M.Judge(r.out,R.Context(S.Operation(),r.request.a,r.request.b,k.cb.target)) &&
    r.out.prepared.plan == r.before.plan && r.history <= r.out.history &&
    Calls.Targets(r.out.history) == Calls.Targets(r.history)+(if r.before.targetChecked then [] else [k.cb.target]) &&
    |Calls.Calls(r.history)| <= |Calls.Calls(r.out.history)| <= |Calls.Calls(r.history)|+1 &&
    (r.out.Returned? ==> A.ValidInputs(k.fs,r.out.prepared.args) && r.out.prepared.targetChecked &&
                         r.out.prepared.args == r.before.args[k.cb.first := k.values[r.request.left]][k.cb.second := k.values[r.request.right]] &&
                         |Calls.Calls(r.out.history)| == |Calls.Calls(r.history)|+1)
  }
  ghost predicate Chain(k: Config,p: P.Prepared,h: seq<C.Event>,records: seq<Record>)
    decreases |records|
  {
    |records| == 0 ||
    (Receipt(k,records[0]) && records[0].before == p && records[0].history == h &&
     (if records[0].decision.Failure? then |records| == 1 else
      Chain(k,records[0].out.prepared,records[0].out.history,records[1..])))
  }
  function Rows(records: seq<Record>): seq<T.Row>
    ensures |Rows(records)| == |records|
    decreases |records|
  {
    if |records| == 0 then [] else [T.Row(records[0].request,Choice(records[0].decision))]+Rows(records[1..])
  }
  function FinalPrepared(p: P.Prepared,records: seq<Record>): P.Prepared {
    if |records| == 0 then p else records[|records|-1].out.prepared
  }
  function FinalHistory(h: seq<C.Event>,records: seq<Record>): seq<C.Event> {
    if |records| == 0 then h else records[|records|-1].out.history
  }
  function Splice(choice: T.Choice, next: T.Environment, cut: nat): T.Environment {
    (trace: seq<T.Row>,q: T.Request) => if |trace| < cut then choice else next(trace,q)
  }
  ghost predicate Future(a: T.Environment,b: T.Environment,cut: nat) {
    forall t: seq<T.Row>,q: T.Request :: |t| >= cut ==> a(t,q) == b(t,q)
  }
  ghost predicate Window(a: T.Environment,b: T.Environment,start: nat,end: nat) {
    forall t: seq<T.Row>,q: T.Request :: start <= |t| < end ==> a(t,q) == b(t,q)
  }
  function Join(earlier: T.Environment,later: T.Environment,cut: nat): T.Environment {
    (trace: seq<T.Row>,q: T.Request) => if |trace| < cut then earlier(trace,q) else later(trace,q)
  }

}
