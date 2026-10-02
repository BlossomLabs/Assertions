// SPDX-License-Identifier: MIT
// Independent integer/modular exponent foundation. Native checks and exact
// compiled entry connections remain open; no public bytecode claim.
include "../../../operations/checked-power/Model.dfy"
module OperationsPowerWordKernel {
  import P = OperationsCheckedPowerModel
  const M:int := P.Word
  const H:int := P.Half
  type Word = n:nat | n<M witness 0
  function Signed(n:Word):int { if n<H then n else n-M }
  function Encode(n:int):Word { n%M }
  function PowWord(a:Word,b:nat):Word
    decreases b
  {
    if b==0 then 1
    else
      var p:=PowWord(a,b/2);
      ((p*p)%M*(if b%2==1 then a else 1))%M
  }
  lemma ProductCongruence(x:int,y:int)
    ensures ((x%M)*(y%M))%M==(x*y)%M
  {
    assert x==M*(x/M)+x%M;
    assert y==M*(y/M)+y%M;
    var coefficient:=M*(x/M)*(y/M)+(x/M)*(y%M)+(y/M)*(x%M);
    assert x*y==M*coefficient+(x%M)*(y%M);
    assert (M*coefficient+(x%M)*(y%M))%M==((x%M)*(y%M))%M;
  }
  lemma ProductResidues(x:int,y:int,u:int,v:int)
    requires x%M==u%M && y%M==v%M
    ensures (x*y)%M==(u*v)%M
  { ProductCongruence(x,y);ProductCongruence(u,v); }
  lemma PowerCongruence(x:int,y:int,b:nat)
    requires x%M==y%M
    ensures P.Power(x,b)%M==P.Power(y,b)%M
    decreases b
  {
    if b>0 {
      PowerCongruence(x,y,b-1);
      ProductResidues(x,P.Power(x,b-1),y,P.Power(y,b-1));
    }
  }
  lemma PowWordMeaning(a:Word,b:nat)
    ensures PowWord(a,b)==P.Power(a,b)%M
    decreases b
  {
    if b>0 {
      var half:=b/2;var p:=PowWord(a,half);
      PowWordMeaning(a,half);
      P.PowerAdd(a,half,half);
      assert P.Power(a,2*half)==P.Power(a,half)*P.Power(a,half);
      ProductCongruence(P.Power(a,half),P.Power(a,half));
      assert (p*p)%M==P.Power(a,2*half)%M;
      assert b==2*half+b%2;
      P.PowerAdd(a,2*half,b%2);
      if b%2==1 {
        assert P.Power(a,1)==a;
        ProductResidues((p*p)%M,a,P.Power(a,2*half),a);
      } else { assert b%2==0 && P.Power(a,0)==1; }
    }
  }
  lemma SignedEncoding(a:Word)
    ensures P.Signed(Signed(a)) && Encode(Signed(a))==a
  {}
  lemma SignedPowerResidue(a:Word,b:nat)
    ensures PowWord(a,b)==P.Power(Signed(a),b)%M
  {
    SignedEncoding(a);PowerCongruence(a,Signed(a),b);PowWordMeaning(a,b);
  }
  lemma PowZeroExponent(a:Word)
    ensures PowWord(a,0)==1
  {}
  lemma PowZeroBase(b:nat)
    ensures PowWord(0,b)==(if b==0 then 1 else 0)
    decreases b
  { if b>0 { PowZeroBase(b/2);if b/2==0 { assert b==1; } } }
  lemma PowOneBase(b:nat)
    ensures PowWord(1,b)==1
    decreases b
  { if b>0 { PowOneBase(b/2); } }
  lemma PowerMonotoneBase(a:nat,c:nat,b:nat)
    requires a<=c
    ensures 0<=P.Power(a,b)<=P.Power(c,b)
    decreases b
  {
    if b>0 { PowerMonotoneBase(a,c,b-1); }
  }
  lemma PowerMonotoneExponent(a:nat,b:nat,c:nat)
    requires a>=1 && b<=c
    ensures 1<=P.Power(a,b)<=P.Power(a,c)
    decreases c
  {
    if c>0 { if b<c { PowerMonotoneExponent(a,b,c-1); } else { PowerMonotoneExponent(a,b-1,c-1); } }
  }
  function CheckedTrace(a:Word,b:nat,acc:Word):P.Outcome
    decreases b
  {
    if b==0 then P.Value(acc)
    else
      var product:=acc*a;
      if b%2==1 && product>=M then P.Panic(17)
      else
        var next:Word:=if b%2==1 then product else acc;
        var half:=b/2;
        if half==0 then P.Value(next)
        else if a*a>=M then P.Panic(17)
        else CheckedTrace((a*a) as Word,half,next)
  }
  lemma CheckedTraceMeaning(a:Word,b:nat,acc:Word)
    requires a>=1 && acc>=1
    ensures CheckedTrace(a,b,acc)==
            (if acc*P.Power(a,b)<M then P.Value(acc*P.Power(a,b)) else P.Panic(17))
    decreases b
  {
    if b>0 {
      P.PowerBinary(a,b);
      var product:=acc*a;
      if b%2==1 && product>=M {
        PowerMonotoneExponent(a,1,b);
        assert acc*P.Power(a,b)>=product;
      } else {
        var next:Word:=if b%2==1 then product else acc;
        var half:=b/2;
        assert next>=1;
        assert acc*P.Power(a,b)==next*P.Power(a*a,half);
        if half==0 { assert P.Power(a*a,half)==1; }
        else if a*a>=M {
          PowerMonotoneExponent(a*a,1,half);
          assert next*P.Power(a*a,half)>=a*a;
        } else { CheckedTraceMeaning((a*a) as Word,half,next); }
      }
    }
  }
  lemma SignedTraceRange(a:int,b:nat,acc:int)
    requires P.Signed(a) && P.Signed(acc)
    ensures P.Trace(a,b,acc).Value? ==> P.Signed(P.Trace(a,b,acc).result)
    decreases b
  {
    if b>0 {
      var product:=acc*a;
      if b%2==0 || P.Signed(product) {
        var next:=if b%2==1 then product else acc;
        var half:=b/2;
        if half>0 && P.Signed(a*a) { SignedTraceRange(a*a,half,next); }
      }
    }
  }
  lemma SignedTraceMeaning(a:Word,b:nat)
    ensures P.Trace(Signed(a),b,1).Value? ==>
              P.Trace(Signed(a),b,1).result==P.Power(Signed(a),b) &&
              P.Signed(P.Trace(Signed(a),b,1).result) &&
              Encode(P.Trace(Signed(a),b,1).result)==PowWord(a,b)
  {
    P.TraceMath(Signed(a),b,1);
    SignedTraceRange(Signed(a),b,1);
    SignedEncoding(a);PowerCongruence(Signed(a),a,b);PowWordMeaning(a,b);
  }
  function TwoPower(bits:nat):nat
    ensures TwoPower(bits)>0
    decreases bits
  { if bits==0 then 1 else 2*TwoPower(bits-1) }
  lemma TwoPowerMeaning(bits:nat)
    ensures TwoPower(bits)==P.Power(2,bits)
    decreases bits
  { if bits>0 { TwoPowerMeaning(bits-1); } }
  function BinaryDepth(n:nat):nat
    decreases n
  { if n==0 then 0 else 1+BinaryDepth(n/2) }
  lemma DepthBound(n:nat,bits:nat)
    requires n<TwoPower(bits)
    ensures BinaryDepth(n)<=bits
    decreases bits
  {
    if bits==0 { assert n==0; }
    else if n>0 { assert n/2<TwoPower(bits-1);DepthBound(n/2,bits-1); }
  }
}
