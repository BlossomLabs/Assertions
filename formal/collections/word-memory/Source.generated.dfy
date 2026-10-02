// SPDX-License-Identifier: MIT
// Generated from the structurally gated complete Yul helper bodies.
include "Model.dfy"
module CollectionsWordMemorySource {
  import opened AbiFrames
  import M = CollectionsWordMemoryModel
  function ReadAddress(base: nat,index: nat): nat { M.Add(M.Add(base,32),M.Mul(index,32)) }
  function WriteAddress(base: nat,index: nat): nat { M.Add(M.Add(base,32),M.Mul(index,32)) }
  ghost method WordAt(memory: seq<Byte>,base: nat,index: nat) returns (value: nat)
    requires ReadAddress(base,index)+32 <= |memory|
    ensures value == M.Load(memory,ReadAddress(base,index)) && M.Fits(value)
  {
    var address := ReadAddress(base,index);
    value := ReadNat(memory[address..address+32]);
    BytesNatRoundTrip(memory[address..address+32]);
  }
  ghost method SetWord(memory: seq<Byte>,base: nat,index: nat,value: nat) returns (after: seq<Byte>)
    requires WriteAddress(base,index)+32 <= |memory| && M.Fits(value)
    ensures after == M.Store(memory,WriteAddress(base,index),value)
  {
    var address := WriteAddress(base,index);
    after := memory[..address]+Word(value)+memory[address+32..];
  }
}
