// SPDX-License-Identifier: MIT
// Independent observable byte image and memory frame for the actual bytes encoder.
include "BlobSpec.dfy"
include "../Sequences.dfy"
module AssertionsConstraintFailedBlobMemory {
  import D = AssertionsConstraintFailedBlobSpec
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import R = BytecodeScanRepresentation
  import Q = AssertionsConstraintSequences
  type Word = S.Word
  type Byte = S.Byte
  lemma StorePoint(mem: seq<Byte>, dst: Word, value: Word, i: nat)
    requires i < |mem| && i < dst
    ensures S.Store(mem,dst,value)[i] == mem[i]
  {
    var expanded := S.Expand(mem,(dst as nat)+32);
    assert expanded[..|mem|] == mem;
  }
  lemma StoreOutside(mem: seq<Byte>, dst: Word, value: Word, i: nat)
    requires i < |mem| && (i < dst || dst+32 <= i)
    ensures S.Store(mem,dst,value)[i] == mem[i]
  {
    var expanded := S.Expand(mem,(dst as nat)+32);
    assert expanded[..|mem|] == mem;
    if i < dst {} else {}
  }
  lemma Header(mem: seq<Byte>, dst: Word, src: Word, length: Word)
    requires D.Heap(mem,dst,src,length)
    ensures |D.Header(mem,dst,length)|%32 == 0
    ensures dst+32 <= |D.Header(mem,dst,length)| <= dst+64
    ensures D.Header(mem,dst,length)[dst..dst+32] == G.Encode(length,32)
    ensures forall i: nat {:trigger D.Header(mem,dst,length)[i]} :: i < src+32+length ==> D.Header(mem,dst,length)[i] == mem[i]
  {
    D.Bounds(mem,dst,src,length); R.StoredWord(mem,dst,length);
    C.Rounded((dst as nat)+32);
    forall i: nat {:trigger D.Header(mem,dst,length)[i]} | i < src+32+length
      ensures D.Header(mem,dst,length)[i] == mem[i]
    { StorePoint(mem,dst,length,i); }
  }
  lemma Copied(mem: seq<Byte>, dst: Word, src: Word, length: Word)
    requires D.Heap(mem,dst,src,length)
    ensures |D.Payload(mem,dst,src,length)|%32 == 0
    ensures dst+32+length <= |D.Payload(mem,dst,src,length)| <= D.End(dst,length)+32
    ensures D.Payload(mem,dst,src,length)[dst..dst+32] == G.Encode(length,32)
    ensures D.Payload(mem,dst,src,length)[dst+32..dst+32+length] == mem[src+32..src+32+length]
  {
    Header(mem,dst,src,length); D.Bounds(mem,dst,src,length);
    C.Rounded(length); C.Rounded((dst as nat)+32+length);
    assert S.Round32((dst as nat)+32+length) <= dst+64+S.Round32(length);
    var header := D.Header(mem,dst,length);
    C.MemorySize(header,dst+32,src+32,length);
    forall j: nat {:trigger D.Payload(mem,dst,src,length)[dst+j]} | j < 32
      ensures D.Payload(mem,dst,src,length)[dst+j] == header[dst+j]
    { C.MemoryFrame(header,dst+32,src+32,length,dst+j); }
    Q.Span(D.Payload(mem,dst,src,length),header,dst,dst,32);
    forall j: nat {:trigger D.Payload(mem,dst,src,length)[dst+32+j]} | j < length
      ensures D.Payload(mem,dst,src,length)[dst+32+j] == mem[src+32+j]
    { C.MemoryValue(header,dst+32,src+32,length,j); }
  }
  lemma ZeroByteWidth(width: nat, i: nat)
    requires i < width
    ensures G.Encode(0,width)[i] == 0
    decreases width
  { if i < width-1 { ZeroByteWidth(width-1,i); } }
  lemma ZeroByte(i: nat)
    requires i < 32
    ensures G.Encode(0,32)[i] == 0
  { ZeroByteWidth(32,i); }
  lemma Built(mem: seq<Byte>, dst: Word, src: Word, length: Word)
    requires D.Heap(mem,dst,src,length)
    ensures D.Value(mem,D.Image(mem,dst,src,length),dst,src,length)
    ensures |D.Image(mem,dst,src,length)|%32 == 0
    ensures |D.Image(mem,dst,src,length)| <= D.End(dst,length)+64
    ensures forall j: nat {:trigger D.Image(mem,dst,src,length)[j]} :: j < |mem| && j < dst ==> D.Image(mem,dst,src,length)[j] == mem[j]
  {
    Copied(mem,dst,src,length); C.Rounded(length);
    var payload := D.Payload(mem,dst,src,length);
    var end := dst+32+length;
    R.StoredWord(payload,end,0);
    assert S.Round32((end as nat)+32) <= dst+96+S.Round32(length);
    forall j: nat {:trigger D.Image(mem,dst,src,length)[dst+j]} | j < 32
      ensures D.Image(mem,dst,src,length)[dst+j] == G.Encode(length,32)[j]
    { StorePoint(payload,end,0,dst+j); }
    forall j: nat {:trigger D.Image(mem,dst,src,length)[dst+32+j]} | j < length
      ensures D.Image(mem,dst,src,length)[dst+32+j] == mem[src+32+j]
    {
      assert payload[dst+32..dst+32+length][j] == mem[src+32..src+32+length][j];
      assert payload[dst+32+j] == mem[src+32+j];
      StorePoint(payload,end,0,dst+32+j);
    }
    Q.Span(D.Image(mem,dst,src,length),mem,dst+32,src+32,length);
    Q.Span(D.Image(mem,dst,src,length),payload,dst,dst,32);
    forall p: nat {:trigger D.Image(mem,dst,src,length)[p]} | dst+32+length <= p < dst+32+S.Round32(length)
      ensures D.Image(mem,dst,src,length)[p] == 0
    { assert 0 <= p-end < 32; ZeroByte(p-end); }
    forall j: nat {:trigger D.Image(mem,dst,src,length)[j]} | j < |mem| && j < dst
      ensures D.Image(mem,dst,src,length)[j] == mem[j]
    {
      StorePoint(mem,dst,length,j);
      C.MemoryFrame(D.Header(mem,dst,length),dst+32,src+32,length,j);
      StorePoint(payload,end,0,j);
    }
  }
}
