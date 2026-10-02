// SPDX-License-Identifier: MIT
// Physical zero calldata copy and initial reversed heap; no allocation resource claim.
include "../../iota/AllocationMemory.dfy"
include "../Memory.dfy"
module BytecodeReverseAllocationMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import O = BytecodeIotaOutput
  import A = BytecodeIotaAllocationMemory
  import R = BytecodeWordReverseMemory
  import M = BytecodeCopyMachine
  lemma InitialHeap(n: S.Word, offset: S.Word, data: seq<S.Byte>)
    requires R.Admitted(n,0,offset,data)
    ensures R.Heap(n,0,offset,data) == O.Heap(n,0)
  {
    forall j: nat {:trigger R.Heap(n,0,offset,data)[j]} | j < R.Extent(n)
      ensures R.Heap(n,0,offset,data)[j] == O.Heap(n,0)[j]
    {
      if j >= 160 { assert (j-160)/32 < n; }
    }
  }
  lemma ActualCopy(code: seq<S.Byte>, n: S.Word, prefix: seq<S.Word>, value: S.Word, data: seq<S.Byte>)
    requires |code| > 5837 && code[5837] == 0x37
    requires n < 0x800000000000000 && |data| < G.Modulus() && |prefix| <= 1021
    ensures M.Step(code,{},S.Running(5837,prefix+[n*32,|data|,160],A.Head(n)),value,data) == S.Running(5838,prefix,O.Heap(n,0))
  {
    A.HeadBytes(n); O.Aligned(n); A.ZeroPayload(n,data);
    M.CalldataStep(code,5837,prefix,A.Head(n),160,|data|,n*32,value,data);
  }
}
