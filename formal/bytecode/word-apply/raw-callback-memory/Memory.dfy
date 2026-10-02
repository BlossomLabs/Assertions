// SPDX-License-Identifier: MIT
// Derived callback admission after actual template allocation and ordered stamping.
include "../raw-stamp/Memory.dfy"
include "../callback-copy/Memory.dfy"
module BytecodeApplyRawCallbackMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import C = BytecodeCopyMemory
  import A = BytecodeApplyAllocationMemory
  import O = BytecodeIotaOutput
  import H = BytecodeApplyTemplateMemory
  import F = BytecodeApplyTemplateFrame
  import M = BytecodeApplyStampMemory
  import W = BytecodeApplyWindowInputs
  import T = BytecodeApplyRawStampMemory
  import P = BytecodeApplyCallbackCopyMemory
  lemma EqualLoad(lhs: seq<S.Byte>,rhs: seq<S.Byte>,offset: S.Word)
    requires (offset as nat)+32 <= |lhs| && (offset as nat)+32 <= |rhs|
    requires forall j: int {:trigger lhs[j]} :: offset <= j < (offset as nat)+32 ==> lhs[j] == rhs[j]
    ensures S.Load(lhs,offset) == S.Load(rhs,offset)
  {
    var left := lhs[offset..offset+32]; var right := rhs[offset..offset+32];
    assert |left| == 32 && |right| == 32;
    forall j: int | 0 <= j < 32
      ensures left[j] == right[j]
    { assert lhs[(offset as nat)+j] == rhs[(offset as nat)+j]; }
    assert left == right;
    assert G.Grow(lhs,(offset as nat)+32) == lhs;
    assert G.Grow(rhs,(offset as nat)+32) == rhs;
  }
  lemma CopiedLoad(mem: seq<S.Byte>,dst: S.Word,src: S.Word,length: S.Word,data: seq<S.Byte>,other: S.Word)
    requires (other as nat)+32 <= |mem| && (other as nat)+32 <= dst
    ensures S.Load(C.Calldata(mem,dst,src,length,data),other) == S.Load(mem,other)
  {
    C.Size(mem,dst,S.Window(data,src,length));
    C.Frame(mem,dst,S.Window(data,src,length));
    var copied := C.Calldata(mem,dst,src,length,data);
    forall j: int {:trigger copied[j]} | other <= j < (other as nat)+32
      ensures copied[j] == mem[j]
    { assert j < dst && j < |mem|; }
    EqualLoad(copied,mem,other);
  }
  lemma StampLoad(mem: seq<S.Byte>,ptr: S.Word,length: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>,word: S.Word,index: nat,at: S.Word)
    requires M.Fits(mem,ptr,length,arrayOffset,count,data) && index <= count
    requires (at as nat)+32 <= |mem|
    requires (at as nat)+32 <= ptr+32 || ptr+32+length <= at
    ensures S.Load(M.Stamped(mem,ptr,length,arrayOffset,count,data,word,index),at) == S.Load(mem,at)
  {
    M.Extent(mem,ptr,length,arrayOffset,count,data,word,index);
    var stamped := M.Stamped(mem,ptr,length,arrayOffset,count,data,word,index);
    forall j: int {:trigger stamped[j]} | at <= j < (at as nat)+32
      ensures stamped[j] == mem[j]
    { M.Outside(mem,ptr,length,arrayOffset,count,data,word,index,j); }
    EqualLoad(stamped,mem,at);
  }
  function Stamped(n: nat,offset: S.Word,length: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>,word: S.Word): seq<S.Byte>
    requires n < 0x800000000000000 && W.Valid(length,arrayOffset,count,data)
    ensures P.Fits(Stamped(n,offset,length,arrayOffset,count,data,word),O.Extent(n),H.Free(O.Extent(n),length),length)
    ensures S.Load(Stamped(n,offset,length,arrayOffset,count,data,word),64) == H.Free(O.Extent(n),length)
    ensures S.Load(Stamped(n,offset,length,arrayOffset,count,data,word),O.Extent(n)) == length
    ensures (H.Free(O.Extent(n),length) as nat)+96 < G.Modulus()
  {
    Admission(n,offset,length,arrayOffset,count,data,word,count);
    M.Stamped(H.Complete(A.Heap(n),O.Extent(n),offset,length,data),O.Extent(n),length,arrayOffset,count,data,word,count)
  }
  lemma Layout(n: nat,offset: S.Word,length: S.Word,data: seq<S.Byte>)
    requires n < 0x800000000000000 && length < 0x10000000000000000
    ensures S.Load(H.Complete(A.Heap(n),O.Extent(n),offset,length,data),64) == H.Free(O.Extent(n),length)
    ensures S.Load(H.Complete(A.Heap(n),O.Extent(n),offset,length,data),O.Extent(n)) == length
  {
    hide G.BitAnd();
    F.Bounds(n,length);
    var ptr: S.Word := O.Extent(n);
    var mem := A.Heap(n);
    H.Arithmetic(ptr,length);
    R.StoredWord(mem,64,H.Free(ptr,length));
    R.StoredWord(H.Pointer(mem,ptr,length),ptr,length);
    R.StoredFrame(H.Pointer(mem,ptr,length),ptr,length,64);
    assert S.Load(H.Head(mem,ptr,length),64) == H.Free(ptr,length);
    assert S.Load(H.Head(mem,ptr,length),ptr) == length;
    CopiedLoad(H.Head(mem,ptr,length),ptr+32,offset,length,data,64);
    CopiedLoad(H.Head(mem,ptr,length),ptr+32,offset,length,data,ptr);
    assert S.Load(H.Copied(mem,ptr,offset,length,data),64) == H.Free(ptr,length);
    assert S.Load(H.Copied(mem,ptr,offset,length,data),ptr) == length;
    R.StoredFrame(H.Copied(mem,ptr,offset,length,data),ptr+32+length,0,64);
    R.StoredFrame(H.Copied(mem,ptr,offset,length,data),ptr+32+length,0,ptr);
  }
  lemma Admission(n: nat,offset: S.Word,length: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>,word: S.Word,index: nat)
    requires n < 0x800000000000000 && W.Valid(length,arrayOffset,count,data) && index <= count
    ensures var ptr: S.Word := O.Extent(n);
            M.Fits(H.Complete(A.Heap(n),ptr,offset,length,data),ptr,length,arrayOffset,count,data)
    ensures var ptr: S.Word := O.Extent(n);
            var mem := H.Complete(A.Heap(n),ptr,offset,length,data);
            P.Fits(M.Stamped(mem,ptr,length,arrayOffset,count,data,word,index),ptr,H.Free(ptr,length),length)
    ensures var ptr: S.Word := O.Extent(n);
            var mem := H.Complete(A.Heap(n),ptr,offset,length,data);
            S.Load(M.Stamped(mem,ptr,length,arrayOffset,count,data,word,index),64) == H.Free(ptr,length)
    ensures var ptr: S.Word := O.Extent(n);
            var mem := H.Complete(A.Heap(n),ptr,offset,length,data);
            S.Load(M.Stamped(mem,ptr,length,arrayOffset,count,data,word,index),ptr) == length
    ensures (H.Free(O.Extent(n),length) as nat)+96 < G.Modulus()
  {
    hide G.BitAnd();
    F.Bounds(n,length);
    var ptr: S.Word := O.Extent(n);
    var mem := H.Complete(A.Heap(n),ptr,offset,length,data);
    H.Arithmetic(ptr,length);
    T.CompleteFits(n,offset,length,arrayOffset,count,data);
    M.Extent(mem,ptr,length,arrayOffset,count,data,word,index);
    Layout(n,offset,length,data);
    StampLoad(mem,ptr,length,arrayOffset,count,data,word,index,64);
    StampLoad(mem,ptr,length,arrayOffset,count,data,word,index,ptr);
  }
}
