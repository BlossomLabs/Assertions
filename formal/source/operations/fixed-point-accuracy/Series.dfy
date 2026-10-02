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
  lemma MultiplyOrder(a: real,b: real,c: real)
    requires a <= b && c >= 0.0
    ensures a*c <= b*c
  { assert (b-a)*c >= 0.0; assert b*c-a*c == (b-a)*c; }
  lemma DivideOrder(a: real,b: real,d: real)
    requires a <= b && d > 0.0
    ensures a/d <= b/d
  { assert (b-a)/d >= 0.0; assert b/d-a/d == (b-a)/d; }
  lemma DivideProduct(a: real,b: real,c: real)
    requires b != 0.0 && c != 0.0
    ensures a/(b*c) == a/b/c
  { assert (a/(b*c))*(b*c) == a; assert (a/b/c)*(b*c) == a; }
  lemma DivideScale(a: real,b: real,c: real)
    requires b != 0.0
    ensures (a/b)*c == (a*c)/b
  { assert ((a/b)*c)*b == a*c; }
  lemma AbsQuotient(x: real,d: real)
    requires d > 0.0
    ensures Abs(x/d) == Abs(x)/d
  { if x < 0.0 { } }
  lemma DivideIdentity(d: real)
    requires d > 0.0
    ensures (d/2.0)/d == 0.5
    ensures (d/3.0)/d == 1.0/3.0
  { }
  lemma DivideDenominator(a: real,b: real,c: real)
    requires a >= 0.0 && 0.0 < b <= c
    ensures a/c <= a/b
  {
    assert 1.0/c <= 1.0/b;
    MultiplyOrder(1.0/c,1.0/b,a);
    assert a/c == a*(1.0/c);
    assert a/b == a*(1.0/b);
  }
  lemma WeightedBound(a: real,b: real,c: real,d: real)
    requires 0.0 <= a <= b && 0.0 <= c <= d
    ensures a*c <= b*d
  { MultiplyOrder(a,b,c); MultiplyOrder(c,d,b); }
  lemma ProductDivide(a: real,b: real,d: real)
    requires d != 0.0
    ensures (a*b)/d == a*(b/d)
  { DivideScale(b,d,a); assert a*b == b*a; }
  lemma SumOrder(a: real,b: real,c: real,d: real)
    requires a <= b && c <= d
    ensures a+c <= b+d
  { }
  lemma CancelEquality(a: real,b: real,d: real)
    requires d != 0.0 && a*d == b*d
    ensures a == b
  { CancelProduct(a,d); CancelProduct(b,d); }
  lemma DivideSum(a: real,b: real,d: real)
    requires d != 0.0
    ensures (a+b)/d == a/d+b/d
  { assert ((a+b)/d)*d == a+b; assert (a/d+b/d)*d == a+b; CancelEquality((a+b)/d,a/d+b/d,d); }
  lemma DivideStrict(a: real,b: real,d: real)
    requires a < b && d > 0.0
    ensures a/d < b/d
  { assert (b-a)/d > 0.0; assert b/d-a/d == (b-a)/d; }
  lemma MultiplyStrict(a: real,b: real,c: real)
    requires a < b && c > 0.0
    ensures a*c < b*c
  { assert (b-a)*c > 0.0; assert b*c-a*c == (b-a)*c; }
  lemma AffineFractionDifference(a: real,b: real,c: real,offset: real,d: real)
    requires d != 0.0
    ensures (a*c+offset)/d-(b*c+offset)/d == (a-b)*(c/d)
  {
    DivideSum(a*c,offset,d); DivideSum(b*c,offset,d);
    ProductDivide(a,c,d); ProductDivide(b,c,d);
    assert a*(c/d)-b*(c/d) == (a-b)*(c/d);
  }
  lemma QuotientDifference(p: real,q: real,p0: real,q0: real)
    requires q > 0.0 && q0 > 0.0
    ensures p/q-p0/q0 == (p-p0)/q+p0*(q0-q)/(q*q0)
  {
    DivideProduct(p0*(q0-q),q,q0);
    ProductDivide(p0,q0-q,q);
    assert ((p/q-p0/q0)*q)*q0 == p*q0-p0*q;
    assert (((p-p0)/q+p0*(q0-q)/(q*q0))*q)*q0 == p*q0-p0*q;
    var left := p/q-p0/q0;
    var right := (p-p0)/q+p0*(q0-q)/(q*q0);
    CancelEquality(left*q,right*q,q0);
    CancelEquality(left,right,q);
  }
  lemma AbsNeg(x: real)
    ensures Abs(-x) == Abs(x)
  { if x < 0.0 { } }
  lemma CancelProduct(a: real,b: real)
    requires b != 0.0
    ensures a*b/b == a
  { assert (a*b/b)*b == a*b; }
  lemma PositiveSquare(x: real)
    requires x > 0.0
    ensures x*x != 0.0 && x*x > 0.0
  {
    CancelProduct(x,x);
    var square := x*x;
    assert square/x == x;
    if square == 0.0 { assert square/x == 0.0; }
    assert square != 0.0;
    assert square >= 0.0;
    assert square > 0.0;
  }
  lemma AbsProduct(x: real,y: real)
    ensures Abs(x*y) == Abs(x)*Abs(y)
  { if x < 0.0 { if y < 0.0 { } } else { if y < 0.0 { } } }
  lemma AbsProductBound(a: real,b: real,da: real,db: real)
    requires Abs(a) <= da && Abs(b) <= db
    requires da >= 0.0 && db >= 0.0
    ensures Abs(a*b) <= da*db
  {
    AbsProduct(a,b);
    WeightedBound(Abs(a),da,Abs(b),db);
  }
  lemma AbsQuotientBound(a: real,d: real,bound: real)
    requires d > 0.0 && Abs(a) <= bound
    ensures Abs(a/d) <= bound/d
  { AbsQuotient(a,d); DivideOrder(Abs(a),bound,d); }
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
    if n > 0 { GeometricBound(q,n-1); PowerNonnegative(q,n-1); }
    assert 1.0-q > 0.0;
    assert Geometric(q,n) == (1.0-Power(q,n))/(1.0-q);
    assert 1.0/(1.0-q)-Geometric(q,n) == Power(q,n)/(1.0-q);
    DivideOrder(0.0,Power(q,n),1.0-q);
    assert Geometric(q,n) <= 1.0/(1.0-q);
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
      assert Power(t,i) == t*Power(t,i-1);
      assert Factorial(i) == i*Factorial(i-1);
      assert (Factorial(i) as real) == (i as real)*(Factorial(i-1) as real);
      assert ExpTerm(t,i) == Power(t,i)/((Factorial(i-1) as real)*(i as real));
      DivideProduct(Power(t,i),(Factorial(i-1) as real),(i as real));
      DivideScale(Power(t,i-1),(Factorial(i-1) as real),t);
      assert ExpTerm(t,i) == ExpTerm(t,i-1)*t/(i as real);
      assert 2.0*Abs(t) <= i as real;
      DivideOrder(Abs(t),(i as real)/2.0,i as real);
      DivideIdentity(i as real);
      assert 0.0 <= Abs(t)/(i as real) <= 0.5;
      AbsQuotient(ExpTerm(t,i-1)*t,i as real);
      assert Abs(ExpTerm(t,i-1)*t) == Abs(ExpTerm(t,i-1))*Abs(t);
      assert Abs(ExpTerm(t,i)) == Abs(ExpTerm(t,i-1))*Abs(t)/(i as real);
      ProductDivide(Abs(ExpTerm(t,i-1)),Abs(t),i as real);
      PowerNonnegative(0.5,offset-1);
      assert Abs(ExpTerm(t,i-1)) >= 0.0;
      assert Abs(ExpTerm(t,start)) >= 0.0;
      MultiplyOrder(Abs(t)/(i as real),0.5,Abs(ExpTerm(t,i-1)));
      var previous := Abs(ExpTerm(t,i-1));
      var first := Abs(ExpTerm(t,start));
      var power := Power(0.5,offset-1);
      var rate := Abs(t)/(i as real);
      var actual := Abs(ExpTerm(t,i));
      assert actual == previous*rate;
      assert previous >= 0.0 && rate <= 0.5;
      MultiplyOrder(rate,0.5,previous);
      assert actual <= previous*0.5;
      assert previous <= first*power;
      MultiplyOrder(previous,first*power,0.5);
      assert actual <= first*power*0.5;
      assert Power(0.5,offset) == 0.5*power;
      assert actual <= first*Power(0.5,offset);
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
    {
      ExpTailSegment(t,start,n-start); GeometricBound(0.5,n-start);
      assert start+(n-start) == n;
      assert Abs(ExpTerm(t,start)) >= 0.0;
      assert Geometric(0.5,n-start) <= 2.0;
      MultiplyOrder(Geometric(0.5,n-start),2.0,Abs(ExpTerm(t,start)));
      assert Abs(ExpTerm(t,start))*Geometric(0.5,n-start) <= 2.0*Abs(ExpTerm(t,start));
      assert ExpRadius(t,start) == 2.0*Abs(ExpTerm(t,start));
      assert Abs(ExpSum(t,n)-ExpSum(t,start)) <= Abs(ExpTerm(t,start))*Geometric(0.5,n-start);
      assert Abs(ExpSum(t,n)-ExpSum(t,start)) <= ExpRadius(t,start);
    }
  }
  lemma ExpLimitEnclosure(t: real,start: nat,e: real)
    requires ExpLimit(t,e)
    requires 2.0*Abs(t) <= (start+1) as real
    ensures Abs(e-ExpSum(t,start)) <= ExpRadius(t,start)
  {
    ExpFiniteTail(t,start);
    if Abs(e-ExpSum(t,start)) > ExpRadius(t,start) {
      var delta := (Abs(e-ExpSum(t,start))-ExpRadius(t,start))/2.0;
      assert delta > 0.0;
      assert ExpEventual(t,e,delta);
      var cutoff: nat :| ExpAfter(t,e,delta,cutoff);
      var n := if cutoff < start then start else cutoff;
      assert ExpWithin(t,e,delta,n);
      assert Abs(e-ExpSum(t,n)) == Abs(ExpSum(t,n)-e);
      assert Abs(ExpSum(t,n)-ExpSum(t,start)) <= ExpRadius(t,start);
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
      assert i > 0;
      assert 2*(i-1)+1 == 2*i-1;
      assert Power(z,2*i+1) == z*Power(z,2*i);
      assert Power(z,2*i) == z*Power(z,2*i-1);
      assert AtanhTerm(z,i) == AtanhTerm(z,i-1)*z*z*((2*i-1) as real)/((2*i+1) as real);
      AbsProduct(AtanhTerm(z,i-1),z*z);
      assert 0.0 <= ((2*i-1) as real)/((2*i+1) as real) <= 1.0;
      assert Abs(AtanhTerm(z,i)) == Abs(AtanhTerm(z,i-1))*z*z*((2*i-1) as real)/((2*i+1) as real);
      PowerNonnegative(z*z,offset-1);
      assert z*z >= 0.0;
      assert Abs(AtanhTerm(z,i-1)) >= 0.0;
      assert Abs(AtanhTerm(z,start)) >= 0.0;
      DivideScale((2*i-1) as real,(2*i+1) as real,Abs(AtanhTerm(z,i-1))*z*z);
      MultiplyOrder(((2*i-1) as real)/((2*i+1) as real),1.0,Abs(AtanhTerm(z,i-1))*z*z);
      assert Abs(AtanhTerm(z,i)) <= Abs(AtanhTerm(z,i-1))*z*z;
      var previous := Abs(AtanhTerm(z,i-1));
      var first := Abs(AtanhTerm(z,start));
      var power := Power(z*z,offset-1);
      var rate := z*z;
      var actual := Abs(AtanhTerm(z,i));
      assert previous <= first*power;
      assert actual <= previous*rate;
      MultiplyOrder(previous,first*power,rate);
      assert actual <= first*power*rate;
      assert Power(rate,offset) == rate*power;
      assert actual <= first*Power(rate,offset);
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
      assert AtanhSum(z,start+length) == AtanhSum(z,start+length-1)+AtanhTerm(z,start+length-1);
      assert Geometric(z*z,length) == Geometric(z*z,length-1)+Power(z*z,length-1);
      assert Abs(AtanhTerm(z,start)) >= 0.0;
      assert Abs(AtanhSum(z,start+length)-AtanhSum(z,start)) <=
             Abs(AtanhSum(z,start+length-1)-AtanhSum(z,start))+Abs(AtanhTerm(z,start+length-1));
      assert Abs(AtanhSum(z,start+length-1)-AtanhSum(z,start)) <= Abs(AtanhTerm(z,start))*Geometric(z*z,length-1);
      assert Abs(AtanhTerm(z,start+length-1)) <= Abs(AtanhTerm(z,start))*Power(z*z,length-1);
      var segment := Abs(AtanhSum(z,start+length-1)-AtanhSum(z,start));
      var term := Abs(AtanhTerm(z,start+length-1));
      var first := Abs(AtanhTerm(z,start));
      var previousGeometric := Geometric(z*z,length-1);
      var previousPower := Power(z*z,length-1);
      assert segment <= first*previousGeometric;
      assert term <= first*previousPower;
      assert Abs(AtanhSum(z,start+length)-AtanhSum(z,start)) <= segment+term;
      SumOrder(segment,first*previousGeometric,term,first*previousPower);
      assert segment+term <= first*previousGeometric+first*previousPower;
      assert first*Geometric(z*z,length) == first*previousGeometric+first*previousPower;
      var actual := Abs(AtanhSum(z,start+length)-AtanhSum(z,start));
      var bound := first*Geometric(z*z,length);
      assert actual <= segment+term;
      assert bound == first*previousGeometric+first*previousPower;
      assert actual <= bound;
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
      assert delta > 0.0;
      assert AtanhEventual(z,l,delta);
      var cutoff: nat :| AtanhAfter(z,l,delta,cutoff);
      var n := if cutoff < start then start else cutoff;
      assert AtanhWithin(z,l,delta,n);
      assert Abs(l-AtanhSum(z,n)) == Abs(AtanhSum(z,n)-l);
      assert Abs(AtanhSum(z,n)-AtanhSum(z,start)) <= AtanhRadius(z,start);
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
      assert epsilon > 0.0;
      assert ExpEventual(t,a,epsilon);
      assert ExpEventual(t,b,epsilon);
      var startA: nat :| ExpAfter(t,a,epsilon,startA);
      var startB: nat :| ExpAfter(t,b,epsilon,startB);
      var n := if startA < startB then startB else startA;
      assert ExpWithin(t,a,epsilon,n);
      assert ExpWithin(t,b,epsilon,n);
      assert Abs(a-ExpSum(t,n)) == Abs(ExpSum(t,n)-a);
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
      assert epsilon > 0.0;
      assert AtanhEventual(z,a,epsilon);
      assert AtanhEventual(z,b,epsilon);
      var startA: nat :| AtanhAfter(z,a,epsilon,startA);
      var startB: nat :| AtanhAfter(z,b,epsilon,startB);
      var n := if startA < startB then startB else startA;
      assert AtanhWithin(z,a,epsilon,n);
      assert AtanhWithin(z,b,epsilon,n);
      assert Abs(a-AtanhSum(z,n)) == Abs(AtanhSum(z,n)-a);
      Triangle(a-AtanhSum(z,n),AtanhSum(z,n)-b);
      assert Abs(a-b) < 2.0*epsilon;
    }
  }
}
