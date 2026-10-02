// SPDX-License-Identifier: MIT
// Mathematical correspondence for the reached arithmetic instructions. Raw entry remains open.
include "Execution.dfy"
include "../sqrt-word-kernel-v3/SeedScan.dfy"
module OperationsSquareRootOpcodeKernel {
  import M = OperationsBytecodeLog2Machine
  import E = OperationsSquareRootExecution
  import F = OperationsSquareRootMath
  import S = OperationsSquareRootSeed
  import L = OperationsSquareRootLimits
  import N = OperationsSquareRootNewton
  import W = OperationsSquareRootArithmetic
  lemma PowerEquality(exponent: nat)
    ensures M.Pow2(exponent)==S.Power2(exponent)
    decreases exponent
  { if exponent>0 { PowerEquality(exponent-1); } }
  lemma TwicePower(exponent: nat)
    ensures S.Power2(2*exponent)==S.Power4(exponent)
    decreases exponent
  { if exponent>0 { TwicePower(exponent-1); } }
  lemma PowerProduct(left: nat,right: nat)
    ensures S.Power2(left+right)==S.Power2(left)*S.Power2(right)
    decreases right
  { if right>0 { PowerProduct(left,right-1); } }
  lemma RightSeed(aa: M.Word,width: M.Word)
    requires width in {1,2,4,8,16,32,64}
    ensures M.Right(aa,2*width)==aa/S.Power4(width)
  {
    PowerEquality(2*width); TwicePower(width); reveal M.Right();
  }
  lemma LeftSeed(seed: M.Word,k: nat,width: M.Word)
    requires width in {1,2,4,8,16,32,64} && k+width<=127
    requires seed==S.Power2(k)
    ensures E.Left(seed,width)==S.Power2(k+width)
    ensures E.Left(seed,width)<=F.Limit/2
  {
    L.WordLimit(); S.Power2Monotone(k+width,127);
    PowerEquality(width); PowerProduct(k,width); reveal E.Left();
    assert seed*M.Pow2(width)<M.Modulus();
  }
  lemma FirstEstimate(scale: M.Word)
    requires 1<=scale<=F.Limit/2
    ensures M.Right((3*scale)%M.Modulus(),1)==3*scale/2
    ensures 3*scale<M.Modulus()
  { assert M.Pow2(1)==2; reveal M.Right(); }
  lemma NextArithmetic(n: M.Word,estimate: M.Word)
    requires estimate>0 && estimate+n/estimate<M.Modulus()
    ensures M.Right((estimate+M.Quotient(n,estimate))%M.Modulus(),1)==N.Next(n,estimate)
  { assert M.Pow2(1)==2; reveal M.Right(); N.NextDefinition(n,estimate); }
  lemma FirstNext(n: M.Word,root: nat,scale: M.Word)
    requires n>=2 && F.IsRoot(n,root) && 1<=scale<=F.Limit/2
    requires scale*scale<=n<4*scale*scale
    ensures var estimate:=M.Right((3*scale)%M.Modulus(),1);
            estimate>0 && estimate+n/estimate<M.Modulus() &&
            M.Right((estimate+M.Quotient(n,estimate))%M.Modulus(),1)==N.Next(n,3*scale/2)
  { FirstEstimate(scale); W.FirstWindow(n,root,scale); NextArithmetic(n,3*scale/2); }
  lemma LaterNext(n: M.Word,root: nat,estimate: M.Word)
    requires n>=2 && F.IsRoot(n,root) && 1<=root<=estimate<=2*F.Limit
    ensures estimate+n/estimate<M.Modulus()
    ensures M.Right((estimate+M.Quotient(n,estimate))%M.Modulus(),1)==N.Next(n,estimate)
    ensures root<=N.Next(n,estimate)<=2*F.Limit
  { W.LaterWindow(n,root,estimate); NextArithmetic(n,estimate); }
}
