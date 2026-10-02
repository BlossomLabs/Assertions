include "Control.generated.dfy"
module OperationsModularConnection {
  import M = OperationsModularMath
  import S = OperationsModularSource
  lemma AddU(a: int,b: int,m: int)
    requires M.Uint256(a) && M.Uint256(b) && M.Uint256(m)
    ensures S.AddU(a,b,m) == (if m == 0 then M.Panic(18) else M.Ok((a+b) % m))
  { }
  lemma MulU(a: int,b: int,m: int)
    requires M.Uint256(a) && M.Uint256(b) && M.Uint256(m)
    ensures S.MulU(a,b,m) == (if m == 0 then M.Panic(18) else M.Ok((a*b) % m))
  { }
  lemma AddS(a: int,b: int,m: int)
    requires M.Int256(a) && M.Int256(b) && M.Int256(m)
    ensures S.AddS(a,b,m) == M.Specification(a+b,m)
  { M.AddCorrect(a,b,m); }
  lemma MulS(a: int,b: int,m: int)
    requires M.Int256(a) && M.Int256(b) && M.Int256(m)
    ensures S.MulS(a,b,m) == M.Specification(a*b,m)
  { M.MulCorrect(a,b,m); }
  lemma FullWidthProductWitness()
    ensures S.MulS(-M.Half,-M.Half,7) == M.Ok(1)
  { }
  lemma UnsignedAddWitness()
    ensures S.AddU(3,5,11) == M.Ok(8)
  { }

}
