// SPDX-License-Identifier: MIT
include "Model.dfy"
include "../../abi/source/ByteSemantics.dfy"

module NavigationRuntime {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened NavigationModel

  datatype Error = InvalidNavigation(at: nat)
                 | ReturnDataOutOfBounds(wordIndex: int, length: nat)
                 | InvalidTypeDescriptor(at: nat)
                 | InvalidValue(at: nat)
                 | ElementIndexOutOfBounds(index: int, count: nat)
                 | Panic(code: nat)
  datatype NumberResult = Number(value: nat) | Failed(error: Error)

  function Half(): nat { Limit()/2 }
  predicate Sint(i: int) { -(Half() as int) <= i < Half() }

  function Signed(n: nat): int
    requires Uint(n)
  { if n < Half() then n else n-Limit() }

  function WordAt(data: seq<Byte>, pos: nat): NumberResult {
    if pos+32 > |data| then Failed(ReturnDataOutOfBounds(pos/32,|data|))
    else Number(ReadNat(data[pos..pos+32]))
  }

  // Full helper behavior includes Solidity's checked negation of int256(count).
  // Actual callers will establish count < Half() from descriptor/data bounds.
  function Normalize(index: int, count: nat): NumberResult
    requires Sint(index) && Uint(count)
  {
    if index >= 0 then
      (if index < count then Number(index) else Failed(ElementIndexOutOfBounds(index,count)))
    else if count == Half() then Failed(Error.Panic(17))
    else if count > Half() || index < -(count as int) then Failed(ElementIndexOutOfBounds(index,count))
    else Number(count+index)
  }

  lemma NormalizedIndex(index: int, count: nat)
    requires Sint(index) && count < Half()
    ensures Normalize(index,count).Number? == (-(count as int) <= index < count)
    ensures Normalize(index,count).Number? ==> Normalize(index,count).value == Position(index,count)
    ensures Normalize(index,count).Failed? ==>
              Normalize(index,count) == Failed(ElementIndexOutOfBounds(index,count))
  {}

  lemma LengthBoundsCount(length: nat, count: nat)
    requires Uint(length) && count <= length/32
    ensures count < Half() && Uint(count)
  {
    assert Limit() > 0 && Limit()%32 == 0;
  }

  lemma FixedBoundsCount(count: nat)
    requires count < 0x100000000
    ensures count < Half() && Uint(count)
  {}

  lemma WordBounds(data: seq<Byte>, pos: nat)
    ensures WordAt(data,pos).Number? == (pos+32 <= |data|)
    ensures WordAt(data,pos).Number? ==> Uint(WordAt(data,pos).value)
  {
    if pos+32 <= |data| { BytesNatRoundTrip(data[pos..pos+32]); }
  }
}
