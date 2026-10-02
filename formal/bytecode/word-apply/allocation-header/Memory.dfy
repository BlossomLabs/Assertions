// SPDX-License-Identifier: MIT
// Exact allocated header and the reached zero-fill CALLDATACOPY.
include "../../iota/AllocationMemory.dfy"
module BytecodeApplyAllocationMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import A = BytecodeIotaAllocationMemory
  import O = BytecodeIotaOutput
  import C = BytecodeCopyMemory
  import M = BytecodeCopyMachine
  function Head(count: nat): seq<S.Byte>
    requires count < 0x800000000000000
  { A.Head(count) }
  function Heap(count: nat): seq<S.Byte>
    requires count < 0x800000000000000
  { O.Heap(count,0) }
  lemma Header(count: nat)
    requires count < 0x800000000000000
    ensures |Head(count)| == 160
    ensures Head(count) == S.Store(S.Store(S.Store([],64,128),128,count*32),64,count*32+160)
    ensures Head(count) == Heap(count)[..160]
  { A.HeadBytes(count); }
  lemma Empty()
    ensures Head(0) == Heap(0)
  { Header(0); }
  lemma ActualCopy(code: seq<S.Byte>, count: nat, prefix: seq<S.Word>, value: S.Word, data: seq<S.Byte>)
    requires |code| > 12311 && code[12311] == 0x37
    requires count < 0x800000000000000 && |data| < G.Modulus() && |prefix| <= 1021
    ensures M.Step(code,{},S.Running(12311,prefix+[count*32,|data|,160],Head(count)),value,data) == S.Running(12312,prefix,Heap(count))
  {
    Header(count);
    A.ZeroPayload(count,data);
    M.CalldataStep(code,12311,prefix,Head(count),160,|data|,count*32,value,data);
  }
}
