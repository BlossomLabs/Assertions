// SPDX-License-Identifier: MIT
// Generated compiler-bound sortWords segment; each actual reached opcode is checked.
include "../../scans/Execution.dfy"
include "../../copy/Memory.dfy"
include "Scalar.dfy"
module BytecodeSortSegmentMiddleComputed {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import SC = BytecodeSortMergeScalar
  predicate Admitted(offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word) { n < 0x800000000000000 && offset < 0x10000000000000000 && out < 0x20000000000000000 && scratch < 0x20000000000000000 && 0 < width <= 2*n+1 && start <= 3*n && start < n && start+width < n }
  predicate MemoryAdmitted(mem: seq<Byte>, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word) { Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && true }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 && code[3663] == 91 &&
                                              code[3664] == 144 &&
                                              code[3665] == 80 }
  function Destinations(): set<nat> { {} }
  opaque predicate Good(id: nat, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>) { Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && (
                                                                                                                                                                                                                                           if id == 0 then state == Running(3663,[785862473,518,offset,n*32,out,n,scratch,width,start,0,start+width],mem)
                                                                                                                                                                                                                                           else if id == 1 then state == Running(3664,[785862473,518,offset,n*32,out,n,scratch,width,start,0,start+width],mem)
                                                                                                                                                                                                                                           else if id == 2 then state == Running(3665,[785862473,518,offset,n*32,out,n,scratch,width,start,start+width,0],mem)
                                                                                                                                                                                                                                           else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(0,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3663,[785862473,518,offset,n*32,out,n,scratch,width,start,0,start+width],mem);
    assert Fetch(code,3663) == Op(91,3664,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(1,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3664,[785862473,518,offset,n*32,out,n,scratch,width,start,0,start+width],mem);
    assert Fetch(code,3664) == Op(144,3665,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(2,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(3666,[785862473,518,offset,n*32,out,n,scratch,width,start,start+width],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3665,[785862473,518,offset,n*32,out,n,scratch,width,start,start+width,0],mem);
    assert Fetch(code,3665) == Op(80,3666,0);
  }
  lemma Start(offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>)
    requires Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take)
    ensures Good(0,Running(3663,[785862473,518,offset,n*32,out,n,scratch,width,start,0,start+width],mem),offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take)
    ensures state == Running(3666,[785862473,518,offset,n*32,out,n,scratch,width,start,start+width],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 4 && trace[0] == Running(3663,[785862473,518,offset,n*32,out,n,scratch,width,start,0,start+width],mem) && trace[|trace|-1] == state
  {
    Start(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem);state := Running(3663,[785862473,518,offset,n*32,out,n,scratch,width,start,0,start+width],mem);trace := [state];
    Advance0(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
  }
}
