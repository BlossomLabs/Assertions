// SPDX-License-Identifier: MIT
include "../evaluation/Control.dfy"
module ExpressionRecursiveSpec {
  import opened ExpressionEvaluationControl
  datatype Arguments = Collected(values: seq<Value>, memo: map<nat,Value>, history: seq<Request>)
                     | Stopped(error: Error, memo: map<nat,Value>, history: seq<Request>)

  function Invoke(request: Request, oracle: (Request,seq<Request>)->Raw,
                  memo: map<nat,Value>, history: seq<Request>): Result {
    var raw := oracle(request,history);
    if raw.Aborted? then Failure(raw.error,memo,history+[request])
    else Success(raw.value,memo,history+[request])
  }

  function Complete(index: nat, valid: (nat,Value)->bool, reject: (nat,Value)->Error, body: Result): Result {
    if body.Failure? then body else
    if !valid(index,body.value) then Failure(reject(index,body.value),body.memo,body.history)
    else Success(body.value,body.memo[index := body.value],body.history)
  }

  ghost function Evaluate(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                          oracle: (Request,seq<Request>)->Raw, index: nat,
                          memo: map<nat,Value>, history: seq<Request>): Result
    requires Program(nodes) && index < |nodes|
    decreases index,2,0
  {
    if index in memo then Success(memo[index],memo,history)
    else Complete(index,valid,reject,Body(nodes,valid,truth,reject,oracle,index,memo,history))
  }

  ghost function Body(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                      oracle: (Request,seq<Request>)->Raw, index: nat,
                      memo: map<nat,Value>, history: seq<Request>): Result
    requires Program(nodes) && index < |nodes|
    decreases index,1,0
  {
    var node := nodes[index];
    if node.kind == Select then
      var cond := Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      if cond.Failure? then cond else
      Evaluate(nodes,valid,truth,reject,oracle,node.refs[if truth(cond.value) then 1 else 2],cond.memo,cond.history)
    else if node.kind in {TryOrElse,IsValid} then
      var attempted := Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      var classified := if attempted.Success? then attempted
                        else Invoke(Request(index,GuardFailure,[attempted.error.payload]),oracle,memo,attempted.history);
      if classified.Failure? then classified else
      var working := if attempted.Success? then attempted.memo else memo;
      if node.kind == IsValid then
        Invoke(Request(index,Boolean,[if attempted.Success? then [1] else [0]]),oracle,working,classified.history)
      else if attempted.Success? then attempted else
      Evaluate(nodes,valid,truth,reject,oracle,node.refs[1],memo,classified.history)
    else
      var args := Gather(nodes,valid,truth,reject,oracle,index,0,[],memo,history);
      if args.Stopped? then Failure(args.error,args.memo,args.history) else
      Invoke(Request(index,if node.kind in {Literal,Parameter,Resolve} then Leaf else Finish,args.values),oracle,args.memo,args.history)
  }

  ghost function Gather(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                        oracle: (Request,seq<Request>)->Raw, index: nat, pos: nat,
                        values: seq<Value>, memo: map<nat,Value>, history: seq<Request>): Arguments
    requires Program(nodes) && index < |nodes| && pos <= |nodes[index].refs|
    decreases index,0,|nodes[index].refs|-pos
  {
    if pos == |nodes[index].refs| then Collected(values,memo,history) else
    var child := Evaluate(nodes,valid,truth,reject,oracle,nodes[index].refs[pos],memo,history);
    if child.Failure? then Stopped(child.error,child.memo,child.history) else
    var checked := if pos == 0 && nodes[index].kind in {Call,ProbeCall}
                   then Invoke(Request(index,Address,[child.value]),oracle,child.memo,child.history) else child;
    if checked.Failure? then Stopped(checked.error,checked.memo,checked.history) else
    Gather(nodes,valid,truth,reject,oracle,index,pos+1,values+[child.value],child.memo,checked.history)
  }
}
