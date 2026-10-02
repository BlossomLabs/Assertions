// SPDX-License-Identifier: MIT
// Generated actual raw bytes decoder empty-rejection path.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeZipRawHeadShort {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import DS = BytecodeScanDecoderScalar
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  function HeadA(data: seq<Byte>): Word { DataWord(data,4) }
  function HeadB(data: seq<Byte>): Word { DataWord(data,36) }
  function HeadPositionA(data: seq<Byte>): Word { ((HeadA(data) as nat)+4)%G.Modulus() }
  function HeadPositionB(data: seq<Byte>): Word { ((HeadB(data) as nat)+4)%G.Modulus() }
  function LengthA(data: seq<Byte>): Word { DataWord(data,HeadPositionA(data)) }
  function LengthB(data: seq<Byte>): Word { DataWord(data,HeadPositionB(data)) }
  function OffsetA(data: seq<Byte>): Word { ((HeadA(data) as nat)+36)%G.Modulus() }
  function OffsetB(data: seq<Byte>): Word { ((HeadB(data) as nat)+36)%G.Modulus() }
  predicate Admitted(data: seq<Byte>) { 4 <= |data| < 0x10000000000000000 && |data| < 68 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[499] == 91 &&
                                              code[500] == 97 &&
                                              code[501] == 2 &&
                                              code[502] == 6 &&
                                              code[503] == 97 &&
                                              code[504] == 2 &&
                                              code[505] == 1 &&
                                              code[506] == 54 &&
                                              code[507] == 96 &&
                                              code[508] == 4 &&
                                              code[509] == 97 &&
                                              code[510] == 82 &&
                                              code[511] == 113 &&
                                              code[512] == 86 &&
                                              code[21105] == 91 &&
                                              code[21106] == 95 &&
                                              code[21107] == 95 &&
                                              code[21108] == 95 &&
                                              code[21109] == 95 &&
                                              code[21110] == 96 &&
                                              code[21111] == 64 &&
                                              code[21112] == 133 &&
                                              code[21113] == 135 &&
                                              code[21114] == 3 &&
                                              code[21115] == 18 &&
                                              code[21116] == 21 &&
                                              code[21117] == 97 &&
                                              code[21118] == 82 &&
                                              code[21119] == 132 &&
                                              code[21120] == 87 &&
                                              code[21121] == 95 &&
                                              code[21122] == 95 &&
                                              code[21123] == 253 &&
                                              code[21124] == 91
  }
  function Destinations(): set<nat> { {21105,21124} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>) { Admitted(data) && (
                                                                                    if id == 0 then state == Running(499,[269019481],mem)
                                                                                    else if id == 1 then state == Running(500,[269019481],mem)
                                                                                    else if id == 2 then state == Running(503,[269019481,518],mem)
                                                                                    else if id == 3 then state == Running(506,[269019481,518,513],mem)
                                                                                    else if id == 4 then state == Running(507,[269019481,518,513,|data|],mem)
                                                                                    else if id == 5 then state == Running(509,[269019481,518,513,|data|,4],mem)
                                                                                    else if id == 6 then state == Running(512,[269019481,518,513,|data|,4,21105],mem)
                                                                                    else if id == 7 then state == Running(21105,[269019481,518,513,|data|,4],mem)
                                                                                    else if id == 8 then state == Running(21106,[269019481,518,513,|data|,4],mem)
                                                                                    else if id == 9 then state == Running(21107,[269019481,518,513,|data|,4,0],mem)
                                                                                    else if id == 10 then state == Running(21108,[269019481,518,513,|data|,4,0,0],mem)
                                                                                    else if id == 11 then state == Running(21109,[269019481,518,513,|data|,4,0,0,0],mem)
                                                                                    else if id == 12 then state == Running(21110,[269019481,518,513,|data|,4,0,0,0,0],mem)
                                                                                    else if id == 13 then state == Running(21112,[269019481,518,513,|data|,4,0,0,0,0,64],mem)
                                                                                    else if id == 14 then state == Running(21113,[269019481,518,513,|data|,4,0,0,0,0,64,4],mem)
                                                                                    else if id == 15 then state == Running(21114,[269019481,518,513,|data|,4,0,0,0,0,64,4,|data|],mem)
                                                                                    else if id == 16 then state == Running(21115,[269019481,518,513,|data|,4,0,0,0,0,64,((|data| as nat)+G.Modulus()-(4 as nat))%G.Modulus()],mem)
                                                                                    else if id == 17 then state == Running(21116,[269019481,518,513,|data|,4,0,0,0,0,1],mem)
                                                                                    else if id == 18 then state == Running(21117,[269019481,518,513,|data|,4,0,0,0,0,0],mem)
                                                                                    else if id == 19 then state == Running(21120,[269019481,518,513,|data|,4,0,0,0,0,0,21124],mem)
                                                                                    else if id == 20 then state == Running(21121,[269019481,518,513,|data|,4,0,0,0,0],mem)
                                                                                    else if id == 21 then state == Running(21122,[269019481,518,513,|data|,4,0,0,0,0,0],mem)
                                                                                    else if id == 22 then state == Running(21123,[269019481,518,513,|data|,4,0,0,0,0,0,0],mem)
                                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(0,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(499,[269019481],mem);
    assert Fetch(code,499) == Op(91,500,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(1,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(500,[269019481],mem);
    F.Push2(code,500);
    assert Fetch(code,500) == Op(97,503,518);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(2,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(503,[269019481,518],mem);
    F.Push2(code,503);
    assert Fetch(code,503) == Op(97,506,513);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(3,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(506,[269019481,518,513],mem);
    assert Fetch(code,506) == Op(54,507,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(4,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(507,[269019481,518,513,|data|],mem);
    F.Push1(code,507);
    assert Fetch(code,507) == Op(96,509,4);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(5,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(509,[269019481,518,513,|data|,4],mem);
    F.Push2(code,509);
    assert Fetch(code,509) == Op(97,512,21105);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(6,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(512,[269019481,518,513,|data|,4,21105],mem);
    assert Fetch(code,512) == Op(86,513,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(7,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21105,[269019481,518,513,|data|,4],mem);
    assert Fetch(code,21105) == Op(91,21106,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(8,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21106,[269019481,518,513,|data|,4],mem);
    assert Fetch(code,21106) == Op(95,21107,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(9,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21107,[269019481,518,513,|data|,4,0],mem);
    assert Fetch(code,21107) == Op(95,21108,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(10,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21108,[269019481,518,513,|data|,4,0,0],mem);
    assert Fetch(code,21108) == Op(95,21109,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(11,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21109,[269019481,518,513,|data|,4,0,0,0],mem);
    assert Fetch(code,21109) == Op(95,21110,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(12,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21110,[269019481,518,513,|data|,4,0,0,0,0],mem);
    F.Push1(code,21110);
    assert Fetch(code,21110) == Op(96,21112,64);
  }
  lemma Advance13(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(13,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21112,[269019481,518,513,|data|,4,0,0,0,0,64],mem);
    assert Fetch(code,21112) == Op(133,21113,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(14,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21113,[269019481,518,513,|data|,4,0,0,0,0,64,4],mem);
    assert Fetch(code,21113) == Op(135,21114,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(15,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21114,[269019481,518,513,|data|,4,0,0,0,0,64,4,|data|],mem);
    assert Fetch(code,21114) == Op(3,21115,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(16,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21115,[269019481,518,513,|data|,4,0,0,0,0,64,((|data| as nat)+G.Modulus()-(4 as nat))%G.Modulus()],mem);
    assert Fetch(code,21115) == Op(18,21116,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(17,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21116,[269019481,518,513,|data|,4,0,0,0,0,1],mem);
    assert Fetch(code,21116) == Op(21,21117,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(18,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21117,[269019481,518,513,|data|,4,0,0,0,0,0],mem);
    F.Push2(code,21117);
    assert Fetch(code,21117) == Op(97,21120,21124);
  }
  lemma Advance19(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(19,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21120,[269019481,518,513,|data|,4,0,0,0,0,0,21124],mem);
    assert Fetch(code,21120) == Op(87,21121,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(20,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21121,[269019481,518,513,|data|,4,0,0,0,0],mem);
    assert Fetch(code,21121) == Op(95,21122,0);
  }
  lemma Advance21(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(21,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21122,[269019481,518,513,|data|,4,0,0,0,0,0],mem);
    assert Fetch(code,21122) == Op(95,21123,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(22,state,data,mem)
    ensures state.Running? && |state.stack| <= 12 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted([])
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21123,[269019481,518,513,|data|,4,0,0,0,0,0,0],mem);
    assert Fetch(code,21123) == Op(253,21124,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>)
    requires Admitted(data)
    ensures Good(0,Running(499,[269019481],mem),data,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data)
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 24 && trace[0] == Running(499,[269019481],mem) && trace[|trace|-1] == state
  {
    Start(data,mem);
    state := Running(499,[269019481],mem);
    trace := [state];
    Advance0(code,state,data,mem,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(499,[269019481],mem);
    state := next0;
    Advance1(code,state,data,mem,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(499,[269019481],mem);
    state := next1;
    Advance2(code,state,data,mem,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(499,[269019481],mem);
    state := next2;
    Advance3(code,state,data,mem,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(499,[269019481],mem);
    state := next3;
    Advance4(code,state,data,mem,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(499,[269019481],mem);
    state := next4;
    Advance5(code,state,data,mem,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(499,[269019481],mem);
    state := next5;
    Advance6(code,state,data,mem,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(499,[269019481],mem);
    state := next6;
    Advance7(code,state,data,mem,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(499,[269019481],mem);
    state := next7;
    Advance8(code,state,data,mem,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(499,[269019481],mem);
    state := next8;
    Advance9(code,state,data,mem,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(499,[269019481],mem);
    state := next9;
    Advance10(code,state,data,mem,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(499,[269019481],mem);
    state := next10;
    Advance11(code,state,data,mem,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(499,[269019481],mem);
    state := next11;
    Advance12(code,state,data,mem,value);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(499,[269019481],mem);
    state := next12;
    Advance13(code,state,data,mem,value);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(499,[269019481],mem);
    state := next13;
    Advance14(code,state,data,mem,value);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(499,[269019481],mem);
    state := next14;
    Advance15(code,state,data,mem,value);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(499,[269019481],mem);
    state := next15;
    Advance16(code,state,data,mem,value);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(499,[269019481],mem);
    state := next16;
    Advance17(code,state,data,mem,value);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(499,[269019481],mem);
    state := next17;
    Advance18(code,state,data,mem,value);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(499,[269019481],mem);
    state := next18;
    Advance19(code,state,data,mem,value);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(499,[269019481],mem);
    state := next19;
    Advance20(code,state,data,mem,value);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    assert trace[0] == Running(499,[269019481],mem);
    state := next20;
    Advance21(code,state,data,mem,value);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    assert trace[0] == Running(499,[269019481],mem);
    state := next21;
    Advance22(code,state,data,mem,value);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    assert trace[0] == Running(499,[269019481],mem);
    state := next22;
  }
}
