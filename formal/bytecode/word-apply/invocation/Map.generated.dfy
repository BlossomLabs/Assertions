// SPDX-License-Identifier: MIT
// Generated actual wrapper call into the shared map/filter body; arbitrary lower prefix and memory preserved.
include "../../scans/Execution.dfy"
module BytecodeApplyInvokeMap {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted(data: seq<Byte>) { true }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[1050] == 91 &&
                                              code[1051] == 97 &&
                                              code[1052] == 34 &&
                                              code[1053] == 25 &&
                                              code[1054] == 86 &&
                                              code[8729] == 91 &&
                                              code[8730] == 96 &&
                                              code[8731] == 96 &&
                                              code[8732] == 97 &&
                                              code[8733] == 21 &&
                                              code[8734] == 150 &&
                                              code[8735] == 136 &&
                                              code[8736] == 136 &&
                                              code[8737] == 136 &&
                                              code[8738] == 136 &&
                                              code[8739] == 136 &&
                                              code[8740] == 136 &&
                                              code[8741] == 136 &&
                                              code[8742] == 95 &&
                                              code[8743] == 97 &&
                                              code[8744] == 47 &&
                                              code[8745] == 145 &&
                                              code[8746] == 86 &&
                                              code[12177] == 91
  }
  function Destinations(): set<nat> { {8729,12177} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word) { Admitted(data) && (
                                                                                                                                                                                                                                         if id == 0 then state == Running(1050,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem)
                                                                                                                                                                                                                                         else if id == 1 then state == Running(1051,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem)
                                                                                                                                                                                                                                         else if id == 2 then state == Running(1054,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,8729],mem)
                                                                                                                                                                                                                                         else if id == 3 then state == Running(8729,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem)
                                                                                                                                                                                                                                         else if id == 4 then state == Running(8730,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem)
                                                                                                                                                                                                                                         else if id == 5 then state == Running(8732,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96],mem)
                                                                                                                                                                                                                                         else if id == 6 then state == Running(8735,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526],mem)
                                                                                                                                                                                                                                         else if id == 7 then state == Running(8736,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset],mem)
                                                                                                                                                                                                                                         else if id == 8 then state == Running(8737,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength],mem)
                                                                                                                                                                                                                                         else if id == 9 then state == Running(8738,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target],mem)
                                                                                                                                                                                                                                         else if id == 10 then state == Running(8739,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset],mem)
                                                                                                                                                                                                                                         else if id == 11 then state == Running(8740,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength],mem)
                                                                                                                                                                                                                                         else if id == 12 then state == Running(8741,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset],mem)
                                                                                                                                                                                                                                         else if id == 13 then state == Running(8742,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem)
                                                                                                                                                                                                                                         else if id == 14 then state == Running(8743,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0],mem)
                                                                                                                                                                                                                                         else if id == 15 then state == Running(8746,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,12177],mem)
                                                                                                                                                                                                                                         else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(0,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1050,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem);
    assert Fetch(code,1050) == Op(91,1051,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(1,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1051,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem);
    F.Push2(code,1051);
    assert Fetch(code,1051) == Op(97,1054,8729);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(2,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1054,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,8729],mem);
    assert Fetch(code,1054) == Op(86,1055,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(3,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8729,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem);
    assert Fetch(code,8729) == Op(91,8730,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(4,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8730,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem);
    F.Push1(code,8730);
    assert Fetch(code,8730) == Op(96,8732,96);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(5,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8732,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96],mem);
    F.Push2(code,8732);
    assert Fetch(code,8732) == Op(97,8735,5526);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(6,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8735,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526],mem);
    assert Fetch(code,8735) == Op(136,8736,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(7,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8736,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset],mem);
    assert Fetch(code,8736) == Op(136,8737,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(8,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8737,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength],mem);
    assert Fetch(code,8737) == Op(136,8738,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(9,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8738,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target],mem);
    assert Fetch(code,8738) == Op(136,8739,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(10,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8739,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset],mem);
    assert Fetch(code,8739) == Op(136,8740,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(11,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8740,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength],mem);
    assert Fetch(code,8740) == Op(136,8741,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(12,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8741,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset],mem);
    assert Fetch(code,8741) == Op(136,8742,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(13,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8742,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem);
    assert Fetch(code,8742) == Op(95,8743,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(14,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8743,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0],mem);
    F.Push2(code,8743);
    assert Fetch(code,8743) == Op(97,8746,12177);
  }
  lemma Advance15(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(15,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(12177,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8746,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,12177],mem);
    assert Fetch(code,8746) == Op(86,8747,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word)
    requires Admitted(data)
    ensures Good(0,Running(1050,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem),data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  { reveal Good(); }
  ghost method Block0(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && Good(0,initial,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state == Running(12177,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 17 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance0(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0]; state := next0;
    Advance1(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1]; state := next1;
    Advance2(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2]; state := next2;
    Advance3(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3]; state := next3;
    Advance4(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4]; state := next4;
    Advance5(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5]; state := next5;
    Advance6(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6]; state := next6;
    Advance7(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7]; state := next7;
    Advance8(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8]; state := next8;
    Advance9(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9]; state := next9;
    Advance10(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10]; state := next10;
    Advance11(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11]; state := next11;
    Advance12(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12]; state := next12;
    Advance13(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13]; state := next13;
    Advance14(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14]; state := next14;
    Advance15(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15]; state := next15;
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && |prefix| <= 1006
    ensures state == Running(12177,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 17 && trace[0] == Running(1050,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem) && trace[|trace|-1] == state
  {
    Start(data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count);
    state := Running(1050,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem); trace := [state];
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
