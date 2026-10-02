include "Euclid.dfy"
module OperationsModularPowerInverseSource {
  import B = OperationsBinaryLogModel
  import P = OperationsFullMulDivProduct
  import M = OperationsFullMulDivModel
  import H = OperationsFullMulDivSignedHelpers
  import S = OperationsFullMulDivSource
  import E = OperationsModularPowerEuclid
  method Step(a: nat,n: nat,gcd: nat,remainder: nat,x: int,y: int)
    returns (nextG: nat,nextR: nat,nextX: int,nextY: int)
    requires a < B.Word && 0 < n < B.Word && 0 < remainder < gcd <= n
    requires M.Signed(x) && M.Signed(y) && 2*E.Abs(x) <= n && 2*E.Abs(y) <= n
    requires x*y <= 0 && E.Abs(x)*remainder+E.Abs(y)*gcd == n
    requires (a*x)%n == gcd%n && (a*y)%n == remainder
    ensures nextG == remainder && nextR == gcd%remainder
    ensures M.Signed(nextX) && M.Signed(nextY) && 2*E.Abs(nextX) <= n
    ensures (a*nextX)%n == nextG%n
    ensures nextR > 0 ==> nextX*nextY <= 0 && E.Abs(nextX)*nextR+E.Abs(nextY)*nextG == n
    ensures nextR > 0 ==> (a*nextY)%n == nextR && 2*E.Abs(nextY) <= n
  {
    var quotient: nat := P.Div(gcd,remainder);
    E.QuotientStep(gcd,remainder);
    E.Determinant(gcd,remainder,x,y,n);
    E.CanonicalRemainder(remainder,n);
    E.CongruenceStep(a,n,gcd,remainder,x,y,quotient);
    E.WrappedStep(x,y,quotient);
    ghost var mathNext := x-quotient*y;
    nextG,nextR := remainder,((gcd - ((remainder * quotient) % B.Word)) % B.Word);
    assert nextR == gcd-quotient*remainder && nextR < n;
    E.CanonicalRemainder(nextR,n);
    assert (a*mathNext)%n == nextR;
    nextX,nextY := y,H.Signed(x - H.Signed(y * H.Signed(quotient)));
    if nextR > 0 {
      E.CoefficientRange(mathNext,n);
      H.WordIdentity(mathNext);
      assert nextY == mathNext;
    }
  }
  method Normalize(a: nat,n: nat,x: int) returns (inverse: nat)
    requires a < B.Word && 0 < n < B.Word && M.Signed(x) && 2*E.Abs(x) <= n
    requires (a*x)%n == 1%n
    ensures n == 1 ==> inverse == 0
    ensures n > 1 ==> 0 < inverse < n
    ensures n > 1 ==> (a*inverse)%n == 1
  {
    if n == 1 { assert x == 0; }
    else { E.CanonicalRemainder(1,n); }
    if x < 0 { H.WordIdentity(-x); }
    inverse := S.Ternary((x < 0),((n - ((H.Signed(-x)) % B.Word)) % B.Word),((x) % B.Word));
    if x < 0 {
      assert inverse == n+x;
      P.ShiftRemainder(a*inverse,a*x,a,n);
    } else { assert inverse == x; }
  }
  method Inverse(a: nat,n: nat) returns (inverse: nat)
    requires a < B.Word && n < B.Word
    ensures n == 0 ==> inverse == 0
    ensures n > 0 && E.Gcd(n,a%n) != 1 ==> inverse == 0
    ensures n == 1 ==> inverse == 0
    ensures n > 1 && E.Gcd(n,a%n) == 1 ==> 0 < inverse < n && (a*inverse)%n == 1
  {
    B.KnownPowers();
    if (n == 0) { inverse := 0; return; }
    var remainder: nat := (a%n);
    var gcd: nat := n;
    var x: int := 0;
    var y: int := 1;
    while (remainder != 0)
      invariant 0 < gcd <= n && remainder < gcd
      invariant E.Gcd(gcd,remainder) == E.Gcd(n,a%n)
      invariant M.Signed(x) && M.Signed(y) && 2*E.Abs(x) <= n
      invariant (a*x)%n == gcd%n
      invariant remainder > 0 ==> x*y <= 0 && E.Abs(x)*remainder+E.Abs(y)*gcd == n
      invariant remainder > 0 ==> (a*y)%n == remainder && 2*E.Abs(y) <= n
      decreases remainder
    {
      gcd,remainder,x,y := Step(a,n,gcd,remainder,x,y);
    }
    if (gcd != 1) { inverse := 0; return; }
    inverse := Normalize(a,n,x);
  }
  method CoefficientWitness()
  {
    var x: int := -1;
    var y: int := 2;
    var quotient: nat := 3;
    var next := H.Signed(x - H.Signed(y * H.Signed(quotient)));
    assert next == -7;
  }
}
