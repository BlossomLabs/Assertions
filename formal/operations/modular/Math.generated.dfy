// SPDX-License-Identifier: MIT
// Source-correspondence model of Operations' signed addMod/mulMod and helpers.
// This is a mathematical proof, not a proof of Solidity compilation or bytecode.
module OperationsModularMath {
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
  function MagnitudeImpl(v: int): int {
    if v < 0 then Unsigned(Unsigned(Signed(-Signed(v + 1))) + 1)
    else Unsigned(v)
  }

  function SignedMagnitudeImpl(v: int, negative: bool): Outcome {
    if v > (if negative then Half else Half - 1) then Panic(17)
    else Ok(if negative then Signed(-Signed(v)) else Signed(v))
  }

  // Solidity checks zero for %, addmod and mulmod (Panic(0x12)). The EVM
  // opcodes alone return zero for modulus zero. All magnitude calculations
  // preceding these checks are total, so the shared zero branch is equivalent.
  function AddImpl(a: int, b: int, m: int): Outcome {
    var x := MagnitudeImpl(a);
    var y := MagnitudeImpl(b);
    var d := MagnitudeImpl(m);
    if d == 0 then Panic(18)
    else if (a < 0) == (b < 0) then SignedMagnitudeImpl((x + y) % d, a < 0)
    else if x >= y then SignedMagnitudeImpl((x - y) % d, a < 0)
    else SignedMagnitudeImpl((y - x) % d, b < 0)
  }

  function MulImpl(a: int, b: int, m: int): Outcome {
    var x := MagnitudeImpl(a);
    var y := MagnitudeImpl(b);
    var d := MagnitudeImpl(m);
    if d == 0 then Panic(18)
    else SignedMagnitudeImpl((x * y) % d, (a < 0) != (b < 0))
  }

  // Independent specification: divide an unbounded mathematical numerator
  // toward zero, then subtract divisor * quotient. The modulus sign is ignored.
  function Remainder(n: int, d: int): int
    requires d > 0
  {
    var q := if n < 0 then -((-n) / d) else n / d;
    n - d * q
  }

  function Specification(n: int, m: int): Outcome {
    if m == 0 then Panic(18) else Ok(Remainder(n, Abs(m)))
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

  lemma RemainderRule(n: int, d: int)
    requires d > 0
    ensures Remainder(n, d) == (if n < 0 then -(Abs(n) % d) else Abs(n) % d)
    ensures -d < Remainder(n, d) < d
    ensures n >= 0 ==> Remainder(n, d) >= 0
    ensures n <= 0 ==> Remainder(n, d) <= 0
  {
    if n == 0 {
      assert 0 / d == 0;
      assert Remainder(n, d) == 0;
    } else if n < 0 {
      assert -n == ((-n) / d) * d + (-n) % d;
      assert 0 <= (-n) % d < d;
    } else {
      assert n == (n / d) * d + n % d;
      assert 0 <= n % d < d;
    }
  }

  lemma RestoreRemainder(n: int, magnitude: int, negative: bool, d: int)
    requires 0 <= magnitude
    requires n == (if negative then -magnitude else magnitude)
    requires 0 < d <= Half
    ensures SignedMagnitudeImpl(magnitude % d, negative) == Ok(Remainder(n, d))
  {
    assert 0 <= magnitude % d < d;
    SignedMagnitudeCorrect(magnitude % d, negative);
    RemainderRule(n, d);
    if magnitude == 0 { assert Remainder(n, d) == 0; }
  }

  // O13: the specification's addition/product are unbounded integers.
  // O14: every int256 input is admitted, including Half with a negative sign.
  lemma AddCorrect(a: int, b: int, m: int)
    requires Int256(a) && Int256(b) && Int256(m)
    ensures AddImpl(a, b, m) == Specification(a + b, m)
  {
    MagnitudeCorrect(a);
    MagnitudeCorrect(b);
    MagnitudeCorrect(m);
    var x := MagnitudeImpl(a);
    var y := MagnitudeImpl(b);
    var d := MagnitudeImpl(m);
    if m != 0 {
      if (a < 0) == (b < 0) {
        RestoreRemainder(a + b, x + y, a < 0, d);
      } else if x >= y {
        RestoreRemainder(a + b, x - y, a < 0, d);
      } else {
        RestoreRemainder(a + b, y - x, b < 0, d);
      }
    }
  }

  lemma {:isolate_assertions} MulCorrect(a: int, b: int, m: int)
    requires Int256(a) && Int256(b) && Int256(m)
    ensures MulImpl(a, b, m) == Specification(a * b, m)
  {
    MagnitudeCorrect(a);
    MagnitudeCorrect(b);
    MagnitudeCorrect(m);
    if m != 0 {
      var x := MagnitudeImpl(a);
      var y := MagnitudeImpl(b);
      assert x >= 0 && y >= 0;
      assert x * y >= 0;
      if a < 0 {
        if b < 0 {
          assert a == -x && b == -y;
          assert a * b == x * y;
        } else {
          assert a == -x && b == y;
          assert a * b == -(x * y);
        }
      } else {
        if b < 0 {
          assert a == x && b == -y;
          assert a * b == -(x * y);
        } else {
          assert a == x && b == y;
          assert a * b == x * y;
        }
      }
      assert a * b == (if (a < 0) != (b < 0) then -(x * y) else x * y);
      RestoreRemainder(a * b, x * y, (a < 0) != (b < 0), MagnitudeImpl(m));
    }
  }

  lemma CompleteOutcomes(a: int, b: int, m: int)
    requires Int256(a) && Int256(b) && Int256(m)
    ensures m == 0 ==> AddImpl(a, b, m) == Panic(18) && MulImpl(a, b, m) == Panic(18)
    ensures m != 0 ==> AddImpl(a, b, m).Ok? && MulImpl(a, b, m).Ok?
    ensures m != 0 ==> Int256(AddImpl(a, b, m).value) && Int256(MulImpl(a, b, m).value)
  {
    AddCorrect(a, b, m);
    MulCorrect(a, b, m);
    if m != 0 {
      MagnitudeCorrect(m);
      RemainderRule(a + b, Abs(m));
      RemainderRule(a * b, Abs(m));
    }
  }

  // Independent ground obligation: no calls to lemmas whose postconditions
  // could hide a mutation when running this negative control in isolation.
  lemma ProductDoesNotWrap()
    ensures MulImpl(-Half, -Half, 7) == Ok(1)
  {
    assert MagnitudeImpl(-Half) == Half;
    assert MagnitudeImpl(7) == 7;
    assert (Half * Half) % 7 == 1;
    assert SignedMagnitudeImpl(1, false) == Ok(1);
  }

}
