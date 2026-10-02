include "../modular/Math.generated.dfy"
module OperationsDecimalDigitsModel {
  import M = OperationsModularMath
  const Mod: int := M.Word
  const Half: int := M.Half
  datatype Outcome = Ok(value: int) | Empty | Invalid(position: int,character: bv8) | Panic(code: int)
  predicate Digit(c: bv8) { 48 <= c <= 57 }
  function Scan(s: seq<bv8>,i: int,value: int): Outcome
    requires 0 <= i <= |s| && 0 <= value < Mod
    ensures Scan(s,i,value).Ok? ==> 0 <= Scan(s,i,value).value < Mod
    decreases |s|-i
  {
    if i == |s| then Ok(value)
    else if !Digit(s[i]) then Invalid(i,s[i])
    else if value*10+(s[i] as int)-48 >= Mod then Panic(17)
    else Scan(s,i+1,value*10+(s[i] as int)-48)
  }
  function Parse(s: seq<bv8>,start: int): Outcome
    requires 0 <= start <= |s|
    ensures Parse(s,start).Ok? ==> 0 <= Parse(s,start).value < Mod
  { if start == |s| then Empty else Scan(s,start,0) }
  function Restore(r: Outcome,negative: bool): Outcome {
    if !r.Ok? then r
    else if r.value > (if negative then Half else Half-1) then Panic(17)
    else Ok(if negative then -r.value else r.value)
  }
  function SignedSpec(s: seq<bv8>): Outcome {
    if |s| == 0 then Empty
    else Restore(Parse(s,if s[0] == 45 || s[0] == 43 then 1 else 0),s[0] == 45)
  }
  function Convert(r: M.Outcome): Outcome { if r.Panic? then Panic(r.code) else Ok(r.value) }
  lemma RestoreCorrect(value: int,negative: bool)
    requires 0 <= value < Mod
    ensures Convert(M.SignedMagnitudeImpl(value,negative)) == Restore(Ok(value),negative)
  { M.SignedMagnitudeCorrect(value,negative); }
}
