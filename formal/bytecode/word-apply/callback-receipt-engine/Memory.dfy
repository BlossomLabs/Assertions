// SPDX-License-Identifier: MIT
// Derive receipt admission after the actual packed callback payload.
include "../callback-copy/Memory.dfy"
include "../callback-receipt/Memory.dfy"
include "../callback-empty-receipt/Memory.dfy"
include "../raw-callback-memory/Memory.dfy"
module BytecodeApplyFullCallbackReceiptMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import R = BytecodeScanRepresentation
  import P = BytecodeApplyCallbackCopyMemory
  import H = BytecodeApplyCallbackReceiptMemory
  import Z = BytecodeApplyEmptyReceiptMemory
  import F = BytecodeApplyRawCallbackMemory
  predicate Fits(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,returned: seq<S.Byte>) {
    P.Fits(mem,ptr,free,length) && S.Load(mem,64) == free && S.Load(mem,ptr) == length
    && 128 <= |mem| < H.Bound() && 160 <= free && free%32 == 0
    && free+length+256 < H.Bound() && free+|returned|+256 < H.Bound()
    && S.Load(mem,96) == 0
  }
  lemma PackedBounds(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,returned: seq<S.Byte>)
    requires Fits(mem,ptr,free,length,returned)
    ensures 128 <= |P.Packed(mem,ptr,free,length)| < H.Bound()
    ensures |P.Packed(mem,ptr,free,length)|%32 == 0
    ensures S.Load(P.Packed(mem,ptr,free,length),64) == free
    ensures S.Load(P.Packed(mem,ptr,free,length),96) == 0
  {
    hide S.DataWord(); hide S.ShiftRight(); hide G.BitAnd();
    P.Bounds(mem,ptr,free,length); P.FreePointer(mem,ptr,free,length);
    C.MemorySize(mem,free,ptr+32,length);
    C.Rounded(free+length); C.Rounded(free+length+32);
    R.StoredWord(P.Copied(mem,ptr,free,length),free+length,0);
    var packed := P.Packed(mem,ptr,free,length);
    forall j: int {:trigger packed[j]} | 96 <= j < 128
      ensures packed[j] == mem[j]
    { P.Original(mem,ptr,free,length,j); }
    F.EqualLoad(packed,mem,96);
  }
  lemma Admission(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,returned: seq<S.Byte>)
    requires Fits(mem,ptr,free,length,returned)
    ensures if |returned| > 0 then H.Fits(P.Packed(mem,ptr,free,length),free,returned)
            else Z.Fits(P.Packed(mem,ptr,free,length),free)
  {
    PackedBounds(mem,ptr,free,length,returned);
  }
  function Final(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,returned: seq<S.Byte>): seq<S.Byte>
    requires Fits(mem,ptr,free,length,returned)
  {
    Admission(mem,ptr,free,length,returned);
    if |returned| == 0 then P.Packed(mem,ptr,free,length)
    else H.Complete(P.Packed(mem,ptr,free,length),free,returned)
  }
  function Receipt(free: S.Word,returned: seq<S.Byte>): S.Word { if |returned| == 0 then 96 else free }
  lemma Header(mem: seq<S.Byte>,ptr: S.Word,free: S.Word,length: S.Word,returned: seq<S.Byte>)
    requires Fits(mem,ptr,free,length,returned)
    ensures Receipt(free,returned)+32 <= |Final(mem,ptr,free,length,returned)|
    ensures S.Load(Final(mem,ptr,free,length,returned),Receipt(free,returned)) == |returned|
    ensures 96 <= |Final(mem,ptr,free,length,returned)| < G.Modulus()
    ensures |Final(mem,ptr,free,length,returned)|%32 == 0
    ensures 160 <= S.Load(Final(mem,ptr,free,length,returned),64)
    ensures S.Load(Final(mem,ptr,free,length,returned),64)+160 < G.Modulus()
  {
    hide S.DataWord(); hide S.ShiftRight(); hide G.BitAnd();
    Admission(mem,ptr,free,length,returned); PackedBounds(mem,ptr,free,length,returned);
    if |returned| == 0 { Z.Header(P.Packed(mem,ptr,free,length),free); }
    else { H.Bounds(P.Packed(mem,ptr,free,length),free,returned); H.Layout(P.Packed(mem,ptr,free,length),free,returned); }
  }
}
