// SPDX-License-Identifier: MIT
// Generated current runtime instructions from PC zero to the filterWords wrapper.
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
include "ShiftKernel.dfy"
module BytecodeWordFilterPrefix {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import K = BytecodeFilterPrefixShift
  opaque predicate SelectorAdmitted(data: seq<Byte>) { ShiftRight(DataWord(data,0),224) == 2005396296 }
  predicate Admitted(value: Word, data: seq<Byte>) { value == 0 && 4 <= |data| < 0x10000000000000000 && SelectorAdmitted(data) }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[0] == 96 &&
                                              code[1] == 128 &&
                                              code[2] == 96 &&
                                              code[3] == 64 &&
                                              code[4] == 82 &&
                                              code[5] == 52 &&
                                              code[6] == 128 &&
                                              code[7] == 21 &&
                                              code[8] == 97 &&
                                              code[9] == 0 &&
                                              code[10] == 15 &&
                                              code[11] == 87 &&
                                              code[15] == 91 &&
                                              code[16] == 80 &&
                                              code[17] == 96 &&
                                              code[18] == 4 &&
                                              code[19] == 54 &&
                                              code[20] == 16 &&
                                              code[21] == 97 &&
                                              code[22] == 1 &&
                                              code[23] == 198 &&
                                              code[24] == 87 &&
                                              code[25] == 95 &&
                                              code[26] == 53 &&
                                              code[27] == 96 &&
                                              code[28] == 224 &&
                                              code[29] == 28 &&
                                              code[30] == 128 &&
                                              code[31] == 99 &&
                                              code[32] == 141 &&
                                              code[33] == 39 &&
                                              code[34] == 244 &&
                                              code[35] == 141 &&
                                              code[36] == 17 &&
                                              code[37] == 97 &&
                                              code[38] == 0 &&
                                              code[39] == 254 &&
                                              code[40] == 87 &&
                                              code[254] == 91 &&
                                              code[255] == 128 &&
                                              code[256] == 99 &&
                                              code[257] == 57 &&
                                              code[258] == 81 &&
                                              code[259] == 56 &&
                                              code[260] == 13 &&
                                              code[261] == 17 &&
                                              code[262] == 97 &&
                                              code[263] == 1 &&
                                              code[264] == 105 &&
                                              code[265] == 87 &&
                                              code[266] == 128 &&
                                              code[267] == 99 &&
                                              code[268] == 109 &&
                                              code[269] == 36 &&
                                              code[270] == 231 &&
                                              code[271] == 156 &&
                                              code[272] == 17 &&
                                              code[273] == 97 &&
                                              code[274] == 1 &&
                                              code[275] == 68 &&
                                              code[276] == 87 &&
                                              code[277] == 128 &&
                                              code[278] == 99 &&
                                              code[279] == 109 &&
                                              code[280] == 36 &&
                                              code[281] == 231 &&
                                              code[282] == 156 &&
                                              code[283] == 20 &&
                                              code[284] == 97 &&
                                              code[285] == 2 &&
                                              code[286] == 201 &&
                                              code[287] == 87 &&
                                              code[288] == 128 &&
                                              code[289] == 99 &&
                                              code[290] == 109 &&
                                              code[291] == 230 &&
                                              code[292] == 12 &&
                                              code[293] == 176 &&
                                              code[294] == 20 &&
                                              code[295] == 97 &&
                                              code[296] == 2 &&
                                              code[297] == 220 &&
                                              code[298] == 87 &&
                                              code[299] == 128 &&
                                              code[300] == 99 &&
                                              code[301] == 117 &&
                                              code[302] == 13 &&
                                              code[303] == 130 &&
                                              code[304] == 215 &&
                                              code[305] == 20 &&
                                              code[306] == 97 &&
                                              code[307] == 2 &&
                                              code[308] == 239 &&
                                              code[309] == 87 &&
                                              code[310] == 128 &&
                                              code[311] == 99 &&
                                              code[312] == 119 &&
                                              code[313] == 135 &&
                                              code[314] == 235 &&
                                              code[315] == 72 &&
                                              code[316] == 20 &&
                                              code[317] == 97 &&
                                              code[318] == 3 &&
                                              code[319] == 2 &&
                                              code[320] == 87 &&
                                              code[324] == 91 &&
                                              code[361] == 91 &&
                                              code[454] == 91 &&
                                              code[713] == 91 &&
                                              code[732] == 91 &&
                                              code[751] == 91 &&
                                              code[770] == 91
  }
  function Destinations(): set<nat> { {15,254,324,361,454,713,732,751,770} }
  opaque predicate Good(id: nat, state: State, value: Word, data: seq<Byte>) { Admitted(value,data) && (
                                                                                 if id == 0 then state == Running(0,[],[])
                                                                                 else if id == 1 then state == Running(2,[128],[])
                                                                                 else if id == 2 then state == Running(4,[128,64],[])
                                                                                 else if id == 3 then state == Running(5,[],Store([],64,128))
                                                                                 else if id == 4 then state == Running(6,[value],Store([],64,128))
                                                                                 else if id == 5 then state == Running(7,[value,value],Store([],64,128))
                                                                                 else if id == 6 then state == Running(8,[value,1],Store([],64,128))
                                                                                 else if id == 7 then state == Running(11,[value,1,15],Store([],64,128))
                                                                                 else if id == 8 then state == Running(15,[value],Store([],64,128))
                                                                                 else if id == 9 then state == Running(16,[value],Store([],64,128))
                                                                                 else if id == 10 then state == Running(17,[],Store([],64,128))
                                                                                 else if id == 11 then state == Running(19,[4],Store([],64,128))
                                                                                 else if id == 12 then state == Running(20,[4,|data|],Store([],64,128))
                                                                                 else if id == 13 then state == Running(21,[0],Store([],64,128))
                                                                                 else if id == 14 then state == Running(24,[0,454],Store([],64,128))
                                                                                 else if id == 15 then state == Running(25,[],Store([],64,128))
                                                                                 else if id == 16 then state == Running(26,[0],Store([],64,128))
                                                                                 else if id == 17 then state == Running(27,[DataWord(data,0)],Store([],64,128))
                                                                                 else if id == 18 then state == Running(29,[DataWord(data,0),224],Store([],64,128))
                                                                                 else if id == 19 then state == Running(30,[2005396296],Store([],64,128))
                                                                                 else if id == 20 then state == Running(31,[2005396296,2005396296],Store([],64,128))
                                                                                 else if id == 21 then state == Running(36,[2005396296,2005396296,2368205965],Store([],64,128))
                                                                                 else if id == 22 then state == Running(37,[2005396296,1],Store([],64,128))
                                                                                 else if id == 23 then state == Running(40,[2005396296,1,254],Store([],64,128))
                                                                                 else if id == 24 then state == Running(254,[2005396296],Store([],64,128))
                                                                                 else if id == 25 then state == Running(255,[2005396296],Store([],64,128))
                                                                                 else if id == 26 then state == Running(256,[2005396296,2005396296],Store([],64,128))
                                                                                 else if id == 27 then state == Running(261,[2005396296,2005396296,961624077],Store([],64,128))
                                                                                 else if id == 28 then state == Running(262,[2005396296,0],Store([],64,128))
                                                                                 else if id == 29 then state == Running(265,[2005396296,0,361],Store([],64,128))
                                                                                 else if id == 30 then state == Running(266,[2005396296],Store([],64,128))
                                                                                 else if id == 31 then state == Running(267,[2005396296,2005396296],Store([],64,128))
                                                                                 else if id == 32 then state == Running(272,[2005396296,2005396296,1831135132],Store([],64,128))
                                                                                 else if id == 33 then state == Running(273,[2005396296,0],Store([],64,128))
                                                                                 else if id == 34 then state == Running(276,[2005396296,0,324],Store([],64,128))
                                                                                 else if id == 35 then state == Running(277,[2005396296],Store([],64,128))
                                                                                 else if id == 36 then state == Running(278,[2005396296,2005396296],Store([],64,128))
                                                                                 else if id == 37 then state == Running(283,[2005396296,2005396296,1831135132],Store([],64,128))
                                                                                 else if id == 38 then state == Running(284,[2005396296,0],Store([],64,128))
                                                                                 else if id == 39 then state == Running(287,[2005396296,0,713],Store([],64,128))
                                                                                 else if id == 40 then state == Running(288,[2005396296],Store([],64,128))
                                                                                 else if id == 41 then state == Running(289,[2005396296,2005396296],Store([],64,128))
                                                                                 else if id == 42 then state == Running(294,[2005396296,2005396296,1843793072],Store([],64,128))
                                                                                 else if id == 43 then state == Running(295,[2005396296,0],Store([],64,128))
                                                                                 else if id == 44 then state == Running(298,[2005396296,0,732],Store([],64,128))
                                                                                 else if id == 45 then state == Running(299,[2005396296],Store([],64,128))
                                                                                 else if id == 46 then state == Running(300,[2005396296,2005396296],Store([],64,128))
                                                                                 else if id == 47 then state == Running(305,[2005396296,2005396296,1963819735],Store([],64,128))
                                                                                 else if id == 48 then state == Running(306,[2005396296,0],Store([],64,128))
                                                                                 else if id == 49 then state == Running(309,[2005396296,0,751],Store([],64,128))
                                                                                 else if id == 50 then state == Running(310,[2005396296],Store([],64,128))
                                                                                 else if id == 51 then state == Running(311,[2005396296,2005396296],Store([],64,128))
                                                                                 else if id == 52 then state == Running(316,[2005396296,2005396296,2005396296],Store([],64,128))
                                                                                 else if id == 53 then state == Running(317,[2005396296,1],Store([],64,128))
                                                                                 else if id == 54 then state == Running(320,[2005396296,1,770],Store([],64,128))
                                                                                 else false) }
  lemma LoadedSelector(data: seq<Byte>)
    requires SelectorAdmitted(data)
    ensures ShiftRight(DataWord(data,0),224) == 2005396296
  { reveal SelectorAdmitted(); }
  lemma Advance0(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(0,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(0,[],[]);
    F.Push1(code,0);
    assert Fetch(code,0) == Op(96,2,128);
  }
  lemma Advance1(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(1,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(2,[128],[]);
    F.Push1(code,2);
    assert Fetch(code,2) == Op(96,4,64);
  }
  lemma Advance2(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(2,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(4,[128,64],[]);
    assert Fetch(code,4) == Op(82,5,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(3,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(5,[],Store([],64,128));
    assert Fetch(code,5) == Op(52,6,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(4,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(6,[value],Store([],64,128));
    assert Fetch(code,6) == Op(128,7,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(5,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(7,[value,value],Store([],64,128));
    assert Fetch(code,7) == Op(21,8,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(6,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(8,[value,1],Store([],64,128));
    F.Push2(code,8);
    assert Fetch(code,8) == Op(97,11,15);
  }
  lemma Advance7(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(7,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(11,[value,1,15],Store([],64,128));
    assert Fetch(code,11) == Op(87,12,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(8,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(15,[value],Store([],64,128));
    assert Fetch(code,15) == Op(91,16,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(9,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(16,[value],Store([],64,128));
    assert Fetch(code,16) == Op(80,17,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(10,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(17,[],Store([],64,128));
    F.Push1(code,17);
    assert Fetch(code,17) == Op(96,19,4);
  }
  lemma Advance11(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(11,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(19,[4],Store([],64,128));
    assert Fetch(code,19) == Op(54,20,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(12,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(20,[4,|data|],Store([],64,128));
    assert Fetch(code,20) == Op(16,21,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(13,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(21,[0],Store([],64,128));
    F.Push2(code,21);
    assert Fetch(code,21) == Op(97,24,454);
  }
  lemma Advance14(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(14,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(24,[0,454],Store([],64,128));
    assert Fetch(code,24) == Op(87,25,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(15,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(25,[],Store([],64,128));
    assert Fetch(code,25) == Op(95,26,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(16,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(26,[0],Store([],64,128));
    assert Fetch(code,26) == Op(53,27,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(17,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(27,[DataWord(data,0)],Store([],64,128));
    F.Push1(code,27);
    assert Fetch(code,27) == Op(96,29,224);
  }
  lemma Advance18(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(18,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,value,data)
  {
    reveal Matches(); reveal Good();
    hide ShiftRight(); hide DataWord();
    assert state == Running(29,[DataWord(data,0),224],Store([],64,128));
    LoadedSelector(data);
    K.Loaded(code,Destinations(),state,Store([],64,128),value,data,2005396296);
    assert Fetch(code,29) == Op(28,30,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(19,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(30,[2005396296],Store([],64,128));
    assert Fetch(code,30) == Op(128,31,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(20,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(31,[2005396296,2005396296],Store([],64,128));
    P.Push4(code,31);
    assert Fetch(code,31) == Op(99,36,2368205965);
  }
  lemma Advance21(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(21,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(36,[2005396296,2005396296,2368205965],Store([],64,128));
    assert Fetch(code,36) == Op(17,37,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(22,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(37,[2005396296,1],Store([],64,128));
    F.Push2(code,37);
    assert Fetch(code,37) == Op(97,40,254);
  }
  lemma Advance23(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(23,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(40,[2005396296,1,254],Store([],64,128));
    assert Fetch(code,40) == Op(87,41,0);
  }
  lemma Advance24(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(24,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(254,[2005396296],Store([],64,128));
    assert Fetch(code,254) == Op(91,255,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(25,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(255,[2005396296],Store([],64,128));
    assert Fetch(code,255) == Op(128,256,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(26,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(256,[2005396296,2005396296],Store([],64,128));
    P.Push4(code,256);
    assert Fetch(code,256) == Op(99,261,961624077);
  }
  lemma Advance27(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(27,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(261,[2005396296,2005396296,961624077],Store([],64,128));
    assert Fetch(code,261) == Op(17,262,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(28,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(262,[2005396296,0],Store([],64,128));
    F.Push2(code,262);
    assert Fetch(code,262) == Op(97,265,361);
  }
  lemma Advance29(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(29,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(265,[2005396296,0,361],Store([],64,128));
    assert Fetch(code,265) == Op(87,266,0);
  }
  lemma Advance30(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(30,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(266,[2005396296],Store([],64,128));
    assert Fetch(code,266) == Op(128,267,0);
  }
  lemma Advance31(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(31,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(32,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(267,[2005396296,2005396296],Store([],64,128));
    P.Push4(code,267);
    assert Fetch(code,267) == Op(99,272,1831135132);
  }
  lemma Advance32(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(32,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(33,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(272,[2005396296,2005396296,1831135132],Store([],64,128));
    assert Fetch(code,272) == Op(17,273,0);
  }
  lemma Advance33(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(33,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(34,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(273,[2005396296,0],Store([],64,128));
    F.Push2(code,273);
    assert Fetch(code,273) == Op(97,276,324);
  }
  lemma Advance34(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(34,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(35,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(276,[2005396296,0,324],Store([],64,128));
    assert Fetch(code,276) == Op(87,277,0);
  }
  lemma Advance35(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(35,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(36,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(277,[2005396296],Store([],64,128));
    assert Fetch(code,277) == Op(128,278,0);
  }
  lemma Advance36(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(36,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(37,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(278,[2005396296,2005396296],Store([],64,128));
    P.Push4(code,278);
    assert Fetch(code,278) == Op(99,283,1831135132);
  }
  lemma Advance37(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(37,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(38,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(283,[2005396296,2005396296,1831135132],Store([],64,128));
    assert Fetch(code,283) == Op(20,284,0);
  }
  lemma Advance38(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(38,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(39,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(284,[2005396296,0],Store([],64,128));
    F.Push2(code,284);
    assert Fetch(code,284) == Op(97,287,713);
  }
  lemma Advance39(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(39,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(40,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(287,[2005396296,0,713],Store([],64,128));
    assert Fetch(code,287) == Op(87,288,0);
  }
  lemma Advance40(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(40,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(41,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(288,[2005396296],Store([],64,128));
    assert Fetch(code,288) == Op(128,289,0);
  }
  lemma Advance41(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(41,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(42,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(289,[2005396296,2005396296],Store([],64,128));
    P.Push4(code,289);
    assert Fetch(code,289) == Op(99,294,1843793072);
  }
  lemma Advance42(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(42,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(43,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(294,[2005396296,2005396296,1843793072],Store([],64,128));
    assert Fetch(code,294) == Op(20,295,0);
  }
  lemma Advance43(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(43,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(44,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(295,[2005396296,0],Store([],64,128));
    F.Push2(code,295);
    assert Fetch(code,295) == Op(97,298,732);
  }
  lemma Advance44(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(44,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(45,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(298,[2005396296,0,732],Store([],64,128));
    assert Fetch(code,298) == Op(87,299,0);
  }
  lemma Advance45(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(45,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(46,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(299,[2005396296],Store([],64,128));
    assert Fetch(code,299) == Op(128,300,0);
  }
  lemma Advance46(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(46,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(47,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(300,[2005396296,2005396296],Store([],64,128));
    P.Push4(code,300);
    assert Fetch(code,300) == Op(99,305,1963819735);
  }
  lemma Advance47(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(47,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(48,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(305,[2005396296,2005396296,1963819735],Store([],64,128));
    assert Fetch(code,305) == Op(20,306,0);
  }
  lemma Advance48(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(48,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(49,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(306,[2005396296,0],Store([],64,128));
    F.Push2(code,306);
    assert Fetch(code,306) == Op(97,309,751);
  }
  lemma Advance49(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(49,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(50,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(309,[2005396296,0,751],Store([],64,128));
    assert Fetch(code,309) == Op(87,310,0);
  }
  lemma Advance50(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(50,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(51,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(310,[2005396296],Store([],64,128));
    assert Fetch(code,310) == Op(128,311,0);
  }
  lemma Advance51(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(51,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(52,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(311,[2005396296,2005396296],Store([],64,128));
    P.Push4(code,311);
    assert Fetch(code,311) == Op(99,316,2005396296);
  }
  lemma Advance52(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(52,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(53,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(316,[2005396296,2005396296,2005396296],Store([],64,128));
    assert Fetch(code,316) == Op(20,317,0);
  }
  lemma Advance53(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(53,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(54,next,value,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(317,[2005396296,1],Store([],64,128));
    F.Push2(code,317);
    assert Fetch(code,317) == Op(97,320,770);
  }
  lemma Advance54(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(54,state,value,data)
    ensures state.Running? && |state.stack| <= 3 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(770,[2005396296],Store([],64,128))
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(320,[2005396296,1,770],Store([],64,128));
    assert Fetch(code,320) == Op(87,321,0);
  }
  lemma Start(value: Word, data: seq<Byte>)
    requires Admitted(value,data)
    ensures Good(0,Running(0,[],[]),value,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(value,data)
    ensures state == Running(770,[2005396296],Store([],64,128))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 56 && trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
  {
    Start(value,data);
    state := Running(0,[],[]);
    trace := [state];
    Advance0(code,state,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(0,[],[]);
    state := next0;
    Advance1(code,state,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(0,[],[]);
    state := next1;
    Advance2(code,state,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(0,[],[]);
    state := next2;
    Advance3(code,state,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(0,[],[]);
    state := next3;
    Advance4(code,state,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(0,[],[]);
    state := next4;
    Advance5(code,state,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(0,[],[]);
    state := next5;
    Advance6(code,state,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(0,[],[]);
    state := next6;
    Advance7(code,state,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(0,[],[]);
    state := next7;
    Advance8(code,state,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(0,[],[]);
    state := next8;
    Advance9(code,state,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(0,[],[]);
    state := next9;
    Advance10(code,state,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(0,[],[]);
    state := next10;
    Advance11(code,state,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(0,[],[]);
    state := next11;
    Advance12(code,state,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(0,[],[]);
    state := next12;
    Advance13(code,state,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(0,[],[]);
    state := next13;
    Advance14(code,state,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(0,[],[]);
    state := next14;
    Advance15(code,state,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(0,[],[]);
    state := next15;
    Advance16(code,state,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(0,[],[]);
    state := next16;
    Advance17(code,state,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(0,[],[]);
    state := next17;
    Advance18(code,state,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(0,[],[]);
    state := next18;
    Advance19(code,state,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(0,[],[]);
    state := next19;
    Advance20(code,state,value,data);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    assert trace[0] == Running(0,[],[]);
    state := next20;
    Advance21(code,state,value,data);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    assert trace[0] == Running(0,[],[]);
    state := next21;
    Advance22(code,state,value,data);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22];
    assert trace[0] == Running(0,[],[]);
    state := next22;
    Advance23(code,state,value,data);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23];
    assert trace[0] == Running(0,[],[]);
    state := next23;
    Advance24(code,state,value,data);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24];
    assert trace[0] == Running(0,[],[]);
    state := next24;
    Advance25(code,state,value,data);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25];
    assert trace[0] == Running(0,[],[]);
    state := next25;
    Advance26(code,state,value,data);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26];
    assert trace[0] == Running(0,[],[]);
    state := next26;
    Advance27(code,state,value,data);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27];
    assert trace[0] == Running(0,[],[]);
    state := next27;
    Advance28(code,state,value,data);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28];
    assert trace[0] == Running(0,[],[]);
    state := next28;
    Advance29(code,state,value,data);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);
    trace := trace+[next29];
    assert trace[0] == Running(0,[],[]);
    state := next29;
    Advance30(code,state,value,data);
    var next30 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30);
    trace := trace+[next30];
    assert trace[0] == Running(0,[],[]);
    state := next30;
    Advance31(code,state,value,data);
    var next31 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31);
    trace := trace+[next31];
    assert trace[0] == Running(0,[],[]);
    state := next31;
    Advance32(code,state,value,data);
    var next32 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next32);
    trace := trace+[next32];
    assert trace[0] == Running(0,[],[]);
    state := next32;
    Advance33(code,state,value,data);
    var next33 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next33);
    trace := trace+[next33];
    assert trace[0] == Running(0,[],[]);
    state := next33;
    Advance34(code,state,value,data);
    var next34 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next34);
    trace := trace+[next34];
    assert trace[0] == Running(0,[],[]);
    state := next34;
    Advance35(code,state,value,data);
    var next35 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next35);
    trace := trace+[next35];
    assert trace[0] == Running(0,[],[]);
    state := next35;
    Advance36(code,state,value,data);
    var next36 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next36);
    trace := trace+[next36];
    assert trace[0] == Running(0,[],[]);
    state := next36;
    Advance37(code,state,value,data);
    var next37 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next37);
    trace := trace+[next37];
    assert trace[0] == Running(0,[],[]);
    state := next37;
    Advance38(code,state,value,data);
    var next38 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next38);
    trace := trace+[next38];
    assert trace[0] == Running(0,[],[]);
    state := next38;
    Advance39(code,state,value,data);
    var next39 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next39);
    trace := trace+[next39];
    assert trace[0] == Running(0,[],[]);
    state := next39;
    Advance40(code,state,value,data);
    var next40 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next40);
    trace := trace+[next40];
    assert trace[0] == Running(0,[],[]);
    state := next40;
    Advance41(code,state,value,data);
    var next41 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next41);
    trace := trace+[next41];
    assert trace[0] == Running(0,[],[]);
    state := next41;
    Advance42(code,state,value,data);
    var next42 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next42);
    trace := trace+[next42];
    assert trace[0] == Running(0,[],[]);
    state := next42;
    Advance43(code,state,value,data);
    var next43 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next43);
    trace := trace+[next43];
    assert trace[0] == Running(0,[],[]);
    state := next43;
    Advance44(code,state,value,data);
    var next44 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next44);
    trace := trace+[next44];
    assert trace[0] == Running(0,[],[]);
    state := next44;
    Advance45(code,state,value,data);
    var next45 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next45);
    trace := trace+[next45];
    assert trace[0] == Running(0,[],[]);
    state := next45;
    Advance46(code,state,value,data);
    var next46 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next46);
    trace := trace+[next46];
    assert trace[0] == Running(0,[],[]);
    state := next46;
    Advance47(code,state,value,data);
    var next47 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next47);
    trace := trace+[next47];
    assert trace[0] == Running(0,[],[]);
    state := next47;
    Advance48(code,state,value,data);
    var next48 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next48);
    trace := trace+[next48];
    assert trace[0] == Running(0,[],[]);
    state := next48;
    Advance49(code,state,value,data);
    var next49 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next49);
    trace := trace+[next49];
    assert trace[0] == Running(0,[],[]);
    state := next49;
    Advance50(code,state,value,data);
    var next50 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next50);
    trace := trace+[next50];
    assert trace[0] == Running(0,[],[]);
    state := next50;
    Advance51(code,state,value,data);
    var next51 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next51);
    trace := trace+[next51];
    assert trace[0] == Running(0,[],[]);
    state := next51;
    Advance52(code,state,value,data);
    var next52 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next52);
    trace := trace+[next52];
    assert trace[0] == Running(0,[],[]);
    state := next52;
    Advance53(code,state,value,data);
    var next53 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next53);
    trace := trace+[next53];
    assert trace[0] == Running(0,[],[]);
    state := next53;
    Advance54(code,state,value,data);
    var next54 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next54);
    trace := trace+[next54];
    assert trace[0] == Running(0,[],[]);
    state := next54;
  }
}
