// SPDX-License-Identifier: MIT
// Callback admission from exact accumulator-first template stamping, including protected header.
include "../stamp-engine-repair-v2/Memory.dfy"
include "../callback-memory-repair-v2/Memory.dfy"
module BytecodeFoldSuccessfulIterationMemoryV2 {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeFoldStampMemoryV2
  import A = BytecodeApplyStampMemory
  import R = BytecodeScanRepresentation
  import P = BytecodeApplyCallbackCopyMemory
  import C = BytecodeFoldCallbackMemoryV2
  lemma Header(mem: seq<Byte>,ptr: Word,length: Word,accOffset: Word,acc: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word)
    requires M.Fits(mem,ptr,length,accOffset,arrayOffset,count,data)
    ensures Load(M.Stamped(mem,ptr,length,accOffset,acc,arrayOffset,count,data,word,count),ptr) == Load(mem,ptr)
  {
    M.AccExtent(mem,ptr,length,accOffset,arrayOffset,count,data,acc);
    var initial := M.Accumulator(mem,ptr,accOffset,acc);
    var stamped := M.Stamped(mem,ptr,length,accOffset,acc,arrayOffset,count,data,word,count);
    R.StoredFrame(mem,ptr+32+accOffset,acc,ptr);
    var left := stamped[ptr..ptr+32]; var right := initial[ptr..ptr+32];
    forall j: nat {:trigger left[j]} | j < 32
      ensures left[j] == right[j]
    {
      A.Outside(initial,ptr,length,arrayOffset,count,data,word,count,ptr+j);
      assert left[j] == stamped[ptr+j]; assert right[j] == initial[ptr+j];
    }
    assert left == right;
    G.LoadProjection(stamped,ptr); G.LoadProjection(initial,ptr);
  }
  lemma Admission(mem: seq<Byte>,ptr: Word,free: Word,length: Word,accOffset: Word,acc: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word,returned: seq<Byte>)
    requires M.Fits(mem,ptr,length,accOffset,arrayOffset,count,data) && P.Fits(mem,ptr,free,length)
    requires Load(mem,64) == free && Load(mem,ptr) == length && (free as nat)+96 < G.Modulus() && |returned| == 32
    ensures var stamped := M.Stamped(mem,ptr,length,accOffset,acc,arrayOffset,count,data,word,count);
            C.Fits(stamped,ptr,free,length,returned) && Load(stamped,64) == free && Load(stamped,ptr) == length
  {
    M.Extent(mem,ptr,length,accOffset,acc,arrayOffset,count,data,word,count);
    M.WordFrame(mem,ptr,length,accOffset,acc,arrayOffset,count,data,word,count,64);
    Header(mem,ptr,length,accOffset,acc,arrayOffset,count,data,word);
  }
}
