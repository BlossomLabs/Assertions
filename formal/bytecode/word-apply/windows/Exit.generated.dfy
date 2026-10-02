// SPDX-License-Identifier: MIT
// Generated valid element-window control fragment; all reached instructions and helper calls retained.
include "Inputs.dfy"
module BytecodeApplyWindowsExit {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import W = BytecodeApplyWindowInputs
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted(data: seq<Byte>,templateLength: Word,arrayOffset: Word,count: Word,index: Word) { W.Represented(templateLength,arrayOffset,count,data) && templateLength >= 32 && index == count }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[12235] == 91 &&
                                              code[16419] == 91 &&
                                              code[16420] == 80 &&
                                              code[16421] == 80 &&
                                              code[16422] == 80 &&
                                              code[16423] == 80 &&
                                              code[16424] == 80 &&
                                              code[16425] == 86 &&
                                              code[16728] == 91 &&
                                              code[16729] == 129 &&
                                              code[16730] == 129 &&
                                              code[16731] == 16 &&
                                              code[16732] == 21 &&
                                              code[16733] == 97 &&
                                              code[16734] == 64 &&
                                              code[16735] == 35 &&
                                              code[16736] == 87
  }
  function Destinations(): set<nat> { {12235,16419} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word) { Admitted(data,templateLength,arrayOffset,count,index) && (
                                                                                                                                                                                                                if id == 0 then state == Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem)
                                                                                                                                                                                                                else if id == 1 then state == Running(16729,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem)
                                                                                                                                                                                                                else if id == 2 then state == Running(16730,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,count],mem)
                                                                                                                                                                                                                else if id == 3 then state == Running(16731,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,count,index],mem)
                                                                                                                                                                                                                else if id == 4 then state == Running(16732,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,0],mem)
                                                                                                                                                                                                                else if id == 5 then state == Running(16733,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,1],mem)
                                                                                                                                                                                                                else if id == 6 then state == Running(16736,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,1,16419],mem)
                                                                                                                                                                                                                else if id == 7 then state == Running(16419,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem)
                                                                                                                                                                                                                else if id == 8 then state == Running(16420,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem)
                                                                                                                                                                                                                else if id == 9 then state == Running(16421,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],mem)
                                                                                                                                                                                                                else if id == 10 then state == Running(16422,prefix+[returnPc,templateOffset,templateLength,arrayOffset],mem)
                                                                                                                                                                                                                else if id == 11 then state == Running(16423,prefix+[returnPc,templateOffset,templateLength],mem)
                                                                                                                                                                                                                else if id == 12 then state == Running(16424,prefix+[returnPc,templateOffset],mem)
                                                                                                                                                                                                                else if id == 13 then state == Running(16425,prefix+[returnPc],mem)
                                                                                                                                                                                                                else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(0,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1016
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem);
    assert Fetch(code,16728) == Op(91,16729,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(1,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1016
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16729,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem);
    assert Fetch(code,16729) == Op(129,16730,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(2,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1016
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16730,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,count],mem);
    assert Fetch(code,16730) == Op(129,16731,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(3,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1016
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16731,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,count,index],mem);
    assert Fetch(code,16731) == Op(16,16732,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(4,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1016
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16732,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,0],mem);
    assert Fetch(code,16732) == Op(21,16733,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(5,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1016
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16733,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,1],mem);
    F.Push2(code,16733);
    assert Fetch(code,16733) == Op(97,16736,16419);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(6,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1016
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16736,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,1,16419],mem);
    assert Fetch(code,16736) == Op(87,16737,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(7,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1016
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16419,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem);
    assert Fetch(code,16419) == Op(91,16420,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(8,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1016
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16420,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem);
    assert Fetch(code,16420) == Op(80,16421,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(9,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1016
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16421,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],mem);
    assert Fetch(code,16421) == Op(80,16422,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(10,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1016
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16422,prefix+[returnPc,templateOffset,templateLength,arrayOffset],mem);
    assert Fetch(code,16422) == Op(80,16423,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(11,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1016
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16423,prefix+[returnPc,templateOffset,templateLength],mem);
    assert Fetch(code,16423) == Op(80,16424,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(12,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1016
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16424,prefix+[returnPc,templateOffset],mem);
    assert Fetch(code,16424) == Op(80,16425,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(13,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1016
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(12235,prefix+[],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16425,prefix+[returnPc],mem);
    assert Fetch(code,16425) == Op(86,16426,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word)
    requires returnPc == 12235 && Admitted(data,templateLength,arrayOffset,count,index)
    ensures Good(0,Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem),data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  { reveal Good(); }
  ghost method Block0(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word) returns (state: State, trace: seq<State>)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(0,initial,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1016
    ensures state == Running(12235,prefix+[],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 15 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance0(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0]; state := next0;
    Advance1(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1]; state := next1;
    Advance2(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2]; state := next2;
    Advance3(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3]; state := next3;
    Advance4(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4]; state := next4;
    Advance5(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5]; state := next5;
    Advance6(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6]; state := next6;
    Advance7(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7]; state := next7;
    Advance8(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8]; state := next8;
    Advance9(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9]; state := next9;
    Advance10(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10]; state := next10;
    Advance11(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11]; state := next11;
    Advance12(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12]; state := next12;
    Advance13(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13]; state := next13;
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word) returns (state: State, trace: seq<State>)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && |prefix| <= 1016
    ensures state == Running(12235,prefix+[],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 15 && trace[0] == Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem) && trace[|trace|-1] == state
  {
    Start(data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index);
    state := Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem); trace := [state];
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
