// SPDX-License-Identifier: MIT
include "Spec.dfy"

module ExpressionTreeEquivalence {
  import opened ExpressionEvaluationControl
  import S = ExpressionRecursiveSpec
  import T = ExpressionTreeSpec

  function Oracle(primitive: Request->Raw): (Request,seq<Request>)->Raw {
    (q: Request,h: seq<Request>) => primitive(q)
  }
  function RawResult(out: Result): Raw {
    if out.Success? then Produced(out.value) else Aborted(out.error)
  }
  function Arguments(out: S.Arguments): T.Arguments {
    if out.Collected? then T.Values(out.values) else T.Stopped(out.error)
  }
  ghost predicate Consistent(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool,
                             reject: (nat,Value)->Error, primitive: Request->Raw, memo: map<nat,Value>)
    requires Program(nodes)
  {
    forall i <- memo.Keys :: i < |nodes| && T.Evaluate(nodes,valid,truth,reject,primitive,i) == Produced(memo[i])
  }

  lemma Evaluate(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool,
                 reject: (nat,Value)->Error, primitive: Request->Raw,
                 index: nat, memo: map<nat,Value>, history: seq<Request>)
    requires Program(nodes) && index < |nodes| && Consistent(nodes,valid,truth,reject,primitive,memo)
    ensures RawResult(S.Evaluate(nodes,valid,truth,reject,Oracle(primitive),index,memo,history)) == T.Evaluate(nodes,valid,truth,reject,primitive,index)
    ensures Consistent(nodes,valid,truth,reject,primitive,S.Evaluate(nodes,valid,truth,reject,Oracle(primitive),index,memo,history).memo)
    decreases index,2,0
  {
    if index !in memo {
      Body(nodes,valid,truth,reject,primitive,index,memo,history);
      var body := S.Body(nodes,valid,truth,reject,Oracle(primitive),index,memo,history);
      if body.Success? && valid(index,body.value) {
        assert T.Evaluate(nodes,valid,truth,reject,primitive,index) == Produced(body.value);
      }
    }
  }

  lemma Body(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool,
             reject: (nat,Value)->Error, primitive: Request->Raw,
             index: nat, memo: map<nat,Value>, history: seq<Request>)
    requires Program(nodes) && index < |nodes| && Consistent(nodes,valid,truth,reject,primitive,memo)
    ensures RawResult(S.Body(nodes,valid,truth,reject,Oracle(primitive),index,memo,history)) == T.Body(nodes,valid,truth,reject,primitive,index)
    ensures Consistent(nodes,valid,truth,reject,primitive,S.Body(nodes,valid,truth,reject,Oracle(primitive),index,memo,history).memo)
    decreases index,1,0
  {
    var node := nodes[index];
    var oracle := Oracle(primitive);
    if node.kind == Select {
      Evaluate(nodes,valid,truth,reject,primitive,node.refs[0],memo,history);
      var condition := S.Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      if condition.Success? {
        Evaluate(nodes,valid,truth,reject,primitive,node.refs[if truth(condition.value) then 1 else 2],condition.memo,condition.history);
      }
    } else if node.kind in {TryOrElse,IsValid} {
      Evaluate(nodes,valid,truth,reject,primitive,node.refs[0],memo,history);
      var attempt := S.Evaluate(nodes,valid,truth,reject,oracle,node.refs[0],memo,history);
      if attempt.Failure? {
        var classified := S.Invoke(Request(index,GuardFailure,[attempt.error.payload]),oracle,memo,attempt.history);
        if classified.Success? && node.kind == TryOrElse {
          Evaluate(nodes,valid,truth,reject,primitive,node.refs[1],memo,classified.history);
        }
      }
    } else {
      Gather(nodes,valid,truth,reject,primitive,index,0,[],memo,history);
    }
  }

  lemma Gather(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool,
               reject: (nat,Value)->Error, primitive: Request->Raw,
               index: nat, pos: nat, values: seq<Value>, memo: map<nat,Value>, history: seq<Request>)
    requires Program(nodes) && index < |nodes| && pos <= |nodes[index].refs|
    requires Consistent(nodes,valid,truth,reject,primitive,memo)
    ensures Arguments(S.Gather(nodes,valid,truth,reject,Oracle(primitive),index,pos,values,memo,history)) == T.Gather(nodes,valid,truth,reject,primitive,index,pos,values)
    ensures Consistent(nodes,valid,truth,reject,primitive,S.Gather(nodes,valid,truth,reject,Oracle(primitive),index,pos,values,memo,history).memo)
    decreases index,0,|nodes[index].refs|-pos
  {
    if pos < |nodes[index].refs| {
      Evaluate(nodes,valid,truth,reject,primitive,nodes[index].refs[pos],memo,history);
      var child := S.Evaluate(nodes,valid,truth,reject,Oracle(primitive),nodes[index].refs[pos],memo,history);
      if child.Success? {
        var checked := if pos == 0 && nodes[index].kind in {Call,ProbeCall}
        then S.Invoke(Request(index,Address,[child.value]),Oracle(primitive),child.memo,child.history) else child;
        if checked.Success? {
          Gather(nodes,valid,truth,reject,primitive,index,pos+1,values+[child.value],child.memo,checked.history);
        }
      }
    }
  }
}
