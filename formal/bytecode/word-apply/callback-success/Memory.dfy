// SPDX-License-Identifier: MIT
// Exact caller-local 32-byte successful receipt allocation/copy and result load.
include "../../external-calls/Execution.dfy"
include "../../scans/Representation.dfy"
module BytecodeApplyCallbackSuccessMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import M = BytecodeExternalMemory
  import R = BytecodeScanRepresentation
  predicate Fits(mem: seq<S.Byte>,free: S.Word) {
    96 <= |mem| < G.Modulus() && |mem|%32 == 0 && 96 <= free && (free as nat)+96 < G.Modulus() && S.Load(mem,64) == free
  }
  function Pointer(mem: seq<S.Byte>,free: S.Word): seq<S.Byte>
    requires Fits(mem,free)
  { S.Store(mem,64,free+64) }
  function Head(mem: seq<S.Byte>,free: S.Word): seq<S.Byte>
    requires Fits(mem,free)
  { S.Store(Pointer(mem,free),free,32) }
  function Complete(mem: seq<S.Byte>,free: S.Word,returned: seq<S.Byte>): seq<S.Byte>
    requires Fits(mem,free) && |returned| == 32
  { M.ReturnCopy(Head(mem,free),free+32,0,32,returned) }
  function Result(returned: seq<S.Byte>): S.Word
    requires |returned| == 32
  { S.DataWord(returned,0) }
  lemma Bounds(mem: seq<S.Byte>,free: S.Word,returned: seq<S.Byte>)
    requires Fits(mem,free) && |returned| == 32
    ensures 96 <= |Pointer(mem,free)| < G.Modulus() && |Pointer(mem,free)|%32 == 0
    ensures free+32 <= |Head(mem,free)| < G.Modulus() && |Head(mem,free)|%32 == 0
    ensures free+64 <= |Complete(mem,free,returned)| < G.Modulus() && |Complete(mem,free,returned)|%32 == 0
  {
    R.StoredWord(mem,64,free+64);
    R.StoredWord(Pointer(mem,free),free,32);
    C.Rounded(free+32); C.Rounded(free+64);
    C.Size(Head(mem,free),free+32,returned);
  }
  lemma Layout(mem: seq<S.Byte>,free: S.Word,returned: seq<S.Byte>)
    requires Fits(mem,free) && |returned| == 32
    ensures S.Load(Pointer(mem,free),64) == free+64
    ensures S.Load(Head(mem,free),free) == 32 && S.Load(Head(mem,free),64) == free+64
    ensures S.Load(Complete(mem,free,returned),free) == 32 && S.Load(Complete(mem,free,returned),64) == free+64
    ensures S.Load(Complete(mem,free,returned),free+32) == Result(returned)
  {
    Bounds(mem,free,returned);
    R.StoredWord(mem,64,free+64);
    R.StoredWord(Pointer(mem,free),free,32);
    R.StoredFrame(Pointer(mem,free),free,32,64);
    C.Frame(Head(mem,free),free+32,returned);
    forall j: nat {:trigger Complete(mem,free,returned)[free+j]} | j < 32
      ensures Complete(mem,free,returned)[free+j] == Head(mem,free)[free+j]
    {}
    assert Complete(mem,free,returned)[free..free+32] == Head(mem,free)[free..free+32];
    forall j: nat {:trigger Complete(mem,free,returned)[64+j]} | j < 32
      ensures Complete(mem,free,returned)[64+j] == Head(mem,free)[64+j]
    {}
    assert Complete(mem,free,returned)[64..96] == Head(mem,free)[64..96];
    C.Span(Head(mem,free),free+32,returned);
    assert Complete(mem,free,returned)[free+32..free+64] == returned;
    G.WordPower(); G.DecodeBound(returned); R.WordProjection(returned,0);
  }
}
