// SPDX-License-Identifier: MIT
include "AfterCopy.generated.dfy"
include "AllocateNonempty.generated.dfy"
include "AllocateEmpty.generated.dfy"
include "Memory.dfy"
include "../../copy/Lift.dfy"
module BytecodeUniqueAllocationEngine {
  import S = BytecodeScanMachine
  import M = BytecodeCopyMachine
  import C = BytecodeCopyExecution
  import L = BytecodeCopyTraceLift
  import O = BytecodeIotaOutput
  import N = BytecodeUniqueAllocateNonempty
  import Z = BytecodeUniqueAllocateEmpty
  import A = BytecodeIotaAllocationMemory
  import AM = BytecodeUniqueAllocationMemory
  import R = BytecodeWordUniqueMemory
  import P = BytecodeUniqueAllocationAfterCopy
  predicate Matches(code: seq<S.Byte>) {
    N.Matches(code) && Z.Matches(code) && P.Matches(code) &&
    |code| > 6714 && code[6714] == 0x37
  }
  function Destinations(): set<nat> { N.Destinations()+Z.Destinations()+P.Destinations() }
  ghost method Run(code: seq<S.Byte>, n: S.Word, offset: S.Word, length: S.Word, ordered: S.Word, value: S.Word, data: seq<S.Byte>)
    returns (state: S.State, trace: seq<S.State>)
    requires Matches(code) && R.Admitted(n,[],offset,data,n) && length == n*32
    ensures state == S.Running(6724,[3045624246,518,offset,length,ordered,128,0,0],R.Heap(n,[],offset,data,n))
    ensures C.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == S.Running(6676,[3045624246,518,offset,length,ordered,96,n*32],S.Store([],64,128))
    ensures trace[|trace|-1] == state
  {
    AM.InitialHeap(n,offset,data);
    if n == 0 {
      Z.FreeLength(n);
      state,trace := Z.Run(code,n,offset,length,ordered,value,data);
      A.HeadBytes(n);
      assert A.Head(n) == O.Heap(n,0);
      L.Trace(code,Z.Destinations(),value,data,trace);
      C.WidenTrace(code,Z.Destinations(),Destinations(),value,data,trace);
    } else {
      N.FreeLength(n);
      var ready,left := N.Run(code,n,offset,length,ordered,value,data);
      L.Trace(code,N.Destinations(),value,data,left);
      C.WidenTrace(code,N.Destinations(),Destinations(),value,data,left);
      var prefix: seq<S.Word> := [3045624246,518,offset,length,ordered,96,128,n*32,160,n*32];
      assert ready == S.Running(6714,prefix+[n*32,|data|,160],A.Head(n));
      AM.ActualCopy(code,n,prefix,value,data);
      assert M.Step(code,{},ready,value,data) == S.Running(6715,prefix,O.Heap(n,0));
      C.WidenStep(code,{},Destinations(),ready,value,data);
      var copied := M.Step(code,Destinations(),ready,value,data);
      C.Extend(code,Destinations(),value,data,left,copied);
      var first := left+[copied];
      var terminal,right := P.Run(code,n,offset,length,ordered,value,data);
      L.Trace(code,P.Destinations(),value,data,right);
      C.WidenTrace(code,P.Destinations(),Destinations(),value,data,right);
      C.Join(code,Destinations(),value,data,first,right);
      state := terminal;
      trace := first+right[1..];
    }
  }
}
