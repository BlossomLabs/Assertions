// SPDX-License-Identifier: MIT
include "EvmValues.dfy"

module EvmScalarValues {
  import D = Int
  import U256
  import I256
  import A = EvmArithmetic

  predicate Word(n: int) { 0 <= n < D.TWO_256 }
  predicate Signed(n: int) { D.MIN_I256 <= n <= D.MAX_I256 }
  function Abs(n: int): int { A.Abs(n) }
  function Trunc(a: int, b: int): int { if b == 0 then 0 else D.Div(a,b) }
  function Rem(a: int, b: int): int { if b == 0 then a else D.Rem(a,b) }
  function And(a: int, b: int): int
    requires Word(a) && Word(b)
    ensures Word(And(a,b))
  { U256.And(a as D.u256,b as D.u256) as int }
  function Or(a: int, b: int): int
    requires Word(a) && Word(b)
    ensures Word(Or(a,b))
  { U256.Or(a as D.u256,b as D.u256) as int }
  function Xor(a: int, b: int): int
    requires Word(a) && Word(b)
    ensures Word(Xor(a,b))
  { U256.Xor(a as D.u256,b as D.u256) as int }
}
