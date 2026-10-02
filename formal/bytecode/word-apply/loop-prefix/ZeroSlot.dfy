// SPDX-License-Identifier: MIT
// Derive the empty receipt zero header from the reached caller heap.
include "../loop-state/Model.dfy"
include "../callback-empty-receipt/Memory.dfy"
module BytecodeApplyRawLoopPrefixZeroSlot {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import C = BytecodeCopyMemory
  import I = BytecodeApplyRawInputs
  import L = BytecodeApplyRawLoopState
  import O = BytecodeIotaOutput
  import A = BytecodeApplyAllocationMemory
  import H = BytecodeApplyTemplateMemory
  import B = BytecodeApplyRawIterationBounds
  import M = BytecodeApplyRepeatedIterationMemory
  import F = BytecodeApplyRawCallbackMemory
  import E = BytecodeApplyEmptyReceiptMemory
  import HS = BytecodeApplyCallbackSuccessMemory
  lemma Initial(data: seq<Byte>)
    requires L.Fits(data)
    ensures Load(L.Initial(data),96) == 0
  {
    hide G.BitAnd();
    var n := L.N(data); var ptr: Word := O.Extent(n); var length := I.TemplateLength(data);
    B.Allocation(n,length,0);
    H.Arithmetic(ptr,length);
    var raw := A.Heap(n);
    O.ZeroEncoding(32);
    assert raw[96..128] == G.Encode(0,32);
    G.LoadProjection(raw,96); G.RoundTrip(0,32);
    var pointer := H.Pointer(raw,ptr,length);
    R.StoredWord(raw,64,H.Free(ptr,length));
    R.StoredFrame(raw,64,H.Free(ptr,length),96);
    var head := H.Head(raw,ptr,length);
    R.StoredWord(pointer,ptr,length);
    R.StoredFrame(pointer,ptr,length,96);
    var copied := H.Copied(raw,ptr,I.Offset(I.TemplateHead(data)),length,data);
    C.Size(head,ptr+32,Window(data,I.Offset(I.TemplateHead(data)),length));
    C.Frame(head,ptr+32,Window(data,I.Offset(I.TemplateHead(data)),length));
    forall j: int {:trigger copied[j]} | 96 <= j < 128
      ensures copied[j] == head[j]
    {}
    F.EqualLoad(copied,head,96);
    R.StoredFrame(copied,ptr+32+length,0,96);
  }
  lemma Step(data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,index: Word)
    requires L.Receipts(data,filter,receipts) && index < L.N(data)
    ensures Load(L.Update(L.Heap(data,filter,receipts,index),data,index,L.Kept(data,filter,receipts,index),filter,receipts[index]),96) == Load(L.Heap(data,filter,receipts,index),96)
  {
    hide G.BitAnd(); hide L.Heap(); hide M.After();
    var n := L.N(data); var mem := L.Heap(data,filter,receipts,index);
    var ptr: Word := O.Extent(n); var free := B.Free(n,I.TemplateLength(data),index);
    var length := I.TemplateLength(data); var arrayOffset := I.Offset(I.ArrayHead(data)); var count := I.Count(data);
    M.Layout(mem,ptr,free,length,arrayOffset,count,data,L.Original(data,index),receipts[index]);
    var after := M.After(mem,ptr,free,length,arrayOffset,count,data,L.Original(data,index),receipts[index]);
    forall j: int {:trigger after[j]} | 96 <= j < 128
      ensures after[j] == mem[j]
    {}
    F.EqualLoad(after,mem,96);
    var kept := L.Kept(data,filter,receipts,index);
    var offset: Word := 160+32*(if filter then kept else index);
    R.StoredFrame(after,offset,if filter then L.Original(data,index) else HS.Result(receipts[index]),96);
    reveal L.Update();
  }
  lemma Heap(data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,index: Word)
    requires L.Receipts(data,filter,receipts) && index <= L.N(data)
    ensures Load(L.Heap(data,filter,receipts,index),96) == 0
    decreases index
  {
    hide L.Heap(); hide L.Update();
    if index == 0 { Initial(data); }
    else {
      Heap(data,filter,receipts,index-1);
      Step(data,filter,receipts,index-1);
    }
    reveal L.Heap();
  }
  lemma EmptyAdmission(data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,index: Word)
    requires L.Receipts(data,filter,receipts) && index <= L.N(data)
    ensures E.Fits(L.Heap(data,filter,receipts,index),B.Free(L.N(data),I.TemplateLength(data),index))
  {
    hide L.Heap();
    Heap(data,filter,receipts,index);
  }
}
