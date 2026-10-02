// SPDX-License-Identifier: MIT
include "../guarded/Connection.dfy"
module ExpressionFramesModel {
  import opened ExpressionEvaluationControl
  import S = ExpressionRecursiveSpec
  datatype Frame = Frame(index: nat, memo: map<nat,Value>, history: seq<Request>, guardOwner: int)
  predicate Origin(nodes: seq<Node>, index: nat, owner: int) {
    owner == -1 || (index < owner < |nodes| && nodes[owner].kind in {TryOrElse,IsValid} &&
                    |nodes[owner].refs| > 0 && nodes[owner].refs[0] == index)
  }
  predicate Safe(nodes: seq<Node>, valid: (nat,Value)->bool, initial: map<nat,Value>,
                 history: seq<Request>, bound: nat, frames: seq<Frame>) {
    forall f <- frames :: f.index <= bound && f.index < |nodes| && Origin(nodes,f.index,f.guardOwner) &&
                          Good(nodes,valid,f.memo) && Extends(initial,f.memo) && history <= f.history
  }
  lemma Append(nodes: seq<Node>, valid: (nat,Value)->bool, initial: map<nat,Value>,
               history: seq<Request>, bound: nat, frames: seq<Frame>, childInitial: map<nat,Value>,
               childHistory: seq<Request>, childBound: nat, children: seq<Frame>)
    requires Safe(nodes,valid,initial,history,bound,frames)
    requires Safe(nodes,valid,childInitial,childHistory,childBound,children)
    requires Extends(initial,childInitial) && history <= childHistory && childBound < bound
    ensures Safe(nodes,valid,initial,history,bound,frames+children)
  {
    forall f | f in children
      ensures Extends(initial,f.memo)
    {
      forall i | i in initial
        ensures i in f.memo && f.memo[i] == initial[i]
      {}
    }
  }
  ghost function Trace(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool,
                       reject: (nat,Value)->Error, oracle: (Request,seq<Request>)->Raw,
                       index: nat, memo: map<nat,Value>, history: seq<Request>, owner: int): seq<Frame>
    requires Program(nodes) && index < |nodes|
    decreases index,2,0
  {
    [Frame(index,memo,history,owner)] +
    (if index in memo then [] else BodyTrace(nodes,valid,truth,reject,oracle,index,memo,history))
  }
  ghost function BodyTrace(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool,
                           reject: (nat,Value)->Error, oracle: (Request,seq<Request>)->Raw,
                           index: nat, memo: map<nat,Value>, history: seq<Request>): seq<Frame>
    requires Program(nodes) && index < |nodes|
    decreases index,1,0
  {
    var node := nodes[index];
    if node.kind == Select then
      var cond := S.Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      Trace(nodes,valid,truth,reject,oracle,node.refs[0],memo,history,-1) +
      (if cond.Failure? then [] else
       Trace(nodes,valid,truth,reject,oracle,node.refs[if truth(cond.value) then 1 else 2],cond.memo,cond.history,-1))
    else if node.kind in {TryOrElse,IsValid} then
      var attempted := S.Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      var prefix := Trace(nodes,valid,truth,reject,oracle,node.refs[0],memo,history,index);
      if attempted.Success? || node.kind == IsValid then prefix else
      var classified := S.Invoke(Request(index,GuardFailure,[attempted.error.payload]),oracle,memo,attempted.history);
      prefix + (if classified.Failure? then [] else
                Trace(nodes,valid,truth,reject,oracle,node.refs[1],memo,classified.history,-1))
    else GatherTrace(nodes,valid,truth,reject,oracle,index,0,memo,history)
  }
  ghost function GatherTrace(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool,
                             reject: (nat,Value)->Error, oracle: (Request,seq<Request>)->Raw,
                             index: nat, pos: nat, memo: map<nat,Value>, history: seq<Request>): seq<Frame>
    requires Program(nodes) && index < |nodes| && pos <= |nodes[index].refs|
    decreases index,0,|nodes[index].refs|-pos
  {
    if pos == |nodes[index].refs| then [] else
    var childIndex := nodes[index].refs[pos];
    var child := S.Evaluate(nodes,valid,truth,reject,oracle,childIndex,memo,history);
    var prefix := Trace(nodes,valid,truth,reject,oracle,childIndex,memo,history,-1);
    if child.Failure? then prefix else
    var checked := if pos == 0 && nodes[index].kind in {Call,ProbeCall}
                   then S.Invoke(Request(index,Address,[child.value]),oracle,child.memo,child.history) else child;
    prefix + (if checked.Failure? then [] else
              GatherTrace(nodes,valid,truth,reject,oracle,index,pos+1,child.memo,checked.history))
  }

}
