// SPDX-License-Identifier: MIT
// Generated compiler-bound sortWords segment; each actual reached opcode is checked.
include "../../scans/Execution.dfy"
include "../../copy/Memory.dfy"
include "Scalar.dfy"
module BytecodeSortSegmentMiddleRecompute {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import SC = BytecodeSortMergeScalar
  predicate Admitted(offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word) { n < 0x800000000000000 && offset < 0x10000000000000000 && out < 0x20000000000000000 && scratch < 0x20000000000000000 && 0 < width <= 2*n+1 && start <= 3*n && start < n && start+width < n }
  predicate MemoryAdmitted(mem: seq<Byte>, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word) { Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && true }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 && code[3642] == 91 &&
                                              code[3643] == 16 &&
                                              code[3644] == 97 &&
                                              code[3645] == 14 &&
                                              code[3646] == 69 &&
                                              code[3647] == 87 &&
                                              code[3653] == 91 &&
                                              code[3654] == 97 &&
                                              code[3655] == 14 &&
                                              code[3656] == 79 &&
                                              code[3657] == 131 &&
                                              code[3658] == 131 &&
                                              code[3659] == 97 &&
                                              code[3660] == 92 &&
                                              code[3661] == 52 &&
                                              code[3662] == 86 &&
                                              code[23604] == 91 }
  function Destinations(): set<nat> { {3653,23604} }
  opaque predicate Good(id: nat, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>) { Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && (
                                                                                                                                                                                                                                           if id == 0 then state == Running(3642,[785862473,518,offset,n*32,out,n,scratch,width,start,0,n,start+width],mem)
                                                                                                                                                                                                                                           else if id == 1 then state == Running(3643,[785862473,518,offset,n*32,out,n,scratch,width,start,0,n,start+width],mem)
                                                                                                                                                                                                                                           else if id == 2 then state == Running(3644,[785862473,518,offset,n*32,out,n,scratch,width,start,0,1],mem)
                                                                                                                                                                                                                                           else if id == 3 then state == Running(3647,[785862473,518,offset,n*32,out,n,scratch,width,start,0,1,3653],mem)
                                                                                                                                                                                                                                           else if id == 4 then state == Running(3653,[785862473,518,offset,n*32,out,n,scratch,width,start,0],mem)
                                                                                                                                                                                                                                           else if id == 5 then state == Running(3654,[785862473,518,offset,n*32,out,n,scratch,width,start,0],mem)
                                                                                                                                                                                                                                           else if id == 6 then state == Running(3657,[785862473,518,offset,n*32,out,n,scratch,width,start,0,3663],mem)
                                                                                                                                                                                                                                           else if id == 7 then state == Running(3658,[785862473,518,offset,n*32,out,n,scratch,width,start,0,3663,width],mem)
                                                                                                                                                                                                                                           else if id == 8 then state == Running(3659,[785862473,518,offset,n*32,out,n,scratch,width,start,0,3663,width,start],mem)
                                                                                                                                                                                                                                           else if id == 9 then state == Running(3662,[785862473,518,offset,n*32,out,n,scratch,width,start,0,3663,width,start,23604],mem)
                                                                                                                                                                                                                                           else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(0,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3642,[785862473,518,offset,n*32,out,n,scratch,width,start,0,n,start+width],mem);
    assert Fetch(code,3642) == Op(91,3643,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(1,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3643,[785862473,518,offset,n*32,out,n,scratch,width,start,0,n,start+width],mem);
    assert Fetch(code,3643) == Op(16,3644,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(2,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3644,[785862473,518,offset,n*32,out,n,scratch,width,start,0,1],mem);
    F.Push2(code,3644);
    assert Fetch(code,3644) == Op(97,3647,3653);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(3,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3647,[785862473,518,offset,n*32,out,n,scratch,width,start,0,1,3653],mem);
    assert Fetch(code,3647) == Op(87,3648,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(4,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3653,[785862473,518,offset,n*32,out,n,scratch,width,start,0],mem);
    assert Fetch(code,3653) == Op(91,3654,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(5,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3654,[785862473,518,offset,n*32,out,n,scratch,width,start,0],mem);
    F.Push2(code,3654);
    assert Fetch(code,3654) == Op(97,3657,3663);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(6,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3657,[785862473,518,offset,n*32,out,n,scratch,width,start,0,3663],mem);
    assert Fetch(code,3657) == Op(131,3658,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(7,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3658,[785862473,518,offset,n*32,out,n,scratch,width,start,0,3663,width],mem);
    assert Fetch(code,3658) == Op(131,3659,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(8,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3659,[785862473,518,offset,n*32,out,n,scratch,width,start,0,3663,width,start],mem);
    F.Push2(code,3659);
    assert Fetch(code,3659) == Op(97,3662,23604);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && Good(9,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
    ensures state.Running? && |state.stack| <= 30 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23604,[785862473,518,offset,n*32,out,n,scratch,width,start,0,3663,width,start],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3662,[785862473,518,offset,n*32,out,n,scratch,width,start,0,3663,width,start,23604],mem);
    assert Fetch(code,3662) == Op(86,3663,0);
  }
  lemma Start(offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>)
    requires Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take)
    ensures Good(0,Running(3642,[785862473,518,offset,n*32,out,n,scratch,width,start,0,n,start+width],mem),offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, n: Word, out: Word, scratch: Word, width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, lword: Word, rword: Word, take: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take) && MemoryAdmitted(mem,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take)
    ensures state == Running(23604,[785862473,518,offset,n*32,out,n,scratch,width,start,0,3663,width,start],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 11 && trace[0] == Running(3642,[785862473,518,offset,n*32,out,n,scratch,width,start,0,n,start+width],mem) && trace[|trace|-1] == state
  {
    Start(offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem);state := Running(3642,[785862473,518,offset,n*32,out,n,scratch,width,start,0,n,start+width],mem);trace := [state];
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
    Advance6(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,take,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
  }
}
