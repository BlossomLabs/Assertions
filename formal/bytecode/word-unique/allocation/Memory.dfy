// SPDX-License-Identifier: MIT
// Actual zero copy and initial unique-word heap; resources remain conditional.
include "../../iota/AllocationMemory.dfy"
include "../Memory.dfy"
module BytecodeUniqueAllocationMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import O = BytecodeIotaOutput
  import A = BytecodeIotaAllocationMemory
  import R = BytecodeWordUniqueMemory
  import M = BytecodeCopyMachine
  lemma InitialHeap(n: S.Word, offset: S.Word, data: seq<S.Byte>)
    requires R.Admitted(n,[],offset,data,n)
    ensures R.Heap(n,[],offset,data,n) == O.Heap(n,0)
  {
    forall j: nat {:trigger R.Heap(n,[],offset,data,n)[j]} | j < R.Extent(n)
      ensures R.Heap(n,[],offset,data,n)[j] == O.Heap(n,0)[j]
    {
      if j >= 160 { assert (j-160)/32 < n; }
    }
  }
  lemma ActualCopy(code: seq<S.Byte>, n: S.Word, prefix: seq<S.Word>, value: S.Word, data: seq<S.Byte>)
    requires |code| > 6714 && code[6714] == 0x37
    requires n < 0x800000000000000 && |data| < G.Modulus() && |prefix| <= 1021
    ensures M.Step(code,{},S.Running(6714,prefix+[n*32,|data|,160],A.Head(n)),value,data) == S.Running(6715,prefix,O.Heap(n,0))
  {
    A.HeadBytes(n); O.Aligned(n); A.ZeroPayload(n,data);
    M.CalldataStep(code,6714,prefix,A.Head(n),160,|data|,n*32,value,data);
  }
}
