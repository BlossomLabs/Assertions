// SPDX-License-Identifier: MIT
include "../traversal/Model.dfy"
module CollectionsEnvironmentModel {
  import opened AbiFrames
  import opened CollectionsTraversalModel
  function Splice(earlier: Environment, later: Environment, cut: nat): Environment {
    Environment((q: Request,c: Context) => if |c.history| < cut then earlier.step(q,c) else later.step(q,c))
  }
  ghost predicate Window(a: Environment, b: Environment, start: nat, end: nat) {
    forall q: Request, c: Context :: start <= |c.history| < end ==> a.step(q,c) == b.step(q,c)
  }
  ghost predicate Future(a: Environment, b: Environment, start: nat) {
    forall q: Request, c: Context :: start <= |c.history| ==> a.step(q,c) == b.step(q,c)
  }
  lemma Before(a: Environment, b: Environment, start: nat, cut: nat)
    ensures Window(a,Splice(a,b,cut),start,cut)
  {}
  lemma After(a: Environment, b: Environment, cut: nat)
    ensures Future(b,Splice(a,b,cut),cut)
  {}
  lemma Restrict(a: Environment, b: Environment, start: nat, next: nat)
    requires Future(a,b,start) && start <= next
    ensures Future(a,b,next)
  {}
  datatype Row = Row(start: Context, accumulator: seq<Byte>, env: Environment, out: Outcome)
  ghost predicate Chain(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, values: seq<seq<Byte>>, index: nat, acc: seq<Byte>, c: Context, rows: seq<Row>)
    requires index <= |values|
    decreases |values|-index
  {
    if index == |values| then |rows| == 0 else
    |rows| > 0 && rows[0].start == c && rows[0].accumulator == acc &&
    rows[0].out == Step(mode,inputType,outputType,values[index],index,acc,c,rows[0].env) &&
    (if rows[0].out.Failure? then |rows| == 1 else
     Chain(mode,inputType,outputType,values,index+1,rows[0].out.accumulator,rows[0].out.context,rows[1..]))
  }
  function Collected(rows: seq<Row>, acc: seq<Byte>, c: Context): Outcome
    decreases |rows|
  {
    if |rows| == 0 then Success([],acc,c) else
    if rows[0].out.Failure? then rows[0].out else
    Prepend(rows[0].out.values,Collected(rows[1..],rows[0].out.accumulator,rows[0].out.context))
  }

}
