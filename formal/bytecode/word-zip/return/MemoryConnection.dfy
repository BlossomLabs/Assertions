// SPDX-License-Identifier: MIT
// Exact selected original-byte heap connects to the physical aligned bytes serializer.
include "../Memory.dfy"
include "../../bytes-return/Memory.dfy"
module BytecodeZipReturnHeapConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeWordZipMemory
  import B = BytecodeAlignedBytesReturnMemory
  lemma Heap(n: nat, a: S.Word, b: S.Word, data: seq<S.Byte>)
    requires R.Admitted(n,2*n,a,b,data)
    ensures |R.Payload(n,a,b,data)| == 2*n*32
    ensures R.Heap(n,2*n,a,b,data) == B.Heap(2*n,R.Payload(n,a,b,data))
  {
    R.OriginalBytes(n,a,b,data);
    var heap := R.Heap(n,2*n,a,b,data);
    var expected := B.Heap(2*n,R.Payload(n,a,b,data));
    assert 2*n < 0x800000000000000;
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
        assert expected[j] == R.Payload(n,a,b,data)[j-160];
      }
    }
  }
}
