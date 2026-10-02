// SPDX-License-Identifier: MIT
include "../../abi/Frames.dfy"
module CollectionsWordMemoryModel {
  import opened AbiFrames
  predicate Fits(n: nat) { n < Pow256(32) }
  function Add(a: nat,b: nat): nat { (a+b) % Pow256(32) }
  function Mul(a: nat,b: nat): nat { (a*b) % Pow256(32) }
  function Load(memory: seq<Byte>,address: nat): nat
    requires address+32 <= |memory|
  { ReadNat(memory[address..address+32]) }
  function Store(memory: seq<Byte>,address: nat,value: nat): seq<Byte>
    requires address+32 <= |memory|
    ensures |Store(memory,address,value)| == |memory|
  { memory[..address]+Word(value)+memory[address+32..] }
  predicate Frame(memory: seq<Byte>,base: nat,payload: seq<Byte>) {
    base+32+|payload| <= |memory| && memory[base..base+32] == Word(|payload|) &&
    memory[base+32..base+32+|payload|] == payload
  }
  function Words(payload: seq<Byte>): seq<nat> {
    seq(|payload|/32,i requires 0 <= i < |payload|/32 => ReadNat(payload[32*i..32*i+32]))
  }
  predicate Room(memory: seq<Byte>,base: nat,payload: seq<Byte>,index: nat) {
    Fits(|memory|) && Frame(memory,base,payload) && index < |payload|/32
  }
}
