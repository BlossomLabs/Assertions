// SPDX-License-Identifier: MIT
// Source-correspondence model of Operations' signed addMod/mulMod and helpers.
// This is a mathematical proof, not a proof of Solidity compilation or bytecode.
module OperationsFullMulDivSignedHelpers {
  const Half: int := 57896044618658097711785492504343953926634992332820282019728792003956564819968
  const Word: int := 2 * Half

  predicate Int256(v: int) { -Half <= v < Half }
  predicate Uint256(v: int) { 0 <= v < Word }
  function Abs(v: int): int { if v < 0 then -v else v }
  function Unsigned(v: int): int { v % Word }
  function Signed(v: int): int {
    var w := Unsigned(v);
    if w < Half then w else w - Word
  }
  datatype Outcome = Ok(value: int) | Panic(code: int)

  // Casts and operations inside Solidity's unchecked block wrap at 256 bits.
  function MagnitudeImpl(value: int): int { $MAGNITUDE$ }


  function SignedMagnitudeImpl(value: int, negative: bool): Outcome {
    if $SIGNED_GUARD$ then Panic(17)
    else Ok($SIGNED_VALUE$)
  }


  lemma WordIdentity(v: int)
    requires Int256(v)
    ensures Signed(v) == v
  {}

  lemma MagnitudeCorrect(v: int)
    requires Int256(v)
    ensures MagnitudeImpl(v) == Abs(v)
    ensures 0 <= MagnitudeImpl(v) <= Half
    ensures (MagnitudeImpl(v) == 0) == (v == 0)
  {
    if v < 0 {
      WordIdentity(v + 1);
      WordIdentity(-(v + 1));
    }
  }

  lemma SignedMagnitudeCorrect(v: int, negative: bool)
    requires Uint256(v)
    ensures v > (if negative then Half else Half - 1) ==> SignedMagnitudeImpl(v, negative) == Panic(17)
    ensures v <= (if negative then Half else Half - 1) ==> SignedMagnitudeImpl(v, negative) == Ok(if negative then -v else v)
  {
    if v < Half {
      WordIdentity(v);
      WordIdentity(-v);
    } else if v == Half && negative {
      assert Signed(v) == -Half;
      assert Signed(-Signed(v)) == -Half;
    }
  }

}
