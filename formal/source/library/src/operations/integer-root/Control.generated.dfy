include "Convergence.dfy"
module OperationsIntegerRootSource {
  import M = OperationsIntegerRootModel
  import S = OperationsIntegerRootSeed
  import C = OperationsIntegerRootConvergence
  import B = OperationsBinaryLogModel
  function ToUint(b: bool): nat
    ensures ToUint(b) == B.Bool(b)
  { B.Iszero(B.Iszero(B.Bool(b))) }
  method Seed64(a: nat,aa: nat,xn: nat,ghost e: nat) returns (nextAA: nat,nextXN: nat,ghost nextE: nat)
    requires e+64 <= 127 && aa == a/B.Power(2*e) && xn == B.Power(e)
    requires 1 <= aa < B.Power(256)
    ensures nextE == e+(if aa >= B.Power(128) then 64 else 0)
    ensures nextE <= e+64 && nextXN == B.Power(nextE)
    ensures 1 <= a/B.Power(2*nextE) < B.Power(128)
    ensures nextAA == a/B.Power(2*nextE)
  {
    B.KnownPowers();
    S.Advance(a,e,64,aa,xn);
    nextAA,nextXN,nextE := aa,xn,e;
    if (aa >= ((1 * B.Power(128)) % B.Word)) {
      nextAA := aa/B.Power(128);
      assert xn*B.Power(64) == B.Power(e+64);
      S.PowerMonotone(e+64,127);
      assert B.Power(128) == 2*B.Power(127);
      assert xn*B.Power(64) < B.Word;
      nextXN := (xn*B.Power(64)) % B.Word;
      nextE := e+64;
    }
  }
  method Seed32(a: nat,aa: nat,xn: nat,ghost e: nat) returns (nextAA: nat,nextXN: nat,ghost nextE: nat)
    requires e+32 <= 127 && aa == a/B.Power(2*e) && xn == B.Power(e)
    requires 1 <= aa < B.Power(128)
    ensures nextE == e+(if aa >= B.Power(64) then 32 else 0)
    ensures nextE <= e+32 && nextXN == B.Power(nextE)
    ensures 1 <= a/B.Power(2*nextE) < B.Power(64)
    ensures nextAA == a/B.Power(2*nextE)
  {
    B.KnownPowers();
    S.Advance(a,e,32,aa,xn);
    nextAA,nextXN,nextE := aa,xn,e;
    if (aa >= ((1 * B.Power(64)) % B.Word)) {
      nextAA := aa/B.Power(64);
      assert xn*B.Power(32) == B.Power(e+32);
      S.PowerMonotone(e+32,127);
      assert B.Power(128) == 2*B.Power(127);
      assert xn*B.Power(32) < B.Word;
      nextXN := (xn*B.Power(32)) % B.Word;
      nextE := e+32;
    }
  }
  method Seed16(a: nat,aa: nat,xn: nat,ghost e: nat) returns (nextAA: nat,nextXN: nat,ghost nextE: nat)
    requires e+16 <= 127 && aa == a/B.Power(2*e) && xn == B.Power(e)
    requires 1 <= aa < B.Power(64)
    ensures nextE == e+(if aa >= B.Power(32) then 16 else 0)
    ensures nextE <= e+16 && nextXN == B.Power(nextE)
    ensures 1 <= a/B.Power(2*nextE) < B.Power(32)
    ensures nextAA == a/B.Power(2*nextE)
  {
    B.KnownPowers();
    S.Advance(a,e,16,aa,xn);
    nextAA,nextXN,nextE := aa,xn,e;
    if (aa >= ((1 * B.Power(32)) % B.Word)) {
      nextAA := aa/B.Power(32);
      assert xn*B.Power(16) == B.Power(e+16);
      S.PowerMonotone(e+16,127);
      assert B.Power(128) == 2*B.Power(127);
      assert xn*B.Power(16) < B.Word;
      nextXN := (xn*B.Power(16)) % B.Word;
      nextE := e+16;
    }
  }
  method Seed8(a: nat,aa: nat,xn: nat,ghost e: nat) returns (nextAA: nat,nextXN: nat,ghost nextE: nat)
    requires e+8 <= 127 && aa == a/B.Power(2*e) && xn == B.Power(e)
    requires 1 <= aa < B.Power(32)
    ensures nextE == e+(if aa >= B.Power(16) then 8 else 0)
    ensures nextE <= e+8 && nextXN == B.Power(nextE)
    ensures 1 <= a/B.Power(2*nextE) < B.Power(16)
    ensures nextAA == a/B.Power(2*nextE)
  {
    B.KnownPowers();
    S.Advance(a,e,8,aa,xn);
    nextAA,nextXN,nextE := aa,xn,e;
    if (aa >= ((1 * B.Power(16)) % B.Word)) {
      nextAA := aa/B.Power(16);
      assert xn*B.Power(8) == B.Power(e+8);
      S.PowerMonotone(e+8,127);
      assert B.Power(128) == 2*B.Power(127);
      assert xn*B.Power(8) < B.Word;
      nextXN := (xn*B.Power(8)) % B.Word;
      nextE := e+8;
    }
  }
  method Seed4(a: nat,aa: nat,xn: nat,ghost e: nat) returns (nextAA: nat,nextXN: nat,ghost nextE: nat)
    requires e+4 <= 127 && aa == a/B.Power(2*e) && xn == B.Power(e)
    requires 1 <= aa < B.Power(16)
    ensures nextE == e+(if aa >= B.Power(8) then 4 else 0)
    ensures nextE <= e+4 && nextXN == B.Power(nextE)
    ensures 1 <= a/B.Power(2*nextE) < B.Power(8)
    ensures nextAA == a/B.Power(2*nextE)
  {
    B.KnownPowers();
    S.Advance(a,e,4,aa,xn);
    nextAA,nextXN,nextE := aa,xn,e;
    if (aa >= ((1 * B.Power(8)) % B.Word)) {
      nextAA := aa/B.Power(8);
      assert xn*B.Power(4) == B.Power(e+4);
      S.PowerMonotone(e+4,127);
      assert B.Power(128) == 2*B.Power(127);
      assert xn*B.Power(4) < B.Word;
      nextXN := (xn*B.Power(4)) % B.Word;
      nextE := e+4;
    }
  }
  method Seed2(a: nat,aa: nat,xn: nat,ghost e: nat) returns (nextAA: nat,nextXN: nat,ghost nextE: nat)
    requires e+2 <= 127 && aa == a/B.Power(2*e) && xn == B.Power(e)
    requires 1 <= aa < B.Power(8)
    ensures nextE == e+(if aa >= B.Power(4) then 2 else 0)
    ensures nextE <= e+2 && nextXN == B.Power(nextE)
    ensures 1 <= a/B.Power(2*nextE) < B.Power(4)
    ensures nextAA == a/B.Power(2*nextE)
  {
    B.KnownPowers();
    S.Advance(a,e,2,aa,xn);
    nextAA,nextXN,nextE := aa,xn,e;
    if (aa >= ((1 * B.Power(4)) % B.Word)) {
      nextAA := aa/B.Power(4);
      assert xn*B.Power(2) == B.Power(e+2);
      S.PowerMonotone(e+2,127);
      assert B.Power(128) == 2*B.Power(127);
      assert xn*B.Power(2) < B.Word;
      nextXN := (xn*B.Power(2)) % B.Word;
      nextE := e+2;
    }
  }
  method Seed1(a: nat,aa: nat,xn: nat,ghost e: nat) returns (nextAA: nat,nextXN: nat,ghost nextE: nat)
    requires e+1 <= 127 && aa == a/B.Power(2*e) && xn == B.Power(e)
    requires 1 <= aa < B.Power(4)
    ensures nextE == e+(if aa >= B.Power(2) then 1 else 0)
    ensures nextE <= e+1 && nextXN == B.Power(nextE)
    ensures 1 <= a/B.Power(2*nextE) < B.Power(2)
    ensures nextAA == aa
  {
    B.KnownPowers();
    S.Advance(a,e,1,aa,xn);
    nextAA,nextXN,nextE := aa,xn,e;
    if (aa >= ((1 * B.Power(2)) % B.Word)) {
      assert xn*B.Power(1) == B.Power(e+1);
      S.PowerMonotone(e+1,127);
      assert B.Power(128) == 2*B.Power(127);
      assert xn*B.Power(1) < B.Word;
      nextXN := (xn*B.Power(1)) % B.Word;
      nextE := e+1;
    }
  }
  method Update1(a: nat,t: nat,xn: nat,ghost r: nat) returns (next: nat)
    requires 1 <= t <= B.Power(127) && t*t <= a < 4*t*t
    requires M.Root(a,r) && t <= r && t <= xn <= 8*t+8
    ensures next == M.Newton(a,xn) && t <= next <= 8*t+8
  {
    B.KnownPowers();
    S.Coarse(a,t,xn);
    M.NewtonLower(a,xn,r);
    next := (((xn + (a / xn)) % B.Word) / B.Power(1));
  }
  method Update2(a: nat,t: nat,xn: nat,ghost r: nat) returns (next: nat)
    requires 1 <= t <= B.Power(127) && t*t <= a < 4*t*t
    requires M.Root(a,r) && t <= r && t <= xn <= 8*t+8
    ensures next == M.Newton(a,xn) && t <= next <= 8*t+8
  {
    B.KnownPowers();
    S.Coarse(a,t,xn);
    M.NewtonLower(a,xn,r);
    next := (((xn + (a / xn)) % B.Word) / B.Power(1));
  }
  method Update3(a: nat,t: nat,xn: nat,ghost r: nat) returns (next: nat)
    requires 1 <= t <= B.Power(127) && t*t <= a < 4*t*t
    requires M.Root(a,r) && t <= r && t <= xn <= 8*t+8
    ensures next == M.Newton(a,xn) && t <= next <= 8*t+8
  {
    B.KnownPowers();
    S.Coarse(a,t,xn);
    M.NewtonLower(a,xn,r);
    next := (((xn + (a / xn)) % B.Word) / B.Power(1));
  }
  method Update4(a: nat,t: nat,xn: nat,ghost r: nat) returns (next: nat)
    requires 1 <= t <= B.Power(127) && t*t <= a < 4*t*t
    requires M.Root(a,r) && t <= r && t <= xn <= 8*t+8
    ensures next == M.Newton(a,xn) && t <= next <= 8*t+8
  {
    B.KnownPowers();
    S.Coarse(a,t,xn);
    M.NewtonLower(a,xn,r);
    next := (((xn + (a / xn)) % B.Word) / B.Power(1));
  }
  method Update5(a: nat,t: nat,xn: nat,ghost r: nat) returns (next: nat)
    requires 1 <= t <= B.Power(127) && t*t <= a < 4*t*t
    requires M.Root(a,r) && t <= r && t <= xn <= 8*t+8
    ensures next == M.Newton(a,xn) && t <= next <= 8*t+8
  {
    B.KnownPowers();
    S.Coarse(a,t,xn);
    M.NewtonLower(a,xn,r);
    next := (((xn + (a / xn)) % B.Word) / B.Power(1));
  }
  method Update6(a: nat,t: nat,xn: nat,ghost r: nat) returns (next: nat)
    requires 1 <= t <= B.Power(127) && t*t <= a < 4*t*t
    requires M.Root(a,r) && t <= r && t <= xn <= 8*t+8
    ensures next == M.Newton(a,xn) && t <= next <= 8*t+8
  {
    B.KnownPowers();
    S.Coarse(a,t,xn);
    M.NewtonLower(a,xn,r);
    next := (((xn + (a / xn)) % B.Word) / B.Power(1));
  }
  method Library(a: nat) returns (out: nat)
    requires a < B.Word
    ensures out == M.Spec(a) && M.Root(a,out)
  {
    B.KnownPowers();
    if (a <= 1) {
      out := a;
      M.RootUnique(a,out,M.Spec(a));
      return;
    }
    var aa := a;
    var xn: nat := 1;
    ghost var e: nat := 0;
    assert aa == a/B.Power(2*e) && xn == B.Power(e);
    assert 1 <= aa < B.Power(256);
    assert e <= 0;
    aa,xn,e := Seed64(a,aa,xn,e);
    assert e <= 64;
    aa,xn,e := Seed32(a,aa,xn,e);
    assert e <= 96;
    aa,xn,e := Seed16(a,aa,xn,e);
    assert e <= 112;
    aa,xn,e := Seed8(a,aa,xn,e);
    assert e <= 120;
    aa,xn,e := Seed4(a,aa,xn,e);
    assert e <= 124;
    aa,xn,e := Seed2(a,aa,xn,e);
    assert e <= 126;
    aa,xn,e := Seed1(a,aa,xn,e);
    assert e <= 127;
    S.Bounds(a,e);
    var t := xn;
    assert t <= B.Power(127);
    assert B.Power(128) == 2*B.Power(127);
    assert 3*xn < B.Word;
    xn := (((3 * xn) % B.Word) / B.Power(1));
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
    var correction := ToUint((xn > (a / xn)));
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
    var next := (((xn + (a / xn)) % B.Word) / B.Power(1));
    assert next == 4;
  }
  method CorrectionWitness()
  {
    var a: nat := 3;
    var xn: nat := 2;
    var correction := ToUint((xn > (a / xn)));
    assert xn-correction == 1;
  }
}
