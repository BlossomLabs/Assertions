module OperationsFixedPointAccuracySeries {
  ghost function Abs(x: real): real { if x < 0.0 then -x else x }
  ghost function Power(x: real,n: nat): real
    decreases n
  { if n == 0 then 1.0 else x*Power(x,n-1) }
  ghost function Factorial(n: nat): nat
    ensures Factorial(n) > 0
    decreases n
  { if n == 0 then 1 else n*Factorial(n-1) }
  // n is the number of terms; term n is the first omitted term.
  ghost function ExpTerm(t: real,i: nat): real { Power(t,i)/(Factorial(i) as real) }
  ghost function ExpSum(t: real,n: nat): real
    decreases n
  { if n == 0 then 0.0 else ExpSum(t,n-1)+ExpTerm(t,n-1) }
  ghost predicate ExpWithin(t: real,e: real,epsilon: real,n: nat) { Abs(ExpSum(t,n)-e) < epsilon }
  ghost predicate ExpAfter(t: real,e: real,epsilon: real,start: nat) {
    forall n: nat :: n >= start ==> ExpWithin(t,e,epsilon,n)
  }
  ghost predicate ExpEventual(t: real,e: real,epsilon: real) {
    exists start: nat :: ExpAfter(t,e,epsilon,start)
  }
  ghost predicate ExpLimit(t: real,e: real) {
    forall epsilon: real :: epsilon > 0.0 ==> ExpEventual(t,e,epsilon)
  }
  // This is a series characterization, not an uninterpreted exp oracle.
  // Existence/positivity and identification with standard real exp remain open.
  ghost predicate ExpPoint(t: real,e: real) { e > 0.0 && ExpLimit(t,e) }
  ghost function ExpRadius(t: real,n: nat): real { 2.0*Abs(ExpTerm(t,n)) }
  ghost function AtanhTerm(z: real,i: nat): real { 2.0*Power(z,2*i+1)/((2*i+1) as real) }
  ghost function AtanhSum(z: real,n: nat): real
    decreases n
  { if n == 0 then 0.0 else AtanhSum(z,n-1)+AtanhTerm(z,n-1) }
  ghost predicate AtanhWithin(z: real,l: real,epsilon: real,n: nat) { Abs(AtanhSum(z,n)-l) < epsilon }
  ghost predicate AtanhAfter(z: real,l: real,epsilon: real,start: nat) {
    forall n: nat :: n >= start ==> AtanhWithin(z,l,epsilon,n)
  }
  ghost predicate AtanhEventual(z: real,l: real,epsilon: real) {
    exists start: nat :: AtanhAfter(z,l,epsilon,start)
  }
  ghost predicate AtanhLimit(z: real,l: real) {
    forall epsilon: real :: epsilon > 0.0 ==> AtanhEventual(z,l,epsilon)
  }
  ghost function LogArgument(y: real): real
    requires y > 0.0
  { (y-1.0)/(y+1.0) }
  ghost predicate LnPoint(y: real,l: real) {
    y > 0.0 && AtanhLimit(LogArgument(y),l)
  }
  ghost function AtanhRadius(z: real,n: nat): real
    requires -1.0 < z < 1.0
  { Abs(AtanhTerm(z,n))/(1.0-z*z) }
  ghost function Geometric(q: real,n: nat): real
    decreases n
  { if n == 0 then 0.0 else Geometric(q,n-1)+Power(q,n-1) }
  lemma AbsProduct(x: real,y: real)
    ensures Abs(x*y) == Abs(x)*Abs(y)
  { if x < 0.0 { if y < 0.0 { } } else { if y < 0.0 { } } }
  lemma Triangle(x: real,y: real)
    ensures Abs(x+y) <= Abs(x)+Abs(y)
  { if x+y < 0.0 { } else { } }
  lemma PowerNonnegative(x: real,n: nat)
    requires x >= 0.0
    ensures Power(x,n) >= 0.0
    decreases n
  { if n > 0 { PowerNonnegative(x,n-1); } }
  lemma PowerAbs(x: real,n: nat)
    ensures Abs(Power(x,n)) == Power(Abs(x),n)
    decreases n
  { if n > 0 { PowerAbs(x,n-1); AbsProduct(x,Power(x,n-1)); } }
  lemma GeometricIdentity(q: real,n: nat)
    ensures (1.0-q)*Geometric(q,n) == 1.0-Power(q,n)
    decreases n
  { if n > 0 { GeometricIdentity(q,n-1); } }
  lemma GeometricBound(q: real,n: nat)
    requires 0.0 <= q < 1.0
    ensures 0.0 <= Geometric(q,n) <= 1.0/(1.0-q)
    decreases n
  {
    GeometricIdentity(q,n); PowerNonnegative(q,n);
    if n > 0 { GeometricBound(q,n-1); }
  }
  lemma ExpTailTerm(t: real,start: nat,offset: nat)
    requires 2.0*Abs(t) <= (start+1) as real
    ensures Abs(ExpTerm(t,start+offset)) <= Abs(ExpTerm(t,start))*Power(0.5,offset)
    decreases offset
  {
    if offset > 0 {
      ExpTailTerm(t,start,offset-1);
      var i := start+offset;
      AbsProduct(ExpTerm(t,i-1),t);
      assert ExpTerm(t,i) == ExpTerm(t,i-1)*t/(i as real);
      assert 0.0 <= Abs(t)/(i as real) <= 0.5;
      assert Abs(ExpTerm(t,i)) == Abs(ExpTerm(t,i-1))*Abs(t)/(i as real);
      PowerNonnegative(0.5,offset-1);
    }
  }
  lemma ExpTailSegment(t: real,start: nat,length: nat)
    requires 2.0*Abs(t) <= (start+1) as real
    ensures Abs(ExpSum(t,start+length)-ExpSum(t,start)) <= Abs(ExpTerm(t,start))*Geometric(0.5,length)
    decreases length
  {
    if length > 0 {
      ExpTailSegment(t,start,length-1); ExpTailTerm(t,start,length-1);
      Triangle(ExpSum(t,start+length-1)-ExpSum(t,start),ExpTerm(t,start+length-1));
    }
  }
  lemma ExpFiniteTail(t: real,start: nat)
    requires 2.0*Abs(t) <= (start+1) as real
    ensures forall n: nat :: n >= start ==> Abs(ExpSum(t,n)-ExpSum(t,start)) <= ExpRadius(t,start)
  {
    forall n: nat | n >= start
      ensures Abs(ExpSum(t,n)-ExpSum(t,start)) <= ExpRadius(t,start)
    { ExpTailSegment(t,start,n-start); GeometricBound(0.5,n-start); }
  }
  lemma ExpLimitEnclosure(t: real,start: nat,e: real)
    requires ExpLimit(t,e)
    requires 2.0*Abs(t) <= (start+1) as real
    ensures Abs(e-ExpSum(t,start)) <= ExpRadius(t,start)
  {
    ExpFiniteTail(t,start);
    if Abs(e-ExpSum(t,start)) > ExpRadius(t,start) {
      var delta := (Abs(e-ExpSum(t,start))-ExpRadius(t,start))/2.0;
      var cutoff: nat :| ExpAfter(t,e,delta,cutoff);
      var n := if cutoff < start then start else cutoff;
      Triangle(e-ExpSum(t,n),ExpSum(t,n)-ExpSum(t,start));
      assert Abs(e-ExpSum(t,start)) < delta+ExpRadius(t,start);
    }
  }
  lemma AtanhTailTerm(z: real,start: nat,offset: nat)
    requires -1.0 < z < 1.0
    ensures Abs(AtanhTerm(z,start+offset)) <= Abs(AtanhTerm(z,start))*Power(z*z,offset)
    decreases offset
  {
    if offset > 0 {
      AtanhTailTerm(z,start,offset-1);
      var i := start+offset;
      assert AtanhTerm(z,i) == AtanhTerm(z,i-1)*z*z*((2*i-1) as real)/((2*i+1) as real);
      AbsProduct(AtanhTerm(z,i-1),z*z);
      assert 0.0 <= ((2*i-1) as real)/((2*i+1) as real) <= 1.0;
      assert Abs(AtanhTerm(z,i)) == Abs(AtanhTerm(z,i-1))*z*z*((2*i-1) as real)/((2*i+1) as real);
      PowerNonnegative(z*z,offset-1);
    }
  }
  lemma AtanhTailSegment(z: real,start: nat,length: nat)
    requires -1.0 < z < 1.0
    ensures Abs(AtanhSum(z,start+length)-AtanhSum(z,start)) <= Abs(AtanhTerm(z,start))*Geometric(z*z,length)
    decreases length
  {
    if length > 0 {
      AtanhTailSegment(z,start,length-1); AtanhTailTerm(z,start,length-1);
      Triangle(AtanhSum(z,start+length-1)-AtanhSum(z,start),AtanhTerm(z,start+length-1));
    }
  }
  lemma AtanhFiniteTail(z: real,start: nat)
    requires -1.0 < z < 1.0
    ensures forall n: nat :: n >= start ==> Abs(AtanhSum(z,n)-AtanhSum(z,start)) <= AtanhRadius(z,start)
  {
    forall n: nat | n >= start
      ensures Abs(AtanhSum(z,n)-AtanhSum(z,start)) <= AtanhRadius(z,start)
    { AtanhTailSegment(z,start,n-start); GeometricBound(z*z,n-start); }
  }
  lemma AtanhLimitEnclosure(z: real,start: nat,l: real)
    requires -1.0 < z < 1.0 && AtanhLimit(z,l)
    ensures Abs(l-AtanhSum(z,start)) <= AtanhRadius(z,start)
  {
    AtanhFiniteTail(z,start);
    if Abs(l-AtanhSum(z,start)) > AtanhRadius(z,start) {
      var delta := (Abs(l-AtanhSum(z,start))-AtanhRadius(z,start))/2.0;
      var cutoff: nat :| AtanhAfter(z,l,delta,cutoff);
      var n := if cutoff < start then start else cutoff;
      Triangle(l-AtanhSum(z,n),AtanhSum(z,n)-AtanhSum(z,start));
      assert Abs(l-AtanhSum(z,start)) < delta+AtanhRadius(z,start);
    }
  }
  lemma LogArgumentRange(y: real)
    requires y > 0.0
    ensures -1.0 < LogArgument(y) < 1.0
  { assert y+1.0 > 0.0; }
  lemma LnLimitEnclosure(y: real,start: nat,l: real)
    requires LnPoint(y,l)
    ensures Abs(l-AtanhSum(LogArgument(y),start)) <= AtanhRadius(LogArgument(y),start)
  { LogArgumentRange(y); AtanhLimitEnclosure(LogArgument(y),start,l); }
  lemma ExpLimitUnique(t: real,a: real,b: real)
    requires ExpLimit(t,a) && ExpLimit(t,b)
    ensures a == b
  {
    if a != b {
      var epsilon := Abs(a-b)/3.0;
      var startA: nat :| ExpAfter(t,a,epsilon,startA);
      var startB: nat :| ExpAfter(t,b,epsilon,startB);
      var n := if startA < startB then startB else startA;
      Triangle(a-ExpSum(t,n),ExpSum(t,n)-b);
      assert Abs(a-b) < 2.0*epsilon;
    }
  }
  lemma AtanhLimitUnique(z: real,a: real,b: real)
    requires AtanhLimit(z,a) && AtanhLimit(z,b)
    ensures a == b
  {
    if a != b {
      var epsilon := Abs(a-b)/3.0;
      var startA: nat :| AtanhAfter(z,a,epsilon,startA);
      var startB: nat :| AtanhAfter(z,b,epsilon,startB);
      var n := if startA < startB then startB else startA;
      Triangle(a-AtanhSum(z,n),AtanhSum(z,n)-b);
      assert Abs(a-b) < 2.0*epsilon;
    }
  }
}
