// SPDX-License-Identifier: MIT
include "Multiply.generated.dfy"
include "MultiplyOverflow.generated.dfy"
include "Panic17.generated.dfy"
module BytecodeIotaMultiplyConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import A = BytecodeIotaArithmetic
  import Fit = BytecodeIotaMultiply
  import Overflow = BytecodeIotaMultiplyOverflow
  import Panic = BytecodeIotaPanic17
  import E = BytecodeScanExecution
  function Destinations(): set<nat> {
    Fit.Destinations()+Overflow.Destinations()+Panic.Destinations()
  }
  ghost method Success(code: seq<S.Byte>, n: S.Word, value: S.Word, data: seq<S.Byte>)
    returns (state: S.State, trace: seq<S.State>)
    requires Fit.Matches(code) && n <= A.Limit()
    ensures state == S.Running(5553,[2368205965,518,n,96,n*32],S.Store([],64,128))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == S.Running(5540,[2368205965,518,n],S.Store([],64,128))
    ensures trace[|trace|-1] == state
  {
    A.Fit(n);
    state,trace := Fit.Run(code,n,value,data);
    E.WidenTrace(code,Fit.Destinations(),Destinations(),value,data,trace);
  }
  ghost method Rejection(code: seq<S.Byte>, n: S.Word, value: S.Word, data: seq<S.Byte>)
    returns (state: S.State, trace: seq<S.State>)
    requires Overflow.Matches(code) && Panic.Matches(code) && n > A.Limit()
    ensures state == S.Reverted(G.Encode(0x4e487b71,4)+G.Encode(17,32))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == S.Running(5540,[2368205965,518,n],S.Store([],64,128))
    ensures trace[|trace|-1] == state
  {
    var branch,left := Overflow.Run(code,n,value,data);
    var prefix: seq<S.Word> := [2368205965,518,n,96,5553,n,32,A.Product(n),13698];
    assert branch == S.Running(23542,prefix,S.Store([],64,128));
    var terminal,right := Panic.Run(code,prefix,value,data);
    E.WidenTrace(code,Overflow.Destinations(),Destinations(),value,data,left);
    E.WidenTrace(code,Panic.Destinations(),Destinations(),value,data,right);
    E.Join(code,Destinations(),value,data,left,right);
    state := terminal;
    trace := left+right[1..];
  }
}
