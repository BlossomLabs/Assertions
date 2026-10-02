// SPDX-License-Identifier: MIT
include "../iteration-engine/Engine.dfy"
include "../loop-state/Model.dfy"
module BytecodeApplyRawLoopBindings {
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
  function Last(oldReturn: seq<Byte>,receipts: seq<seq<Byte>>,index: nat): seq<Byte>
    requires index <= |receipts|
  { if index == 0 then oldReturn else receipts[index-1] }
  function Stack(data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,prefix: seq<Word>,returnPc: Word,index: Word): seq<Word>
    requires L.Receipts(data,filter,receipts) && index <= L.N(data)
  { prefix+[returnPc,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),if filter then 1 else 0,128,L.N(data),L.Kept(data,filter,receipts,index),O.Extent(L.N(data)),index] }
  lemma StackShape(data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,prefix: seq<Word>,returnPc: Word,index: Word)
    requires L.Receipts(data,filter,receipts) && index <= L.N(data)
    ensures Stack(data,filter,receipts,prefix,returnPc,index) == prefix+[returnPc,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),if filter then 1 else 0,128,L.N(data),L.Kept(data,filter,receipts,index),O.Extent(L.N(data)),index]
  {}
  predicate Tape(data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,self: Word,cursor: nat,before: seq<Word>,requested: seq<Word>,observations: seq<X.Observation>) {
    L.Receipts(data,filter,receipts) && |before| == L.N(data) && |requested| == L.N(data) && cursor+3*L.N(data) <= |observations| &&
    forall index: Word {:trigger receipts[index]} :: index < L.N(data) ==>
                                                       observations[cursor+3*index] == X.Gas(before[index]) && observations[cursor+3*index+1] == X.Gas(requested[index]) &&
                                                       observations[cursor+3*index+2] == X.StaticCall(self,requested[index],I.Target(data),M.Stamped(L.Heap(data,filter,receipts,index),O.Extent(L.N(data)),B.Free(L.N(data),I.TemplateLength(data),index),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,L.Original(data,index))[O.Extent(L.N(data))+32..O.Extent(L.N(data))+32+I.TemplateLength(data)],true,receipts[index])
  }
  lemma ReadAdmission(data: seq<Byte>,index: Word)
    requires L.Fits(data) && index < L.N(data)
    ensures R.Admitted(data,I.Offset(I.SourceHead(data)),I.SourceLength(data),L.N(data),index)
    ensures I.Target(data) < AM.Bound()
  {
    hide G.BitAnd();
    I.Pointer(I.SourceHead(data));
    assert I.SourceLength(data) == L.N(data)*32;
  }
  lemma Slot(data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,self: Word,cursor: nat,before: seq<Word>,requested: seq<Word>,observations: seq<X.Observation>,index: Word)
    requires Tape(data,filter,receipts,self,cursor,before,requested,observations) && index < L.N(data)
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
  lemma Step(data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,prefix: seq<Word>,returnPc: Word,oldReturn: seq<Byte>,index: Word)
    requires L.Receipts(data,filter,receipts) && index < L.N(data)
    requires R.Admitted(data,I.Offset(I.SourceHead(data)),I.SourceLength(data),L.N(data),index)
    requires M.Fits(L.Heap(data,filter,receipts,index),O.Extent(L.N(data)),Load(L.Heap(data,filter,receipts,index),64),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    ensures V.Output(L.Heap(data,filter,receipts,index),data,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),L.N(data),L.Kept(data,filter,receipts,index),index,filter,receipts[index]) == L.Heap(data,filter,receipts,index+1)
    ensures Stack(data,filter,receipts,prefix,returnPc,index+1) == prefix+[returnPc,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),if filter then 1 else 0,128,L.N(data),L.Kept(data,filter,receipts,index)+(if filter && H.Result(receipts[index]) == 0 then 0 else 1),O.Extent(L.N(data)),index+1]
    ensures Last(oldReturn,receipts,index+1) == receipts[index]
  {
    hide G.BitAnd();
    hide M.After();
    ReadAdmission(data,index);
    var mem := L.Heap(data,filter,receipts,index);
    assert Load(mem,64) == B.Free(L.N(data),I.TemplateLength(data),index);
    assert L.Original(data,index) == DataWord(data,I.Offset(I.SourceHead(data))+32*index);
    assert L.Heap(data,filter,receipts,index+1) == L.Update(mem,data,index,L.Kept(data,filter,receipts,index),filter,receipts[index]);
  }
  lemma ProductStep(factor: nat,index: nat)
    ensures factor*(index+1) == factor*index+factor
  {}
  lemma LengthStep(data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,index: Word)
    requires L.Receipts(data,filter,receipts) && index < L.N(data)
    ensures 1+(if filter then 338 else 357)*(index+1)+40*(I.Count(data) as nat)*(index+1)+(if filter then 32*(L.Kept(data,filter,receipts,index+1) as nat) else 0) ==
            1+(if filter then 338 else 357)*index+40*(I.Count(data) as nat)*index+(if filter then 32*(L.Kept(data,filter,receipts,index) as nat) else 0)+(if filter then (if H.Result(receipts[index]) == 0 then 338 else 370) else 357)+40*(I.Count(data) as nat)
  {
    hide G.BitAnd();
    ProductStep(if filter then 338 else 357,index);
    ProductStep(40*(I.Count(data) as nat),index);
    assert L.Kept(data,filter,receipts,index+1) == L.Kept(data,filter,receipts,index)+(if filter && H.Result(receipts[index]) == 0 then 0 else 1);
  }
}
