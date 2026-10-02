// SPDX-License-Identifier: MIT
include "Completion.dfy"
module BytecodeApplyRawLoopPrefixBindings {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeApplyRawInputs
  import O = BytecodeIotaOutput
  import L = BytecodeApplyRawLoopState
  import B = BytecodeApplyRawIterationBounds
  import M = BytecodeApplyRepeatedIterationMemory
  import H = BytecodeApplyCallbackSuccessMemory
  import V = BytecodeApplySuccessfulIterationEngine
  import R = BytecodeApplyElementRead
  import AM = BytecodeApplyAddressMask
  predicate TapePrefix(data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,self: Word,stop: Word,cursor: nat,before: seq<Word>,requested: seq<Word>,observations: seq<X.Observation>) {
    L.Receipts(data,filter,receipts) && stop <= L.N(data) && |before| == stop && |requested| == stop && cursor+3*stop <= |observations| &&
    forall index: Word {:trigger receipts[index]} :: index < stop ==>
      observations[cursor+3*index] == X.Gas(before[index]) && observations[cursor+3*index+1] == X.Gas(requested[index]) &&
      observations[cursor+3*index+2] == X.StaticCall(self,requested[index],I.Target(data),M.Stamped(L.Heap(data,filter,receipts,index),O.Extent(L.N(data)),B.Free(L.N(data),I.TemplateLength(data),index),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,L.Original(data,index))[O.Extent(L.N(data))+32..O.Extent(L.N(data))+32+I.TemplateLength(data)],true,receipts[index])
  }
  lemma Slot(data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,self: Word,stop: Word,cursor: nat,before: seq<Word>,requested: seq<Word>,observations: seq<X.Observation>,index: Word)
    requires TapePrefix(data,filter,receipts,self,stop,cursor,before,requested,observations) && index < stop
    requires R.Admitted(data,I.Offset(I.SourceHead(data)),I.SourceLength(data),L.N(data),index)
    requires M.Fits(L.Heap(data,filter,receipts,index),O.Extent(L.N(data)),Load(L.Heap(data,filter,receipts,index),64),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    ensures |receipts[index]| == 32 && (!filter || H.Result(receipts[index]) <= 1)
    ensures cursor+3*index+2 < |observations|
    ensures observations[cursor+3*index] == X.Gas(before[index]) && observations[cursor+3*index+1] == X.Gas(requested[index])
    ensures observations[cursor+3*index+2] == X.StaticCall(self,requested[index],I.Target(data),M.Stamped(L.Heap(data,filter,receipts,index),O.Extent(L.N(data)),Load(L.Heap(data,filter,receipts,index),64),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,DataWord(data,I.Offset(I.SourceHead(data))+index*32))[O.Extent(L.N(data))+32..O.Extent(L.N(data))+32+I.TemplateLength(data)],true,receipts[index])
  {
    hide G.BitAnd();
    hide L.Heap();
    hide M.Stamped();
    var mem := L.Heap(data,filter,receipts,index);
    assert Load(mem,64) == B.Free(L.N(data),I.TemplateLength(data),index);
    assert L.Original(data,index) == DataWord(data,I.Offset(I.SourceHead(data))+32*index);
  }
}
