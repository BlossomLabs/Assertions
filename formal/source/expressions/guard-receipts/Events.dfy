// SPDX-License-Identifier: MIT
include "../trace-bounds/Connection.dfy"
module ExpressionGuardReceiptEvents {
  import opened ExpressionEvaluationControl
  import S = ExpressionRecursiveSpec
  import F = ExpressionFramesModel
  import H = ExpressionOracleStability
  import Bounds = ExpressionTraceBounds

  ghost predicate Events(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                         oracle: (Request,seq<Request>)->Raw, frames: seq<F.Frame>, end: seq<Request>)
    requires Program(nodes)
  {
    forall f <- frames :: f.index < |nodes| &&
                          (f.guardOwner >= 0 ==>
                             var attempt := S.Evaluate(nodes,valid,truth,reject,oracle,f.index,f.memo,f.history);
                             attempt.Failure? ==> attempt.history+[Request(f.guardOwner as nat,GuardFailure,[attempt.error.payload])] <= end)
  }
  lemma Widen(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
              oracle: (Request,seq<Request>)->Raw, frames: seq<F.Frame>, start: seq<Request>, end: seq<Request>,
              earlier: seq<Request>, later: seq<Request>)
    requires Program(nodes) && Events(nodes,valid,truth,reject,oracle,frames,end)
    requires end <= later
    ensures Events(nodes,valid,truth,reject,oracle,frames,later)
  {}
  lemma Relabel(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                oracle: (Request,seq<Request>)->Raw, index: nat, memo: map<nat,Value>, history: seq<Request>, owner: nat, end: seq<Request>)
    requires Program(nodes) && index < |nodes|
    requires Events(nodes,valid,truth,reject,oracle,F.Trace(nodes,valid,truth,reject,oracle,index,memo,history,-1),end)
    requires var attempt := S.Evaluate(nodes,valid,truth,reject,oracle,index,memo,history);
             attempt.Failure? ==> attempt.history+[Request(owner,GuardFailure,[attempt.error.payload])] <= end
    ensures Events(nodes,valid,truth,reject,oracle,F.Trace(nodes,valid,truth,reject,oracle,index,memo,history,owner),end)
  {
    assert F.Trace(nodes,valid,truth,reject,oracle,index,memo,history,-1)[1..] ==
           F.Trace(nodes,valid,truth,reject,oracle,index,memo,history,owner)[1..];
  }

  lemma Evaluate(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                 oracle: (Request,seq<Request>)->Raw, index: nat, memo: map<nat,Value>, history: seq<Request>)
    requires Program(nodes) && index < |nodes|
    ensures Events(nodes,valid,truth,reject,oracle,F.Trace(nodes,valid,truth,reject,oracle,index,memo,history,-1),
                   S.Evaluate(nodes,valid,truth,reject,oracle,index,memo,history).history)
    decreases index,2,0
  {
    H.EvaluateHistory(nodes,valid,truth,reject,oracle,index,memo,history);
    if index !in memo { Body(nodes,valid,truth,reject,oracle,index,memo,history); }
  }
  lemma Body(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
             oracle: (Request,seq<Request>)->Raw, index: nat, memo: map<nat,Value>, history: seq<Request>)
    requires Program(nodes) && index < |nodes|
    ensures Events(nodes,valid,truth,reject,oracle,F.BodyTrace(nodes,valid,truth,reject,oracle,index,memo,history),
                   S.Body(nodes,valid,truth,reject,oracle,index,memo,history).history)
    decreases index,1,0
  {
    var node := nodes[index];
    var end := S.Body(nodes,valid,truth,reject,oracle,index,memo,history).history;
    if node.kind == Select {
      Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      var cond := S.Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      if cond.Success? {
        var branch := node.refs[if truth(cond.value) then 1 else 2];
        Evaluate(nodes,valid,truth,reject,oracle,branch,cond.memo,cond.history);
        H.EvaluateHistory(nodes,valid,truth,reject,oracle,branch,cond.memo,cond.history);
        Widen(nodes,valid,truth,reject,oracle,F.Trace(nodes,valid,truth,reject,oracle,branch,cond.memo,cond.history,-1),cond.history,end,history,end);
      }
      Widen(nodes,valid,truth,reject,oracle,F.Trace(nodes,valid,truth,reject,oracle,node.refs[0],memo,history,-1),history,cond.history,history,end);
    } else if node.kind in {TryOrElse,IsValid} {
      Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      var attempted := S.Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      var classified := if attempted.Success? then attempted else S.Invoke(Request(index,GuardFailure,[attempted.error.payload]),oracle,memo,attempted.history);
      if node.kind == TryOrElse && attempted.Failure? && classified.Success? {
        Evaluate(nodes,valid,truth,reject,oracle,node.refs[1],memo,classified.history);
        H.EvaluateHistory(nodes,valid,truth,reject,oracle,node.refs[1],memo,classified.history);
        Widen(nodes,valid,truth,reject,oracle,F.Trace(nodes,valid,truth,reject,oracle,node.refs[1],memo,classified.history,-1),classified.history,end,history,end);
      }
      Widen(nodes,valid,truth,reject,oracle,F.Trace(nodes,valid,truth,reject,oracle,node.refs[0],memo,history,-1),history,attempted.history,history,end);
      Relabel(nodes,valid,truth,reject,oracle,node.refs[0],memo,history,index,end);
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
    ensures Events(nodes,valid,truth,reject,oracle,F.GatherTrace(nodes,valid,truth,reject,oracle,index,pos,memo,history),
                   S.Gather(nodes,valid,truth,reject,oracle,index,pos,values,memo,history).history)
    decreases index,0,|nodes[index].refs|-pos
  {
    if pos < |nodes[index].refs| {
      var childIndex := nodes[index].refs[pos];
      Evaluate(nodes,valid,truth,reject,oracle,childIndex,memo,history);
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
  lemma Root(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
             oracle: (Request,seq<Request>)->Raw, index: nat, memo: map<nat,Value>, frames: seq<F.Frame>, trace: seq<Request>)
    requires Program(nodes) && index < |nodes|
    requires frames == F.Trace(nodes,valid,truth,reject,oracle,index,memo,[],-1)
    requires Bounds.Within(nodes,valid,truth,reject,oracle,frames,[],trace)
    ensures Events(nodes,valid,truth,reject,oracle,frames,trace)
  {
    Evaluate(nodes,valid,truth,reject,oracle,index,memo,[]);
    assert F.Frame(index,memo,[],-1) in frames;
    Widen(nodes,valid,truth,reject,oracle,frames,[],S.Evaluate(nodes,valid,truth,reject,oracle,index,memo,[]).history,[],trace);
  }
}
