// SPDX-License-Identifier: MIT
// Exact reversed payload heap connects to the shared physical bytes serializer.
include "../Memory.dfy"
include "../../bytes-return/Memory.dfy"
module BytecodeReverseReturnMemoryConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeWordReverseMemory
  import B = BytecodeAlignedBytesReturnMemory
  lemma Heap(n: nat, start: S.Word, data: seq<S.Byte>)
    requires R.Admitted(n,n,start,data)
    ensures |R.Payload(n,start,data)| == n*32
    ensures R.Heap(n,n,start,data) == B.Heap(n,R.Payload(n,start,data))
  {
    R.OriginalBytes(n,start,data);
    var heap := R.Heap(n,n,start,data);
    var expected := B.Heap(n,R.Payload(n,start,data));
    assert |heap| == |expected|;
    forall j: nat {:trigger heap[j]} | j < |heap|
      ensures heap[j] == expected[j]
    {
      if j < 64 {}
      else if j < 96 {}
      else if j < 128 {}
      else if j < 160 {}
      else {
        assert heap[j] == heap[160..][j-160];
        assert expected[j] == R.Payload(n,start,data)[j-160];
      }
    }
  }
}
