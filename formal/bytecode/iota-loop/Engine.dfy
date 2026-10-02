// SPDX-License-Identifier: MIT
include "Body.generated.dfy"
include "Exit.generated.dfy"
module BytecodeIotaLoopEngine {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import O = BytecodeIotaOutput
  import B = BytecodeIotaLoopBody
  import X = BytecodeIotaLoopExit
  import E = BytecodeScanExecution
  function Destinations(): set<nat> { B.Destinations()+X.Destinations() }
  ghost method Run(code: seq<S.Byte>, n: S.Word, value: S.Word, data: seq<S.Byte>)
    returns (state: S.State, trace: seq<S.State>)
    requires B.Matches(code) && X.Matches(code) && n < 0x800000000000000
    ensures state == S.Running(518,[2368205965,128],O.Heap(n,n))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == S.Running(5623,[2368205965,518,n,128,0],O.Heap(n,0))
    ensures trace[|trace|-1] == state && |trace| == 14+21*n
  {
    var index: nat := 0;
    state := S.Running(5623,[2368205965,518,n,128,0],O.Heap(n,0));
    trace := [state];
    while index < n
      invariant index <= n
      invariant state == S.Running(5623,[2368205965,518,n,128,index],O.Heap(n,index))
      invariant E.Trace(code,Destinations(),value,data,trace)
      invariant trace[0] == S.Running(5623,[2368205965,518,n,128,0],O.Heap(n,0))
      invariant trace[|trace|-1] == state && |trace| == 1+21*index
      decreases n-index
    {
      var next,segment := B.Run(code,n,index,value,data);
      E.WidenTrace(code,B.Destinations(),Destinations(),value,data,segment);
      E.Join(code,Destinations(),value,data,trace,segment);
      trace := trace+segment[1..];
      state := next;
      index := index+1;
    }
    var terminal,exit := X.Run(code,n,n,value,data);
    E.WidenTrace(code,X.Destinations(),Destinations(),value,data,exit);
    E.Join(code,Destinations(),value,data,trace,exit);
    trace := trace+exit[1..];
    state := terminal;
  }
}
