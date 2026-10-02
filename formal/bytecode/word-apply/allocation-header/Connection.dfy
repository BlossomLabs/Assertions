// SPDX-License-Identifier: MIT
// Complete physical output allocation, including the empty branch and zero-fill copy.
include "AllocateNonempty.generated.dfy"
include "AllocateEmpty.generated.dfy"
include "CopyTail.generated.dfy"
include "Memory.dfy"
include "../../copy/Execution.dfy"
module BytecodeApplyOutputAllocation {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import X = BytecodeCopyExecution
  import C = BytecodeCopyMachine
  import N = BytecodeApplyAllocateNonempty
  import Z = BytecodeApplyAllocateEmpty
  import T = BytecodeApplyAllocationCopyTail
  import A = BytecodeApplyAllocationMemory
  predicate Matches(code: seq<Byte>) {
    N.Matches(code) && Z.Matches(code) && T.Matches(code) && |code| > 12311 && code[12311] == 0x37
  }
  function Destinations(): set<nat> { N.Destinations()+Z.Destinations()+T.Destinations() }
  lemma Lift(code: seq<Byte>,small: set<nat>,value: Word,data: seq<Byte>,trace: seq<State>)
    requires small <= Destinations() && E.Trace(code,small,value,data,trace)
    ensures X.Trace(code,Destinations(),value,data,trace)
  {
    forall i {:trigger trace[i]} | 0 <= i < |trace|-1
      ensures !trace[i].Running? || trace[i].pc >= |code| || Fetch(code,trace[i].pc).op !in {0x37,0x5e}
    {
      assert Step(code,small,trace[i],value,data) != Bad;
      reveal Step();
    }
    X.Lift(code,small,value,data,trace);
    X.WidenTrace(code,small,Destinations(),value,data,trace);
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,mode: Word,n: Word,value: Word)
    returns (state: State,trace: seq<State>)
    requires Matches(code) && n < 0x800000000000000 && |data| < G.Modulus() && |prefix| <= 1006
    ensures state == Running(12319,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n],A.Heap(n))
    ensures X.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(12273,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,n,n*32],Store([],64,128))
    ensures trace[|trace|-1] == state && |trace| == (if n == 0 then 28 else 39)
  {
    A.Header(n);
    if n == 0 {
      state,trace := Z.Run(code,n,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value,data);
      Lift(code,Z.Destinations(),value,data,trace);
      Z.FreeLength(n);
      A.Empty();
    } else {
      state,trace := N.Run(code,n,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value,data);
      Lift(code,N.Destinations(),value,data,trace);
      N.FreeLength(n);
      var copyPrefix := prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,n,128,n*32,160,n*32];
      assert state == Running(12311,copyPrefix+[n*32,|data|,160],A.Head(n));
      A.ActualCopy(code,n,copyPrefix,value,data);
      var next := Running(12312,copyPrefix,A.Heap(n));
      X.WidenStep(code,{},Destinations(),state,value,data);
      X.Extend(code,Destinations(),value,data,trace,next);
      trace := trace+[next];
      var part: seq<State>;
      state,part := T.Run(code,data,A.Heap(n),prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,value);
      Lift(code,T.Destinations(),value,data,part);
      X.Join(code,Destinations(),value,data,trace,part);
      trace := trace+part[1..];
    }
  }
}
