// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsEnvironmentConnection {
  import opened AbiFrames
  import opened CollectionsTraversalModel
  import opened CollectionsEnvironmentModel

  lemma StepLength(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, value: seq<Byte>, index: nat, acc: seq<Byte>, c: Context, env: Environment)
    ensures c.history <= Step(mode,inputType,outputType,value,index,acc,c,env).context.history
    ensures |c.history|+1 <= |Step(mode,inputType,outputType,value,index,acc,c,env).context.history| <= |c.history|+3
    ensures Step(mode,inputType,outputType,value,index,acc,c,env).Success? ==>
              |Step(mode,inputType,outputType,value,index,acc,c,env).context.history| == |c.history|+(if mode == Filter then 2 else 3)
  {}
  lemma AdmissionLength(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, initial: seq<Byte>, c: Context, env: Environment)
    ensures c.history <= Admission(mode,inputType,outputType,initial,c,env).context.history
    ensures |c.history|+1 <= |Admission(mode,inputType,outputType,initial,c,env).context.history| <= |c.history|+3
    ensures Admission(mode,inputType,outputType,initial,c,env).Success? ==>
              |Admission(mode,inputType,outputType,initial,c,env).context.history| == |c.history|+(if mode == Filter then 2 else 3)
  {}
  lemma AskSame(q: Request, c: Context, a: Environment, b: Environment)
    requires a.step(q,c) == b.step(q,c)
    ensures Ask(q,c,a) == Ask(q,c,b)
  {}

  lemma StepReplay(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, value: seq<Byte>, index: nat, acc: seq<Byte>, c: Context, a: Environment, b: Environment)
    requires Window(a,b,|c.history|,|Step(mode,inputType,outputType,value,index,acc,c,a).context.history|)
    ensures Step(mode,inputType,outputType,value,index,acc,c,a) == Step(mode,inputType,outputType,value,index,acc,c,b)
  {
    StepLength(mode,inputType,outputType,value,index,acc,c,a);
    AskSame(Validate(inputType,value),c,a,b);
    var input := Ask(Validate(inputType,value),c,a);
    if input.reply.Error? { return; }
    var q := if mode == Filter then Predicate(value,[],false,index,0) else
    if mode == Map then Call(value,[],false,index,0) else Call(acc,value,true,index,0);
    AskSame(q,input.context,a,b);
    var call := Ask(q,input.context,a);
    if call.reply.Error? || mode == Filter { return; }
    AskSame(ValidateResult(outputType,call.reply.value,index),call.context,a,b);
  }
  lemma AdmissionReplay(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, initial: seq<Byte>, c: Context, a: Environment, b: Environment)
    requires Window(a,b,|c.history|,|Admission(mode,inputType,outputType,initial,c,a).context.history|)
    ensures Admission(mode,inputType,outputType,initial,c,a) == Admission(mode,inputType,outputType,initial,c,b)
  {
    AdmissionLength(mode,inputType,outputType,initial,c,a);
    AskSame(Prepare(mode == Fold),c,a,b);
    var prepared := Ask(Prepare(mode == Fold),c,a);
    if prepared.reply.Error? { return; }
    AskSame(Shape(inputType),prepared.context,a,b);
    var input := Ask(Shape(inputType),prepared.context,a);
    if input.reply.Error? || mode == Filter { return; }
    AskSame(if mode == Map then Shape(outputType) else Validate(outputType,initial),input.context,a,b);
  }
  lemma TailReplay(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, values: seq<seq<Byte>>, index: nat, acc: seq<Byte>, c: Context, a: Environment, b: Environment)
    requires index <= |values| && Future(a,b,|c.history|)
    ensures Tail(mode,inputType,outputType,values,index,acc,c,a) == Tail(mode,inputType,outputType,values,index,acc,c,b)
    decreases |values|-index
  {
    if index == |values| { return; }
    var next := Step(mode,inputType,outputType,values[index],index,acc,c,a);
    assert Window(a,b,|c.history|,|next.context.history|);
    StepReplay(mode,inputType,outputType,values[index],index,acc,c,a,b);
    if next.Failure? { return; }
    StepLength(mode,inputType,outputType,values[index],index,acc,c,a);
    Restrict(a,b,|c.history|,|next.context.history|);
    TailReplay(mode,inputType,outputType,values,index+1,next.accumulator,next.context,a,b);
  }

  lemma JoinStep(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, values: seq<seq<Byte>>, index: nat, acc: seq<Byte>, c: Context, local: Environment, later: Environment)
    requires index < |values|
    ensures var first := Step(mode,inputType,outputType,values[index],index,acc,c,local);
            var joined := Splice(local,later,|first.context.history|);
            Tail(mode,inputType,outputType,values,index,acc,c,joined) ==
            (if first.Failure? then first else Prepend(first.values,Tail(mode,inputType,outputType,values,index+1,first.accumulator,first.context,later)))
  {
    var first := Step(mode,inputType,outputType,values[index],index,acc,c,local);
    var joined := Splice(local,later,|first.context.history|);
    Before(local,later,|c.history|,|first.context.history|);
    StepReplay(mode,inputType,outputType,values[index],index,acc,c,local,joined);
    if first.Failure? { return; }
    After(local,later,|first.context.history|);
    TailReplay(mode,inputType,outputType,values,index+1,first.accumulator,first.context,later,joined);
  }
  lemma JoinAdmission(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, values: seq<seq<Byte>>, initial: seq<Byte>, c: Context, local: Environment, later: Environment)
    ensures var first := Admission(mode,inputType,outputType,initial,c,local);
            var joined := Splice(local,later,|first.context.history|);
            Run(mode,inputType,outputType,values,initial,c,joined) ==
            (if first.Failure? then first else Tail(mode,inputType,outputType,values,0,initial,first.context,later))
  {
    var first := Admission(mode,inputType,outputType,initial,c,local);
    var joined := Splice(local,later,|first.context.history|);
    Before(local,later,|c.history|,|first.context.history|);
    AdmissionReplay(mode,inputType,outputType,initial,c,local,joined);
    if first.Failure? { return; }
    After(local,later,|first.context.history|);
    TailReplay(mode,inputType,outputType,values,0,initial,first.context,later,joined);
  }
  lemma ChainBounds(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, values: seq<seq<Byte>>, index: nat, acc: seq<Byte>, c: Context, rows: seq<Row>)
    requires index <= |values| && Chain(mode,inputType,outputType,values,index,acc,c,rows)
    ensures forall j :: 0 <= j < |rows| ==> |c.history| <= |rows[j].start.history| < |rows[j].out.context.history|
    decreases |values|-index
  {
    if index == |values| { return; }
    StepLength(mode,inputType,outputType,values[index],index,acc,c,rows[0].env);
    if rows[0].out.Failure? { return; }
    ChainBounds(mode,inputType,outputType,values,index+1,rows[0].out.accumulator,rows[0].out.context,rows[1..]);
  }
  ghost method Assemble(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, values: seq<seq<Byte>>, index: nat, acc: seq<Byte>, c: Context, rows: seq<Row>) returns (env: Environment)
    requires index <= |values| && Chain(mode,inputType,outputType,values,index,acc,c,rows)
    ensures Tail(mode,inputType,outputType,values,index,acc,c,env) == Collected(rows,acc,c)
    ensures forall j :: 0 <= j < |rows| ==> Window(env,rows[j].env,|rows[j].start.history|,|rows[j].out.context.history|)
    decreases |values|-index
  {
    env := Environment((q: Request,at: Context) => Observation(Error([]),at.state));
    if index == |values| { return; }
    var first := rows[0];
    var later := env;
    if first.out.Success? {
      later := Assemble(mode,inputType,outputType,values,index+1,first.out.accumulator,first.out.context,rows[1..]);
      ChainBounds(mode,inputType,outputType,values,index+1,first.out.accumulator,first.out.context,rows[1..]);
    }
    env := Splice(first.env,later,|first.out.context.history|);
    JoinStep(mode,inputType,outputType,values,index,acc,c,first.env,later);
    Before(first.env,later,|c.history|,|first.out.context.history|);
    After(first.env,later,|first.out.context.history|);
    forall j | 0 <= j < |rows|
      ensures Window(env,rows[j].env,|rows[j].start.history|,|rows[j].out.context.history|)
    {
      if j > 0 {
        assert first.out.Success?;
        assert rows[1..][j-1] == rows[j];
      }
    }
  }

}
