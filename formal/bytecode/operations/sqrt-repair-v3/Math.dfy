// SPDX-License-Identifier: MIT
// Independent integer-square-root specification candidate. No opcode credit.
module OperationsSquareRootMath {
  const Limit: nat := 0x100000000000000000000000000000000
  const Modulus: nat := Limit*Limit
  type Word = n: nat | n<Modulus witness 0

  predicate IsRoot(n: nat,result: nat) { result*result<=n<(result+1)*(result+1) }

  function Search(n: nat,low: nat,high: nat): nat
    requires low<=high && low*low<=n<(high+1)*(high+1)
    ensures IsRoot(n,Search(n,low,high))
    decreases high-low
  {
    if low==high then low else
    var middle: nat := (low+high+1)/2;
    if middle*middle<=n then Search(n,middle,high)
    else Search(n,low,middle-1)
  }

  function Floor(n: nat): nat
    ensures IsRoot(n,Floor(n))
  { Search(n,0,n) }

  lemma ProductOrder(left: nat,right: nat,factor: nat)
    requires left<=right
    ensures left*factor<=right*factor
  {
    assert 0<=(right-left)*factor;
    assert right*factor-left*factor==(right-left)*factor;
  }

  lemma SquareOrder(left: nat,right: nat)
    requires left<=right
    ensures left*left<=right*right
  {
    ProductOrder(left,right,left);
    ProductOrder(left,right,right);
    assert right*left==left*right;
  }

  lemma Unique(n: nat,left: nat,right: nat)
    requires IsRoot(n,left) && IsRoot(n,right)
    ensures left==right
  {
    if left<right { SquareOrder(left+1,right); }
    else if right<left { SquareOrder(right+1,left); }
  }

  lemma Fitting(n: Word)
    ensures Floor(n)<Limit
    ensures Floor(n)<Modulus
  {
    if Floor(n)>=Limit { SquareOrder(Limit,Floor(n)); }
  }

  lemma PerfectSquare(root: nat)
    ensures Floor(root*root)==root
  {
    assert root*root<(root+1)*(root+1);
    Unique(root*root,Floor(root*root),root);
  }
}
