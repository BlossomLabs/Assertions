// SPDX-License-Identifier: MIT
// Generated ordered raw four-head decoder source rejection; arbitrary prefix preserved until REVERT.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeApplyRawSourceHeaderShort {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import DS = BytecodeScanDecoderScalar
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  function Head(data: seq<Byte>): Word { DataWord(data,4) }
  function Header(data: seq<Byte>): Word { ((Head(data) as nat)+4)%G.Modulus() }
  function Length(data: seq<Byte>): Word { DataWord(data,Header(data)) }
  function Offset(data: seq<Byte>): Word { ((Head(data) as nat)+36)%G.Modulus() }
  predicate Admitted(data: seq<Byte>) { 4 <= |data| < 0x10000000000000000 && 132 <= |data| && Head(data) < 0x10000000000000000 && (Head(data) as nat)+36 > |data| }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[20617] == 91 &&
                                              code[20618] == 95 &&
                                              code[20619] == 95 &&
                                              code[20620] == 131 &&
                                              code[20621] == 96 &&
                                              code[20622] == 31 &&
                                              code[20623] == 132 &&
                                              code[20624] == 1 &&
                                              code[20625] == 18 &&
                                              code[20626] == 97 &&
                                              code[20627] == 80 &&
                                              code[20628] == 153 &&
                                              code[20629] == 87 &&
                                              code[20630] == 95 &&
                                              code[20631] == 95 &&
                                              code[20632] == 253 &&
                                              code[20633] == 91 &&
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
                                              code[22622] == 91 &&
                                              code[22623] == 97 &&
                                              code[22624] == 88 &&
                                              code[22625] == 106 &&
                                              code[22626] == 138 &&
                                              code[22627] == 130 &&
                                              code[22628] == 139 &&
                                              code[22629] == 1 &&
                                              code[22630] == 97 &&
                                              code[22631] == 80 &&
                                              code[22632] == 137 &&
                                              code[22633] == 86
  }
  function Destinations(): set<nat> { {20617,20633,22601,22622} }
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
                                                                                                                       else if id == 26 then state == Running(22614,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),0],mem)
                                                                                                                       else if id == 27 then state == Running(22615,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1],mem)
                                                                                                                       else if id == 28 then state == Running(22618,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1,22622],mem)
                                                                                                                       else if id == 29 then state == Running(22622,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data)],mem)
                                                                                                                       else if id == 30 then state == Running(22623,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data)],mem)
                                                                                                                       else if id == 31 then state == Running(22626,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634],mem)
                                                                                                                       else if id == 32 then state == Running(22627,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|],mem)
                                                                                                                       else if id == 33 then state == Running(22628,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Head(data)],mem)
                                                                                                                       else if id == 34 then state == Running(22629,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Head(data),4],mem)
                                                                                                                       else if id == 35 then state == Running(22630,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data)],mem)
                                                                                                                       else if id == 36 then state == Running(22633,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),20617],mem)
                                                                                                                       else if id == 37 then state == Running(20617,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data)],mem)
                                                                                                                       else if id == 38 then state == Running(20618,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data)],mem)
                                                                                                                       else if id == 39 then state == Running(20619,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0],mem)
                                                                                                                       else if id == 40 then state == Running(20620,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0],mem)
                                                                                                                       else if id == 41 then state == Running(20621,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0,|data|],mem)
                                                                                                                       else if id == 42 then state == Running(20623,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0,|data|,31],mem)
                                                                                                                       else if id == 43 then state == Running(20624,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0,|data|,31,Header(data)],mem)
                                                                                                                       else if id == 44 then state == Running(20625,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0,|data|,((Header(data) as nat)+(31 as nat))%G.Modulus()],mem)
                                                                                                                       else if id == 45 then state == Running(20626,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0,0],mem)
                                                                                                                       else if id == 46 then state == Running(20629,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0,0,20633],mem)
                                                                                                                       else if id == 47 then state == Running(20630,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0],mem)
                                                                                                                       else if id == 48 then state == Running(20631,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0,0],mem)
                                                                                                                       else if id == 49 then state == Running(20632,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0,0,0],mem)
                                                                                                                       else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(0,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22579,prefix+[returnPc,|data|,4],mem);
    assert Fetch(code,22579) == Op(91,22580,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(1,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22580,prefix+[returnPc,|data|,4],mem);
    assert Fetch(code,22580) == Op(95,22581,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(2,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22581,prefix+[returnPc,|data|,4,0],mem);
    assert Fetch(code,22581) == Op(95,22582,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(3,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22582,prefix+[returnPc,|data|,4,0,0],mem);
    assert Fetch(code,22582) == Op(95,22583,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(4,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22583,prefix+[returnPc,|data|,4,0,0,0],mem);
    assert Fetch(code,22583) == Op(95,22584,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(5,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22584,prefix+[returnPc,|data|,4,0,0,0,0],mem);
    assert Fetch(code,22584) == Op(95,22585,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(6,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22585,prefix+[returnPc,|data|,4,0,0,0,0,0],mem);
    assert Fetch(code,22585) == Op(95,22586,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(7,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22586,prefix+[returnPc,|data|,4,0,0,0,0,0,0],mem);
    assert Fetch(code,22586) == Op(95,22587,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(8,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22587,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem);
    F.Push1(code,22587);
    assert Fetch(code,22587) == Op(96,22589,128);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(9,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22589,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128],mem);
    assert Fetch(code,22589) == Op(136,22590,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(10,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22590,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,4],mem);
    assert Fetch(code,22590) == Op(138,22591,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(11,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22591,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,4,|data|],mem);
    assert Fetch(code,22591) == Op(3,22592,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(12,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22592,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,128,((|data| as nat)+G.Modulus()-(4 as nat))%G.Modulus()],mem);
    assert Fetch(code,22592) == Op(18,22593,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(13,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22593,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,0],mem);
    assert Fetch(code,22593) == Op(21,22594,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(14,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22594,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,1],mem);
    F.Push2(code,22594);
    assert Fetch(code,22594) == Op(97,22597,22601);
  }
  lemma Advance15(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(15,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22597,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,1,22601],mem);
    assert Fetch(code,22597) == Op(87,22598,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(16,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22601,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem);
    assert Fetch(code,22601) == Op(91,22602,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(17,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22602,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0],mem);
    assert Fetch(code,22602) == Op(135,22603,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(18,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22603,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,4],mem);
    assert Fetch(code,22603) == Op(53,22604,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(19,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22604,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data)],mem);
    F.Push1(code,22604);
    assert Fetch(code,22604) == Op(96,22606,1);
  }
  lemma Advance20(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(20,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22606,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1],mem);
    F.Push1(code,22606);
    assert Fetch(code,22606) == Op(96,22608,1);
  }
  lemma Advance21(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(21,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22608,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1,1],mem);
    F.Push1(code,22608);
    assert Fetch(code,22608) == Op(96,22610,64);
  }
  lemma Advance22(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(22,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22610,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1,1,64],mem);
    DS.DecoderLimit();
    assert Fetch(code,22610) == Op(27,22611,0);
  }
  lemma Advance23(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(23,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22611,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1,18446744073709551616],mem);
    assert Fetch(code,22611) == Op(3,22612,0);
  }
  lemma Advance24(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(24,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22612,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),18446744073709551615],mem);
    assert Fetch(code,22612) == Op(129,22613,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(25,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22613,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),18446744073709551615,Head(data)],mem);
    assert Fetch(code,22613) == Op(17,22614,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(26,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22614,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),0],mem);
    assert Fetch(code,22614) == Op(21,22615,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(27,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22615,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1],mem);
    F.Push2(code,22615);
    assert Fetch(code,22615) == Op(97,22618,22622);
  }
  lemma Advance28(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(28,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22618,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),1,22622],mem);
    assert Fetch(code,22618) == Op(87,22619,0);
  }
  lemma Advance29(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(29,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22622,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data)],mem);
    assert Fetch(code,22622) == Op(91,22623,0);
  }
  lemma Advance30(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(30,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22623,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data)],mem);
    F.Push2(code,22623);
    assert Fetch(code,22623) == Op(97,22626,22634);
  }
  lemma Advance31(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(31,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(32,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22626,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634],mem);
    assert Fetch(code,22626) == Op(138,22627,0);
  }
  lemma Advance32(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(32,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(33,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22627,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|],mem);
    assert Fetch(code,22627) == Op(130,22628,0);
  }
  lemma Advance33(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(33,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(34,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22628,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Head(data)],mem);
    assert Fetch(code,22628) == Op(139,22629,0);
  }
  lemma Advance34(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(34,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(35,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22629,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Head(data),4],mem);
    assert Fetch(code,22629) == Op(1,22630,0);
  }
  lemma Advance35(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(35,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(36,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22630,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data)],mem);
    F.Push2(code,22630);
    assert Fetch(code,22630) == Op(97,22633,20617);
  }
  lemma Advance36(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(36,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(37,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22633,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),20617],mem);
    assert Fetch(code,22633) == Op(86,22634,0);
  }
  lemma Advance37(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(37,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(38,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20617,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data)],mem);
    assert Fetch(code,20617) == Op(91,20618,0);
  }
  lemma Advance38(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(38,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(39,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20618,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data)],mem);
    assert Fetch(code,20618) == Op(95,20619,0);
  }
  lemma Advance39(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(39,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(40,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20619,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0],mem);
    assert Fetch(code,20619) == Op(95,20620,0);
  }
  lemma Advance40(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(40,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(41,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20620,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0],mem);
    assert Fetch(code,20620) == Op(131,20621,0);
  }
  lemma Advance41(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(41,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(42,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20621,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0,|data|],mem);
    F.Push1(code,20621);
    assert Fetch(code,20621) == Op(96,20623,31);
  }
  lemma Advance42(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(42,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(43,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20623,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0,|data|,31],mem);
    assert Fetch(code,20623) == Op(132,20624,0);
  }
  lemma Advance43(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(43,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(44,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20624,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0,|data|,31,Header(data)],mem);
    assert Fetch(code,20624) == Op(1,20625,0);
  }
  lemma Advance44(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(44,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(45,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20625,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0,|data|,((Header(data) as nat)+(31 as nat))%G.Modulus()],mem);
    assert Fetch(code,20625) == Op(18,20626,0);
  }
  lemma Advance45(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(45,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(46,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20626,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0,0],mem);
    F.Push2(code,20626);
    assert Fetch(code,20626) == Op(97,20629,20633);
  }
  lemma Advance46(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(46,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(47,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20629,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0,0,20633],mem);
    assert Fetch(code,20629) == Op(87,20630,0);
  }
  lemma Advance47(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(47,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(48,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20630,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0],mem);
    assert Fetch(code,20630) == Op(95,20631,0);
  }
  lemma Advance48(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(48,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(49,next,data,mem,prefix,returnPc)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20631,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0,0],mem);
    assert Fetch(code,20631) == Op(95,20632,0);
  }
  lemma Advance49(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word)
    requires Matches(code) && Admitted(data) && Good(49,state,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted([])
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(20632,prefix+[returnPc,|data|,4,0,0,0,0,0,0,0,Head(data),22634,|data|,Header(data),0,0,0,0],mem);
    assert Fetch(code,20632) == Op(253,20633,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word)
    requires Admitted(data)
    ensures Good(0,Running(22579,prefix+[returnPc,|data|,4],mem),data,mem,prefix,returnPc)
  { reveal Good(); }
  ghost method Block0(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && Good(0,initial,data,mem,prefix,returnPc) && |prefix| <= 1005
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
    requires Matches(code) && Admitted(data) && Good(20,initial,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures Good(40,state,data,mem,prefix,returnPc) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
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
    Advance32(code,state,data,mem,prefix,returnPc,value);
    var next32 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next32);
    trace := trace+[next32]; state := next32;
    Advance33(code,state,data,mem,prefix,returnPc,value);
    var next33 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next33);
    trace := trace+[next33]; state := next33;
    Advance34(code,state,data,mem,prefix,returnPc,value);
    var next34 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next34);
    trace := trace+[next34]; state := next34;
    Advance35(code,state,data,mem,prefix,returnPc,value);
    var next35 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next35);
    trace := trace+[next35]; state := next35;
    Advance36(code,state,data,mem,prefix,returnPc,value);
    var next36 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next36);
    trace := trace+[next36]; state := next36;
    Advance37(code,state,data,mem,prefix,returnPc,value);
    var next37 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next37);
    trace := trace+[next37]; state := next37;
    Advance38(code,state,data,mem,prefix,returnPc,value);
    var next38 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next38);
    trace := trace+[next38]; state := next38;
    Advance39(code,state,data,mem,prefix,returnPc,value);
    var next39 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next39);
    trace := trace+[next39]; state := next39;
  }
  ghost method Block2(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && Good(40,initial,data,mem,prefix,returnPc) && |prefix| <= 1005
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 11 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance40(code,state,data,mem,prefix,returnPc,value);
    var next40 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next40);
    trace := trace+[next40]; state := next40;
    Advance41(code,state,data,mem,prefix,returnPc,value);
    var next41 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next41);
    trace := trace+[next41]; state := next41;
    Advance42(code,state,data,mem,prefix,returnPc,value);
    var next42 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next42);
    trace := trace+[next42]; state := next42;
    Advance43(code,state,data,mem,prefix,returnPc,value);
    var next43 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next43);
    trace := trace+[next43]; state := next43;
    Advance44(code,state,data,mem,prefix,returnPc,value);
    var next44 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next44);
    trace := trace+[next44]; state := next44;
    Advance45(code,state,data,mem,prefix,returnPc,value);
    var next45 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next45);
    trace := trace+[next45]; state := next45;
    Advance46(code,state,data,mem,prefix,returnPc,value);
    var next46 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next46);
    trace := trace+[next46]; state := next46;
    Advance47(code,state,data,mem,prefix,returnPc,value);
    var next47 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next47);
    trace := trace+[next47]; state := next47;
    Advance48(code,state,data,mem,prefix,returnPc,value);
    var next48 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next48);
    trace := trace+[next48]; state := next48;
    Advance49(code,state,data,mem,prefix,returnPc,value);
    var next49 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next49);
    trace := trace+[next49]; state := next49;
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && |prefix| <= 1005
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 51 && trace[0] == Running(22579,prefix+[returnPc,|data|,4],mem) && trace[|trace|-1] == state
  {
    Start(data,mem,prefix,returnPc);
    state := Running(22579,prefix+[returnPc,|data|,4],mem); trace := [state];
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block1(code,state,data,mem,prefix,returnPc,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block2(code,state,data,mem,prefix,returnPc,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
