// SPDX-License-Identifier: MIT
include "../entry/Connection.dfy"
include "../admission-errors/Connection.dfy"
include "../encoded/Connection.dfy"
module ExpressionSelfCallConnection {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiShapeSemantics
  import opened AbiConnectionModel
  import Cache = ExpressionCache
  import K = ConstraintModel
  import R = ResolutionModel
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import A = ExpressionAdmission
  import O = ExpressionOracleModel
  import Entry = ExpressionEntryConnection
  import Bounds = ExpressionAdmissionErrorBounds
  import AdmissionBytes = ExpressionAdmissionErrors
  import Encoded = ExpressionEncodedModel
  import Wrapper = ExpressionEncodedConnection
  import Calls = ExpressionCallModel
  import W = ExpressionReceiptEncoding

  datatype Gas = Gas(before: K.Word, after: K.Word)

  ghost function Raw(inner: Entry.Outcome): E.Raw {
    if inner.AdmissionRejected? then E.Aborted(E.Error(AdmissionBytes.Encoded(inner.error))) else inner.raw
  }
  predicate ByteRaw(raw: E.Raw) {
    if raw.Produced? then B.Bytes(raw.value) else B.Bytes(raw.error.payload)
  }
  function Payload(raw: E.Raw): seq<Byte>
    requires ByteRaw(raw)
  { if raw.Produced? then B.Narrow(raw.value) else B.Narrow(raw.error.payload) }
  function Observe(raw: E.Raw, gas: Gas): R.Observation
    requires ByteRaw(raw)
  { R.Observation(true,raw.Produced?,Payload(raw),gas.before,gas.after) }
  function Install(base: R.Environment, history: seq<R.Request>, request: R.Request, observed: R.Observation): R.Environment {
    R.Environment((h: seq<R.Request>,q: R.Request) => if h == history && q == request then observed else base.call(h,q),
                  base.balance,base.decodeCall,base.decodeOr)
  }
  lemma InstalledCall(base: R.Environment, history: seq<R.Request>, request: R.Request, observed: R.Observation)
    ensures Install(base,history,request,observed).call(history,request) == observed
    ensures forall h,q :: h != history || q != request ==>
                            Install(base,history,request,observed).call(h,q) == base.call(h,q)
    ensures Install(base,history,request,observed).balance == base.balance
    ensures Install(base,history,request,observed).decodeCall == base.decodeCall && Install(base,history,request,observed).decodeOr == base.decodeOr
  {}
  function Verdict(raw: E.Raw, callData: seq<Byte>, self: R.Address, gas: Gas): E.Raw
    requires ByteRaw(raw)
  {
    if raw.Produced? then raw else
    if R.Exhausted(Observe(raw,gas)) then E.Aborted(E.Error(R.Signal())) else
    E.Aborted(E.Error(W.Encoded(Calls.NodeCallFailed(0,self,callData,Payload(raw)))))
  }

  ghost method Compose(c: O.Config, result: nat, hash: seq<Byte>->nat, reject: (nat,E.Value)->E.Error,
                       data: seq<Byte>, decode: seq<Byte>->Encoded.Decode, gas: Gas,
                       base: R.Environment, history: seq<R.Request>)
    returns (inner: Entry.Outcome, outer: Encoded.Outcome, linked: R.Environment, covered: bool)
    requires Bounds.WordNodes(c.nodes) && Uint(result)
    requires forall i: nat,v: E.Value :: i < |c.nodes| ==> B.Bytes(reject(i,v).payload)
    requires decode(data) == Encoded.Decoded(Encoded.Graph(c.core,c.nodes,result))
    requires Encoded.Wire(Encoded.Graph(c.core,c.nodes,result),c.parameters)
    ensures inner.AdmissionRejected? <==> A.Admit(c.nodes,result,hash).Rejected?
    ensures inner.AdmissionRejected? ==> inner.error == A.Admit(c.nodes,result,hash).error &&
                                         AdmissionBytes.Fits(inner.error) && Raw(inner).error.payload == AdmissionBytes.Spec(inner.error)
    ensures ByteRaw(Raw(inner))
    ensures inner.Evaluated? ==> result < |inner.types| && Cache.Types(inner.types)
    ensures inner.Evaluated? && inner.raw.Produced? ==>
              Validate(TypeOf(inner.types[result]),B.Narrow(inner.raw.value)).Parsed? &&
              WellTyped(TypeOf(inner.types[result]),Validate(TypeOf(inner.types[result]),B.Narrow(inner.raw.value)).value) &&
              B.Narrow(inner.raw.value) == Encode(TypeOf(inner.types[result]),Validate(TypeOf(inner.types[result]),B.Narrow(inner.raw.value)).value)
    ensures covered == (inner.AdmissionRejected? || inner.covered)
    ensures inner.Evaluated? && covered ==> O.Covered(c,inner.execution.history) && O.ValidTrace(c,inner.execution.history,inner.replies)
    ensures linked == Install(base,history,R.Call(c.self,Encoded.CallData(Encoded.Graph(c.core,c.nodes,result),c.parameters)),Observe(Raw(inner),gas))
    ensures outer == Encoded.Spec(data,c.parameters,c.self,decode,linked,history)
    ensures outer.history == history+[R.Call(c.self,Encoded.CallData(Encoded.Graph(c.core,c.nodes,result),c.parameters))]
    ensures outer.raw == Verdict(Raw(inner),Encoded.CallData(Encoded.Graph(c.core,c.nodes,result),c.parameters),c.self,gas)
    ensures outer.raw.Produced? <==> inner.Evaluated? && inner.raw.Produced?
    ensures outer.raw.Produced? ==> outer.raw == inner.raw
  {
    inner := Entry.Evaluate(c,result,hash,reject);
    if inner.AdmissionRejected? {
      Bounds.AdmissionFields(c.nodes,result,hash);
      AdmissionBytes.Exact(inner.error);
      B.ByteIdentity(AdmissionBytes.Encoded(inner.error));
    }
    var raw := Raw(inner);
    assert ByteRaw(raw);
    var callData := Encoded.CallData(Encoded.Graph(c.core,c.nodes,result),c.parameters);
    var observed := Observe(raw,gas);
    linked := Install(base,history,R.Call(c.self,callData),observed);
    InstalledCall(base,history,R.Call(c.self,callData),observed);
    outer := Encoded.Spec(data,c.parameters,c.self,decode,linked,history);
    Wrapper.Outcomes(data,c.parameters,c.self,decode,linked,history);
    if raw.Produced? { assert B.Narrow(raw.value) == raw.value; }
    covered := inner.AdmissionRejected? || inner.covered;
  }

}
