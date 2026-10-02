// SPDX-License-Identifier: MIT
include "../dynamic-bytes-copy-repair-v2/Memory.dfy"
include "../../scans/ErrorBytes.dfy"
module BytecodeApplyCallbackFailedMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import E = BytecodeScanErrorBytes
  import F = BytecodeApplyStoreByteFrame
  import D = BytecodeApplyDynamicBytesCopyMemory
  function Selector(): S.Word { 0x117cf6f6 }
  function Header(): S.Word { 0x117cf6f600000000000000000000000000000000000000000000000000000000 }
  predicate Fits(mem: seq<S.Byte>,ptr: S.Word,receipt: S.Word,free: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>) {
    |mem|%32 == 0 && |mem| < D.Bound() && 160 <= free && free%32 == 0 && S.Load(mem,64) == free &&
    96 <= ptr && (ptr as nat)+32+|payload| <= |mem| && (ptr as nat)+32+|payload| <= free &&
    96 <= receipt && (receipt as nat)+32+|reason| <= |mem| && (receipt as nat)+32+|reason| <= free &&
    S.Load(mem,ptr) == |payload| && mem[ptr+32..ptr+32+|payload|] == payload &&
    S.Load(mem,receipt) == |reason| && mem[receipt+32..receipt+32+|reason|] == reason &&
    (free as nat)+|payload|+|reason|+512 < D.Bound()
  }
  function FirstDst(free: S.Word): S.Word
    requires free+512 < D.Bound()
  { free+196 }
  function ReasonOffset(payload: seq<S.Byte>): S.Word
    requires |payload|+512 < D.Bound()
  { 224+S.Round32(|payload|) }
  function ReasonDst(free: S.Word,payload: seq<S.Byte>): S.Word
    requires free+|payload|+512 < D.Bound()
  { free+4+ReasonOffset(payload) }
  function End(free: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>): S.Word
    requires free+|payload|+|reason|+512 < D.Bound()
  { ReasonDst(free,payload)+32+S.Round32(|reason|) }
  function Packet(operation: S.Word,index: S.Word,target: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>): seq<S.Byte>
    requires |payload|+512 < D.Bound() && |reason| < D.Bound()
  {
    G.Encode(Selector(),4)+G.Encode(operation,32)+G.Encode(index,32)+G.Encode(0,32)+G.Encode(target,32)+
    G.Encode(192,32)+G.Encode(ReasonOffset(payload),32)+D.Bytes(|payload|,payload)+D.Bytes(|reason|,reason)
  }
  function Head(mem: seq<S.Byte>,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,k: nat): seq<S.Byte>
    requires |mem|%32 == 0 && free+512 < D.Bound() && k <= 6
    ensures |Head(mem,free,operation,index,target,k)| >= |mem|
    decreases k
  {
    if k == 0 then mem
    else S.Store(Head(mem,free,operation,index,target,k-1),if k == 1 then free else free+4+32*(k-2),
      if k == 1 then Header() else if k == 2 then operation else if k == 3 then index else if k == 4 then 0 else if k == 5 then target else 192)
  }
  lemma HeadLayout(mem: seq<S.Byte>,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,k: nat)
    requires |mem|%32 == 0 && |mem| < D.Bound() && free+512 < D.Bound() && k <= 6
    ensures |Head(mem,free,operation,index,target,k)|%32 == 0 && |Head(mem,free,operation,index,target,k)| < D.Bound()
    ensures k > 0 ==> free+(if k == 1 then 32 else 4+32*(k-1)) <= |Head(mem,free,operation,index,target,k)|
    decreases k
  {
    if k > 0 {
      HeadLayout(mem,free,operation,index,target,k-1);
      R.StoredWord(Head(mem,free,operation,index,target,k-1),if k == 1 then free else free+4+32*(k-2),
        if k == 1 then Header() else if k == 2 then operation else if k == 3 then index else if k == 4 then 0 else if k == 5 then target else 192);
    }
  }
  lemma HeadOriginal(mem: seq<S.Byte>,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,k: nat,j: nat)
    requires |mem|%32 == 0 && |mem| < D.Bound() && free+512 < D.Bound() && k <= 6 && j < |mem| && j < free
    ensures Head(mem,free,operation,index,target,k)[j] == mem[j]
    decreases k
  {
    HeadLayout(mem,free,operation,index,target,k);
    if k > 0 {
      HeadOriginal(mem,free,operation,index,target,k-1,j);
      F.Outside(Head(mem,free,operation,index,target,k-1),if k == 1 then free else free+4+32*(k-2),
        if k == 1 then Header() else if k == 2 then operation else if k == 3 then index else if k == 4 then 0 else if k == 5 then target else 192,j);
    }
  }
  lemma Sources(mem: seq<S.Byte>,after: seq<S.Byte>,ptr: S.Word,receipt: S.Word,free: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>)
    requires Fits(mem,ptr,receipt,free,payload,reason) && |after| >= |mem|
    requires forall j: int {:trigger after[j]} :: 0 <= j < |mem| && j < free ==> after[j] == mem[j]
    ensures S.Load(after,ptr) == |payload| && after[ptr+32..ptr+32+|payload|] == payload
    ensures S.Load(after,receipt) == |reason| && after[receipt+32..receipt+32+|reason|] == reason
    ensures S.Load(after,64) == free
  {
    assert after[ptr..ptr+32] == mem[ptr..ptr+32];
    assert after[receipt..receipt+32] == mem[receipt..receipt+32];
    assert after[64..96] == mem[64..96];
    G.LoadProjection(after,ptr);G.LoadProjection(mem,ptr);
    G.LoadProjection(after,receipt);G.LoadProjection(mem,receipt);
    G.LoadProjection(after,64);G.LoadProjection(mem,64);
  }
  lemma FirstAdmission(mem: seq<S.Byte>,ptr: S.Word,receipt: S.Word,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>)
    requires Fits(mem,ptr,receipt,free,payload,reason)
    ensures D.Fits(Head(mem,free,operation,index,target,6),ptr,FirstDst(free),|payload|,payload)
  {
    HeadLayout(mem,free,operation,index,target,6);
    var head := Head(mem,free,operation,index,target,6);
    forall j: int {:trigger head[j]} | 0 <= j < |mem| && j < free
      ensures head[j] == mem[j]
    { HeadOriginal(mem,free,operation,index,target,6,j); }
    Sources(mem,head,ptr,receipt,free,payload,reason);
  }
  function First(mem: seq<S.Byte>,ptr: S.Word,receipt: S.Word,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>): seq<S.Byte>
    requires Fits(mem,ptr,receipt,free,payload,reason)
    ensures |First(mem,ptr,receipt,free,operation,index,target,payload,reason)| >= |mem|
  {
    FirstAdmission(mem,ptr,receipt,free,operation,index,target,payload,reason);
    D.Stage(Head(mem,free,operation,index,target,6),ptr,FirstDst(free),|payload|,payload,3)
  }
  function Offset(mem: seq<S.Byte>,ptr: S.Word,receipt: S.Word,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>): seq<S.Byte>
    requires Fits(mem,ptr,receipt,free,payload,reason)
    ensures |Offset(mem,ptr,receipt,free,operation,index,target,payload,reason)| >= |mem|
  { S.Store(First(mem,ptr,receipt,free,operation,index,target,payload,reason),free+164,ReasonOffset(payload)) }
  lemma OffsetLayout(mem: seq<S.Byte>,ptr: S.Word,receipt: S.Word,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>)
    requires Fits(mem,ptr,receipt,free,payload,reason)
    ensures |Offset(mem,ptr,receipt,free,operation,index,target,payload,reason)| < D.Bound() && |Offset(mem,ptr,receipt,free,operation,index,target,payload,reason)|%32 == 0
    ensures End(free,payload,[]) == ReasonDst(free,payload)+32
    ensures ReasonDst(free,payload) <= |Offset(mem,ptr,receipt,free,operation,index,target,payload,reason)|
    ensures free+196 <= |Offset(mem,ptr,receipt,free,operation,index,target,payload,reason)|
  {
    FirstAdmission(mem,ptr,receipt,free,operation,index,target,payload,reason);
    D.Sizes(Head(mem,free,operation,index,target,6),ptr,FirstDst(free),|payload|,payload,3);
    R.StoredWord(First(mem,ptr,receipt,free,operation,index,target,payload,reason),free+164,ReasonOffset(payload));
  }
  lemma OffsetOriginal(mem: seq<S.Byte>,ptr: S.Word,receipt: S.Word,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>,j: nat)
    requires Fits(mem,ptr,receipt,free,payload,reason) && j < |mem| && j < free
    ensures Offset(mem,ptr,receipt,free,operation,index,target,payload,reason)[j] == mem[j]
  {
    FirstAdmission(mem,ptr,receipt,free,operation,index,target,payload,reason);
    HeadOriginal(mem,free,operation,index,target,6,j);
    D.Original(Head(mem,free,operation,index,target,6),ptr,FirstDst(free),|payload|,payload,3,j);
    F.Outside(First(mem,ptr,receipt,free,operation,index,target,payload,reason),free+164,ReasonOffset(payload),j);
  }
  lemma ReasonAdmission(mem: seq<S.Byte>,ptr: S.Word,receipt: S.Word,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>)
    requires Fits(mem,ptr,receipt,free,payload,reason)
    ensures D.Fits(Offset(mem,ptr,receipt,free,operation,index,target,payload,reason),receipt,ReasonDst(free,payload),|reason|,reason)
  {
    OffsetLayout(mem,ptr,receipt,free,operation,index,target,payload,reason);
    var after := Offset(mem,ptr,receipt,free,operation,index,target,payload,reason);
    forall j: int {:trigger after[j]} | 0 <= j < |mem| && j < free
      ensures after[j] == mem[j]
    { OffsetOriginal(mem,ptr,receipt,free,operation,index,target,payload,reason,j); }
    Sources(mem,after,ptr,receipt,free,payload,reason);
  }
  function Final(mem: seq<S.Byte>,ptr: S.Word,receipt: S.Word,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>): seq<S.Byte>
    requires Fits(mem,ptr,receipt,free,payload,reason)
    ensures |Final(mem,ptr,receipt,free,operation,index,target,payload,reason)| >= |mem|
  {
    ReasonAdmission(mem,ptr,receipt,free,operation,index,target,payload,reason);
    D.Stage(Offset(mem,ptr,receipt,free,operation,index,target,payload,reason),receipt,ReasonDst(free,payload),|reason|,reason,3)
  }
  lemma FinalLayout(mem: seq<S.Byte>,ptr: S.Word,receipt: S.Word,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>)
    requires Fits(mem,ptr,receipt,free,payload,reason)
    ensures End(free,payload,reason) <= |Final(mem,ptr,receipt,free,operation,index,target,payload,reason)| < D.Bound()
    ensures |Final(mem,ptr,receipt,free,operation,index,target,payload,reason)|%32 == 0
    ensures S.Load(Final(mem,ptr,receipt,free,operation,index,target,payload,reason),64) == free
  {
    ReasonAdmission(mem,ptr,receipt,free,operation,index,target,payload,reason);
    var after := Offset(mem,ptr,receipt,free,operation,index,target,payload,reason);
    D.Sizes(after,receipt,ReasonDst(free,payload),|reason|,reason,3);
    D.Headers(after,receipt,ReasonDst(free,payload),|reason|,reason,3);
    forall j: int {:trigger after[j]} | 0 <= j < |mem| && j < free
      ensures after[j] == mem[j]
    { OffsetOriginal(mem,ptr,receipt,free,operation,index,target,payload,reason,j); }
    Sources(mem,after,ptr,receipt,free,payload,reason);
  }
  lemma HeadPrefix(mem: seq<S.Byte>,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,k: nat,j: nat)
    requires |mem|%32 == 0 && |mem| < D.Bound() && free+512 < D.Bound() && 2 <= k <= 6 && free <= j < free+4+32*(k-1)
    ensures Head(mem,free,operation,index,target,6)[j] == Head(mem,free,operation,index,target,k)[j]
    decreases 6-k
  {
    HeadLayout(mem,free,operation,index,target,k);
    if k < 6 {
      F.Outside(Head(mem,free,operation,index,target,k),free+4+32*(k-1),if k == 2 then index else if k == 3 then 0 else if k == 4 then target else 192,j);
      HeadPrefix(mem,free,operation,index,target,k+1,j);
    }
  }
  lemma HeadZero(mem: seq<S.Byte>,free: S.Word,operation: S.Word,index: S.Word,target: S.Word)
    requires |mem|%32 == 0 && free+512 < D.Bound()
    ensures Head(mem,free,operation,index,target,0) == mem
  { reveal Head(); }
  lemma HeadNext(mem: seq<S.Byte>,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,k: nat)
    requires |mem|%32 == 0 && free+512 < D.Bound() && k < 6
    ensures Head(mem,free,operation,index,target,k+1) == S.Store(Head(mem,free,operation,index,target,k),if k == 0 then free else free+4+32*(k-1),if k == 0 then Header() else if k == 1 then operation else if k == 2 then index else if k == 3 then 0 else if k == 4 then target else 192)
  { reveal Head(); }
  lemma HeadBytes(mem: seq<S.Byte>,free: S.Word,operation: S.Word,index: S.Word,target: S.Word)
    requires |mem|%32 == 0 && |mem| < D.Bound() && free+512 < D.Bound()
    ensures Head(mem,free,operation,index,target,6)[free..free+164] == G.Encode(Selector(),4)+G.Encode(operation,32)+G.Encode(index,32)+G.Encode(0,32)+G.Encode(target,32)+G.Encode(192,32)
  {
    hide G.Encode(); hide Head();
    HeadLayout(mem,free,operation,index,target,6);
    HeadLayout(mem,free,operation,index,target,2);HeadLayout(mem,free,operation,index,target,3);
    HeadLayout(mem,free,operation,index,target,4);HeadLayout(mem,free,operation,index,target,5);
    HeadZero(mem,free,operation,index,target);
    HeadNext(mem,free,operation,index,target,0);HeadNext(mem,free,operation,index,target,1);
    HeadNext(mem,free,operation,index,target,2);HeadNext(mem,free,operation,index,target,3);
    HeadNext(mem,free,operation,index,target,4);HeadNext(mem,free,operation,index,target,5);
    E.PhysicalError(mem,free,Selector(),Header(),operation);
    R.StoredWord(Head(mem,free,operation,index,target,2),free+36,index);
    R.StoredWord(Head(mem,free,operation,index,target,3),free+68,0);
    R.StoredWord(Head(mem,free,operation,index,target,4),free+100,target);
    R.StoredWord(Head(mem,free,operation,index,target,5),free+132,192);
    var head := Head(mem,free,operation,index,target,6);
    var bytes := G.Encode(Selector(),4)+G.Encode(operation,32)+G.Encode(index,32)+G.Encode(0,32)+G.Encode(target,32)+G.Encode(192,32);
    forall j: int {:trigger head[j]} | free <= j < free+164
      ensures head[j] == bytes[j-free]
    {
      if j < free+36 { HeadPrefix(mem,free,operation,index,target,2,j); }
      else if j < free+68 { HeadPrefix(mem,free,operation,index,target,3,j); }
      else if j < free+100 { HeadPrefix(mem,free,operation,index,target,4,j); }
      else if j < free+132 { HeadPrefix(mem,free,operation,index,target,5,j); }
    }
    assert |bytes| == 164;
    forall k: int {:trigger head[free..free+164][k]} | 0 <= k < 164
      ensures head[free..free+164][k] == bytes[k]
    { assert head[free+k] == bytes[k]; }
    assert head[free..free+164] == bytes;
  }
  lemma FinalBytes(mem: seq<S.Byte>,ptr: S.Word,receipt: S.Word,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>)
    requires Fits(mem,ptr,receipt,free,payload,reason)
    ensures Final(mem,ptr,receipt,free,operation,index,target,payload,reason)[free..End(free,payload,reason)] == Packet(operation,index,target,payload,reason)
    ensures |Packet(operation,index,target,payload,reason)| == 260+S.Round32(|payload|)+S.Round32(|reason|)
  {
    hide S.BitNot();hide G.BitAnd();
    FirstAdmission(mem,ptr,receipt,free,operation,index,target,payload,reason);
    ReasonAdmission(mem,ptr,receipt,free,operation,index,target,payload,reason);
    HeadLayout(mem,free,operation,index,target,6);HeadBytes(mem,free,operation,index,target);
    OffsetLayout(mem,ptr,receipt,free,operation,index,target,payload,reason);
    FinalLayout(mem,ptr,receipt,free,operation,index,target,payload,reason);
    var head := Head(mem,free,operation,index,target,6);
    var first := First(mem,ptr,receipt,free,operation,index,target,payload,reason);
    var offset := Offset(mem,ptr,receipt,free,operation,index,target,payload,reason);
    var last := Final(mem,ptr,receipt,free,operation,index,target,payload,reason);
    D.Sizes(head,ptr,FirstDst(free),|payload|,payload,3);D.Output(head,ptr,FirstDst(free),|payload|,payload);
    R.StoredWord(first,free+164,ReasonOffset(payload));
    D.Output(offset,receipt,ReasonDst(free,payload),|reason|,reason);
    var packet := Packet(operation,index,target,payload,reason);
    forall j: int {:trigger last[j]} | free <= j < End(free,payload,reason)
      ensures last[j] == packet[j-free]
    {
      if j < ReasonDst(free,payload) {
        D.Original(offset,receipt,ReasonDst(free,payload),|reason|,reason,3,j);
        if j < free+164 {
          F.Outside(first,free+164,ReasonOffset(payload),j);
          D.Original(head,ptr,FirstDst(free),|payload|,payload,3,j);
        } else if j >= free+196 {
          F.Outside(first,free+164,ReasonOffset(payload),j);
        }
      }
    }
  }
}
