include "Inverse.generated.dfy"
include "InverseModel.dfy"
include "Power.dfy"
module OperationsModularPowerInverseConnection {
  import B = OperationsBinaryLogModel
  import E = OperationsModularPowerEuclid
  import M = OperationsModularPowerInverseModel
  import S = OperationsModularPowerInverseSource
  method Connection(a: nat,n: nat) returns (inverse: nat)
    requires a < B.Word && n < B.Word
    ensures inverse == M.Spec(a,n)
    ensures n > 1 && E.Gcd(n,a%n) == 1 ==> 0 < inverse < n && (a*inverse)%n == 1
  {
    inverse := S.Inverse(a,n);
    if n > 1 && E.Gcd(n,a%n) == 1 {
      M.RepresentativeCorrect(a,n);
      M.Unique(a,n,inverse,M.Representative(a,n));
    }
  }
}
