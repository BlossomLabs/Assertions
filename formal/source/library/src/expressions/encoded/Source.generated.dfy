// SPDX-License-Identifier: MIT
// evaluateEncoded from Expressions.sol SHA-256: dc53eb78d3550ded3d9dce3f61172a9a16e103a6be33cea95b1de04701c7124d
include "Model.dfy"
module ExpressionEncodedSource {
  import opened AbiFrames
  import opened ExpressionEncodedModel
  import R = ResolutionModel
  import E = ExpressionEvaluationControl
  import Receipt = ExpressionReceiptConnection

  method EvaluateEncoded(data: seq<Byte>, parameters: seq<seq<Byte>>, self: R.Address, decode: seq<Byte>->Decode,
                         env: R.Environment, history: seq<R.Request>) returns (ghost out: Outcome)
    requires decode(data).Decoded? ==> Wire(decode(data).graph,parameters)
    ensures out == Spec(data,parameters,self,decode,env,history)
    ensures decode(data).Malformed? ==> out == Outcome(E.Aborted(E.Error([])),history)
  {
    var decoded := decode(data);
    if decoded.Malformed? { out := Outcome(E.Aborted(E.Error([])),history); return; }
    var calldata := CallData(decoded.graph,parameters);
    var raw,after := Receipt.CallReceipt(0,self,self,calldata,GuardSelector(),env,history);
    out := Outcome(raw,after);
  }
}
