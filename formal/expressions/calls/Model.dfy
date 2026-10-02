// SPDX-License-Identifier: MIT
include "../scalars/Model.dfy"
module ExpressionCallModel {
  import opened AbiFrames
  import R = ResolutionModel

  datatype Error = Forbidden | InvalidTarget(index: nat, target: R.Address)
                 | NodeCallFailed(index: nat, target: R.Address, callData: seq<Byte>, reason: seq<Byte>)
                 | OutOfGas | DidNotRevert(target: R.Address, callData: seq<Byte>)
                 | Unexpected(expected: seq<Byte>, actual: seq<Byte>)
  datatype Result = Returned(data: seq<Byte>) | Failed(error: Error)
  datatype Outcome = Outcome(result: Result, history: seq<R.Request>)

  function Zero(): seq<Byte> { [0,0,0,0] }
  function Head(data: seq<Byte>): seq<Byte> {
    if |data| < 4 then Zero() else data[..4]
  }
  predicate ForbiddenRequest(target: R.Address, self: R.Address, data: seq<Byte>, selector: seq<Byte>)
    requires |selector| == 4
  { target == self && |data| >= 4 && data[..4] == selector }

  function CallResult(index: nat, target: R.Address, data: seq<Byte>, o: R.Observation): Result {
    if !o.codePresent then Failed(InvalidTarget(index,target)) else
    if o.success then Returned(o.data) else
    if R.Exhausted(o) then Failed(OutOfGas) else
    Failed(NodeCallFailed(index,target,data,o.data))
  }
  function ProbeResult(target: R.Address, data: seq<Byte>, expected: seq<Byte>, o: R.Observation): Result
    requires |expected| == 4
  {
    if !o.codePresent then
      (if expected == Zero() then Returned([]) else Failed(Unexpected(expected,Zero()))) else
    if o.success then Failed(DidNotRevert(target,data)) else
    if R.Exhausted(o) then Failed(OutOfGas) else
    if expected == Zero() then Returned(o.data) else
    if Head(o.data) != expected then Failed(Unexpected(expected,Head(o.data))) else
    Returned(o.data[4..])
  }

  // The environment sees each attempted code-presence lookup. Its observation
  // includes the actual staticcall outcome and sampled caller-frame gas when
  // that call occurs. Forbidden dispatch performs neither lookup nor call.
  function Call(index: nat, target: R.Address, self: R.Address, data: seq<Byte>, selector: seq<Byte>,
                env: R.Environment, history: seq<R.Request>): Outcome
    requires |selector| == 4
  {
    if ForbiddenRequest(target,self,data,selector) then Outcome(Failed(Forbidden),history) else
    var req := R.Call(target,data);
    Outcome(CallResult(index,target,data,env.call(history,req)),history+[req])
  }
  function Probe(target: R.Address, self: R.Address, data: seq<Byte>, selector: seq<Byte>, expected: seq<Byte>,
                 env: R.Environment, history: seq<R.Request>): Outcome
    requires |selector| == 4 && |expected| == 4
  {
    if ForbiddenRequest(target,self,data,selector) then Outcome(Failed(Forbidden),history) else
    var req := R.Call(target,data);
    Outcome(ProbeResult(target,data,expected,env.call(history,req)),history+[req])
  }

  lemma ProbeSuccess(target: R.Address, data: seq<Byte>, expected: seq<Byte>, o: R.Observation)
    requires |expected| == 4
    ensures ProbeResult(target,data,expected,o).Returned? <==>
            (!o.codePresent && expected == Zero()) ||
            (o.codePresent && !o.success && !R.Exhausted(o) &&
             (expected == Zero() || Head(o.data) == expected))
    ensures o.codePresent && ProbeResult(target,data,expected,o).Returned? && expected != Zero() ==>
              |o.data| >= 4 && o.data == expected + ProbeResult(target,data,expected,o).data
  {
    if o.codePresent && !o.success && !R.Exhausted(o) && expected != Zero() && Head(o.data) == expected {
      assert o.data == o.data[..4] + o.data[4..];
    }
  }
}
