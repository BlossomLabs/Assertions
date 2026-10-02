include "../full-mul-div/Connection.dfy"
module OperationsFixedPointModel {
  import B = OperationsBinaryLogModel
  import P = OperationsFullMulDivProduct
  const Half: int := B.Word/2
  const Q96: int := 0x1000000000000000000000000
  const ExpLower: int := -42139678854452767551
  const ExpUpper: int := 135305999368893231589
  const Ln2: int := 54916777467707473351141471128
  datatype Outcome = Value(result: int) | Panic(code: nat) | Undefined(argument: int)
  predicate Signed(x: int) { -Half <= x < Half }
  function Abs(x: int): int { if x < 0 then -x else x }
  function U(x: int): nat { x%B.Word }
  function S(x: int): int
    ensures Signed(S(x))
  { var u := U(x); if u < Half then u as int else (u as int)-B.Word }
  function Trunc(a: int,b: int): int
  { if b == 0 then 0 else if (a < 0) != (b < 0) then -(Abs(a)/Abs(b)) else Abs(a)/Abs(b) }
  function Shl(a: int,n: nat): nat
  { if n >= 256 then 0 else U(a*B.Power(n)) }
  function Shr(a: int,n: nat): nat
  { if n >= 256 then 0 else P.Div(U(a),B.Power(n)) }
  function Sar(a: int,n: nat): int
  { if n >= 256 then (if a < 0 then -1 else 0) else a/B.Power(n) }
  // Quantized, finite-word Horner evaluation, independent of source variable assignments.
  function Step(x: int,y: int,c: int): int { S(Sar(S(x*y),96)+c) }
  function Horner(x: int,seed: int,coefficients: seq<int>): int
    decreases |coefficients|
  { if |coefficients| == 0 then seed else Horner(x,Step(x,seed,coefficients[0]),coefficients[1..]) }
  function ExpDenominator(x: int): int
  { Horner(x,S(x-2855989394907223263936484059900),[
             50020603652535783019961831881945,-533845033583426703283633433725380,
             3604857256930695427073651918091429,-14423608567350463180887372962807573,
             26449188498355588339934803723976023]) }
  function ExpY(x: int): int
  { Horner(x,S(x+1346386616545796478920950773328),[57155421227552351082224309758442]) }
  function ExpCore(x: int): int
  { var y := ExpY(x); Step(y,S(S(y+x)-94201549194550492254356042504812),28719021644029726153956944680412240) }
  function ExpNumerator(x: int): int
  { S(S(ExpCore(x)*x)+S(Shl(4385272521454847904659076985693276,96))) }
  function ExpFinish(r: int,k: int): int
  { S(Shr(U(r)*3822833074963236453042738258902158003155416615667,U(S(195-k)))) }
  function LnNumerator(x: int): int
  {
    var p := Horner(x,S(x+3273285459638523848632254066296),[
                      24828157081833163892658089445524,43456485725739037958740375743393,
                      -11111509109440967052023855526967,-45023709667254063763336534515857,
                      -14706773417378608786704636184526]);
    S(S(p*x)-S(Shl(795164235651350426258249787498,96)))
  }
  function LnDenominator(x: int): int
  { Horner(x,S(x+5573035233440673466300451813936),[
             71694874799317883764090561454958,283447036172924575727196451306956,
             401686690394027663651624208769553,204048457590392012362485061816622,
             31853899698501571402653359427138,909429971244387300277376558375]) }
  function ExpScale(x: int): int { S(Trunc(S(Shl(x,78)),3814697265625)) }
  function ExpExponent(x: int): int { Sar(S(Trunc(S(Shl(x,96)),Ln2)+39614081257132168796771975168),96) }
  function ExpReduction(x: int,k: int): int { S(x-S(k*Ln2)) }
  function Exp(x: int): Outcome
  {
    if x <= ExpLower then Value(0) else if x >= ExpUpper then Panic(17) else
    var scaled := ExpScale(x);
    var k := ExpExponent(scaled);
    var reduced := ExpReduction(scaled,k);
    var p := ExpNumerator(reduced);
    var q := ExpDenominator(reduced);
    if q == 0 then Panic(18) else
    Value(ExpFinish(S(Trunc(p,q)),k))
  }
  function LnNormalization(x: int,log: nat): int
  { S(Shr(S(Shl(x,U(S(255-(log as int))))),159)) }
  function LnFinish(r: int,k: int): int
  { Sar(S(S(S(r*1677202110996718588342820967067443963516166)
            +S(16597577552685614221487285958193947469193820559219878177908093499208371*k))
          +600920179829731861736702779321621459595472258049074101567377883020018308),174) }
  function Ln(x: int): Outcome
  {
    if x <= 0 then Undefined(x) else
    var log := B.Log(x as nat);
    var normalized := LnNormalization(x,log);
    var p := LnNumerator(normalized);
    var q := LnDenominator(normalized);
    if q == 0 then Panic(18) else Value(LnFinish(S(Trunc(p,q)),S((log as int)-96)))
  }
}
