// SPDX-License-Identifier: MIT
// Actual allocation and full byte copy for an arbitrary nonempty callback receipt.
include "../../external-calls/Execution.dfy"
include "../../scans/Representation.dfy"
module BytecodeApplyCallbackReceiptMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import M = BytecodeExternalMemory
  import R = BytecodeScanRepresentation
  function Bound(): nat { 0x400000000000000000 }
  predicate Fits(mem: seq<S.Byte>,free: S.Word,returned: seq<S.Byte>) {
    96 <= |mem| < Bound() && |mem|%32 == 0 && 96 <= free && free%32 == 0
    && 0 < |returned| && free+|returned|+256 < Bound() && S.Load(mem,64) == free
  }
  function End(free: S.Word,returned: seq<S.Byte>): S.Word
    requires free+|returned|+256 < Bound()
  { free+32+S.Round32(|returned|) }
  function Pointer(mem: seq<S.Byte>,free: S.Word,returned: seq<S.Byte>): seq<S.Byte>
    requires Fits(mem,free,returned)
  { S.Store(mem,64,End(free,returned)) }
  function Head(mem: seq<S.Byte>,free: S.Word,returned: seq<S.Byte>): seq<S.Byte>
    requires Fits(mem,free,returned)
  { S.Store(Pointer(mem,free,returned),free,|returned|) }
  function Complete(mem: seq<S.Byte>,free: S.Word,returned: seq<S.Byte>): seq<S.Byte>
    requires Fits(mem,free,returned)
  { M.ReturnCopy(Head(mem,free,returned),free+32,0,|returned|,returned) }
  lemma Bounds(mem: seq<S.Byte>,free: S.Word,returned: seq<S.Byte>)
    requires Fits(mem,free,returned)
    ensures free+32+|returned| <= End(free,returned) < Bound()
    ensures End(free,returned)%32 == 0
    ensures 96 <= |Pointer(mem,free,returned)| < Bound() && |Pointer(mem,free,returned)|%32 == 0
    ensures free+32 <= |Head(mem,free,returned)| < Bound() && |Head(mem,free,returned)|%32 == 0
    ensures free+32+|returned| <= |Complete(mem,free,returned)| < Bound() && |Complete(mem,free,returned)|%32 == 0
  {
    C.Rounded(|returned|);
    R.StoredWord(mem,64,End(free,returned));
    R.StoredWord(Pointer(mem,free,returned),free,|returned|);
    C.Rounded(free+32+|returned|);
    assert S.Round32(free+32+|returned|) == End(free,returned);
    C.Size(Head(mem,free,returned),free+32,returned);
  }
  lemma Layout(mem: seq<S.Byte>,free: S.Word,returned: seq<S.Byte>)
    requires Fits(mem,free,returned)
    ensures S.Load(Pointer(mem,free,returned),64) == End(free,returned)
    ensures S.Load(Head(mem,free,returned),free) == |returned|
    ensures S.Load(Head(mem,free,returned),64) == End(free,returned)
    ensures S.Load(Complete(mem,free,returned),free) == |returned|
    ensures S.Load(Complete(mem,free,returned),64) == End(free,returned)
    ensures Complete(mem,free,returned)[free+32..free+32+|returned|] == returned
  {
    Bounds(mem,free,returned);
    R.StoredWord(mem,64,End(free,returned));
    R.StoredWord(Pointer(mem,free,returned),free,|returned|);
    R.StoredFrame(Pointer(mem,free,returned),free,|returned|,64);
    C.Frame(Head(mem,free,returned),free+32,returned);
    forall j: int {:trigger Complete(mem,free,returned)[j]} | free <= j < free+32
      ensures Complete(mem,free,returned)[j] == Head(mem,free,returned)[j]
    {}
    assert Complete(mem,free,returned)[free..free+32] == Head(mem,free,returned)[free..free+32];
    forall j: int {:trigger Complete(mem,free,returned)[j]} | 64 <= j < 96
      ensures Complete(mem,free,returned)[j] == Head(mem,free,returned)[j]
    {}
    assert Complete(mem,free,returned)[64..96] == Head(mem,free,returned)[64..96];
    C.Span(Head(mem,free,returned),free+32,returned);
  }
  lemma ErrorReady(mem: seq<S.Byte>,free: S.Word,returned: seq<S.Byte>)
    requires Fits(mem,free,returned)
    ensures 96 <= |Complete(mem,free,returned)| < G.Modulus()
    ensures |Complete(mem,free,returned)|%32 == 0
    ensures 96 <= End(free,returned) && End(free,returned)+160 < G.Modulus()
    ensures S.Load(Complete(mem,free,returned),64) == End(free,returned)
  { Bounds(mem,free,returned); Layout(mem,free,returned); }
}
