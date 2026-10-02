include "../full-mul-div/Connection.dfy"
module OperationsScaledPowerModel {
  import B = OperationsBinaryLogModel
  import M = OperationsFullMulDivModel
  import I = OperationsFullMulDivBits
  lemma AndOne(n: nat)
    ensures I.And(n,1) == n%2
  { }
  function Trace(x: nat,n: nat,base: nat,accumulator: nat): M.Outcome
    requires x < B.Word && base < B.Word && accumulator < B.Word && base > 0
    decreases n
  {
    if n == 0 then M.Value(accumulator)
    else var selected := if n%2 == 1 then M.UnsignedSpec(accumulator,x,base,0) else M.Value(accumulator);
         if selected.Panic? then selected
         else var remaining := n/2;
              if remaining == 0 then selected
              else var square := M.UnsignedSpec(x,x,base,0);
                   if square.Panic? then square else Trace(square.result as nat,remaining,base,selected.result as nat)
  }
  function Spec(x: nat,n: nat,base: nat): M.Outcome
    requires x < B.Word && n < B.Word && base < B.Word
  {
    if base == 0 then M.Panic(18)
    else if x == 0 then M.Value(if n == 0 then base else 0)
    else Trace(x,n,base,base)
  }
  lemma TraceRange(x: nat,n: nat,base: nat,accumulator: nat)
    requires x < B.Word && base < B.Word && accumulator < B.Word && base > 0
    ensures Trace(x,n,base,accumulator).Value? ==> 0 <= Trace(x,n,base,accumulator).result < B.Word
    ensures Trace(x,n,base,accumulator).Panic? ==> Trace(x,n,base,accumulator).code == 17
    decreases n
  {
    if n > 0 {
      var selected := if n%2 == 1 then M.UnsignedSpec(accumulator,x,base,0) else M.Value(accumulator);
      if selected.Value? && n/2 > 0 {
        var square := M.UnsignedSpec(x,x,base,0);
        if square.Value? { TraceRange(square.result as nat,n/2,base,selected.result as nat); }
      }
    }
  }
}
