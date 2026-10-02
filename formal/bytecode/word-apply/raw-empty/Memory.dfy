// SPDX-License-Identifier: MIT
include "../allocation-header/Memory.dfy"
include "../../bytes-return/Memory.dfy"
module BytecodeApplyEmptyHeap {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import A = BytecodeApplyAllocationMemory
  import O = BytecodeIotaOutput
  import R = BytecodeAlignedBytesReturnMemory
  lemma Exact()
    ensures A.Heap(0) == R.Heap(0,[])
    ensures S.Store(A.Heap(0),128,0) == A.Heap(0)
  {
    O.ZeroEncoding(32);
    var heap := A.Heap(0);
    var expected := R.Heap(0,[]);
    assert |heap| == 160 && |expected| == 160;
    forall j: nat | j < 160
      ensures heap[j] == expected[j]
    {
      if j < 64 {} else if j < 96 {} else if j < 128 {} else {}
    }
    assert heap[128..160] == G.Encode(0,32);
    assert S.Expand(heap,160) == heap;
  }
}
