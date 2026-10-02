include "Intervals.dfy"
module OperationsFixedPointAccuracyKernel {
  import B = OperationsBinaryLogModel
  import M = OperationsFixedPointModel
  import A = OperationsFixedPointBounds
  import K = OperationsFixedPointAccuracyBridge
  import R = OperationsFixedPointAccuracySeries
  import I = OperationsFixedPointAccuracyIntervals
  import S = OperationsFixedPointAccuracySpec
  ghost function Horner(x: real,seed: real,coefficients: seq<int>): real
    decreases |coefficients|
  {
    if |coefficients| == 0 then seed else
    Horner(x,x*seed/(M.Q96 as real)+(coefficients[0] as real),coefficients[1..])
  }
  ghost predicate HornerNoWrap(x: int,seed: int,coefficients: seq<int>)
    decreases |coefficients|
  {
    |coefficients| == 0 ||
    (M.Signed(x*seed) && M.Signed((x*seed)/M.Q96+coefficients[0]) &&
     HornerNoWrap(x,M.Step(x,seed,coefficients[0]),coefficients[1..]))
  }
  lemma HornerSeedPerturbation(x: real,a: real,b: real,coefficients: seq<int>)
    ensures R.Abs(Horner(x,a,coefficients)-Horner(x,b,coefficients)) ==
            R.Abs(a-b)*R.Power(R.Abs(x)/(M.Q96 as real),|coefficients|)
    decreases |coefficients|
  {
    if |coefficients| > 0 {
      var nextA := x*a/(M.Q96 as real)+(coefficients[0] as real);
      var nextB := x*b/(M.Q96 as real)+(coefficients[0] as real);
      HornerSeedPerturbation(x,nextA,nextB,coefficients[1..]);
      R.AbsProduct(x/(M.Q96 as real),a-b);
      assert nextA-nextB == x/(M.Q96 as real)*(a-b);
    }
  }
  lemma HornerQuantization(x: int,seed: int,coefficients: seq<int>,kappa: real)
    requires HornerNoWrap(x,seed,coefficients)
    requires 0.0 <= R.Abs(x as real)/(M.Q96 as real) <= kappa
    ensures R.Abs((M.Horner(x,seed,coefficients) as real)-Horner(x as real,seed as real,coefficients)) <=
            R.Geometric(kappa,|coefficients|)
    decreases |coefficients|
  {
    if |coefficients| > 0 {
      K.StepNoWrap(x,seed,coefficients[0]);
      var next := M.Step(x,seed,coefficients[0]);
      var exact := (x as real)*(seed as real)/(M.Q96 as real)+(coefficients[0] as real);
      HornerQuantization(x,next,coefficients[1..],kappa);
      HornerSeedPerturbation(x as real,next as real,exact,coefficients[1..]);
      I.PowerMonotone(R.Abs(x as real)/(M.Q96 as real),kappa,|coefficients|-1);
      R.PowerNonnegative(kappa,|coefficients|-1);
      R.Triangle((M.Horner(x,next,coefficients[1..]) as real)-Horner(x as real,next as real,coefficients[1..]),
                 Horner(x as real,next as real,coefficients[1..])-Horner(x as real,exact,coefficients[1..]));
    }
  }
  lemma ProductPerturbation(a: real,b: real,a0: real,b0: real,da: real,db: real)
    requires R.Abs(a-a0) <= da && R.Abs(b-b0) <= db && da >= 0.0 && db >= 0.0
    ensures R.Abs(a*b-a0*b0) <= da*R.Abs(b0)+db*R.Abs(a0)+da*db
  {
    var x := a-a0; var y := b-b0;
    assert a*b-a0*b0 == x*b0+y*a0+x*y;
    R.AbsProduct(x,b0); R.AbsProduct(y,a0); R.AbsProduct(x,y);
    R.Triangle(x*b0,y*a0); R.Triangle(x*b0+y*a0,x*y);
  }
  lemma QuotientPerturbation(p: real,q: real,p0: real,q0: real,dp: real,dq: real,pmax: real,qmin: real)
    requires q >= qmin > 0.0 && q0 >= qmin
    requires dp >= 0.0 && dq >= 0.0 && pmax >= 0.0
    requires R.Abs(p-p0) <= dp && R.Abs(q-q0) <= dq && R.Abs(p0) <= pmax
    ensures R.Abs(p/q-p0/q0) <= dp/qmin+pmax*dq/(qmin*qmin)
  {
    assert p/q-p0/q0 == (p-p0)/q+p0*(q0-q)/(q*q0);
    R.Triangle((p-p0)/q,p0*(q0-q)/(q*q0));
    R.AbsProduct(p0,q0-q);
    assert q*q0 >= qmin*qmin;
  }
  ghost function ExpCoefficients(): seq<int> {
    [50020603652535783019961831881945,-533845033583426703283633433725380,
     3604857256930695427073651918091429,-14423608567350463180887372962807573,
     26449188498355588339934803723976023]
  }
  ghost function LnCoefficients(): seq<int> {
    [71694874799317883764090561454958,283447036172924575727196451306956,
     401686690394027663651624208769553,204048457590392012362485061816622,
     31853899698501571402653359427138,909429971244387300277376558375]
  }
  ghost function ExpDenominator(x: real): real { Horner(x,x-2855989394907223263936484059900.0,ExpCoefficients()) }
  ghost function ExpNumerator(x: real): real {
    var y := (x+1346386616545796478920950773328.0)*x/(M.Q96 as real)+57155421227552351082224309758442.0;
    var p := (y+x-94201549194550492254356042504812.0)*y/(M.Q96 as real)+28719021644029726153956944680412240.0;
    p*x+4385272521454847904659076985693276.0*(M.Q96 as real)
  }
  ghost function LnDenominator(x: real): real { Horner(x,x+5573035233440673466300451813936.0,LnCoefficients()) }
  ghost function LnNumerator(x: real): real {
    var p := Horner(x,x+3273285459638523848632254066296.0,
                    [24828157081833163892658089445524,43456485725739037958740375743393,
                     -11111509109440967052023855526967,-45023709667254063763336534515857,
                     -14706773417378608786704636184526]);
    p*x-795164235651350426258249787498.0*(M.Q96 as real)
  }
  ghost function ExpBase(x: real): real
    requires ExpDenominator(x) > 0.0
  { ExpNumerator(x)/ExpDenominator(x)*(K.ExpMultiplier as real)/(B.Power(195) as real)/S.Wad }
  ghost function LnBase(x: real): real
    requires LnDenominator(x) > 0.0
  { LnNumerator(x)/LnDenominator(x)*(K.LnMultiplier as real)/(B.Power(174) as real)/S.Wad }
  ghost predicate ExpBasePoint(x: real,e: real) { R.ExpPoint(x/(M.Q96 as real),e) }
  ghost predicate LnBasePoint(x: real,l: real) { R.LnPoint(x/(M.Q96 as real),l) }
  ghost predicate ExpRealDenominatorPositive() {
    forall x: real :: -(M.Ln2 as real) <= x <= M.Ln2 as real ==> ExpDenominator(x) > 0.0
  }
  ghost predicate LnRealDenominatorPositive() {
    forall x: real :: (M.Q96 as real) <= x <= 2.0*(M.Q96 as real) ==> LnDenominator(x) > 0.0
  }
  // Separate universal certificate goals: neither is an assumed theorem.
  ghost predicate ExpBaseCertificate(relative: real,absolute: real) {
    relative >= 0.0 && absolute >= 0.0 && ExpRealDenominatorPositive() &&
    forall x: real,e: real :: -(M.Ln2 as real) <= x <= M.Ln2 as real && ExpBasePoint(x,e) ==>
                                ExpDenominator(x) > 0.0 && R.Abs(ExpBase(x)-e) <= absolute+relative*e
  }
  ghost predicate LnBaseCertificate(absolute: real) {
    absolute >= 0.0 && LnRealDenominatorPositive() &&
    forall x: real,l: real :: (M.Q96 as real) <= x <= 2.0*(M.Q96 as real) && LnBasePoint(x,l) ==>
                                LnDenominator(x) > 0.0 && R.Abs(LnBase(x)-l) <= absolute
  }
  lemma ExpDenominatorQuantization(x: int,kappa: real)
    requires M.Signed(x-2855989394907223263936484059900)
    requires HornerNoWrap(x,x-2855989394907223263936484059900,ExpCoefficients())
    requires R.Abs(x as real)/(M.Q96 as real) <= kappa
    ensures R.Abs((M.ExpDenominator(x) as real)-ExpDenominator(x as real)) <= R.Geometric(kappa,5)
  {
    A.Identity(x-2855989394907223263936484059900);
    HornerQuantization(x,x-2855989394907223263936484059900,ExpCoefficients(),kappa);
  }
  lemma LnDenominatorQuantization(x: int,kappa: real)
    requires M.Signed(x+5573035233440673466300451813936)
    requires HornerNoWrap(x,x+5573035233440673466300451813936,LnCoefficients())
    requires R.Abs(x as real)/(M.Q96 as real) <= kappa
    ensures R.Abs((M.LnDenominator(x) as real)-LnDenominator(x as real)) <= R.Geometric(kappa,6)
  {
    A.Identity(x+5573035233440673466300451813936);
    HornerQuantization(x,x+5573035233440673466300451813936,LnCoefficients(),kappa);
  }
}
