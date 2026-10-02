// SPDX-License-Identifier: MIT
// Gated raw-return tails; Expressions.sol SHA-256: dc53eb78d3550ded3d9dce3f61172a9a16e103a6be33cea95b1de04701c7124d
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
    assert Uint(result+32);
    out := M.Window(memory,result+32,length);
    M.Payload(memory,result,value);
  }
  ghost method EncodedReturn(memory: seq<Byte>, result: nat, value: seq<Byte>) returns (out: seq<Byte>)
    requires M.Object(memory,result,value)
    ensures out == value
  {
    M.ObjectLength(memory,result,value);
    var length := ReadNat(memory[result..result+32]);
    assert Uint(result+32);
    out := M.Window(memory,result+32,length);
    M.Payload(memory,result,value);
  }
}
