// SPDX-License-Identifier: MIT
// Independent probe semantics, shared by the core and Expressions. Source
// correspondence and retained evidence remain separate obligations.
include "../resolution/Model.dfy"
module ProbeModel {
  import opened ConstraintModel
  import opened ResolutionModel

  datatype Error = ResolutionError(ResolutionModel.Error)
                 | DidNotRevert(target: Address, data: seq<Byte>)
                 | UnexpectedRevertData(expected: seq<Byte>, actual: seq<Byte>)
                 | RevertProbeNotACall(fetcher: Fetcher) | RevertProbeConstrained(count: nat)
  datatype Result = Reason(bytes: seq<Byte>) | Failed(error: Error)
  datatype ProbeOutcome = ProbeOutcome(result: Result, history: seq<Request>)

  function ZeroSelector(): seq<Byte> { [0,0,0,0] }
  function Head(data: seq<Byte>): seq<Byte> {
    if |data| >= 4 then data[..4] else ZeroSelector()
  }

  function Inspect(target: Address, data: seq<Byte>, expected: seq<Byte>, observation: Observation): Result
    requires |expected| == 4
  {
    if !observation.codePresent then
      (if expected == ZeroSelector() then Reason([]) else Result.Failed(UnexpectedRevertData(expected,ZeroSelector()))) else
    if observation.success then Result.Failed(DidNotRevert(target,data)) else
    if Exhausted(observation) then Result.Failed(ResolutionError(SubcallOutOfGas)) else
    if expected == ZeroSelector() then Reason(observation.data) else
    if Head(observation.data) != expected then Result.Failed(UnexpectedRevertData(expected,Head(observation.data))) else
    Reason(observation.data[4..])
  }

  function Probe(target: Address, data: seq<Byte>, expected: seq<Byte>, env: Environment, history: seq<Request>): ProbeOutcome
    requires |expected| == 4
  {
    var request := Call(target,data);
    ProbeOutcome(Inspect(target,data,expected,env.call(history,request)),history+[request])
  }

  function RevertData(param: Param, expected: seq<Byte>, env: Environment, history: seq<Request>): ProbeOutcome
    requires |expected| == 4
  {
    if param.fetcher != STATIC_CALL then ProbeOutcome(Result.Failed(RevertProbeNotACall(param.fetcher)),history) else
    if |param.constraints| != 0 then ProbeOutcome(Result.Failed(RevertProbeConstrained(|param.constraints|)),history) else
    var decoded := env.decodeCall(param.data);
    if decoded.MalformedCall? then ProbeOutcome(Result.Failed(ResolutionError(ResolutionModel.Error.BareRevert)),history)
    else Probe(decoded.target,decoded.data,expected,env,history)
  }

  lemma SelectorStripped(target: Address, data: seq<Byte>, expected: seq<Byte>, observation: Observation)
    requires |expected| == 4 && expected != ZeroSelector()
    ensures Inspect(target,data,expected,observation).Reason? ==>
              observation.codePresent && !observation.success && !Exhausted(observation) &&
              |observation.data| >= 4 && observation.data[..4] == expected &&
              expected+Inspect(target,data,expected,observation).bytes == observation.data
  {
    if Inspect(target,data,expected,observation).Reason? {
      assert observation.data == observation.data[..4]+observation.data[4..];
    }
  }

  lemma SuccessfulCallNeverPasses(target: Address, data: seq<Byte>, expected: seq<Byte>, observation: Observation)
    requires |expected| == 4 && observation.codePresent && observation.success
    ensures Inspect(target,data,expected,observation) == Result.Failed(DidNotRevert(target,data))
  {}
}
