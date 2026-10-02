// SPDX-License-Identifier: MIT
// Generated actual post-copy allocator instructions.
include "../../iota/Output.dfy"
include "../../scans/Execution.dfy"
module BytecodeUniqueAllocationAfterCopy {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import O = BytecodeIotaOutput
  predicate Admitted(n: Word, offset: Word, length: Word, ordered: Word) { n < 0x800000000000000 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6715] == 1 &&
                                              code[6716] == 144 &&
                                              code[6717] == 80 &&
                                              code[6718] == 91 &&
                                              code[6719] == 80 &&
                                              code[6720] == 144 &&
                                              code[6721] == 80 &&
                                              code[6722] == 95 &&
                                              code[6723] == 128
  }
  function Destinations(): set<nat> { {} }
  opaque predicate Good(id: nat, state: State, n: Word, offset: Word, length: Word, ordered: Word) { Admitted(n,offset,length,ordered) && (
                                                                                                       if id == 0 then state == Running(6715,[3045624246,518,offset,length,ordered,96,128,n*32,160,n*32],O.Heap(n,0))
                                                                                                       else if id == 1 then state == Running(6716,[3045624246,518,offset,length,ordered,96,128,n*32,O.Extent(n)],O.Heap(n,0))
                                                                                                       else if id == 2 then state == Running(6717,[3045624246,518,offset,length,ordered,96,128,O.Extent(n),n*32],O.Heap(n,0))
                                                                                                       else if id == 3 then state == Running(6718,[3045624246,518,offset,length,ordered,96,128,O.Extent(n)],O.Heap(n,0))
                                                                                                       else if id == 4 then state == Running(6719,[3045624246,518,offset,length,ordered,96,128,O.Extent(n)],O.Heap(n,0))
                                                                                                       else if id == 5 then state == Running(6720,[3045624246,518,offset,length,ordered,96,128],O.Heap(n,0))
                                                                                                       else if id == 6 then state == Running(6721,[3045624246,518,offset,length,ordered,128,96],O.Heap(n,0))
                                                                                                       else if id == 7 then state == Running(6722,[3045624246,518,offset,length,ordered,128],O.Heap(n,0))
                                                                                                       else if id == 8 then state == Running(6723,[3045624246,518,offset,length,ordered,128,0],O.Heap(n,0))
                                                                                                       else false) }
  lemma Advance0(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered) && Good(0,state,n,offset,length,ordered)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,n,offset,length,ordered)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(6715,[3045624246,518,offset,length,ordered,96,128,n*32,160,n*32],O.Heap(n,0));
    assert Fetch(code,6715) == Op(1,6716,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered) && Good(1,state,n,offset,length,ordered)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,n,offset,length,ordered)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(6716,[3045624246,518,offset,length,ordered,96,128,n*32,O.Extent(n)],O.Heap(n,0));
    assert Fetch(code,6716) == Op(144,6717,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered) && Good(2,state,n,offset,length,ordered)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,n,offset,length,ordered)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(6717,[3045624246,518,offset,length,ordered,96,128,O.Extent(n),n*32],O.Heap(n,0));
    assert Fetch(code,6717) == Op(80,6718,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered) && Good(3,state,n,offset,length,ordered)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,n,offset,length,ordered)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(6718,[3045624246,518,offset,length,ordered,96,128,O.Extent(n)],O.Heap(n,0));
    assert Fetch(code,6718) == Op(91,6719,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered) && Good(4,state,n,offset,length,ordered)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,n,offset,length,ordered)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(6719,[3045624246,518,offset,length,ordered,96,128,O.Extent(n)],O.Heap(n,0));
    assert Fetch(code,6719) == Op(80,6720,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered) && Good(5,state,n,offset,length,ordered)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,n,offset,length,ordered)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(6720,[3045624246,518,offset,length,ordered,96,128],O.Heap(n,0));
    assert Fetch(code,6720) == Op(144,6721,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered) && Good(6,state,n,offset,length,ordered)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,n,offset,length,ordered)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(6721,[3045624246,518,offset,length,ordered,128,96],O.Heap(n,0));
    assert Fetch(code,6721) == Op(80,6722,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered) && Good(7,state,n,offset,length,ordered)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,n,offset,length,ordered)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(6722,[3045624246,518,offset,length,ordered,128],O.Heap(n,0));
    assert Fetch(code,6722) == Op(95,6723,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,length,ordered) && Good(8,state,n,offset,length,ordered)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(6724,[3045624246,518,offset,length,ordered,128,0,0],O.Heap(n,0))
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(6723,[3045624246,518,offset,length,ordered,128,0],O.Heap(n,0));
    assert Fetch(code,6723) == Op(128,6724,0);
  }
  lemma Start(n: Word, offset: Word, length: Word, ordered: Word)
    requires Admitted(n,offset,length,ordered)
    ensures Good(0,Running(6715,[3045624246,518,offset,length,ordered,96,128,n*32,160,n*32],O.Heap(n,0)),n,offset,length,ordered)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, n: Word, offset: Word, length: Word, ordered: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,offset,length,ordered)
    ensures state == Running(6724,[3045624246,518,offset,length,ordered,128,0,0],O.Heap(n,0))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 10 && trace[0] == Running(6715,[3045624246,518,offset,length,ordered,96,128,n*32,160,n*32],O.Heap(n,0)) && trace[|trace|-1] == state
  {
    Start(n,offset,length,ordered);
    state := Running(6715,[3045624246,518,offset,length,ordered,96,128,n*32,160,n*32],O.Heap(n,0));
    trace := [state];
    Advance0(code,state,n,offset,length,ordered,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6715,[3045624246,518,offset,length,ordered,96,128,n*32,160,n*32],O.Heap(n,0));
    state := next0;
    Advance1(code,state,n,offset,length,ordered,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6715,[3045624246,518,offset,length,ordered,96,128,n*32,160,n*32],O.Heap(n,0));
    state := next1;
    Advance2(code,state,n,offset,length,ordered,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6715,[3045624246,518,offset,length,ordered,96,128,n*32,160,n*32],O.Heap(n,0));
    state := next2;
    Advance3(code,state,n,offset,length,ordered,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6715,[3045624246,518,offset,length,ordered,96,128,n*32,160,n*32],O.Heap(n,0));
    state := next3;
    Advance4(code,state,n,offset,length,ordered,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6715,[3045624246,518,offset,length,ordered,96,128,n*32,160,n*32],O.Heap(n,0));
    state := next4;
    Advance5(code,state,n,offset,length,ordered,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6715,[3045624246,518,offset,length,ordered,96,128,n*32,160,n*32],O.Heap(n,0));
    state := next5;
    Advance6(code,state,n,offset,length,ordered,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6715,[3045624246,518,offset,length,ordered,96,128,n*32,160,n*32],O.Heap(n,0));
    state := next6;
    Advance7(code,state,n,offset,length,ordered,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(6715,[3045624246,518,offset,length,ordered,96,128,n*32,160,n*32],O.Heap(n,0));
    state := next7;
    Advance8(code,state,n,offset,length,ordered,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(6715,[3045624246,518,offset,length,ordered,96,128,n*32,160,n*32],O.Heap(n,0));
    state := next8;
  }
}
