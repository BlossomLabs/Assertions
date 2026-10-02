include "Convergence.dfy"
module OperationsIntegerRootSource {
  import M = OperationsIntegerRootModel
  import S = OperationsIntegerRootSeed
  import C = OperationsIntegerRootConvergence
  import B = OperationsBinaryLogModel
  function ToUint(b: bool): nat
    ensures ToUint(b) == B.Bool(b)
  { $CAST$ }
$STAGE_METHODS$
$UPDATE_METHODS$
  method Library(a: nat) returns (out: nat)
    requires a < B.Word
    ensures out == M.Spec(a) && M.Root(a,out)
  {
    B.KnownPowers();
    if $EARLY$ {
      out := a;
      M.RootUnique(a,out,M.Spec(a));
      return;
    }
    var aa := a;
    var xn: nat := 1;
    ghost var e: nat := 0;
    assert aa == a/B.Power(2*e) && xn == B.Power(e);
    assert 1 <= aa < B.Power(256);
$STAGES$
    assert e <= 127;
    S.Bounds(a,e);
    var t := xn;
    assert t <= B.Power(127);
    assert B.Power(128) == 2*B.Power(127);
    assert 3*xn < B.Word;
    xn := $INITIAL$;
    var x0 := xn;
    assert x0 == (3*t)/2;
    var r := M.Spec(a);
    M.SeedRoot(a,t,r);
    assert t <= xn <= 8*t+8;
    var x1 := Update1(a,t,xn,r);
    xn := x1;
    var x2 := Update2(a,t,xn,r);
    xn := x2;
    var x3 := Update3(a,t,xn,r);
    xn := x3;
    var x4 := Update4(a,t,xn,r);
    xn := x4;
    var x5 := Update5(a,t,xn,r);
    xn := x5;
    var x6 := Update6(a,t,xn,r);
    xn := x6;
    assert 1 <= t <= B.Power(127) && t*t <= a < 4*t*t;
    assert x1 == M.Newton(a,x0);
    assert x2 == M.Newton(a,x1);
    assert x3 == M.Newton(a,x2);
    assert x4 == M.Newton(a,x3);
    assert x5 == M.Newton(a,x4);
    assert x6 == M.Newton(a,x5);
    C.Six(a,t,x0,x1,x2,x3,x4,x5,x6);
    M.FinalCorrection(a,r,xn);
    var correction := ToUint($FINAL$);
    assert correction <= xn;
    out := (xn-correction) % B.Word;
  }
  method Public(x: nat) returns (out: nat)
    requires x < B.Word
    ensures out == M.Spec(x) && out*out <= x < (out+1)*(out+1)
  { out := Library(x); }
  method NewtonWitness()
  {
    B.KnownPowers();
    var a: nat := 16;
    var xn: nat := 4;
    var next := $NEWTON1$;
    assert next == 4;
  }
  method CorrectionWitness()
  {
    var a: nat := 3;
    var xn: nat := 2;
    var correction := ToUint($FINAL$);
    assert xn-correction == 1;
  }
}
