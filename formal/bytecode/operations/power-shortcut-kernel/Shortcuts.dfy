// SPDX-License-Identifier: MIT
// Integer outcomes behind compiler shortcuts. Development only, native pending.
include "../power-unit-shift/Shift.generated.dfy"
module OperationsPowerShortcuts {
  import P = OperationsCheckedPowerModel
  import K = OperationsPowerWordKernel
  import B = OperationsPowerBounds
  import M = OperationsSignedMultiplyMachine
  import U = OperationsPowerUnitShift

  lemma ZeroExponent(a:K.Word)
    ensures P.Unsigned(a,0)==P.Value(1)
    ensures P.SignedSpec(K.Signed(a),0)==P.Value(1)
  { K.SignedEncoding(a); }

  lemma UnsignedZero(b:nat)
    ensures P.Unsigned(0,b)==P.Value(if b==0 then 1 else 0)
    decreases b
  { if b>0 { assert P.Power(0,b)==0; } }

  lemma UnsignedOne(b:nat)
    ensures P.Unsigned(1,b)==P.Value(1)
    decreases b
  { if b>0 { UnsignedOne(b-1); } }

  lemma UnsignedFirst(a:K.Word)
    ensures P.Unsigned(a,1)==P.Value(a)
  {}

  lemma TwoBase(b:K.Word)
    ensures P.Unsigned(2,b)==(if b<256 then P.Value(M.Shift(1,b)) else P.Panic(17))
  {
    B.WordBound(); B.HalfBound();
    if b<256 {
      K.PowerMonotoneExponent(2,b,255);
      K.TwoPowerMeaning(b); U.Unit(b);
    } else { K.PowerMonotoneExponent(2,256,b); }
  }

  lemma LargeExponent(a:K.Word,b:K.Word)
    requires a>=2 && b>=256
    ensures P.Unsigned(a,b)==P.Panic(17)
  {
    B.WordBound(); K.PowerMonotoneBase(2,a,b);
    K.PowerMonotoneExponent(2,256,b);
  }

  lemma SmallShortcut(a:K.Word,b:K.Word)
    requires (a<=10 && b<=77) || (a<=306 && b<=31)
    ensures P.Unsigned(a,b)==P.Value(K.PowWord(a,b))
    ensures P.Power(a,b)==K.PowWord(a,b)
  {
    B.ShortcutRanges(a,b); P.PowerNonnegative(a,b);
    K.PowWordMeaning(a,b);
  }

  lemma SignedFirst(a:K.Word)
    ensures P.SignedSpec(K.Signed(a),1)==P.Value(K.Signed(a))
  { K.SignedEncoding(a); }

  lemma TraceOne(b:nat,acc:int)
    requires P.Signed(acc)
    ensures P.Trace(1,b,acc)==P.Value(acc)
    decreases b
  {
    if b>1 { assert b/2>0; TraceOne(b/2,acc); }
    else if b==1 { assert b/2==0; }
  }

  lemma SignedOne(b:K.Word)
    ensures P.SignedSpec(1,b)==P.Value(1)
  { TraceOne(b,1); }

  lemma SignedMinusOne(b:K.Word)
    ensures P.SignedSpec(-1,b)==P.Value(if b%2==1 then -1 else 1)
  {
    if b==0 { assert b%2==0; }
    else {
      var acc:=if b%2==1 then -1 else 1;
      assert P.Signed(acc);
      if b/2>0 { TraceOne(b/2,acc); }
    }
  }

  lemma TraceZero(b:nat,acc:int)
    requires P.Signed(acc)
    ensures P.Trace(0,b,acc)==P.Value(if b==0 then acc else 0)
    decreases b
  {
    if b>0 {
      var next:=if b%2==1 then 0 else acc;
      if b/2>0 { TraceZero(b/2,next); }
      else { assert b==1; }
    }
  }

  lemma SignedZero(b:K.Word)
    ensures P.SignedSpec(0,b)==P.Value(if b==0 then 1 else 0)
  { TraceZero(b,1); }
}
