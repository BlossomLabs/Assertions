// SPDX-License-Identifier: MIT
// Complete fitting-size partition; actual path proofs are separate dependencies.
include "RawHeadShort.generated.dfy"
include "RawOffsetLarge.generated.dfy"
include "RawHeaderShort.generated.dfy"
include "RawLengthLarge.generated.dfy"
include "RawTailShort.generated.dfy"
include "../IndexDecoder.generated.dfy"
module BytecodeIndexRawAdmission {
  import opened BytecodeScanMachine
  import A = BytecodeScanIndexDecoder
  import H = BytecodeIndexRawHeadShort
  import O = BytecodeIndexRawOffsetLarge
  import S = BytecodeIndexRawHeaderShort
  import N = BytecodeIndexRawLengthLarge
  import T = BytecodeIndexRawTailShort
  datatype Class = HeadShort | OffsetLarge | HeaderShort | LengthLarge | TailShort | Accepted
  function Classify(data: seq<Byte>): Class {
    if |data| < 68 then HeadShort
    else if A.Head(data) >= 0x10000000000000000 then OffsetLarge
    else if (A.Head(data) as nat)+36 > |data| then HeaderShort
    else if A.Length(data) >= 0x10000000000000000 then LengthLarge
    else if (A.Head(data) as nat)+36+(A.Length(data) as nat) > |data| then TailShort
    else Accepted
  }
  lemma Exhaustive(data: seq<Byte>)
    requires 4 <= |data| < 0x10000000000000000
    ensures match Classify(data)
            case HeadShort => H.Admitted(data)
            case OffsetLarge => O.Admitted(data)
            case HeaderShort => S.Admitted(data)
            case LengthLarge => N.Admitted(data)
            case TailShort => T.Admitted(data)
            case Accepted => A.Admitted(data)
    ensures (Classify(data) == Accepted) == A.Admitted(data)
  {}
}
