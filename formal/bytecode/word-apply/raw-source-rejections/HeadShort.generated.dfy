// SPDX-License-Identifier: MIT
// Generated ordered raw four-head decoder source rejection; arbitrary prefix preserved until REVERT.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeApplyRawHeadShort {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import DS = BytecodeScanDecoderScalar
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  function Head(data: seq<Byte>): Word { DataWord(data,4) }
  function Header(data: seq<Byte>): Word { ((Head(data) as nat)+4)%G.Modulus() }
  function Length(data: seq<Byte>): Word { DataWord(data,Header(data)) }
  function Offset(data: seq<Byte>): Word { ((Head(data) as nat)+36)%G.Modulus() }
  predicate Admitted(data: seq<Byte>) { 4 <= |data| < 0x10000000000000000 && |data| < 132 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[22579] == 91 &&
                                              code[22580] == 95 &&
                                              code[22581] == 95 &&
                                              code[22582] == 95 &&
                                              code[22583] == 95 &&
                                              code[22584] == 95 &&
                                              code[22585] == 95 &&
                                              code[22586] == 95 &&
                                              code[22587] == 96 &&
                                              code[22588] == 128 &&
                                              code[22589] == 136 &&
                                              code[22590] == 138 &&
                                              code[22591] == 3 &&
                                              code[22592] == 18 &&
                                              code[22593] == 21 &&
                                              code[22594] == 97 &&
                                              code[22595] == 88 &&
                                              code[22596] == 73 &&
                                              code[22597] == 87 &&
                                              code[22598] == 95 &&
                                              code[22599] == 95 &&
                                              code[22600] == 253 &&
                                              code[22601] == 91
  }
  function Destinations(): set<nat> { {22601} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word) { Admitted(data) && (
                                                                                                                       if id == 0 then state == Running(22579,prefix+[returnPc,|data|,4],mem)
                                                                                                                       else if id == 1 then state == Running(22580,prefix+[returnPc,|data|,4],mem)
                                                                                                                       else if id == 2 then state == Running(22581,prefix+[returnPc,|data|,4,0],mem)
                                                                                                                       else if id == 3 then state == Running(22582,prefix+[returnPc,|data|,4,0,0],mem)
                                                                                                                       else if id == 4 then state == Running(22583,prefix+[returnPc,|data|,4,0,0,0],mem)
                                                                                                                       else if id == 5 then state == Running(22584,prefix+[returnPc,|data|,4,0,0,0,0],mem)
                                                                                                                       else if id == 6 then state == Running(22585,prefix+[returnPc,|data|,4,0,0,0,0,0],mem)
                                                                                                                       else if id == 7 then state == Running(22586,prefix+[returnPc,|data|,4,0,0,0,0,0,0],mem)
                                                                                                                       else if id == 8 then state == Running(22587,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem)
                                                                                                                       else if id == 9 then state == Running(22589,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128],mem)
                                                                                                                       else if id == 10 then state == Running(22590,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,4],mem)
                                                                                                                       else if id == 11 then state == Running(22591,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,4,|data|],mem)
                                                                                                                       else if id == 12 then state == Running(22592,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,((|data| as nat)+G.Modulus()-(4 as nat))%G.Modulus()],mem)
                                                                                                                       else if id == 13 then state == Running(22593,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,1],mem)
                                                                                                                       else if id == 14 then state == Running(22594,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,0],mem)
                                                                                                                       else if id == 15 then state == Running(22597,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,0,22601],mem)
                                                                                                                       else if id == 16 then state == Running(22598,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem)
                                                                                                                       else if id == 17 then state == Running(22599,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,0],mem)
                                                                                                                       else if id == 18 then state == Running(22600,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,0,0],mem)
                                                                                                                       else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(0,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22579,prefix+[returnPc,|data|,4],mem);
    assert Fetch(code,22579) == Op(91,22580,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(1,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22580,prefix+[returnPc,|data|,4],mem);
    assert Fetch(code,22580) == Op(95,22581,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(2,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22581,prefix+[returnPc,|data|,4,0],mem);
    assert Fetch(code,22581) == Op(95,22582,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(3,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22582,prefix+[returnPc,|data|,4,0,0],mem);
    assert Fetch(code,22582) == Op(95,22583,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(4,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22583,prefix+[returnPc,|data|,4,0,0,0],mem);
    assert Fetch(code,22583) == Op(95,22584,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(5,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22584,prefix+[returnPc,|data|,4,0,0,0,0],mem);
    assert Fetch(code,22584) == Op(95,22585,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(6,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22585,prefix+[returnPc,|data|,4,0,0,0,0,0],mem);
    assert Fetch(code,22585) == Op(95,22586,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(7,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22586,prefix+[returnPc,|data|,4,0,0,0,0,0,0],mem);
    assert Fetch(code,22586) == Op(95,22587,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(8,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22587,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem);
    F.Push1(code,22587);
    assert Fetch(code,22587) == Op(96,22589,128);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(9,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22589,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128],mem);
    assert Fetch(code,22589) == Op(136,22590,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(10,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22590,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,4],mem);
    assert Fetch(code,22590) == Op(138,22591,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(11,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22591,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,4,|data|],mem);
    assert Fetch(code,22591) == Op(3,22592,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(12,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22592,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,((|data| as nat)+G.Modulus()-(4 as nat))%G.Modulus()],mem);
    assert Fetch(code,22592) == Op(18,22593,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(13,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22593,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,1],mem);
    assert Fetch(code,22593) == Op(21,22594,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(14,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22594,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,0],mem);
    F.Push2(code,22594);
    assert Fetch(code,22594) == Op(97,22597,22601);
  }
  lemma Advance15(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(15,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22597,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,0,22601],mem);
    assert Fetch(code,22597) == Op(87,22598,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(16,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22598,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem);
    assert Fetch(code,22598) == Op(95,22599,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(17,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22599,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,0],mem);
    assert Fetch(code,22599) == Op(95,22600,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(18,state,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted([])
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22600,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,0,0],mem);
    assert Fetch(code,22600) == Op(253,22601,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word)
    requires Admitted(data)
    ensures Good(0,Running(22579,prefix+[returnPc,|data|,4],mem),data,mem,prefix,returnPc)
  { reveal Good(); }
  ghost method Block0(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && Good(0,initial,data,mem,prefix,returnPc) && |prefix| <= 1011
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 20 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance0(code,state,data,mem,prefix,returnPc,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0]; state := next0;
    Advance1(code,state,data,mem,prefix,returnPc,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1]; state := next1;
    Advance2(code,state,data,mem,prefix,returnPc,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2]; state := next2;
    Advance3(code,state,data,mem,prefix,returnPc,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3]; state := next3;
    Advance4(code,state,data,mem,prefix,returnPc,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4]; state := next4;
    Advance5(code,state,data,mem,prefix,returnPc,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5]; state := next5;
    Advance6(code,state,data,mem,prefix,returnPc,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6]; state := next6;
    Advance7(code,state,data,mem,prefix,returnPc,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7]; state := next7;
    Advance8(code,state,data,mem,prefix,returnPc,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8]; state := next8;
    Advance9(code,state,data,mem,prefix,returnPc,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9]; state := next9;
    Advance10(code,state,data,mem,prefix,returnPc,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10]; state := next10;
    Advance11(code,state,data,mem,prefix,returnPc,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11]; state := next11;
    Advance12(code,state,data,mem,prefix,returnPc,value);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12]; state := next12;
    Advance13(code,state,data,mem,prefix,returnPc,value);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13]; state := next13;
    Advance14(code,state,data,mem,prefix,returnPc,value);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14]; state := next14;
    Advance15(code,state,data,mem,prefix,returnPc,value);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15]; state := next15;
    Advance16(code,state,data,mem,prefix,returnPc,value);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16]; state := next16;
    Advance17(code,state,data,mem,prefix,returnPc,value);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17]; state := next17;
    Advance18(code,state,data,mem,prefix,returnPc,value);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18]; state := next18;
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && |prefix| <= 1011
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 20 && trace[0] == Running(22579,prefix+[returnPc,|data|,4],mem) && trace[|trace|-1] == state
  {
    Start(data,mem,prefix,returnPc);
    state := Running(22579,prefix+[returnPc,|data|,4],mem); trace := [state];
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
