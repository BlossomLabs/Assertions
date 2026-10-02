// SPDX-License-Identifier: MIT
include "../receipts/Connection.dfy"
include "../requests/Connection.dfy"
module ExpressionProbeInput {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import Complete = AbiParserCompleteness
  import A = ExpressionAdmission
  import B = ExpressionEvaluationBridge
  import E = ExpressionEvaluationControl
  import M = ExpressionScalarModel
  import R = ResolutionModel
  import C = ExpressionCallModel
  import W = ExpressionReceiptEncoding
  import Receipt = ExpressionReceiptConnection

  lemma BytesDescriptor(s: Descriptor)
    requires Admissible(s) && Render(s) == A.BytesType()
    ensures s == Name(A.BytesType()) && TypeOf(s) == Bytes
  {
    var text := A.BytesType();
    assert Admissible(Name(text));
    Complete.Accept(text,0,5,s);
    Complete.Accept(text,0,5,Name(text));
  }
  lemma ProbeOperandType(nodes: seq<A.Node>, types: seq<Descriptor>, index: nat, hash: seq<Byte>->nat)
    requires index < |nodes| && nodes[index].kind == A.ProbeCall
    requires A.Backwards(nodes[index].refs,index) && A.Arity(nodes,index,hash)
    requires |types| == |nodes|
    requires forall i :: 0 <= i < |types| ==> Admissible(types[i]) && Render(types[i]) == nodes[i].valueType
    requires forall i :: 0 <= i < |nodes| && hash(nodes[i].valueType) == hash(A.BytesType()) ==> nodes[i].valueType == A.BytesType()
    ensures |nodes[index].refs| == 2 && TypeOf(types[nodes[index].refs[1]]) == Bytes
  {
    var child := nodes[index].refs[1];
    assert hash(nodes[child].valueType) == hash(A.BytesType());
    assert nodes[child].valueType == A.BytesType();
    BytesDescriptor(types[child]);
  }
  predicate Decodable(value: seq<Byte>) {
    |value| >= 64 && ReadNat(value[..32]) == 32 && ReadNat(value[32..64]) <= |value|-64
  }
  function DecodeBytes(value: seq<Byte>): seq<Byte>
    requires Decodable(value)
  { value[64..64+ReadNat(value[32..64])] }

  lemma CanonicalDecode(value: seq<Byte>)
    requires Uint(|value|) && Validate(Bytes,value).Parsed?
    ensures Decodable(value)
    ensures Validate(Bytes,value).value.Buffer?
    ensures DecodeBytes(value) == Validate(Bytes,value).value.payload
    ensures value == Encode(Bytes,Buffer(DecodeBytes(value)))
  {
    ValidationSound(Bytes,value);
    var payload := Validate(Bytes,value).value.payload;
    assert value == Word(32)+Word(|payload|)+Padded(payload);
    assert |payload| < Pow256(32);
    NatBytesRoundTrip(32,32); NatBytesRoundTrip(|payload|,32);
    assert value[..32] == Word(32);
    assert value[32..64] == Word(|payload|);
    PaddingLayout(payload);
    assert value[64..64+|payload|] == payload;
  }

  method Probe(value: seq<Byte>, target: R.Address, self: R.Address, guardSelector: seq<Byte>, expected: seq<Byte>,
               env: R.Environment, history: seq<R.Request>) returns (ghost raw: E.Raw, after: seq<R.Request>)
    requires Uint(|value|) && Validate(Bytes,value).Parsed?
    requires |guardSelector| == 4 && |expected| == 4
    requires Decodable(value)
    requires |env.call(history,R.Call(target,DecodeBytes(value))).data|+96 < Pow256(32)
    ensures after == C.Probe(target,self,DecodeBytes(value),guardSelector,expected,env,history).history
    ensures var result := C.Probe(target,self,DecodeBytes(value),guardSelector,expected,env,history).result;
            if result.Returned? then raw == E.Produced(Encode(Bytes,Buffer(result.data)))
            else raw == E.Aborted(E.Error(W.Spec(result.error)))
    ensures raw.Produced? ==> Validate(Bytes,B.Narrow(raw.value)).Parsed?
  {
    CanonicalDecode(value);
    var callData := DecodeBytes(value);
    raw,after := Receipt.ProbeReceipt(target,self,callData,guardSelector,expected,env,history);
  }
}
