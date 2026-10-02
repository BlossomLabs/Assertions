include "Model.dfy"
module OperationsBinaryLogSource {
  import M = OperationsBinaryLogModel
  function ToUint(b: bool): nat
    ensures ToUint(b) == M.Bool(b)
  { $CAST$ }
  method Library(x: nat) returns (result: nat)
    requires x < M.Word
    ensures result == M.Log(x) && result < 256
  {
    M.KnownPowers();
    var r: bv8 := 0;
    assert M.Log(x) == (r as int)+M.Log(x/M.Power(r as int));
    assert x/M.Power(r as int) < M.Power(256);
$STAGES$
    var q := x/M.Power(r as int);
    assert q < 16;
    var lookup := $TABLE$;
    M.Table(q,lookup);
    M.SmallLog(q);
    var next := $RETURN$;
    assert r&(M.Byte(q,lookup) as bv8) == 0;
    assert (r as int)+M.Byte(q,lookup) < 256;
    M.OrClear(r,M.Byte(q,lookup) as bv8);
    assert (next as int) == M.Log(x);
    result := next as int;
  }
  method Public(x: nat) returns (out: M.Outcome)
    requires x < M.Word
    ensures out == M.Spec(x)
    ensures out.Value? ==> out.result < 256
  {
    if $ZERO$ { out := M.LogarithmUndefined(0); return; }
    var r := Library(x);
    out := M.Value(r);
  }
  method TableWitness()
  {
    M.BytePowers();
    var table := $TABLE$;
    var value := M.Byte(2,table);
    assert value == 1;
  }

}
