// SPDX-License-Identifier: MIT
include "Source.generated.dfy"
include "../../../foundations/v1/SequenceMemory.dfy"
module CollectionsWordMemoryConnection {
  import opened AbiFrames
  import F = SourceSequenceMemoryV1
  import M = CollectionsWordMemoryModel
  import S = CollectionsWordMemorySource

  lemma SmallMod(n: nat,modulus: nat)
    requires n < modulus
    ensures n % modulus == n
  {}

  lemma Slice(memory: seq<Byte>,lo: nat,hi: nat,a: nat,b: nat)
    requires lo <= hi <= |memory| && a <= b <= hi-lo
    ensures memory[lo..hi][a..b] == memory[lo+a..lo+b]
  {
    F.NestedSlice(memory,lo,hi,a,b);
  }

  lemma Address(memory: seq<Byte>,base: nat,payload: seq<Byte>,index: nat)
    requires M.Room(memory,base,payload,index)
    ensures S.ReadAddress(base,index) == base+32+32*index
    ensures S.WriteAddress(base,index) == base+32+32*index
    ensures base+32+32*index+32 <= |memory|
  {
    assert 32*(index+1) <= |payload|;
    assert base+32+32*index < Pow256(32);
    SmallMod(index*32,Pow256(32));
    SmallMod(base+32,Pow256(32));
    assert M.Mul(index,32) == 32*index;
    assert M.Add(base,32) == base+32;
    SmallMod(base+32+32*index,Pow256(32));
  }

  lemma Outside(memory: seq<Byte>,address: nat,value: nat,lo: nat,hi: nat)
    requires address+32 <= |memory| && lo <= hi <= |memory|
    requires hi <= address || address+32 <= lo
    ensures M.Store(memory,address,value)[lo..hi] == memory[lo..hi]
  {
    F.Outside(memory,address,Word(value),lo,hi);
  }

  lemma Inside(memory: seq<Byte>,address: nat,value: nat,lo: nat,hi: nat)
    requires lo <= address && address+32 <= hi <= |memory|
    ensures M.Store(memory,address,value)[lo..hi] == M.Store(memory[lo..hi],address-lo,value)
  {
    var after := M.Store(memory,address,value);
    Outside(memory,address,value,lo,address);
    Outside(memory,address,value,address+32,hi);
    assert after[address..address+32] == Word(value);
    assert after[lo..hi] == after[lo..address]+after[address..address+32]+after[address+32..hi];
    assert memory[lo..hi][..address-lo] == memory[lo..address];
    assert memory[lo..hi][address-lo+32..] == memory[address+32..hi];
  }

  lemma WordBounds(payload: seq<Byte>)
    ensures |M.Words(payload)| == |payload|/32
    ensures forall i :: 0 <= i < |M.Words(payload)| ==> M.Fits(M.Words(payload)[i])
  {
    forall i | 0 <= i < |M.Words(payload)|
      ensures M.Fits(M.Words(payload)[i])
    {
      BytesNatRoundTrip(payload[32*i..32*i+32]);
    }
  }

  lemma Assignment(payload: seq<Byte>,index: nat,value: nat)
    requires index < |payload|/32 && M.Fits(value)
    ensures M.Words(M.Store(payload,32*index,value)) == M.Words(payload)[index:=value]
    ensures M.Store(payload,32*index,value)[32*(|payload|/32)..] == payload[32*(|payload|/32)..]
  {
    var after := M.Store(payload,32*index,value);
    NatBytesRoundTrip(value,32);
    forall j | 0 <= j < |M.Words(payload)|
      ensures M.Words(after)[j] == (M.Words(payload)[index:=value])[j]
    {
      if j == index {
        assert after[32*j..32*j+32] == Word(value);
      } else {
        Outside(payload,32*index,value,32*j,32*j+32);
      }
    }
    Outside(payload,32*index,value,32*(|payload|/32),|payload|);
  }

  ghost method Read(memory: seq<Byte>,base: nat,payload: seq<Byte>,index: nat) returns (value: nat)
    requires M.Room(memory,base,payload,index)
    ensures value == M.Words(payload)[index] && M.Fits(value)
  {
    Address(memory,base,payload,index);
    value := S.WordAt(memory,base,index);
    Slice(memory,base+32,base+32+|payload|,32*index,32*index+32);
    assert memory[base+32..base+32+|payload|][32*index..32*index+32] ==
           memory[base+32+32*index..base+32+32*index+32];
  }

  ghost method Write(memory: seq<Byte>,base: nat,payload: seq<Byte>,index: nat,value: nat) returns (after: seq<Byte>)
    requires M.Room(memory,base,payload,index) && M.Fits(value)
    ensures after == M.Store(memory,base+32+32*index,value)
    ensures |after| == |memory|
    ensures M.Frame(after,base,M.Store(payload,32*index,value))
    ensures M.Words(M.Store(payload,32*index,value)) == M.Words(payload)[index:=value]
    ensures after[..base+32+32*index] == memory[..base+32+32*index]
    ensures after[base+32+32*index+32..] == memory[base+32+32*index+32..]
  {
    Address(memory,base,payload,index);
    after := S.SetWord(memory,base,index,value);
    var address := base+32+32*index;
    Outside(memory,address,value,base,base+32);
    Inside(memory,address,value,base+32,base+32+|payload|);
    Assignment(payload,index,value);
  }

  lemma DisjointFrame(memory: seq<Byte>,address: nat,value: nat,otherBase: nat,otherPayload: seq<Byte>)
    requires address+32 <= |memory|
    requires M.Frame(memory,otherBase,otherPayload)
    requires otherBase+32+|otherPayload| <= address || address+32 <= otherBase
    ensures M.Frame(M.Store(memory,address,value),otherBase,otherPayload)
  {
    Outside(memory,address,value,otherBase,otherBase+32);
    Outside(memory,address,value,otherBase+32,otherBase+32+|otherPayload|);
  }
}
