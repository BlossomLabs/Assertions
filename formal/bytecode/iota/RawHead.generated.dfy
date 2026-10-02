// SPDX-License-Identifier: MIT
// Generated actual iota scalar wrapper/decoder instructions.
include "../scans/Execution.dfy"
module BytecodeIotaRawHead {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  function N(data: seq<Byte>): Word { DataWord(data,4) }
  predicate Admitted(data: seq<Byte>) { 4 <= |data| < 36 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[789] == 91 &&
                                              code[790] == 97 &&
                                              code[791] == 2 &&
                                              code[792] == 6 &&
                                              code[793] == 97 &&
                                              code[794] == 3 &&
                                              code[795] == 35 &&
                                              code[796] == 54 &&
                                              code[797] == 96 &&
                                              code[798] == 4 &&
                                              code[799] == 97 &&
                                              code[800] == 88 &&
                                              code[801] == 224 &&
                                              code[802] == 86 &&
                                              code[22752] == 91 &&
                                              code[22753] == 95 &&
                                              code[22754] == 96 &&
                                              code[22755] == 32 &&
                                              code[22756] == 130 &&
                                              code[22757] == 132 &&
                                              code[22758] == 3 &&
                                              code[22759] == 18 &&
                                              code[22760] == 21 &&
                                              code[22761] == 97 &&
                                              code[22762] == 88 &&
                                              code[22763] == 240 &&
                                              code[22764] == 87 &&
                                              code[22765] == 95 &&
                                              code[22766] == 95 &&
                                              code[22767] == 253 &&
                                              code[22768] == 91
  }
  function Destinations(): set<nat> { {22752,22768} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>) { Admitted(data) && (
                                                                    if id == 0 then state == Running(789,[2368205965],Store([],64,128))
                                                                    else if id == 1 then state == Running(790,[2368205965],Store([],64,128))
                                                                    else if id == 2 then state == Running(793,[2368205965,518],Store([],64,128))
                                                                    else if id == 3 then state == Running(796,[2368205965,518,803],Store([],64,128))
                                                                    else if id == 4 then state == Running(797,[2368205965,518,803,|data|],Store([],64,128))
                                                                    else if id == 5 then state == Running(799,[2368205965,518,803,|data|,4],Store([],64,128))
                                                                    else if id == 6 then state == Running(802,[2368205965,518,803,|data|,4,22752],Store([],64,128))
                                                                    else if id == 7 then state == Running(22752,[2368205965,518,803,|data|,4],Store([],64,128))
                                                                    else if id == 8 then state == Running(22753,[2368205965,518,803,|data|,4],Store([],64,128))
                                                                    else if id == 9 then state == Running(22754,[2368205965,518,803,|data|,4,0],Store([],64,128))
                                                                    else if id == 10 then state == Running(22756,[2368205965,518,803,|data|,4,0,32],Store([],64,128))
                                                                    else if id == 11 then state == Running(22757,[2368205965,518,803,|data|,4,0,32,4],Store([],64,128))
                                                                    else if id == 12 then state == Running(22758,[2368205965,518,803,|data|,4,0,32,4,|data|],Store([],64,128))
                                                                    else if id == 13 then state == Running(22759,[2368205965,518,803,|data|,4,0,32,(|data|-4)],Store([],64,128))
                                                                    else if id == 14 then state == Running(22760,[2368205965,518,803,|data|,4,0,1],Store([],64,128))
                                                                    else if id == 15 then state == Running(22761,[2368205965,518,803,|data|,4,0,0],Store([],64,128))
                                                                    else if id == 16 then state == Running(22764,[2368205965,518,803,|data|,4,0,0,22768],Store([],64,128))
                                                                    else if id == 17 then state == Running(22765,[2368205965,518,803,|data|,4,0],Store([],64,128))
                                                                    else if id == 18 then state == Running(22766,[2368205965,518,803,|data|,4,0,0],Store([],64,128))
                                                                    else if id == 19 then state == Running(22767,[2368205965,518,803,|data|,4,0,0,0],Store([],64,128))
                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(0,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(789,[2368205965],Store([],64,128));
    assert Fetch(code,789) == Op(91,790,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(1,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(790,[2368205965],Store([],64,128));
    F.Push2(code,790);
    assert Fetch(code,790) == Op(97,793,518);
  }
  lemma Advance2(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(2,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(793,[2368205965,518],Store([],64,128));
    F.Push2(code,793);
    assert Fetch(code,793) == Op(97,796,803);
  }
  lemma Advance3(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(3,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(796,[2368205965,518,803],Store([],64,128));
    assert Fetch(code,796) == Op(54,797,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(4,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(797,[2368205965,518,803,|data|],Store([],64,128));
    F.Push1(code,797);
    assert Fetch(code,797) == Op(96,799,4);
  }
  lemma Advance5(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(5,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(799,[2368205965,518,803,|data|,4],Store([],64,128));
    F.Push2(code,799);
    assert Fetch(code,799) == Op(97,802,22752);
  }
  lemma Advance6(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(6,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(802,[2368205965,518,803,|data|,4,22752],Store([],64,128));
    assert Fetch(code,802) == Op(86,803,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(7,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22752,[2368205965,518,803,|data|,4],Store([],64,128));
    assert Fetch(code,22752) == Op(91,22753,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(8,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22753,[2368205965,518,803,|data|,4],Store([],64,128));
    assert Fetch(code,22753) == Op(95,22754,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(9,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22754,[2368205965,518,803,|data|,4,0],Store([],64,128));
    F.Push1(code,22754);
    assert Fetch(code,22754) == Op(96,22756,32);
  }
  lemma Advance10(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(10,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22756,[2368205965,518,803,|data|,4,0,32],Store([],64,128));
    assert Fetch(code,22756) == Op(130,22757,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(11,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22757,[2368205965,518,803,|data|,4,0,32,4],Store([],64,128));
    assert Fetch(code,22757) == Op(132,22758,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(12,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22758,[2368205965,518,803,|data|,4,0,32,4,|data|],Store([],64,128));
    assert Fetch(code,22758) == Op(3,22759,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(13,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22759,[2368205965,518,803,|data|,4,0,32,(|data|-4)],Store([],64,128));
    assert Fetch(code,22759) == Op(18,22760,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(14,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22760,[2368205965,518,803,|data|,4,0,1],Store([],64,128));
    assert Fetch(code,22760) == Op(21,22761,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(15,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22761,[2368205965,518,803,|data|,4,0,0],Store([],64,128));
    F.Push2(code,22761);
    assert Fetch(code,22761) == Op(97,22764,22768);
  }
  lemma Advance16(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(16,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22764,[2368205965,518,803,|data|,4,0,0,22768],Store([],64,128));
    assert Fetch(code,22764) == Op(87,22765,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(17,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22765,[2368205965,518,803,|data|,4,0],Store([],64,128));
    assert Fetch(code,22765) == Op(95,22766,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(18,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22766,[2368205965,518,803,|data|,4,0,0],Store([],64,128));
    assert Fetch(code,22766) == Op(95,22767,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(19,state,data)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted([])
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22767,[2368205965,518,803,|data|,4,0,0,0],Store([],64,128));
    assert Fetch(code,22767) == Op(253,22768,0);
  }
  lemma Start(data: seq<Byte>)
    requires Admitted(data)
    ensures Good(0,Running(789,[2368205965],Store([],64,128)),data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data)
    ensures state == Reverted([])
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == Running(789,[2368205965],Store([],64,128)) && trace[|trace|-1] == state
  {
    Start(data);
    state := Running(789,[2368205965],Store([],64,128));
    trace := [state];
    Advance0(code,state,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
    Advance11(code,state,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    state := next11;
    Advance12(code,state,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    state := next12;
    Advance13(code,state,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    state := next13;
    Advance14(code,state,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    state := next14;
    Advance15(code,state,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    state := next15;
    Advance16(code,state,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    state := next16;
    Advance17(code,state,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    state := next17;
    Advance18(code,state,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    state := next18;
    Advance19(code,state,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    state := next19;
  }
}
