include "Bounds.dfy"
module OperationsFixedPointSource {
  import B = OperationsBinaryLogModel
  import L = OperationsBinaryLogSource
  import M = OperationsFixedPointModel
  import A = OperationsFixedPointBounds
  import P = OperationsFullMulDivSource
  method Reduce(entry: int) returns (x: int,k: int)
    requires M.Signed(entry)
    ensures x == M.ExpReduction(M.ExpScale(entry),M.ExpExponent(M.ExpScale(entry)))
    ensures k == M.ExpExponent(M.ExpScale(entry))
  {
    x := entry;
$E_REDUCE$
  }
  method ExpNumerator(x: int) returns (p: int)
    requires M.Signed(x)
    ensures p == M.ExpNumerator(x)
  {
    A.Powers(); A.ExpCoefficient();
$E_P$
  }
  method ExpDenominator(x: int) returns (q: int)
    requires M.Signed(x)
    ensures q == M.ExpDenominator(x)
  {
$E_Q$
  }
  method ExpParts(x: int) returns (p: int,q: int)
    requires M.Signed(x)
    ensures p == M.ExpNumerator(x) && q == M.ExpDenominator(x)
  { p := ExpNumerator(x); q := ExpDenominator(x); }
  method Normalize(entry: int,log: nat) returns (x: int,k: int)
    requires M.Signed(entry) && log < 256
    ensures x == M.LnNormalization(entry,log)
    ensures k == M.S((log as int)-96)
  {
    x := entry;
    A.Identity(log as int); A.Identity((log as int)-96); A.Identity(255-(log as int));
$L_NORMALIZE$
  }
  method LnParts(x: int) returns (p: int,q: int)
    requires M.Signed(x)
    ensures p == M.LnNumerator(x) && q == M.LnDenominator(x)
  {
    A.Powers();
$L_P$
$L_Q$
  }
  method LnFinish(entry: int,k: int) returns (r: int)
    requires M.Signed(entry)
    ensures r == M.LnFinish(entry,k) && M.Signed(r)
  {
    r := entry;
$L_FINISH$
  }
  method ExpFinish(r: int,k: int) returns (out: int)
    ensures out == M.ExpFinish(r,k)
    ensures M.Signed(out)
  {
    A.Residue(M.U(r)*3822833074963236453042738258902158003155416615667);
    A.Residue(M.S(195-k));
    out := $E_RESULT$;
  }
  method Exp(entry: int) returns (out: M.Outcome)
    requires M.Signed(entry)
    ensures out == M.Exp(entry)
    ensures out.Value? ==> M.Signed(out.result)
    ensures out.Panic? ==> entry >= M.ExpUpper && out.code == 17
  {
    var x := entry;
    if $E_ZERO$ { out := M.Value(0); return; }
    if $E_OVERFLOW$ {
      ghost var payload := P.OpsPanic(17,seq(64,i => 0));
      out := M.Panic(17); return;
    }
    var k: int;
    x,k := Reduce(entry);
    A.ScaledRange(entry); A.ReducedRange(M.ExpScale(entry));
    A.ExpDenominatorPositive(x);
    var p,q := ExpParts(x);
    assert q > 0;
    var r: int;
$E_RATIO$
    var result := ExpFinish(r,k);
    assert result == M.ExpFinish(M.S(M.Trunc(p,q)),k);
    out := M.Value(result);
  }
  method Ln(entry: int) returns (out: M.Outcome)
    requires M.Signed(entry)
    ensures out == M.Ln(entry)
    ensures out.Value? ==> M.Signed(out.result)
    ensures out.Undefined? ==> entry <= 0 && out.argument == entry
    ensures !out.Panic?
  {
    var x := entry;
    if $L_UNDEFINED$ { out := M.Undefined(entry); return; }
    assert M.U(entry) == entry;
    var log := L.Library(M.U(entry));
    var k: int;
    x,k := Normalize(entry,log);
    A.NormalizedRange(entry,log);
    A.LnDenominatorPositive(x);
    var p,q := LnParts(x);
    assert q > 0;
    var r: int;
$L_RATIO$
    r := LnFinish(r,k);
    out := M.Value(r);
  }
  method ExpDenominatorWitness()
  {
    var x: int := 0;
    var q: int;
    A.Powers();
$E_Q_WITNESS$
    assert q == M.ExpDenominator(0);
  }
  method LnFinishWitness()
  {
    var r: int := 0;
    var k: int := 0;
$L_FINISH$
    assert r == M.LnFinish(0,0);
  }
}
