// SPDX-License-Identifier: MIT
// Candidate integer Newton bounds. Not verified and no opcode/public credit.
include "Math.dfy"
module OperationsSquareRootNewton {
  import F = OperationsSquareRootMath

  opaque function Next(n: nat,estimate: nat): nat
    requires estimate>0
    ensures n>=2 ==> Next(n,estimate)>0
  { (estimate+n/estimate)/2 }

  lemma NextDefinition(n: nat,estimate: nat)
    requires estimate>0
    ensures Next(n,estimate)==(estimate+n/estimate)/2
  { reveal Next(); }

  lemma ProductOrder(left: nat,right: nat,factor: nat)
    requires left<=right
    ensures left*factor<=right*factor
  {
    assert 0<=(right-left)*factor;
    assert right*factor-left*factor==(right-left)*factor;
  }

  lemma QuotientAtLeast(n: nat,divisor: nat,minimum: nat)
    requires divisor>0 && minimum*divisor<=n
    ensures n/divisor>=minimum
  {
    var quotient:=n/divisor;
    assert n==quotient*divisor+n%divisor;
    if quotient<minimum {
      ProductOrder(quotient+1,minimum,divisor);
      assert n<(quotient+1)*divisor;
    }
  }

  lemma Lower(n: nat,estimate: nat,root: nat)
    requires estimate>0 && root*root<=n
    ensures Next(n,estimate)>=root
  {
    NextDefinition(n,estimate);
    if estimate>=2*root { assert estimate+n/estimate>=2*root; }
    else {
      var missing: nat:=2*root-estimate;
      var difference: int:=(estimate as int)-root;
      assert 0<=difference*difference;
      assert root*root-missing*estimate==difference*difference;
      QuotientAtLeast(n,estimate,missing);
      assert estimate+n/estimate>=2*root;
    }
  }

  lemma Error(n: nat,estimate: nat,root: nat)
    requires estimate>0 && F.IsRoot(n,root)
    ensures Next(n,estimate)>=root
    ensures 2*estimate*(Next(n,estimate)-root)<=
            ((estimate as int)-root)*((estimate as int)-root)+2*root
  {
    NextDefinition(n,estimate);
    Lower(n,estimate,root);
    assert n-root*root<=2*root;
    assert 2*Next(n,estimate)<=estimate+n/estimate;
    ProductOrder(2*Next(n,estimate),estimate+n/estimate,estimate);
    assert (n/estimate)*estimate<=n;
    assert (estimate as int)*estimate+n-2*estimate*root==
           ((estimate as int)-root)*((estimate as int)-root)+(n-root*root);
  }

  lemma ScaledError(root: nat,estimate: nat,scale: nat,error: nat,square: nat)
    requires scale<=root<=estimate
    requires 2*estimate*error<=square+2*root
    ensures 2*scale*error<=square+2*scale
  {
    if error>0 {
      assert 2*estimate*(error-1)<=square;
      ProductOrder(scale,estimate,error-1);
      assert 2*scale*(error-1)<=square;
      assert 2*scale*error==2*scale*(error-1)+2*scale;
    } else { assert 2*scale*error==0; }
  }

  lemma ErrorAfterLower(n: nat,estimate: nat,root: nat,scale: nat)
    requires estimate>=root && estimate>0 && scale<=root && F.IsRoot(n,root)
    ensures Next(n,estimate)>=root
    ensures 2*scale*(Next(n,estimate)-root)<=
            (estimate-root)*(estimate-root)+2*scale
  {
    Lower(n,estimate,root); Error(n,estimate,root);
    var error: nat:=Next(n,estimate)-root;
    var square: nat:=(estimate-root)*(estimate-root);
    ScaledError(root,estimate,scale,error,square);
  }

  lemma Final(n: nat,estimate: nat,root: nat)
    requires estimate>=root && estimate>0 && F.IsRoot(n,root)
    requires (estimate-root)*(estimate-root)<2*root
    ensures root<=Next(n,estimate)<=root+1
  {
    Lower(n,estimate,root); ErrorAfterLower(n,estimate,root,root);
    var before: nat:=estimate-root;
    assert before*before>=0 && root>0;
    var after: nat:=Next(n,estimate)-root;
    if after>=2 {
      ProductOrder(2,after,2*root);
      assert 4*root<=2*root*after;
      assert false;
    }
    assert after<2;
  }

  lemma Correct(n: nat,estimate: nat,root: nat)
    requires estimate>0 && root<=estimate<=root+1 && F.IsRoot(n,root)
    ensures estimate-(if estimate>n/estimate then 1 else 0)==root
  {
    NextDefinition(n,estimate);
    if estimate==root {
      QuotientAtLeast(n,estimate,root);
    } else {
      assert estimate==root+1 && n<estimate*estimate;
      QuotientUpper(n,estimate,estimate-1);
      assert n/estimate<estimate;
    }
  }
  lemma Cancel(left: nat,right: nat,factor: nat)
    requires factor>0 && left*factor<=right*factor
    ensures left<=right
  {
    if left>right {
      ProductOrder(right+1,left,factor);
      assert right*factor<(right+1)*factor;
    }
  }

  lemma SquareInterval(value: int,bound: nat)
    requires -(bound as int)<=value<=bound
    ensures value*value<=bound*bound
  {
    var left: int:=(bound as int)-value;
    var right: int:=(bound as int)+value;
    assert 0<=left && 0<=right;
    assert 0<=left*right;
    assert (bound as int)*bound-value*value==left*right;
  }

  lemma RootFromScale(n: nat,root: nat,scale: nat)
    requires F.IsRoot(n,root) && scale*scale<=n<4*scale*scale
    ensures scale<=root<2*scale
  {
    if root<scale { F.SquareOrder(root+1,scale); }
    else if root>=2*scale { F.SquareOrder(2*scale,root); }
  }

  lemma InitialError(n: nat,root: nat,scale: nat)
    requires F.IsRoot(n,root) && scale>=2 && scale%2==0
    requires scale*scale<=n<4*scale*scale
    ensures Next(n,3*scale/2)>=root
    ensures 12*(Next(n,3*scale/2)-root)<=scale+16
  {
    RootFromScale(n,root,scale);
    var estimate:=3*scale/2;
    assert 2*estimate==3*scale && estimate>0;
    Lower(n,estimate,root); Error(n,estimate,root);
    var difference: int:=(estimate as int)-root;
    assert -(scale as int)<=2*difference<=scale;
    SquareInterval(2*difference,scale);
    assert 4*difference*difference<=scale*scale;
    assert 12*scale*(Next(n,estimate)-root)<=scale*scale+16*scale;
    Cancel(12*(Next(n,estimate)-root),scale+16,scale);
  }

  // This integer invariant bounds the excess above the mathematical floor root.
  // No real-root approximation or library correctness assertion is assumed.
  lemma Refine(n: nat,estimate: nat,root: nat,scale: nat,denominator: nat)
    requires F.IsRoot(n,root) && scale>=4 && scale<=root<=estimate
    requires denominator>=4 && denominator*(estimate-root)<=scale+2*denominator
    ensures Next(n,estimate)>=root
    ensures (3*denominator*denominator/2)*(Next(n,estimate)-root)<=
            scale+2*(3*denominator*denominator/2)
  {
    ErrorAfterLower(n,estimate,root,scale);
    var before:=estimate-root;
    var after:=Next(n,estimate)-root;
    F.SquareOrder(denominator*before,scale+2*denominator);
    assert denominator*denominator*before*before<=
           scale*scale+4*scale*denominator+4*denominator*denominator;
    var nextDenominator:=3*denominator*denominator/2;
    assert nextDenominator>0 && nextDenominator<=2*denominator*denominator;
    ProductOrder(2*scale*after,before*before+2*scale,denominator*denominator);
    assert 4*denominator<=denominator*denominator;
    ProductOrder(4*denominator,denominator*denominator,scale);
    ProductOrder(4,scale,denominator*denominator);
    assert 4*scale*denominator+4*denominator*denominator<=
           2*scale*denominator*denominator;
    assert 2*scale*denominator*denominator*after<=
           scale*scale+4*scale*denominator*denominator;
    ProductOrder(2*scale*denominator*denominator*after,
                 scale*scale+4*scale*denominator*denominator,nextDenominator);
    ProductOrder(nextDenominator,2*denominator*denominator,scale*scale);
    calc {
       2*scale*denominator*denominator*(nextDenominator*after);
    == nextDenominator*(2*scale*denominator*denominator*after);
    <= nextDenominator*(scale*scale+4*scale*denominator*denominator);
    == nextDenominator*scale*scale+4*scale*denominator*denominator*nextDenominator;
    <= 2*denominator*denominator*scale*scale+4*scale*denominator*denominator*nextDenominator;
    == 2*scale*denominator*denominator*(scale+2*nextDenominator);
    }
    Cancel(nextDenominator*after,scale+2*nextDenominator,
           2*scale*denominator*denominator);
  }

  const D1: nat := 12
  const D2: nat := 216
  const D3: nat := 69984
  const D4: nat := 7346640384
  const D5: nat := 80959687397729501184

  lemma CancelStrict(left: nat,right: nat,factor: nat)
    requires factor>0 && left*factor<right*factor
    ensures left<right
  {
    if left>=right {
      ProductOrder(right,left,factor);
      assert false;
    }
  }

  lemma LastError(scale: nat,error: nat)
    requires 16<=scale<=F.Limit/2 && D5*error<=scale+2*D5
    ensures error*error<2*scale
  {
    F.SquareOrder(D5*error,scale+2*D5);
    ProductOrder(scale,F.Limit/2,scale);
    ProductOrder(16,scale,D5*D5);
    assert 4*(scale+2*D5)*(scale+2*D5)<=
           scale*(4*(F.Limit/2)+16*D5+D5*D5);
    assert 4*(F.Limit/2)+16*D5+D5*D5<8*D5*D5;
    assert 4*D5*D5*error*error<8*scale*D5*D5;
    var factor: nat:=4*D5*D5;
    assert D5==80959687397729501184 && factor>0;
    calc {
       (error*error)*factor;
    == 4*D5*D5*error*error;
    < 8*scale*D5*D5;
    == (2*scale)*factor;
    }
    CancelStrict(error*error,2*scale,factor);
  }

  lemma SixSteps(n: nat,root: nat,scale: nat)
    requires n>=2 // Already implied by scale>=16 and scale*scale<=n.
    requires F.IsRoot(n,root) && 16<=scale<=F.Limit/2 && scale%2==0
    requires scale*scale<=n<4*scale*scale
    ensures var first:=Next(n,3*scale/2);
            var second:=Next(n,first);
            var third:=Next(n,second);
            var fourth:=Next(n,third);
            var fifth:=Next(n,fourth);
            root<=Next(n,fifth)<=root+1
  {
    RootFromScale(n,root,scale); InitialError(n,root,scale);
    var first:=Next(n,3*scale/2);
    assert D1*(first-root)<=scale+2*D1;
    Refine(n,first,root,scale,D1);
    var second:=Next(n,first);
    assert 3*D1*D1/2==D2;
    Refine(n,second,root,scale,D2);
    var third:=Next(n,second);
    assert 3*D2*D2/2==D3;
    Refine(n,third,root,scale,D3);
    var fourth:=Next(n,third);
    assert 3*D3*D3/2==D4;
    Refine(n,fourth,root,scale,D4);
    var fifth:=Next(n,fourth);
    assert 3*D4*D4/2==D5;
    LastError(scale,fifth-root);
    assert (fifth-root)*(fifth-root)<2*root;
    Final(n,fifth,root);
  }

  lemma QuotientUpper(n: nat,divisor: nat,maximum: nat)
    requires divisor>0 && n<(maximum+1)*divisor
    ensures n/divisor<=maximum
  {
    if n/divisor>maximum {
      ProductOrder(maximum+1,n/divisor,divisor);
      assert (n/divisor)*divisor<=n;
    }
  }

  lemma TightStep(n: nat,estimate: nat,root: nat)
    requires F.IsRoot(n,root) && root>=1 && estimate>=root
    ensures root<=Next(n,estimate)
    ensures Next(n,estimate)<=if estimate>=root+2 then estimate-1 else root+1
  {
    NextDefinition(n,estimate);
    Lower(n,estimate,root);
    if estimate>=root+2 {
      F.SquareOrder(root+1,estimate-1);
      assert n<(estimate-1)*(estimate-1)<(estimate-1)*estimate;
      QuotientUpper(n,estimate,estimate-2);
    } else if estimate==root+1 {
      assert n<estimate*estimate;
      QuotientUpper(n,estimate,estimate-1);
    } else {
      assert estimate==root && n<=root*root+2*root;
      assert n<(root+3)*root;
      QuotientUpper(n,estimate,root+2);
    }
  }

  lemma SmallSteps(n: nat,root: nat,scale: nat)
    requires n>=2 && F.IsRoot(n,root) && 1<=scale<16
    requires scale==1 || scale%2==0
    requires scale*scale<=n<4*scale*scale
    ensures var first:=Next(n,3*scale/2);
            var second:=Next(n,first);
            var third:=Next(n,second);
            var fourth:=Next(n,third);
            var fifth:=Next(n,fourth);
            root<=Next(n,fifth)<=root+1
  {
    NextDefinition(n,3*scale/2);
    RootFromScale(n,root,scale);
    var first:=Next(n,3*scale/2);
    if scale==1 {
      assert 2<=n<=3 && root==1;
      assert first<=root+1;
    } else {
      InitialError(n,root,scale);
      assert first<=root+2;
    }
    TightStep(n,first,root); var second:=Next(n,first);
    assert second<=root+1;
    TightStep(n,second,root); var third:=Next(n,second);
    TightStep(n,third,root); var fourth:=Next(n,third);
    TightStep(n,fourth,root); var fifth:=Next(n,fourth);
    TightStep(n,fifth,root);
  }

}
