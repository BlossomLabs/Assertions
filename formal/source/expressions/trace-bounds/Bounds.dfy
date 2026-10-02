// SPDX-License-Identifier: MIT
include "../context/Connection.dfy"
module ExpressionTraceBounds {
  import opened ExpressionEvaluationControl
  import S = ExpressionRecursiveSpec
  import F = ExpressionFramesModel
  import H = ExpressionOracleStability

  ghost predicate Within(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                         oracle: (Request,seq<Request>)->Raw, frames: seq<F.Frame>, start: seq<Request>, end: seq<Request>)
    requires Program(nodes)
  {
    forall f <- frames :: f.index < |nodes| && start <= f.history &&
                          f.history <= S.Evaluate(nodes,valid,truth,reject,oracle,f.index,f.memo,f.history).history &&
                          S.Evaluate(nodes,valid,truth,reject,oracle,f.index,f.memo,f.history).history <= end
  }
  lemma Widen(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
              oracle: (Request,seq<Request>)->Raw, frames: seq<F.Frame>, start: seq<Request>, end: seq<Request>,
              earlier: seq<Request>, later: seq<Request>)
    requires Program(nodes) && Within(nodes,valid,truth,reject,oracle,frames,start,end)
    requires earlier <= start && end <= later
    ensures Within(nodes,valid,truth,reject,oracle,frames,earlier,later)
  {}

  lemma Evaluate(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                 oracle: (Request,seq<Request>)->Raw, index: nat, memo: map<nat,Value>, history: seq<Request>, owner: int)
    requires Program(nodes) && index < |nodes|
    ensures Within(nodes,valid,truth,reject,oracle,F.Trace(nodes,valid,truth,reject,oracle,index,memo,history,owner),
                   history,S.Evaluate(nodes,valid,truth,reject,oracle,index,memo,history).history)
    decreases index,2,0
  {
    H.EvaluateHistory(nodes,valid,truth,reject,oracle,index,memo,history);
    if index !in memo { Body(nodes,valid,truth,reject,oracle,index,memo,history); }
  }
  lemma Body(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
             oracle: (Request,seq<Request>)->Raw, index: nat, memo: map<nat,Value>, history: seq<Request>)
    requires Program(nodes) && index < |nodes|
    ensures Within(nodes,valid,truth,reject,oracle,F.BodyTrace(nodes,valid,truth,reject,oracle,index,memo,history),
                   history,S.Body(nodes,valid,truth,reject,oracle,index,memo,history).history)
    decreases index,1,0
  {
    var node := nodes[index];
    var end := S.Body(nodes,valid,truth,reject,oracle,index,memo,history).history;
    if node.kind == Select {
      Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history,-1);
      var cond := S.Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      if cond.Success? {
        var branch := node.refs[if truth(cond.value) then 1 else 2];
        Evaluate(nodes,valid,truth,reject,oracle,branch,cond.memo,cond.history,-1);
        H.EvaluateHistory(nodes,valid,truth,reject,oracle,branch,cond.memo,cond.history);
        Widen(nodes,valid,truth,reject,oracle,F.Trace(nodes,valid,truth,reject,oracle,branch,cond.memo,cond.history,-1),cond.history,end,history,end);
      }
      Widen(nodes,valid,truth,reject,oracle,F.Trace(nodes,valid,truth,reject,oracle,node.refs[0],memo,history,-1),history,cond.history,history,end);
    } else if node.kind in {TryOrElse,IsValid} {
      Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history,index);
      var attempted := S.Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      var classified := if attempted.Success? then attempted else S.Invoke(Request(index,GuardFailure,[attempted.error.payload]),oracle,memo,attempted.history);
      if node.kind == TryOrElse && attempted.Failure? && classified.Success? {
        Evaluate(nodes,valid,truth,reject,oracle,node.refs[1],memo,classified.history,-1);
        H.EvaluateHistory(nodes,valid,truth,reject,oracle,node.refs[1],memo,classified.history);
        Widen(nodes,valid,truth,reject,oracle,F.Trace(nodes,valid,truth,reject,oracle,node.refs[1],memo,classified.history,-1),classified.history,end,history,end);
      }
      Widen(nodes,valid,truth,reject,oracle,F.Trace(nodes,valid,truth,reject,oracle,node.refs[0],memo,history,index),history,attempted.history,history,end);
    } else {
      Gather(nodes,valid,truth,reject,oracle,index,0,[],memo,history);
      var args := S.Gather(nodes,valid,truth,reject,oracle,index,0,[],memo,history);
      Widen(nodes,valid,truth,reject,oracle,F.GatherTrace(nodes,valid,truth,reject,oracle,index,0,memo,history),history,args.history,history,end);
    }
  }
  lemma Gather(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
               oracle: (Request,seq<Request>)->Raw, index: nat, pos: nat, values: seq<Value>,
               memo: map<nat,Value>, history: seq<Request>)
    requires Program(nodes) && index < |nodes| && pos <= |nodes[index].refs|
    ensures Within(nodes,valid,truth,reject,oracle,F.GatherTrace(nodes,valid,truth,reject,oracle,index,pos,memo,history),
                   history,S.Gather(nodes,valid,truth,reject,oracle,index,pos,values,memo,history).history)
    decreases index,0,|nodes[index].refs|-pos
  {
    if pos < |nodes[index].refs| {
      var childIndex := nodes[index].refs[pos];
      Evaluate(nodes,valid,truth,reject,oracle,childIndex,memo,history,-1);
      var child := S.Evaluate(nodes,valid,truth,reject,oracle,childIndex,memo,history);
      var end := S.Gather(nodes,valid,truth,reject,oracle,index,pos,values,memo,history).history;
      if child.Success? {
        var checked := if pos == 0 && nodes[index].kind in {Call,ProbeCall}
        then S.Invoke(Request(index,Address,[child.value]),oracle,child.memo,child.history) else child;
        if checked.Success? {
          Gather(nodes,valid,truth,reject,oracle,index,pos+1,values+[child.value],child.memo,checked.history);
          H.GatherHistory(nodes,valid,truth,reject,oracle,index,pos+1,values+[child.value],child.memo,checked.history);
          Widen(nodes,valid,truth,reject,oracle,F.GatherTrace(nodes,valid,truth,reject,oracle,index,pos+1,child.memo,checked.history),checked.history,end,history,end);
        }
      }
      Widen(nodes,valid,truth,reject,oracle,F.Trace(nodes,valid,truth,reject,oracle,childIndex,memo,history,-1),history,child.history,history,end);
    }
  }
}
