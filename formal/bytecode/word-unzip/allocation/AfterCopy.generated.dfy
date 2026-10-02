// SPDX-License-Identifier: MIT
// Generated actual post-copy allocator instructions.
include "../../iota/Output.dfy"
include "../../scans/Execution.dfy"
module BytecodeUnzipAllocationAfterCopy {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import O = BytecodeIotaOutput
  predicate Admitted(n: Word, offset: Word, length: Word, lane: Word, count: Word, i: Word) { n < 0x800000000000000 && i == 0 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6154] == 1 &&
                                              code[6155] == 144 &&
                                              code[6156] == 80 &&
                                              code[6157] == 91 &&
                                              code[6158] == 80 &&
                                              code[6159] == 146 &&
                                              code[6160] == 80 &&
                                              code[6161] == 95
  }
  function Destinations(): set<nat> { {} }
  opaque predicate Good(id: nat, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, i: Word) { Admitted(n,offset,length,lane,count,i) && (
                                                                                                                          if id == 0 then state == Running(6154,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32],O.Heap(n,0))
                                                                                                                          else if id == 1 then state == Running(6155,[2989505972,518,offset,length,lane,96,count,n,128,n*32,O.Extent(n)],O.Heap(n,0))
                                                                                                                          else if id == 2 then state == Running(6156,[2989505972,518,offset,length,lane,96,count,n,128,O.Extent(n),n*32],O.Heap(n,0))
                                                                                                                          else if id == 3 then state == Running(6157,[2989505972,518,offset,length,lane,96,count,n,128,O.Extent(n)],O.Heap(n,0))
                                                                                                                          else if id == 4 then state == Running(6158,[2989505972,518,offset,length,lane,96,count,n,128,O.Extent(n)],O.Heap(n,0))
                                                                                                                          else if id == 5 then state == Running(6159,[2989505972,518,offset,length,lane,96,count,n,128],O.Heap(n,0))
                                                                                                                          else if id == 6 then state == Running(6160,[2989505972,518,offset,length,lane,128,count,n,96],O.Heap(n,0))
                                                                                                                          else if id == 7 then state == Running(6161,[2989505972,518,offset,length,lane,128,count,n],O.Heap(n,0))
                                                                                                                          else false) }
  lemma Advance0(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,i) && Good(0,state,n,offset,length,lane,count,i)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,n,offset,length,lane,count,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(6154,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32],O.Heap(n,0));
    assert Fetch(code,6154) == Op(1,6155,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,i) && Good(1,state,n,offset,length,lane,count,i)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,n,offset,length,lane,count,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(6155,[2989505972,518,offset,length,lane,96,count,n,128,n*32,O.Extent(n)],O.Heap(n,0));
    assert Fetch(code,6155) == Op(144,6156,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,i) && Good(2,state,n,offset,length,lane,count,i)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,n,offset,length,lane,count,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(6156,[2989505972,518,offset,length,lane,96,count,n,128,O.Extent(n),n*32],O.Heap(n,0));
    assert Fetch(code,6156) == Op(80,6157,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,i) && Good(3,state,n,offset,length,lane,count,i)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,n,offset,length,lane,count,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(6157,[2989505972,518,offset,length,lane,96,count,n,128,O.Extent(n)],O.Heap(n,0));
    assert Fetch(code,6157) == Op(91,6158,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,i) && Good(4,state,n,offset,length,lane,count,i)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,n,offset,length,lane,count,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(6158,[2989505972,518,offset,length,lane,96,count,n,128,O.Extent(n)],O.Heap(n,0));
    assert Fetch(code,6158) == Op(80,6159,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,i) && Good(5,state,n,offset,length,lane,count,i)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,n,offset,length,lane,count,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(6159,[2989505972,518,offset,length,lane,96,count,n,128],O.Heap(n,0));
    assert Fetch(code,6159) == Op(146,6160,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,i) && Good(6,state,n,offset,length,lane,count,i)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,n,offset,length,lane,count,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(6160,[2989505972,518,offset,length,lane,128,count,n,96],O.Heap(n,0));
    assert Fetch(code,6160) == Op(80,6161,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, lane: Word, count: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,i) && Good(7,state,n,offset,length,lane,count,i)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(6162,[2989505972,518,offset,length,lane,128,count,n,0],O.Heap(n,0))
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(6161,[2989505972,518,offset,length,lane,128,count,n],O.Heap(n,0));
    assert Fetch(code,6161) == Op(95,6162,0);
  }
  lemma Start(n: Word, offset: Word, length: Word, lane: Word, count: Word, i: Word)
    requires Admitted(n,offset,length,lane,count,i)
    ensures Good(0,Running(6154,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32],O.Heap(n,0)),n,offset,length,lane,count,i)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, n: Word, offset: Word, length: Word, lane: Word, count: Word, i: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,offset,length,lane,count,i)
    ensures state == Running(6162,[2989505972,518,offset,length,lane,128,count,n,0],O.Heap(n,0))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 9 && trace[0] == Running(6154,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32],O.Heap(n,0)) && trace[|trace|-1] == state
  {
    Start(n,offset,length,lane,count,i);
    state := Running(6154,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32],O.Heap(n,0));
    trace := [state];
    Advance0(code,state,n,offset,length,lane,count,i,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6154,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32],O.Heap(n,0));
    state := next0;
    Advance1(code,state,n,offset,length,lane,count,i,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6154,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32],O.Heap(n,0));
    state := next1;
    Advance2(code,state,n,offset,length,lane,count,i,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6154,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32],O.Heap(n,0));
    state := next2;
    Advance3(code,state,n,offset,length,lane,count,i,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6154,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32],O.Heap(n,0));
    state := next3;
    Advance4(code,state,n,offset,length,lane,count,i,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6154,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32],O.Heap(n,0));
    state := next4;
    Advance5(code,state,n,offset,length,lane,count,i,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6154,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32],O.Heap(n,0));
    state := next5;
    Advance6(code,state,n,offset,length,lane,count,i,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6154,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32],O.Heap(n,0));
    state := next6;
    Advance7(code,state,n,offset,length,lane,count,i,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(6154,[2989505972,518,offset,length,lane,96,count,n,128,n*32,160,n*32],O.Heap(n,0));
    state := next7;
  }
}
