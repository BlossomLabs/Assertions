// SPDX-License-Identifier: MIT
include "../frames/Connection.dfy"
module ExpressionContextShift {
  import opened ExpressionEvaluationControl
  import S = ExpressionRecursiveSpec
  import Stable = ExpressionOracleStability

  function Oracle(outer: (Request,seq<Request>)->Raw, prefix: seq<Request>): (Request,seq<Request>)->Raw {
    (q: Request,h: seq<Request>) => outer(q,prefix+h)
  }
  function ResultAt(prefix: seq<Request>, result: Result): Result {
    if result.Success? then Success(result.value,result.memo,prefix+result.history)
    else Failure(result.error,result.memo,prefix+result.history)
  }
  function ArgumentsAt(prefix: seq<Request>, args: S.Arguments): S.Arguments {
    if args.Collected? then S.Collected(args.values,args.memo,prefix+args.history)
    else S.Stopped(args.error,args.memo,prefix+args.history)
  }
  lemma Invoke(q: Request, outer: (Request,seq<Request>)->Raw, prefix: seq<Request>,
               memo: map<nat,Value>, history: seq<Request>)
    ensures S.Invoke(q,outer,memo,prefix+history) == ResultAt(prefix,S.Invoke(q,Oracle(outer,prefix),memo,history))
  {}
  lemma Complete(index: nat, valid: (nat,Value)->bool, reject: (nat,Value)->Error, prefix: seq<Request>, body: Result)
    ensures S.Complete(index,valid,reject,ResultAt(prefix,body)) == ResultAt(prefix,S.Complete(index,valid,reject,body))
  {}

  lemma Evaluate(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                 outer: (Request,seq<Request>)->Raw, prefix: seq<Request>, index: nat,
                 memo: map<nat,Value>, history: seq<Request>)
    requires Program(nodes) && index < |nodes|
    ensures S.Evaluate(nodes,valid,truth,reject,outer,index,memo,prefix+history) ==
            ResultAt(prefix,S.Evaluate(nodes,valid,truth,reject,Oracle(outer,prefix),index,memo,history))
    decreases index,2,0
  {
    if index !in memo {
      Body(nodes,valid,truth,reject,outer,prefix,index,memo,history);
      Complete(index,valid,reject,prefix,S.Body(nodes,valid,truth,reject,Oracle(outer,prefix),index,memo,history));
    }
  }
  lemma Body(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
             outer: (Request,seq<Request>)->Raw, prefix: seq<Request>, index: nat,
             memo: map<nat,Value>, history: seq<Request>)
    requires Program(nodes) && index < |nodes|
    ensures S.Body(nodes,valid,truth,reject,outer,index,memo,prefix+history) ==
            ResultAt(prefix,S.Body(nodes,valid,truth,reject,Oracle(outer,prefix),index,memo,history))
    decreases index,1,0
  {
    var local := Oracle(outer,prefix);
    var node := nodes[index];
    if node.kind == Select {
      Evaluate(nodes,valid,truth,reject,outer,prefix,node.refs[0],memo,history);
      var cond := S.Evaluate(nodes,valid,truth,reject,local,node.refs[0],memo,history);
      if cond.Success? {
        Evaluate(nodes,valid,truth,reject,outer,prefix,node.refs[if truth(cond.value) then 1 else 2],cond.memo,cond.history);
      }
    } else if node.kind in {TryOrElse,IsValid} {
      Evaluate(nodes,valid,truth,reject,outer,prefix,node.refs[0],memo,history);
      var attempted := S.Evaluate(nodes,valid,truth,reject,local,node.refs[0],memo,history);
      if attempted.Failure? { Invoke(Request(index,GuardFailure,[attempted.error.payload]),outer,prefix,memo,attempted.history); }
      var classified := if attempted.Success? then attempted else S.Invoke(Request(index,GuardFailure,[attempted.error.payload]),local,memo,attempted.history);
      if classified.Success? {
        var working := if attempted.Success? then attempted.memo else memo;
        if node.kind == IsValid { Invoke(Request(index,Boolean,[if attempted.Success? then [1] else [0]]),outer,prefix,working,classified.history); }
        else if attempted.Failure? { Evaluate(nodes,valid,truth,reject,outer,prefix,node.refs[1],memo,classified.history); }
      }
    } else {
      Gather(nodes,valid,truth,reject,outer,prefix,index,0,[],memo,history);
      var args := S.Gather(nodes,valid,truth,reject,local,index,0,[],memo,history);
      if args.Collected? { Invoke(Request(index,if node.kind in {Literal,Parameter,Resolve} then Leaf else Finish,args.values),outer,prefix,args.memo,args.history); }
    }
  }
  lemma Gather(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
               outer: (Request,seq<Request>)->Raw, prefix: seq<Request>, index: nat, pos: nat,
               values: seq<Value>, memo: map<nat,Value>, history: seq<Request>)
    requires Program(nodes) && index < |nodes| && pos <= |nodes[index].refs|
    ensures S.Gather(nodes,valid,truth,reject,outer,index,pos,values,memo,prefix+history) ==
            ArgumentsAt(prefix,S.Gather(nodes,valid,truth,reject,Oracle(outer,prefix),index,pos,values,memo,history))
    decreases index,0,|nodes[index].refs|-pos
  {
    if pos < |nodes[index].refs| {
      Evaluate(nodes,valid,truth,reject,outer,prefix,nodes[index].refs[pos],memo,history);
      var local := Oracle(outer,prefix);
      var child := S.Evaluate(nodes,valid,truth,reject,local,nodes[index].refs[pos],memo,history);
      if child.Success? {
        if pos == 0 && nodes[index].kind in {Call,ProbeCall} { Invoke(Request(index,Address,[child.value]),outer,prefix,child.memo,child.history); }
        var checked := if pos == 0 && nodes[index].kind in {Call,ProbeCall}
        then S.Invoke(Request(index,Address,[child.value]),local,child.memo,child.history) else child;
        if checked.Success? {
          Gather(nodes,valid,truth,reject,outer,prefix,index,pos+1,values+[child.value],child.memo,checked.history);
        }
      }
    }
  }
  lemma Rebase(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
               outer: (Request,seq<Request>)->Raw, local: (Request,seq<Request>)->Raw, prefix: seq<Request>,
               index: nat, memo: map<nat,Value>)
    requires Program(nodes) && index < |nodes|
    requires forall q: Request,h: seq<Request> :: local(q,h) == outer(q,prefix+h)
    ensures S.Evaluate(nodes,valid,truth,reject,outer,index,memo,prefix) ==
            ResultAt(prefix,S.Evaluate(nodes,valid,truth,reject,local,index,memo,[]))
  {
    var shifted := Oracle(outer,prefix);
    var inner := S.Evaluate(nodes,valid,truth,reject,local,index,memo,[]);
    Evaluate(nodes,valid,truth,reject,outer,prefix,index,memo,[]);
    assert prefix+[] == prefix;
    assert S.Evaluate(nodes,valid,truth,reject,outer,index,memo,prefix+[]) == ResultAt(prefix,S.Evaluate(nodes,valid,truth,reject,Oracle(outer,prefix),index,memo,[]));
    assert shifted == Oracle(outer,prefix);
    Stable.EvaluateStable(nodes,valid,truth,reject,local,shifted,index,memo,[],inner.history);
    calc {
       S.Evaluate(nodes,valid,truth,reject,outer,index,memo,prefix);
    == ResultAt(prefix,S.Evaluate(nodes,valid,truth,reject,shifted,index,memo,[]));
    == ResultAt(prefix,inner);
    }
  }
}
