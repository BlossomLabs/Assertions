// SPDX-License-Identifier: MIT
// Physical zero copy and initial interleaved heap, without a resource-availability claim.
include "../../iota/AllocationMemory.dfy"
include "../Memory.dfy"
module BytecodeZipAllocationMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import O = BytecodeIotaOutput
  import A = BytecodeIotaAllocationMemory
  import R = BytecodeWordZipMemory
  import M = BytecodeCopyMachine
  lemma InitialHeap(count: S.Word, a: S.Word, b: S.Word, data: seq<S.Byte>)
    requires R.Admitted(count,0,a,b,data)
    ensures R.Heap(count,0,a,b,data) == O.Heap(2*count,0)
  {
    forall j: nat {:trigger R.Heap(count,0,a,b,data)[j]} | j < R.Extent(count)
      ensures R.Heap(count,0,a,b,data)[j] == O.Heap(2*count,0)[j]
    {
      if j >= 160 { assert (j-160)/32 < 2*count; }
    }
  }
  lemma ActualCopy(code: seq<S.Byte>, n: S.Word, prefix: seq<S.Word>, value: S.Word, data: seq<S.Byte>)
    requires |code| > 2085 && code[2085] == 0x37
    requires n < 0x800000000000000 && |data| < G.Modulus() && |prefix| <= 1021
    ensures M.Step(code,{},S.Running(2085,prefix+[n*32,|data|,160],A.Head(n)),value,data) == S.Running(2086,prefix,O.Heap(n,0))
  {
    A.HeadBytes(n); O.Aligned(n); A.ZeroPayload(n,data);
    M.CalldataStep(code,2085,prefix,A.Head(n),160,|data|,n*32,value,data);
  }
}
