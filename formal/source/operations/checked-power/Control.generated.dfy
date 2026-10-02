include "Model.dfy"
module OperationsCheckedPowerSource {
  import M = OperationsCheckedPowerModel
  method Unsigned(a: nat,b: nat) returns (out: M.Outcome)
    requires a < M.Word && b < M.Word
    ensures out == M.Unsigned(a,b)
  {
    M.PowerNonnegative(a,b);
    var result := M.Power(a,b);
    if result >= M.Word { out := M.Panic(17); return; }
    out := M.Value(result);
  }
  method Signed(a0: int,b0: nat) returns (out: M.Outcome)
    requires M.Signed(a0) && b0 < M.Word
    ensures out == M.SignedSpec(a0,b0)
    ensures out.Value? ==> out.result == M.Power(a0,b0) && M.Signed(out.result)
  {
    var a := a0;
    var b := b0;
    var result := 1;
    M.TraceMath(a0,b0,1);
    while (b != 0)
      invariant M.Signed(a) && M.Signed(result) && 0 <= b < M.Word
      invariant M.SignedSpec(a0,b0) == M.Trace(a,b,result)
      decreases b
    {
      ghost var before := M.Trace(a,b,result);
      if ((b % 2) != 0) {
        var product := (result * a);
        if !M.Signed(product) { out := M.Panic(17); return; }
        result := product;
      }
      var nextB := (b / 2);
      b := nextB;
      if (b != 0) {
        var square := (a * a);
        if !M.Signed(square) { out := M.Panic(17); return; }
        a := square;
      }
      assert before == M.Trace(a,b,result);
    }
    out := M.Value(result);
  }
  method UnsignedWitness()
  {
    var a := 2;
    var b := 3;
    var result := M.Power(a,b);
    assert result == 8;
  }
  method OddWitness()
  {
    var b := 3;
    assert ((b % 2) != 0);
  }
}
