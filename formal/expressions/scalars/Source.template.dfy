// SPDX-License-Identifier: MIT
// Selected scalar source paths in Expressions.sol $HASH.
include "Model.dfy"
include "../../abi/source/BytesBody.generated.dfy"
module ExpressionScalarSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened ExpressionScalarModel
  import B = ExpressionEvaluationBridge
  import E = ExpressionEvaluationControl
  import R = ResolutionModel
  import AbiBytesSource

  method Literal(data: seq<Byte>) returns (value: seq<Byte>)
    ensures value == data
  { value := data; }

  ghost method Parameter(index: nat, data: seq<Byte>, parameters: seq<seq<Byte>>) returns (result: ScalarResult)
    requires Uint(index) && Uint(|data|)
    ensures result == ParameterSpec(index,data,parameters)
    ensures result.Rejected? ==> Uint(result.error.index) && (result.error.BadReference? ==> Uint(result.error.reference))
  {
    if |data| != 32 { result := ScalarResult.Rejected(BadNode(index)); return; }
    var decoded := AbiBytesSource.ReadWord(data,0);
    assert data[0..32] == data;
    assert decoded == Ok(ReadNat(data));
    var parameter := decoded.used;
    if parameter $PARAMETER_BOUND |parameters| { result := ScalarResult.Rejected(BadReference(index,parameter)); return; }
    result := ValueResult(parameters[parameter]);
  }

  ghost method Address(index: nat, data: seq<Byte>) returns (result: AddressResult)
    requires Uint(index) && Uint(|data|)
    ensures result == AddressSpec(index,data)
    ensures result.Addressed? ==> result.address < Pow256(20)
  {
    if |data| != 32 { result := InvalidAddress(index); return; }
    var word := AbiBytesSource.ReadWord(data,0);
    assert data[0..32] == data;
    assert word == Ok(ReadNat(data));
    if word.used $ADDRESS_BOUND Pow256(20)-1 { result := InvalidAddress(index); return; }
    result := Addressed(word.used);
  }

  ghost method Truth(value: seq<Byte>) returns (chosen: bool)
    requires Uint(|value|) && |value| >= 32
    ensures chosen == (ReadNat(value[..32]) != 0)
    ensures chosen == TotalTruth(value)
  {
    var word := AbiBytesSource.ReadWord(value,0);
    assert word.Ok?;
    chosen := word.used $TRUTH_OPERATOR 0;
    B.ByteIdentity(value);
  }

  ghost method TypedTruth(t: AbiType, value: seq<Byte>) returns (chosen: bool)
    requires WellFormed(t) && Validate(t,value).Parsed? && Uint(|value|)
    ensures chosen == TotalTruth(value)
    ensures IsDynamic(t) ==> chosen
  {
    CanonicalTruth(t,value);
    chosen := Truth(value);
  }

  ghost method BooleanValue(success: bool) returns (encoded: seq<Byte>)
    ensures encoded == Word(if success then 1 else 0)
    ensures Validate(Scalar(Boolean),encoded).Parsed?
  {
    encoded := Word(if success then 1 else 0);
    BooleanEncoding(success);
  }

  method LiteralReceipt(data: seq<Byte>) returns (out: E.Raw)
    ensures out == E.Produced(data)
  {
    var value := Literal(data);
    out := E.Produced(value);
  }

  ghost method BooleanReceipt(success: bool) returns (out: E.Raw)
    ensures out == E.Produced(Word(if success then 1 else 0))
  {
    var value := BooleanValue(success);
    out := E.Produced(value);
  }

  method GuardFailure(observed: R.Observation) returns (out: E.Raw)
    ensures out == GuardSpec(observed)
  {
    var head: seq<Byte> := [0,0,0,0];
    if |observed.data| == 4 { head := observed.data; }
    if observed.gasAfter <= observed.gasBefore/63 $GUARD_OPERATOR head == R.Signal() {
      out := E.Aborted(E.Error(R.Signal())); return;
    }
    out := E.Produced([]);
  }

  ghost method ParameterReceipt(index: nat, data: seq<Byte>, parameters: seq<seq<Byte>>) returns (out: E.Raw)
    requires Uint(index) && Uint(|data|)
    ensures out == Receipt(ParameterSpec(index,data,parameters))
  {
    var result := Parameter(index,data,parameters);
    out := Receipt(result);
  }

  ghost method AddressReceipt(index: nat, data: seq<Byte>) returns (out: E.Raw)
    requires Uint(index) && Uint(|data|)
    ensures out == (if AddressSpec(index,data).Addressed? then E.Produced(data) else E.Aborted(E.Error(ErrorBytes(BadNode(index)))))
  {
    var result := Address(index,data);
    out := if result.Addressed? then E.Produced(data) else E.Aborted(E.Error(ErrorBytes(BadNode(index))));
  }
}
