include "Model.dfy"
module OperationsBinaryLogSource {
  import M = OperationsBinaryLogModel
  function ToUint(b: bool): nat
    ensures ToUint(b) == M.Bool(b)
  { M.Iszero(M.Iszero(M.Bool(b))) }
  method Library(x: nat) returns (result: nat)
    requires x < M.Word
    ensures result == M.Log(x) && result < 256
  {
    M.KnownPowers();
    var r: bv8 := 0;
    assert M.Log(x) == (r as int)+M.Log(x/M.Power(r as int));
    assert x/M.Power(r as int) < M.Power(256);
    {
      var previous := r;
      var flag := ((ToUint((x > 340282366920938463463374607431768211455)) as bv8) << 7);
      r := M.Or(previous,flag);
      assert flag == (if x/M.Power(previous as int) >= M.Power(128) then 128 as bv8 else 0);
      assert previous&(128 as bv8) == 0 && (previous as int)+128 < 256;
      M.Stage(x,previous,128,r);
      assert r&(127 as bv8) == 0;
      assert M.Log(x) == (r as int)+M.Log(x/M.Power(r as int));
    }
    {
      var previous := r;
      var flag := ((ToUint(((x/M.Power(r as int)) > 18446744073709551615)) as bv8) << 6);
      r := M.Or(previous,flag);
      assert flag == (if x/M.Power(previous as int) >= M.Power(64) then 64 as bv8 else 0);
      assert previous&(64 as bv8) == 0 && (previous as int)+64 < 256;
      M.Stage(x,previous,64,r);
      assert r&(63 as bv8) == 0;
      assert M.Log(x) == (r as int)+M.Log(x/M.Power(r as int));
    }
    {
      var previous := r;
      var flag := ((ToUint(((x/M.Power(r as int)) > 4294967295)) as bv8) << 5);
      r := M.Or(previous,flag);
      assert flag == (if x/M.Power(previous as int) >= M.Power(32) then 32 as bv8 else 0);
      assert previous&(32 as bv8) == 0 && (previous as int)+32 < 256;
      M.Stage(x,previous,32,r);
      assert r&(31 as bv8) == 0;
      assert M.Log(x) == (r as int)+M.Log(x/M.Power(r as int));
    }
    {
      var previous := r;
      var flag := ((ToUint(((x/M.Power(r as int)) > 65535)) as bv8) << 4);
      r := M.Or(previous,flag);
      assert flag == (if x/M.Power(previous as int) >= M.Power(16) then 16 as bv8 else 0);
      assert previous&(16 as bv8) == 0 && (previous as int)+16 < 256;
      M.Stage(x,previous,16,r);
      assert r&(15 as bv8) == 0;
      assert M.Log(x) == (r as int)+M.Log(x/M.Power(r as int));
    }
    {
      var previous := r;
      var flag := ((ToUint(((x/M.Power(r as int)) > 255)) as bv8) << 3);
      r := M.Or(previous,flag);
      assert flag == (if x/M.Power(previous as int) >= M.Power(8) then 8 as bv8 else 0);
      assert previous&(8 as bv8) == 0 && (previous as int)+8 < 256;
      M.Stage(x,previous,8,r);
      assert r&(7 as bv8) == 0;
      assert M.Log(x) == (r as int)+M.Log(x/M.Power(r as int));
    }
    {
      var previous := r;
      var flag := ((ToUint(((x/M.Power(r as int)) > 15)) as bv8) << 2);
      r := M.Or(previous,flag);
      assert flag == (if x/M.Power(previous as int) >= M.Power(4) then 4 as bv8 else 0);
      assert previous&(4 as bv8) == 0 && (previous as int)+4 < 256;
      M.Stage(x,previous,4,r);
      assert r&(3 as bv8) == 0;
      assert M.Log(x) == (r as int)+M.Log(x/M.Power(r as int));
    }
    var q := x/M.Power(r as int);
    assert q < 16;
    var lookup := 6928917744019834342450304135053993530982274426945361611473370484834304;
    M.Table(q,lookup);
    M.SmallLog(q);
    var next := M.Or(r,(M.Byte((x/M.Power(r as int)),6928917744019834342450304135053993530982274426945361611473370484834304) as bv8));
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
    if (x == 0) { out := M.LogarithmUndefined(0); return; }
    var r := Library(x);
    out := M.Value(r);
  }
  method TableWitness()
  {
    M.BytePowers();
    var table := 6928917744019834342450304135053993530982274426945361611473370484834304;
    var value := M.Byte(2,table);
    assert value == 1;
  }

}
