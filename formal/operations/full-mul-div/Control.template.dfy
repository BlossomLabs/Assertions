include "Memory.dfy"
include "Helpers.generated.dfy"
module OperationsFullMulDivSource {
  import B = OperationsBinaryLogModel
  import M = OperationsFullMulDivModel
  import P = OperationsFullMulDivProduct
  import I = OperationsFullMulDivBits
  import V = OperationsFullMulDivInverse
  import C = OperationsFullMulDivRecombine
  import H = OperationsFullMulDivSignedHelpers
  import E = OperationsFullMulDivMemory
  function OpcodeDiv(n: nat,d: nat): nat
  { if d == 0 then 0 else P.Div(n,d) }
  function ToUint(b: bool): nat
    ensures ToUint(b) == B.Bool(b)
  { $CAST$ }
  method Ternary(condition: bool,a: nat,b: nat) returns (out: nat)
    requires a < B.Word && b < B.Word
    ensures out == (if condition then a else b)
  {
    B.KnownPowers();
    I.XorBound(a,b,256);
    out := $TERNARY$;
    if condition { I.XorCommute(a,b); I.XorCancel(b,a); }
    else { I.XorZero(b); }
  }
  ghost method MathPanic(code: nat,memory: seq<nat>) returns (payload: seq<nat>)
    requires code < B.Word && |memory| >= 64
    ensures payload == E.Canonical(code)
  {
    E.LowSelector();
    var first := E.Store(memory,$MATH_PANIC_FIRST_OFFSET$,$MATH_PANIC_SELECTOR$);
    var second := E.Store(first,$MATH_PANIC_SECOND_OFFSET$,code);
    payload := second[$MATH_PANIC_READ_OFFSET$..$MATH_PANIC_READ_OFFSET$+$MATH_PANIC_READ_LENGTH$];
    forall i: nat | i < 36
      ensures payload[i] == E.Canonical(code)[i]
    { if i < 4 { assert payload[i] == [78,72,123,113][i]; } else { assert payload[i] == E.Word(code)[i-4]; } }
  }
  ghost method OpsPanic(code: nat,memory: seq<nat>) returns (payload: seq<nat>)
    requires code < B.Word && |memory| >= 64
    ensures payload == E.Canonical(code)
  {
    E.HighSelector();
    var first := E.Store(memory,$OPS_PANIC_FIRST_OFFSET$,$OPS_PANIC_SELECTOR$);
    var second := E.Store(first,$OPS_PANIC_SECOND_OFFSET$,code);
    payload := second[$OPS_PANIC_READ_OFFSET$..$OPS_PANIC_READ_OFFSET$+$OPS_PANIC_READ_LENGTH$];
    forall i: nat | i < 36
      ensures payload[i] == E.Canonical(code)[i]
    { if i < 4 { assert payload[i] == [78,72,123,113][i]; } else { assert payload[i] == E.Word(code)[i-4]; } }
  }
  method Mul512(a: nat,b: nat) returns (high: nat,low: nat)
    requires a < B.Word && b < B.Word
    ensures high < B.Word && low < B.Word && high*B.Word+low == a*b
  {
    P.CRT(a,b);
    var mm := $MM$;
    low := $LOW$;
    high := $HIGH$;
  }
$UPDATES$
  method Library(x: nat,y: nat,entryDenominator: nat) returns (out: M.Outcome)
    requires x < B.Word && y < B.Word && entryDenominator < B.Word
    ensures out == (if entryDenominator == 0 then M.Panic(18) else if (x*y)/entryDenominator >= B.Word then M.Panic(17) else M.Value((x*y)/entryDenominator))
    ensures out.Value? ==> entryDenominator > 0 && 0 <= out.result < B.Word
  {
    var denominator := entryDenominator;
    B.KnownPowers();
    B.ProductNonnegative(x,y);
    var high,low := Mul512(x,y);
    if $HIGH_ZERO$ {
      if denominator == 0 { out := M.Panic(18); return; }
      out := M.Value(P.Div(low,denominator));
      return;
    }
    if $OVERFLOW$ {
      var code := Ternary(denominator == 0,18,17);
      ghost var payload := MathPanic(code,seq(64,i => 0));
      if denominator > 0 { M.QuotientOverflow(x*y,denominator); }
      out := M.Panic(code);
      return;
    }
    assert 0 < high < denominator;
    M.QuotientOverflow(x*y,denominator);
    ghost var q := P.Div(x*y,denominator);
    assert q < B.Word;
    var remainder := $REMAINDER$;
    ghost var originalHigh := high;
    ghost var originalLow := low;
    P.Borrow(high,low,remainder);
    high := $BORROW_HIGH$;
    low := $BORROW_LOW$;
    assert high*B.Word+low == q*denominator;
    var twos := $TWOS$;
    I.Lowest(256,denominator);
    I.Factors(256,denominator);
    assert twos == I.Twos(denominator);
    ghost var k: nat :| k < 256 && twos == B.Power(k);
    ghost var oldDenominator := denominator;
    ghost var divisor := twos;
    ghost var lowBeforeDivision := low;
    denominator := $DIV_DENOM$;
    low := $DIV_LOW$;
    assert denominator%2 == 1;
    C.Flip(divisor);
    twos := $FLIP$;
    assert twos == (B.Word/divisor)%B.Word;
    assert (high*twos)%B.Word == (high*(B.Word/divisor))%B.Word;
    assert oldDenominator == divisor*denominator;
    C.Associate(q,divisor,denominator);
    assert high < B.Word && lowBeforeDivision < B.Word && k <= 255;
    assert high*B.Word+lowBeforeDivision == q*(B.Power(k)*denominator);
    C.Combine(high,lowBeforeDivision,k,q,denominator);
    low := $COMBINE$;
    assert low == (q*denominator)%B.Word;
    I.XorBound((3*denominator)%B.Word,2,256);
    var inverse := $INVERSE_SEED$;
    V.Seed(denominator);
    assert (denominator*inverse)%B.Power(4) == 1;
    inverse := Update4(denominator,inverse);
    inverse := Update8(denominator,inverse);
    inverse := Update16(denominator,inverse);
    inverse := Update32(denominator,inverse);
    inverse := Update64(denominator,inverse);
    inverse := Update128(denominator,inverse);
    assert (denominator*inverse)%B.Word == 1;
    C.Final(q,denominator,low,inverse);
    var result := $RESULT$;
    out := M.Value(result);
  }
  method Unsigned(a: nat,b: nat,denominator: nat,rounding: nat) returns (out: M.Outcome)
    requires a < B.Word && b < B.Word && denominator < B.Word && rounding <= 2
    ensures out == M.UnsignedSpec(a,b,denominator,rounding)
  {
    out := Library(a,b,denominator);
    if out.Panic? { return; }
    var result := out.result;
    if $UNSIGNED_ROUND$ {
      if result+1 >= B.Word { out := M.Panic(17); return; }
      result := result+1;
    }
    out := M.Value(result);
  }
  method Signed(a: int,b: int,denominator: int,rounding: nat) returns (out: M.Outcome)
    requires M.Signed(a) && M.Signed(b) && M.Signed(denominator) && rounding <= 2
    ensures out == M.SignedSpec(a,b,denominator,rounding)
  {
    var negative := $SIGNED_NEGATIVE$;
    H.MagnitudeCorrect(a); H.MagnitudeCorrect(b); H.MagnitudeCorrect(denominator);
    var x := H.MagnitudeImpl(a);
    var y := H.MagnitudeImpl(b);
    var d := H.MagnitudeImpl(denominator);
    out := Library(x,y,d);
    if out.Panic? { return; }
    var result := out.result;
    if $SIGNED_ROUND$ {
      if result+1 >= B.Word { out := M.Panic(17); return; }
      result := result+1;
    }
    H.SignedMagnitudeCorrect(result,negative);
    var restored := H.SignedMagnitudeImpl(result,negative);
    if restored.Panic? {
      ghost var payload := OpsPanic(17,seq(64,i => 0));
      out := M.Panic(17);
    } else { out := M.Value(restored.value); }
  }
  method CarryWitness()
  {
    B.KnownPowers();
    var mm: nat := 0;
    var low: nat := 1;
    var high := $HIGH$;
    assert high == B.Word-2;
  }
  method SeedWitness()
  {
    B.KnownPowers();
    I.XorTwo(9);
    var denominator: nat := 3;
    var inverse := $INVERSE_SEED$;
    assert (denominator*inverse)%16 == 1;
  }
}
