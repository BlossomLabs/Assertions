// SPDX-License-Identifier: MIT
// Independent leaf semantics from ERC-8211 wire kind numbers.
include "../scans/Representation.dfy"
module AssertionsConstraintSpec {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  type Word = S.Word
  datatype Verdict = Holds | Fails | BadData | BadRange
  function Width(kind: Word): nat { if kind == 7 then 0 else if kind in {3,8} then 64 else 32 }
  function Predicate(kind: Word, actual: Word, lower: Word, upper: Word): bool
    requires kind <= 8 && kind != 6
  {
    if kind == 0 then actual == lower
    else if kind == 1 then lower <= actual
    else if kind == 2 then actual <= lower
    else if kind == 3 then lower <= actual <= upper
    else if kind == 4 then G.Signed(lower) <= G.Signed(actual)
    else if kind == 5 then G.Signed(actual) <= G.Signed(lower)
    else if kind == 7 then true
    else G.Signed(lower) <= G.Signed(actual) <= G.Signed(upper)
  }
  function Judge(kind: Word, length: Word, actual: Word, lower: Word, upper: Word): Verdict
    requires kind <= 8 && kind != 6
  {
    if length != Width(kind) then BadData
    else if (kind == 3 && upper < lower) || (kind == 8 && G.Signed(upper) < G.Signed(lower)) then BadRange
    else if Predicate(kind,actual,lower,upper) then Holds else Fails
  }
  function Error(v: Verdict, entry: Word, param: Word, index: Word, length: Word): seq<S.Byte>
    requires v in {BadData,BadRange}
  {
    if v == BadData then G.Encode(0xe70ce766,4)+G.Encode(entry,32)+G.Encode(param,32)+G.Encode(index,32)+G.Encode(length,32)
    else G.Encode(0x295a41c5,4)+G.Encode(entry,32)+G.Encode(param,32)+G.Encode(index,32)
  }
  // These are representation premises at an internal helper boundary, to be
  // discharged by the caller's decoder and memory-allocation proof.
  predicate Memory(mem: seq<S.Byte>, constraint: Word, reference: Word, free: Word,
                   kind: Word, length: Word, lower: Word, upper: Word) {
    |mem|%32 == 0 && 96 <= |mem| < 0x10000000000000000 &&
    (constraint as nat)+64 <= |mem| && (reference as nat)+32 <= |mem| &&
    128 <= free && (free as nat)+160 < 0x10000000000000000 &&
    S.Load(mem,constraint) == kind && S.Load(mem,constraint+32) == reference &&
    S.Load(mem,reference) == length && S.Load(mem,64) == free &&
    (length in {32,64} ==> (reference as nat)+32+length <= |mem| && S.Load(mem,reference+32) == lower) &&
    (length == 64 ==> S.Load(mem,reference+64) == upper)
  }
}
