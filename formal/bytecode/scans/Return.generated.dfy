// SPDX-License-Identifier: MIT
// Generated physical scalar-return instructions from the pinned current runtime.
include "Execution.dfy"
module BytecodeSumReturn {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import R = BytecodeScanRepresentation
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[490] == 91 &&
                                              code[491] == 96 &&
                                              code[492] == 64 &&
                                              code[493] == 81 &&
                                              code[494] == 128 &&
                                              code[495] == 145 &&
                                              code[496] == 3 &&
                                              code[497] == 144 &&
                                              code[498] == 243 &&
                                              code[604] == 91 &&
                                              code[605] == 96 &&
                                              code[606] == 64 &&
                                              code[607] == 81 &&
                                              code[608] == 144 &&
                                              code[609] == 129 &&
                                              code[610] == 82 &&
                                              code[611] == 96 &&
                                              code[612] == 32 &&
                                              code[613] == 1 &&
                                              code[614] == 97 &&
                                              code[615] == 1 &&
                                              code[616] == 234 &&
                                              code[617] == 86
  }
  function Destinations(): set<nat> { {490} }
  opaque predicate Good(id: nat, state: State, total: Word) {
    if id == 0 then state == Running(604,[394725771,total],Store([],64,128))
    else if id == 1 then state == Running(605,[394725771,total],Store([],64,128))
    else if id == 2 then state == Running(607,[394725771,total,64],Store([],64,128))
    else if id == 3 then state == Running(608,[394725771,total,128],Store([],64,128))
    else if id == 4 then state == Running(609,[394725771,128,total],Store([],64,128))
    else if id == 5 then state == Running(610,[394725771,128,total,128],Store([],64,128))
    else if id == 6 then state == Running(611,[394725771,128],Store(Store([],64,128),128,total))
    else if id == 7 then state == Running(613,[394725771,128,32],Store(Store([],64,128),128,total))
    else if id == 8 then state == Running(614,[394725771,160],Store(Store([],64,128),128,total))
    else if id == 9 then state == Running(617,[394725771,160,490],Store(Store([],64,128),128,total))
    else if id == 10 then state == Running(490,[394725771,160],Store(Store([],64,128),128,total))
    else if id == 11 then state == Running(491,[394725771,160],Store(Store([],64,128),128,total))
    else if id == 12 then state == Running(493,[394725771,160,64],Store(Store([],64,128),128,total))
    else if id == 13 then state == Running(494,[394725771,160,128],Store(Store([],64,128),128,total))
    else if id == 14 then state == Running(495,[394725771,160,128,128],Store(Store([],64,128),128,total))
    else if id == 15 then state == Running(496,[394725771,128,128,160],Store(Store([],64,128),128,total))
    else if id == 16 then state == Running(497,[394725771,128,32],Store(Store([],64,128),128,total))
    else if id == 17 then state == Running(498,[394725771,32,128],Store(Store([],64,128),128,total))
    else false
  }
  lemma Advance0(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(0,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,total)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(604,[394725771,total],Store([],64,128));
    assert Fetch(code,604) == Op(91,605,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(1,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,total)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(605,[394725771,total],Store([],64,128));
    F.Push1(code,605);
    assert Fetch(code,605) == Op(96,607,64);
  }
  lemma Advance2(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(2,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,total)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(607,[394725771,total,64],Store([],64,128));
    assert Fetch(code,607) == Op(81,608,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(3,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,total)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(608,[394725771,total,128],Store([],64,128));
    assert Fetch(code,608) == Op(144,609,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(4,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,total)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(609,[394725771,128,total],Store([],64,128));
    assert Fetch(code,609) == Op(129,610,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(5,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,total)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(610,[394725771,128,total,128],Store([],64,128));
    assert Fetch(code,610) == Op(82,611,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(6,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,total)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(611,[394725771,128],Store(Store([],64,128),128,total));
    F.Push1(code,611);
    assert Fetch(code,611) == Op(96,613,32);
  }
  lemma Advance7(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(7,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,total)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(613,[394725771,128,32],Store(Store([],64,128),128,total));
    assert Fetch(code,613) == Op(1,614,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(8,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,total)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(614,[394725771,160],Store(Store([],64,128),128,total));
    F.Push2(code,614);
    assert Fetch(code,614) == Op(97,617,490);
  }
  lemma Advance9(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(9,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,total)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(617,[394725771,160,490],Store(Store([],64,128),128,total));
    assert Fetch(code,617) == Op(86,618,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(10,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,total)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(490,[394725771,160],Store(Store([],64,128),128,total));
    assert Fetch(code,490) == Op(91,491,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(11,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,total)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(491,[394725771,160],Store(Store([],64,128),128,total));
    F.Push1(code,491);
    assert Fetch(code,491) == Op(96,493,64);
  }
  lemma Advance12(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(12,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,total)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(493,[394725771,160,64],Store(Store([],64,128),128,total));
    assert Fetch(code,493) == Op(81,494,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(13,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,total)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(494,[394725771,160,128],Store(Store([],64,128),128,total));
    assert Fetch(code,494) == Op(128,495,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(14,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,total)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(495,[394725771,160,128,128],Store(Store([],64,128),128,total));
    assert Fetch(code,495) == Op(145,496,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(15,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,total)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(496,[394725771,128,128,160],Store(Store([],64,128),128,total));
    assert Fetch(code,496) == Op(3,497,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(16,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,total)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(497,[394725771,128,32],Store(Store([],64,128),128,total));
    assert Fetch(code,497) == Op(144,498,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(17,state,total)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Returned(G.Encode(total,32))
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running(498,[394725771,32,128],Store(Store([],64,128),128,total));
    assert Fetch(code,498) == Op(243,499,0);
  }
  lemma Start(total: Word)
    ensures Good(0,Running(604,[394725771,total],Store([],64,128)),total)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, total: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code)
    ensures state == Returned(G.Encode(total,32))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 19 && trace[0] == Running(604,[394725771,total],Store([],64,128)) && trace[|trace|-1] == state
  {
    Start(total);
    state := Running(604,[394725771,total],Store([],64,128));
    trace := [state];
    Advance0(code,state,total,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,total,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,total,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,total,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,total,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,total,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,total,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,total,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,total,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,total,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,total,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
    Advance11(code,state,total,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    state := next11;
    Advance12(code,state,total,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    state := next12;
    Advance13(code,state,total,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    state := next13;
    Advance14(code,state,total,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    state := next14;
    Advance15(code,state,total,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    state := next15;
    Advance16(code,state,total,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    state := next16;
    Advance17(code,state,total,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    state := next17;
  }
}
