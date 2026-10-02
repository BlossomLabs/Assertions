// SPDX-License-Identifier: MIT
// Gated Assertions.sol source SHA-256: 8fa122e5e5750ca115c66898c22186e076eac9d95e7c91c228928a5b09ad273a
include "Guard.dfy"
include "../resolution/Source.generated.dfy"
module GuardSource {
  import opened ConstraintModel
  import opened ResolutionWords
  import opened ResolutionModel
  import opened GuardModel
  import Resolver = ResolutionSource

  ghost method OrElseSource(a: Param, b: Param, env: SelfEnvironment, history: seq<Request>) returns (out: Outcome)
    ensures out == OrElse(a,b,env,history)
  {
    var request := SelfRequest(a,env);
    var observed := env.base.call(history,request);
    var after := history+[request];
    if !observed.success {
      var head := if |observed.data| == 4 then observed.data else [0,0,0,0];
      if ((observed.gasAfter <= (observed.gasBefore / 63)) || (head == Signal())) { out := Outcome(Failed(SubcallOutOfGas),after); return; }
      out := Resolver.ResolveSource(b,Context([],0,1),env.base,after); return;
    }
    out := Outcome(Value(observed.data),after);
  }

  ghost method IsValidSource(a: Param, env: SelfEnvironment, history: seq<Request>) returns (out: Outcome)
    ensures out == IsValid(a,env,history)
  {
    var request := SelfRequest(a,env);
    var observed := env.base.call(history,request);
    var after := history+[request];
    if !observed.success {
      var head := if |observed.data| == 4 then observed.data else [0,0,0,0];
      if ((observed.gasAfter <= (observed.gasBefore / 63)) || (head == Signal())) { out := Outcome(Failed(SubcallOutOfGas),after); return; }
    }
    out := Outcome(Value(EncodeWord(if observed.success then 1 else 0)),after);
  }
  // Resolve's source body is pinned to this internal call and a raw return.
  // Relating this receipt to an actual external self-call is the ABI/call-frame
  // projection premise; the callee's resolver itself is proved here.
  ghost method ResolutionReceipt(a: Param, frame: Environment, history: seq<Request>, errorBytes: ResolutionModel.Error -> seq<Byte>, gasBefore: Word, gasAfter: Word) returns (observed: Observation)
    ensures MatchesResolution(a,observed,frame,history,errorBytes)
  {
    var resolved := Resolver.ResolveSource(a,Context([],0,0),frame,history);
    observed := Observation(true,resolved.result.Value?,if resolved.result.Value? then resolved.result.bytes else errorBytes(resolved.result.error),gasBefore,gasAfter);
  }

}
