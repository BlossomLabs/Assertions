// SPDX-License-Identifier: MIT
// Generated valid element-window control fragment; all reached instructions and helper calls retained.
include "Inputs.dfy"
module BytecodeApplyWindowsEntry {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import W = BytecodeApplyWindowInputs
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted(data: seq<Byte>,templateLength: Word,arrayOffset: Word,count: Word,index: Word) { W.Represented(templateLength,arrayOffset,count,data) && templateLength >= 32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[12235] == 91 &&
                                              code[16683] == 91 &&
                                              code[16684] == 96 &&
                                              code[16685] == 32 &&
                                              code[16686] == 131 &&
                                              code[16687] == 16 &&
                                              code[16688] == 21 &&
                                              code[16689] == 97 &&
                                              code[16690] == 65 &&
                                              code[16691] == 86 &&
                                              code[16692] == 87 &&
                                              code[16726] == 91 &&
                                              code[16727] == 95
  }
  function Destinations(): set<nat> { {12235,16726} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word) { Admitted(data,templateLength,arrayOffset,count,index) && (
                                                                                                                                                                                                                if id == 0 then state == Running(16683,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],mem)
                                                                                                                                                                                                                else if id == 1 then state == Running(16684,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],mem)
                                                                                                                                                                                                                else if id == 2 then state == Running(16686,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,32],mem)
                                                                                                                                                                                                                else if id == 3 then state == Running(16687,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,32,templateLength],mem)
                                                                                                                                                                                                                else if id == 4 then state == Running(16688,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,0],mem)
                                                                                                                                                                                                                else if id == 5 then state == Running(16689,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,1],mem)
                                                                                                                                                                                                                else if id == 6 then state == Running(16692,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,1,16726],mem)
                                                                                                                                                                                                                else if id == 7 then state == Running(16726,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],mem)
                                                                                                                                                                                                                else if id == 8 then state == Running(16727,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],mem)
                                                                                                                                                                                                                else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(0,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1017
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16683,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],mem);
    assert Fetch(code,16683) == Op(91,16684,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(1,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1017
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16684,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],mem);
    F.Push1(code,16684);
    assert Fetch(code,16684) == Op(96,16686,32);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(2,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1017
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16686,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,32],mem);
    assert Fetch(code,16686) == Op(131,16687,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(3,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1017
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16687,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,32,templateLength],mem);
    assert Fetch(code,16687) == Op(16,16688,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(4,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1017
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16688,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,0],mem);
    assert Fetch(code,16688) == Op(21,16689,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(5,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1017
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16689,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,1],mem);
    F.Push2(code,16689);
    assert Fetch(code,16689) == Op(97,16692,16726);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(6,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1017
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16692,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,1,16726],mem);
    assert Fetch(code,16692) == Op(87,16693,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(7,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1017
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16726,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],mem);
    assert Fetch(code,16726) == Op(91,16727,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(8,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1017
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,0],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16727,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],mem);
    assert Fetch(code,16727) == Op(95,16728,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word)
    requires returnPc == 12235 && Admitted(data,templateLength,arrayOffset,count,index)
    ensures Good(0,Running(16683,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],mem),data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  { reveal Good(); }
  ghost method Block0(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word) returns (state: State, trace: seq<State>)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(0,initial,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1017
    ensures state == Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,0],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 10 && trace[0] == initial && trace[|trace|-1] == state
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
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word) returns (state: State, trace: seq<State>)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && |prefix| <= 1017
    ensures state == Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,0],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 10 && trace[0] == Running(16683,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],mem) && trace[|trace|-1] == state
  {
    Start(data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index);
    state := Running(16683,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count],mem); trace := [state];
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
