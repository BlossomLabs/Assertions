// SPDX-License-Identifier: MIT
// Generated actual stamping loop leaf; arbitrary finite indices and words.
include "../windows/Inputs.dfy"
include "../../scans/Push.dfy"
module BytecodeApplyStampExit {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import W = BytecodeApplyWindowInputs
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word) { index == count && returnPc == 12472 && |prefix| <= 1016 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 && code[12472] == 91 &&
                                              code[16419] == 91 &&
                                              code[16420] == 80 &&
                                              code[16421] == 80 &&
                                              code[16422] == 80 &&
                                              code[16423] == 80 &&
                                              code[16424] == 80 &&
                                              code[16425] == 86 &&
                                              code[16850] == 91 &&
                                              code[16851] == 130 &&
                                              code[16852] == 129 &&
                                              code[16853] == 16 &&
                                              code[16854] == 21 &&
                                              code[16855] == 97 &&
                                              code[16856] == 64 &&
                                              code[16857] == 35 &&
                                              code[16858] == 87 }
  function Destinations(): set<nat> { {12472,16419} }
  opaque predicate Good(id: nat,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word) { Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && (
                                                                                                                                                                                                                                if id == 0 then state == Running(16850,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem)
                                                                                                                                                                                                                                else if id == 1 then state == Running(16851,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem)
                                                                                                                                                                                                                                else if id == 2 then state == Running(16852,prefix+[returnPc,callPtr,arrayOffset,count,word,index,count],mem)
                                                                                                                                                                                                                                else if id == 3 then state == Running(16853,prefix+[returnPc,callPtr,arrayOffset,count,word,index,count,index],mem)
                                                                                                                                                                                                                                else if id == 4 then state == Running(16854,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0],mem)
                                                                                                                                                                                                                                else if id == 5 then state == Running(16855,prefix+[returnPc,callPtr,arrayOffset,count,word,index,1],mem)
                                                                                                                                                                                                                                else if id == 6 then state == Running(16858,prefix+[returnPc,callPtr,arrayOffset,count,word,index,1,16419],mem)
                                                                                                                                                                                                                                else if id == 7 then state == Running(16419,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem)
                                                                                                                                                                                                                                else if id == 8 then state == Running(16420,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem)
                                                                                                                                                                                                                                else if id == 9 then state == Running(16421,prefix+[returnPc,callPtr,arrayOffset,count,word],mem)
                                                                                                                                                                                                                                else if id == 10 then state == Running(16422,prefix+[returnPc,callPtr,arrayOffset,count],mem)
                                                                                                                                                                                                                                else if id == 11 then state == Running(16423,prefix+[returnPc,callPtr,arrayOffset],mem)
                                                                                                                                                                                                                                else if id == 12 then state == Running(16424,prefix+[returnPc,callPtr],mem)
                                                                                                                                                                                                                                else if id == 13 then state == Running(16425,prefix+[returnPc],mem)
                                                                                                                                                                                                                                else false) }
  lemma Advance0(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(0,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16850,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem);
    assert Fetch(code,16850) == Op(91,16851,0);
  }
  lemma Advance1(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(1,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16851,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem);
    assert Fetch(code,16851) == Op(130,16852,0);
  }
  lemma Advance2(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(2,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16852,prefix+[returnPc,callPtr,arrayOffset,count,word,index,count],mem);
    assert Fetch(code,16852) == Op(129,16853,0);
  }
  lemma Advance3(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(3,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16853,prefix+[returnPc,callPtr,arrayOffset,count,word,index,count,index],mem);
    assert Fetch(code,16853) == Op(16,16854,0);
  }
  lemma Advance4(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(4,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16854,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0],mem);
    assert Fetch(code,16854) == Op(21,16855,0);
  }
  lemma Advance5(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(5,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16855,prefix+[returnPc,callPtr,arrayOffset,count,word,index,1],mem);
    F.Push2(code,16855);
    assert Fetch(code,16855) == Op(97,16858,16419);
  }
  lemma Advance6(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(6,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16858,prefix+[returnPc,callPtr,arrayOffset,count,word,index,1,16419],mem);
    assert Fetch(code,16858) == Op(87,16859,0);
  }
  lemma Advance7(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(7,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16419,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem);
    assert Fetch(code,16419) == Op(91,16420,0);
  }
  lemma Advance8(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(8,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16420,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem);
    assert Fetch(code,16420) == Op(80,16421,0);
  }
  lemma Advance9(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(9,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16421,prefix+[returnPc,callPtr,arrayOffset,count,word],mem);
    assert Fetch(code,16421) == Op(80,16422,0);
  }
  lemma Advance10(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(10,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16422,prefix+[returnPc,callPtr,arrayOffset,count],mem);
    assert Fetch(code,16422) == Op(80,16423,0);
  }
  lemma Advance11(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(11,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16423,prefix+[returnPc,callPtr,arrayOffset],mem);
    assert Fetch(code,16423) == Op(80,16424,0);
  }
  lemma Advance12(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(12,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16424,prefix+[returnPc,callPtr],mem);
    assert Fetch(code,16424) == Op(80,16425,0);
  }
  lemma Advance13(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(13,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(12472,prefix,mem)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16425,prefix+[returnPc],mem);
    assert Fetch(code,16425) == Op(86,16426,0);
  }
  ghost method Block0(code: seq<Byte>,initial: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(0,initial,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state == Running(12472,prefix,mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 15 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial; trace := [state];
    Advance0(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0); trace := trace+[next0]; state := next0;
    Advance1(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1); trace := trace+[next1]; state := next1;
    Advance2(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2); trace := trace+[next2]; state := next2;
    Advance3(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3); trace := trace+[next3]; state := next3;
    Advance4(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4); trace := trace+[next4]; state := next4;
    Advance5(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5); trace := trace+[next5]; state := next5;
    Advance6(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6); trace := trace+[next6]; state := next6;
    Advance7(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7); trace := trace+[next7]; state := next7;
    Advance8(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8); trace := trace+[next8]; state := next8;
    Advance9(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9); trace := trace+[next9]; state := next9;
    Advance10(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10); trace := trace+[next10]; state := next10;
    Advance11(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11); trace := trace+[next11]; state := next11;
    Advance12(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12); trace := trace+[next12]; state := next12;
    Advance13(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13); trace := trace+[next13]; state := next13;
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state == Running(12472,prefix,mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 15 && trace[0] == Running(16850,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem) && trace[|trace|-1] == state
  { state := Running(16850,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem); trace := [state]; reveal Good(); var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
