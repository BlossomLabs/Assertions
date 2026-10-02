// SPDX-License-Identifier: MIT
// Generated actual post-copy allocator instructions.
include "../../iota/Output.dfy"
include "../../scans/Execution.dfy"
module BytecodeReverseAllocationAfterCopy {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import O = BytecodeIotaOutput
  predicate Admitted(n: Word, offset: Word, i: Word) { n < 0x800000000000000 && i == 0 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[5838] == 1 &&
                                              code[5839] == 144 &&
                                              code[5840] == 80 &&
                                              code[5841] == 91 &&
                                              code[5842] == 80 &&
                                              code[5843] == 145 &&
                                              code[5844] == 80 &&
                                              code[5845] == 95
  }
  function Destinations(): set<nat> { {} }
  opaque predicate Good(id: nat, state: State, n: Word, offset: Word, i: Word) { Admitted(n,offset,i) && (
                                                                                   if id == 0 then state == Running(5838,[2874738232,518,offset,n*32,96,n,128,n*32,160,n*32],O.Heap(n,0))
                                                                                   else if id == 1 then state == Running(5839,[2874738232,518,offset,n*32,96,n,128,n*32,O.Extent(n)],O.Heap(n,0))
                                                                                   else if id == 2 then state == Running(5840,[2874738232,518,offset,n*32,96,n,128,O.Extent(n),n*32],O.Heap(n,0))
                                                                                   else if id == 3 then state == Running(5841,[2874738232,518,offset,n*32,96,n,128,O.Extent(n)],O.Heap(n,0))
                                                                                   else if id == 4 then state == Running(5842,[2874738232,518,offset,n*32,96,n,128,O.Extent(n)],O.Heap(n,0))
                                                                                   else if id == 5 then state == Running(5843,[2874738232,518,offset,n*32,96,n,128],O.Heap(n,0))
                                                                                   else if id == 6 then state == Running(5844,[2874738232,518,offset,n*32,128,n,96],O.Heap(n,0))
                                                                                   else if id == 7 then state == Running(5845,[2874738232,518,offset,n*32,128,n],O.Heap(n,0))
                                                                                   else false) }
  lemma Advance0(code: seq<Byte>, state: State, n: Word, offset: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,i) && Good(0,state,n,offset,i)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,n,offset,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5838,[2874738232,518,offset,n*32,96,n,128,n*32,160,n*32],O.Heap(n,0));
    assert Fetch(code,5838) == Op(1,5839,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, n: Word, offset: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,i) && Good(1,state,n,offset,i)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,n,offset,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5839,[2874738232,518,offset,n*32,96,n,128,n*32,O.Extent(n)],O.Heap(n,0));
    assert Fetch(code,5839) == Op(144,5840,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, n: Word, offset: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,i) && Good(2,state,n,offset,i)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,n,offset,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5840,[2874738232,518,offset,n*32,96,n,128,O.Extent(n),n*32],O.Heap(n,0));
    assert Fetch(code,5840) == Op(80,5841,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, n: Word, offset: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,i) && Good(3,state,n,offset,i)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,n,offset,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5841,[2874738232,518,offset,n*32,96,n,128,O.Extent(n)],O.Heap(n,0));
    assert Fetch(code,5841) == Op(91,5842,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, n: Word, offset: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,i) && Good(4,state,n,offset,i)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,n,offset,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5842,[2874738232,518,offset,n*32,96,n,128,O.Extent(n)],O.Heap(n,0));
    assert Fetch(code,5842) == Op(80,5843,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, n: Word, offset: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,i) && Good(5,state,n,offset,i)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,n,offset,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5843,[2874738232,518,offset,n*32,96,n,128],O.Heap(n,0));
    assert Fetch(code,5843) == Op(145,5844,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, n: Word, offset: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,i) && Good(6,state,n,offset,i)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,n,offset,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5844,[2874738232,518,offset,n*32,128,n,96],O.Heap(n,0));
    assert Fetch(code,5844) == Op(80,5845,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, n: Word, offset: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,i) && Good(7,state,n,offset,i)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(5846,[2874738232,518,offset,n*32,128,n,0],O.Heap(n,0))
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5845,[2874738232,518,offset,n*32,128,n],O.Heap(n,0));
    assert Fetch(code,5845) == Op(95,5846,0);
  }
  lemma Start(n: Word, offset: Word, i: Word)
    requires Admitted(n,offset,i)
    ensures Good(0,Running(5838,[2874738232,518,offset,n*32,96,n,128,n*32,160,n*32],O.Heap(n,0)),n,offset,i)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, n: Word, offset: Word, i: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,offset,i)
    ensures state == Running(5846,[2874738232,518,offset,n*32,128,n,0],O.Heap(n,0))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 9 && trace[0] == Running(5838,[2874738232,518,offset,n*32,96,n,128,n*32,160,n*32],O.Heap(n,0)) && trace[|trace|-1] == state
  {
    Start(n,offset,i);
    state := Running(5838,[2874738232,518,offset,n*32,96,n,128,n*32,160,n*32],O.Heap(n,0));
    trace := [state];
    Advance0(code,state,n,offset,i,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(5838,[2874738232,518,offset,n*32,96,n,128,n*32,160,n*32],O.Heap(n,0));
    state := next0;
    Advance1(code,state,n,offset,i,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(5838,[2874738232,518,offset,n*32,96,n,128,n*32,160,n*32],O.Heap(n,0));
    state := next1;
    Advance2(code,state,n,offset,i,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(5838,[2874738232,518,offset,n*32,96,n,128,n*32,160,n*32],O.Heap(n,0));
    state := next2;
    Advance3(code,state,n,offset,i,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(5838,[2874738232,518,offset,n*32,96,n,128,n*32,160,n*32],O.Heap(n,0));
    state := next3;
    Advance4(code,state,n,offset,i,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(5838,[2874738232,518,offset,n*32,96,n,128,n*32,160,n*32],O.Heap(n,0));
    state := next4;
    Advance5(code,state,n,offset,i,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(5838,[2874738232,518,offset,n*32,96,n,128,n*32,160,n*32],O.Heap(n,0));
    state := next5;
    Advance6(code,state,n,offset,i,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(5838,[2874738232,518,offset,n*32,96,n,128,n*32,160,n*32],O.Heap(n,0));
    state := next6;
    Advance7(code,state,n,offset,i,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(5838,[2874738232,518,offset,n*32,96,n,128,n*32,160,n*32],O.Heap(n,0));
    state := next7;
  }
}
