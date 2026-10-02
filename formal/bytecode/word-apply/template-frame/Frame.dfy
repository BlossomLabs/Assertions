// SPDX-License-Identifier: MIT
include "../template-copy/Memory.dfy"
include "../allocation-header/Memory.dfy"
module BytecodeApplyTemplateFrame {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import A = BytecodeApplyAllocationMemory
  import O = BytecodeIotaOutput
  import H = BytecodeApplyTemplateMemory
  lemma StoreByte(mem: seq<S.Byte>,offset: S.Word,word: S.Word,index: nat)
    requires index < |mem| && (index < offset || (offset as nat)+32 <= index)
    ensures S.Store(mem,offset,word)[index] == mem[index]
  {
    var expanded := S.Expand(mem,(offset as nat)+32);
    assert expanded[..|mem|] == mem;
    if index < offset {} else { assert (offset as nat)+32 <= index; }
  }
  lemma Bounds(n: nat,length: S.Word)
    requires n < 0x800000000000000 && length < 0x10000000000000000
    ensures |A.Heap(n)| == O.Extent(n) < 0x20000000000000000
    ensures |A.Heap(n)|%32 == 0
    ensures S.Load(A.Heap(n),64) == O.Extent(n)
  { O.Header(n,0); O.Aligned(n); }
  lemma Preserved(n: nat,offset: S.Word,length: S.Word,data: seq<S.Byte>,index: nat)
    requires n < 0x800000000000000 && length < 0x10000000000000000
    requires index < O.Extent(n) && (index < 64 || 96 <= index)
    ensures H.Complete(A.Heap(n),O.Extent(n),offset,length,data)[index] == A.Heap(n)[index]
  {
    Bounds(n,length);
    var fp: S.Word := O.Extent(n);
    var mem := A.Heap(n);
    H.Arithmetic(fp,length);
    StoreByte(mem,64,H.Free(fp,length),index);
    assert index < |H.Pointer(mem,fp,length)|;
    StoreByte(H.Pointer(mem,fp,length),fp,length,index);
    C.Frame(H.Head(mem,fp,length),fp+32,S.Window(data,offset,length));
    assert index < |H.Head(mem,fp,length)|;
    assert index < |H.Copied(mem,fp,offset,length,data)|;
    StoreByte(H.Copied(mem,fp,offset,length,data),fp+32+length,0,index);
  }
  lemma Copied(n: nat,offset: S.Word,length: S.Word,data: seq<S.Byte>,index: nat)
    requires n < 0x800000000000000 && length < 0x10000000000000000
    requires (offset as nat)+length <= |data| && index < length
    ensures H.Complete(A.Heap(n),O.Extent(n),offset,length,data)[O.Extent(n)+32+index] == data[offset+index]
  {
    Bounds(n,length);
    var fp: S.Word := O.Extent(n);
    C.CalldataValue(H.Head(A.Heap(n),fp,length),fp+32,offset,length,data,index);
    assert fp+32+index < |H.Copied(A.Heap(n),fp,offset,length,data)|;
    StoreByte(H.Copied(A.Heap(n),fp,offset,length,data),fp+32+length,0,fp+32+index);
  }
}
