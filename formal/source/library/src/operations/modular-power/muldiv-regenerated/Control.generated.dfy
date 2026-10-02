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
  { B.Iszero(B.Iszero(B.Bool(b))) }
  method Ternary(condition: bool,a: nat,b: nat) returns (out: nat)
    requires a < B.Word && b < B.Word
    ensures out == (if condition then a else b)
  {
    B.KnownPowers();
    I.XorBound(a,b,256);
    out := I.Xor(b,((I.Xor(a,b) * ToUint(condition)) % B.Word));
    if condition { I.XorCommute(a,b); I.XorCancel(b,a); }
    else { I.XorZero(b); }
  }
  ghost method MathPanic(code: nat,memory: seq<nat>) returns (payload: seq<nat>)
    requires code < B.Word && |memory| >= 64
    ensures payload == E.Canonical(code)
  {
    E.LowSelector();
    var first := E.Store(memory,0,1313373041);
    var second := E.Store(first,32,code);
    payload := second[28..28+36];
    forall i: nat | i < 36
      ensures payload[i] == E.Canonical(code)[i]
    { if i < 4 { assert payload[i] == [78,72,123,113][i]; } else { assert payload[i] == E.Word(code)[i-4]; } }
  }
  ghost method OpsPanic(code: nat,memory: seq<nat>) returns (payload: seq<nat>)
    requires code < B.Word && |memory| >= 64
    ensures payload == E.Canonical(code)
  {
    E.HighSelector();
    var first := E.Store(memory,0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    var second := E.Store(first,4,code);
    payload := second[0..0+36];
    forall i: nat | i < 36
      ensures payload[i] == E.Canonical(code)[i]
    { if i < 4 { assert payload[i] == [78,72,123,113][i]; } else { assert payload[i] == E.Word(code)[i-4]; } }
  }
  method Mul512(a: nat,b: nat) returns (high: nat,low: nat)
    requires a < B.Word && b < B.Word
    ensures high < B.Word && low < B.Word && high*B.Word+low == a*b
  {
    P.CRT(a,b);
    var mm := (if (B.Word-1-0) == 0 then 0 else (a * b) % (B.Word-1-0));
    low := ((a * b) % B.Word);
    high := ((((mm - low) % B.Word) - B.Bool(mm < low)) % B.Word);
  }
  method Update4(denominator: nat,inverse: nat) returns (next: nat)
    requires denominator < B.Word && inverse < B.Word
    requires (denominator*inverse)%B.Power(4) == 1
    ensures next < B.Word && (denominator*next)%B.Power(8) == 1
  {
    V.Hensel(denominator,inverse,4);
    next := ((inverse * ((2 - ((denominator * inverse) % B.Word)) % B.Word)) % B.Word);
    assert next == V.Update(denominator,inverse);
  }
  method Update8(denominator: nat,inverse: nat) returns (next: nat)
    requires denominator < B.Word && inverse < B.Word
    requires (denominator*inverse)%B.Power(8) == 1
    ensures next < B.Word && (denominator*next)%B.Power(16) == 1
  {
    V.Hensel(denominator,inverse,8);
    next := ((inverse * ((2 - ((denominator * inverse) % B.Word)) % B.Word)) % B.Word);
    assert next == V.Update(denominator,inverse);
  }
  method Update16(denominator: nat,inverse: nat) returns (next: nat)
    requires denominator < B.Word && inverse < B.Word
    requires (denominator*inverse)%B.Power(16) == 1
    ensures next < B.Word && (denominator*next)%B.Power(32) == 1
  {
    V.Hensel(denominator,inverse,16);
    next := ((inverse * ((2 - ((denominator * inverse) % B.Word)) % B.Word)) % B.Word);
    assert next == V.Update(denominator,inverse);
  }
  method Update32(denominator: nat,inverse: nat) returns (next: nat)
    requires denominator < B.Word && inverse < B.Word
    requires (denominator*inverse)%B.Power(32) == 1
    ensures next < B.Word && (denominator*next)%B.Power(64) == 1
  {
    V.Hensel(denominator,inverse,32);
    next := ((inverse * ((2 - ((denominator * inverse) % B.Word)) % B.Word)) % B.Word);
    assert next == V.Update(denominator,inverse);
  }
  method Update64(denominator: nat,inverse: nat) returns (next: nat)
    requires denominator < B.Word && inverse < B.Word
    requires (denominator*inverse)%B.Power(64) == 1
    ensures next < B.Word && (denominator*next)%B.Power(128) == 1
  {
    V.Hensel(denominator,inverse,64);
    next := ((inverse * ((2 - ((denominator * inverse) % B.Word)) % B.Word)) % B.Word);
    assert next == V.Update(denominator,inverse);
  }
  method Update128(denominator: nat,inverse: nat) returns (next: nat)
    requires denominator < B.Word && inverse < B.Word
    requires (denominator*inverse)%B.Power(128) == 1
    ensures next < B.Word && (denominator*next)%B.Power(256) == 1
  {
    V.Hensel(denominator,inverse,128);
    next := ((inverse * ((2 - ((denominator * inverse) % B.Word)) % B.Word)) % B.Word);
    assert next == V.Update(denominator,inverse);
  }
  method Library(x: nat,y: nat,entryDenominator: nat) returns (out: M.Outcome)
    requires x < B.Word && y < B.Word && entryDenominator < B.Word
    ensures out == (if entryDenominator == 0 then M.Panic(18) else if (x*y)/entryDenominator >= B.Word then M.Panic(17) else M.Value((x*y)/entryDenominator))
    ensures out.Value? ==> entryDenominator > 0 && 0 <= out.result < B.Word
  {
    var denominator := entryDenominator;
    B.KnownPowers();
    B.ProductNonnegative(x,y);
    var high,low := Mul512(x,y);
    if (high == 0) {
      if denominator == 0 { out := M.Panic(18); return; }
      out := M.Value(P.Div(low,denominator));
      return;
    }
    if (denominator <= high) {
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
    var remainder := (if denominator == 0 then 0 else (x * y) % denominator);
    ghost var originalHigh := high;
    ghost var originalLow := low;
    P.Borrow(high,low,remainder);
    high := ((high - B.Bool(remainder > low)) % B.Word);
    low := ((low - remainder) % B.Word);
    assert high*B.Word+low == q*denominator;
    var twos := I.And(denominator,((0 - denominator) % B.Word));
    I.Lowest(256,denominator);
    I.Factors(256,denominator);
    assert twos == I.Twos(denominator);
    ghost var k: nat :| k < 256 && twos == B.Power(k);
    ghost var oldDenominator := denominator;
    ghost var divisor := twos;
    ghost var lowBeforeDivision := low;
    denominator := OpcodeDiv(denominator,twos);
    low := OpcodeDiv(low,twos);
    assert denominator%2 == 1;
    C.Flip(divisor);
    twos := ((OpcodeDiv(((0 - twos) % B.Word),twos) + 1) % B.Word);
    assert twos == (B.Word/divisor)%B.Word;
    assert (high*twos)%B.Word == (high*(B.Word/divisor))%B.Word;
    assert oldDenominator == divisor*denominator;
    C.Associate(q,divisor,denominator);
    assert high < B.Word && lowBeforeDivision < B.Word && k <= 255;
    assert high*B.Word+lowBeforeDivision == q*(B.Power(k)*denominator);
    C.Combine(high,lowBeforeDivision,k,q,denominator);
    low := I.Or(low,((high * twos) % B.Word));
    assert low == (q*denominator)%B.Word;
    I.XorBound((3*denominator)%B.Word,2,256);
    var inverse := I.Xor(((3 * denominator) % B.Word),2);
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
    var result := ((low * inverse) % B.Word);
    out := M.Value(result);
  }
  method Unsigned(a: nat,b: nat,denominator: nat,rounding: nat) returns (out: M.Outcome)
    requires a < B.Word && b < B.Word && denominator < B.Word && rounding <= 2
    ensures out == M.UnsignedSpec(a,b,denominator,rounding)
  {
    out := Library(a,b,denominator);
    if out.Panic? { return; }
    var result := out.result;
    if ((rounding == 2) && (((a * b) % denominator) != 0)) {
      if result+1 >= B.Word { out := M.Panic(17); return; }
      result := result+1;
    }
    out := M.Value(result);
  }
  method Signed(a: int,b: int,denominator: int,rounding: nat) returns (out: M.Outcome)
    requires M.Signed(a) && M.Signed(b) && M.Signed(denominator) && rounding <= 2
    ensures out == M.SignedSpec(a,b,denominator,rounding)
  {
    var negative := (((a < 0) != (b < 0)) != (denominator < 0));
    H.MagnitudeCorrect(a); H.MagnitudeCorrect(b); H.MagnitudeCorrect(denominator);
    var x := H.MagnitudeImpl(a);
    var y := H.MagnitudeImpl(b);
    var d := H.MagnitudeImpl(denominator);
    out := Library(x,y,d);
    if out.Panic? { return; }
    var result := out.result;
    if ((((x * y) % d) != 0) && ((negative && (rounding == 1)) || (!negative && (rounding == 2)))) {
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
    var high := ((((mm - low) % B.Word) - B.Bool(mm < low)) % B.Word);
    assert high == B.Word-2;
  }
  method SeedWitness()
  {
    B.KnownPowers();
    I.XorTwo(9);
    var denominator: nat := 3;
    var inverse := I.Xor(((3 * denominator) % B.Word),2);
    assert (denominator*inverse)%16 == 1;
  }
}
