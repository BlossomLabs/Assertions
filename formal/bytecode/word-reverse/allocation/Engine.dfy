// SPDX-License-Identifier: MIT
include "AfterCopy.generated.dfy"
include "AllocateNonempty.generated.dfy"
include "AllocateEmpty.generated.dfy"
include "Memory.dfy"
include "../../copy/Lift.dfy"
module BytecodeReverseAllocationEngine {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeCopyMachine
  import C = BytecodeCopyExecution
  import L = BytecodeCopyTraceLift
  import O = BytecodeIotaOutput
  import N = BytecodeReverseAllocateNonempty
  import Z = BytecodeReverseAllocateEmpty
  import A = BytecodeIotaAllocationMemory
  import AM = BytecodeReverseAllocationMemory
  import R = BytecodeWordReverseMemory
  import P = BytecodeReverseAllocationAfterCopy
  predicate Matches(code: seq<S.Byte>) {
    N.Matches(code) && Z.Matches(code) && P.Matches(code) &&
    |code| > 5837 && code[5837] == 0x37
  }
  function Destinations(): set<nat> { N.Destinations()+Z.Destinations()+P.Destinations() }
  ghost method Run(code: seq<S.Byte>, n: S.Word, offset: S.Word, value: S.Word, data: seq<S.Byte>)
    returns (state: S.State, trace: seq<S.State>)
    requires Matches(code) && R.Admitted(n,0,offset,data)
    ensures state == S.Running(5846,[2874738232,518,offset,n*32,128,n,0],R.Heap(n,0,offset,data))
    ensures C.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == S.Running(5799,[2874738232,518,offset,n*32,96,n,n*32],S.Store([],64,128))
    ensures trace[|trace|-1] == state && |trace| == (if n == 0 then 29 else 40)
  {
    AM.InitialHeap(n,offset,data);
    if n == 0 {
      Z.FreeLength(n);
      state,trace := Z.Run(code,n,offset,value,data);
      A.HeadBytes(n);
      assert A.Head(n) == O.Heap(n,0);
      L.Trace(code,Z.Destinations(),value,data,trace);
      C.WidenTrace(code,Z.Destinations(),Destinations(),value,data,trace);
    } else {
      N.FreeLength(n);
      var ready,left := N.Run(code,n,offset,value,data);
      L.Trace(code,N.Destinations(),value,data,left);
      C.WidenTrace(code,N.Destinations(),Destinations(),value,data,left);
      var prefix: seq<S.Word> := [2874738232,518,offset,n*32,96,n,128,n*32,160,n*32];
      assert ready == S.Running(5837,prefix+[n*32,|data|,160],A.Head(n));
      AM.ActualCopy(code,n,prefix,value,data);
      assert M.Step(code,{},ready,value,data) == S.Running(5838,prefix,O.Heap(n,0));
      C.WidenStep(code,{},Destinations(),ready,value,data);
      var copied := M.Step(code,Destinations(),ready,value,data);
      C.Extend(code,Destinations(),value,data,left,copied);
      var first := left+[copied];
      var terminal,right := P.Run(code,n,offset,0,value,data);
      L.Trace(code,P.Destinations(),value,data,right);
      C.WidenTrace(code,P.Destinations(),Destinations(),value,data,right);
      C.Join(code,Destinations(),value,data,first,right);
      state := terminal;
      trace := first+right[1..];
    }
  }
}
