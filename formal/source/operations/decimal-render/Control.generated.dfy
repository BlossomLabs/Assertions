include "Model.dfy"
module OperationsDecimalRenderSource {
  import M = OperationsDecimalRenderModel
  import Signed = OperationsModularMath
  method Unsigned(v: nat) returns (buf: seq<bv8>)
    requires v < M.Word
    ensures buf == M.Decimal(v)
  {
    if (v == 0) { buf := [48]; return; }
    var digits := 0;
    var t := v;
    while (t > 0)
      invariant 0 <= t <= v
      invariant digits+M.Count(t) == M.Count(v)
      invariant 0 <= digits < M.Word
      decreases t
    {
      assert digits+1 <= M.Count(v) <= v;
      digits := digits+1;
      t := (t / 10);
    }
    assert digits == M.Count(v);
    buf := seq(digits, i => 0 as bv8);
    t := v;
    while (t > 0)
      invariant 0 <= t <= v
      invariant 0 <= digits <= |buf| == M.Count(v)
      invariant digits == M.Count(t)
      invariant M.Nonzero(v) == M.Nonzero(t)+buf[digits..]
      decreases t
    {
      digits := digits-1;
      var digit := (((48 + (t % 10))) as bv8);
      buf := buf[digits := digit];
      assert M.Nonzero(t) == M.Nonzero(t/10)+[digit];
      assert [digit]+buf[digits+1..] == buf[digits..];
      t := (t / 10);
    }
  }
  method SignedValue(value: int) returns (out: seq<bv8>)
    requires -Signed.Half <= value < Signed.Half
    ensures out == M.SignedDecimal(value)
  {
    var magnitude := Signed.MagnitudeImpl(value);
    Signed.MagnitudeCorrect(value);
    var inner := Unsigned(magnitude);
    out := (if (value < 0) then [45] else [])+inner;
  }
}
