// SPDX-License-Identifier: MIT
// Gated raw-return tails; Expressions.sol SHA-256: $HASH
include "Model.dfy"
module ExpressionReturnSource {
  import opened AbiFrames
  import opened AbiByteSemantics
  import M = ExpressionReturnMemory

  ghost method EvaluateReturn(memory: seq<Byte>, result: nat, value: seq<Byte>) returns (out: seq<Byte>)
    requires M.Object(memory,result,value)
    ensures out == value
  {
    M.ObjectLength(memory,result,value);
    var length := ReadNat(memory[result..result+32]);
    assert Uint(result+$EVALUATE_OFFSET);
    out := M.Window(memory,result+$EVALUATE_OFFSET,length);
    M.Payload(memory,result,value);
  }
  ghost method EncodedReturn(memory: seq<Byte>, result: nat, value: seq<Byte>) returns (out: seq<Byte>)
    requires M.Object(memory,result,value)
    ensures out == value
  {
    M.ObjectLength(memory,result,value);
    var length := ReadNat(memory[result..result+32]);
    assert Uint(result+$ENCODED_OFFSET);
    out := M.Window(memory,result+$ENCODED_OFFSET,length);
    M.Payload(memory,result,value);
  }
}
