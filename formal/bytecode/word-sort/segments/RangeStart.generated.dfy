// SPDX-License-Identifier: MIT
// Generated compiler-bound sortWords segment; each actual reached opcode is checked.
include "../../scans/Execution.dfy"
include "../../copy/Memory.dfy"
include "Scalar.dfy"
module BytecodeSortSegmentRangeStart {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import SC = BytecodeSortMergeScalar
  predicate Admitted(offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word) { n < 0x800000000000000 && offset < 0x10000000000000000 && out < 0x20000000000000000 && scratch < 0x20000000000000000 && 0 < width <= 2*n+1 && start <= 3*n && start <= middle <= end }
  predicate MemoryAdmitted(mem: seq<Byte>, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word) { Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && true }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 && code[3720] == 91 &&
                                              code[3721] == 144 &&
                                              code[3722] == 80 &&
                                              code[3723] == 130 &&
                                              code[3724] == 130 &&
                                              code[3725] == 129 }
  function Destinations(): set<nat> { {} }
  opaque predicate Good(id: nat, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>) { Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && (
                                                                                                                                                                                                                                           if id == 0 then state == Running(3720,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,0,end],mem)
                                                                                                                                                                                                                                           else if id == 1 then state == Running(3721,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,0,end],mem)
                                                                                                                                                                                                                                           else if id == 2 then state == Running(3722,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,0],mem)
                                                                                                                                                                                                                                           else if id == 3 then state == Running(3723,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end],mem)
                                                                                                                                                                                                                                           else if id == 4 then state == Running(3724,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,start],mem)
                                                                                                                                                                                                                                           else if id == 5 then state == Running(3725,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,start,middle],mem)
                                                                                                                                                                                                                                           else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(0,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3720,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,0,end],mem);
    assert Fetch(code,3720) == Op(91,3721,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(1,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3721,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,0,end],mem);
    assert Fetch(code,3721) == Op(144,3722,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(2,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3722,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,0],mem);
    assert Fetch(code,3722) == Op(80,3723,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(3,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3723,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end],mem);
    assert Fetch(code,3723) == Op(130,3724,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(4,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3724,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,start],mem);
    assert Fetch(code,3724) == Op(130,3725,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(5,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(3726,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,start,middle,start],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3725,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,start,middle],mem);
    assert Fetch(code,3725) == Op(129,3726,0);
  }
  lemma Start(offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>)
    requires Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take)
    ensures Good(0,Running(3720,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,0,end],mem),offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take)
    ensures state == Running(3726,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,start,middle,start],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 7 && trace[0] == Running(3720,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,0,end],mem) && trace[|trace|-1] == state
  {
    Start(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem);state := Running(3720,[785862473,518,offset,n*32,out,n,scratch,width,start,middle,0,end],mem);trace := [state];
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
    Advance3(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
  }
}
