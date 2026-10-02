// SPDX-License-Identifier: MIT
// Physical callback completion protects the complete FoldRun and original call template.
include "../../word-apply/callback-success-engine/Memory.dfy"
module BytecodeFoldCallbackMemoryV2 {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import P = BytecodeApplyCallbackCopyMemory
  import H = BytecodeApplyCallbackSuccessMemory
  import M = BytecodeApplySuccessfulCallMemory
  import X = BytecodeExternalMemory
  predicate Fits(mem: seq<Byte>,ptr: Word,free: Word,length: Word,returned: seq<Byte>) {
    P.Fits(mem,ptr,free,length) && Load(mem,64) == free && (free as nat)+96 < G.Modulus() && |returned| == 32
  }
  function Complete(mem: seq<Byte>,ptr: Word,free: Word,length: Word,returned: seq<Byte>): seq<Byte>
    requires Fits(mem,ptr,free,length,returned)
  { M.Fits(mem,ptr,free,length); H.Complete(P.Packed(mem,ptr,free,length),free,returned) }
  lemma Bounds(mem: seq<Byte>,ptr: Word,free: Word,length: Word,returned: seq<Byte>)
    requires Fits(mem,ptr,free,length,returned)
    ensures |Complete(mem,ptr,free,length,returned)| >= |mem|
    ensures |Complete(mem,ptr,free,length,returned)|%32 == 0 && |Complete(mem,ptr,free,length,returned)| < G.Modulus()
    ensures Load(Complete(mem,ptr,free,length,returned),64) == free+64
  {
    P.Bounds(mem,ptr,free,length); M.Fits(mem,ptr,free,length);
    H.Bounds(P.Packed(mem,ptr,free,length),free,returned);
    H.Layout(P.Packed(mem,ptr,free,length),free,returned);
    assert |P.Packed(mem,ptr,free,length)| >= |mem|;
    assert |H.Pointer(P.Packed(mem,ptr,free,length),free)| >= |P.Packed(mem,ptr,free,length)|;
    assert |H.Head(P.Packed(mem,ptr,free,length),free)| >= |H.Pointer(P.Packed(mem,ptr,free,length),free)|;
    assert |Complete(mem,ptr,free,length,returned)| >= |H.Head(P.Packed(mem,ptr,free,length),free)|;
  }
  lemma ByteFrame(mem: seq<Byte>,ptr: Word,free: Word,length: Word,returned: seq<Byte>,index: nat)
    requires Fits(mem,ptr,free,length,returned) && 96 <= index < |mem| && index < free
    ensures Complete(mem,ptr,free,length,returned)[index] == mem[index]
  {
    Bounds(mem,ptr,free,length,returned);
    var packed := P.Packed(mem,ptr,free,length);
    M.Fits(mem,ptr,free,length); H.Bounds(packed,free,returned);
    P.Original(mem,ptr,free,length,index);
    P.StoredByteFrame(packed,64,free+64,index);
    P.StoredByteFrame(H.Pointer(packed,free),free,32,index);
    X.CopyFrame(H.Head(packed,free),free+32,0,32,returned,index);
  }
  lemma WordFrame(mem: seq<Byte>,ptr: Word,free: Word,length: Word,returned: seq<Byte>,slot: Word)
    requires Fits(mem,ptr,free,length,returned) && 96 <= slot && (slot as nat)+32 <= |mem| && (slot as nat)+32 <= free
    ensures Load(Complete(mem,ptr,free,length,returned),slot) == Load(mem,slot)
  {
    Bounds(mem,ptr,free,length,returned);
    var after := Complete(mem,ptr,free,length,returned);
    var left := after[slot..slot+32]; var right := mem[slot..slot+32];
    assert |left| == 32 && |right| == 32;
    forall j: nat {:trigger left[j]} | j < 32
      ensures left[j] == right[j]
    { ByteFrame(mem,ptr,free,length,returned,slot+j); assert left[j] == after[slot+j]; assert right[j] == mem[slot+j]; }
    assert left == right;
    assert after[slot..slot+32] == mem[slot..slot+32];
    G.LoadProjection(after,slot); G.LoadProjection(mem,slot);
  }
  lemma FoldRun(mem: seq<Byte>,ptr: Word,free: Word,length: Word,returned: seq<Byte>)
    requires Fits(mem,ptr,free,length,returned) && 320 <= ptr && 320 <= |mem|
    ensures forall j: nat {:trigger Load(Complete(mem,ptr,free,length,returned),128+32*j)} :: j < 6 ==> Load(Complete(mem,ptr,free,length,returned),128+32*j) == Load(mem,128+32*j)
  {
    forall j: nat | j < 6
      ensures Load(Complete(mem,ptr,free,length,returned),128+32*j) == Load(mem,128+32*j)
    { WordFrame(mem,ptr,free,length,returned,128+32*j); }
  }
}
