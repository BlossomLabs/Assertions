// SPDX-License-Identifier: MIT
// Candidate mathematical connection for the seven executed seed reductions.
// Actual instruction/state binding and public bytecode evidence remain open.
include "../sqrt-repair-v3/Limits.generated.dfy"
module OperationsSquareRootSeedScan {
  import F = OperationsSquareRootMath
  import S = OperationsSquareRootSeed
  import L = OperationsSquareRootLimits
  lemma PowerProduct(left: nat,right: nat)
    ensures S.Power4(left+right)==S.Power4(left)*S.Power4(right)
    decreases right
  { if right>0 { PowerProduct(left,right-1); } }
  lemma DivisionProduct(n: nat,first: nat,second: nat)
    requires first>0 && second>0
    ensures (n/first)/second==n/(first*second)
  {
    var whole:=n/first; var high:=whole/second;
    var low:=whole%second; var remainder:=n%first;
    assert n==first*whole+remainder;
    assert whole==second*high+low;
    assert n==(first*second)*high+(first*low+remainder);
    assert 0<=first*low+remainder<first*second;
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
      bb:=aa/S.Power4(width); next:=k+width;
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
    assert S.Power4(k)<=n<4*S.Power4(k);
    ClassUnique(n,k); seed:=S.Power2(k);
    S.Powers(k); S.Bounds(n); L.Fitting(n);
  }
}
