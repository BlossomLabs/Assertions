// SPDX-License-Identifier: MIT
// Full-width physical body composition; gas/resource adequacy remains explicit.
include "../iota/AllocationConnection.dfy"
include "../iota-allocation/Engine.dfy"
include "../iota-loop/Engine.dfy"
include "../iota-return/Control.generated.dfy"
include "../copy/Lift.dfy"
module BytecodeIotaBodyConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import A = BytecodeIotaArithmetic
  import AC = BytecodeIotaAllocationConnection
  import AL = BytecodeIotaAllocationEngine
  import LE = BytecodeIotaLoopEngine
  import LB = BytecodeIotaLoopBody
  import LX = BytecodeIotaLoopExit
  import RC = BytecodeIotaReturnControl
  import R = BytecodeIotaReturnMemory
  import C = BytecodeCopyExecution
  import L = BytecodeCopyTraceLift
  predicate Matches(code: seq<S.Byte>) {
    AC.Matches(code) && AL.Matches(code) && LB.Matches(code) && LX.Matches(code) && RC.Matches(code)
  }
  function Destinations(): set<nat> {
    AC.Destinations()+AL.Destinations()+LE.Destinations()+RC.Destinations()
  }
  function Result(n: S.Word): S.State {
    if n > A.Limit() then S.Reverted(G.Encode(0x4e487b71,4)+G.Encode(17,32))
    else if n >= 0x800000000000000 then S.Reverted(G.Encode(0x4e487b71,4)+G.Encode(65,32))
    else S.Returned(R.Bytes(n))
  }
  ghost method Run(code: seq<S.Byte>, n: S.Word, value: S.Word, data: seq<S.Byte>)
    returns (state: S.State, trace: seq<S.State>)
    requires Matches(code) && |data| < G.Modulus()
    ensures state == Result(n)
    ensures C.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == S.Running(5540,[2368205965,518,n],S.Store([],64,128))
    ensures trace[|trace|-1] == state
  {
    state,trace := AC.Run(code,n,value,data);
    L.Trace(code,AC.Destinations(),value,data,trace);
    C.WidenTrace(code,AC.Destinations(),Destinations(),value,data,trace);
    if n < 0x800000000000000 {
      assert n <= A.Limit();
      var prepared,allocation := AL.Run(code,n,value,data);
      C.WidenTrace(code,AL.Destinations(),Destinations(),value,data,allocation);
      C.Join(code,Destinations(),value,data,trace,allocation);
      trace := trace+allocation[1..]; state := prepared;
      var filled,loop := LE.Run(code,n,value,data);
      L.Trace(code,LE.Destinations(),value,data,loop);
      C.WidenTrace(code,LE.Destinations(),Destinations(),value,data,loop);
      C.Join(code,Destinations(),value,data,trace,loop);
      trace := trace+loop[1..]; state := filled;
      var terminal,serialized := RC.Run(code,n,value,data);
      C.WidenTrace(code,RC.Destinations(),Destinations(),value,data,serialized);
      C.Join(code,Destinations(),value,data,trace,serialized);
      trace := trace+serialized[1..]; state := terminal;
    }
  }
}
