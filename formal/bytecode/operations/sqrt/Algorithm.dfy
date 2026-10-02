// SPDX-License-Identifier: MIT
// Unverified integer-iteration connection candidate. No opcode or public credit.
include "Limits.generated.dfy"
include "Newton.dfy"
module OperationsSquareRootAlgorithm {
  import F = OperationsSquareRootMath
  import S = OperationsSquareRootSeed
  import L = OperationsSquareRootLimits
  import N = OperationsSquareRootNewton
  function Sixth(n: nat,scale: nat): nat
    requires n>=2 && scale>0
    ensures Sixth(n,scale)>0
  {
    var first:=N.Next(n,3*scale/2);
    var second:=N.Next(n,first);
    var third:=N.Next(n,second);
    var fourth:=N.Next(n,third);
    var fifth:=N.Next(n,fourth);
    N.Next(n,fifth)
  }
  function Outcome(n: F.Word): nat {
    if n<=1 then n else
    var sixth:=Sixth(n,S.Initial(n));
    sixth-(if sixth>n/sixth then 1 else 0)
  }
  lemma Connection(n: F.Word)
    ensures Outcome(n)==F.Floor(n)
    ensures Outcome(n)<F.Limit
  {
    F.Fitting(n);
    if n<=1 {
      assert F.IsRoot(n,n); F.Unique(n,n,F.Floor(n));
    } else {
      var root:=F.Floor(n); var scale:=S.Initial(n);
      S.Bounds(n); L.Fitting(n); S.Parity(S.Class(n));
      if scale<16 { N.SmallSteps(n,root,scale); }
      else { N.SixSteps(n,root,scale); }
      var sixth:=Sixth(n,scale);
      assert root<=sixth<=root+1;
      N.Correct(n,sixth,root);
    }
  }
}
