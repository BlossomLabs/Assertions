// SPDX-License-Identifier: MIT
// Copied template bytes and disjoint pre-allocation FoldRun word frames.
include "../../word-apply/template-copy/Memory.dfy"
include "../run-allocation/Memory.dfy"
module BytecodeFoldTemplateFrames {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import R = BytecodeScanRepresentation
  import H = BytecodeApplyTemplateMemory
  predicate Admitted(mem: seq<S.Byte>,fp: S.Word,offset: S.Word,length: S.Word,data: seq<S.Byte>) {
    96 <= |mem| <= fp < 0x20000000000000000 && |mem|%32 == 0 &&
    length < 0x10000000000000000 && (offset as nat)+length <= |data|
  }
  lemma Geometry(mem: seq<S.Byte>,fp: S.Word,offset: S.Word,length: S.Word,data: seq<S.Byte>)
    requires Admitted(mem,fp,offset,length,data)
    ensures |H.Pointer(mem,fp,length)| == |mem| && |H.Pointer(mem,fp,length)|%32 == 0
    ensures |H.Head(mem,fp,length)| >= fp+32 && |H.Head(mem,fp,length)|%32 == 0
    ensures |H.Copied(mem,fp,offset,length,data)| >= fp+32+length && |H.Copied(mem,fp,offset,length,data)|%32 == 0
    ensures |H.Complete(mem,fp,offset,length,data)| >= fp+64+length
  {
    H.Arithmetic(fp,length);
    R.StoredWord(mem,64,H.Free(fp,length));
    R.StoredWord(H.Pointer(mem,fp,length),fp,length);
    C.Size(H.Head(mem,fp,length),fp+32,S.Window(data,offset,length));
    C.Rounded(fp+32+length);
    R.StoredWord(H.Copied(mem,fp,offset,length,data),fp+32+length,0);
  }
  lemma CopiedFrame(mem: seq<S.Byte>,fp: S.Word,offset: S.Word,length: S.Word,data: seq<S.Byte>,slot: S.Word)
    requires Admitted(mem,fp,offset,length,data) && (slot as nat)+32 <= |mem|
    ensures S.Load(H.Copied(mem,fp,offset,length,data),slot) == S.Load(H.Head(mem,fp,length),slot)
  {
    Geometry(mem,fp,offset,length,data);
    var head := H.Head(mem,fp,length);
    var copied := H.Copied(mem,fp,offset,length,data);
    C.Frame(head,fp+32,S.Window(data,offset,length));
    forall j: nat {:trigger copied[slot+j]} | j < 32
      ensures copied[slot+j] == head[slot+j]
    {}
    assert copied[slot..slot+32] == head[slot..slot+32];
    assert G.Grow(copied,(slot as nat)+32) == copied;
    assert G.Grow(head,(slot as nat)+32) == head;
  }
  lemma WordFrame(mem: seq<S.Byte>,fp: S.Word,offset: S.Word,length: S.Word,data: seq<S.Byte>,slot: S.Word)
    requires Admitted(mem,fp,offset,length,data) && 96 <= slot && (slot as nat)+32 <= |mem|
    ensures S.Load(H.Complete(mem,fp,offset,length,data),slot) == S.Load(mem,slot)
  {
    Geometry(mem,fp,offset,length,data);
    R.StoredFrame(mem,64,H.Free(fp,length),slot);
    R.StoredFrame(H.Pointer(mem,fp,length),fp,length,slot);
    CopiedFrame(mem,fp,offset,length,data,slot);
    R.StoredFrame(H.Copied(mem,fp,offset,length,data),fp+32+length,0,slot);
  }
  lemma Payload(mem: seq<S.Byte>,fp: S.Word,offset: S.Word,length: S.Word,data: seq<S.Byte>)
    requires Admitted(mem,fp,offset,length,data)
    ensures H.Complete(mem,fp,offset,length,data)[fp+32..fp+32+length] == data[offset..offset+length]
  {
    Geometry(mem,fp,offset,length,data);
    var copied := H.Copied(mem,fp,offset,length,data);
    var complete := H.Complete(mem,fp,offset,length,data);
    var expanded := S.Expand(copied,(fp as nat)+64+length);
    R.Expansion(copied,(fp as nat)+64+length);
    forall j: nat {:trigger complete[fp+32+j]} | j < length
      ensures complete[fp+32+j] == data[offset+j]
    {
      C.CalldataValue(H.Head(mem,fp,length),fp+32,offset,length,data,j);
      assert expanded[fp+32+j] == copied[fp+32+j];
      assert complete[fp+32+j] == copied[fp+32+j];
    }
  }
}
