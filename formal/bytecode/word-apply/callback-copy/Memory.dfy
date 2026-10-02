// SPDX-License-Identifier: MIT
// Physical callback payload copy and padding, with explicit memory bounds.
include "../../copy/Memory.dfy"
include "../../scans/Representation.dfy"
module BytecodeApplyCallbackCopyMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import R = BytecodeScanRepresentation
  predicate Fits(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word) {
    |mem|%32 == 0 && |mem| < G.Modulus() && 96 <= ptr &&
    (ptr as nat)+32+length <= |mem| && (ptr as nat)+32+length <= free &&
    (free as nat)+length+64 < G.Modulus()
  }
  function Copied(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word): seq<S.Byte>
    requires Fits(mem,ptr,free,length)
  { C.Memory(mem,free,ptr+32,length) }
  function Packed(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word): seq<S.Byte>
    requires Fits(mem,ptr,free,length)
  { S.Store(Copied(mem,ptr,free,length),free+length,0) }
  lemma Bounds(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word)
    requires Fits(mem,ptr,free,length)
    ensures |Copied(mem,ptr,free,length)|%32 == 0 && |Copied(mem,ptr,free,length)| < G.Modulus()
    ensures |Packed(mem,ptr,free,length)|%32 == 0 && |Packed(mem,ptr,free,length)| < G.Modulus()
    ensures |Packed(mem,ptr,free,length)| >= free+length+32
  {
    C.MemorySize(mem,free,ptr+32,length);
    C.Rounded(free+length);
    R.StoredWord(Copied(mem,ptr,free,length),free+length,0);
    C.Rounded(free+length+32);
  }
  lemma StoredByteFrame(mem: seq<S.Byte>,offset: S.Word,word: S.Word,index: nat)
    requires |mem|%32 == 0 && index < |mem|
    requires index < offset || (offset as nat)+32 <= index
    ensures |S.Store(mem,offset,word)| >= |mem|
    ensures S.Store(mem,offset,word)[index] == mem[index]
  {
    R.StoredWord(mem,offset,word);
    var expanded := S.Expand(mem,(offset as nat)+32);
    assert expanded[..|mem|] == mem;
    assert G.Grow(expanded,(offset as nat)+32) == expanded;
    if index < offset {} else { assert (offset as nat)+32 <= index; }
  }
  lemma Byte(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,index: nat)
    requires Fits(mem,ptr,free,length) && index < length
    ensures Packed(mem,ptr,free,length)[free+index] == mem[ptr+32+index]
  {
    Bounds(mem,ptr,free,length);
    C.MemoryValue(mem,free,ptr+32,length,index);
    StoredByteFrame(Copied(mem,ptr,free,length),free+length,0,free+index);
  }
  lemma Input(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word)
    requires Fits(mem,ptr,free,length)
    ensures Packed(mem,ptr,free,length)[free..free+length] == mem[ptr+32..ptr+32+length]
  {
    Bounds(mem,ptr,free,length);
    forall j: nat {:trigger Packed(mem,ptr,free,length)[free+j]} | j < length
      ensures Packed(mem,ptr,free,length)[free+j] == mem[ptr+32+j]
    { Byte(mem,ptr,free,length,j); }
  }
  lemma Original(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,index: nat)
    requires Fits(mem,ptr,free,length) && index < |mem| && index < free
    ensures Packed(mem,ptr,free,length)[index] == mem[index]
  {
    Bounds(mem,ptr,free,length);
    C.MemoryFrame(mem,free,ptr+32,length,index);
    StoredByteFrame(Copied(mem,ptr,free,length),free+length,0,index);
  }
  lemma FreePointer(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word)
    requires Fits(mem,ptr,free,length)
    ensures S.Load(Packed(mem,ptr,free,length),64) == S.Load(mem,64)
  {
    Bounds(mem,ptr,free,length);
    forall j: nat {:trigger Packed(mem,ptr,free,length)[64+j]} | j < 32
      ensures Packed(mem,ptr,free,length)[64+j] == mem[64+j]
    { Original(mem,ptr,free,length,64+j); }
    assert Packed(mem,ptr,free,length)[64..96] == mem[64..96];
  }
}
