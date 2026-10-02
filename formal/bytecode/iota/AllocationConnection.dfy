// SPDX-License-Identifier: MIT
include "MultiplyConnection.dfy"
include "AllocationGuard.generated.dfy"
include "AllocationLimit.generated.dfy"
include "Panic41.generated.dfy"
module BytecodeIotaAllocationConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import A = BytecodeIotaArithmetic
  import MC = BytecodeIotaMultiplyConnection
  import MF = BytecodeIotaMultiply
  import MO = BytecodeIotaMultiplyOverflow
  import P17 = BytecodeIotaPanic17
  import Guard = BytecodeIotaAllocationGuard
  import Limit = BytecodeIotaAllocationLimit
  import P41 = BytecodeIotaPanic41
  import E = BytecodeScanExecution
  predicate Matches(code: seq<S.Byte>) {
    MF.Matches(code) && MO.Matches(code) && P17.Matches(code) &&
    Guard.Matches(code) && Limit.Matches(code) && P41.Matches(code)
  }
  function Destinations(): set<nat> {
    MC.Destinations()+Guard.Destinations()+Limit.Destinations()+P41.Destinations()
  }
  ghost method Run(code: seq<S.Byte>, n: S.Word, value: S.Word, data: seq<S.Byte>)
    returns (state: S.State, trace: seq<S.State>)
    requires Matches(code)
    ensures state == (if n > A.Limit()
                      then S.Reverted(G.Encode(0x4e487b71,4)+G.Encode(17,32))
                      else if n >= 0x800000000000000
                        then S.Reverted(G.Encode(0x4e487b71,4)+G.Encode(65,32))
                        else S.Running(5576,[2368205965,518,n,96,n*32],S.Store([],64,128)))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == S.Running(5540,[2368205965,518,n],S.Store([],64,128))
    ensures trace[|trace|-1] == state
  {
    if n > A.Limit() {
      state,trace := MC.Rejection(code,n,value,data);
      E.WidenTrace(code,MC.Destinations(),Destinations(),value,data,trace);
    } else {
      A.Fit(n);
      var multiplied,left := MC.Success(code,n,value,data);
      E.WidenTrace(code,MC.Destinations(),Destinations(),value,data,left);
      if n < 0x800000000000000 {
        var accepted,right := Guard.Run(code,n,value,data);
        E.WidenTrace(code,Guard.Destinations(),Destinations(),value,data,right);
        E.Join(code,Destinations(),value,data,left,right);
        state := accepted;
        trace := left+right[1..];
      } else {
        var guarded,middle := Limit.Run(code,n,value,data);
        var prefix: seq<S.Word> := [2368205965,518,n,96,A.Product(n),5576];
        assert guarded == S.Running(23354,prefix,S.Store([],64,128));
        var terminal,right := P41.Run(code,prefix,value,data);
        E.WidenTrace(code,Limit.Destinations(),Destinations(),value,data,middle);
        E.WidenTrace(code,P41.Destinations(),Destinations(),value,data,right);
        E.Join(code,Destinations(),value,data,left,middle);
        var partial := left+middle[1..];
        E.Join(code,Destinations(),value,data,partial,right);
        state := terminal;
        trace := partial+right[1..];
      }
    }
  }
}
