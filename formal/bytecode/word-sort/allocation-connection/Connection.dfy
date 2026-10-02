// SPDX-License-Identifier: MIT
// Physical source copy, count helper and both scratch allocation paths.
include "../copy-allocation/CopyHeader.generated.dfy"
include "../copy-allocation/CopyTail.generated.dfy"
include "../copy-allocation/Memory.dfy"
include "../kernels/Div32.generated.dfy"
include "../scratch-allocation-repair/CountGuard.generated.dfy"
include "../scratch-allocation-repair/ScratchNonempty.generated.dfy"
include "../scratch-allocation-repair/ScratchEmpty.generated.dfy"
include "../scratch-allocation-repair/ScratchTail.generated.dfy"
include "../initial-memory/Memory.dfy"
include "../../copy/Execution.dfy"
module BytecodeSortAllocationConnection {
  import opened BytecodeScanMachine
  import H = BytecodeSortAllocationCopyHeader
  import T = BytecodeSortAllocationCopyTail
  import D = BytecodeSortCopyAllocationMemory
  import Q = BytecodeSortHelperDiv32
  import G = BytecodeSortCountGuard
  import N = BytecodeSortScratchNonempty
  import Z = BytecodeSortScratchEmpty
  import L = BytecodeSortScratchTail
  import I = BytecodeSortInitialMemory
  import M = BytecodeWordSortMemory
  import C = BytecodeCopyMachine
  import B = BytecodeCopyMemory
  import X = BytecodeCopyExecution
  import E = BytecodeScanExecution
  predicate Matches(code: seq<Byte>) {
    |code| == 24560 && code[3510] == 0x37 && code[3602] == 0x37 &&
    H.Matches(code) && T.Matches(code) && Q.Matches(code) && G.Matches(code) &&
    N.Matches(code) && Z.Matches(code) && L.Matches(code)
  }
  function Destinations(): set<nat> {
    H.Destinations()+T.Destinations()+Q.Destinations()+G.Destinations()+N.Destinations()+Z.Destinations()+L.Destinations()
  }
  lemma Lift(code: seq<Byte>, small: set<nat>, large: set<nat>, value: Word, data: seq<Byte>, trace: seq<State>)
    requires small <= large && E.Trace(code,small,value,data,trace)
    ensures X.Trace(code,large,value,data,trace)
  {
    forall i {:trigger trace[i]} | 0 <= i < |trace|-1
      ensures !trace[i].Running? || trace[i].pc >= |code| || Fetch(code,trace[i].pc).op !in {0x37,0x5e}
    {
      assert Step(code,small,trace[i],value,data) != Bad;
      reveal Step();
    }
    X.Lift(code,small,value,data,trace);
    X.WidenTrace(code,small,large,value,data,trace);
  }
  ghost method Append(code: seq<Byte>, value: Word, data: seq<Byte>, left: seq<State>, right: seq<State>, small: set<nat>) returns (trace: seq<State>)
    requires X.Trace(code,Destinations(),value,data,left) && E.Trace(code,small,value,data,right)
    requires small <= Destinations() && left[|left|-1] == right[0]
    ensures X.Trace(code,Destinations(),value,data,trace)
    ensures trace == left+right[1..]
    ensures trace[0] == left[0] && trace[|trace|-1] == right[|right|-1]
  {
    Lift(code,small,Destinations(),value,data,right);
    X.Join(code,Destinations(),value,data,left,right);
    trace := left+right[1..];
  }
  ghost method Run(code: seq<Byte>, n: Word, offset: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && D.Fits(n,offset,data)
    ensures state == Running(3612,[785862473,518,offset,n*32,128,n,160+n*32,1],M.Heap(n,I.Originals(n),I.Scratch(n),offset,data))
    ensures X.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(3468,[785862473,518,offset,n*32,96],Store([],64,128)) && trace[|trace|-1] == state
    ensures |trace| == (if n == 0 then 112 else 123)
  {
    var initialMemory := Store([],64,128);
    state,trace := H.Run(code,n,offset,initialMemory,value,data);
    Lift(code,H.Destinations(),Destinations(),value,data,trace);
    var copyPrefix: seq<Word> := [785862473,518,offset,n*32,96,128,offset,n*32,n*32,160,offset,n*32];
    assert state == Running(3510,copyPrefix+[n*32,offset,160],D.Head(n));
    D.ActualCopy(code,n,offset,data,copyPrefix,value);
    var next := Running(3511,copyPrefix,D.Copied(n,offset,data));
    assert C.Step(code,{},state,value,data) == next;
    X.WidenStep(code,{},Destinations(),state,value,data);
    assert C.Step(code,Destinations(),state,value,data) == next;
    X.Extend(code,Destinations(),value,data,trace,next);
    trace := trace+[next];
    D.CopiedFrame(n,offset,data);
    var part: seq<State>;
    state,part := T.Run(code,n,offset,D.Copied(n,offset,data),value,data);
    trace := Append(code,value,data,trace,part,T.Destinations());
    D.TailFrame(n,offset,data);
    M.Rounded(n);
    var tail := D.Tail(n,offset,data);
    state,part := Q.Run(code,[785862473,518,offset,n*32,128,0],n*32,tail,value,data);
    trace := Append(code,value,data,trace,part,Q.Destinations());
    state,part := G.Run(code,n,offset,tail,value,data);
    trace := Append(code,value,data,trace,part,G.Destinations());
    I.HeaderFrame(n,offset,data);
    I.Connection(n,offset,data);
    if n == 0 {
      state,part := Z.Run(code,n,offset,tail,value,data);
      trace := Append(code,value,data,trace,part,Z.Destinations());
      B.ZeroLength(I.Header(n,offset,data),192+n*32,|data|,data);
    } else {
      state,part := N.Run(code,n,offset,tail,value,data);
      trace := Append(code,value,data,trace,part,N.Destinations());
      var scratchPrefix: seq<Word> := [785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32];
      assert state == Running(3602,scratchPrefix+[n*32,|data|,192+n*32],I.Header(n,offset,data));
      C.CalldataStep(code,3602,scratchPrefix,I.Header(n,offset,data),192+n*32,|data|,n*32,value,data);
      next := Running(3603,scratchPrefix,I.Initialized(n,offset,data));
      assert C.Step(code,{},state,value,data) == next;
      X.WidenStep(code,{},Destinations(),state,value,data);
      assert C.Step(code,Destinations(),state,value,data) == next;
      X.Extend(code,Destinations(),value,data,trace,next);
      trace := trace+[next];
      state,part := L.Run(code,n,offset,I.Initialized(n,offset,data),value,data);
      trace := Append(code,value,data,trace,part,L.Destinations());
    }
  }
}
