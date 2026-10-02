// SPDX-License-Identifier: MIT
// Generated actual raw bytes decoder empty-rejection path.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeSortRawOffsetLarge {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import DS = BytecodeScanDecoderScalar
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  function Head(data: seq<Byte>): Word { DataWord(data,4) }
  function HeadPosition(data: seq<Byte>): Word { ((Head(data) as nat)+4)%G.Modulus() }
  function Length(data: seq<Byte>): Word { DataWord(data,HeadPosition(data)) }
  function Offset(data: seq<Byte>): Word { ((Head(data) as nat)+36)%G.Modulus() }
  predicate Admitted(data: seq<Byte>) { 4 <= |data| < 0x10000000000000000 && 36 <= |data| && Head(data) >= 0x10000000000000000 }
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
                                              code[21506] == 91 &&
                                              code[21507] == 130 &&
                                              code[21508] == 53 &&
                                              code[21509] == 96 &&
                                              code[21510] == 1 &&
                                              code[21511] == 96 &&
                                              code[21512] == 1 &&
                                              code[21513] == 96 &&
                                              code[21514] == 64 &&
                                              code[21515] == 27 &&
                                              code[21516] == 3 &&
                                              code[21517] == 129 &&
                                              code[21518] == 17 &&
                                              code[21519] == 21 &&
                                              code[21520] == 97 &&
                                              code[21521] == 84 &&
                                              code[21522] == 23 &&
                                              code[21523] == 87 &&
                                              code[21524] == 95 &&
                                              code[21525] == 95 &&
                                              code[21526] == 253 &&
                                              code[21527] == 91
  }
  function Destinations(): set<nat> { {21489,21506,21527} }
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
                                                                                    else if id == 15 then state == Running(21498,[785862473,518,651,|data|,4,0,0,0],mem)
                                                                                    else if id == 16 then state == Running(21499,[785862473,518,651,|data|,4,0,0,1],mem)
                                                                                    else if id == 17 then state == Running(21502,[785862473,518,651,|data|,4,0,0,1,21506],mem)
                                                                                    else if id == 18 then state == Running(21506,[785862473,518,651,|data|,4,0,0],mem)
                                                                                    else if id == 19 then state == Running(21507,[785862473,518,651,|data|,4,0,0],mem)
                                                                                    else if id == 20 then state == Running(21508,[785862473,518,651,|data|,4,0,0,4],mem)
                                                                                    else if id == 21 then state == Running(21509,[785862473,518,651,|data|,4,0,0,Head(data)],mem)
                                                                                    else if id == 22 then state == Running(21511,[785862473,518,651,|data|,4,0,0,Head(data),1],mem)
                                                                                    else if id == 23 then state == Running(21513,[785862473,518,651,|data|,4,0,0,Head(data),1,1],mem)
                                                                                    else if id == 24 then state == Running(21515,[785862473,518,651,|data|,4,0,0,Head(data),1,1,64],mem)
                                                                                    else if id == 25 then state == Running(21516,[785862473,518,651,|data|,4,0,0,Head(data),1,18446744073709551616],mem)
                                                                                    else if id == 26 then state == Running(21517,[785862473,518,651,|data|,4,0,0,Head(data),18446744073709551615],mem)
                                                                                    else if id == 27 then state == Running(21518,[785862473,518,651,|data|,4,0,0,Head(data),18446744073709551615,Head(data)],mem)
                                                                                    else if id == 28 then state == Running(21519,[785862473,518,651,|data|,4,0,0,Head(data),1],mem)
                                                                                    else if id == 29 then state == Running(21520,[785862473,518,651,|data|,4,0,0,Head(data),0],mem)
                                                                                    else if id == 30 then state == Running(21523,[785862473,518,651,|data|,4,0,0,Head(data),0,21527],mem)
                                                                                    else if id == 31 then state == Running(21524,[785862473,518,651,|data|,4,0,0,Head(data)],mem)
                                                                                    else if id == 32 then state == Running(21525,[785862473,518,651,|data|,4,0,0,Head(data),0],mem)
                                                                                    else if id == 33 then state == Running(21526,[785862473,518,651,|data|,4,0,0,Head(data),0,0],mem)
                                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(0,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(637,[785862473],mem);
    assert Fetch(code,637) == Op(91,638,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(1,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(638,[785862473],mem);
    F.Push2(code,638);
    assert Fetch(code,638) == Op(97,641,518);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(2,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(641,[785862473,518],mem);
    F.Push2(code,641);
    assert Fetch(code,641) == Op(97,644,651);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(3,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(644,[785862473,518,651],mem);
    assert Fetch(code,644) == Op(54,645,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(4,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(645,[785862473,518,651,|data|],mem);
    F.Push1(code,645);
    assert Fetch(code,645) == Op(96,647,4);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(5,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(647,[785862473,518,651,|data|,4],mem);
    F.Push2(code,647);
    assert Fetch(code,647) == Op(97,650,21489);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(6,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(650,[785862473,518,651,|data|,4,21489],mem);
    assert Fetch(code,650) == Op(86,651,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(7,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21489,[785862473,518,651,|data|,4],mem);
    assert Fetch(code,21489) == Op(91,21490,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(8,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21490,[785862473,518,651,|data|,4],mem);
    assert Fetch(code,21490) == Op(95,21491,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(9,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21491,[785862473,518,651,|data|,4,0],mem);
    assert Fetch(code,21491) == Op(95,21492,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(10,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21492,[785862473,518,651,|data|,4,0,0],mem);
    F.Push1(code,21492);
    assert Fetch(code,21492) == Op(96,21494,32);
  }
  lemma Advance11(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(11,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21494,[785862473,518,651,|data|,4,0,0,32],mem);
    assert Fetch(code,21494) == Op(131,21495,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(12,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21495,[785862473,518,651,|data|,4,0,0,32,4],mem);
    assert Fetch(code,21495) == Op(133,21496,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(13,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21496,[785862473,518,651,|data|,4,0,0,32,4,|data|],mem);
    assert Fetch(code,21496) == Op(3,21497,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(14,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21497,[785862473,518,651,|data|,4,0,0,32,((|data| as nat)+G.Modulus()-(4 as nat))%G.Modulus()],mem);
    assert Fetch(code,21497) == Op(18,21498,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(15,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21498,[785862473,518,651,|data|,4,0,0,0],mem);
    assert Fetch(code,21498) == Op(21,21499,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(16,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21499,[785862473,518,651,|data|,4,0,0,1],mem);
    F.Push2(code,21499);
    assert Fetch(code,21499) == Op(97,21502,21506);
  }
  lemma Advance17(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(17,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21502,[785862473,518,651,|data|,4,0,0,1,21506],mem);
    assert Fetch(code,21502) == Op(87,21503,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(18,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21506,[785862473,518,651,|data|,4,0,0],mem);
    assert Fetch(code,21506) == Op(91,21507,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(19,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21507,[785862473,518,651,|data|,4,0,0],mem);
    assert Fetch(code,21507) == Op(130,21508,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(20,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21508,[785862473,518,651,|data|,4,0,0,4],mem);
    assert Fetch(code,21508) == Op(53,21509,0);
  }
  lemma Advance21(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(21,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21509,[785862473,518,651,|data|,4,0,0,Head(data)],mem);
    F.Push1(code,21509);
    assert Fetch(code,21509) == Op(96,21511,1);
  }
  lemma Advance22(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(22,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21511,[785862473,518,651,|data|,4,0,0,Head(data),1],mem);
    F.Push1(code,21511);
    assert Fetch(code,21511) == Op(96,21513,1);
  }
  lemma Advance23(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(23,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21513,[785862473,518,651,|data|,4,0,0,Head(data),1,1],mem);
    F.Push1(code,21513);
    assert Fetch(code,21513) == Op(96,21515,64);
  }
  lemma Advance24(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(24,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21515,[785862473,518,651,|data|,4,0,0,Head(data),1,1,64],mem);
    DS.DecoderLimit();
    assert Fetch(code,21515) == Op(27,21516,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(25,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21516,[785862473,518,651,|data|,4,0,0,Head(data),1,18446744073709551616],mem);
    assert Fetch(code,21516) == Op(3,21517,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(26,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21517,[785862473,518,651,|data|,4,0,0,Head(data),18446744073709551615],mem);
    assert Fetch(code,21517) == Op(129,21518,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(27,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21518,[785862473,518,651,|data|,4,0,0,Head(data),18446744073709551615,Head(data)],mem);
    assert Fetch(code,21518) == Op(17,21519,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(28,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21519,[785862473,518,651,|data|,4,0,0,Head(data),1],mem);
    assert Fetch(code,21519) == Op(21,21520,0);
  }
  lemma Advance29(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(29,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21520,[785862473,518,651,|data|,4,0,0,Head(data),0],mem);
    F.Push2(code,21520);
    assert Fetch(code,21520) == Op(97,21523,21527);
  }
  lemma Advance30(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(30,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21523,[785862473,518,651,|data|,4,0,0,Head(data),0,21527],mem);
    assert Fetch(code,21523) == Op(87,21524,0);
  }
  lemma Advance31(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(31,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(32,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21524,[785862473,518,651,|data|,4,0,0,Head(data)],mem);
    assert Fetch(code,21524) == Op(95,21525,0);
  }
  lemma Advance32(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(32,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(33,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21525,[785862473,518,651,|data|,4,0,0,Head(data),0],mem);
    assert Fetch(code,21525) == Op(95,21526,0);
  }
  lemma Advance33(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(33,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted([])
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(21526,[785862473,518,651,|data|,4,0,0,Head(data),0,0],mem);
    assert Fetch(code,21526) == Op(253,21527,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>)
    requires Admitted(data)
    ensures Good(0,Running(637,[785862473],mem),data,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data)
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 35 && trace[0] == Running(637,[785862473],mem) && trace[|trace|-1] == state
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
    Advance21(code,state,data,mem,value);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    assert trace[0] == Running(637,[785862473],mem);
    state := next21;
    Advance22(code,state,data,mem,value);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    assert trace[0] == Running(637,[785862473],mem);
    state := next22;
    Advance23(code,state,data,mem,value);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23];
    assert trace[0] == Running(637,[785862473],mem);
    state := next23;
    Advance24(code,state,data,mem,value);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24];
    assert trace[0] == Running(637,[785862473],mem);
    state := next24;
    Advance25(code,state,data,mem,value);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25];
    assert trace[0] == Running(637,[785862473],mem);
    state := next25;
    Advance26(code,state,data,mem,value);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26];
    assert trace[0] == Running(637,[785862473],mem);
    state := next26;
    Advance27(code,state,data,mem,value);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27];
    assert trace[0] == Running(637,[785862473],mem);
    state := next27;
    Advance28(code,state,data,mem,value);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28];
    assert trace[0] == Running(637,[785862473],mem);
    state := next28;
    Advance29(code,state,data,mem,value);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);
    trace := trace+[next29];
    assert trace[0] == Running(637,[785862473],mem);
    state := next29;
    Advance30(code,state,data,mem,value);
    var next30 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30);
    trace := trace+[next30];
    assert trace[0] == Running(637,[785862473],mem);
    state := next30;
    Advance31(code,state,data,mem,value);
    var next31 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31);
    trace := trace+[next31];
    assert trace[0] == Running(637,[785862473],mem);
    state := next31;
    Advance32(code,state,data,mem,value);
    var next32 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next32);
    trace := trace+[next32];
    assert trace[0] == Running(637,[785862473],mem);
    state := next32;
    Advance33(code,state,data,mem,value);
    var next33 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next33);
    trace := trace+[next33];
    assert trace[0] == Running(637,[785862473],mem);
    state := next33;
  }
}
