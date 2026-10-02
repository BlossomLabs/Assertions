// SPDX-License-Identifier: MIT
// Connect actual uniqueWords output shrink to serializer heap without shrinking capacity.
include "Memory.dfy"
include "../word-unique/Memory.dfy"
module BytecodeUniqueCapacityReturnConnection {
  import U = BytecodeWordUniqueMemory
  import R = BytecodeCapacityBytesReturnMemory
  import G = BytecodeGetterMachine
  lemma Heap(capacity: nat, ids: seq<nat>, start: U.Word, data: seq<U.Byte>)
    requires U.Admitted(capacity,ids,start,data,|ids|)
    ensures U.Heap(capacity,ids,start,data,|ids|) == R.Heap(capacity,|ids|,U.Payload(capacity,ids,start,data))
  {
    U.OriginalBytes(capacity,ids,start,data,|ids|);
    var before := U.Heap(capacity,ids,start,data,|ids|);
    var after := R.Heap(capacity,|ids|,U.Payload(capacity,ids,start,data));
    forall j: nat {:trigger before[j]} | j < U.Extent(capacity)
      ensures before[j] == after[j]
    {
      if j < 64 { assert after[j] == 0; }
      else if j < 96 { assert after[j] == G.Encode(U.Extent(capacity),32)[j-64]; }
      else if j < 128 { assert after[j] == 0; }
      else if j < 160 { assert after[j] == G.Encode(|ids|*32,32)[j-128]; }
      else if j < 160+|ids|*32 {
        assert after[j] == U.Payload(capacity,ids,start,data)[j-160];
        assert before[j] == before[160..160+|ids|*32][j-160];
      } else {
        assert (j-160)/32 >= |ids|;
        assert before[j] == 0 && after[j] == 0;
      }
    }
  }
}
