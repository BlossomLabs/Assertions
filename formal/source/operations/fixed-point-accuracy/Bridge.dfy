include "../fixed-point/Bounds.dfy"
include "Series.dfy"
module OperationsFixedPointAccuracyBridge {
  import B = OperationsBinaryLogModel
  import M = OperationsFixedPointModel
  import A = OperationsFixedPointBounds
  import R = OperationsFixedPointAccuracySeries
  const ExpMultiplier: int := 3822833074963236453042738258902158003155416615667
  const LnMultiplier: int := 1677202110996718588342820967067443963516166
  const LnExponentMultiplier: int := 16597577552685614221487285958193947469193820559219878177908093499208371
  const LnOffset: int := 600920179829731861736702779321621459595472258049074101567377883020018308
  lemma FloorError(a: int,d: int)
    requires d > 0
    ensures 0.0 <= (a as real)/(d as real)-((a/d) as real) < 1.0
  {
    assert a == (a/d)*d+a%d;
    assert 0 <= a%d < d;
    assert (a as real) == ((a/d) as real)*(d as real)+(a%d) as real;
  }
  lemma TruncError(a: int,d: int)
    requires d > 0
    ensures R.Abs((a as real)/(d as real)-(M.Trunc(a,d) as real)) < 1.0
  {
    if a < 0 { FloorError(-a,d); }
    else { FloorError(a,d); }
  }
  lemma TruncSigned(a: int,d: int)
    requires M.Signed(a) && d > 0
    ensures M.Signed(M.Trunc(a,d))
    ensures M.S(M.Trunc(a,d)) == M.Trunc(a,d)
  {
    A.TruncRemainder(a,d);
    if a < 0 {
      var magnitude := (-a)/d;
      assert -a == magnitude*d+(-a)%d;
      assert 0 <= magnitude <= -a;
    } else {
      assert a == (a/d)*d+a%d;
      assert 0 <= a/d <= a;
    }
    A.Identity(M.Trunc(a,d));
  }
  lemma StepNoWrap(x: int,y: int,c: int)
    requires M.Signed(x*y) && M.Signed((x*y)/M.Q96+c)
    ensures M.Step(x,y,c) == (x*y)/M.Q96+c
    ensures 0.0 <= (x as real)*(y as real)/(M.Q96 as real)+(c as real)-(M.Step(x,y,c) as real) < 1.0
  {
    A.Powers(); A.Identity(x*y); A.Identity((x*y)/M.Q96+c);
    FloorError(x*y,M.Q96);
  }
  lemma WordShiftAsFloor(product: int,n: nat)
    requires 0 <= product < B.Word
    ensures M.Shr(product,n) == product/B.Power(n)
  {
    B.KnownPowers();
    assert M.U(product) == product;
    if n >= 256 {
      B.PowerAdd(256,n-256);
      assert B.Power(n) >= B.Word;
      assert product/B.Power(n) == 0;
    }
  }
  // These are certificate conditions, not conclusions about all admitted inputs.
  ghost predicate ExpFinishNoWrap(r: int,k: int) {
    0 <= r && r*ExpMultiplier < B.Word &&
    0 <= 195-k < M.Half &&
    (r*ExpMultiplier)/B.Power((195-k) as nat) < M.Half
  }
  ghost function ExpFinishReal(r: real,k: int): real
    requires 195-k >= 0
  { r*(ExpMultiplier as real)/(B.Power((195-k) as nat) as real) }
  lemma ExpFinishRounding(r: int,k: int)
    requires ExpFinishNoWrap(r,k)
    ensures M.ExpFinish(r,k) == (r*ExpMultiplier)/B.Power((195-k) as nat)
    ensures 0.0 <= ExpFinishReal(r as real,k)-(M.ExpFinish(r,k) as real) < 1.0
  {
    A.Identity(195-k);
    assert M.U(r) == r;
    assert M.U(195-k) == 195-k;
    WordShiftAsFloor(r*ExpMultiplier,(195-k) as nat);
    A.Identity((r*ExpMultiplier)/B.Power((195-k) as nat));
    FloorError(r*ExpMultiplier,B.Power((195-k) as nat));
  }
  ghost predicate LnFinishNoWrap(r: int,k: int) {
    M.Signed(r*LnMultiplier) &&
    M.Signed(k*LnExponentMultiplier) &&
    M.Signed(r*LnMultiplier+k*LnExponentMultiplier) &&
    M.Signed(r*LnMultiplier+k*LnExponentMultiplier+LnOffset)
  }
  ghost function LnFinishReal(r: real,k: int): real {
    (r*(LnMultiplier as real)+(k as real)*(LnExponentMultiplier as real)+(LnOffset as real))/(B.Power(174) as real)
  }
  lemma LnFinishRounding(r: int,k: int)
    requires LnFinishNoWrap(r,k)
    ensures M.LnFinish(r,k) == (r*LnMultiplier+k*LnExponentMultiplier+LnOffset)/B.Power(174)
    ensures 0.0 <= LnFinishReal(r as real,k)-(M.LnFinish(r,k) as real) < 1.0
  {
    A.Identity(r*LnMultiplier); A.Identity(k*LnExponentMultiplier);
    A.Identity(r*LnMultiplier+k*LnExponentMultiplier);
    A.Identity(r*LnMultiplier+k*LnExponentMultiplier+LnOffset);
    FloorError(r*LnMultiplier+k*LnExponentMultiplier+LnOffset,B.Power(174));
  }
  lemma RationalDivisionError(p: int,q: int)
    requires M.Signed(p) && q > 0
    ensures M.S(M.Trunc(p,q)) == M.Trunc(p,q)
    ensures R.Abs((p as real)/(q as real)-(M.S(M.Trunc(p,q)) as real)) < 1.0
  { TruncSigned(p,q); TruncError(p,q); }
  lemma ExpKernelRounding(p: int,q: int,k: int)
    requires M.Signed(p) && q > 0
    requires ExpFinishNoWrap(M.Trunc(p,q),k)
    ensures R.Abs(ExpFinishReal((p as real)/(q as real),k)-(M.ExpFinish(M.S(M.Trunc(p,q)),k) as real)) <
            1.0+(ExpMultiplier as real)/(B.Power((195-k) as nat) as real)
  {
    RationalDivisionError(p,q); ExpFinishRounding(M.Trunc(p,q),k);
    var exact := (p as real)/(q as real);
    var rounded := M.Trunc(p,q) as real;
    var multiplier := (ExpMultiplier as real)/(B.Power((195-k) as nat) as real);
    assert multiplier > 0.0;
    R.AbsProduct(exact-rounded,multiplier);
    R.Triangle(ExpFinishReal(exact,k)-ExpFinishReal(rounded,k),
               ExpFinishReal(rounded,k)-(M.ExpFinish(M.S(M.Trunc(p,q)),k) as real));
  }
  lemma LnKernelRounding(p: int,q: int,k: int)
    requires M.Signed(p) && q > 0
    requires LnFinishNoWrap(M.Trunc(p,q),k)
    ensures R.Abs(LnFinishReal((p as real)/(q as real),k)-(M.LnFinish(M.S(M.Trunc(p,q)),k) as real)) <
            1.0+(LnMultiplier as real)/(B.Power(174) as real)
  {
    RationalDivisionError(p,q); LnFinishRounding(M.Trunc(p,q),k);
    var exact := (p as real)/(q as real);
    var rounded := M.Trunc(p,q) as real;
    var multiplier := (LnMultiplier as real)/(B.Power(174) as real);
    assert multiplier > 0.0;
    R.AbsProduct(exact-rounded,multiplier);
    R.Triangle(LnFinishReal(exact,k)-LnFinishReal(rounded,k),
               LnFinishReal(rounded,k)-(M.LnFinish(M.S(M.Trunc(p,q)),k) as real));
  }
  lemma ErrorCompose(actual: real,kernel: real,ideal: real,rounding: real,analytic: real)
    requires R.Abs(actual-kernel) <= rounding && R.Abs(kernel-ideal) <= analytic
    ensures R.Abs(actual-ideal) <= rounding+analytic
  { R.Triangle(actual-kernel,kernel-ideal); }
  lemma NormalizedMantissaError(entry: int,log: nat)
    requires 0 < entry && M.Signed(entry) && log == B.Log(entry as nat)
    ensures 0.0 <= (entry as real)/(B.Power(log) as real)-
            (M.LnNormalization(entry,log) as real)/(M.Q96 as real) < 1.0/(M.Q96 as real)
  {
    A.Powers(); B.KnownPowers(); B.Floor(entry as nat);
    assert log < 255;
    var shift: nat := 255-log;
    B.PowerAdd(log,shift); B.PowerAdd(159,96);
    var moved := entry*B.Power(shift);
    assert M.Half <= moved < B.Word;
    A.Identity(255-(log as int)); A.Residue(moved);
    var normalized := moved/B.Power(159);
    A.NormalizedRange(entry,log);
    A.Identity(normalized);
    assert M.LnNormalization(entry,log) == normalized;
    FloorError(moved,B.Power(159));
    assert (entry as real)/(B.Power(log) as real) ==
           (moved as real)/((B.Power(159) as real)*(M.Q96 as real));
  }
}
