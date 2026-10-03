include "../../../foundations/EvmScalarValues.dfy"
module OperationsScalarModel {
  import V = EvmScalarValues
  const Mod: int := 0x10000000000000000000000000000000000000000000000000000000000000000
  const Half: int := 0x8000000000000000000000000000000000000000000000000000000000000000
  const Low: int := -Half
  const High: int := Half - 1
  datatype Outcome = Value(value: int) | Panic(code: int)
  predicate Word(x: int) { 0 <= x < Mod }
  predicate Signed(x: int) { Low <= x <= High }
  function Abs(x: int): int
  { V.Abs(x) }
  function Wrap(x: int): int { x % Mod }
  function CheckedU(x: int): Outcome { if Word(x) then Value(x) else Panic(17) }
  function CheckedS(x: int): Outcome { if Signed(x) then Value(x) else Panic(17) }
  function Quotient(a: int, b: int): int { if b == 0 then 0 else a / b }
  function Remainder(a: int, b: int): int { if b == 0 then 0 else a % b }
  function Trunc(a: int, b: int): int
  { V.Trunc(a,b) }
  function Rem(a: int, b: int): int
  { V.Rem(a,b) }
  function And(a: int, b: int): int
    requires Word(a) && Word(b)
    ensures Word(And(a,b))
  { V.And(a,b) }
  function Or(a: int, b: int): int
    requires Word(a) && Word(b)
    ensures Word(Or(a,b))
  { V.Or(a,b) }
  function Xor(a: int, b: int): int
    requires Word(a) && Word(b)
    ensures Word(Xor(a,b))
  { V.Xor(a,b) }
  function Left(a: int, b: int): int
    requires Word(a) && Word(b)
    ensures Word(Left(a,b))
  { if b >= 256 then 0 else ((a as bv256) << (b as bv256)) as int }
  function Right(a: int, b: int): int
    requires Word(a) && Word(b)
    ensures Word(Right(a,b))
  { if b >= 256 then 0 else ((a as bv256) >> (b as bv256)) as int }
  function ArithmeticRight(a: int, b: int): int
    requires Signed(a) && Word(b)
  { if a >= 0 then Right(a, b) else -1 - Right(-1-a, b) }
}
