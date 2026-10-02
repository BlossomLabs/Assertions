// SPDX-License-Identifier: MIT
// Actual zero copy and initial lane heap, without a resource-availability claim.
include "../../iota/AllocationMemory.dfy"
include "../Memory.dfy"
module BytecodeUnzipAllocationMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import O = BytecodeIotaOutput
  import A = BytecodeIotaAllocationMemory
  import R = BytecodeWordUnzipMemory
  import M = BytecodeCopyMachine
  lemma InitialHeap(count: S.Word, lane: S.Word, offset: S.Word, data: seq<S.Byte>)
    requires R.Admitted(count,0,lane,offset,data)
    ensures R.Heap(count,0,lane,offset,data) == O.Heap(R.Count(count,lane),0)
  {
    forall j: nat {:trigger R.Heap(count,0,lane,offset,data)[j]} | j < R.Extent(count,lane)
      ensures R.Heap(count,0,lane,offset,data)[j] == O.Heap(R.Count(count,lane),0)[j]
    {
      if j >= 160 { assert (j-160)/32 < R.Count(count,lane); }
    }
  }
  lemma ActualCopy(code: seq<S.Byte>, n: S.Word, prefix: seq<S.Word>, value: S.Word, data: seq<S.Byte>)
    requires |code| > 6153 && code[6153] == 0x37
    requires n < 0x800000000000000 && |data| < G.Modulus() && |prefix| <= 1021
    ensures M.Step(code,{},S.Running(6153,prefix+[n*32,|data|,160],A.Head(n)),value,data) == S.Running(6154,prefix,O.Heap(n,0))
  {
    A.HeadBytes(n); O.Aligned(n); A.ZeroPayload(n,data);
    M.CalldataStep(code,6153,prefix,A.Head(n),160,|data|,n*32,value,data);
  }
}
