include "Model.dfy"
module OperationsParseUnitsSource {
  import M = OperationsParseUnitsModel
  import U = OperationsDecimalUnitsModel
  import S = OperationsModularMath
  method Engine(value: seq<bv8>,decimals: int,rounding: int,allowSigned: bool) returns (out: M.Outcome)
    requires |value| < S.Word && 0 <= decimals < S.Word && 0 <= rounding <= 2
    ensures out == M.Parse(value,decimals,rounding,allowSigned)
  {
    if $PRECISION$ { out := M.InvalidPrecision(decimals); return; }
    if $EMPTY$ { out := M.Empty; return; }
    var negative := $NEGATIVE$;
    if $UNSIGNED_MINUS$ { out := M.Invalid(0,value[0]); return; }
    var start := $START$;
    var point := false;
    var digit := false;
    var remainder := false;
    var fractional := 0;
    var magnitude := 0;
    var i := start;
    while $LOOP$
      invariant start <= i <= |value|
      invariant 0 <= fractional <= decimals
      invariant 0 <= magnitude < S.Word
      invariant M.Parse(value,decimals,rounding,allowSigned) == M.Scan(value,i,decimals,rounding,negative,point,digit,remainder,fractional,magnitude)
      decreases |value|-i
    {
      var before := M.Scan(value,i,decimals,rounding,negative,point,digit,remainder,fractional,magnitude);
      var c := value[i];
      if $POINT$ {
        point := true;
        i := i+1;
        assert before == M.Scan(value,i,decimals,rounding,negative,point,digit,remainder,fractional,magnitude);
        continue;
      }
      if $BAD$ { out := M.Invalid(i,c); return; }
      digit := true;
      if $DROP$ {
        if $STICKY$ { remainder := true; }
      } else {
        var product := $PRODUCT$;
        if product < 0 || product >= S.Word { out := M.Panic(17); return; }
        var next := $ACCUMULATE$;
        if next < 0 || next >= S.Word { out := M.Panic(17); return; }
        magnitude := next;
        if $FRACTIONAL$ { fractional := fractional+1; }
      }
      i := i+1;
      assert before == M.Scan(value,i,decimals,rounding,negative,point,digit,remainder,fractional,magnitude);
    }
    if $NO_DIGITS$ { out := M.Empty; return; }
    U.PowerBound(decimals-fractional);
    U.ProductNonnegative(magnitude,U.Power(decimals-fractional));
    var scaled := $SCALE$;
    if scaled < 0 || scaled >= S.Word { out := M.Panic(17); return; }
    magnitude := scaled;
    if $ROUND$ {
      if magnitude+1 >= S.Word { out := M.Panic(17); return; }
      magnitude := magnitude+1;
    }
    out := M.Numeric(magnitude,negative);
  }
  method Unsigned(value: seq<bv8>,decimals: int,rounding: int) returns (out: M.Outcome)
    requires |value| < S.Word && 0 <= decimals < S.Word && 0 <= rounding <= 2
    ensures out == M.Parse(value,decimals,rounding,false)
  { out := Engine(value,decimals,rounding,$UNSIGNED_MODE$); }
  method SignedValue(value: seq<bv8>,decimals: int,rounding: int) returns (out: M.Outcome)
    requires |value| < S.Word && 0 <= decimals < S.Word && 0 <= rounding <= 2
    ensures out == M.Restore(M.Parse(value,decimals,rounding,true))
  {
    out := Engine(value,decimals,rounding,$SIGNED_MODE$);
    if out.Numeric? {
      var r := S.SignedMagnitudeImpl(out.value,out.negative);
      M.RestoreCorrect(out.value,out.negative);
      out := if r.Panic? then M.Panic(r.code) else M.Numeric(r.value,out.negative);
    }
  }
}
