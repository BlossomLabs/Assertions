// SPDX-License-Identifier: MIT
include "Model.dfy"
module ExpressionExecutionRun {
  import opened ExpressionEvaluationControl
  import M = ExpressionOracleModel
  import X = ExpressionExecutionModel
  import H = ExpressionOracleStability
  import S = ExpressionRecursiveSpec

  ghost method Run(c: M.Config, nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                   index: nat, memo: map<nat,Value>, history: seq<Request>, replies: seq<M.Reply>)
    returns (out: Result, more: seq<M.Reply>)
    requires Program(nodes) && index < |nodes| && X.Certified(c,history,replies)
    ensures history <= out.history && replies <= more && X.Certified(c,out.history,more)
    ensures out == S.Evaluate(nodes,valid,truth,reject,M.Replay(out.history,more),index,memo,history)
    decreases index,2,0
  {
    if index in memo { out := Success(memo[index],memo,history); more := replies; }
    else {
      var body, built := Body(c,nodes,valid,truth,reject,index,memo,history,replies);
      out := S.Complete(index,valid,reject,body); more := built;
    }
  }

  ghost method Body(c: M.Config, nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                    index: nat, memo: map<nat,Value>, history: seq<Request>, replies: seq<M.Reply>)
    returns (out: Result, more: seq<M.Reply>)
    requires Program(nodes) && index < |nodes| && X.Certified(c,history,replies)
    ensures history <= out.history && replies <= more && X.Certified(c,out.history,more)
    ensures out == S.Body(nodes,valid,truth,reject,M.Replay(out.history,more),index,memo,history)
    decreases index,1,0
  {
    var node := nodes[index];
    if node.kind == Select {
      var cond, a := Run(c,nodes,valid,truth,reject,node.refs[0],memo,history,replies);
      if cond.Failure? { out := cond; more := a; }
      else {
        out, more := Run(c,nodes,valid,truth,reject,node.refs[if truth(cond.value) then 1 else 2],cond.memo,cond.history,a);
        X.PreserveEvaluation(nodes,valid,truth,reject,node.refs[0],memo,history,cond,a,out.history,more);
      }
    } else if node.kind in {TryOrElse,IsValid} {
      var attempted, a := Run(c,nodes,valid,truth,reject,node.refs[0],memo,history,replies);
      var classified := attempted;
      var b := a;
      if attempted.Failure? { classified,b := X.Invoke(c,Request(index,GuardFailure,[attempted.error.payload]),memo,attempted.history,a); }
      if classified.Failure? { out := classified; more := b; }
      else {
        var working := if attempted.Success? then attempted.memo else memo;
        if node.kind == IsValid {
          out,more := X.Invoke(c,Request(index,Boolean,[if attempted.Success? then [1] else [0]]),working,classified.history,b);
        } else if attempted.Success? { out := attempted; more := a; }
        else { out,more := Run(c,nodes,valid,truth,reject,node.refs[1],memo,classified.history,b); }
      }
      X.PreserveEvaluation(nodes,valid,truth,reject,node.refs[0],memo,history,attempted,a,out.history,more);
      if attempted.Failure? { X.PreserveInvoke(Request(index,GuardFailure,[attempted.error.payload]),memo,attempted.history,classified,b,out.history,more); }
    } else {
      var args,a := Gather(c,nodes,valid,truth,reject,index,0,[],memo,history,replies);
      if args.Stopped? { out := Failure(args.error,args.memo,args.history); more := a; }
      else {
        out,more := X.Invoke(c,Request(index,if node.kind in {Literal,Parameter,Resolve} then Leaf else Finish,args.values),args.memo,args.history,a);
        H.ReplayExtension(args.history,a,out.history,more);
        H.GatherStable(nodes,valid,truth,reject,M.Replay(args.history,a),M.Replay(out.history,more),index,0,[],memo,history,args.history);
      }
    }
  }

  ghost method Gather(c: M.Config, nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                      index: nat, pos: nat, values: seq<Value>, memo: map<nat,Value>, history: seq<Request>, replies: seq<M.Reply>)
    returns (out: S.Arguments, more: seq<M.Reply>)
    requires Program(nodes) && index < |nodes| && pos <= |nodes[index].refs| && X.Certified(c,history,replies)
    ensures history <= out.history && replies <= more && X.Certified(c,out.history,more)
    ensures out == S.Gather(nodes,valid,truth,reject,M.Replay(out.history,more),index,pos,values,memo,history)
    decreases index,0,|nodes[index].refs|-pos
  {
    if pos == |nodes[index].refs| { out := S.Collected(values,memo,history); more := replies; }
    else {
      var child,a := Run(c,nodes,valid,truth,reject,nodes[index].refs[pos],memo,history,replies);
      if child.Failure? { out := S.Stopped(child.error,child.memo,child.history); more := a; }
      else {
        var checked := child;
        var b := a;
        if pos == 0 && nodes[index].kind in {Call,ProbeCall} { checked,b := X.Invoke(c,Request(index,Address,[child.value]),child.memo,child.history,a); }
        if checked.Failure? { out := S.Stopped(checked.error,checked.memo,checked.history); more := b; }
        else { out,more := Gather(c,nodes,valid,truth,reject,index,pos+1,values+[child.value],child.memo,checked.history,b); }
        X.PreserveEvaluation(nodes,valid,truth,reject,nodes[index].refs[pos],memo,history,child,a,out.history,more);
        if pos == 0 && nodes[index].kind in {Call,ProbeCall} { X.PreserveInvoke(Request(index,Address,[child.value]),child.memo,child.history,checked,b,out.history,more); }
      }
    }
  }
}
