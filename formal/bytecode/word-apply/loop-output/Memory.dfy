// SPDX-License-Identifier: MIT
include "../loop-state/Model.dfy"
module BytecodeApplyRawLoopOutputMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import SR = BytecodeScanRepresentation
  import I = BytecodeApplyRawInputs
  import L = BytecodeApplyRawLoopState
  import M = BytecodeApplyRepeatedIterationMemory
  import B = BytecodeApplyRawIterationBounds
  import C = BytecodeApplyCallbackSuccessMemory
  import A = BytecodeApplyAllocationMemory
  import O = BytecodeIotaOutput
  import F = BytecodeApplyTemplateFrame
  import R = BytecodeApplyRawCallbackMemory
  lemma InitialLoad(data: seq<S.Byte>,at: S.Word)
    requires L.Fits(data) && 96 <= at && (at as nat)+32 <= O.Extent(L.N(data))
    ensures S.Load(L.Initial(data),at) == S.Load(A.Heap(L.N(data)),at)
  {
    var n := L.N(data); var ptr := O.Extent(n);
    F.Bounds(n,I.TemplateLength(data));
    var initial := L.Initial(data); var base := A.Heap(n);
    forall j: int {:trigger initial[j]} | at <= j < (at as nat)+32
      ensures initial[j] == base[j]
    { F.Preserved(n,I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data,j); }
    R.EqualLoad(initial,base,at);
  }
  lemma CallbackLoad(mem: seq<S.Byte>,data: seq<S.Byte>,index: S.Word,returned: seq<S.Byte>,at: S.Word)
    requires L.Fits(data) && index < L.N(data) && |returned| == 32
    requires M.Fits(mem,O.Extent(L.N(data)),B.Free(L.N(data),I.TemplateLength(data),index),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    requires 96 <= at && (at as nat)+32 <= O.Extent(L.N(data))
    ensures S.Load(M.After(mem,O.Extent(L.N(data)),B.Free(L.N(data),I.TemplateLength(data),index),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,L.Original(data,index),returned),at) == S.Load(mem,at)
  {
    hide M.After();
    var n := L.N(data); var ptr: S.Word := O.Extent(n); var free := B.Free(n,I.TemplateLength(data),index);
    M.Bounds(mem,ptr,free,I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,L.Original(data,index),returned);
    M.Layout(mem,ptr,free,I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,L.Original(data,index),returned);
    var after := M.After(mem,ptr,free,I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,L.Original(data,index),returned);
    R.EqualLoad(after,mem,at);
  }
  lemma ProtectedWord(mem: seq<S.Byte>,data: seq<S.Byte>,index: S.Word,kept: S.Word,filter: bool,returned: seq<S.Byte>,at: S.Word)
    requires L.Fits(data) && index < L.N(data) && kept <= index && |returned| == 32
    requires M.Fits(mem,O.Extent(L.N(data)),B.Free(L.N(data),I.TemplateLength(data),index),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    requires 96 <= at && (at as nat)+32 <= O.Extent(L.N(data))
    requires (filter && C.Result(returned) == 0) || (at as nat)+32 <= 160+32*(if filter then kept else index) || 192+32*(if filter then kept else index) <= at
    ensures S.Load(L.Update(mem,data,index,kept,filter,returned),at) == S.Load(mem,at)
  {
    hide M.After();
    var n := L.N(data); var ptr: S.Word := O.Extent(n); var free := B.Free(n,I.TemplateLength(data),index);
    CallbackLoad(mem,data,index,returned,at);
    M.Bounds(mem,ptr,free,I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,L.Original(data,index),returned);
    var after := M.After(mem,ptr,free,I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,L.Original(data,index),returned);
    if !filter || C.Result(returned) != 0 {
      var offset: S.Word := 160+32*(if filter then kept else index);
      SR.StoredFrame(after,offset,if filter then L.Original(data,index) else C.Result(returned),at);
    }
  }
  lemma WrittenWord(mem: seq<S.Byte>,data: seq<S.Byte>,index: S.Word,kept: S.Word,filter: bool,returned: seq<S.Byte>)
    requires L.Fits(data) && index < L.N(data) && kept <= index && |returned| == 32
    requires M.Fits(mem,O.Extent(L.N(data)),B.Free(L.N(data),I.TemplateLength(data),index),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    requires !filter || C.Result(returned) != 0
    ensures S.Load(L.Update(mem,data,index,kept,filter,returned),160+32*(if filter then kept else index)) == (if filter then L.Original(data,index) else C.Result(returned))
  {
    hide M.After();
    var n := L.N(data); var ptr: S.Word := O.Extent(n); var free := B.Free(n,I.TemplateLength(data),index);
    M.Bounds(mem,ptr,free,I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,L.Original(data,index),returned);
    var after := M.After(mem,ptr,free,I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,L.Original(data,index),returned);
    SR.StoredWord(after,160+32*(if filter then kept else index),if filter then L.Original(data,index) else C.Result(returned));
  }
}
