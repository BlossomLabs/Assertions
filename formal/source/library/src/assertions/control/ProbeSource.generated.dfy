// SPDX-License-Identifier: MIT
// Gated Assertions.sol source SHA-256: 8fa122e5e5750ca115c66898c22186e076eac9d95e7c91c228928a5b09ad273a
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
    if ((observed.gasAfter <= (observed.gasBefore / 63)) || (head == Signal())) {
      r := ProbeModel.Result.Failed(ResolutionError(SubcallOutOfGas)); return;
    }
    if expected == ZeroSelector() { r := Reason(observation.data); return; }
    var actual := ZeroSelector();
    if (|observed.data| >= 4) { actual := observation.data[..4]; }
    if actual != expected { r := ProbeModel.Result.Failed(UnexpectedRevertData(expected,actual)); return; }
    assert |observation.data| >= 4;
    r := Reason(observation.data[4..]);
  }

  ghost method RevertDataSource(param: Param, expected: seq<Byte>, env: Environment, history: seq<Request>) returns (out: ProbeOutcome)
    requires |expected| == 4
    ensures out == RevertData(param,expected,env,history)
  {
    if (param.fetcher != STATIC_CALL) { out := ProbeOutcome(ProbeModel.Result.Failed(RevertProbeNotACall(param.fetcher)),history); return; }
    if (|param.constraints| != 0) { out := ProbeOutcome(ProbeModel.Result.Failed(RevertProbeConstrained(|param.constraints|)),history); return; }
    var decoded := env.decodeCall(param.data);
    if decoded.MalformedCall? { out := ProbeOutcome(ProbeModel.Result.Failed(ResolutionError(ResolutionModel.Error.BareRevert)),history); return; }
    var request := Call(decoded.target,decoded.data);
    var observed := env.call(history,request);
    var result := InspectSource(decoded.target,decoded.data,expected,observed);
    out := ProbeOutcome(result,history+[request]);
  }
}
