// SPDX-License-Identifier: MIT
// Refine physical arbitrary-count allocation with its measured memory bound.
include "../GatherAllocation.dfy"
include "Iteration.dfy"
module AssertionsGatherConstrainedAllocation {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import A = AssertionsGatherAllocation
  import I = AssertionsGatherInitialization
  import P = AssertionsControlGatherStart
  import Z = AssertionsControlGatherStartZero
  import H = AssertionsControlGatherHeaderExit
  import F = AssertionsControlGatherFill
  import L = AssertionsControlGatherFillLast
  import Q = AssertionsGatherConstrainedIteration
  type Word = S.Word
  type Byte = S.Byte
  predicate Space(mem: seq<Byte>, free: Word, count: Word) {
    |mem|%32 == 0 && 96 <= |mem| <= free && free%32 == 0 && free >= 128 && A.End(free,count)+96 < 0x10000000000000000
  }
  lemma EndAligned(free: Word, count: Word)
    requires free%32 == 0
    ensures S.Round32(free+32) == free+32
    ensures S.Round32(A.End(free,count)) == A.End(free,count)
  {}
  lemma Head(mem: seq<Byte>, free: Word, count: Word)
    requires Space(mem,free,count)
    ensures I.Heap(A.Header(mem,free,count),free,count) && I.Done(A.Header(mem,free,count),free,0)
    ensures |A.Header(mem,free,count)| <= A.End(free,count)
  {
    EndAligned(free,count);
    hide A.Header();
    A.HeaderObject(mem,free,count);
    assert S.Round32(free+32) == free+32;
    assert S.Round32(A.End(free,count)) == A.End(free,count);
    assert |A.Header(mem,free,count)| <= A.End(free,count) by { reveal A.Header(); }
  }
  lemma Pointer(mem: seq<Byte>, free: Word, count: Word, index: nat)
    requires I.Heap(mem,free,count) && I.Done(mem,free,index) && index < count
    requires free%32 == 0 && |mem| <= A.End(free,count)
    ensures I.Heap(S.Store(mem,I.Slot(free,index),96),free,count) && I.Done(S.Store(mem,I.Slot(free,index),96),free,index+1)
    ensures |S.Store(mem,I.Slot(free,index),96)| <= A.End(free,count)
  {
    I.StorePointer(mem,free,count,index);
    assert I.Slot(free,index) == free+32+index*32;
    assert S.Round32(I.Slot(free,index)+32) <= A.End(free,count);
  }
  function Destinations(ret: Word): set<nat> { A.Destinations(ret) }
  ghost method Fill(code: seq<Byte>, ret: Word, args: Word, count: Word, free: Word, index: nat, prefix: seq<Word>, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: S.State, trace: seq<S.State>)
    requires F.Matches(code) && L.Matches(code) && I.Heap(mem,free,count)
    requires index < count <= 0xffffffffffffffff && |prefix| <= 960
    ensures E.Trace(code,Destinations(ret),value,data,trace)
    ensures forall j {:trigger trace[j]} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000
    ensures trace[0] == S.Running(2435,prefix+[ret,args,count,96,free,count-index,I.Slot(free,index)],mem) && trace[|trace|-1] == state
    ensures index+1 < count ==> state == S.Running(2435,prefix+[ret,args,count,96,free,count-index-1,I.Slot(free,index+1)],S.Store(mem,I.Slot(free,index),96))
    ensures index+1 == count ==> state == S.Running(2454,prefix+[ret,args,count,96,free,0,I.Slot(free,count)],S.Store(mem,I.Slot(free,index),96))
  {
    var remain: Word := count-index;
    var slot := I.Slot(free,index);
    assert slot == free+32+index*32;
    if remain > 1 {
      state,trace := F.Run(code,ret,args,0,0,slot,count,remain,free,prefix,mem,value,data);
      E.WidenTrace(code,F.Destinations(ret),Destinations(ret),value,data,trace);
    } else {
      state,trace := L.Run(code,ret,args,0,0,slot,count,remain,free,prefix,mem,value,data);
      E.WidenTrace(code,L.Destinations(ret),Destinations(ret),value,data,trace);
    }
  }

  ghost method Run(code: seq<Byte>, ret: Word, args: Word, count: Word, free: Word, prefix: seq<Word>, initial: seq<Byte>, value: Word, data: seq<Byte>) returns (state: S.State, trace: seq<S.State>, mem: seq<Byte>)
    requires P.Matches(code) && Z.Matches(code) && H.Matches(code) && F.Matches(code) && L.Matches(code)
    requires Space(initial,free,count) && count <= 0xffffffffffffffff && S.Load(initial,64) == free && |prefix| <= 960
    ensures E.Trace(code,Destinations(ret),value,data,trace)
    ensures forall j {:trigger trace[j]} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000
    ensures trace[0] == S.Running(2379,prefix+[ret,args,count],initial) && trace[|trace|-1] == state
    ensures state == S.Running(2461,prefix+[ret,args,count,free,0],mem)
    ensures Q.Ready(mem,free,count,A.End(free,count))
  {
    Head(initial,free,count); A.Images(initial,free,count,ret,args,prefix);
    mem := A.Header(initial,free,count);
    if count == 0 {
      state,trace := Z.Run(code,ret,args,0,0,0,count,0,free,prefix,initial,value,data);
      E.WidenTrace(code,Z.Destinations(ret),Destinations(ret),value,data,trace);
    } else {
      state,trace := P.Run(code,ret,args,0,0,0,count,0,free,prefix,initial,value,data);
      E.WidenTrace(code,P.Destinations(ret),Destinations(ret),value,data,trace);
      var index: nat := 0;
      while index < count
        invariant index <= count && I.Heap(mem,free,count) && I.Done(mem,free,index) && |mem| <= A.End(free,count)
        invariant E.Trace(code,Destinations(ret),value,data,trace)
        invariant forall j {:trigger trace[j]} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000
        invariant trace[0] == S.Running(2379,prefix+[ret,args,count],initial) && trace[|trace|-1] == state
        invariant index < count ==> state == S.Running(2435,prefix+[ret,args,count,96,free,count-index,I.Slot(free,index)],mem)
        invariant index == count ==> state == S.Running(2454,prefix+[ret,args,count,96,free,0,I.Slot(free,count)],mem)
        decreases count-index
      {
        var part: seq<S.State>;
        state,part := Fill(code,ret,args,count,free,index,prefix,mem,value,data);
        Pointer(mem,free,count,index);
        mem := S.Store(mem,I.Slot(free,index),96);
        E.Join(code,Destinations(ret),value,data,trace,part); trace := trace+part[1..];
        index := index+1;
      }
      var part: seq<S.State>;
      state,part := H.Run(code,ret,args,0,0,I.Slot(free,count),count,0,free,prefix,mem,value,data);
      E.WidenTrace(code,H.Destinations(ret),Destinations(ret),value,data,part);
      E.Join(code,Destinations(ret),value,data,trace,part); trace := trace+part[1..];
    }
    assert (A.End(free,count))%32 == 0;
  }
}
