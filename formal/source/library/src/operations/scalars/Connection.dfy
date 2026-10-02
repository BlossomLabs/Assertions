include "Control.generated.dfy"
module OperationsScalarConnection {
  import M = OperationsScalarModel
  import S = OperationsScalarSource
  lemma addU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.addU(a,b) == (M.CheckedU(a + b))
  {
  }
  lemma addS(a: int, b: int)
    requires M.Signed(a) && M.Signed(b)
    ensures S.addS(a,b) == (M.CheckedS(a + b))
  {
  }
  lemma subU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.subU(a,b) == (M.CheckedU(a - b))
  {
  }
  lemma subS(a: int, b: int)
    requires M.Signed(a) && M.Signed(b)
    ensures S.subS(a,b) == (M.CheckedS(a - b))
  {
  }
  lemma mulU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.mulU(a,b) == (M.CheckedU(a * b))
  {
  }
  lemma mulS(a: int, b: int)
    requires M.Signed(a) && M.Signed(b)
    ensures S.mulS(a,b) == (M.CheckedS(a * b))
  {
  }
  lemma divU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.divU(a,b) == ((if b == 0 then M.Panic(18) else M.Value(a / b)))
  {
  }
  lemma divS(a: int, b: int)
    requires M.Signed(a) && M.Signed(b)
    ensures S.divS(a,b) == ((if b == 0 then M.Panic(18) else if a == M.Low && b == -1 then M.Panic(17) else M.Value(M.Trunc(a,b))))
  {
  }
  lemma modU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.modU(a,b) == ((if b == 0 then M.Panic(18) else M.Value(a % b)))
  {
  }
  lemma modS(a: int, b: int)
    requires M.Signed(a) && M.Signed(b)
    ensures S.modS(a,b) == ((if b == 0 then M.Panic(18) else M.Value(a - M.Trunc(a,b) * b)))
  {
  }
  lemma minU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.minU(a,b) == (M.Value(if a <= b then a else b))
  {
  }
  lemma minS(a: int, b: int)
    requires M.Signed(a) && M.Signed(b)
    ensures S.minS(a,b) == (M.Value(if a <= b then a else b))
  {
  }
  lemma maxU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.maxU(a,b) == (M.Value(if a >= b then a else b))
  {
  }
  lemma maxS(a: int, b: int)
    requires M.Signed(a) && M.Signed(b)
    ensures S.maxS(a,b) == (M.Value(if a >= b then a else b))
  {
  }
  lemma absDiffU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.absDiffU(a,b) == (M.Value(M.Abs(a-b)))
  {
  }
  lemma absDiffS(a: int, b: int)
    requires M.Signed(a) && M.Signed(b)
    ensures S.absDiffS(a,b) == (M.Value(M.Abs(a-b)))
  {
    assert 0 <= M.Abs(a-b) < M.Mod;
    assert M.Wrap(a) - M.Wrap(b) == a-b || M.Wrap(a) - M.Wrap(b) == a-b+M.Mod || M.Wrap(a) - M.Wrap(b) == a-b-M.Mod;
  }
  lemma eqU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.eqU(a,b) == (a == b)
  {
  }
  lemma neU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.neU(a,b) == (!(a == b))
  {
  }
  lemma ltU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.ltU(a,b) == (!(a >= b))
  {
  }
  lemma ltS(a: int, b: int)
    requires M.Signed(a) && M.Signed(b)
    ensures S.ltS(a,b) == (!(a >= b))
  {
  }
  lemma gtU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.gtU(a,b) == (!(a <= b))
  {
  }
  lemma gtS(a: int, b: int)
    requires M.Signed(a) && M.Signed(b)
    ensures S.gtS(a,b) == (!(a <= b))
  {
  }
  lemma leU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.leU(a,b) == (a < b || a == b)
  {
  }
  lemma leS(a: int, b: int)
    requires M.Signed(a) && M.Signed(b)
    ensures S.leS(a,b) == (a < b || a == b)
  {
  }
  lemma geU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.geU(a,b) == (a > b || a == b)
  {
  }
  lemma geS(a: int, b: int)
    requires M.Signed(a) && M.Signed(b)
    ensures S.geS(a,b) == (a > b || a == b)
  {
  }
  lemma bitAndU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.bitAndU(a,b) == (M.Value(((a as bv256) & (b as bv256)) as int))
  {
  }
  lemma bitOrU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.bitOrU(a,b) == (M.Value(((a as bv256) | (b as bv256)) as int))
  {
  }
  lemma bitXorU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.bitXorU(a,b) == (M.Value(((a as bv256) ^ (b as bv256)) as int))
  {
  }
  lemma shlU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.shlU(a,b) == (M.Value(if b >= 256 then 0 else ((a as bv256) << (b as bv256)) as int))
  {
  }
  lemma shrU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.shrU(a,b) == (M.Value(if b >= 256 then 0 else ((a as bv256) >> (b as bv256)) as int))
  {
  }
  lemma shrS(a: int, b: int)
    requires M.Signed(a) && M.Word(b)
    ensures S.shrS(a,b) == (M.Value(if a < 0 then -1-M.Right(-a-1,b) else M.Right(a,b)))
  {
  }
  lemma bitSetU(a: int, b: int)
    requires M.Word(a) && M.Word(b)
    ensures S.bitSetU(a,b) == ((((M.Right(a,b) as bv256) & 1) as int) == 1)
  {

  }
  lemma FullWidthDistance()
    ensures S.absDiffS(M.Low,M.High) == M.Value(M.Mod-1)
  { absDiffS(M.Low,M.High); }
  lemma LargeShifts(a: int,b: int)
    requires M.Word(a) && M.Word(b) && b >= 256
    ensures S.shlU(a,b) == (M.Value(0))
    ensures S.shrU(a,b) == (M.Value(0))
    ensures !S.bitSetU(a,b)
  { }
  lemma BitAndWitness()
    ensures S.bitAndU(3,5) == M.Value(1)
  { }

}
