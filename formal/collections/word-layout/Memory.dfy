// SPDX-License-Identifier: MIT
include "Control.generated.dfy"
module CollectionsWordLayoutMemory {
  import opened AbiFrames
  import M = CollectionsWordMemoryModel
  import P = CollectionsWordMemoryConnection
  import Ctrl = CollectionsWordLayoutControl
  lemma Modulus(a: nat,b: nat,m: nat)
    requires m > 0 && b <= a < m
    ensures (a+m-b)%m == a-b
  {
    var r := a-b;
    assert r < m;
    assert a+m-b == m+r;
    assert (m+r)/m == 1;
    assert (m+r)%m == r;
  }
  lemma Sub(a: nat,b: nat)
    requires b <= a < Pow256(32)
    ensures Ctrl.Sub(a,b) == a-b
  { P.SmallMod(b,Pow256(32)); Modulus(a,b,Pow256(32)); }
  lemma Addresses(memory: seq<Byte>,base: nat,payload: seq<Byte>,index: nat,count: nat)
    requires M.Room(memory,base,payload,index) && count < Pow256(32)
    ensures Ctrl.UnzipAddress(base,index) == base+32+32*index
    ensures 2*index < |payload|/32 ==> Ctrl.ZipLeftAddress(base,index) == base+32+32*(2*index)
    ensures 2*index+1 < |payload|/32 ==> Ctrl.ZipRightAddress(base,index) == base+32+32*(2*index+1)
    ensures index < count && count <= |payload|/32 ==> Ctrl.ReverseAddress(base,count,index) == base+32+32*(count-1-index)
  {
    P.SmallMod(base+32,Pow256(32)); P.SmallMod(index*32,Pow256(32)); P.SmallMod(base+32+32*index,Pow256(32));
    if 2*index < |payload|/32 {
      P.SmallMod(2*index,Pow256(32)); P.SmallMod(32*(2*index),Pow256(32)); P.SmallMod(base+32+32*(2*index),Pow256(32));
    }
    if 2*index+1 < |payload|/32 {
      P.SmallMod(2*index,Pow256(32)); P.SmallMod(2*index+1,Pow256(32)); P.SmallMod(32*(2*index+1),Pow256(32)); P.SmallMod(base+32+32*(2*index+1),Pow256(32));
    }
    if index < count && count <= |payload|/32 {
      Sub(count,1); Sub(count-1,index);
      P.SmallMod(32*(count-1-index),Pow256(32)); P.SmallMod(base+32+32*(count-1-index),Pow256(32));
    }
  }
  // Independent concrete address obligations keep semantic fault checks
  // decisive without depending on a solver finding a large memory model.
  lemma ReverseCorner()
    ensures Ctrl.ReverseAddress(0,2,1) == 32
  {
    Sub(2,1); Sub(1,1); Sub(1,0);
    P.SmallMod(0,Pow256(32)); P.SmallMod(32,Pow256(32)); P.SmallMod(64,Pow256(32));
  }
  lemma ZipCorner()
    ensures Ctrl.ZipRightAddress(0,0) == 64
  {
    P.SmallMod(0,Pow256(32)); P.SmallMod(1,Pow256(32));
    P.SmallMod(32,Pow256(32)); P.SmallMod(64,Pow256(32));
  }
  ghost method Store(memory: seq<Byte>,base: nat,payload: seq<Byte>,index: nat,value: nat,address: nat)
    returns (after: seq<Byte>,updated: seq<Byte>)
    requires M.Room(memory,base,payload,index) && M.Fits(value)
    requires address == base+32+32*index
    ensures after == M.Store(memory,address,value) && updated == M.Store(payload,32*index,value)
    ensures M.Frame(after,base,updated) && |after| == |memory|
    ensures M.Words(updated) == M.Words(payload)[index:=value]
    ensures after[..base+32] == memory[..base+32] && after[base+32+|payload|..] == memory[base+32+|payload|..]
  {
    after := P.Write(memory,base,payload,index,value);
    updated := M.Store(payload,32*index,value);
    P.Assignment(payload,index,value);
    P.Address(memory,base,payload,index);
  }
}
