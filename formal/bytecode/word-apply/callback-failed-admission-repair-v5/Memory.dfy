// SPDX-License-Identifier: MIT
include "../callback-receipt-engine/Memory.dfy"
include "../callback-failed-memory-repair-v4/Memory.dfy"
module BytecodeApplyCallbackFailedReceiptAdmission {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import EM = BytecodeExternalMemory
  import F = BytecodeApplyFullCallbackReceiptMemory
  import R = BytecodeApplyCallbackReceiptMemory
  import P = BytecodeApplyCallbackCopyMemory
  import H = BytecodeApplyCallbackFailedMemory
  import D = BytecodeApplyDynamicBytesCopyMemory
  import W = BytecodeApplyStoreByteFrame
  import Rep = BytecodeScanRepresentation
  lemma Bounds(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,returned: seq<S.Byte>)
    requires F.Fits(mem,ptr,free,length,returned)
    ensures |F.Final(mem,ptr,free,length,returned)|%32 == 0 && |F.Final(mem,ptr,free,length,returned)| < R.Bound()
    ensures |F.Final(mem,ptr,free,length,returned)| >= |mem|
    ensures ptr+32+length <= |F.Final(mem,ptr,free,length,returned)|
    ensures ptr+32+length <= S.Load(F.Final(mem,ptr,free,length,returned),64)
    ensures 160 <= S.Load(F.Final(mem,ptr,free,length,returned),64) && S.Load(F.Final(mem,ptr,free,length,returned),64)%32 == 0
  {
    hide F.Final();hide P.Packed();hide R.Complete();
    F.Admission(mem,ptr,free,length,returned);F.PackedBounds(mem,ptr,free,length,returned);
    C.MemorySize(mem,free,ptr+32,length);
    Rep.StoredWord(P.Copied(mem,ptr,free,length),free+length,0);
    var packed := P.Packed(mem,ptr,free,length);
    assert |packed| >= |mem| by { reveal P.Packed(); }
    if |returned| > 0 {
      R.Bounds(packed,free,returned);R.Layout(packed,free,returned);
      Rep.StoredWord(packed,64,R.End(free,returned));
      Rep.StoredWord(R.Pointer(packed,free,returned),free,|returned|);
      C.Size(R.Head(packed,free,returned),free+32,returned);
      assert |R.Complete(packed,free,returned)| >= |packed| by { reveal R.Complete(); }
    }
    reveal F.Final();
  }
  lemma ReceiptByte(mem: seq<S.Byte>,free: S.Word,returned: seq<S.Byte>,j: nat)
    requires R.Fits(mem,free,returned) && 96 <= j < free && j < |mem|
    ensures |R.Complete(mem,free,returned)| > j
    ensures R.Complete(mem,free,returned)[j] == mem[j]
  {
    hide G.BitAnd();hide S.BitNot();hide G.Encode();hide R.Pointer();hide R.Head();hide R.Complete();
    R.Bounds(mem,free,returned);
    W.Outside(mem,64,R.End(free,returned),j);
    var pointer := R.Pointer(mem,free,returned);
    assert pointer == S.Store(mem,64,R.End(free,returned)) by { reveal R.Pointer(); }
    assert pointer[j] == mem[j];
    W.Outside(pointer,free,|returned|,j);
    var head := R.Head(mem,free,returned);
    assert head == S.Store(pointer,free,|returned|) by { reveal R.Head(); }
    assert head[j] == pointer[j];
    C.Frame(head,free+32,returned);
    C.Size(head,free+32,returned);
    assert C.Write(head,free+32,returned)[j] == head[j];
    assert R.Complete(mem,free,returned) == C.Write(head,free+32,returned) by { reveal R.Complete(); }
  }
  lemma Original(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,returned: seq<S.Byte>,j: nat)
    requires F.Fits(mem,ptr,free,length,returned) && ptr <= j < ptr+32+length
    requires j < |mem| && j < free && ptr+32+length <= |F.Final(mem,ptr,free,length,returned)|
    ensures ptr+32+length <= |F.Final(mem,ptr,free,length,returned)|
    ensures F.Final(mem,ptr,free,length,returned)[j] == mem[j]
  {
    hide G.BitAnd();hide S.BitNot();hide G.Encode();hide F.Final();hide P.Packed();hide R.Complete();
    Bounds(mem,ptr,free,length,returned);
    P.Original(mem,ptr,free,length,j);F.Admission(mem,ptr,free,length,returned);F.PackedBounds(mem,ptr,free,length,returned);
    var packed := P.Packed(mem,ptr,free,length);
    C.MemorySize(mem,free,ptr+32,length);
    Rep.StoredWord(P.Copied(mem,ptr,free,length),free+length,0);
    assert |packed| >= |mem| by { reveal P.Packed(); }
    assert j < |packed|;
    if |returned| > 0 {
      ReceiptByte(packed,free,returned,j);
      assert F.Final(mem,ptr,free,length,returned) == R.Complete(packed,free,returned) by { reveal F.Final(); }
    } else {
      assert F.Final(mem,ptr,free,length,returned) == packed by { reveal F.Final(); }
    }
  }

  lemma Admission(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,payload: seq<S.Byte>,returned: seq<S.Byte>)
    requires F.Fits(mem,ptr,free,length,returned) && |payload| == length && mem[ptr+32..ptr+32+length] == payload
    requires S.Load(F.Final(mem,ptr,free,length,returned),64)+|payload|+|returned|+512 < D.Bound()
    ensures H.Fits(F.Final(mem,ptr,free,length,returned),ptr,F.Receipt(free,returned),S.Load(F.Final(mem,ptr,free,length,returned),64),payload,returned)
  {
    hide G.BitAnd();hide S.BitNot();hide F.Final();hide P.Packed();hide R.Complete();
    F.Admission(mem,ptr,free,length,returned);F.PackedBounds(mem,ptr,free,length,returned);F.Header(mem,ptr,free,length,returned);
    Bounds(mem,ptr,free,length,returned);
    var after := F.Final(mem,ptr,free,length,returned);var receipt := F.Receipt(free,returned);
    var packed := P.Packed(mem,ptr,free,length);
    forall j: int {:trigger after[j]} | ptr <= j < ptr+32+length
      ensures after[j] == mem[j]
    { Original(mem,ptr,free,length,returned,j); }
    forall k: nat {:trigger after[ptr+k]} | k < 32
      ensures after[ptr..ptr+32][k] == mem[ptr..ptr+32][k]
    {}
    assert after[ptr..ptr+32] == mem[ptr..ptr+32];
    forall k: nat {:trigger after[ptr+32+k]} | k < length
      ensures after[ptr+32..ptr+32+length][k] == payload[k]
    {}
    assert after[ptr+32..ptr+32+length] == payload;
    G.LoadProjection(after,ptr);G.LoadProjection(mem,ptr);
    if |returned| == 0 {
      assert after == packed by { reveal F.Final(); }
      assert S.Load(after,64) == free;
      assert S.Load(after,96) == 0;
      assert after[128..128] == returned;
    } else {
      R.Bounds(packed,free,returned);R.Layout(packed,free,returned);
      assert after == R.Complete(packed,free,returned) by { reveal F.Final(); }
      assert S.Load(after,64) == R.End(free,returned);
      assert after[receipt+32..receipt+32+|returned|] == returned;
    }
  }
}
