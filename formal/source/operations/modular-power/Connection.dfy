include "Control.generated.dfy"
module OperationsModularPowerConnection {
  import B = OperationsBinaryLogModel
  import Q = OperationsFullMulDivModel
  import M = OperationsModularPowerModel
  import R = OperationsModularPowerMemory
  import W = OperationsModularPowerWorld
  import S = OperationsModularPowerSource
  method UnsignedUnsigned(a: nat,e: nat,m: nat,memory: seq<nat>,ptr: nat,world: (nat,nat,nat) -> W.Reply)
    returns (out: M.Outcome)
    requires a < B.Word && e < B.Word && m < B.Word && R.Heap(memory,ptr) && W.World(world)
    ensures out == M.UnsignedUnsigned(a,e,m)
    ensures out.Value? ==> 0 <= out.result < m
    ensures out.Panic? ==> m == 0 && out.code == 18
  { out := S.UnsignedUnsigned(a,e,m,memory,ptr,world); }
  method SignedUnsigned(a: int,e: nat,m: int,memory: seq<nat>,ptr: nat,world: (nat,nat,nat) -> W.Reply)
    returns (out: M.Outcome)
    requires Q.Signed(a) && e < B.Word && Q.Signed(m) && R.Heap(memory,ptr) && W.World(world)
    ensures out == M.SignedUnsigned(a,e,m)
    ensures out.Value? ==> Q.Signed(out.result) && Q.Abs(out.result) < Q.Abs(m)
    ensures out.Panic? ==> m == 0 && out.code == 18
  { out := S.SignedUnsigned(a,e,m,memory,ptr,world); }
  method UnsignedSigned(a: nat,e: int,m: nat,memory: seq<nat>,ptr: nat,world: (nat,nat,nat) -> W.Reply)
    returns (out: M.Outcome)
    requires a < B.Word && Q.Signed(e) && m < B.Word && R.Heap(memory,ptr) && W.World(world)
    ensures out == M.UnsignedSigned(a,e,m)
    ensures out.Value? ==> 0 <= out.result < m
    ensures out.Panic? ==> m == 0 && out.code == 18
    ensures out.MissingInverse? ==> e < 0 && out.base == a && out.modulus == m
  { out := S.UnsignedSigned(a,e,m,memory,ptr,world); }
  method SignedSigned(a: int,e: int,m: int,memory: seq<nat>,ptr: nat,world: (nat,nat,nat) -> W.Reply)
    returns (out: M.Outcome)
    requires Q.Signed(a) && Q.Signed(e) && Q.Signed(m) && R.Heap(memory,ptr) && W.World(world)
    ensures out == M.SignedSigned(a,e,m)
    ensures out.Value? ==> Q.Signed(out.result) && Q.Abs(out.result) < Q.Abs(m)
    ensures out.Panic? ==> m == 0 && out.code == 18
    ensures out.MissingInverse? ==> e < 0 && out.base == Q.Abs(a) && out.modulus == Q.Abs(m)
  { out := S.SignedSigned(a,e,m,memory,ptr,world); }
}
