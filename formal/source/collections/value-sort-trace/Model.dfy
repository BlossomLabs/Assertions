// SPDX-License-Identifier: MIT
include "../sort-core/Connection.dfy"
include "../../abi/Frames.dfy"
module CollectionsValueSortTraceModel {
  import opened AbiFrames
  import Core = CollectionsSortModel
  predicate CountRoom(n: nat) { 32*n < Pow256(32) }
  datatype Request = Request(a: nat,b: nat,left: nat,right: nat)
  datatype Choice = Chosen(left: bool) | Rejected(reason: seq<Byte>)
  datatype Row = Row(request: Request,choice: Choice)
  type Environment = (seq<Row>,Request)->Choice
  datatype Outcome = Success(ids: seq<nat>,trace: seq<Row>) | Failure(reason: seq<Byte>,trace: seq<Row>)
  function Prepend(prefix: seq<nat>,out: Outcome): Outcome {
    if out.Failure? then out else Success(prefix+out.ids,out.trace)
  }
  predicate Coherent(trace: seq<Row>,le: (nat,nat)->bool) {
    forall i :: 0 <= i < |trace| && trace[i].choice.Chosen? ==>
                  trace[i].choice.left == le(trace[i].request.left,trace[i].request.right)
  }
  predicate Clear(trace: seq<Row>) {
    forall i :: 0 <= i < |trace| ==> trace[i].choice.Chosen?
  }
  predicate Extends(before: seq<Row>,after: seq<Row>,env: Environment) {
    before <= after && (forall i :: |before| <= i < |after| ==> after[i].choice == env(after[..i],after[i].request))
  }
  predicate Stopped(out: Outcome) {
    if out.Success? then Clear(out.trace) else
    |out.trace| > 0 && Clear(out.trace[..|out.trace|-1]) && out.trace[|out.trace|-1].choice == Rejected(out.reason)
  }
  function Merge(source: seq<nat>,middle: nat,end: nat,a: nat,b: nat,trace: seq<Row>,env: Environment): Outcome
    requires a <= middle <= b <= end <= |source|
    ensures Merge(source,middle,end,a,b,trace,env).Success? ==> |Merge(source,middle,end,a,b,trace,env).ids| == middle-a+end-b
    decreases (middle-a)+(end-b)
  {
    if a == middle then Success(source[b..end],trace) else
    if b == end then Success(source[a..middle],trace) else
    var q := Request(a,b,source[a],source[b]); var choice := env(trace,q); var next := trace+[Row(q,choice)];
                                                                           if choice.Rejected? then Failure(choice.reason,next) else
                                                                           if choice.left then Prepend([source[a]],Merge(source,middle,end,a+1,b,next,env))
                                                                           else Prepend([source[b]],Merge(source,middle,end,a,b+1,next,env))
  }
  function Pass(source: seq<nat>,width: nat,start: nat,trace: seq<Row>,env: Environment): Outcome
    requires width > 0
    ensures Pass(source,width,start,trace,env).Success? ==> |Pass(source,width,start,trace,env).ids| == |source|-Core.Min(start,|source|)
    decreases |source|-start
  {
    if start >= |source| then Success([],trace) else
    var middle := Core.Min(start+width,|source|); var end := Core.Min(start+2*width,|source|);
                                                  var first := Merge(source,middle,end,start,middle,trace,env);
                                                  if first.Failure? then first else Prepend(first.ids,Pass(source,width,start+2*width,first.trace,env))
  }
  function Sort(source: seq<nat>,width: nat,trace: seq<Row>,env: Environment): Outcome
    requires width > 0
    ensures Sort(source,width,trace,env).Success? ==> |Sort(source,width,trace,env).ids| == |source|
    decreases |source|-width
  {
    if width >= |source| then Success(source,trace) else
    var pass := Pass(source,width,0,trace,env);
    if pass.Failure? then pass else Sort(pass.ids,2*width,pass.trace,env)
  }
}
