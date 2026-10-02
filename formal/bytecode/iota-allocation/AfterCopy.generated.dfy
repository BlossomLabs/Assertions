// SPDX-License-Identifier: MIT
// Generated actual post-copy allocator instructions.
include "../iota/Output.dfy"
include "../scans/Execution.dfy"
module BytecodeIotaAllocationAfterCopy {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import O = BytecodeIotaOutput
  predicate Admitted(n: Word, i: Word) { n < 0x800000000000000 && i == 0 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[5615] == 1 &&
                                              code[5616] == 144 &&
                                              code[5617] == 80 &&
                                              code[5618] == 91 &&
                                              code[5619] == 80 &&
                                              code[5620] == 144 &&
                                              code[5621] == 80 &&
                                              code[5622] == 95
  }
  function Destinations(): set<nat> { {} }
  opaque predicate Good(id: nat, state: State, n: Word, i: Word) { Admitted(n,i) && (
                                                                     if id == 0 then state == Running(5615,[2368205965,518,n,96,128,n*32,160,n*32],O.Heap(n,0))
                                                                     else if id == 1 then state == Running(5616,[2368205965,518,n,96,128,n*32,O.Extent(n)],O.Heap(n,0))
                                                                     else if id == 2 then state == Running(5617,[2368205965,518,n,96,128,O.Extent(n),n*32],O.Heap(n,0))
                                                                     else if id == 3 then state == Running(5618,[2368205965,518,n,96,128,O.Extent(n)],O.Heap(n,0))
                                                                     else if id == 4 then state == Running(5619,[2368205965,518,n,96,128,O.Extent(n)],O.Heap(n,0))
                                                                     else if id == 5 then state == Running(5620,[2368205965,518,n,96,128],O.Heap(n,0))
                                                                     else if id == 6 then state == Running(5621,[2368205965,518,n,128,96],O.Heap(n,0))
                                                                     else if id == 7 then state == Running(5622,[2368205965,518,n,128],O.Heap(n,0))
                                                                     else false) }
  lemma Advance0(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(0,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5615,[2368205965,518,n,96,128,n*32,160,n*32],O.Heap(n,0));
    assert Fetch(code,5615) == Op(1,5616,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(1,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5616,[2368205965,518,n,96,128,n*32,O.Extent(n)],O.Heap(n,0));
    assert Fetch(code,5616) == Op(144,5617,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(2,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5617,[2368205965,518,n,96,128,O.Extent(n),n*32],O.Heap(n,0));
    assert Fetch(code,5617) == Op(80,5618,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(3,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5618,[2368205965,518,n,96,128,O.Extent(n)],O.Heap(n,0));
    assert Fetch(code,5618) == Op(91,5619,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(4,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5619,[2368205965,518,n,96,128,O.Extent(n)],O.Heap(n,0));
    assert Fetch(code,5619) == Op(80,5620,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(5,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5620,[2368205965,518,n,96,128],O.Heap(n,0));
    assert Fetch(code,5620) == Op(144,5621,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(6,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5621,[2368205965,518,n,128,96],O.Heap(n,0));
    assert Fetch(code,5621) == Op(80,5622,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(7,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(5623,[2368205965,518,n,128,0],O.Heap(n,0))
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5622,[2368205965,518,n,128],O.Heap(n,0));
    assert Fetch(code,5622) == Op(95,5623,0);
  }
  lemma Start(n: Word, i: Word)
    requires Admitted(n,i)
    ensures Good(0,Running(5615,[2368205965,518,n,96,128,n*32,160,n*32],O.Heap(n,0)),n,i)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, n: Word, i: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,i)
    ensures state == Running(5623,[2368205965,518,n,128,0],O.Heap(n,0))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 9 && trace[0] == Running(5615,[2368205965,518,n,96,128,n*32,160,n*32],O.Heap(n,0)) && trace[|trace|-1] == state
  {
    Start(n,i);
    state := Running(5615,[2368205965,518,n,96,128,n*32,160,n*32],O.Heap(n,0));
    trace := [state];
    Advance0(code,state,n,i,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,n,i,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,n,i,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,n,i,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,n,i,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,n,i,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,n,i,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,n,i,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
  }
}
