// SPDX-License-Identifier: MIT
include "../iteration-bounds/Bounds.dfy"
module BytecodeApplyRawLoopState {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import I = BytecodeApplyRawInputs
  import W = BytecodeApplyWindowInputs
  import A = BytecodeApplyAllocationMemory
  import O = BytecodeIotaOutput
  import H = BytecodeApplyTemplateMemory
  import R = BytecodeApplyRawCallbackMemory
  import F = BytecodeApplyRawStampMemory
  import M = BytecodeApplyRepeatedIterationMemory
  import B = BytecodeApplyRawIterationBounds
  import C = BytecodeApplyCallbackSuccessMemory
  predicate Fits(data: seq<S.Byte>) {
    I.Fits(data) && 0 < I.SourceLength(data) && I.SourceLength(data)%32 == 0 &&
    W.Valid(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
  }
  function N(data: seq<S.Byte>): S.Word
    requires Fits(data)
    ensures 0 < N(data) < 0x800000000000000
  { I.SourceLength(data)/32 }
  predicate Receipts(data: seq<S.Byte>,filter: bool,receipts: seq<seq<S.Byte>>) {
    Fits(data) && |receipts| == N(data) &&
    forall index: int {:trigger receipts[index]} :: 0 <= index < |receipts| ==> |receipts[index]| == 32 && (!filter || C.Result(receipts[index]) <= 1)
  }
  function Original(data: seq<S.Byte>,index: S.Word): S.Word
    requires Fits(data) && index < N(data)
    ensures Original(data,index) == S.DataWord(data,I.Offset(I.SourceHead(data))+32*index)
    ensures Original(data,index) == G.Decode(data[I.Offset(I.SourceHead(data))+32*index..I.Offset(I.SourceHead(data))+32*index+32])
  {
    B.RawSource(data,index);
    S.DataWord(data,I.Offset(I.SourceHead(data))+32*index)
  }
  function Kept(data: seq<S.Byte>,filter: bool,receipts: seq<seq<S.Byte>>,index: S.Word): S.Word
    requires Receipts(data,filter,receipts) && index <= N(data)
    ensures Kept(data,filter,receipts,index) <= index
    ensures !filter ==> Kept(data,filter,receipts,index) == index
    decreases index
  {
    if index == 0 then 0
    else Kept(data,filter,receipts,index-1)+(if filter && C.Result(receipts[index-1]) == 0 then 0 else 1)
  }
  function Selected(data: seq<S.Byte>,filter: bool,receipts: seq<seq<S.Byte>>,index: S.Word): seq<S.Word>
    requires Receipts(data,filter,receipts) && index <= N(data)
    ensures |Selected(data,filter,receipts,index)| == Kept(data,filter,receipts,index)
    decreases index
  {
    if index == 0 then []
    else var before := Selected(data,filter,receipts,index-1);
         if filter && C.Result(receipts[index-1]) == 0 then before
         else before+[if filter then Original(data,index-1) else C.Result(receipts[index-1])]
  }
  function Initial(data: seq<S.Byte>): seq<S.Byte>
    requires Fits(data)
    ensures M.Fits(Initial(data),O.Extent(N(data)),B.Free(N(data),I.TemplateLength(data),0),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
  {
    InitialFits(data);
    H.Complete(A.Heap(N(data)),O.Extent(N(data)),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data)
  }
  lemma InitialFits(data: seq<S.Byte>)
    requires Fits(data)
    ensures M.Fits(H.Complete(A.Heap(N(data)),O.Extent(N(data)),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data),O.Extent(N(data)),B.Free(N(data),I.TemplateLength(data),0),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
  {
    var n := N(data);
    F.CompleteFits(n,I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data);
    R.Admission(n,I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,0,0);
    B.Allocation(n,I.TemplateLength(data),0);
  }
  function Update(mem: seq<S.Byte>,data: seq<S.Byte>,index: S.Word,kept: S.Word,filter: bool,returned: seq<S.Byte>): seq<S.Byte>
    requires Fits(data) && index < N(data) && kept <= index && |returned| == 32
    requires M.Fits(mem,O.Extent(N(data)),B.Free(N(data),I.TemplateLength(data),index),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
  {
    var n := N(data);
    var after := M.After(mem,O.Extent(n),B.Free(n,I.TemplateLength(data),index),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,Original(data,index),returned);
    if filter && C.Result(returned) == 0 then after
    else S.Store(after,160+32*(if filter then kept else index),if filter then Original(data,index) else C.Result(returned))
  }
  lemma StepFits(mem: seq<S.Byte>,data: seq<S.Byte>,index: S.Word,kept: S.Word,filter: bool,returned: seq<S.Byte>)
    requires Fits(data) && index < N(data) && kept <= index && |returned| == 32
    requires M.Fits(mem,O.Extent(N(data)),B.Free(N(data),I.TemplateLength(data),index),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    ensures M.Fits(Update(mem,data,index,kept,filter,returned),O.Extent(N(data)),B.Free(N(data),I.TemplateLength(data),index+1),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
  {
    var n := N(data); var ptr: S.Word := O.Extent(n); var length := I.TemplateLength(data);
    var free := B.Free(n,length,index); var arrayOffset := I.Offset(I.ArrayHead(data)); var count := I.Count(data);
    var word := Original(data,index);
    M.Bounds(mem,ptr,free,length,arrayOffset,count,data,word,returned);
    M.Layout(mem,ptr,free,length,arrayOffset,count,data,word,returned);
    var after := M.After(mem,ptr,free,length,arrayOffset,count,data,word,returned);
    if !filter || C.Result(returned) != 0 {
      var offset: S.Word := 160+32*(if filter then kept else index);
      assert offset+32 <= ptr;
      M.OutputWrite(after,ptr,free+64,length,arrayOffset,count,data,offset,if filter then word else C.Result(returned));
    }
    B.Advance(n,length,index);
  }
  function Step(mem: seq<S.Byte>,data: seq<S.Byte>,index: S.Word,kept: S.Word,filter: bool,returned: seq<S.Byte>): seq<S.Byte>
    requires Fits(data) && index < N(data) && kept <= index && |returned| == 32
    requires M.Fits(mem,O.Extent(N(data)),B.Free(N(data),I.TemplateLength(data),index),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    ensures M.Fits(Step(mem,data,index,kept,filter,returned),O.Extent(N(data)),B.Free(N(data),I.TemplateLength(data),index+1),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
  {
    StepFits(mem,data,index,kept,filter,returned);
    Update(mem,data,index,kept,filter,returned)
  }
  function Heap(data: seq<S.Byte>,filter: bool,receipts: seq<seq<S.Byte>>,index: S.Word): seq<S.Byte>
    requires Receipts(data,filter,receipts) && index <= N(data)
    ensures M.Fits(Heap(data,filter,receipts,index),O.Extent(N(data)),B.Free(N(data),I.TemplateLength(data),index),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    decreases index
  {
    if index == 0 then Initial(data)
    else Step(Heap(data,filter,receipts,index-1),data,index-1,Kept(data,filter,receipts,index-1),filter,receipts[index-1])
  }
}
