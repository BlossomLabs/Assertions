// SPDX-License-Identifier: MIT
include "../recursive/Spec.dfy"

// Unfold references on every occurrence. Original node identities are retained
// in requests and errors; no memo is read or written by this specification.
module ExpressionTreeSpec {
  import opened ExpressionEvaluationControl

  datatype Arguments = Values(values: seq<Value>) | Stopped(error: Error)

  function Complete(index: nat, valid: (nat,Value)->bool, reject: (nat,Value)->Error, raw: Raw): Raw {
    if raw.Aborted? then raw else
    if valid(index,raw.value) then raw else Aborted(reject(index,raw.value))
  }

  ghost function Evaluate(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool,
                          reject: (nat,Value)->Error, primitive: Request->Raw, index: nat): Raw
    requires Program(nodes) && index < |nodes|
    decreases index,2,0
  { Complete(index,valid,reject,Body(nodes,valid,truth,reject,primitive,index)) }

  ghost function Body(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool,
                      reject: (nat,Value)->Error, primitive: Request->Raw, index: nat): Raw
    requires Program(nodes) && index < |nodes|
    decreases index,1,0
  {
    var node := nodes[index];
    if node.kind == Select then
      var condition := Evaluate(nodes,valid,truth,reject,primitive,node.refs[0]);
      if condition.Aborted? then condition else
      Evaluate(nodes,valid,truth,reject,primitive,node.refs[if truth(condition.value) then 1 else 2])
    else if node.kind in {TryOrElse,IsValid} then
      var attempt := Evaluate(nodes,valid,truth,reject,primitive,node.refs[0]);
      var classified := if attempt.Produced? then attempt else primitive(Request(index,GuardFailure,[attempt.error.payload]));
      if classified.Aborted? then classified else
      if node.kind == IsValid then primitive(Request(index,Boolean,[if attempt.Produced? then [1] else [0]]))
      else if attempt.Produced? then attempt else Evaluate(nodes,valid,truth,reject,primitive,node.refs[1])
    else
      var arguments := Gather(nodes,valid,truth,reject,primitive,index,0,[]);
      if arguments.Stopped? then Aborted(arguments.error) else
      primitive(Request(index,if node.kind in {Literal,Parameter,Resolve} then Leaf else Finish,arguments.values))
  }

  ghost function Gather(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool,
                        reject: (nat,Value)->Error, primitive: Request->Raw,
                        index: nat, pos: nat, values: seq<Value>): Arguments
    requires Program(nodes) && index < |nodes| && pos <= |nodes[index].refs|
    decreases index,0,|nodes[index].refs|-pos
  {
    if pos == |nodes[index].refs| then Values(values) else
    var child := Evaluate(nodes,valid,truth,reject,primitive,nodes[index].refs[pos]);
    if child.Aborted? then Stopped(child.error) else
    var checked := if pos == 0 && nodes[index].kind in {Call,ProbeCall}
                   then primitive(Request(index,Address,[child.value])) else child;
    if checked.Aborted? then Stopped(checked.error) else
    Gather(nodes,valid,truth,reject,primitive,index,pos+1,values+[child.value])
  }
}
