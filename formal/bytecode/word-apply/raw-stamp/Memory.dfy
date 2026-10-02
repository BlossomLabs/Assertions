// SPDX-License-Identifier: MIT
include "../template-frame/Frame.dfy"
include "../stamp-engine/Memory.dfy"
module BytecodeApplyRawStampMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import R = BytecodeScanRepresentation
  import A = BytecodeApplyAllocationMemory
  import O = BytecodeIotaOutput
  import H = BytecodeApplyTemplateMemory
  import F = BytecodeApplyTemplateFrame
  import W = BytecodeApplyWindowInputs
  import M = BytecodeApplyStampMemory
  lemma CompleteFits(n: nat,offset: S.Word,length: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>)
    requires n < 0x800000000000000 && W.Valid(length,arrayOffset,count,data)
    ensures M.Fits(H.Complete(A.Heap(n),O.Extent(n),offset,length,data),O.Extent(n),length,arrayOffset,count,data)
  {
    F.Bounds(n,length);
    var fp: S.Word := O.Extent(n);
    H.Arithmetic(fp,length);
    R.StoredWord(A.Heap(n),64,H.Free(fp,length));
    R.StoredWord(H.Pointer(A.Heap(n),fp,length),fp,length);
    C.Size(H.Head(A.Heap(n),fp,length),fp+32,S.Window(data,offset,length));
    C.Rounded(fp+32+length);
    assert |H.Copied(A.Heap(n),fp,offset,length,data)|%32 == 0;
    assert |H.Copied(A.Heap(n),fp,offset,length,data)| < 0x40000000000000000;
    R.StoredWord(H.Copied(A.Heap(n),fp,offset,length,data),fp+32+length,0);
  }
}
