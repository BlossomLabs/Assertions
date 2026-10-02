// SPDX-License-Identifier: MIT
// Only reached successful iterations and the first bad callback are observed.
include "../loop-prefix-repair-v2/Engine.dfy"
include "../wrong-size-iteration-repair-v8/Memory.dfy"
module BytecodeApplyRawWrongSizeBindings {
  import opened BytecodeScanMachine
  import X = BytecodeExternalMachine
  import C = BytecodeApplyRawLoopPrefixCompletion
  import L = BytecodeApplyRawLoopState
  import I = BytecodeApplyRawInputs
  import B = BytecodeApplyRawIterationBounds
  import O = BytecodeIotaOutput
  import M = BytecodeApplyRepeatedIterationMemory
  function Completed(data: seq<Byte>,filter: bool,actual: seq<seq<Byte>>): seq<seq<Byte>>
    requires C.Successful(data,filter,actual)
    ensures L.Receipts(data,filter,Completed(data,filter,actual))
    ensures Completed(data,filter,actual) == C.Complete(data,filter,actual)
  { C.Admits(data,filter,actual); C.Complete(data,filter,actual) }
  predicate BadTape(data: seq<Byte>,filter: bool,actual: seq<seq<Byte>>,self: Word,cursor: nat,observations: seq<X.Observation>,gasBefore: Word,requestedGas: Word,returned: seq<Byte>)
    requires C.Successful(data,filter,actual) && |actual| < L.N(data)
  {
    var receipts := Completed(data,filter,actual);
    var index: Word := |actual|;
    var mem := L.Heap(data,filter,receipts,index);
    var ptr: Word := O.Extent(L.N(data));
    var free := B.Free(L.N(data),I.TemplateLength(data),index);
    var stamped := M.Stamped(mem,ptr,free,I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,L.Original(data,index));
    cursor+2 < |observations| && observations[cursor] == X.Gas(gasBefore) && observations[cursor+1] == X.Gas(requestedGas)
    && observations[cursor+2] == X.StaticCall(self,requestedGas,I.Target(data),stamped[ptr+32..ptr+32+I.TemplateLength(data)],true,returned)
  }
}
