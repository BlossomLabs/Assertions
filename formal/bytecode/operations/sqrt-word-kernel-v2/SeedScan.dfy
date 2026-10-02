// SPDX-License-Identifier: MIT
// Candidate mathematical connection for the seven executed seed reductions.
// Actual instruction/state binding and public bytecode evidence remain open.
include "Arithmetic.dfy"
module OperationsSquareRootSeedScan {
  import F = OperationsSquareRootMath
  import S = OperationsSquareRootSeed
  import L = OperationsSquareRootLimits
  import N = OperationsSquareRootNewton
  lemma PowerProduct(left: nat,right: nat)
    ensures S.Power4(left+right)==S.Power4(left)*S.Power4(right)
    decreases right
  { if right>0 { PowerProduct(left,right-1); } }
  lemma ProductRemainder(first: nat,second: nat,low: nat,remainder: nat)
    requires first>0 && second>0 && low<second && remainder<first
    ensures first*low+remainder<first*second
  { N.ProductOrder(low,second-1,first); }
  lemma DivisionUnique(n: nat,divisor: nat,quotient: nat,remainder: nat)
    requires divisor>0 && remainder<divisor
    requires n==quotient*divisor+remainder
    ensures n/divisor==quotient
  {
    var actual:=n/divisor;
    assert actual*divisor<=n<(actual+1)*divisor;
    if actual<quotient { N.ProductOrder(actual+1,quotient,divisor); }
    if quotient<actual { N.ProductOrder(quotient+1,actual,divisor); }
  }
  lemma DecodedBounds(n: nat,divisor: nat,quotient: nat)
    requires divisor>0 && quotient==n/divisor && 1<=quotient<4
    ensures divisor<=n<4*divisor
  {
    assert quotient*divisor<=n<(quotient+1)*divisor;
    N.ProductOrder(1,quotient,divisor);
    N.ProductOrder(quotient+1,4,divisor);
  }
  lemma DivisionProduct(n: nat,first: nat,second: nat)
    requires first>0 && second>0
    ensures (n/first)/second==n/(first*second)
  {
    var whole:=n/first; var high:=whole/second;
    var low:=whole%second; var remainder:=n%first;
    assert n==first*whole+remainder;
    assert whole==second*high+low;
    assert n==(first*second)*high+(first*low+remainder);
    ProductRemainder(first,second,low,remainder);
    DivisionUnique(n,first*second,high,first*low+remainder);
  }
  lemma ClassUnique(n: nat,k: nat)
    requires n>0 && S.Power4(k)<=n<4*S.Power4(k)
    ensures S.Class(n)==k
  {
    if k<S.Class(n) { S.Monotone(k+1,S.Class(n)); }
    if S.Class(n)<k { S.Monotone(S.Class(n)+1,k); }
  }
  ghost method Reduce(n: nat,aa: nat,k: nat,width: nat) returns(bb: nat,next: nat)
    requires width>0 && aa==n/S.Power4(k) && 1<=aa<S.Power4(2*width)
    ensures bb==n/S.Power4(next) && 1<=bb<S.Power4(width)
    ensures next==k || next==k+width
  {
    PowerProduct(width,width);
    if aa>=S.Power4(width) {
      var divisor:=S.Power4(width);
      N.QuotientAtLeast(aa,divisor,1);
      N.QuotientUpper(aa,divisor,divisor-1);
      bb:=aa/divisor; next:=k+width;
      DivisionProduct(n,S.Power4(k),S.Power4(width));
      PowerProduct(k,width);
    } else { bb:=aa; next:=k; }
  }
  ghost method Scan(n: F.Word) returns(seed: nat)
    requires n>=2
    ensures seed==S.Initial(n)
    ensures seed*seed<=n<4*seed*seed
    ensures 1<=seed<=F.Limit/2
  {
    L.WordLimit();
    var aa:nat:=n; var k:nat:=0;
    aa,k:=Reduce(n,aa,k,64);
    aa,k:=Reduce(n,aa,k,32);
    aa,k:=Reduce(n,aa,k,16);
    aa,k:=Reduce(n,aa,k,8);
    aa,k:=Reduce(n,aa,k,4);
    aa,k:=Reduce(n,aa,k,2);
    aa,k:=Reduce(n,aa,k,1);
    DecodedBounds(n,S.Power4(k),aa);
    assert S.Power4(k)<=n<4*S.Power4(k);
    ClassUnique(n,k); seed:=S.Power2(k);
    S.Powers(k); S.Bounds(n); L.Fitting(n);
  }
}
