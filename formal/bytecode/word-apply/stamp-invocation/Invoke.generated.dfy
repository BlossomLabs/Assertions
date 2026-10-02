// SPDX-License-Identifier: MIT
// Generated complete actual stamp helper invocation; arbitrary word/pointers and lower stack/memory preserved.
include "../../scans/Execution.dfy"
module BytecodeApplyStampInvoke {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted(data: seq<Byte>,sourceOffset: Word,sourceLength: Word,n: Word,index: Word) { true }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[12235] == 91 &&
                                              code[12458] == 91 &&
                                              code[12459] == 144 &&
                                              code[12460] == 80 &&
                                              code[12461] == 97 &&
                                              code[12462] == 48 &&
                                              code[12463] == 184 &&
                                              code[12464] == 131 &&
                                              code[12465] == 138 &&
                                              code[12466] == 138 &&
                                              code[12467] == 132 &&
                                              code[12468] == 97 &&
                                              code[12469] == 65 &&
                                              code[12470] == 208 &&
                                              code[12471] == 86 &&
                                              code[16848] == 91 &&
                                              code[16849] == 95
  }
  function Destinations(): set<nat> { {12235,16848} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word) { Admitted(data,sourceOffset,sourceLength,n,index) && (
                                                                                                                                                                                                                                                                                                                                             if id == 0 then state == Running(12458,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,0,word],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 1 then state == Running(12459,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,0,word],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 2 then state == Running(12460,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 3 then state == Running(12461,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 4 then state == Running(12464,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 5 then state == Running(12465,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472,callPtr],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 6 then state == Running(12466,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472,callPtr,arrayOffset],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 7 then state == Running(12467,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472,callPtr,arrayOffset,count],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 8 then state == Running(12468,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472,callPtr,arrayOffset,count,word],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 9 then state == Running(12471,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472,callPtr,arrayOffset,count,word,16848],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 10 then state == Running(16848,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472,callPtr,arrayOffset,count,word],mem)
                                                                                                                                                                                                                                                                                                                                             else if id == 11 then state == Running(16849,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472,callPtr,arrayOffset,count,word],mem)
                                                                                                                                                                                                                                                                                                                                             else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(0,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1003
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12458,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,0,word],mem);
    assert Fetch(code,12458) == Op(91,12459,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(1,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1003
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12459,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,0,word],mem);
    assert Fetch(code,12459) == Op(144,12460,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(2,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1003
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12460,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,0],mem);
    assert Fetch(code,12460) == Op(80,12461,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(3,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1003
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12461,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word],mem);
    F.Push2(code,12461);
    assert Fetch(code,12461) == Op(97,12464,12472);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(4,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1003
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12464,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472],mem);
    assert Fetch(code,12464) == Op(131,12465,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(5,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1003
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12465,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472,callPtr],mem);
    assert Fetch(code,12465) == Op(138,12466,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(6,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1003
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12466,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472,callPtr,arrayOffset],mem);
    assert Fetch(code,12466) == Op(138,12467,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(7,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1003
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12467,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472,callPtr,arrayOffset,count],mem);
    assert Fetch(code,12467) == Op(132,12468,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(8,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1003
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12468,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472,callPtr,arrayOffset,count,word],mem);
    F.Push2(code,12468);
    assert Fetch(code,12468) == Op(97,12471,16848);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(9,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1003
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12471,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472,callPtr,arrayOffset,count,word,16848],mem);
    assert Fetch(code,12471) == Op(86,12472,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(10,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1003
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16848,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472,callPtr,arrayOffset,count,word],mem);
    assert Fetch(code,16848) == Op(91,16849,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(11,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1003
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(16850,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472,callPtr,arrayOffset,count,word,0],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16849,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472,callPtr,arrayOffset,count,word],mem);
    assert Fetch(code,16849) == Op(95,16850,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word)
    requires Admitted(data,sourceOffset,sourceLength,n,index)
    ensures Good(0,Running(12458,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,0,word],mem),data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word)
  { reveal Good(); }
  ghost method Block0(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && Good(0,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word) && |prefix| <= 1003
    ensures state == Running(16850,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472,callPtr,arrayOffset,count,word,0],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 13 && trace[0] == initial && trace[|trace|-1] == state
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
    Advance11(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11]; state := next11;
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, out: Word, n: Word, kept: Word, callPtr: Word, index: Word, word: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data,sourceOffset,sourceLength,n,index) && |prefix| <= 1003
    ensures state == Running(16850,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,12472,callPtr,arrayOffset,count,word,0],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 13 && trace[0] == Running(12458,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,0,word],mem) && trace[|trace|-1] == state
  {
    Start(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word);
    state := Running(12458,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,0,word],mem); trace := [state];
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,out,n,kept,callPtr,index,word,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
