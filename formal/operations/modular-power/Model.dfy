include "InverseConnection.dfy"
module OperationsModularPowerModel {
  import B = OperationsBinaryLogModel
  import M = OperationsFullMulDivModel
  import E = OperationsModularPowerEuclid
  import I = OperationsModularPowerInverseModel
  import P = OperationsModularPowerPower
  datatype Outcome = Value(result: int) | Panic(code: nat) | MissingInverse(base: nat,modulus: nat)
  function UnsignedUnsigned(a: nat,e: nat,m: nat): Outcome
    requires a < B.Word && e < B.Word && m < B.Word
  { if m == 0 then Panic(18) else Value(P.Power(a,e)%m) }
  function SignedUnsigned(a: int,e: nat,m: int): Outcome
    requires M.Signed(a) && e < B.Word && M.Signed(m)
  {
    if m == 0 then Panic(18)
    else var magnitude := P.Power(M.Abs(a),e)%M.Abs(m);
         Value(if a < 0 && e%2 == 1 then -(magnitude as int) else magnitude as int)
  }
  function UnsignedSigned(a: nat,e: int,m: nat): Outcome
    requires a < B.Word && M.Signed(e) && m < B.Word
  {
    if m == 0 then Panic(18)
    else if e < 0 && m > 1 && E.Gcd(m,a%m) != 1 then MissingInverse(a,m)
    else var base := if e < 0 then I.Spec(a,m) else a;
         Value(P.Power(base,M.Abs(e))%m)
  }
  function SignedSigned(a: int,e: int,m: int): Outcome
    requires M.Signed(a) && M.Signed(e) && M.Signed(m)
  {
    if m == 0 then Panic(18)
    else var modulus := M.Abs(m);
         var base := M.Abs(a);
         if e < 0 && modulus > 1 && E.Gcd(modulus,base%modulus) != 1 then MissingInverse(base,modulus)
         else var powered := P.Power(if e < 0 then I.Spec(base,modulus) else base,M.Abs(e))%modulus;
              Value(if a < 0 && M.Abs(e)%2 == 1 then -(powered as int) else powered as int)
  }
}
