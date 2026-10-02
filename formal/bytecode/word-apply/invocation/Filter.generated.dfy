// SPDX-License-Identifier: MIT
// Generated actual wrapper call into the shared map/filter body; arbitrary lower prefix and memory preserved.
include "../../scans/Execution.dfy"
module BytecodeApplyInvokeFilter {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted(data: seq<Byte>) { true }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[784] == 91 &&
                                              code[785] == 97 &&
                                              code[786] == 21 &&
                                              code[787] == 131 &&
                                              code[788] == 86 &&
                                              code[5507] == 91 &&
                                              code[5508] == 96 &&
                                              code[5509] == 96 &&
                                              code[5510] == 97 &&
                                              code[5511] == 21 &&
                                              code[5512] == 150 &&
                                              code[5513] == 136 &&
                                              code[5514] == 136 &&
                                              code[5515] == 136 &&
                                              code[5516] == 136 &&
                                              code[5517] == 136 &&
                                              code[5518] == 136 &&
                                              code[5519] == 136 &&
                                              code[5520] == 96 &&
                                              code[5521] == 1 &&
                                              code[5522] == 97 &&
                                              code[5523] == 47 &&
                                              code[5524] == 145 &&
                                              code[5525] == 86 &&
                                              code[12177] == 91
  }
  function Destinations(): set<nat> { {5507,12177} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word) { Admitted(data) && (
                                                                                                                                                                                                                                         if id == 0 then state == Running(784,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem)
                                                                                                                                                                                                                                         else if id == 1 then state == Running(785,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem)
                                                                                                                                                                                                                                         else if id == 2 then state == Running(788,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,5507],mem)
                                                                                                                                                                                                                                         else if id == 3 then state == Running(5507,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem)
                                                                                                                                                                                                                                         else if id == 4 then state == Running(5508,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem)
                                                                                                                                                                                                                                         else if id == 5 then state == Running(5510,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96],mem)
                                                                                                                                                                                                                                         else if id == 6 then state == Running(5513,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526],mem)
                                                                                                                                                                                                                                         else if id == 7 then state == Running(5514,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset],mem)
                                                                                                                                                                                                                                         else if id == 8 then state == Running(5515,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength],mem)
                                                                                                                                                                                                                                         else if id == 9 then state == Running(5516,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target],mem)
                                                                                                                                                                                                                                         else if id == 10 then state == Running(5517,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset],mem)
                                                                                                                                                                                                                                         else if id == 11 then state == Running(5518,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength],mem)
                                                                                                                                                                                                                                         else if id == 12 then state == Running(5519,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset],mem)
                                                                                                                                                                                                                                         else if id == 13 then state == Running(5520,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem)
                                                                                                                                                                                                                                         else if id == 14 then state == Running(5522,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1],mem)
                                                                                                                                                                                                                                         else if id == 15 then state == Running(5525,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,12177],mem)
                                                                                                                                                                                                                                         else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(0,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(784,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem);
    assert Fetch(code,784) == Op(91,785,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(1,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(785,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem);
    F.Push2(code,785);
    assert Fetch(code,785) == Op(97,788,5507);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(2,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(788,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,5507],mem);
    assert Fetch(code,788) == Op(86,789,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(3,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5507,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem);
    assert Fetch(code,5507) == Op(91,5508,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(4,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5508,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem);
    F.Push1(code,5508);
    assert Fetch(code,5508) == Op(96,5510,96);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(5,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5510,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96],mem);
    F.Push2(code,5510);
    assert Fetch(code,5510) == Op(97,5513,5526);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(6,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5513,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526],mem);
    assert Fetch(code,5513) == Op(136,5514,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(7,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5514,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset],mem);
    assert Fetch(code,5514) == Op(136,5515,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(8,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5515,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength],mem);
    assert Fetch(code,5515) == Op(136,5516,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(9,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5516,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target],mem);
    assert Fetch(code,5516) == Op(136,5517,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(10,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5517,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset],mem);
    assert Fetch(code,5517) == Op(136,5518,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(11,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5518,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength],mem);
    assert Fetch(code,5518) == Op(136,5519,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(12,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5519,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset],mem);
    assert Fetch(code,5519) == Op(136,5520,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(13,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5520,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem);
    F.Push1(code,5520);
    assert Fetch(code,5520) == Op(96,5522,1);
  }
  lemma Advance14(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(14,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5522,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1],mem);
    F.Push2(code,5522);
    assert Fetch(code,5522) == Op(97,5525,12177);
  }
  lemma Advance15(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(15,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(12177,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5525,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,12177],mem);
    assert Fetch(code,5525) == Op(86,5526,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word)
    requires Admitted(data)
    ensures Good(0,Running(784,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem),data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count)
  { reveal Good(); }
  ghost method Block0(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && Good(0,initial,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count) && |prefix| <= 1006
    ensures state == Running(12177,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1],mem) && E.Trace(code,Destinations(),value,data,trace)
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
    ensures state == Running(12177,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,5526,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 17 && trace[0] == Running(784,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem) && trace[|trace|-1] == state
  {
    Start(data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count);
    state := Running(784,prefix+[sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem); trace := [state];
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
