// SPDX-License-Identifier: MIT
// Exact selected original-byte heap connects to the physical aligned bytes serializer.
include "../Memory.dfy"
include "../../bytes-return/Memory.dfy"
module BytecodeUnzipReturnHeapConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeWordUnzipMemory
  import B = BytecodeAlignedBytesReturnMemory
  lemma Heap(n: nat, lane: nat, start: S.Word, data: seq<S.Byte>)
    requires lane <= 1 && R.Admitted(n,R.Count(n,lane),lane,start,data)
    ensures |R.Payload(n,lane,start,data)| == R.Count(n,lane)*32
    ensures R.Heap(n,R.Count(n,lane),lane,start,data) == B.Heap(R.Count(n,lane),R.Payload(n,lane,start,data))
  {
    R.OriginalBytes(n,lane,start,data);
    var heap := R.Heap(n,R.Count(n,lane),lane,start,data);
    var expected := B.Heap(R.Count(n,lane),R.Payload(n,lane,start,data));
    assert R.Count(n,lane) <= n;
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
        assert expected[j] == R.Payload(n,lane,start,data)[j-160];
      }
    }
  }
}
