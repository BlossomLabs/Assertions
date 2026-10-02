// SPDX-License-Identifier: MIT
include "../loop-bytes/Bytes.dfy"
include "../serializer-repair-v2/Memory.dfy"
include "../store-bytes/Frame.dfy"
module BytecodeApplyRawSuccessfulOutput {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import I = BytecodeApplyRawInputs
  import L = BytecodeApplyRawLoopState
  import B = BytecodeApplyRawIterationBounds
  import H = BytecodeApplyTemplateMemory
  import O = BytecodeIotaOutput
  import P = BytecodeApplyRawLoopOutputProperties
  import Y = BytecodeApplyRawLoopOutputBytes
  import R = BytecodeScanRepresentation
  import F = BytecodeApplyStoreByteFrame
  import A = BytecodeApplyBytesReturnMemory
  function Final(data: seq<S.Byte>,filter: bool,receipts: seq<seq<S.Byte>>): seq<S.Byte>
    requires L.Receipts(data,filter,receipts)
  {
    var heap := L.Heap(data,filter,receipts,L.N(data));
    if filter then S.Store(heap,128,32*L.Kept(data,filter,receipts,L.N(data))) else heap
  }
  lemma Ready(data: seq<S.Byte>,filter: bool,receipts: seq<seq<S.Byte>>)
    requires L.Receipts(data,filter,receipts)
    ensures A.Fits(Final(data,filter,receipts),B.Free(L.N(data),I.TemplateLength(data),L.N(data)),L.Kept(data,filter,receipts,L.N(data)),Y.Payload(data,filter,receipts,L.N(data)))
  {
    hide G.BitAnd();
    hide L.Heap();
    var n := L.N(data);
    var kept := L.Kept(data,filter,receipts,n);
    var heap := L.Heap(data,filter,receipts,n);
    var free := B.Free(n,I.TemplateLength(data),n);
    var payload := Y.Payload(data,filter,receipts,n);
    P.HeapWords(data,filter,receipts,n);
    Y.PhysicalBytes(data,filter,receipts,n);
    H.Arithmetic(O.Extent(n),I.TemplateLength(data));
    assert free%32 == 0;
    assert (free as nat)+96+kept*32 < A.Bound();
    assert |heap|%32 == 0 && 160+n*32 <= |heap| < A.Bound();
    assert S.Load(heap,64) == free;
    if filter {
      R.StoredWord(heap,128,32*kept);
      R.StoredFrame(heap,128,32*kept,64);
      var after := S.Store(heap,128,32*kept);
      forall j: int {:trigger after[j]} | 160 <= j < 160+32*kept
        ensures after[j] == heap[j]
      { F.Outside(heap,128,32*kept,j); }
      assert after[160..160+32*kept] == payload;
    } else {
      assert kept == n && I.SourceLength(data) == n*32;
    }
  }
}
