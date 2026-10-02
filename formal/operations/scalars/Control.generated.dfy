include "Model.dfy"
module OperationsScalarSource {
  import M = OperationsScalarModel
  function addU(a: int, b: int): M.Outcome
    requires M.Word(a) && M.Word(b)
  { M.CheckedU((a + b)) }

  function addS(a: int, b: int): M.Outcome
    requires M.Signed(a) && M.Signed(b)
  { M.CheckedS((a + b)) }

  function subU(a: int, b: int): M.Outcome
    requires M.Word(a) && M.Word(b)
  { M.CheckedU((a - b)) }

  function subS(a: int, b: int): M.Outcome
    requires M.Signed(a) && M.Signed(b)
  { M.CheckedS((a - b)) }

  function mulU(a: int, b: int): M.Outcome
    requires M.Word(a) && M.Word(b)
  { M.CheckedU((a * b)) }

  function mulS(a: int, b: int): M.Outcome
    requires M.Signed(a) && M.Signed(b)
  { M.CheckedS((a * b)) }

  function divU(a: int, b: int): M.Outcome
    requires M.Word(a) && M.Word(b)
  { (if b == 0 then M.Panic(18) else M.Value(M.Quotient(a, b))) }

  function divS(a: int, b: int): M.Outcome
    requires M.Signed(a) && M.Signed(b)
  { (if b == 0 then M.Panic(18) else if a == M.Low && b == -1 then M.Panic(17) else M.Value(M.Trunc(a, b))) }

  function modU(a: int, b: int): M.Outcome
    requires M.Word(a) && M.Word(b)
  { (if b == 0 then M.Panic(18) else M.Value(M.Remainder(a, b))) }

  function modS(a: int, b: int): M.Outcome
    requires M.Signed(a) && M.Signed(b)
  { (if b == 0 then M.Panic(18) else M.Value(M.Rem(a, b))) }

  function minU(a: int, b: int): M.Outcome
    requires M.Word(a) && M.Word(b)
  { M.Value((if (a < b) then a else b)) }

  function minS(a: int, b: int): M.Outcome
    requires M.Signed(a) && M.Signed(b)
  { M.Value((if (a < b) then a else b)) }

  function maxU(a: int, b: int): M.Outcome
    requires M.Word(a) && M.Word(b)
  { M.Value((if (a > b) then a else b)) }

  function maxS(a: int, b: int): M.Outcome
    requires M.Signed(a) && M.Signed(b)
  { M.Value((if (a > b) then a else b)) }

  function absDiffU(a: int, b: int): M.Outcome
    requires M.Word(a) && M.Word(b)
  { M.Value((if (a > b) then (a - b) else (b - a))) }

  function absDiffS(a: int, b: int): M.Outcome
    requires M.Signed(a) && M.Signed(b)
  { M.Value(M.Wrap((if (a > b) then (M.Wrap(a) - M.Wrap(b)) else (M.Wrap(b) - M.Wrap(a))))) }

  function eqU(a: int, b: int): bool
    requires M.Word(a) && M.Word(b)
  { (a == b) }

  function neU(a: int, b: int): bool
    requires M.Word(a) && M.Word(b)
  { (a != b) }

  function ltU(a: int, b: int): bool
    requires M.Word(a) && M.Word(b)
  { (a < b) }

  function ltS(a: int, b: int): bool
    requires M.Signed(a) && M.Signed(b)
  { (a < b) }

  function gtU(a: int, b: int): bool
    requires M.Word(a) && M.Word(b)
  { (a > b) }

  function gtS(a: int, b: int): bool
    requires M.Signed(a) && M.Signed(b)
  { (a > b) }

  function leU(a: int, b: int): bool
    requires M.Word(a) && M.Word(b)
  { (a <= b) }

  function leS(a: int, b: int): bool
    requires M.Signed(a) && M.Signed(b)
  { (a <= b) }

  function geU(a: int, b: int): bool
    requires M.Word(a) && M.Word(b)
  { (a >= b) }

  function geS(a: int, b: int): bool
    requires M.Signed(a) && M.Signed(b)
  { (a >= b) }

  function bitAndU(a: int, b: int): M.Outcome
    requires M.Word(a) && M.Word(b)
  { M.Value(M.And(a, b)) }

  function bitOrU(a: int, b: int): M.Outcome
    requires M.Word(a) && M.Word(b)
  { M.Value(M.Or(a, b)) }

  function bitXorU(a: int, b: int): M.Outcome
    requires M.Word(a) && M.Word(b)
  { M.Value(M.Xor(a, b)) }

  function shlU(a: int, b: int): M.Outcome
    requires M.Word(a) && M.Word(b)
  { M.Value(M.Left(a, b)) }

  function shrU(a: int, b: int): M.Outcome
    requires M.Word(a) && M.Word(b)
  { M.Value(M.Right(a, b)) }

  function shrS(a: int, b: int): M.Outcome
    requires M.Signed(a) && M.Word(b)
  { M.Value(M.ArithmeticRight(a, b)) }

  function bitSetU(a: int, b: int): bool
    requires M.Word(a) && M.Word(b)
  { (M.And(M.Right(a, b), 1) == 1) }
}
