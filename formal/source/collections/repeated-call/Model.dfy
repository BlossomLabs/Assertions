// SPDX-License-Identifier: MIT
include "../bound-call/Connection.dfy"
module CollectionsRepeatedCallModel {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiByteSemantics
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import A = AbiConstructionModel
  import D = AbiDynamicSemantics
  import W = CollectionsWireModel

  datatype Step = Step(a: seq<Byte>, b: seq<Byte>, context: C.Context)
  datatype Record = Record(before: P.Prepared, history: seq<C.Event>, env: C.Environment, out: C.Outcome)
  function Replace(cb: C.Callback, args: seq<seq<Byte>>, step: Step, binary: bool): seq<seq<Byte>>
    requires cb.first < |args| && (binary ==> cb.second < |args| && cb.first != cb.second)
  { if binary then args[cb.first := step.a][cb.second := step.b] else args[cb.first := step.a] }
  ghost predicate Room(fs: seq<Descriptor>, cb: C.Callback, args: seq<seq<Byte>>, steps: seq<Step>, binary: bool)
    requires cb.first < |fs| && |args| == |fs| && (binary ==> cb.second < |fs| && cb.first != cb.second)
  {
    Uint(|args|) && (forall i :: 0 <= i < |steps| ==>
                                   Uint(cb.first) && Uint(|steps[i].a|) && Uint(32*Width(fs[cb.first])) && D.CursorRoom(fs[cb.first],|steps[i].a|) &&
                                   (binary ==> Uint(cb.second) && Uint(|steps[i].b|) && Uint(32*Width(fs[cb.second])) && D.CursorRoom(fs[cb.second],|steps[i].b|)) &&
                                   Uint(A.TotalBytes(Replace(cb,args,steps[i],binary))) &&
                                   (|cb.expression| > 0 ==> W.ExpressionReady(cb.expression,Replace(cb,args,steps[i],binary))) &&
                                   |steps[i].context.operation| == 4 && Uint(steps[i].context.index) && Uint(steps[i].context.other))
  }
  ghost predicate Chain(cb: C.Callback, steps: seq<Step>, binary: bool, p: P.Prepared, h: seq<C.Event>, records: seq<Record>)
    decreases |records|
  {
    if |records| == 0 then |steps| == 0 else
    |steps| > 0 && records[0].before == p && records[0].history == h &&
    C.Admitted(records[0].env) && C.Valid(cb,p,binary) &&
    records[0].out == C.Run(cb,p,steps[0].context,steps[0].a,steps[0].b,binary,h,records[0].env) &&
    (if records[0].out.Failed? then |records| == 1 else
     Chain(cb,steps[1..],binary,records[0].out.prepared,records[0].out.history,records[1..]))
  }
  function FinalState(records: seq<Record>, p: P.Prepared): P.Prepared {
    if |records| == 0 then p else records[|records|-1].out.prepared
  }
  function FinalHistory(records: seq<Record>, h: seq<C.Event>): seq<C.Event> {
    if |records| == 0 then h else records[|records|-1].out.history
  }
  predicate Success(records: seq<Record>) { forall i :: 0 <= i < |records| ==> records[i].out.Returned? }
}
