// SPDX-License-Identifier: MIT
include "../evaluation/CacheBridge.dfy"
module ExpressionScalarModel {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import B = ExpressionEvaluationBridge
  import E = ExpressionEvaluationControl
  import R = ResolutionModel

  datatype Error = BadNode(index: nat) | BadReference(index: nat, reference: nat)
  datatype ScalarResult = ValueResult(data: seq<Byte>) | Rejected(error: Error)
  datatype AddressResult = Addressed(address: nat) | InvalidAddress(index: nat)

  function NodeSelector(): seq<Byte> { [0x64,0xa4,0x24,0x93] }
  function ReferenceSelector(): seq<Byte> { [0x10,0x15,0x86,0xe0] }
  function ErrorBytes(error: Error): seq<Byte> {
    match error
    case BadNode(index) => NodeSelector()+Word(index)
    case BadReference(index,reference) => ReferenceSelector()+Word(index)+Word(reference)
  }
  lemma ErrorWords(error: Error)
    requires Uint(error.index) && (error.BadReference? ==> Uint(error.reference))
    ensures |ErrorBytes(error)| == (if error.BadNode? then 36 else 68)
    ensures ReadNat(ErrorBytes(error)[4..36]) == error.index
    ensures error.BadReference? ==> ReadNat(ErrorBytes(error)[36..68]) == error.reference
  {
    NatBytesRoundTrip(error.index,32);
    assert ReadNat(Word(error.index)) == error.index;
    var encoded := ErrorBytes(error);
    if error.BadReference? {
      NatBytesRoundTrip(error.reference,32);
      assert ReadNat(Word(error.reference)) == error.reference;
      assert encoded == ReferenceSelector()+Word(error.index)+Word(error.reference);
      assert encoded[4..36] == Word(error.index);
      assert encoded[36..68] == Word(error.reference);
    } else {
      assert encoded == NodeSelector()+Word(error.index);
      assert encoded[4..36] == Word(error.index);
    }
  }
  function Receipt(result: ScalarResult): E.Raw {
    if result.ValueResult? then E.Produced(result.data) else E.Aborted(E.Error(ErrorBytes(result.error)))
  }
  function ParameterSpec(index: nat, data: seq<Byte>, parameters: seq<seq<Byte>>): ScalarResult {
    if |data| != 32 then ScalarResult.Rejected(BadNode(index)) else
    var parameter := ReadNat(data);
    if parameter >= |parameters| then ScalarResult.Rejected(BadReference(index,parameter)) else ValueResult(parameters[parameter])
  }
  function AddressSpec(index: nat, data: seq<Byte>): AddressResult {
    if |data| != 32 then InvalidAddress(index) else
    if ReadNat(data) >= Pow256(20) then InvalidAddress(index) else Addressed(ReadNat(data))
  }
  function TotalTruth(value: E.Value): bool {
    B.Bytes(value) && |value| >= 32 && ReadNat(B.Narrow(value)[..32]) != 0
  }
  function GuardSpec(observed: R.Observation): E.Raw {
    if R.Exhausted(observed) then E.Aborted(E.Error(R.Signal())) else E.Produced([])
  }

  lemma CanonicalHasWord(t: AbiType, value: seq<Byte>)
    requires WellFormed(t) && Validate(t,value).Parsed?
    ensures |value| >= 32
  {
    ValidationSound(t,value);
    BodiesAreFrames(t,Validate(t,value).value);
  }

  lemma CanonicalTruth(t: AbiType, value: seq<Byte>)
    requires WellFormed(t) && Validate(t,value).Parsed?
    ensures |value| >= 32 && TotalTruth(value) == (ReadNat(value[..32]) != 0)
    ensures IsDynamic(t) ==> TotalTruth(value)
  {
    CanonicalHasWord(t,value);
    B.ByteIdentity(value);
    if IsDynamic(t) {
      ValidationSound(t,value);
      SingleValueEnvelope(t,Validate(t,value).value);
    }
  }

  lemma BooleanEncoding(flag: bool)
    ensures WellTyped(Scalar(Boolean),Atom(if flag then 1 else 0))
    ensures Word(if flag then 1 else 0) == Encode(Scalar(Boolean),Atom(if flag then 1 else 0))
    ensures Validate(Scalar(Boolean),Word(if flag then 1 else 0)).Parsed?
    ensures |Word(if flag then 1 else 0)| == 32
  {
    NatBytesRoundTrip(if flag then 1 else 0,32);
    ValidationComplete(Scalar(Boolean),Atom(if flag then 1 else 0));
  }
}
