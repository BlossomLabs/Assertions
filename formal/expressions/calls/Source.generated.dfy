// SPDX-License-Identifier: MIT
// Gated source projection from Expressions.sol dc53eb78d3550ded3d9dce3f61172a9a16e103a6be33cea95b1de04701c7124d.
include "Model.dfy"
include "../scalars/Source.generated.dfy"
module ExpressionCallSource {
  import opened AbiFrames
  import opened ExpressionCallModel
  import R = ResolutionModel
  import S = ExpressionScalarSource

  method CheckPublicCall(target: R.Address, self: R.Address, data: seq<Byte>, selector: seq<Byte>) returns (allowed: bool)
    requires |selector| == 4
    ensures allowed == !ForbiddenRequest(target,self,data,selector)
  {
    if target == self && |data| >= 4 && data[..4] == selector { allowed := false; return; }
    allowed := true;
  }

  method Call(index: nat, target: R.Address, self: R.Address, data: seq<Byte>, selector: seq<Byte>,
              env: R.Environment, history: seq<R.Request>) returns (out: Outcome)
    requires |selector| == 4
    ensures out == ExpressionCallModel.Call(index,target,self,data,selector,env,history)
  {
    var allowed := CheckPublicCall(target,self,data,selector);
    if !allowed { out := Outcome(Failed(Forbidden),history); return; }
    var req := R.Call(target,data);
    var o := env.call(history,req);
    var after := history+[req];
    if !o.codePresent { out := Outcome(Failed(InvalidTarget(index,target)),after); return; }
    if !o.success {
      var guard := S.GuardFailure(o);
      if guard.Aborted? { out := Outcome(Failed(OutOfGas),after); return; }
      out := Outcome(Failed(NodeCallFailed(index,target,data,o.data)),after); return;
    }
    out := Outcome(Returned(o.data),after);
  }

  method Probe(target: R.Address, self: R.Address, data: seq<Byte>, selector: seq<Byte>, expected: seq<Byte>,
               env: R.Environment, history: seq<R.Request>) returns (out: Outcome)
    requires |selector| == 4 && |expected| == 4
    ensures out == ExpressionCallModel.Probe(target,self,data,selector,expected,env,history)
  {
    var allowed := CheckPublicCall(target,self,data,selector);
    if !allowed { out := Outcome(Failed(Forbidden),history); return; }
    var req := R.Call(target,data);
    var o := env.call(history,req);
    var after := history+[req];
    if !o.codePresent {
      if expected != Zero() { out := Outcome(Failed(Unexpected(expected,Zero())),after); return; }
      out := Outcome(Returned([]),after); return;
    }
    if o.success { out := Outcome(Failed(DidNotRevert(target,data)),after); return; }
    var guard := S.GuardFailure(o);
    if guard.Aborted? { out := Outcome(Failed(OutOfGas),after); return; }
    if expected == Zero() { out := Outcome(Returned(o.data),after); return; }
    var actual := Zero();
    if |o.data| >= 4 { actual := o.data[..4]; }
    assert actual == Head(o.data);
    if actual != expected { out := Outcome(Failed(Unexpected(expected,actual)),after); return; }
    assert |o.data| >= 4;
    // Solidity subtraction is safe here; the slice projection is the exact
    // in-range byte sequence. Allocation/resource success remains a premise.
    var size := |o.data|-4;
    assert 4+size == |o.data|;
    assert o.data[4..4+size] == o.data[4..];
    out := Outcome(Returned(o.data[4..4+size]),after);
  }
}
