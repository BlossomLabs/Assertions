// SPDX-License-Identifier: MIT
// Unverified fitting intermediate arithmetic; no opcode/public credit.
include "../sqrt-repair-v3/Algorithm.dfy"
module OperationsSquareRootArithmetic {
  import F = OperationsSquareRootMath
  import S = OperationsSquareRootSeed
  import N = OperationsSquareRootNewton
  lemma FirstWindow(n: F.Word,root: nat,scale: nat)
    requires n>=2 && F.IsRoot(n,root) && 1<=scale<=F.Limit/2
    requires scale*scale<=n<4*scale*scale
    ensures var estimate:=3*scale/2;
            estimate>0 && estimate+n/estimate<F.Modulus
    ensures root<=N.Next(n,3*scale/2)<=2*F.Limit
  {
    var estimate:=3*scale/2;
    N.NextDefinition(n,estimate);
    assert scale<=estimate<=2*scale;
    N.ProductOrder(scale,estimate,4*scale);
    N.QuotientUpper(n,estimate,4*scale-1);
    assert estimate+n/estimate<6*scale<=3*F.Limit<F.Modulus;
    N.Lower(n,estimate,root);
  }
  lemma LaterWindow(n: F.Word,root: nat,estimate: nat)
    requires n>=2 && F.IsRoot(n,root) && 1<=root<=estimate<=2*F.Limit
    ensures estimate+n/estimate<F.Modulus
    ensures root<=N.Next(n,estimate)<=2*F.Limit
  {
    N.NextDefinition(n,estimate);
    F.Fitting(n); F.Unique(n,root,F.Floor(n));
    assert root<F.Limit && n<=root*root+2*root;
    N.ProductOrder(root,estimate,root+3);
    assert n<(root+3)*estimate;
    N.QuotientUpper(n,estimate,root+2);
    assert estimate+n/estimate<=3*F.Limit+1<F.Modulus;
    N.Lower(n,estimate,root);
    assert 2*F.Limit>=1;
  }
}
