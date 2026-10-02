// SPDX-License-Identifier: MIT
include "../../abi/source/ByteSemantics.dfy"
module ExpressionReturnMemory {
  import opened AbiFrames
  import opened AbiByteSemantics

  function Window(memory: seq<Byte>, start: nat, length: nat): seq<Byte> {
    seq(length, i requires 0 <= i < length => if start+i < |memory| then memory[start+i] else 0)
  }
  predicate Object(memory: seq<Byte>, pointer: nat, value: seq<Byte>) {
    Uint(|memory|) && pointer+32+|value| <= |memory| &&
    memory[pointer..pointer+32] == Word(|value|) &&
    memory[pointer+32..pointer+32+|value|] == value
  }
  lemma ObjectLength(memory: seq<Byte>, pointer: nat, value: seq<Byte>)
    requires Object(memory,pointer,value)
    ensures ReadNat(memory[pointer..pointer+32]) == |value|
    ensures Uint(pointer+32) && Uint(|value|)
  { NatBytesRoundTrip(|value|,32); }
  lemma Payload(memory: seq<Byte>, pointer: nat, value: seq<Byte>)
    requires Object(memory,pointer,value)
    ensures Window(memory,pointer+32,|value|) == value
  {
    forall i | 0 <= i < |value|
      ensures Window(memory,pointer+32,|value|)[i] == value[i]
    { assert memory[pointer+32+i] == value[i]; }
  }
}
