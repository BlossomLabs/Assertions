// SPDX-License-Identifier: MIT
include "SignedMod.dfy"

// Word-level model of the assembly oracles in kontrol/SignedModSpec.t.sol.
// The correspondence to Yul is reviewed manually, not a certified translation.
module SignedModReference {
  import opened SM = SignedMod

  // An ABI int256 argument is a word. SLT decodes that word as signed;
  // SUB(0, word) wraps at 256 bits, including when the input is int256.min.
  function Magnitude(v: int): int
    requires Int256(v)
    ensures Magnitude(v) == Abs(v)
    ensures 0 <= Magnitude(v) <= Half
    ensures (Magnitude(v) == 0) == (v == 0)
  {
    var word := Unsigned(v);
    if Signed(word) < 0 then Unsigned(0 - word) else word
  }

  function Restore(r: int, negative: bool): int {
    Signed(if negative then Unsigned(0 - r) else r)
  }

  function AddReference(a: int, b: int, m: int): int
    requires Int256(a) && Int256(b) && Int256(m) && m != 0
  {
    var x := Magnitude(a);
    var y := Magnitude(b);
    var d := Magnitude(m);
    if (a < 0) == (b < 0) then Restore((x + y) % d, a < 0)
    else if x >= y then Restore(Unsigned(x - y) % d, a < 0)
    else Restore(Unsigned(y - x) % d, b < 0)
  }

  function MulReference(a: int, b: int, m: int): int
    requires Int256(a) && Int256(b) && Int256(m) && m != 0
  {
    // MULMOD reduces an unbounded product, rather than a wrapped product.
    Restore((Magnitude(a) * Magnitude(b)) % Magnitude(m), (a < 0) != (b < 0))
  }

  lemma RestoreCorrect(r: int, negative: bool)
    requires 0 <= r < Half
    ensures Restore(r, negative) == (if negative then -r else r)
    ensures SignedMagnitudeImpl(r, negative) == Ok(Restore(r, negative))
  {
    WordIdentity(r);
    WordIdentity(-r);
    SignedMagnitudeCorrect(r, negative);
  }

  lemma {:isolate_assertions} AddReferenceCorrect(a: int, b: int, m: int)
    requires Int256(a) && Int256(b) && Int256(m) && m != 0
    ensures Ok(AddReference(a, b, m)) == Specification(a + b, m)
  {
    MagnitudeCorrect(a);
    MagnitudeCorrect(b);
    MagnitudeCorrect(m);
    var x := Magnitude(a);
    var y := Magnitude(b);
    var d := Magnitude(m);
    if (a < 0) == (b < 0) {
      RestoreCorrect((x + y) % d, a < 0);
    } else if x >= y {
      assert 0 <= x - y <= Half < Word;
      assert Unsigned(x - y) == x - y;
      RestoreCorrect((x - y) % d, a < 0);
    } else {
      assert 0 <= y - x <= Half < Word;
      assert Unsigned(y - x) == y - x;
      RestoreCorrect((y - x) % d, b < 0);
    }
    assert AddImpl(a, b, m) == Ok(AddReference(a, b, m));
    AddCorrect(a, b, m);
  }

  lemma MulReferenceCorrect(a: int, b: int, m: int)
    requires Int256(a) && Int256(b) && Int256(m) && m != 0
    ensures Ok(MulReference(a, b, m)) == Specification(a * b, m)
  {
    MulCorrect(a, b, m);
    MagnitudeCorrect(a);
    MagnitudeCorrect(b);
    MagnitudeCorrect(m);
    var r := (Magnitude(a) * Magnitude(b)) % Magnitude(m);
    RestoreCorrect(r, (a < 0) != (b < 0));
  }
}
