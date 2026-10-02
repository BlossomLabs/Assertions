// SPDX-License-Identifier: MIT
// Generated actual raw bytes decoder empty-rejection path.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeSortRawHeadShort {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import DS = BytecodeScanDecoderScalar
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  function Head(data: seq<Byte>): Word { DataWord(data,4) }
  function HeadPosition(data: seq<Byte>): Word { ((Head(data) as nat)+4)%G.Modulus() }
  function Length(data: seq<Byte>): Word { DataWord(data,HeadPosition(data)) }
  function Offset(data: seq<Byte>): Word { ((Head(data) as nat)+36)%G.Modulus() }
  predicate Admitted(data: seq<Byte>) { 4 <= |data| < 0x10000000000000000 && |data| < 36 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[637] == 91 &&
                                              code[638] == 97 &&
                                              code[639] == 2 &&
                                              code[640] == 6 &&
                                              code[641] == 97 &&
                                              code[642] == 2 &&
                                              code[643] == 139 &&
                                              code[644] == 54 &&
                                              code[645] == 96 &&
                                              code[646] == 4 &&
                                              code[647] == 97 &&
                                              code[648] == 83 &&
                                              code[649] == 241 &&
                                              code[650] == 86 &&
                                              code[21489] == 91 &&
                                              code[21490] == 95 &&
                                              code[21491] == 95 &&
                                              code[21492] == 96 &&
                                              code[21493] == 32 &&
                                              code[21494] == 131 &&
                                              code[21495] == 133 &&
                                              code[21496] == 3 &&
                                              code[21497] == 18 &&
                                              code[21498] == 21 &&
                                              code[21499] == 97 &&
                                              code[21500] == 84 &&
                                              code[21501] == 2 &&
                                              code[21502] == 87 &&
                                              code[21503] == 95 &&
                                              code[21504] == 95 &&
                                              code[21505] == 253 &&
                                              code[21506] == 91
  }
  function Destinations(): set<nat> { {21489,21506} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>) { Admitted(data) && (
                                                                                    if id == 0 then state == Running(637,[785862473],mem)
                                                                                    else if id == 1 then state == Running(638,[785862473],mem)
                                                                                    else if id == 2 then state == Running(641,[785862473,518],mem)
                                                                                    else if id == 3 then state == Running(644,[785862473,518,651],mem)
                                                                                    else if id == 4 then state == Running(645,[785862473,518,651,|data|],mem)
                                                                                    else if id == 5 then state == Running(647,[785862473,518,651,|data|,4],mem)
                                                                                    else if id == 6 then state == Running(650,[785862473,518,651,|data|,4,21489],mem)
                                                                                    else if id == 7 then state == Running(21489,[785862473,518,651,|data|,4],mem)
                                                                                    else if id == 8 then state == Running(21490,[785862473,518,651,|data|,4],mem)
                                                                                    else if id == 9 then state == Running(21491,[785862473,518,651,|data|,4,0],mem)
                                                                                    else if id == 10 then state == Running(21492,[785862473,518,651,|data|,4,0,0],mem)
                                                                                    else if id == 11 then state == Running(21494,[785862473,518,651,|data|,4,0,0,32],mem)
                                                                                    else if id == 12 then state == Running(21495,[785862473,518,651,|data|,4,0,0,32,4],mem)
                                                                                    else if id == 13 then state == Running(21496,[785862473,518,651,|data|,4,0,0,32,4,|data|],mem)
                                                                                    else if id == 14 then state == Running(21497,[785862473,518,651,|data|,4,0,0,32,((|data| as nat)+G.Modulus()-(4 as nat))%G.Modulus()],mem)
                                                                                    else if id == 15 then state == Running(21498,[785862473,518,651,|data|,4,0,0,1],mem)
                                                                                    else if id == 16 then state == Running(21499,[785862473,518,651,|data|,4,0,0,0],mem)
                                                                                    else if id == 17 then state == Running(21502,[785862473,518,651,|data|,4,0,0,0,21506],mem)
                                                                                    else if id == 18 then state == Running(21503,[785862473,518,651,|data|,4,0,0],mem)
                                                                                    else if id == 19 then state == Running(21504,[785862473,518,651,|data|,4,0,0,0],mem)
                                                                                    else if id == 20 then state == Running(21505,[785862473,518,651,|data|,4,0,0,0,0],mem)
                                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(0,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(637,[785862473],mem);
    assert Fetch(code,637) == Op(91,638,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(1,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(638,[785862473],mem);
    F.Push2(code,638);
    assert Fetch(code,638) == Op(97,641,518);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(2,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(641,[785862473,518],mem);
    F.Push2(code,641);
    assert Fetch(code,641) == Op(97,644,651);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(3,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(644,[785862473,518,651],mem);
    assert Fetch(code,644) == Op(54,645,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(4,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(645,[785862473,518,651,|data|],mem);
    F.Push1(code,645);
    assert Fetch(code,645) == Op(96,647,4);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(5,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(647,[785862473,518,651,|data|,4],mem);
    F.Push2(code,647);
    assert Fetch(code,647) == Op(97,650,21489);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(6,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(650,[785862473,518,651,|data|,4,21489],mem);
    assert Fetch(code,650) == Op(86,651,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(7,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21489,[785862473,518,651,|data|,4],mem);
    assert Fetch(code,21489) == Op(91,21490,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(8,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21490,[785862473,518,651,|data|,4],mem);
    assert Fetch(code,21490) == Op(95,21491,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(9,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21491,[785862473,518,651,|data|,4,0],mem);
    assert Fetch(code,21491) == Op(95,21492,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(10,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21492,[785862473,518,651,|data|,4,0,0],mem);
    F.Push1(code,21492);
    assert Fetch(code,21492) == Op(96,21494,32);
  }
  lemma Advance11(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(11,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21494,[785862473,518,651,|data|,4,0,0,32],mem);
    assert Fetch(code,21494) == Op(131,21495,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(12,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21495,[785862473,518,651,|data|,4,0,0,32,4],mem);
    assert Fetch(code,21495) == Op(133,21496,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(13,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21496,[785862473,518,651,|data|,4,0,0,32,4,|data|],mem);
    assert Fetch(code,21496) == Op(3,21497,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(14,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21497,[785862473,518,651,|data|,4,0,0,32,((|data| as nat)+G.Modulus()-(4 as nat))%G.Modulus()],mem);
    assert Fetch(code,21497) == Op(18,21498,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(15,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21498,[785862473,518,651,|data|,4,0,0,1],mem);
    assert Fetch(code,21498) == Op(21,21499,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(16,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21499,[785862473,518,651,|data|,4,0,0,0],mem);
    F.Push2(code,21499);
    assert Fetch(code,21499) == Op(97,21502,21506);
  }
  lemma Advance17(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(17,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21502,[785862473,518,651,|data|,4,0,0,0,21506],mem);
    assert Fetch(code,21502) == Op(87,21503,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(18,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21503,[785862473,518,651,|data|,4,0,0],mem);
    assert Fetch(code,21503) == Op(95,21504,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(19,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21504,[785862473,518,651,|data|,4,0,0,0],mem);
    assert Fetch(code,21504) == Op(95,21505,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(20,state,data,mem)
    ensures state.Running? && |state.stack| <= 10 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted([])
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21505,[785862473,518,651,|data|,4,0,0,0,0],mem);
    assert Fetch(code,21505) == Op(253,21506,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>)
    requires Admitted(data)
    ensures Good(0,Running(637,[785862473],mem),data,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data)
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 22 && trace[0] == Running(637,[785862473],mem) && trace[|trace|-1] == state
  {
    Start(data,mem);
    state := Running(637,[785862473],mem);
    trace := [state];
    Advance0(code,state,data,mem,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(637,[785862473],mem);
    state := next0;
    Advance1(code,state,data,mem,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(637,[785862473],mem);
    state := next1;
    Advance2(code,state,data,mem,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(637,[785862473],mem);
    state := next2;
    Advance3(code,state,data,mem,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(637,[785862473],mem);
    state := next3;
    Advance4(code,state,data,mem,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(637,[785862473],mem);
    state := next4;
    Advance5(code,state,data,mem,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(637,[785862473],mem);
    state := next5;
    Advance6(code,state,data,mem,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(637,[785862473],mem);
    state := next6;
    Advance7(code,state,data,mem,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(637,[785862473],mem);
    state := next7;
    Advance8(code,state,data,mem,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(637,[785862473],mem);
    state := next8;
    Advance9(code,state,data,mem,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(637,[785862473],mem);
    state := next9;
    Advance10(code,state,data,mem,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(637,[785862473],mem);
    state := next10;
    Advance11(code,state,data,mem,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(637,[785862473],mem);
    state := next11;
    Advance12(code,state,data,mem,value);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(637,[785862473],mem);
    state := next12;
    Advance13(code,state,data,mem,value);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(637,[785862473],mem);
    state := next13;
    Advance14(code,state,data,mem,value);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(637,[785862473],mem);
    state := next14;
    Advance15(code,state,data,mem,value);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(637,[785862473],mem);
    state := next15;
    Advance16(code,state,data,mem,value);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(637,[785862473],mem);
    state := next16;
    Advance17(code,state,data,mem,value);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(637,[785862473],mem);
    state := next17;
    Advance18(code,state,data,mem,value);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(637,[785862473],mem);
    state := next18;
    Advance19(code,state,data,mem,value);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(637,[785862473],mem);
    state := next19;
    Advance20(code,state,data,mem,value);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    assert trace[0] == Running(637,[785862473],mem);
    state := next20;
  }
}
