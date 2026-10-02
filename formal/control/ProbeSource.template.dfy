// SPDX-License-Identifier: MIT
// Gated Assertions.sol source SHA-256: $HASH
include "Probe.dfy"
module ProbeSource {
  import opened ConstraintModel
  import opened ResolutionModel
  import opened ProbeModel

  ghost method InspectSource(target: Address, data: seq<Byte>, expected: seq<Byte>, observation: Observation) returns (r: ProbeModel.Result)
    requires |expected| == 4
    ensures r == Inspect(target,data,expected,observation)
  {
    var observed := observation;
    if !observation.codePresent {
      if expected != ZeroSelector() { r := ProbeModel.Result.Failed(UnexpectedRevertData(expected,ZeroSelector())); return; }
      r := Reason([]); return;
    }
    if observation.success { r := ProbeModel.Result.Failed(DidNotRevert(target,data)); return; }
    var head := if |observation.data| == 4 then observation.data else ZeroSelector();
    if $GUARD_EXHAUSTED {
      r := ProbeModel.Result.Failed(ResolutionError(SubcallOutOfGas)); return;
    }
    if expected == ZeroSelector() { r := Reason(observation.data); return; }
    var actual := ZeroSelector();
    if $PROBE_HEAD_LENGTH { actual := observation.data[..4]; }
    if actual != expected { r := ProbeModel.Result.Failed(UnexpectedRevertData(expected,actual)); return; }
    assert |observation.data| >= 4;
    r := Reason(observation.data[4..]);
  }

  ghost method RevertDataSource(param: Param, expected: seq<Byte>, env: Environment, history: seq<Request>) returns (out: ProbeOutcome)
    requires |expected| == 4
    ensures out == RevertData(param,expected,env,history)
  {
    if $PROBE_FETCHER_CHECK { out := ProbeOutcome(ProbeModel.Result.Failed(RevertProbeNotACall(param.fetcher)),history); return; }
    if $PROBE_CONSTRAINED { out := ProbeOutcome(ProbeModel.Result.Failed(RevertProbeConstrained(|param.constraints|)),history); return; }
    var decoded := env.decodeCall(param.data);
    if decoded.MalformedCall? { out := ProbeOutcome(ProbeModel.Result.Failed(ResolutionError(ResolutionModel.Error.BareRevert)),history); return; }
    var request := Call(decoded.target,decoded.data);
    var observed := env.call(history,request);
    var result := InspectSource(decoded.target,decoded.data,expected,observed);
    out := ProbeOutcome(result,history+[request]);
  }
}
