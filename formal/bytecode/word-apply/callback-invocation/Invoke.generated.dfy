// SPDX-License-Identifier: MIT
// Generated actual callback invocation through the first GAS instruction entry; arbitrary word/pointers and lower stack/memory preserved.
include "../../scans/Execution.dfy"
module BytecodeApplyCallbackInvoke {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted(data: seq<Byte>,sourceOffset: Word,sourceLength: Word,n: Word,index: Word) { true }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[12235] == 91 &&
                                              code[12472] == 91 &&
                                              code[12473] == 95 &&
                                              code[12474] == 97 &&
                                              code[12475] == 48 &&
                                              code[12476] == 196 &&
                                              code[12477] == 141 &&
                                              code[12478] == 133 &&
                                              code[12479] == 133 &&
                                              code[12480] == 97 &&
                                              code[12481] == 66 &&
                                              code[12482] == 9 &&
                                              code[12483] == 86 &&
                                              code[16905] == 91 &&
                                              code[16906] == 95 &&
                                              code[16907] == 95
  }
  function Destinations(): set<nat> { {12235,16905} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word) { Admitted(data,sourceOffset,sourceLength,n,index) && (
                                                                                                                                                                                                                                                                                                                                             if id == 0 then state == Running(12472,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 1 then state == Running(12473,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 2 then state == Running(12474,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 3 then state == Running(12477,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 4 then state == Running(12478,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484,target],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 5 then state == Running(12479,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484,target,callPtr],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 6 then state == Running(12480,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484,target,callPtr,index],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 7 then state == Running(12483,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484,target,callPtr,index,16905],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 8 then state == Running(16905,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484,target,callPtr,index],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 9 then state == Running(16906,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484,target,callPtr,index],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 10 then state == Running(16907,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484,target,callPtr,index,0],mem)
                                                                                                                                                                                                                                                                                                                                             else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(0,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1002
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12472,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word],mem);
    assert Fetch(code,12472) == Op(91,12473,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(1,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1002
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12473,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word],mem);
    assert Fetch(code,12473) == Op(95,12474,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(2,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1002
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12474,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0],mem);
    F.Push2(code,12474);
    assert Fetch(code,12474) == Op(97,12477,12484);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(3,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1002
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12477,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484],mem);
    assert Fetch(code,12477) == Op(141,12478,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(4,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1002
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12478,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484,target],mem);
    assert Fetch(code,12478) == Op(133,12479,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(5,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1002
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12479,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484,target,callPtr],mem);
    assert Fetch(code,12479) == Op(133,12480,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(6,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1002
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12480,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484,target,callPtr,index],mem);
    F.Push2(code,12480);
    assert Fetch(code,12480) == Op(97,12483,16905);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(7,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1002
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12483,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484,target,callPtr,index,16905],mem);
    assert Fetch(code,12483) == Op(86,12484,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(8,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1002
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16905,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484,target,callPtr,index],mem);
    assert Fetch(code,16905) == Op(91,16906,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(9,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1002
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16906,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484,target,callPtr,index],mem);
    assert Fetch(code,16906) == Op(95,16907,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(10,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1002
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(16908,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484,target,callPtr,index,0,0],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16907,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484,target,callPtr,index,0],mem);
    assert Fetch(code,16907) == Op(95,16908,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word)
    requires Admitted(data,sourceOffset,sourceLength,n,index)
    ensures Good(0,Running(12472,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word],mem),data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  { reveal Good(); }
  ghost method Block0(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(0,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1002
    ensures state == Running(16908,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484,target,callPtr,index,0,0],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 12 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance0(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0]; state := next0;
    Advance1(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1]; state := next1;
    Advance2(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2]; state := next2;
    Advance3(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3]; state := next3;
    Advance4(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4]; state := next4;
    Advance5(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5]; state := next5;
    Advance6(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6]; state := next6;
    Advance7(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7]; state := next7;
    Advance8(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8]; state := next8;
    Advance9(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9]; state := next9;
    Advance10(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10]; state := next10;
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && |prefix| <= 1002
    ensures state == Running(16908,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0,12484,target,callPtr,index,0,0],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 12 && trace[0] == Running(12472,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word],mem) && trace[|trace|-1] == state
  {
    Start(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word);
    state := Running(12472,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word],mem); trace := [state];
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
