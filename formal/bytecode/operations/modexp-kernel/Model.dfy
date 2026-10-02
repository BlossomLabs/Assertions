// SPDX-License-Identifier: MIT
// Independent unbounded mathematics. No opcode or precompile theorem is assumed.
module OperationsModularPowerKernel {
  function Power(a:nat,e:nat):nat
    decreases e
  { if e==0 then 1 else a*Power(a,e-1) }

  lemma Associate(a:int,b:int,c:int)
    ensures (a*b)*c==a*(b*c)
  {}
  lemma PowerAdd(a:nat,e:nat,f:nat)
    ensures Power(a,e+f)==Power(a,e)*Power(a,f)
    decreases e
  {
    if e>0 { PowerAdd(a,e-1,f); Associate(a,Power(a,e-1),Power(a,f)); }
  }
  lemma SquareProduct(a:nat,b:nat)
    ensures (a*b)*(a*b)==(a*a)*(b*b)
  {}
  lemma PowerDouble(a:nat,e:nat)
    ensures Power(a,2*e)==Power(a*a,e)
    decreases e
  {
    if e>0 {
      PowerDouble(a,e-1);
      PowerAdd(a,e,e);
      PowerAdd(a,e-1,e-1);
      SquareProduct(a,Power(a,e-1));
    }
  }
  lemma PowerBinary(a:nat,e:nat)
    ensures Power(a,e)==(if e%2==1 then a else 1)*Power(a*a,e/2)
  {
    assert e==2*(e/2)+e%2;
    PowerDouble(a,e/2);
    if e%2==1 { PowerAdd(a,2*(e/2),1); }
  }
  lemma ProductResidue(a:int,b:int,m:nat)
    requires m>0
    ensures (a*b)%m==((a%m)*(b%m))%m
  {
    assert a==m*(a/m)+a%m;
    assert b==m*(b/m)+b%m;
    var q:=m*(a/m)*(b/m)+(a/m)*(b%m)+(b/m)*(a%m);
    assert a*b==m*q+(a%m)*(b%m);
    assert (m*q+(a%m)*(b%m))%m==((a%m)*(b%m))%m;
  }
  lemma ProductSameResidue(a:int,b:int,c:int,d:int,m:nat)
    requires m>0 && a%m==c%m && b%m==d%m
    ensures (a*b)%m==(c*d)%m
  { ProductResidue(a,b,m); ProductResidue(c,d,m); }
  lemma PowerResidue(a:nat,b:nat,e:nat,m:nat)
    requires m>0 && a%m==b%m
    ensures Power(a,e)%m==Power(b,e)%m
    decreases e
  {
    if e>0 {
      PowerResidue(a,b,e-1,m);
      ProductSameResidue(a,Power(a,e-1),b,Power(b,e-1),m);
    }
  }
  function Loop(a:nat,e:nat,r:nat,m:nat):nat
    requires m>0 && a<m && r<m
    ensures Loop(a,e,r,m)<m
    decreases e
  {
    if e==0 then r
    else var nextR:=if e%2==1 then (r*a)%m else r;
         var nextE:=e/2;
         var nextA:=if nextE==0 then a else (a*a)%m;
         Loop(nextA,nextE,nextR,m)
  }
  lemma TailMeaning(a:nat,e:nat,r:nat,m:nat)
    requires m>0 && a<m && r<m && e>0
    ensures var nextR:=if e%2==1 then (r*a)%m else r;
            var nextE:=e/2;
            var nextA:=if nextE==0 then a else (a*a)%m;
            (nextR*Power(nextA,nextE))%m==(r*Power(a,e))%m
  {
    PowerBinary(a,e);
    var nextR:=if e%2==1 then (r*a)%m else r;
    var nextE:=e/2;
    var nextA:=if nextE==0 then a else (a*a)%m;
    if nextE>0 { PowerResidue(nextA,a*a,nextE,m); }
    var tail:=Power(nextA,nextE);
    var square:=Power(a*a,nextE);
    assert tail%m==square%m;
    ProductSameResidue(nextR,tail,nextR,square,m);
    if e%2==1 {
      ProductSameResidue(nextR,square,r*a,square,m);
      Associate(r,a,square);
    } else { assert square==Power(a,e); }
  }
  lemma LoopMeaning(a:nat,e:nat,r:nat,m:nat)
    requires m>0 && a<m && r<m
    ensures Loop(a,e,r,m)==(r*Power(a,e))%m
    decreases e
  {
    if e>0 {
      TailMeaning(a,e,r,m);
      var nextR:=if e%2==1 then (r*a)%m else r;
      var nextE:=e/2;
      var nextA:=if nextE==0 then a else (a*a)%m;
      LoopMeaning(nextA,nextE,nextR,m);
    }
  }
  lemma ReducedEntry(a:nat,e:nat,m:nat)
    requires m>0
    ensures Loop(a%m,e,1%m,m)==Power(a,e)%m
  {
    PowerResidue(a%m,a,e,m);
    ProductSameResidue(1%m,Power(a%m,e),1,Power(a,e),m);
    LoopMeaning(a%m,e,1%m,m);
  }
  lemma ModulusOne(a:nat,e:nat)
    ensures Loop(0,e,0,1)==0 && Power(a,e)%1==0
  { LoopMeaning(0,e,0,1); }
}
