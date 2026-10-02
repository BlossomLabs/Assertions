// SPDX-License-Identifier: MIT
include "Probe.dfy"
include "../resolution/Words.dfy"
module GuardModel {
  import opened ConstraintModel
  import opened ResolutionWords
  import opened ResolutionModel

  // The outer frame records the self-call as one call attempt. Its inner frame
  // has its own history/context, exactly like any external-call observation.
  datatype SelfEnvironment = SelfEnvironment(core: Address, encodeResolve: Param -> seq<Byte>, base: Environment)

  function SelfRequest(param: Param, env: SelfEnvironment): Request {
    Call(env.core,env.encodeResolve(param))
  }

  function Observed(param: Param, env: SelfEnvironment, history: seq<Request>): Observation {
    env.base.call(history,SelfRequest(param,env))
  }

  function OrElse(a: Param, b: Param, env: SelfEnvironment, history: seq<Request>): Outcome {
    var request := SelfRequest(a,env);
    var observed := env.base.call(history,request);
    var after := history+[request];
    if observed.success then Outcome(Value(observed.data),after) else
    if Exhausted(observed) then Outcome(Failed(SubcallOutOfGas),after) else
    Resolve(b,Context([],0,1),env.base,after)
  }

  function IsValid(a: Param, env: SelfEnvironment, history: seq<Request>): Outcome {
    var observed := Observed(a,env,history);
    var after := history+[SelfRequest(a,env)];
    if !observed.success && Exhausted(observed) then Outcome(Failed(SubcallOutOfGas),after)
    else Outcome(Value(EncodeWord(if observed.success then 1 else 0)),after)
  }

  // The call-boundary premise relates actual self-call observations to the
  // proved resolver in the callee's context. It does not identify gas/sender
  // environments across frames or assume repeated target calls deterministic.
  predicate MatchesResolution(a: Param, observation: Observation, frame: Environment, innerHistory: seq<Request>, errorBytes: ResolutionModel.Error -> seq<Byte>) {
    var resolved := Resolve(a,Context([],0,0),frame,innerHistory);
    observation.success == resolved.result.Value? &&
    observation.data == (if resolved.result.Value? then resolved.result.bytes else errorBytes(resolved.result.error))
  }

  lemma ValidityFromResolution(a: Param, env: SelfEnvironment, history: seq<Request>, frame: Environment, innerHistory: seq<Request>, errorBytes: ResolutionModel.Error -> seq<Byte>)
    requires MatchesResolution(a,Observed(a,env,history),frame,innerHistory,errorBytes)
    requires Observed(a,env,history).success || !Exhausted(Observed(a,env,history))
    ensures IsValid(a,env,history) == Outcome(Value(EncodeWord(if Resolve(a,Context([],0,0),frame,innerHistory).result.Value? then 1 else 0)),history+[SelfRequest(a,env)])
    ensures IsValid(a,env,history).result.bytes == EncodeWord(1) <==>
            Fetch(a,Context([],0,0),frame,innerHistory).result.Value? &&
            |a.constraints| <= |Fetch(a,Context([],0,0),frame,innerHistory).result.bytes|/32 &&
            (forall i :: 0 <= i < |a.constraints| ==>
                           Judge(Read(Fetch(a,Context([],0,0),frame,innerHistory).result.bytes[32*i..32*i+32]),a.constraints[i],frame.decodeOr) == Yes)
  {
    ResolveSuccess(a,Context([],0,0),frame,innerHistory);
    EncodedWord(0); EncodedWord(1);
  }

  lemma SuccessfulAttemptPreserved(a: Param, b: Param, env: SelfEnvironment, history: seq<Request>, frame: Environment, innerHistory: seq<Request>, errorBytes: ResolutionModel.Error -> seq<Byte>)
    requires MatchesResolution(a,Observed(a,env,history),frame,innerHistory,errorBytes)
    requires Resolve(a,Context([],0,0),frame,innerHistory).result.Value?
    ensures OrElse(a,b,env,history) == Outcome(Resolve(a,Context([],0,0),frame,innerHistory).result,history+[SelfRequest(a,env)])
  {}

  lemma ExhaustionSurvivesSelfCall(a: Param, b: Param, env: SelfEnvironment, history: seq<Request>, frame: Environment, innerHistory: seq<Request>, errorBytes: ResolutionModel.Error -> seq<Byte>)
    requires errorBytes(SubcallOutOfGas) == Signal()
    requires MatchesResolution(a,Observed(a,env,history),frame,innerHistory,errorBytes)
    requires Resolve(a,Context([],0,0),frame,innerHistory).result == Failed(SubcallOutOfGas)
    ensures OrElse(a,b,env,history) == Outcome(Failed(SubcallOutOfGas),history+[SelfRequest(a,env)])
    ensures IsValid(a,env,history) == Outcome(Failed(SubcallOutOfGas),history+[SelfRequest(a,env)])
  {}
}
