// SPDX-License-Identifier: MIT
include "../template-frame/Frame.dfy"
include "../../external-calls/Machine.dfy"
module BytecodeApplyRawTemplatePost {
  import S = BytecodeScanMachine
  import X = BytecodeExternalMachine
  import O = BytecodeIotaOutput
  import M = BytecodeApplyAllocationMemory
  import H = BytecodeApplyTemplateMemory
  import F = BytecodeApplyTemplateFrame
  lemma Payload(frame: X.Frame,n: S.Word,offset: S.Word,length: S.Word,data: seq<S.Byte>)
    requires n < 0x800000000000000 && length < 0x10000000000000000
    requires (offset as nat)+length <= |data|
    requires frame.state.Running? && frame.state.memory == H.Complete(M.Heap(n),O.Extent(n),offset,length,data)
    ensures forall j: nat {:trigger frame.state.memory[O.Extent(n)+32+j]} :: j < length ==> frame.state.memory[O.Extent(n)+32+j] == data[offset+j]
  {
    F.Bounds(n,length);
    forall j: nat {:trigger frame.state.memory[O.Extent(n)+32+j]} | j < length
      ensures frame.state.memory[O.Extent(n)+32+j] == data[offset+j]
    { F.Copied(n,offset,length,data,j); }
  }
  lemma Original(frame: X.Frame,n: S.Word,offset: S.Word,length: S.Word,data: seq<S.Byte>)
    requires n < 0x800000000000000 && length < 0x10000000000000000
    requires frame.state.Running? && frame.state.memory == H.Complete(M.Heap(n),O.Extent(n),offset,length,data)
    ensures forall j: nat :: j < O.Extent(n) && (j < 64 || 96 <= j) ==> frame.state.memory[j] == M.Heap(n)[j]
  {
    forall j: nat | j < O.Extent(n) && (j < 64 || 96 <= j)
      ensures frame.state.memory[j] == M.Heap(n)[j]
    { F.Preserved(n,offset,length,data,j); }
  }
}
