// SPDX-License-Identifier: MIT
// Actual ordered read returns an original retained calldata word.
include "WordAt.generated.dfy"
include "../Memory.dfy"
module BytecodeUniqueOriginalWordRead {
  import S = BytecodeScanMachine
  import U = BytecodeWordUniqueMemory
  import H = BytecodeUniqueMemoryHelperWordAt
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  lemma Memory(capacity: nat, ids: seq<nat>, start: U.Word, data: seq<U.Byte>, index: U.Word)
    requires U.Admitted(capacity,ids,start,data,capacity) && index < |ids|
    ensures H.MemoryAdmitted(U.Heap(capacity,ids,start,data,capacity),index)
    ensures S.Load(U.Heap(capacity,ids,start,data,capacity),160+index*32) == U.Source(capacity,ids[index],start,data)
  {
    U.WordAt(capacity,ids,start,data,capacity,index);
    assert index < capacity;
    assert S.Round32(U.Extent(capacity)) == U.Extent(capacity);
  }
  ghost method Run(code: seq<U.Byte>, capacity: nat, ids: seq<nat>, start: U.Word,
                   data: seq<U.Byte>, index: U.Word, prefix: seq<U.Word>, value: U.Word)
    returns (state: S.State, trace: seq<S.State>)
    requires H.Matches(code) && |prefix| <= 1000
    requires U.Admitted(capacity,ids,start,data,capacity) && index < |ids|
    ensures state == S.Running(6836,prefix+[U.Source(capacity,ids[index],start,data)],U.Heap(capacity,ids,start,data,capacity))
    ensures E.Trace(code,H.Destinations(),value,data,trace)
    ensures |trace| == 14 && trace[0] == S.Running(3833,prefix+[6836,128,index],U.Heap(capacity,ids,start,data,capacity)) && trace[|trace|-1] == state
  {
    Memory(capacity,ids,start,data,index);
    state,trace := H.Run(code,prefix,index,U.Heap(capacity,ids,start,data,capacity),value,data);
  }
}
