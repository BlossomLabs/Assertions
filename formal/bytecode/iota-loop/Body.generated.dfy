// SPDX-License-Identifier: MIT
// Generated actual iota loop body and exit instructions.
include "../iota/Output.dfy"
include "../scans/Execution.dfy"
module BytecodeIotaLoopBody {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import O = BytecodeIotaOutput
  predicate Admitted(n: Word, i: Word) { n < 0x800000000000000 && i < n }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[5623] == 91 &&
                                              code[5624] == 130 &&
                                              code[5625] == 129 &&
                                              code[5626] == 16 &&
                                              code[5627] == 21 &&
                                              code[5628] == 97 &&
                                              code[5629] == 22 &&
                                              code[5630] == 18 &&
                                              code[5631] == 87 &&
                                              code[5632] == 96 &&
                                              code[5633] == 32 &&
                                              code[5634] == 128 &&
                                              code[5635] == 130 &&
                                              code[5636] == 2 &&
                                              code[5637] == 131 &&
                                              code[5638] == 1 &&
                                              code[5639] == 1 &&
                                              code[5640] == 129 &&
                                              code[5641] == 144 &&
                                              code[5642] == 82 &&
                                              code[5643] == 96 &&
                                              code[5644] == 1 &&
                                              code[5645] == 1 &&
                                              code[5646] == 97 &&
                                              code[5647] == 21 &&
                                              code[5648] == 247 &&
                                              code[5649] == 86 &&
                                              code[5650] == 91
  }
  function Destinations(): set<nat> { {5623,5650} }
  opaque predicate Good(id: nat, state: State, n: Word, i: Word) { Admitted(n,i) && (
                                                                     if id == 0 then state == Running(5623,[2368205965,518,n,128,i],O.Heap(n,i))
                                                                     else if id == 1 then state == Running(5624,[2368205965,518,n,128,i],O.Heap(n,i))
                                                                     else if id == 2 then state == Running(5625,[2368205965,518,n,128,i,n],O.Heap(n,i))
                                                                     else if id == 3 then state == Running(5626,[2368205965,518,n,128,i,n,i],O.Heap(n,i))
                                                                     else if id == 4 then state == Running(5627,[2368205965,518,n,128,i,1],O.Heap(n,i))
                                                                     else if id == 5 then state == Running(5628,[2368205965,518,n,128,i,0],O.Heap(n,i))
                                                                     else if id == 6 then state == Running(5631,[2368205965,518,n,128,i,0,5650],O.Heap(n,i))
                                                                     else if id == 7 then state == Running(5632,[2368205965,518,n,128,i],O.Heap(n,i))
                                                                     else if id == 8 then state == Running(5634,[2368205965,518,n,128,i,32],O.Heap(n,i))
                                                                     else if id == 9 then state == Running(5635,[2368205965,518,n,128,i,32,32],O.Heap(n,i))
                                                                     else if id == 10 then state == Running(5636,[2368205965,518,n,128,i,32,32,i],O.Heap(n,i))
                                                                     else if id == 11 then state == Running(5637,[2368205965,518,n,128,i,32,i*32],O.Heap(n,i))
                                                                     else if id == 12 then state == Running(5638,[2368205965,518,n,128,i,32,i*32,128],O.Heap(n,i))
                                                                     else if id == 13 then state == Running(5639,[2368205965,518,n,128,i,32,128+i*32],O.Heap(n,i))
                                                                     else if id == 14 then state == Running(5640,[2368205965,518,n,128,i,160+i*32],O.Heap(n,i))
                                                                     else if id == 15 then state == Running(5641,[2368205965,518,n,128,i,160+i*32,i],O.Heap(n,i))
                                                                     else if id == 16 then state == Running(5642,[2368205965,518,n,128,i,i,160+i*32],O.Heap(n,i))
                                                                     else if id == 17 then state == Running(5643,[2368205965,518,n,128,i],O.Heap(n,i+1))
                                                                     else if id == 18 then state == Running(5645,[2368205965,518,n,128,i,1],O.Heap(n,i+1))
                                                                     else if id == 19 then state == Running(5646,[2368205965,518,n,128,i+1],O.Heap(n,i+1))
                                                                     else if id == 20 then state == Running(5649,[2368205965,518,n,128,i+1,5623],O.Heap(n,i+1))
                                                                     else false) }
  lemma Advance0(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(0,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5623,[2368205965,518,n,128,i],O.Heap(n,i));
    assert Fetch(code,5623) == Op(91,5624,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(1,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5624,[2368205965,518,n,128,i],O.Heap(n,i));
    assert Fetch(code,5624) == Op(130,5625,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(2,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5625,[2368205965,518,n,128,i,n],O.Heap(n,i));
    assert Fetch(code,5625) == Op(129,5626,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(3,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5626,[2368205965,518,n,128,i,n,i],O.Heap(n,i));
    assert Fetch(code,5626) == Op(16,5627,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(4,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5627,[2368205965,518,n,128,i,1],O.Heap(n,i));
    assert Fetch(code,5627) == Op(21,5628,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(5,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5628,[2368205965,518,n,128,i,0],O.Heap(n,i));
    F.Push2(code,5628);
    assert Fetch(code,5628) == Op(97,5631,5650);
  }
  lemma Advance6(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(6,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5631,[2368205965,518,n,128,i,0,5650],O.Heap(n,i));
    assert Fetch(code,5631) == Op(87,5632,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(7,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5632,[2368205965,518,n,128,i],O.Heap(n,i));
    F.Push1(code,5632);
    assert Fetch(code,5632) == Op(96,5634,32);
  }
  lemma Advance8(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(8,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5634,[2368205965,518,n,128,i,32],O.Heap(n,i));
    assert Fetch(code,5634) == Op(128,5635,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(9,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5635,[2368205965,518,n,128,i,32,32],O.Heap(n,i));
    assert Fetch(code,5635) == Op(130,5636,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(10,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5636,[2368205965,518,n,128,i,32,32,i],O.Heap(n,i));
    assert Fetch(code,5636) == Op(2,5637,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(11,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5637,[2368205965,518,n,128,i,32,i*32],O.Heap(n,i));
    assert Fetch(code,5637) == Op(131,5638,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(12,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5638,[2368205965,518,n,128,i,32,i*32,128],O.Heap(n,i));
    assert Fetch(code,5638) == Op(1,5639,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(13,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5639,[2368205965,518,n,128,i,32,128+i*32],O.Heap(n,i));
    assert Fetch(code,5639) == Op(1,5640,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(14,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5640,[2368205965,518,n,128,i,160+i*32],O.Heap(n,i));
    assert Fetch(code,5640) == Op(129,5641,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(15,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5641,[2368205965,518,n,128,i,160+i*32,i],O.Heap(n,i));
    assert Fetch(code,5641) == Op(144,5642,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(16,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();
    O.Advance(n,i);
    assert state == Running(5642,[2368205965,518,n,128,i,i,160+i*32],O.Heap(n,i));
    assert Fetch(code,5642) == Op(82,5643,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(17,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5643,[2368205965,518,n,128,i],O.Heap(n,i+1));
    F.Push1(code,5643);
    assert Fetch(code,5643) == Op(96,5645,1);
  }
  lemma Advance18(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(18,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5645,[2368205965,518,n,128,i,1],O.Heap(n,i+1));
    assert Fetch(code,5645) == Op(1,5646,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(19,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,n,i)
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5646,[2368205965,518,n,128,i+1],O.Heap(n,i+1));
    F.Push2(code,5646);
    assert Fetch(code,5646) == Op(97,5649,5623);
  }
  lemma Advance20(code: seq<Byte>, state: State, n: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,i) && Good(20,state,n,i)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(5623,[2368205965,518,n,128,i+1],O.Heap(n,i+1))
  {
    reveal Matches(); reveal Good(); reveal Step();

    assert state == Running(5649,[2368205965,518,n,128,i+1,5623],O.Heap(n,i+1));
    assert Fetch(code,5649) == Op(86,5650,0);
  }
  lemma Start(n: Word, i: Word)
    requires Admitted(n,i)
    ensures Good(0,Running(5623,[2368205965,518,n,128,i],O.Heap(n,i)),n,i)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, n: Word, i: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,i)
    ensures state == Running(5623,[2368205965,518,n,128,i+1],O.Heap(n,i+1))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 22 && trace[0] == Running(5623,[2368205965,518,n,128,i],O.Heap(n,i)) && trace[|trace|-1] == state
  {
    Start(n,i);
    state := Running(5623,[2368205965,518,n,128,i],O.Heap(n,i));
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
    Advance8(code,state,n,i,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,n,i,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,n,i,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
    Advance11(code,state,n,i,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    state := next11;
    Advance12(code,state,n,i,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    state := next12;
    Advance13(code,state,n,i,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    state := next13;
    Advance14(code,state,n,i,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    state := next14;
    Advance15(code,state,n,i,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    state := next15;
    Advance16(code,state,n,i,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    state := next16;
    Advance17(code,state,n,i,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    state := next17;
    Advance18(code,state,n,i,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    state := next18;
    Advance19(code,state,n,i,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    state := next19;
    Advance20(code,state,n,i,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    state := next20;
  }
}
