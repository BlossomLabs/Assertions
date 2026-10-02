include "Model.dfy"
module OperationsScaledPowerSource {
  import B = OperationsBinaryLogModel
  import M = OperationsFullMulDivModel
  import I = OperationsFullMulDivBits
  import S = OperationsFullMulDivSource
  import R = OperationsScaledPowerModel
  method Step(a: nat,b: nat,base: nat) returns (out: M.Outcome)
    requires a < B.Word && b < B.Word && 0 < base < B.Word
    ensures out == M.UnsignedSpec(a,b,base,0)
    ensures out.Value? ==> 0 <= out.result < B.Word
  { out := S.Library(a,b,base); }
  method Run(entryX: nat,entryN: nat,base: nat) returns (out: M.Outcome)
    requires entryX < B.Word && entryN < B.Word && base < B.Word
    ensures out == R.Spec(entryX,entryN,base)
  {
    B.KnownPowers();
    var x: nat := entryX;
    var n: nat := entryN;
    if (base == 0) {
      ghost var payload := S.OpsPanic(18,seq(64,i => 0));
      out := M.Panic(18); return;
    }
    if (x == 0) { out := M.Value((if (n == 0) then base else 0)); return; }
    var result: nat := base;
    while (n > 0)
      invariant x < B.Word && n < B.Word && result < B.Word && base > 0
      invariant R.Trace(x,n,base,result) == R.Spec(entryX,entryN,base)
      decreases n
    {
      R.AndOne(n);
      if (I.And(n,1) == 1) {
        var step := Step(result,x,base);
        if step.Panic? { out := step; return; }
        result := step.result as nat;
      }
      n := (n/B.Power(1));
      if (n > 0) {
        var square := Step(x,x,base);
        if square.Panic? { out := square; return; }
        x := square.result as nat;
      }
    }
    out := M.Value(result);
  }
  method ShiftWitness()
  {
    B.KnownPowers();
    var n: nat := 5;
    n := (n/B.Power(1));
    assert n == 2;
  }
  method SquareWitness()
  {
    var x: nat := 4;
    var result: nat := 3;
    var base: nat := 3;
    var square := Step(x,x,base);
    assert square == M.Value(5);
  }
}
