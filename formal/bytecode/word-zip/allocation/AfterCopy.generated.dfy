// SPDX-License-Identifier: MIT
// Generated actual post-copy allocator instructions.
include "../../iota/Output.dfy"
include "../../scans/Execution.dfy"
module BytecodeZipAllocationAfterCopy {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import O = BytecodeIotaOutput
  predicate Admitted(n: Word, a: Word, length: Word, b: Word, count: Word, i: Word) { n < 0x800000000000000 && i == 0 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[2086] == 1 &&
                                              code[2087] == 144 &&
                                              code[2088] == 80 &&
                                              code[2089] == 91 &&
                                              code[2090] == 80 &&
                                              code[2091] == 145 &&
                                              code[2092] == 80 &&
                                              code[2093] == 95
  }
  function Destinations(): set<nat> { {} }
  opaque predicate Good(id: nat, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, i: Word) { Admitted(n,a,length,b,count,i) && (
                                                                                                                  if id == 0 then state == Running(2086,[269019481,518,a,length,b,length,96,count,128,n*32,160,n*32],O.Heap(n,0))
                                                                                                                  else if id == 1 then state == Running(2087,[269019481,518,a,length,b,length,96,count,128,n*32,O.Extent(n)],O.Heap(n,0))
                                                                                                                  else if id == 2 then state == Running(2088,[269019481,518,a,length,b,length,96,count,128,O.Extent(n),n*32],O.Heap(n,0))
                                                                                                                  else if id == 3 then state == Running(2089,[269019481,518,a,length,b,length,96,count,128,O.Extent(n)],O.Heap(n,0))
                                                                                                                  else if id == 4 then state == Running(2090,[269019481,518,a,length,b,length,96,count,128,O.Extent(n)],O.Heap(n,0))
                                                                                                                  else if id == 5 then state == Running(2091,[269019481,518,a,length,b,length,96,count,128],O.Heap(n,0))
                                                                                                                  else if id == 6 then state == Running(2092,[269019481,518,a,length,b,length,128,count,96],O.Heap(n,0))
                                                                                                                  else if id == 7 then state == Running(2093,[269019481,518,a,length,b,length,128,count],O.Heap(n,0))
                                                                                                                  else false) }
  lemma Advance0(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,i) && Good(0,state,n,a,length,b,count,i)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,n,a,length,b,count,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(2086,[269019481,518,a,length,b,length,96,count,128,n*32,160,n*32],O.Heap(n,0));
    assert Fetch(code,2086) == Op(1,2087,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,i) && Good(1,state,n,a,length,b,count,i)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,n,a,length,b,count,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(2087,[269019481,518,a,length,b,length,96,count,128,n*32,O.Extent(n)],O.Heap(n,0));
    assert Fetch(code,2087) == Op(144,2088,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,i) && Good(2,state,n,a,length,b,count,i)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,n,a,length,b,count,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(2088,[269019481,518,a,length,b,length,96,count,128,O.Extent(n),n*32],O.Heap(n,0));
    assert Fetch(code,2088) == Op(80,2089,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,i) && Good(3,state,n,a,length,b,count,i)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,n,a,length,b,count,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(2089,[269019481,518,a,length,b,length,96,count,128,O.Extent(n)],O.Heap(n,0));
    assert Fetch(code,2089) == Op(91,2090,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,i) && Good(4,state,n,a,length,b,count,i)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,n,a,length,b,count,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(2090,[269019481,518,a,length,b,length,96,count,128,O.Extent(n)],O.Heap(n,0));
    assert Fetch(code,2090) == Op(80,2091,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,i) && Good(5,state,n,a,length,b,count,i)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,n,a,length,b,count,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(2091,[269019481,518,a,length,b,length,96,count,128],O.Heap(n,0));
    assert Fetch(code,2091) == Op(145,2092,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,i) && Good(6,state,n,a,length,b,count,i)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,n,a,length,b,count,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(2092,[269019481,518,a,length,b,length,128,count,96],O.Heap(n,0));
    assert Fetch(code,2092) == Op(80,2093,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, n: Word, a: Word, length: Word, b: Word, count: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,a,length,b,count,i) && Good(7,state,n,a,length,b,count,i)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(2094,[269019481,518,a,length,b,length,128,count,0],O.Heap(n,0))
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(2093,[269019481,518,a,length,b,length,128,count],O.Heap(n,0));
    assert Fetch(code,2093) == Op(95,2094,0);
  }
  lemma Start(n: Word, a: Word, length: Word, b: Word, count: Word, i: Word)
    requires Admitted(n,a,length,b,count,i)
    ensures Good(0,Running(2086,[269019481,518,a,length,b,length,96,count,128,n*32,160,n*32],O.Heap(n,0)),n,a,length,b,count,i)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, n: Word, a: Word, length: Word, b: Word, count: Word, i: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,a,length,b,count,i)
    ensures state == Running(2094,[269019481,518,a,length,b,length,128,count,0],O.Heap(n,0))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 9 && trace[0] == Running(2086,[269019481,518,a,length,b,length,96,count,128,n*32,160,n*32],O.Heap(n,0)) && trace[|trace|-1] == state
  {
    Start(n,a,length,b,count,i);
    state := Running(2086,[269019481,518,a,length,b,length,96,count,128,n*32,160,n*32],O.Heap(n,0));
    trace := [state];
    Advance0(code,state,n,a,length,b,count,i,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(2086,[269019481,518,a,length,b,length,96,count,128,n*32,160,n*32],O.Heap(n,0));
    state := next0;
    Advance1(code,state,n,a,length,b,count,i,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(2086,[269019481,518,a,length,b,length,96,count,128,n*32,160,n*32],O.Heap(n,0));
    state := next1;
    Advance2(code,state,n,a,length,b,count,i,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(2086,[269019481,518,a,length,b,length,96,count,128,n*32,160,n*32],O.Heap(n,0));
    state := next2;
    Advance3(code,state,n,a,length,b,count,i,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(2086,[269019481,518,a,length,b,length,96,count,128,n*32,160,n*32],O.Heap(n,0));
    state := next3;
    Advance4(code,state,n,a,length,b,count,i,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(2086,[269019481,518,a,length,b,length,96,count,128,n*32,160,n*32],O.Heap(n,0));
    state := next4;
    Advance5(code,state,n,a,length,b,count,i,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(2086,[269019481,518,a,length,b,length,96,count,128,n*32,160,n*32],O.Heap(n,0));
    state := next5;
    Advance6(code,state,n,a,length,b,count,i,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(2086,[269019481,518,a,length,b,length,96,count,128,n*32,160,n*32],O.Heap(n,0));
    state := next6;
    Advance7(code,state,n,a,length,b,count,i,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(2086,[269019481,518,a,length,b,length,96,count,128,n*32,160,n*32],O.Heap(n,0));
    state := next7;
  }
}
