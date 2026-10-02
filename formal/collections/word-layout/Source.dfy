// SPDX-License-Identifier: MIT
include "Memory.dfy"
module CollectionsWordLayoutSource {
  import opened AbiFrames
  import opened CollectionsWordLayoutModel
  import Ctrl = CollectionsWordLayoutControl
  import M = CollectionsWordMemoryModel
  import P = CollectionsWordMemoryConnection
  import Memory = CollectionsWordLayoutMemory
  function Unaligned(s: seq<Byte>): seq<Byte> { Ctrl.UnalignedSelector()+Word(|s|) }
  function Mismatch(a: seq<Byte>,b: seq<Byte>): seq<Byte> { Ctrl.MismatchSelector()+Word(Count(a))+Word(Count(b)) }
  function Invalid(lane: nat): seq<Byte> { Ctrl.InvalidLaneSelector()+Word(lane) }
  function Judge(k: Config): Outcome
    requires Basic(k)
  {
    if k.kind == Iota then (if 32*k.n >= Pow256(32) then Failed(Panic()) else Returned(Values(k))) else
    if !Aligned(k.a) then Failed(Unaligned(k.a)) else
    if k.kind == Zip && !Aligned(k.b) then Failed(Unaligned(k.b)) else
    if k.kind == Zip && |k.a| != |k.b| then Failed(Mismatch(k.a,k.b)) else
    if k.kind == Unzip && k.lane > 1 then Failed(Invalid(k.lane)) else
    if k.kind == Zip && 2*|k.a| >= Pow256(32) then Failed(Panic()) else Returned(Values(k))
  }
  ghost method IotaWords(k: Config,memory: seq<Byte>,base: nat) returns (out: Outcome,after: seq<Byte>,payload: seq<Byte>)
    requires Basic(k) && k.kind == Iota && Budget(k,memory,base)
    ensures out == Judge(k)
    ensures out.Returned? ==> M.Frame(after,base,payload) && |payload| == Size(k) && M.Words(payload) == out.values
    ensures out.Returned? ==> after[..base+32] == memory[..base+32] && after[base+32+Size(k)..] == memory[base+32+Size(k)..]
    ensures out.Failed? ==> after == memory
  {
    after := memory; payload := [];
    var size := Ctrl.IotaBytes(k.n);
    if size >= Pow256(32) { out := Failed(Panic()); return; }
    payload := Zero(size);
    var i: nat := 0;
    while Ctrl.IotaLoop(i,k.n)
      invariant i <= k.n && |payload| == size && size == 32*k.n
      invariant |after| == |memory| && M.Frame(after,base,payload)
      invariant after[..base+32] == memory[..base+32] && after[base+32+Size(k)..] == memory[base+32+Size(k)..]
      invariant forall j :: 0 <= j < i ==> M.Words(payload)[j] == j
      decreases k.n-i
    {
      var before := M.Words(payload);
      after := P.Write(after,base,payload,i,Ctrl.IotaValue(i));
      P.Assignment(payload,i,Ctrl.IotaValue(i));
      payload := M.Store(payload,32*i,Ctrl.IotaValue(i));
      assert i+1 < Pow256(32);
      i := i+1;
    }
    out := Returned(Values(k));
    assert M.Words(payload) == Values(k);
  }
  ghost method ReverseWords(k: Config,memory: seq<Byte>,base: nat) returns (out: Outcome,after: seq<Byte>,payload: seq<Byte>)
    requires Basic(k) && k.kind == Reverse && Budget(k,memory,base)
    ensures out == Judge(k)
    ensures out.Returned? ==> M.Frame(after,base,payload) && |payload| == Size(k) && M.Words(payload) == out.values
    ensures out.Returned? ==> after[..base+32] == memory[..base+32] && after[base+32+Size(k)..] == memory[base+32+Size(k)..]
    ensures out.Failed? ==> after == memory
  {
    after := memory; payload := [];
    if Ctrl.ReverseUnaligned(|k.a|) { out := Failed(Unaligned(k.a)); return; }
    var count := Ctrl.ReverseCount(|k.a|); payload := Zero(|k.a|); var i: nat := 0;
    while Ctrl.ReverseLoop(i,count)
      invariant i <= count && count == Count(k.a) && |payload| == |k.a|
      invariant |after| == |memory| && M.Frame(after,base,payload)
      invariant after[..base+32] == memory[..base+32] && after[base+32+Size(k)..] == memory[base+32+Size(k)..]
      invariant forall j :: 0 <= j < i ==> M.Words(payload)[count-1-j] == Element(k.a,j)
      decreases count-i
    {
      var value := Element(k.a,i); BytesNatRoundTrip(k.a[32*i..32*i+32]);
      Memory.Addresses(after,base,payload,i,count);
      after,payload := Memory.Store(after,base,payload,count-1-i,value,Ctrl.ReverseAddress(base,count,i));
      assert i+1 < Pow256(32); i := i+1;
    }
    out := Returned(Values(k));
    forall j | 0 <= j < count ensures M.Words(payload)[j] == Values(k)[j]
    { assert count-1-(count-1-j) == j; }
  }
  ghost method ZipWords(k: Config,memory: seq<Byte>,base: nat) returns (out: Outcome,after: seq<Byte>,payload: seq<Byte>)
    requires Basic(k) && k.kind == Zip && Budget(k,memory,base)
    ensures out == Judge(k)
    ensures out.Returned? ==> M.Frame(after,base,payload) && |payload| == Size(k) && M.Words(payload) == out.values
    ensures out.Returned? ==> after[..base+32] == memory[..base+32] && after[base+32+Size(k)..] == memory[base+32+Size(k)..]
    ensures out.Failed? ==> after == memory
  {
    after := memory; payload := [];
    if Ctrl.ZipAUnaligned(|k.a|) { out := Failed(Unaligned(k.a)); return; }
    if Ctrl.ZipBUnaligned(|k.b|) { out := Failed(Unaligned(k.b)); return; }
    if Ctrl.ZipMismatch(|k.a|,|k.b|) { out := Failed(Mismatch(k.a,k.b)); return; }
    var count := Ctrl.ZipCount(|k.a|); var size := Ctrl.ZipBytes(|k.a|);
    if size >= Pow256(32) { out := Failed(Panic()); return; }
    payload := Zero(size); var i: nat := 0;
    while Ctrl.ZipLoop(i,count)
      invariant i <= count && count == Count(k.a) && |k.a| == |k.b| && |payload| == 2*|k.a|
      invariant |after| == |memory| && M.Frame(after,base,payload)
      invariant after[..base+32] == memory[..base+32] && after[base+32+Size(k)..] == memory[base+32+Size(k)..]
      invariant forall j :: 0 <= j < i ==> M.Words(payload)[2*j] == Element(k.a,j) && M.Words(payload)[2*j+1] == Element(k.b,j)
      decreases count-i
    {
      var left := Element(k.a,i); var right := Element(k.b,i);
      BytesNatRoundTrip(k.a[32*i..32*i+32]); BytesNatRoundTrip(k.b[32*i..32*i+32]);
      Memory.Addresses(after,base,payload,i,count);
      after,payload := Memory.Store(after,base,payload,2*i,left,Ctrl.ZipLeftAddress(base,i));
      Memory.Addresses(after,base,payload,i,count);
      after,payload := Memory.Store(after,base,payload,2*i+1,right,Ctrl.ZipRightAddress(base,i));
      assert i+1 < Pow256(32); i := i+1;
    }
    out := Returned(Values(k));
    forall j | 0 <= j < 2*count ensures M.Words(payload)[j] == Values(k)[j]
    { assert j == 2*(j/2)+j%2; }
  }
  ghost method UnzipWords(k: Config,memory: seq<Byte>,base: nat) returns (out: Outcome,after: seq<Byte>,payload: seq<Byte>)
    requires Basic(k) && k.kind == Unzip && Budget(k,memory,base)
    ensures out == Judge(k)
    ensures out.Returned? ==> M.Frame(after,base,payload) && |payload| == Size(k) && M.Words(payload) == out.values
    ensures out.Returned? ==> after[..base+32] == memory[..base+32] && after[base+32+Size(k)..] == memory[base+32+Size(k)..]
    ensures out.Failed? ==> after == memory
  {
    after := memory; payload := [];
    if Ctrl.UnzipUnaligned(|k.a|) { out := Failed(Unaligned(k.a)); return; }
    if Ctrl.UnzipInvalid(k.lane) { out := Failed(Invalid(k.lane)); return; }
    var count := Ctrl.UnzipCount(|k.a|); var laneCount := Ctrl.UnzipLaneCount(count,k.lane);
    var size := Ctrl.UnzipBytes(laneCount); payload := Zero(size); var i: nat := 0;
    assert count+1 < Pow256(32) && size < Pow256(32);
    while Ctrl.UnzipLoop(i,laneCount)
      invariant i <= laneCount && laneCount == LaneCount(count,k.lane) && count == Count(k.a)
      invariant |payload| == size && size == 32*laneCount && |after| == |memory| && M.Frame(after,base,payload)
      invariant after[..base+32] == memory[..base+32] && after[base+32+Size(k)..] == memory[base+32+Size(k)..]
      invariant forall j :: 0 <= j < i ==> M.Words(payload)[j] == Element(k.a,2*j+k.lane)
      decreases laneCount-i
    {
      assert 2*i+k.lane < count && (2*i+k.lane)*32+32 <= |k.a|;
      var value := Element(k.a,2*i+k.lane); BytesNatRoundTrip(k.a[(2*i+k.lane)*32..(2*i+k.lane)*32+32]);
      Memory.Addresses(after,base,payload,i,count);
      after,payload := Memory.Store(after,base,payload,i,value,Ctrl.UnzipAddress(base,i));
      assert i+1 < Pow256(32); i := i+1;
    }
    out := Returned(Values(k));
    assert M.Words(payload) == Values(k);
  }
}
