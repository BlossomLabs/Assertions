include "../decimal-units/Model.dfy"
module OperationsParseUnitsModel {
  import U = OperationsDecimalUnitsModel
  import S = OperationsModularMath
  datatype Outcome = Numeric(value: int,negative: bool) | Empty | Invalid(position: int,character: bv8) | InvalidPrecision(precision: int) | Panic(code: int)
  predicate Digit(c: bv8) { 48 <= c <= 57 }
  predicate Away(negative: bool,rounding: int) { (negative && rounding == 1) || (!negative && rounding == 2) }
  function Finish(m: int,f: int,d: int,seen: bool,sticky: bool,negative: bool,rounding: int): Outcome
    requires 0 <= m < S.Word && 0 <= f <= d <= 77 && 0 <= rounding <= 2
    ensures Finish(m,f,d,seen,sticky,negative,rounding).Numeric? ==> 0 <= Finish(m,f,d,seen,sticky,negative,rounding).value < S.Word
  {
    U.ProductNonnegative(m,U.Power(d-f));
    var scaled := m*U.Power(d-f);
    if !seen then Empty
    else if scaled >= S.Word then Panic(17)
    else if sticky && Away(negative,rounding) then
      (if scaled+1 >= S.Word then Panic(17) else Numeric(scaled+1,negative))
    else Numeric(scaled,negative)
  }
  function Scan(s: seq<bv8>,i: int,d: int,rounding: int,negative: bool,point: bool,seen: bool,sticky: bool,f: int,m: int): Outcome
    requires 0 <= i <= |s| && 0 <= d <= 77 && 0 <= rounding <= 2
    requires 0 <= f <= d && 0 <= m < S.Word
    ensures Scan(s,i,d,rounding,negative,point,seen,sticky,f,m).Numeric? ==> 0 <= Scan(s,i,d,rounding,negative,point,seen,sticky,f,m).value < S.Word
    decreases |s|-i
  {
    if i == |s| then Finish(m,f,d,seen,sticky,negative,rounding)
    else if s[i] == 46 && !point then Scan(s,i+1,d,rounding,negative,true,seen,sticky,f,m)
    else if !Digit(s[i]) then Invalid(i,s[i])
    else if point && f >= d then Scan(s,i+1,d,rounding,negative,point,true,sticky || s[i] != 48,f,m)
    else if m*10+(s[i] as int)-48 >= S.Word then Panic(17)
    else Scan(s,i+1,d,rounding,negative,point,true,sticky,if point then f+1 else f,m*10+(s[i] as int)-48)
  }
  function Parse(s: seq<bv8>,d: int,rounding: int,allowSigned: bool): Outcome
    requires 0 <= d && 0 <= rounding <= 2
    ensures Parse(s,d,rounding,allowSigned).Numeric? ==> 0 <= Parse(s,d,rounding,allowSigned).value < S.Word
  {
    if d > 77 then InvalidPrecision(d)
    else if |s| == 0 then Empty
    else if s[0] == 45 && !allowSigned then Invalid(0,s[0])
    else Scan(s,if s[0] == 45 || s[0] == 43 then 1 else 0,d,rounding,s[0] == 45,false,false,false,0,0)
  }
  function Restore(r: Outcome): Outcome {
    if !r.Numeric? then r
    else if r.value > (if r.negative then S.Half else S.Half-1) then Panic(17)
    else Numeric(if r.negative then -r.value else r.value,r.negative)
  }
  lemma RestoreCorrect(value: int,negative: bool)
    requires 0 <= value < S.Word
    ensures (if S.SignedMagnitudeImpl(value,negative).Panic? then Panic(S.SignedMagnitudeImpl(value,negative).code) else Numeric(S.SignedMagnitudeImpl(value,negative).value,negative)) == Restore(Numeric(value,negative))
  { S.SignedMagnitudeCorrect(value,negative); }
}
