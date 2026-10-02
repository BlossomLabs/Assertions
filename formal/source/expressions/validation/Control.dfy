// SPDX-License-Identifier: MIT
include "Bytes.dfy"
module ExpressionValidationControl {
  import opened ExpressionEvaluationControl
  import S = ExpressionRecursiveSpec
  import B = ExpressionEvaluationBridge
  import V = ExpressionValidationBytes

  predicate Memo(memo: map<nat,Value>) { forall i <- memo.Keys :: B.Bytes(memo[i]) }
  predicate ResultBytes(out: Result) {
    Memo(out.memo) && (if out.Success? then B.Bytes(out.value) else B.Bytes(out.error.payload))
  }
  predicate ArgumentBytes(out: S.Arguments) {
    Memo(out.memo) && (if out.Collected? then (forall v <- out.values :: B.Bytes(v)) else B.Bytes(out.error.payload))
  }
  lemma Invoke(q: Request, oracle: (Request,seq<Request>)->Raw, memo: map<nat,Value>, history: seq<Request>)
    requires Memo(memo) && V.Oracle(oracle)
    ensures ResultBytes(S.Invoke(q,oracle,memo,history))
  {}
  lemma Complete(index: nat, valid: (nat,Value)->bool, reject: (nat,Value)->Error, body: Result)
    requires ResultBytes(body)
    requires body.Success? ==> B.Bytes(reject(index,body.value).payload)
    ensures ResultBytes(S.Complete(index,valid,reject,body))
  {}
  lemma Evaluate(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                 oracle: (Request,seq<Request>)->Raw, index: nat, memo: map<nat,Value>, history: seq<Request>)
    requires Program(nodes) && index < |nodes| && Memo(memo) && V.Oracle(oracle)
    requires forall i: nat,v: Value :: i < |nodes| ==> B.Bytes(reject(i,v).payload)
    ensures ResultBytes(S.Evaluate(nodes,valid,truth,reject,oracle,index,memo,history))
    decreases index,2,0
  {
    if index !in memo {
      Body(nodes,valid,truth,reject,oracle,index,memo,history);
      Complete(index,valid,reject,S.Body(nodes,valid,truth,reject,oracle,index,memo,history));
    }
  }
  lemma Body(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
             oracle: (Request,seq<Request>)->Raw, index: nat, memo: map<nat,Value>, history: seq<Request>)
    requires Program(nodes) && index < |nodes| && Memo(memo) && V.Oracle(oracle)
    requires forall i: nat,v: Value :: i < |nodes| ==> B.Bytes(reject(i,v).payload)
    ensures ResultBytes(S.Body(nodes,valid,truth,reject,oracle,index,memo,history))
    decreases index,1,0
  {
    var node := nodes[index];
    if node.kind == Select {
      Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      var cond := S.Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      if cond.Success? { Evaluate(nodes,valid,truth,reject,oracle,node.refs[if truth(cond.value) then 1 else 2],cond.memo,cond.history); }
    } else if node.kind in {TryOrElse,IsValid} {
      Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      var attempted := S.Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      if attempted.Failure? { Invoke(Request(index,GuardFailure,[attempted.error.payload]),oracle,memo,attempted.history); }
      var classified := if attempted.Success? then attempted else S.Invoke(Request(index,GuardFailure,[attempted.error.payload]),oracle,memo,attempted.history);
      if classified.Success? {
        var working := if attempted.Success? then attempted.memo else memo;
        if node.kind == IsValid { Invoke(Request(index,Boolean,[if attempted.Success? then [1] else [0]]),oracle,working,classified.history); }
        else if attempted.Failure? { Evaluate(nodes,valid,truth,reject,oracle,node.refs[1],memo,classified.history); }
      }
    } else {
      Gather(nodes,valid,truth,reject,oracle,index,0,[],memo,history);
      var args := S.Gather(nodes,valid,truth,reject,oracle,index,0,[],memo,history);
      if args.Collected? { Invoke(Request(index,if node.kind in {Literal,Parameter,Resolve} then Leaf else Finish,args.values),oracle,args.memo,args.history); }
    }
  }
  lemma Gather(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
               oracle: (Request,seq<Request>)->Raw, index: nat, pos: nat, values: seq<Value>,
               memo: map<nat,Value>, history: seq<Request>)
    requires Program(nodes) && index < |nodes| && pos <= |nodes[index].refs| && Memo(memo) && V.Oracle(oracle)
    requires forall v <- values :: B.Bytes(v)
    requires forall i: nat,v: Value :: i < |nodes| ==> B.Bytes(reject(i,v).payload)
    ensures ArgumentBytes(S.Gather(nodes,valid,truth,reject,oracle,index,pos,values,memo,history))
    decreases index,0,|nodes[index].refs|-pos
  {
    if pos < |nodes[index].refs| {
      Evaluate(nodes,valid,truth,reject,oracle,nodes[index].refs[pos],memo,history);
      var child := S.Evaluate(nodes,valid,truth,reject,oracle,nodes[index].refs[pos],memo,history);
      if child.Success? {
        if pos == 0 && nodes[index].kind in {Call,ProbeCall} { Invoke(Request(index,Address,[child.value]),oracle,child.memo,child.history); }
        var checked := if pos == 0 && nodes[index].kind in {Call,ProbeCall}
        then S.Invoke(Request(index,Address,[child.value]),oracle,child.memo,child.history) else child;
        if checked.Success? { Gather(nodes,valid,truth,reject,oracle,index,pos+1,values+[child.value],child.memo,checked.history); }
      }
    }
  }
}
