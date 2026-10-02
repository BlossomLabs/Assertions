include "Math.generated.dfy"
module OperationsModularSource {
  import M = OperationsModularMath
  // Complete helper ASTs are gated. Their unchecked/cast lowering is the
  // reviewed fixed template proved by the included full-domain helper lemmas.
  function Magnitude(value: int): int { M.MagnitudeImpl(value) }
  function SignedMagnitude(value: int,negative: bool): M.Outcome { M.SignedMagnitudeImpl(value,negative) }
  function AddU(a: int,b: int,m: int): M.Outcome
    requires M.Uint256(a) && M.Uint256(b) && M.Uint256(m)
  { if m == 0 then M.Panic(18) else M.Ok($ADD_UNSIGNED$) }
  function MulU(a: int,b: int,m: int): M.Outcome
    requires M.Uint256(a) && M.Uint256(b) && M.Uint256(m)
  { if m == 0 then M.Panic(18) else M.Ok($MUL_UNSIGNED$) }
  function AddS(a: int,b: int,m: int): M.Outcome
    requires M.Int256(a) && M.Int256(b) && M.Int256(m)
  {
    var x := Magnitude(a);
    var y := Magnitude(b);
    var modulus := Magnitude(m);
    if modulus == 0 then M.Panic(18)
    else if $SAME_SIGN$ then $ADD_SAME$
    else $ADD_DIFFERENT$
  }
  function MulS(a: int,b: int,m: int): M.Outcome
    requires M.Int256(a) && M.Int256(b) && M.Int256(m)
  {
    var x := Magnitude(a);
    var y := Magnitude(b);
    var modulus := Magnitude(m);
    if modulus == 0 then M.Panic(18) else $MUL_SIGNED$
  }
}
