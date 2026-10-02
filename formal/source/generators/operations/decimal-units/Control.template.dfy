include "Model.dfy"
module OperationsDecimalUnitsSource {
  import M = OperationsDecimalUnitsModel
  import R = OperationsDecimalRenderModel
  import Render = OperationsDecimalRenderSource
  import Signed = OperationsModularMath
  method Unsigned(value: nat,decimals: nat) returns (out: M.Outcome)
    requires value < Signed.Word && decimals < Signed.Word
    ensures out == M.Units(value,decimals)
  {
    if $PRECISION$ { out := M.InvalidPrecision(decimals); return; }
    if $ZERO$ { var text := Render.Unsigned(value); out := M.Text(text); return; }
    M.PowerBound(decimals);
    var scale := $SCALE$;
    var quotient := M.Quotient(value,scale);
    var integerValue := $INTEGER$;
    var integer := Render.Unsigned(integerValue);
    var remainder := $REMAINDER$;
    if $NO_REMAINDER$ { out := M.Text(integer); return; }
    var original := remainder;
    var fraction := seq(decimals, j => 0 as bv8);
    var i := decimals;
    while $FILL_LOOP$
      invariant 0 <= i <= decimals
      invariant 0 <= remainder < M.Power(i)
      invariant |fraction| == decimals
      invariant M.Fixed(original,decimals) == M.Fixed(remainder,i)+fraction[i..]
      decreases i
    {
      i := i-1;
      var digit := $DIGIT$;
      fraction := fraction[i := digit];
      assert M.Fixed(remainder,i+1) == M.Fixed(remainder/10,i)+[digit];
      assert [digit]+fraction[i+1..] == fraction[i..];
      remainder := $DIVIDE$;
    }
    assert fraction == M.Fixed(original,decimals);
    M.FixedValue(original,decimals);
    var length := decimals;
    while $TRIM_LOOP$
      invariant 0 < length <= decimals
      invariant R.Value(fraction[..length]) > 0
      invariant M.Trim(fraction) == M.Trim(fraction[..length])
      decreases length
    {
      assert fraction[length-1] == 48;
      M.TrimStep(fraction[..length]);
      assert fraction[..length][..length-1] == fraction[..length-1];
      assert R.Value(fraction[..length-1]) > 0;
      assert length > 1;
      length := length-1;
    }
    out := M.Text(integer+[46]+fraction[..length]);
  }
  method SignedValue(value: int,decimals: nat) returns (out: M.Outcome)
    requires -Signed.Half <= value < Signed.Half && decimals < Signed.Word
    ensures out == M.SignedUnits(value,decimals)
  {
    var magnitude := Signed.MagnitudeImpl(value);
    Signed.MagnitudeCorrect(value);
    out := Unsigned(magnitude,decimals);
    if out.Text? { out := M.Text((if $NEGATIVE$ then [45] else [])+out.data); }
  }
}
