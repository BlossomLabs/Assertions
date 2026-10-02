// SPDX-License-Identifier: MIT
include "Encoding.dfy"
module ExpressionReceiptConnection {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import C = ExpressionCallModel
  import S = ExpressionCallSource
  import R = ResolutionModel
  import E = ExpressionEvaluationControl
  import ExpressionEvaluationBridge
  import W = ExpressionReceiptEncoding

  lemma CallFields(index: nat, target: R.Address, self: R.Address, data: seq<Byte>, selector: seq<Byte>,
                   env: R.Environment, history: seq<R.Request>)
    requires |selector| == 4 && index < Pow256(32)
    ensures C.Call(index,target,self,data,selector,env,history).result.Failed? ==>
              W.Fields(C.Call(index,target,self,data,selector,env,history).result.error)
  {}
  lemma ProbeFields(target: R.Address, self: R.Address, data: seq<Byte>, selector: seq<Byte>, expected: seq<Byte>,
                    env: R.Environment, history: seq<R.Request>)
    requires |selector| == 4 && |expected| == 4
    ensures C.Probe(target,self,data,selector,expected,env,history).result.Failed? ==>
              W.Fields(C.Probe(target,self,data,selector,expected,env,history).result.error)
  {}
  method CallReceipt(index: nat, target: R.Address, self: R.Address, data: seq<Byte>, selector: seq<Byte>,
                     env: R.Environment, history: seq<R.Request>) returns (ghost raw: E.Raw, after: seq<R.Request>)
    requires |selector| == 4 && index < Pow256(32)
    ensures after == C.Call(index,target,self,data,selector,env,history).history
    ensures var result := C.Call(index,target,self,data,selector,env,history).result;
            if result.Returned? then raw == E.Produced(result.data)
            else raw == E.Aborted(E.Error(W.Spec(result.error)))
  {
    var out := S.Call(index,target,self,data,selector,env,history);
    CallFields(index,target,self,data,selector,env,history);
    if out.result.Failed? { W.EncodingCorrespondence(out.result.error); }
    raw := W.Receipt(out.result); after := out.history;
  }
  method ProbeReceipt(target: R.Address, self: R.Address, data: seq<Byte>, selector: seq<Byte>, expected: seq<Byte>,
                      env: R.Environment, history: seq<R.Request>) returns (ghost raw: E.Raw, after: seq<R.Request>)
    requires |selector| == 4 && |expected| == 4
    requires |env.call(history,R.Call(target,data)).data|+96 < Pow256(32)
    ensures after == C.Probe(target,self,data,selector,expected,env,history).history
    ensures var result := C.Probe(target,self,data,selector,expected,env,history).result;
            if result.Returned? then raw == E.Produced(Encode(Bytes,Buffer(result.data)))
            else raw == E.Aborted(E.Error(W.Spec(result.error)))
    ensures raw.Produced? ==> Validate(Bytes,ExpressionEvaluationBridge.Narrow(raw.value)).Parsed?
  {
    var out := S.Probe(target,self,data,selector,expected,env,history);
    ProbeFields(target,self,data,selector,expected,env,history);
    after := out.history;
    if out.result.Failed? {
      W.EncodingCorrespondence(out.result.error);
      raw := W.Receipt(out.result);
    } else {
      var encoded := Encode(Bytes,Buffer(out.result.data));
      PaddingLayout(out.result.data);
      assert |out.result.data| <= |env.call(history,R.Call(target,data)).data|;
      ValidationComplete(Bytes,Buffer(out.result.data));
      ExpressionEvaluationBridge.ByteIdentity(encoded);
      raw := E.Produced(encoded);
    }
  }
}
