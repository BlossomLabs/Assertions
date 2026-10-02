// SPDX-License-Identifier: MIT
include "../callback-failed-memory-repair-v3/Memory.dfy"
include "../callback-length-error/Scalar.dfy"
module BytecodeApplyCallbackFailedControlMemory {
  import S = BytecodeScanMachine
  import H = BytecodeApplyCallbackFailedMemory
  import D = BytecodeApplyDynamicBytesCopyMemory
  function Heap(mem: seq<S.Byte>,ptr: S.Word,receipt: S.Word,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>,k: nat): seq<S.Byte>
    requires H.Fits(mem,ptr,receipt,free,payload,reason) && k <= 9
    ensures |Heap(mem,ptr,receipt,free,operation,index,target,payload,reason,k)| >= |mem|
  {
    if k <= 6 then H.Head(mem,free,operation,index,target,k)
    else if k == 7 then H.First(mem,ptr,receipt,free,operation,index,target,payload,reason)
    else if k == 8 then H.Offset(mem,ptr,receipt,free,operation,index,target,payload,reason)
    else H.Final(mem,ptr,receipt,free,operation,index,target,payload,reason)
  }
  lemma HeapProjection(mem: seq<S.Byte>,ptr: S.Word,receipt: S.Word,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>,k: nat)
    requires H.Fits(mem,ptr,receipt,free,payload,reason) && k <= 9
    ensures Heap(mem,ptr,receipt,free,operation,index,target,payload,reason,k) == (if k <= 6 then H.Head(mem,free,operation,index,target,k) else if k == 7 then H.First(mem,ptr,receipt,free,operation,index,target,payload,reason) else if k == 8 then H.Offset(mem,ptr,receipt,free,operation,index,target,payload,reason) else H.Final(mem,ptr,receipt,free,operation,index,target,payload,reason))
  { hide H.Head();hide H.First();hide H.Offset();hide H.Final();reveal Heap(); }
  lemma FirstProjection(mem: seq<S.Byte>,ptr: S.Word,receipt: S.Word,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>)
    requires H.Fits(mem,ptr,receipt,free,payload,reason)
    requires D.Fits(H.Head(mem,free,operation,index,target,6),ptr,H.FirstDst(free),|payload|,payload)
    ensures H.First(mem,ptr,receipt,free,operation,index,target,payload,reason) == D.Stage(H.Head(mem,free,operation,index,target,6),ptr,H.FirstDst(free),|payload|,payload,3)
  { hide H.Head();hide D.Stage();H.FirstAdmission(mem,ptr,receipt,free,operation,index,target,payload,reason);reveal H.First(); }
  lemma FinalProjection(mem: seq<S.Byte>,ptr: S.Word,receipt: S.Word,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>)
    requires H.Fits(mem,ptr,receipt,free,payload,reason)
    requires D.Fits(H.Offset(mem,ptr,receipt,free,operation,index,target,payload,reason),receipt,H.ReasonDst(free,payload),|reason|,reason)
    ensures H.Final(mem,ptr,receipt,free,operation,index,target,payload,reason) == D.Stage(H.Offset(mem,ptr,receipt,free,operation,index,target,payload,reason),receipt,H.ReasonDst(free,payload),|reason|,reason,3)
  { hide H.Offset();hide D.Stage();H.ReasonAdmission(mem,ptr,receipt,free,operation,index,target,payload,reason);reveal H.Final(); }
  lemma Info(mem: seq<S.Byte>,ptr: S.Word,receipt: S.Word,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>,k: nat)
    requires H.Fits(mem,ptr,receipt,free,payload,reason) && k <= 9
    ensures |Heap(mem,ptr,receipt,free,operation,index,target,payload,reason,k)|%32 == 0 && |Heap(mem,ptr,receipt,free,operation,index,target,payload,reason,k)| < D.Bound()
    ensures S.Load(Heap(mem,ptr,receipt,free,operation,index,target,payload,reason,k),64) == free
    ensures k == 0 ==> Heap(mem,ptr,receipt,free,operation,index,target,payload,reason,k) == mem
    ensures k >= 7 ==> H.ReasonDst(free,payload) <= |Heap(mem,ptr,receipt,free,operation,index,target,payload,reason,k)|
    ensures k == 9 ==> H.End(free,payload,reason) <= |Heap(mem,ptr,receipt,free,operation,index,target,payload,reason,k)|
  {
    hide H.Head();hide H.First();hide H.Offset();hide H.Final();hide Heap();hide D.Stage();
    HeapProjection(mem,ptr,receipt,free,operation,index,target,payload,reason,k);
    if k <= 6 { H.HeadLayout(mem,free,operation,index,target,k);if k == 0 { H.HeadZero(mem,free,operation,index,target); } }
    else if k == 7 {
      H.FirstAdmission(mem,ptr,receipt,free,operation,index,target,payload,reason);
      D.Sizes(H.Head(mem,free,operation,index,target,6),ptr,H.FirstDst(free),|payload|,payload,3);
      assert H.First(mem,ptr,receipt,free,operation,index,target,payload,reason) == D.Stage(H.Head(mem,free,operation,index,target,6),ptr,H.FirstDst(free),|payload|,payload,3) by { reveal H.First(); }
    } else if k == 8 { H.OffsetLayout(mem,ptr,receipt,free,operation,index,target,payload,reason); }
    else { H.FinalLayout(mem,ptr,receipt,free,operation,index,target,payload,reason); }
    var after := Heap(mem,ptr,receipt,free,operation,index,target,payload,reason,k);
    forall j: int {:trigger after[j]} | 0 <= j < |mem| && j < free
      ensures after[j] == mem[j]
    {
      if k <= 6 { H.HeadOriginal(mem,free,operation,index,target,k,j); }
      else if k == 7 {
        H.HeadOriginal(mem,free,operation,index,target,6,j);
        H.FirstAdmission(mem,ptr,receipt,free,operation,index,target,payload,reason);
        D.Original(H.Head(mem,free,operation,index,target,6),ptr,H.FirstDst(free),|payload|,payload,3,j);
        FirstProjection(mem,ptr,receipt,free,operation,index,target,payload,reason);
      } else if k == 8 { H.OffsetOriginal(mem,ptr,receipt,free,operation,index,target,payload,reason,j); }
      else {
        H.ReasonAdmission(mem,ptr,receipt,free,operation,index,target,payload,reason);
        H.OffsetOriginal(mem,ptr,receipt,free,operation,index,target,payload,reason,j);
        D.Original(H.Offset(mem,ptr,receipt,free,operation,index,target,payload,reason),receipt,H.ReasonDst(free,payload),|reason|,reason,3,j);
        FinalProjection(mem,ptr,receipt,free,operation,index,target,payload,reason);
      }
    }
    H.Sources(mem,after,ptr,receipt,free,payload,reason);
  }
  lemma NextStore(mem: seq<S.Byte>,ptr: S.Word,receipt: S.Word,free: S.Word,operation: S.Word,index: S.Word,target: S.Word,payload: seq<S.Byte>,reason: seq<S.Byte>,k: nat)
    requires H.Fits(mem,ptr,receipt,free,payload,reason) && (k < 6 || k == 7)
    ensures Heap(mem,ptr,receipt,free,operation,index,target,payload,reason,k+1) == S.Store(Heap(mem,ptr,receipt,free,operation,index,target,payload,reason,k),if k == 0 then free else if k == 7 then free+164 else free+4+32*(k-1),if k == 0 then H.Header() else if k == 1 then operation else if k == 2 then index else if k == 3 then 0 else if k == 4 then target else if k == 5 then 192 else H.ReasonOffset(payload))
  {
    hide H.First();
    if k < 6 { H.HeadNext(mem,free,operation,index,target,k); }
    else { reveal H.Offset(); }
  }
}
