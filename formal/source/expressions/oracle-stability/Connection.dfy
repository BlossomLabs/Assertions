// SPDX-License-Identifier: MIT
include "../oracle/Connection.dfy"
module ExpressionOracleStability {
  import opened ExpressionEvaluationControl
  import S = ExpressionRecursiveSpec
  import M = ExpressionOracleModel

  predicate Agree(trace: seq<Request>, a: (Request,seq<Request>)->Raw, b: (Request,seq<Request>)->Raw) {
    forall i :: 0 <= i < |trace| ==> a(trace[i],trace[..i]) == b(trace[i],trace[..i])
  }
  lemma InvokeStable(q: Request, a: (Request,seq<Request>)->Raw, b: (Request,seq<Request>)->Raw,
                     memo: map<nat,Value>, history: seq<Request>, trace: seq<Request>)
    requires history+[q] <= trace && Agree(trace,a,b)
    ensures S.Invoke(q,a,memo,history) == S.Invoke(q,b,memo,history)
  {
    assert trace[|history|] == q && trace[..|history|] == history;
  }

  lemma EvaluateHistory(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                        oracle: (Request,seq<Request>)->Raw, index: nat, memo: map<nat,Value>, history: seq<Request>)
    requires Program(nodes) && index < |nodes|
    ensures history <= S.Evaluate(nodes,valid,truth,reject,oracle,index,memo,history).history
    decreases index,2,0
  {
    if index !in memo { BodyHistory(nodes,valid,truth,reject,oracle,index,memo,history); }
  }
  lemma BodyHistory(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                    oracle: (Request,seq<Request>)->Raw, index: nat, memo: map<nat,Value>, history: seq<Request>)
    requires Program(nodes) && index < |nodes|
    ensures history <= S.Body(nodes,valid,truth,reject,oracle,index,memo,history).history
    decreases index,1,0
  {
    var node := nodes[index];
    if node.kind == Select {
      EvaluateHistory(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      var cond := S.Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      if cond.Success? { EvaluateHistory(nodes,valid,truth,reject,oracle,node.refs[if truth(cond.value) then 1 else 2],cond.memo,cond.history); }
    } else if node.kind in {TryOrElse,IsValid} {
      EvaluateHistory(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      var attempted := S.Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      var classified := if attempted.Success? then attempted else S.Invoke(Request(index,GuardFailure,[attempted.error.payload]),oracle,memo,attempted.history);
      if classified.Success? && node.kind == TryOrElse && attempted.Failure? {
        EvaluateHistory(nodes,valid,truth,reject,oracle,node.refs[1],memo,classified.history);
      }
    } else {
      GatherHistory(nodes,valid,truth,reject,oracle,index,0,[],memo,history);
    }
  }
  lemma GatherHistory(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                      oracle: (Request,seq<Request>)->Raw, index: nat, pos: nat,
                      values: seq<Value>, memo: map<nat,Value>, history: seq<Request>)
    requires Program(nodes) && index < |nodes| && pos <= |nodes[index].refs|
    ensures history <= S.Gather(nodes,valid,truth,reject,oracle,index,pos,values,memo,history).history
    decreases index,0,|nodes[index].refs|-pos
  {
    if pos < |nodes[index].refs| {
      EvaluateHistory(nodes,valid,truth,reject,oracle,nodes[index].refs[pos],memo,history);
      var child := S.Evaluate(nodes,valid,truth,reject,oracle,nodes[index].refs[pos],memo,history);
      if child.Success? {
        var checked := if pos == 0 && nodes[index].kind in {Call,ProbeCall}
        then S.Invoke(Request(index,Address,[child.value]),oracle,child.memo,child.history) else child;
        if checked.Success? { GatherHistory(nodes,valid,truth,reject,oracle,index,pos+1,values+[child.value],child.memo,checked.history); }
      }
    }
  }

  lemma EvaluateStable(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                       a: (Request,seq<Request>)->Raw, b: (Request,seq<Request>)->Raw, index: nat,
                       memo: map<nat,Value>, history: seq<Request>, trace: seq<Request>)
    requires Program(nodes) && index < |nodes| && Agree(trace,a,b)
    requires S.Evaluate(nodes,valid,truth,reject,a,index,memo,history).history <= trace
    ensures S.Evaluate(nodes,valid,truth,reject,a,index,memo,history) == S.Evaluate(nodes,valid,truth,reject,b,index,memo,history)
    decreases index,2,0
  {
    if index !in memo { BodyStable(nodes,valid,truth,reject,a,b,index,memo,history,trace); }
  }
  lemma BodyStable(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                   a: (Request,seq<Request>)->Raw, b: (Request,seq<Request>)->Raw, index: nat,
                   memo: map<nat,Value>, history: seq<Request>, trace: seq<Request>)
    requires Program(nodes) && index < |nodes| && Agree(trace,a,b)
    requires S.Body(nodes,valid,truth,reject,a,index,memo,history).history <= trace
    ensures S.Body(nodes,valid,truth,reject,a,index,memo,history) == S.Body(nodes,valid,truth,reject,b,index,memo,history)
    decreases index,1,0
  {
    var node := nodes[index];
    if node.kind == Select {
      var cond := S.Evaluate(nodes,valid,truth,reject,a,node.refs[0],memo,history);
      if cond.Success? { EvaluateHistory(nodes,valid,truth,reject,a,node.refs[if truth(cond.value) then 1 else 2],cond.memo,cond.history); }
      EvaluateStable(nodes,valid,truth,reject,a,b,node.refs[0],memo,history,trace);
      if cond.Success? { EvaluateStable(nodes,valid,truth,reject,a,b,node.refs[if truth(cond.value) then 1 else 2],cond.memo,cond.history,trace); }
    } else if node.kind in {TryOrElse,IsValid} {
      var attempted := S.Evaluate(nodes,valid,truth,reject,a,node.refs[0],memo,history);
      var classified := if attempted.Success? then attempted else S.Invoke(Request(index,GuardFailure,[attempted.error.payload]),a,memo,attempted.history);
      if classified.Success? && node.kind == TryOrElse && attempted.Failure? {
        EvaluateHistory(nodes,valid,truth,reject,a,node.refs[1],memo,classified.history);
      }
      EvaluateStable(nodes,valid,truth,reject,a,b,node.refs[0],memo,history,trace);
      if attempted.Failure? { InvokeStable(Request(index,GuardFailure,[attempted.error.payload]),a,b,memo,attempted.history,trace); }
      if classified.Success? {
        var working := if attempted.Success? then attempted.memo else memo;
        if node.kind == IsValid {
          InvokeStable(Request(index,Boolean,[if attempted.Success? then [1] else [0]]),a,b,working,classified.history,trace);
        } else if attempted.Failure? {
          EvaluateStable(nodes,valid,truth,reject,a,b,node.refs[1],memo,classified.history,trace);
        }
      }
    } else {
      var args := S.Gather(nodes,valid,truth,reject,a,index,0,[],memo,history);
      GatherStable(nodes,valid,truth,reject,a,b,index,0,[],memo,history,trace);
      if args.Collected? { InvokeStable(Request(index,if node.kind in {Literal,Parameter,Resolve} then Leaf else Finish,args.values),a,b,args.memo,args.history,trace); }
    }
  }
  lemma GatherStable(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                     a: (Request,seq<Request>)->Raw, b: (Request,seq<Request>)->Raw, index: nat, pos: nat,
                     values: seq<Value>, memo: map<nat,Value>, history: seq<Request>, trace: seq<Request>)
    requires Program(nodes) && index < |nodes| && pos <= |nodes[index].refs| && Agree(trace,a,b)
    requires S.Gather(nodes,valid,truth,reject,a,index,pos,values,memo,history).history <= trace
    ensures S.Gather(nodes,valid,truth,reject,a,index,pos,values,memo,history) == S.Gather(nodes,valid,truth,reject,b,index,pos,values,memo,history)
    decreases index,0,|nodes[index].refs|-pos
  {
    if pos < |nodes[index].refs| {
      var child := S.Evaluate(nodes,valid,truth,reject,a,nodes[index].refs[pos],memo,history);
      if child.Success? {
        var checked := if pos == 0 && nodes[index].kind in {Call,ProbeCall}
        then S.Invoke(Request(index,Address,[child.value]),a,child.memo,child.history) else child;
        if checked.Success? { GatherHistory(nodes,valid,truth,reject,a,index,pos+1,values+[child.value],child.memo,checked.history); }
      }
      EvaluateStable(nodes,valid,truth,reject,a,b,nodes[index].refs[pos],memo,history,trace);
      if child.Success? {
        var checked := if pos == 0 && nodes[index].kind in {Call,ProbeCall}
        then S.Invoke(Request(index,Address,[child.value]),a,child.memo,child.history) else child;
        if pos == 0 && nodes[index].kind in {Call,ProbeCall} { InvokeStable(Request(index,Address,[child.value]),a,b,child.memo,child.history,trace); }
        if checked.Success? { GatherStable(nodes,valid,truth,reject,a,b,index,pos+1,values+[child.value],child.memo,checked.history,trace); }
      }
    }
  }

  lemma ReplayExtension(trace: seq<Request>, replies: seq<M.Reply>, longer: seq<Request>, more: seq<M.Reply>)
    requires |trace| == |replies| && |longer| == |more| && trace <= longer && replies <= more
    ensures Agree(trace,M.Replay(trace,replies),M.Replay(longer,more))
  {
    forall i | 0 <= i < |trace|
      ensures M.Replay(trace,replies)(trace[i],trace[..i]) == M.Replay(longer,more)(trace[i],trace[..i])
    { assert longer[i] == trace[i] && longer[..i] == trace[..i] && more[i] == replies[i]; }
  }
}
