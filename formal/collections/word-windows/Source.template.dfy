// SPDX-License-Identifier: MIT
// Generated from four complete structurally gated source helpers.
include "Properties.dfy"
module CollectionsWordWindowsSource {
  import opened AbiFrames
  import M = CollectionsWordWindowsModel
  import Proof = CollectionsWordWindowsProperties
  import Mem = CollectionsWordMemoryModel
  import Memory = CollectionsWordMemoryConnection
  function ErrorSelector(): seq<Byte> { $ERROR }
  function ErrorBytes(offset: nat,n: nat): seq<Byte> { ErrorSelector()+Word(offset)+Word(n) }
  function AccAddress(base: nat,accOffset: nat): nat { $ACC_ADDRESS }
  function ElementAddress(base: nat,offset: nat): nat { $ELEMENT_ADDRESS }
  ghost method CheckElements(n: nat,offsets: seq<nat>) returns (result: M.Admission)
    requires Mem.Fits(n) && Mem.Fits(|offsets|)
    requires forall j :: 0 <= j < |offsets| ==> Mem.Fits(offsets[j])
    ensures result == M.Elements(n,offsets)
  {
    if $SHORT { result := M.Rejected(1,0,0); return; }
    var j: nat := 0;
    while $CHECK_LOOP
      invariant j <= |offsets|
      invariant M.Scan(n,offsets,0) == M.Scan(n,offsets,j)
      decreases |offsets|-j
    {
      if $ELEMENT_CHECK { result := M.Rejected(2,j,offsets[j]); return; }
      assert j+1 < Pow256(32);
      j := j+1;
    }
    result := M.Accepted;
  }
  ghost method CheckWindows(n: nat,accOffset: nat,offsets: seq<nat>) returns (result: M.Admission)
    requires Mem.Fits(n) && Mem.Fits(accOffset) && Mem.Fits(|offsets|)
    requires forall j :: 0 <= j < |offsets| ==> Mem.Fits(offsets[j])
    ensures result == M.Windows(n,accOffset,offsets)
  {
    if $ACC_CHECK { result := M.Rejected(0,0,accOffset); return; }
    result := CheckElements(n,offsets);
  }
  lemma Address(memory: seq<Byte>,base: nat,payload: seq<Byte>,offset: nat)
    requires Mem.Fits(|memory|) && Mem.Frame(memory,base,payload) && M.InBounds(|payload|,offset)
    ensures AccAddress(base,offset) == base+32+offset
    ensures ElementAddress(base,offset) == base+32+offset
    ensures base+32+offset+32 <= |memory|
  {
    Memory.SmallMod(base+32,Pow256(32));
    Memory.SmallMod(base+32+offset,Pow256(32));
  }
  lemma StoreFrame(memory: seq<Byte>,base: nat,payload: seq<Byte>,offset: nat,value: nat)
    requires Mem.Frame(memory,base,payload) && M.InBounds(|payload|,offset)
    ensures Mem.Frame(Mem.Store(memory,base+32+offset,value),base,Mem.Store(payload,offset,value))
    ensures Mem.Store(memory,base+32+offset,value)[..base+32] == memory[..base+32]
    ensures Mem.Store(memory,base+32+offset,value)[base+32+|payload|..] == memory[base+32+|payload|..]
  {
    Memory.Outside(memory,base+32+offset,value,0,base+32);
    Memory.Outside(memory,base+32+offset,value,base+32+|payload|,|memory|);
    Memory.Inside(memory,base+32+offset,value,base+32,base+32+|payload|);
    assert Mem.Store(memory,base+32+offset,value)[base..base+32] == memory[base..base+32];
  }
  ghost method StampElements(memory: seq<Byte>,base: nat,original: seq<Byte>,prior: seq<M.Write>,offsets: seq<nat>,value: nat) returns (after: seq<Byte>)
    requires Mem.Fits(|memory|) && Mem.Fits(|offsets|) && Mem.Fits(value)
    requires Mem.Frame(memory,base,M.Patch(original,prior))
    requires forall j :: 0 <= j < |offsets| ==> M.InBounds(|original|,offsets[j])
    ensures |after| == |memory|
    ensures Mem.Frame(after,base,M.Patch(original,prior+M.ElementWrites(offsets,value)))
    ensures after[..base+32] == memory[..base+32]
    ensures after[base+32+|original|..] == memory[base+32+|original|..]
  {
    after := memory;
    var j: nat := 0;
    assert M.ElementWrites(offsets[..0],value) == [];
    assert prior+M.ElementWrites(offsets[..0],value) == prior;
    while $STAMP_LOOP
      invariant j <= |offsets| && |after| == |memory|
      invariant Mem.Frame(after,base,M.Patch(original,prior+M.ElementWrites(offsets[..j],value)))
      invariant after[..base+32] == memory[..base+32]
      invariant after[base+32+|original|..] == memory[base+32+|original|..]
      decreases |offsets|-j
    {
      var offset := offsets[j];
      var writes := prior+M.ElementWrites(offsets[..j],value);
      Address(after,base,M.Patch(original,writes),offset);
      StoreFrame(after,base,M.Patch(original,writes),offset,value);
      Proof.Append(original,writes,M.Write(offset,value));
      var address := ElementAddress(base,offset);
      after := Mem.Store(after,address,value);
      assert M.ElementWrites(offsets[..j+1],value) == M.ElementWrites(offsets[..j],value)+[M.Write(offset,value)];
      assert writes+[M.Write(offset,value)] == prior+M.ElementWrites(offsets[..j+1],value);
      assert Mem.Frame(after,base,M.Patch(original,prior+M.ElementWrites(offsets[..j+1],value)));
      assert j+1 < Pow256(32);
      j := j+1;
    }
    assert offsets[..j] == offsets;
  }
  ghost method StampWindows(memory: seq<Byte>,base: nat,original: seq<Byte>,accOffset: nat,acc: nat,offsets: seq<nat>,value: nat) returns (after: seq<Byte>)
    requires Mem.Fits(|memory|) && Mem.Fits(|offsets|) && Mem.Fits(value) && Mem.Fits(acc)
    requires Mem.Frame(memory,base,original) && M.InBounds(|original|,accOffset)
    requires forall j :: 0 <= j < |offsets| ==> M.InBounds(|original|,offsets[j])
    ensures |after| == |memory|
    ensures Mem.Frame(after,base,M.Patch(original,[M.Write(accOffset,acc)]+M.ElementWrites(offsets,value)))
    ensures after[..base+32] == memory[..base+32]
    ensures after[base+32+|original|..] == memory[base+32+|original|..]
  {
    Address(memory,base,original,accOffset);
    StoreFrame(memory,base,original,accOffset,acc);
    Proof.Empty(original); Proof.Append(original,[],M.Write(accOffset,acc));
    var address := AccAddress(base,accOffset);
    after := Mem.Store(memory,address,acc);
    after := StampElements(after,base,original,[M.Write(accOffset,acc)],offsets,value);
  }
}
