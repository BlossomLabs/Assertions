// SPDX-License-Identifier: MIT
// Exhaustive fitting raw two-bytes decoder partition.
include "RawHeadShort.generated.dfy"
include "RawFirstOffsetLarge.generated.dfy"
include "RawFirstHeaderShort.generated.dfy"
include "RawFirstLengthLarge.generated.dfy"
include "RawFirstTailShort.generated.dfy"
include "RawSecondOffsetLarge.generated.dfy"
include "RawSecondHeaderShort.generated.dfy"
include "RawSecondLengthLarge.generated.dfy"
include "RawSecondTailShort.generated.dfy"
include "../decoder/Decoder.generated.dfy"
module BytecodeZipRawAdmission {
  import opened BytecodeScanMachine
  import A = BytecodeWordZipDecoder
  import R0 = BytecodeZipRawHeadShort
  import R1 = BytecodeZipRawFirstOffsetLarge
  import R2 = BytecodeZipRawFirstHeaderShort
  import R3 = BytecodeZipRawFirstLengthLarge
  import R4 = BytecodeZipRawFirstTailShort
  import R5 = BytecodeZipRawSecondOffsetLarge
  import R6 = BytecodeZipRawSecondHeaderShort
  import R7 = BytecodeZipRawSecondLengthLarge
  import R8 = BytecodeZipRawSecondTailShort
  datatype Class = HeadShort | FirstOffsetLarge | FirstHeaderShort | FirstLengthLarge | FirstTailShort | SecondOffsetLarge | SecondHeaderShort | SecondLengthLarge | SecondTailShort | Accepted
  function Classify(data: seq<Byte>): Class {
    if |data| < 68 then HeadShort
    else if A.HeadA(data) >= 0x10000000000000000 then FirstOffsetLarge
    else if (A.HeadA(data) as nat)+36 > |data| then FirstHeaderShort
    else if A.LengthA(data) >= 0x10000000000000000 then FirstLengthLarge
    else if (A.HeadA(data) as nat)+36+(A.LengthA(data) as nat) > |data| then FirstTailShort
    else if A.HeadB(data) >= 0x10000000000000000 then SecondOffsetLarge
    else if (A.HeadB(data) as nat)+36 > |data| then SecondHeaderShort
    else if A.LengthB(data) >= 0x10000000000000000 then SecondLengthLarge
    else if (A.HeadB(data) as nat)+36+(A.LengthB(data) as nat) > |data| then SecondTailShort
    else Accepted
  }
  lemma Exhaustive(data: seq<Byte>)
    requires 4 <= |data| < 0x10000000000000000
    ensures match Classify(data)
            case HeadShort => R0.Admitted(data)
            case FirstOffsetLarge => R1.Admitted(data)
            case FirstHeaderShort => R2.Admitted(data)
            case FirstLengthLarge => R3.Admitted(data)
            case FirstTailShort => R4.Admitted(data)
            case SecondOffsetLarge => R5.Admitted(data)
            case SecondHeaderShort => R6.Admitted(data)
            case SecondLengthLarge => R7.Admitted(data)
            case SecondTailShort => R8.Admitted(data)
            case Accepted => A.Admitted(data)
    ensures (Classify(data) == Accepted) == A.Admitted(data)
  {}
}
