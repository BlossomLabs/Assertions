// SPDX-License-Identifier: MIT
include "../../abi/Frames.dfy"

module CollectionsTraversalModel {
  import opened AbiFrames
  datatype Mode = Map | Filter | Fold
  datatype Request = Prepare(binary: bool) | Shape(descriptor: seq<Byte>)
                   | Validate(descriptor: seq<Byte>, value: seq<Byte>)
                   | Call(a: seq<Byte>, b: seq<Byte>, binary: bool, index: nat, other: nat)
                   | Predicate(a: seq<Byte>, b: seq<Byte>, binary: bool, index: nat, other: nat)
                   | ValidateResult(descriptor: seq<Byte>, value: seq<Byte>, index: nat)
  // A state token denotes the full helper context. Concrete prepared-callback,
  // ABI and call projections will supply these observations in a later layer.
  datatype Reply = Ok(value: seq<Byte>, truth: bool) | Error(reason: seq<Byte>)
  datatype Observation = Observation(reply: Reply, state: nat)
  datatype Context = Context(state: nat, history: seq<Request>)
  datatype Environment = Environment(step: (Request,Context) -> Observation)
  datatype Outcome = Success(values: seq<seq<Byte>>, accumulator: seq<Byte>, context: Context)
                   | Failure(reason: seq<Byte>, context: Context)
  datatype Attempt = Attempt(reply: Reply, context: Context)

  function Ask(q: Request, c: Context, env: Environment): Attempt {
    var r := env.step(q,c);
    Attempt(r.reply,Context(r.state,c.history+[q]))
  }
  function Prepend(prefix: seq<seq<Byte>>, out: Outcome): Outcome {
    if out.Failure? then out else Success(prefix+out.values,out.accumulator,out.context)
  }
  function Admission(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, initial: seq<Byte>, c: Context, env: Environment): Outcome {
    var prepared := Ask(Prepare(mode == Fold),c,env);
    if prepared.reply.Error? then Failure(prepared.reply.reason,prepared.context) else
    var input := Ask(Shape(inputType),prepared.context,env);
    if input.reply.Error? then Failure(input.reply.reason,input.context) else
    if mode == Filter then Success([],initial,input.context) else
    var output := Ask(if mode == Map then Shape(outputType) else Validate(outputType,initial),input.context,env);
    if output.reply.Error? then Failure(output.reply.reason,output.context) else Success([],initial,output.context)
  }
  function Step(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, value: seq<Byte>, index: nat, acc: seq<Byte>, c: Context, env: Environment): Outcome {
    var input := Ask(Validate(inputType,value),c,env);
    if input.reply.Error? then Failure(input.reply.reason,input.context) else
    var call := Ask(if mode == Filter then Predicate(value,[],false,index,0) else
                    if mode == Map then Call(value,[],false,index,0) else Call(acc,value,true,index,0),input.context,env);
    if call.reply.Error? then Failure(call.reply.reason,call.context) else
    if mode == Filter then Success(if call.reply.truth then [value] else [],acc,call.context) else
    var checked := Ask(ValidateResult(outputType,call.reply.value,index),call.context,env);
    if checked.reply.Error? then Failure(checked.reply.reason,checked.context) else
    if mode == Map then Success([call.reply.value],acc,checked.context) else Success([],call.reply.value,checked.context)
  }
  function Tail(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, values: seq<seq<Byte>>, index: nat, acc: seq<Byte>, c: Context, env: Environment): Outcome
    requires index <= |values|
    decreases |values|-index
  {
    if index == |values| then Success([],acc,c) else
    var next := Step(mode,inputType,outputType,values[index],index,acc,c,env);
    if next.Failure? then next else
    Prepend(next.values,Tail(mode,inputType,outputType,values,index+1,next.accumulator,next.context,env))
  }
  function Run(mode: Mode, inputType: seq<Byte>, outputType: seq<Byte>, values: seq<seq<Byte>>, initial: seq<Byte>, c: Context, env: Environment): Outcome {
    var admitted := Admission(mode,inputType,outputType,initial,c,env);
    if admitted.Failure? then admitted else Tail(mode,inputType,outputType,values,0,initial,admitted.context,env)
  }
  lemma PrependAssociative(a: seq<seq<Byte>>, b: seq<seq<Byte>>, out: Outcome)
    ensures Prepend(a,Prepend(b,out)) == Prepend(a+b,out)
  {}
}
