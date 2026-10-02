// SPDX-License-Identifier: MIT
// Generated ordered raw four-head decoder source rejection; arbitrary prefix preserved until REVERT.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeApplyRawSourceOffsetLarge {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import DS = BytecodeScanDecoderScalar
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  function Head(data: seq<Byte>): Word { DataWord(data,4) }
  function Header(data: seq<Byte>): Word { ((Head(data) as nat)+4)%G.Modulus() }
  function Length(data: seq<Byte>): Word { DataWord(data,Header(data)) }
  function Offset(data: seq<Byte>): Word { ((Head(data) as nat)+36)%G.Modulus() }
  predicate Admitted(data: seq<Byte>) { 4 <= |data| < 0x10000000000000000 && 132 <= |data| && Head(data) >= 0x10000000000000000 }
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
                                              code[22601] == 91 &&
                                              code[22602] == 135 &&
                                              code[22603] == 53 &&
                                              code[22604] == 96 &&
                                              code[22605] == 1 &&
                                              code[22606] == 96 &&
                                              code[22607] == 1 &&
                                              code[22608] == 96 &&
                                              code[22609] == 64 &&
                                              code[22610] == 27 &&
                                              code[22611] == 3 &&
                                              code[22612] == 129 &&
                                              code[22613] == 17 &&
                                              code[22614] == 21 &&
                                              code[22615] == 97 &&
                                              code[22616] == 88 &&
                                              code[22617] == 94 &&
                                              code[22618] == 87 &&
                                              code[22619] == 95 &&
                                              code[22620] == 95 &&
                                              code[22621] == 253 &&
                                              code[22622] == 91
  }
  function Destinations(): set<nat> { {22601,22622} }
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
                                                                                                                       else if id == 13 then state == Running(22593,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,0],mem)
                                                                                                                       else if id == 14 then state == Running(22594,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,1],mem)
                                                                                                                       else if id == 15 then state == Running(22597,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,1,22601],mem)
                                                                                                                       else if id == 16 then state == Running(22601,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem)
                                                                                                                       else if id == 17 then state == Running(22602,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem)
                                                                                                                       else if id == 18 then state == Running(22603,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,4],mem)
                                                                                                                       else if id == 19 then state == Running(22604,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data)],mem)
                                                                                                                       else if id == 20 then state == Running(22606,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1],mem)
                                                                                                                       else if id == 21 then state == Running(22608,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1,1],mem)
                                                                                                                       else if id == 22 then state == Running(22610,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1,1,64],mem)
                                                                                                                       else if id == 23 then state == Running(22611,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1,18446744073709551616],mem)
                                                                                                                       else if id == 24 then state == Running(22612,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),18446744073709551615],mem)
                                                                                                                       else if id == 25 then state == Running(22613,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),18446744073709551615,Head(data)],mem)
                                                                                                                       else if id == 26 then state == Running(22614,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1],mem)
                                                                                                                       else if id == 27 then state == Running(22615,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),0],mem)
                                                                                                                       else if id == 28 then state == Running(22618,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),0,22622],mem)
                                                                                                                       else if id == 29 then state == Running(22619,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data)],mem)
                                                                                                                       else if id == 30 then state == Running(22620,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),0],mem)
                                                                                                                       else if id == 31 then state == Running(22621,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),0,0],mem)
                                                                                                                       else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(0,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22579,prefix+[returnPc,|data|,4],mem);
    assert Fetch(code,22579) == Op(91,22580,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(1,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22580,prefix+[returnPc,|data|,4],mem);
    assert Fetch(code,22580) == Op(95,22581,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(2,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22581,prefix+[returnPc,|data|,4,0],mem);
    assert Fetch(code,22581) == Op(95,22582,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(3,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22582,prefix+[returnPc,|data|,4,0,0],mem);
    assert Fetch(code,22582) == Op(95,22583,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(4,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22583,prefix+[returnPc,|data|,4,0,0,0],mem);
    assert Fetch(code,22583) == Op(95,22584,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(5,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22584,prefix+[returnPc,|data|,4,0,0,0,0],mem);
    assert Fetch(code,22584) == Op(95,22585,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(6,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22585,prefix+[returnPc,|data|,4,0,0,0,0,0],mem);
    assert Fetch(code,22585) == Op(95,22586,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(7,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22586,prefix+[returnPc,|data|,4,0,0,0,0,0,0],mem);
    assert Fetch(code,22586) == Op(95,22587,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(8,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22587,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem);
    F.Push1(code,22587);
    assert Fetch(code,22587) == Op(96,22589,128);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(9,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22589,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128],mem);
    assert Fetch(code,22589) == Op(136,22590,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(10,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22590,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,4],mem);
    assert Fetch(code,22590) == Op(138,22591,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(11,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22591,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,4,|data|],mem);
    assert Fetch(code,22591) == Op(3,22592,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(12,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22592,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,((|data| as nat)+G.Modulus()-(4 as nat))%G.Modulus()],mem);
    assert Fetch(code,22592) == Op(18,22593,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(13,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22593,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,0],mem);
    assert Fetch(code,22593) == Op(21,22594,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(14,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22594,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,1],mem);
    F.Push2(code,22594);
    assert Fetch(code,22594) == Op(97,22597,22601);
  }
  lemma Advance15(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(15,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22597,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,1,22601],mem);
    assert Fetch(code,22597) == Op(87,22598,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(16,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22601,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem);
    assert Fetch(code,22601) == Op(91,22602,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(17,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22602,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem);
    assert Fetch(code,22602) == Op(135,22603,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(18,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22603,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,4],mem);
    assert Fetch(code,22603) == Op(53,22604,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(19,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22604,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data)],mem);
    F.Push1(code,22604);
    assert Fetch(code,22604) == Op(96,22606,1);
  }
  lemma Advance20(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(20,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22606,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1],mem);
    F.Push1(code,22606);
    assert Fetch(code,22606) == Op(96,22608,1);
  }
  lemma Advance21(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(21,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22608,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1,1],mem);
    F.Push1(code,22608);
    assert Fetch(code,22608) == Op(96,22610,64);
  }
  lemma Advance22(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(22,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22610,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1,1,64],mem);
    DS.DecoderLimit();
    assert Fetch(code,22610) == Op(27,22611,0);
  }
  lemma Advance23(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(23,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22611,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1,18446744073709551616],mem);
    assert Fetch(code,22611) == Op(3,22612,0);
  }
  lemma Advance24(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(24,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22612,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),18446744073709551615],mem);
    assert Fetch(code,22612) == Op(129,22613,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(25,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22613,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),18446744073709551615,Head(data)],mem);
    assert Fetch(code,22613) == Op(17,22614,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(26,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22614,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1],mem);
    assert Fetch(code,22614) == Op(21,22615,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(27,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22615,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),0],mem);
    F.Push2(code,22615);
    assert Fetch(code,22615) == Op(97,22618,22622);
  }
  lemma Advance28(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(28,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22618,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),0,22622],mem);
    assert Fetch(code,22618) == Op(87,22619,0);
  }
  lemma Advance29(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(29,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22619,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data)],mem);
    assert Fetch(code,22619) == Op(95,22620,0);
  }
  lemma Advance30(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(30,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22620,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),0],mem);
    assert Fetch(code,22620) == Op(95,22621,0);
  }
  lemma Advance31(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(31,state,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted([])
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22621,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),0,0],mem);
    assert Fetch(code,22621) == Op(253,22622,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word)
    requires Admitted(data)
    ensures Good(0,Running(22579,prefix+[returnPc,|data|,4],mem),data,mem,prefix,returnPc)
  { reveal Good(); }
  ghost method Block0(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && Good(0,initial,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures Good(20,state,data,mem,prefix,returnPc) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
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
    Advance19(code,state,data,mem,prefix,returnPc,value);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19]; state := next19;
  }
  ghost method Block1(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && Good(20,initial,data,mem,prefix,returnPc) && |prefix| <= 1010
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 13 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance20(code,state,data,mem,prefix,returnPc,value);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20]; state := next20;
    Advance21(code,state,data,mem,prefix,returnPc,value);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21]; state := next21;
    Advance22(code,state,data,mem,prefix,returnPc,value);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22]; state := next22;
    Advance23(code,state,data,mem,prefix,returnPc,value);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23]; state := next23;
    Advance24(code,state,data,mem,prefix,returnPc,value);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24]; state := next24;
    Advance25(code,state,data,mem,prefix,returnPc,value);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25]; state := next25;
    Advance26(code,state,data,mem,prefix,returnPc,value);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26]; state := next26;
    Advance27(code,state,data,mem,prefix,returnPc,value);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27]; state := next27;
    Advance28(code,state,data,mem,prefix,returnPc,value);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28]; state := next28;
    Advance29(code,state,data,mem,prefix,returnPc,value);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);
    trace := trace+[next29]; state := next29;
    Advance30(code,state,data,mem,prefix,returnPc,value);
    var next30 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30);
    trace := trace+[next30]; state := next30;
    Advance31(code,state,data,mem,prefix,returnPc,value);
    var next31 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31);
    trace := trace+[next31]; state := next31;
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && |prefix| <= 1010
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 33 && trace[0] == Running(22579,prefix+[returnPc,|data|,4],mem) && trace[|trace|-1] == state
  {
    Start(data,mem,prefix,returnPc);
    state := Running(22579,prefix+[returnPc,|data|,4],mem); trace := [state];
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block1(code,state,data,mem,prefix,returnPc,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
