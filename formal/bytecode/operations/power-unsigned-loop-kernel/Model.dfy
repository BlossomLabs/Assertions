// SPDX-License-Identifier: MIT
// Independent compiler-loop outcome, not an executed-bytecode certificate.
include "../power-opcode-kernel/Execution.dfy"
module OperationsPowerUnsignedLoopKernel {
  import K = OperationsPowerWordKernel
  import P = OperationsCheckedPowerModel
  import M = OperationsSignedMultiplyMachine

  lemma QuotientProduct(a:K.Word,b:K.Word)
    requires a>0
    ensures b<=((K.M-1)/a) <==> a*b<K.M
  {
    var q:=(K.M-1)/a;
    var r:=(K.M-1)%a;
    assert K.M-1==q*a+r && 0<=r<a;
    if b<=q { assert a*b<=a*q<=K.M-1; }
    else { assert b>=q+1; assert a*b>=a*q+a>K.M-1; }
  }

  function Trace(a:K.Word,b:nat,acc:K.Word):P.Outcome
    requires a>=2 && b>0 && 1<=acc<a
    decreases b
  {
    if b==1 then
      if acc*a<K.M then P.Value(acc*a) else P.Panic(17)
    else if a*a>=K.M then P.Panic(17)
    else
      var next:K.Word:=if b%2==1 then acc*a else acc;
      Trace((a*a) as K.Word,b/2,next)
  }

  lemma WordProducts(a:K.Word,acc:K.Word)
    requires a>=2 && 1<=acc<a && a*a<K.M
    ensures M.Product(acc,a)==acc*a && M.Product(a,a)==a*a
    ensures 1<=acc*a<a*a && acc<a*a
  {
    M.ProductSymmetric(acc,a);
  }

  lemma Meaning(a:K.Word,b:nat,acc:K.Word)
    requires a>=2 && b>0 && 1<=acc<a
    ensures Trace(a,b,acc)==
            (if acc*P.Power(a,b)<K.M then P.Value(acc*P.Power(a,b)) else P.Panic(17))
    decreases b
  {
    if b==1 { assert P.Power(a,1)==a; }
    else {
      K.PowerMonotoneExponent(a,2,b);
      assert acc*P.Power(a,b)>=a*a;
      if a*a<K.M {
        WordProducts(a,acc);
        var next:K.Word:=if b%2==1 then acc*a else acc;
        var half:=b/2;
        assert b>=2 && 0<half<b;
        P.PowerBinary(a,b);
        assert acc*P.Power(a,b)==next*P.Power(a*a,half);
        Meaning((a*a) as K.Word,half,next);
      }
    }
  }

  lemma Initial(a:K.Word,b:nat)
    requires a>=2 && b>0
    ensures Trace(a,b,1)==P.Unsigned(a,b)
  { Meaning(a,b,1); }
}
