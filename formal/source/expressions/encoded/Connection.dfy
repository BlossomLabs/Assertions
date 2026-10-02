// SPDX-License-Identifier: MIT
include "Source.generated.dfy"
include "../returns/Source.generated.dfy"
module ExpressionEncodedConnection {
  import opened AbiFrames
  import M = ExpressionEncodedModel
  import Source = ExpressionEncodedSource
  import R = ResolutionModel
  import C = ExpressionCallModel
  import W = ExpressionReceiptEncoding
  import Receipt = ExpressionReceiptConnection
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import Memory = ExpressionReturnMemory
  import Return = ExpressionReturnSource

  lemma Outcomes(data: seq<Byte>, parameters: seq<seq<Byte>>, self: R.Address, decode: seq<Byte>->M.Decode,
                 env: R.Environment, history: seq<R.Request>)
    requires decode(data).Decoded? ==> M.Wire(decode(data).graph,parameters)
    ensures decode(data).Malformed? ==> M.Spec(data,parameters,self,decode,env,history) == M.Outcome(E.Aborted(E.Error([])),history)
    ensures decode(data).Decoded? ==>
              M.Spec(data,parameters,self,decode,env,history).history == history+[R.Call(self,M.CallData(decode(data).graph,parameters))]
    ensures decode(data).Decoded? ==>
              var callData := M.CallData(decode(data).graph,parameters);
              var observed := env.call(history,R.Call(self,callData));
              var raw := M.Spec(data,parameters,self,decode,env,history).raw;
              raw == (if !observed.codePresent then E.Aborted(E.Error(W.Encoded(C.InvalidTarget(0,self))))
                      else if observed.success then E.Produced(observed.data)
                      else if R.Exhausted(observed) then E.Aborted(E.Error(R.Signal()))
                      else E.Aborted(E.Error(W.Encoded(C.NodeCallFailed(0,self,callData,observed.data)))))
  {
    if decode(data).Decoded? {
      var callData := M.CallData(decode(data).graph,parameters);
      M.CallDataPrefix(decode(data).graph,parameters);
      Receipt.CallFields(0,self,self,callData,M.GuardSelector(),env,history);
      var called := C.Call(0,self,self,callData,M.GuardSelector(),env,history);
      if called.result.Failed? { W.EncodingCorrespondence(called.result.error); }
    }
  }

  // Completes the already-proved source wrapper with its concrete memory tail.
  method WithReturn(data: seq<Byte>, parameters: seq<seq<Byte>>, self: R.Address, decode: seq<Byte>->M.Decode,
                    env: R.Environment, history: seq<R.Request>, memory: seq<Byte>, pointer: nat)
    returns (ghost out: M.Outcome)
    requires decode(data).Decoded? ==> M.Wire(decode(data).graph,parameters)
    requires M.Spec(data,parameters,self,decode,env,history).raw.Produced? ==>
               B.Bytes(M.Spec(data,parameters,self,decode,env,history).raw.value) &&
               Memory.Object(memory,pointer,B.Narrow(M.Spec(data,parameters,self,decode,env,history).raw.value))
    ensures out == M.Spec(data,parameters,self,decode,env,history)
  {
    out := Source.EvaluateEncoded(data,parameters,self,decode,env,history);
    if out.raw.Produced? {
      var returned := Return.EncodedReturn(memory,pointer,B.Narrow(out.raw.value));
      assert B.Narrow(out.raw.value) == out.raw.value;
      out := M.Outcome(E.Produced(returned),out.history);
    }
  }
}
