// SPDX-License-Identifier: MIT
// Resolve branch from Expressions.sol $HASH.
include "Model.dfy"
module ExpressionResolveSource {
  import opened AbiFrames
  import opened ExpressionResolveModel
  import R = ResolutionModel
  import E = ExpressionEvaluationControl
  import ReceiptSource = ExpressionReceiptConnection

  method Resolve(data: seq<Byte>, index: nat, core: R.Address, self: R.Address,
                 resolveSelector: seq<Byte>, guardSelector: seq<Byte>, decode: seq<Byte>->Decode,
                 env: R.Environment, history: seq<R.Request>) returns (ghost out: Outcome)
    requires |resolveSelector| == 4 && |guardSelector| == 4 && index < Pow256(32)
    ensures out == Spec(data,index,core,self,resolveSelector,guardSelector,decode,env,history)
    ensures decode(data).Malformed? ==> out == Outcome(E.Aborted(E.Error([])),history)
  {
    var source := decode(data);
    if source.Malformed? { out := Outcome(E.Aborted(E.Error([])),history); return; }
    var calldata := CallData(source.param,resolveSelector);
    var raw,after := ReceiptSource.CallReceipt($NODE_INDEX,core,self,calldata,guardSelector,env,history);
    out := Outcome(raw,after);
  }
}
