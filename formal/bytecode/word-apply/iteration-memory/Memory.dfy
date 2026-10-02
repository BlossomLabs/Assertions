// SPDX-License-Identifier: MIT
include "../raw-callback-memory/Memory.dfy"
include "../callback-success-engine/Memory.dfy"
module BytecodeApplyRepeatedIterationMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import C = BytecodeCopyMemory
  import M = BytecodeApplyStampMemory
  import P = BytecodeApplyCallbackCopyMemory
  import H = BytecodeApplyCallbackSuccessMemory
  import A = BytecodeApplyRawCallbackMemory
  import B = BytecodeApplySuccessfulCallMemory
  function Bound(): nat { 0x80000000000000000 }
  predicate Fits(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>) {
    M.Fits(mem,ptr,length,arrayOffset,count,data) && P.Fits(mem,ptr,free,length) &&
    S.Load(mem,64) == free && S.Load(mem,ptr) == length && (free as nat)+length+160 < Bound()
  }
  function Stamped(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>,word: S.Word): seq<S.Byte>
    requires Fits(mem,ptr,free,length,arrayOffset,count,data)
    ensures P.Fits(Stamped(mem,ptr,free,length,arrayOffset,count,data,word),ptr,free,length)
    ensures S.Load(Stamped(mem,ptr,free,length,arrayOffset,count,data,word),64) == free
    ensures S.Load(Stamped(mem,ptr,free,length,arrayOffset,count,data,word),ptr) == length
    ensures |Stamped(mem,ptr,free,length,arrayOffset,count,data,word)| == |mem|
  {
    StampFacts(mem,ptr,free,length,arrayOffset,count,data,word);
    M.Stamped(mem,ptr,length,arrayOffset,count,data,word,count)
  }
  lemma StampFacts(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>,word: S.Word)
    requires Fits(mem,ptr,free,length,arrayOffset,count,data)
    ensures P.Fits(M.Stamped(mem,ptr,length,arrayOffset,count,data,word,count),ptr,free,length)
    ensures S.Load(M.Stamped(mem,ptr,length,arrayOffset,count,data,word,count),64) == free
    ensures S.Load(M.Stamped(mem,ptr,length,arrayOffset,count,data,word,count),ptr) == length
    ensures |M.Stamped(mem,ptr,length,arrayOffset,count,data,word,count)| == |mem|
  {
    M.Extent(mem,ptr,length,arrayOffset,count,data,word,count);
    A.StampLoad(mem,ptr,length,arrayOffset,count,data,word,count,64);
    A.StampLoad(mem,ptr,length,arrayOffset,count,data,word,count,ptr);
  }
  function Packed(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>,word: S.Word): seq<S.Byte>
    requires Fits(mem,ptr,free,length,arrayOffset,count,data)
    ensures H.Fits(Packed(mem,ptr,free,length,arrayOffset,count,data,word),free)
  {
    B.Fits(Stamped(mem,ptr,free,length,arrayOffset,count,data,word),ptr,free,length);
    P.Packed(Stamped(mem,ptr,free,length,arrayOffset,count,data,word),ptr,free,length)
  }
  function After(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>,word: S.Word,returned: seq<S.Byte>): seq<S.Byte>
    requires Fits(mem,ptr,free,length,arrayOffset,count,data) && |returned| == 32
  { H.Complete(Packed(mem,ptr,free,length,arrayOffset,count,data,word),free,returned) }
  lemma Bounds(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>,word: S.Word,returned: seq<S.Byte>)
    requires Fits(mem,ptr,free,length,arrayOffset,count,data) && |returned| == 32
    ensures |After(mem,ptr,free,length,arrayOffset,count,data,word,returned)|%32 == 0
    ensures |mem| <= |After(mem,ptr,free,length,arrayOffset,count,data,word,returned)| < Bound()
    ensures M.Fits(After(mem,ptr,free,length,arrayOffset,count,data,word,returned),ptr,length,arrayOffset,count,data)
    ensures P.Fits(After(mem,ptr,free,length,arrayOffset,count,data,word,returned),ptr,free+64,length)
  {
    var stamped := Stamped(mem,ptr,free,length,arrayOffset,count,data,word);
    P.Bounds(stamped,ptr,free,length);
    C.MemorySize(stamped,free,ptr+32,length);
    C.Rounded(free+length);
    C.Rounded(free+length+32);
    C.Rounded(free+32);
    C.Rounded(free+64);
    R.StoredWord(P.Copied(stamped,ptr,free,length),free+length,0);
    var packed := Packed(mem,ptr,free,length,arrayOffset,count,data,word);
    R.StoredWord(packed,64,free+64);
    R.StoredWord(H.Pointer(packed,free),free,32);
    C.Size(H.Head(packed,free),free+32,returned);
    H.Bounds(packed,free,returned);
  }
  lemma ProtectedByte(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>,word: S.Word,returned: seq<S.Byte>,index: nat)
    requires Fits(mem,ptr,free,length,arrayOffset,count,data) && |returned| == 32
    requires 96 <= index < ptr+32
    ensures After(mem,ptr,free,length,arrayOffset,count,data,word,returned)[index] == mem[index]
  {
    Bounds(mem,ptr,free,length,arrayOffset,count,data,word,returned);
    var stamped := Stamped(mem,ptr,free,length,arrayOffset,count,data,word);
    M.Outside(mem,ptr,length,arrayOffset,count,data,word,count,index);
    P.Original(stamped,ptr,free,length,index);
    var packed := Packed(mem,ptr,free,length,arrayOffset,count,data,word);
    P.StoredByteFrame(packed,64,free+64,index);
    P.StoredByteFrame(H.Pointer(packed,free),free,32,index);
    C.Frame(H.Head(packed,free),free+32,returned);
  }
  lemma Layout(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>,word: S.Word,returned: seq<S.Byte>)
    requires Fits(mem,ptr,free,length,arrayOffset,count,data) && |returned| == 32
    ensures S.Load(After(mem,ptr,free,length,arrayOffset,count,data,word,returned),64) == free+64
    ensures S.Load(After(mem,ptr,free,length,arrayOffset,count,data,word,returned),ptr) == length
    ensures forall index: int {:trigger After(mem,ptr,free,length,arrayOffset,count,data,word,returned)[index]} :: 96 <= index < ptr+32 ==> After(mem,ptr,free,length,arrayOffset,count,data,word,returned)[index] == mem[index]
  {
    Bounds(mem,ptr,free,length,arrayOffset,count,data,word,returned);
    H.Layout(Packed(mem,ptr,free,length,arrayOffset,count,data,word),free,returned);
    var after := After(mem,ptr,free,length,arrayOffset,count,data,word,returned);
    forall index: int {:trigger after[index]} | 96 <= index < ptr+32
      ensures after[index] == mem[index]
    { ProtectedByte(mem,ptr,free,length,arrayOffset,count,data,word,returned,index); }
    A.EqualLoad(after,mem,ptr);
  }
  lemma OutputWrite(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,arrayOffset: S.Word,count: S.Word,data: seq<S.Byte>,offset: S.Word,word: S.Word)
    requires M.Fits(mem,ptr,length,arrayOffset,count,data) && P.Fits(mem,ptr,free,length)
    requires S.Load(mem,64) == free && S.Load(mem,ptr) == length
    requires 160 <= offset && (offset as nat)+32 <= ptr
    ensures M.Fits(S.Store(mem,offset,word),ptr,length,arrayOffset,count,data)
    ensures P.Fits(S.Store(mem,offset,word),ptr,free,length)
    ensures S.Load(S.Store(mem,offset,word),64) == free && S.Load(S.Store(mem,offset,word),ptr) == length
    ensures |S.Store(mem,offset,word)| == |mem|
    ensures S.Load(S.Store(mem,offset,word),offset) == word
  {
    R.StoredWord(mem,offset,word);
    C.Rounded(offset+32);
    assert S.Round32(offset+32) <= |mem|;
    R.StoredFrame(mem,offset,word,64);
    R.StoredFrame(mem,offset,word,ptr);
  }
}
