// SPDX-License-Identifier: MIT
// Mathematical stage and physical trace composition. Public entry remains open.
include "../sqrt-opcode-kernel/Kernel.dfy"
module OperationsSquareRootSeedConnectionCore {
  import M = OperationsBytecodeLog2Machine
  import E = OperationsSquareRootExecution
  import K = OperationsSquareRootOpcodeKernel
  import F = OperationsSquareRootMath
  import S = OperationsSquareRootSeed
  import L = OperationsSquareRootLimits
  import N = OperationsSquareRootNewton
  import Q = OperationsSquareRootSeedScan
  lemma QuotientLower(n: nat,divisor: nat,quotient: nat)
    requires divisor>0 && quotient==n/divisor
    ensures quotient*divisor<=n
  { assert n==quotient*divisor+n%divisor; }
  method Reduce(n: M.Word,aa: M.Word,seed: M.Word,k: nat,width: M.Word)
    returns(nextAA: M.Word,nextSeed: M.Word,nextK: nat)
    requires n>=2 && width in {1,2,4,8,16,32,64} && k<=127
    requires aa==n/S.Power4(k) && 1<=aa<S.Power4(2*width) && seed==S.Power2(k)
    ensures nextK<=127 && nextAA==n/S.Power4(nextK) && 1<=nextAA<S.Power4(width)
    ensures nextSeed==S.Power2(nextK)
    ensures nextAA==(if aa>=S.Power4(width) then M.Right(aa,2*width) else aa)
    ensures nextSeed==(if aa>=S.Power4(width) then E.Left(seed,width) else seed)
  {
    L.WordLimit(); Q.PowerProduct(width,width);
    if aa>=S.Power4(width) {
      Q.PowerProduct(k,width);
      N.ProductOrder(S.Power4(width),aa,S.Power4(k));
      QuotientLower(n,S.Power4(k),aa);
      assert S.Power4(k+width)==S.Power4(width)*S.Power4(k);
      assert S.Power4(width)*S.Power4(k)<=aa*S.Power4(k)<=n;
      assert S.Power4(k+width)<=n;
      if k+width>=128 { S.Monotone(128,k+width); }
      assert k+width<=127;
      K.LeftSeed(seed,k,width);K.RightSeed(aa,width);
      nextSeed:=E.Left(seed,width);nextAA:=M.Right(aa,2*width);nextK:=k+width;
      Q.DivisionProduct(n,S.Power4(k),S.Power4(width));
      N.QuotientAtLeast(aa,S.Power4(width),1);
      N.QuotientUpper(aa,S.Power4(width),S.Power4(width)-1);
    } else { nextAA:=aa;nextSeed:=seed;nextK:=k; }
  }
  predicate Trace(code: seq<M.Byte>,destinations: set<nat>,trace: seq<M.State>,
                  value: M.Word,size: M.Word,word: M.Word,a: M.Word) {
    |trace|>0 && forall j:nat :: j+1<|trace| ==>
                                   trace[j+1]==E.Execute(code,destinations,trace[j],value,size,word,a)
  }
  lemma Append(code: seq<M.Byte>,destinations: set<nat>,left: seq<M.State>,right: seq<M.State>,
               value: M.Word,size: M.Word,word: M.Word,a: M.Word)
    requires Trace(code,destinations,left,value,size,word,a) && Trace(code,destinations,right,value,size,word,a)
    requires left[|left|-1]==right[0]
    ensures Trace(code,destinations,left+right[1..],value,size,word,a)
  {
    forall j:nat | j+1<|left+right[1..]|
      ensures (left+right[1..])[j+1]==E.Execute(code,destinations,(left+right[1..])[j],value,size,word,a)
    {
      if j+1<|left| { assert left[j+1]==E.Execute(code,destinations,left[j],value,size,word,a); }
      else if j+1==|left| { assert right[1]==E.Execute(code,destinations,right[0],value,size,word,a); }
      else {
        var r:=j-(|left|-1);
        assert r+1<|right| && right[r+1]==E.Execute(code,destinations,right[r],value,size,word,a);
      }
    }
  }
}
