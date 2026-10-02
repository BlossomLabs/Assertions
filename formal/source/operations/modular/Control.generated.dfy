include "Math.generated.dfy"
module OperationsModularSource {
  import M = OperationsModularMath
  // Complete helper ASTs are gated. Their unchecked/cast lowering is the
  // reviewed fixed template proved by the included full-domain helper lemmas.
  function Magnitude(value: int): int { M.MagnitudeImpl(value) }
  function SignedMagnitude(value: int,negative: bool): M.Outcome { M.SignedMagnitudeImpl(value,negative) }
  function AddU(a: int,b: int,m: int): M.Outcome
    requires M.Uint256(a) && M.Uint256(b) && M.Uint256(m)
  { if m == 0 then M.Panic(18) else M.Ok(((a + b) % m)) }
  function MulU(a: int,b: int,m: int): M.Outcome
    requires M.Uint256(a) && M.Uint256(b) && M.Uint256(m)
  { if m == 0 then M.Panic(18) else M.Ok(((a * b) % m)) }
  function AddS(a: int,b: int,m: int): M.Outcome
    requires M.Int256(a) && M.Int256(b) && M.Int256(m)
  {
    var x := Magnitude(a);
    var y := Magnitude(b);
    var modulus := Magnitude(m);
    if modulus == 0 then M.Panic(18)
    else if ((a < 0) == (b < 0)) then SignedMagnitude(((x + y) % modulus), (a < 0))
    else (if (x >= y) then SignedMagnitude(((x - y) % modulus), (a < 0)) else SignedMagnitude(((y - x) % modulus), (b < 0)))
  }
  function MulS(a: int,b: int,m: int): M.Outcome
    requires M.Int256(a) && M.Int256(b) && M.Int256(m)
  {
    var x := Magnitude(a);
    var y := Magnitude(b);
    var modulus := Magnitude(m);
    if modulus == 0 then M.Panic(18) else SignedMagnitude(((x * y) % modulus), ((a < 0) != (b < 0)))
  }
}
