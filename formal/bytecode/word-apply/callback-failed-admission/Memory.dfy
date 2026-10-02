// SPDX-License-Identifier: MIT
include "../callback-receipt-engine/Memory.dfy"
include "../callback-failed-memory-repair-v3/Memory.dfy"
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
  lemma Original(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,returned: seq<S.Byte>,j: nat)
    requires F.Fits(mem,ptr,free,length,returned) && ptr <= j < ptr+32+length
    ensures F.Final(mem,ptr,free,length,returned)[j] == mem[j]
  {
    hide F.Final();hide P.Packed();hide R.Complete();
    P.Original(mem,ptr,free,length,j);F.Admission(mem,ptr,free,length,returned);F.PackedBounds(mem,ptr,free,length,returned);
    var packed := P.Packed(mem,ptr,free,length);
    if |returned| > 0 {
      R.Bounds(packed,free,returned);
      W.Outside(packed,64,R.End(free,returned),j);
      W.Outside(R.Pointer(packed,free,returned),free,|returned|,j);
      C.Frame(R.Head(packed,free,returned),free+32,returned);
      assert EM.ReturnCopy(R.Head(packed,free,returned),free+32,0,|returned|,returned) == C.Write(R.Head(packed,free,returned),free+32,returned);
      reveal R.Complete();
    }
    reveal F.Final();
  }
  lemma Admission(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,payload: seq<S.Byte>,returned: seq<S.Byte>)
    requires F.Fits(mem,ptr,free,length,returned) && |payload| == length && mem[ptr+32..ptr+32+length] == payload
    requires S.Load(F.Final(mem,ptr,free,length,returned),64)+|payload|+|returned|+512 < D.Bound()
    ensures H.Fits(F.Final(mem,ptr,free,length,returned),ptr,F.Receipt(free,returned),S.Load(F.Final(mem,ptr,free,length,returned),64),payload,returned)
  {
    hide G.BitAnd();hide S.BitNot();hide F.Final();hide P.Packed();hide R.Complete();
    F.Admission(mem,ptr,free,length,returned);F.PackedBounds(mem,ptr,free,length,returned);F.Header(mem,ptr,free,length,returned);
    var after := F.Final(mem,ptr,free,length,returned);var receipt := F.Receipt(free,returned);
    var packed := P.Packed(mem,ptr,free,length);
    forall j: int {:trigger after[j]} | ptr <= j < ptr+32+length
      ensures after[j] == mem[j]
    { Original(mem,ptr,free,length,returned,j); }
    assert after[ptr..ptr+32] == mem[ptr..ptr+32];
    G.LoadProjection(after,ptr);G.LoadProjection(mem,ptr);
    if |returned| == 0 {
      assert after == packed by { reveal F.Final(); }
      assert S.Load(after,64) == free;
    } else {
      R.Bounds(packed,free,returned);R.Layout(packed,free,returned);
      assert after == R.Complete(packed,free,returned) by { reveal F.Final(); }
      assert S.Load(after,64) == R.End(free,returned);
      assert after[receipt+32..receipt+32+|returned|] == returned;
    }
  }
}
