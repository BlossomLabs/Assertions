// SPDX-License-Identifier: MIT
include "Source.dfy"
module ExpressionRequestConnection {
  import opened AbiFrames
  import opened AbiByteSemantics
  import B = ExpressionEvaluationBridge
  import E = ExpressionEvaluationControl
  import M = ExpressionScalarModel
  import ScalarSource = ExpressionScalarSource

  // All encoded error adapters return actual bytes; the recursive request
  // proof needs only this property for a guarded failure's input payload.
  lemma EncodedErrorIsBytes(bytes: seq<Byte>)
    ensures B.Bytes(E.Error(bytes).payload)
  {}
  ghost method AddressReceipt(index: nat, value: seq<Byte>) returns (raw: E.Raw)
    requires Uint(index) && Uint(|value|)
    ensures raw.Produced? ==> M.AddressSpec(index,value).Addressed?
    ensures raw.Aborted? ==> B.Bytes(raw.error.payload)
    ensures raw.Produced? ==> raw.value == value
  {
    raw := ScalarSource.AddressReceipt(index,value);
    if raw.Aborted? {
      EncodedErrorIsBytes(M.ErrorBytes(M.BadNode(index)));
    }
  }
}
