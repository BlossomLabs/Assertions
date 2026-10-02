// SPDX-License-Identifier: MIT
// Generated actual raw bytes decoder empty-rejection path.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeUnzipRawHeadShort {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import DS = BytecodeScanDecoderScalar
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  function Head(data: seq<Byte>): Word { DataWord(data,4) }
  function HeadPosition(data: seq<Byte>): Word { ((Head(data) as nat)+4)%G.Modulus() }
  function Length(data: seq<Byte>): Word { DataWord(data,HeadPosition(data)) }
  function Offset(data: seq<Byte>): Word { ((Head(data) as nat)+36)%G.Modulus() }
  predicate Admitted(data: seq<Byte>) { 4 <= |data| < 0x10000000000000000 && |data| < 68 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[865] == 91 &&
                                              code[866] == 97 &&
                                              code[867] == 2 &&
                                              code[868] == 6 &&
                                              code[869] == 97 &&
                                              code[870] == 3 &&
                                              code[871] == 111 &&
                                              code[872] == 54 &&
                                              code[873] == 96 &&
                                              code[874] == 4 &&
                                              code[875] == 97 &&
                                              code[876] == 88 &&
                                              code[877] == 247 &&
                                              code[878] == 86 &&
                                              code[22775] == 91 &&
                                              code[22776] == 95 &&
                                              code[22777] == 95 &&
                                              code[22778] == 95 &&
                                              code[22779] == 96 &&
                                              code[22780] == 64 &&
                                              code[22781] == 132 &&
                                              code[22782] == 134 &&
                                              code[22783] == 3 &&
                                              code[22784] == 18 &&
                                              code[22785] == 21 &&
                                              code[22786] == 97 &&
                                              code[22787] == 89 &&
                                              code[22788] == 9 &&
                                              code[22789] == 87 &&
                                              code[22790] == 95 &&
                                              code[22791] == 95 &&
                                              code[22792] == 253 &&
                                              code[22793] == 91
  }
  function Destinations(): set<nat> { {22775,22793} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>) { Admitted(data) && (
                                                                                    if id == 0 then state == Running(865,[2989505972],mem)
                                                                                    else if id == 1 then state == Running(866,[2989505972],mem)
                                                                                    else if id == 2 then state == Running(869,[2989505972,518],mem)
                                                                                    else if id == 3 then state == Running(872,[2989505972,518,879],mem)
                                                                                    else if id == 4 then state == Running(873,[2989505972,518,879,|data|],mem)
                                                                                    else if id == 5 then state == Running(875,[2989505972,518,879,|data|,4],mem)
                                                                                    else if id == 6 then state == Running(878,[2989505972,518,879,|data|,4,22775],mem)
                                                                                    else if id == 7 then state == Running(22775,[2989505972,518,879,|data|,4],mem)
                                                                                    else if id == 8 then state == Running(22776,[2989505972,518,879,|data|,4],mem)
                                                                                    else if id == 9 then state == Running(22777,[2989505972,518,879,|data|,4,0],mem)
                                                                                    else if id == 10 then state == Running(22778,[2989505972,518,879,|data|,4,0,0],mem)
                                                                                    else if id == 11 then state == Running(22779,[2989505972,518,879,|data|,4,0,0,0],mem)
                                                                                    else if id == 12 then state == Running(22781,[2989505972,518,879,|data|,4,0,0,0,64],mem)
                                                                                    else if id == 13 then state == Running(22782,[2989505972,518,879,|data|,4,0,0,0,64,4],mem)
                                                                                    else if id == 14 then state == Running(22783,[2989505972,518,879,|data|,4,0,0,0,64,4,|data|],mem)
                                                                                    else if id == 15 then state == Running(22784,[2989505972,518,879,|data|,4,0,0,0,64,((|data| as nat)+G.Modulus()-(4 as nat))%G.Modulus()],mem)
                                                                                    else if id == 16 then state == Running(22785,[2989505972,518,879,|data|,4,0,0,0,1],mem)
                                                                                    else if id == 17 then state == Running(22786,[2989505972,518,879,|data|,4,0,0,0,0],mem)
                                                                                    else if id == 18 then state == Running(22789,[2989505972,518,879,|data|,4,0,0,0,0,22793],mem)
                                                                                    else if id == 19 then state == Running(22790,[2989505972,518,879,|data|,4,0,0,0],mem)
                                                                                    else if id == 20 then state == Running(22791,[2989505972,518,879,|data|,4,0,0,0,0],mem)
                                                                                    else if id == 21 then state == Running(22792,[2989505972,518,879,|data|,4,0,0,0,0,0],mem)
                                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(0,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(865,[2989505972],mem);
    assert Fetch(code,865) == Op(91,866,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(1,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(866,[2989505972],mem);
    F.Push2(code,866);
    assert Fetch(code,866) == Op(97,869,518);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(2,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(869,[2989505972,518],mem);
    F.Push2(code,869);
    assert Fetch(code,869) == Op(97,872,879);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(3,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(872,[2989505972,518,879],mem);
    assert Fetch(code,872) == Op(54,873,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(4,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(873,[2989505972,518,879,|data|],mem);
    F.Push1(code,873);
    assert Fetch(code,873) == Op(96,875,4);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(5,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(875,[2989505972,518,879,|data|,4],mem);
    F.Push2(code,875);
    assert Fetch(code,875) == Op(97,878,22775);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(6,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(878,[2989505972,518,879,|data|,4,22775],mem);
    assert Fetch(code,878) == Op(86,879,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(7,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22775,[2989505972,518,879,|data|,4],mem);
    assert Fetch(code,22775) == Op(91,22776,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(8,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22776,[2989505972,518,879,|data|,4],mem);
    assert Fetch(code,22776) == Op(95,22777,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(9,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22777,[2989505972,518,879,|data|,4,0],mem);
    assert Fetch(code,22777) == Op(95,22778,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(10,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22778,[2989505972,518,879,|data|,4,0,0],mem);
    assert Fetch(code,22778) == Op(95,22779,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(11,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22779,[2989505972,518,879,|data|,4,0,0,0],mem);
    F.Push1(code,22779);
    assert Fetch(code,22779) == Op(96,22781,64);
  }
  lemma Advance12(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(12,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22781,[2989505972,518,879,|data|,4,0,0,0,64],mem);
    assert Fetch(code,22781) == Op(132,22782,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(13,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22782,[2989505972,518,879,|data|,4,0,0,0,64,4],mem);
    assert Fetch(code,22782) == Op(134,22783,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(14,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22783,[2989505972,518,879,|data|,4,0,0,0,64,4,|data|],mem);
    assert Fetch(code,22783) == Op(3,22784,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(15,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22784,[2989505972,518,879,|data|,4,0,0,0,64,((|data| as nat)+G.Modulus()-(4 as nat))%G.Modulus()],mem);
    assert Fetch(code,22784) == Op(18,22785,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(16,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22785,[2989505972,518,879,|data|,4,0,0,0,1],mem);
    assert Fetch(code,22785) == Op(21,22786,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(17,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22786,[2989505972,518,879,|data|,4,0,0,0,0],mem);
    F.Push2(code,22786);
    assert Fetch(code,22786) == Op(97,22789,22793);
  }
  lemma Advance18(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(18,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22789,[2989505972,518,879,|data|,4,0,0,0,0,22793],mem);
    assert Fetch(code,22789) == Op(87,22790,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(19,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22790,[2989505972,518,879,|data|,4,0,0,0],mem);
    assert Fetch(code,22790) == Op(95,22791,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(20,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22791,[2989505972,518,879,|data|,4,0,0,0,0],mem);
    assert Fetch(code,22791) == Op(95,22792,0);
  }
  lemma Advance21(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(21,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted([])
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22792,[2989505972,518,879,|data|,4,0,0,0,0,0],mem);
    assert Fetch(code,22792) == Op(253,22793,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>)
    requires Admitted(data)
    ensures Good(0,Running(865,[2989505972],mem),data,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data)
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 23 && trace[0] == Running(865,[2989505972],mem) && trace[|trace|-1] == state
  {
    Start(data,mem);
    state := Running(865,[2989505972],mem);
    trace := [state];
    Advance0(code,state,data,mem,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next0;
    Advance1(code,state,data,mem,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next1;
    Advance2(code,state,data,mem,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next2;
    Advance3(code,state,data,mem,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next3;
    Advance4(code,state,data,mem,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next4;
    Advance5(code,state,data,mem,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next5;
    Advance6(code,state,data,mem,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next6;
    Advance7(code,state,data,mem,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next7;
    Advance8(code,state,data,mem,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next8;
    Advance9(code,state,data,mem,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next9;
    Advance10(code,state,data,mem,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next10;
    Advance11(code,state,data,mem,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next11;
    Advance12(code,state,data,mem,value);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next12;
    Advance13(code,state,data,mem,value);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next13;
    Advance14(code,state,data,mem,value);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next14;
    Advance15(code,state,data,mem,value);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next15;
    Advance16(code,state,data,mem,value);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next16;
    Advance17(code,state,data,mem,value);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next17;
    Advance18(code,state,data,mem,value);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next18;
    Advance19(code,state,data,mem,value);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next19;
    Advance20(code,state,data,mem,value);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next20;
    Advance21(code,state,data,mem,value);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    assert trace[0] == Running(865,[2989505972],mem);
    state := next21;
  }
}
