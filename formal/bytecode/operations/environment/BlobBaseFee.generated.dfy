// SPDX-License-Identifier: MIT
// Generated exact executed-byte certificate. Never edit directly.
include "Machine.dfy"
module OperationsEnvironmentBlobBaseFee {
  import opened OperationsEnvironmentMachine
  function Result(world: World): Word { world.blobBaseFee }
  predicate Admitted(value: Word, size: Word, word: Word, world: World) {
    value == 0 && 4 <= size < 0x10000000000000000 && Selector(word) == 4162871616
  }
  opaque predicate Matches(code: seq<Byte>) {
    |code| == 21346 &&
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
    code[22] == 4 &&
    code[23] == 242 &&
    code[24] == 87 &&
    code[25] == 95 &&
    code[26] == 53 &&
    code[27] == 96 &&
    code[28] == 224 &&
    code[29] == 28 &&
    code[30] == 128 &&
    code[31] == 99 &&
    code[32] == 129 &&
    code[33] == 254 &&
    code[34] == 87 &&
    code[35] == 134 &&
    code[36] == 17 &&
    code[37] == 97 &&
    code[38] == 2 &&
    code[39] == 143 &&
    code[40] == 87 &&
    code[41] == 128 &&
    code[42] == 99 &&
    code[43] == 177 &&
    code[44] == 47 &&
    code[45] == 232 &&
    code[46] == 38 &&
    code[47] == 17 &&
    code[48] == 97 &&
    code[49] == 1 &&
    code[50] == 97 &&
    code[51] == 87 &&
    code[52] == 128 &&
    code[53] == 99 &&
    code[54] == 222 &&
    code[55] == 194 &&
    code[56] == 140 &&
    code[57] == 91 &&
    code[58] == 17 &&
    code[59] == 97 &&
    code[60] == 0 &&
    code[61] == 213 &&
    code[62] == 87 &&
    code[63] == 128 &&
    code[64] == 99 &&
    code[65] == 246 &&
    code[66] == 128 &&
    code[67] == 22 &&
    code[68] == 183 &&
    code[69] == 17 &&
    code[70] == 97 &&
    code[71] == 0 &&
    code[72] == 143 &&
    code[73] == 87 &&
    code[74] == 128 &&
    code[75] == 99 &&
    code[76] == 246 &&
    code[77] == 128 &&
    code[78] == 22 &&
    code[79] == 183 &&
    code[80] == 20 &&
    code[81] == 97 &&
    code[82] == 11 &&
    code[83] == 99 &&
    code[84] == 87 &&
    code[85] == 128 &&
    code[86] == 99 &&
    code[87] == 248 &&
    code[88] == 32 &&
    code[89] == 97 &&
    code[90] == 64 &&
    code[91] == 20 &&
    code[92] == 97 &&
    code[93] == 11 &&
    code[94] == 105 &&
    code[95] == 87 &&
    code[143] == 91 &&
    code[213] == 91 &&
    code[353] == 91 &&
    code[655] == 91 &&
    code[1266] == 91 &&
    code[1301] == 91 &&
    code[1302] == 96 &&
    code[1303] == 64 &&
    code[1304] == 81 &&
    code[1305] == 128 &&
    code[1306] == 145 &&
    code[1307] == 3 &&
    code[1308] == 144 &&
    code[1309] == 243 &&
    code[1329] == 91 &&
    code[1330] == 96 &&
    code[1331] == 64 &&
    code[1332] == 81 &&
    code[1333] == 144 &&
    code[1334] == 129 &&
    code[1335] == 82 &&
    code[1336] == 96 &&
    code[1337] == 32 &&
    code[1338] == 1 &&
    code[1339] == 97 &&
    code[1340] == 5 &&
    code[1341] == 21 &&
    code[1342] == 86 &&
    code[2915] == 91 &&
    code[2921] == 91 &&
    code[2922] == 74 &&
    code[2923] == 97 &&
    code[2924] == 5 &&
    code[2925] == 49 &&
    code[2926] == 86
  }
  function Destinations(): set<nat> { {15,143,213,353,655,1266,1301,1329,2915,2921} }
  opaque predicate Good(id: nat, state: State, value: Word, size: Word, word: Word, world: World) {
    if id == 0 then state == Running(0,[],[])
    else if id == 1 then state == Running(2,[128],[])
    else if id == 2 then state == Running(4,[128,64],[])
    else if id == 3 then state == Running(5,[],Store([],64,128))
    else if id == 4 then state == Running(6,[value],Store([],64,128))
    else if id == 5 then state == Running(7,[value,value],Store([],64,128))
    else if id == 6 then state == Running(8,[value,(if value == 0 then 1 else 0)],Store([],64,128))
    else if id == 7 then state == Running(11,[value,(if value == 0 then 1 else 0),15],Store([],64,128))
    else if id == 8 then state == Running(15,[value],Store([],64,128))
    else if id == 9 then state == Running(16,[value],Store([],64,128))
    else if id == 10 then state == Running(17,[],Store([],64,128))
    else if id == 11 then state == Running(19,[4],Store([],64,128))
    else if id == 12 then state == Running(20,[4,size],Store([],64,128))
    else if id == 13 then state == Running(21,[(if (size) < (4) then 1 else 0)],Store([],64,128))
    else if id == 14 then state == Running(24,[(if (size) < (4) then 1 else 0),1266],Store([],64,128))
    else if id == 15 then state == Running(25,[],Store([],64,128))
    else if id == 16 then state == Running(26,[0],Store([],64,128))
    else if id == 17 then state == Running(27,[word],Store([],64,128))
    else if id == 18 then state == Running(29,[word,224],Store([],64,128))
    else if id == 19 then state == Running(30,[4162871616],Store([],64,128))
    else if id == 20 then state == Running(31,[4162871616,4162871616],Store([],64,128))
    else if id == 21 then state == Running(36,[4162871616,4162871616,2180929414],Store([],64,128))
    else if id == 22 then state == Running(37,[4162871616,0],Store([],64,128))
    else if id == 23 then state == Running(40,[4162871616,0,655],Store([],64,128))
    else if id == 24 then state == Running(41,[4162871616],Store([],64,128))
    else if id == 25 then state == Running(42,[4162871616,4162871616],Store([],64,128))
    else if id == 26 then state == Running(47,[4162871616,4162871616,2972706854],Store([],64,128))
    else if id == 27 then state == Running(48,[4162871616,0],Store([],64,128))
    else if id == 28 then state == Running(51,[4162871616,0,353],Store([],64,128))
    else if id == 29 then state == Running(52,[4162871616],Store([],64,128))
    else if id == 30 then state == Running(53,[4162871616,4162871616],Store([],64,128))
    else if id == 31 then state == Running(58,[4162871616,4162871616,3737291867],Store([],64,128))
    else if id == 32 then state == Running(59,[4162871616,0],Store([],64,128))
    else if id == 33 then state == Running(62,[4162871616,0,213],Store([],64,128))
    else if id == 34 then state == Running(63,[4162871616],Store([],64,128))
    else if id == 35 then state == Running(64,[4162871616,4162871616],Store([],64,128))
    else if id == 36 then state == Running(69,[4162871616,4162871616,4135589559],Store([],64,128))
    else if id == 37 then state == Running(70,[4162871616,0],Store([],64,128))
    else if id == 38 then state == Running(73,[4162871616,0,143],Store([],64,128))
    else if id == 39 then state == Running(74,[4162871616],Store([],64,128))
    else if id == 40 then state == Running(75,[4162871616,4162871616],Store([],64,128))
    else if id == 41 then state == Running(80,[4162871616,4162871616,4135589559],Store([],64,128))
    else if id == 42 then state == Running(81,[4162871616,0],Store([],64,128))
    else if id == 43 then state == Running(84,[4162871616,0,2915],Store([],64,128))
    else if id == 44 then state == Running(85,[4162871616],Store([],64,128))
    else if id == 45 then state == Running(86,[4162871616,4162871616],Store([],64,128))
    else if id == 46 then state == Running(91,[4162871616,4162871616,4162871616],Store([],64,128))
    else if id == 47 then state == Running(92,[4162871616,1],Store([],64,128))
    else if id == 48 then state == Running(95,[4162871616,1,2921],Store([],64,128))
    else if id == 49 then state == Running(2921,[4162871616],Store([],64,128))
    else if id == 50 then state == Running(2922,[4162871616],Store([],64,128))
    else if id == 51 then state == Running(2923,[4162871616,Observe(world,74)],Store([],64,128))
    else if id == 52 then state == Running(2926,[4162871616,Observe(world,74),1329],Store([],64,128))
    else if id == 53 then state == Running(1329,[4162871616,Observe(world,74)],Store([],64,128))
    else if id == 54 then state == Running(1330,[4162871616,Observe(world,74)],Store([],64,128))
    else if id == 55 then state == Running(1332,[4162871616,Observe(world,74),64],Store([],64,128))
    else if id == 56 then state == Running(1333,[4162871616,Observe(world,74),128],Store([],64,128))
    else if id == 57 then state == Running(1334,[4162871616,128,Observe(world,74)],Store([],64,128))
    else if id == 58 then state == Running(1335,[4162871616,128,Observe(world,74),128],Store([],64,128))
    else if id == 59 then state == Running(1336,[4162871616,128],Store(Store([],64,128),128,Observe(world,74)))
    else if id == 60 then state == Running(1338,[4162871616,128,32],Store(Store([],64,128),128,Observe(world,74)))
    else if id == 61 then state == Running(1339,[4162871616,160],Store(Store([],64,128),128,Observe(world,74)))
    else if id == 62 then state == Running(1342,[4162871616,160,1301],Store(Store([],64,128),128,Observe(world,74)))
    else if id == 63 then state == Running(1301,[4162871616,160],Store(Store([],64,128),128,Observe(world,74)))
    else if id == 64 then state == Running(1302,[4162871616,160],Store(Store([],64,128),128,Observe(world,74)))
    else if id == 65 then state == Running(1304,[4162871616,160,64],Store(Store([],64,128),128,Observe(world,74)))
    else if id == 66 then state == Running(1305,[4162871616,160,128],Store(Store([],64,128),128,Observe(world,74)))
    else if id == 67 then state == Running(1306,[4162871616,160,128,128],Store(Store([],64,128),128,Observe(world,74)))
    else if id == 68 then state == Running(1307,[4162871616,128,128,160],Store(Store([],64,128),128,Observe(world,74)))
    else if id == 69 then state == Running(1308,[4162871616,128,32],Store(Store([],64,128),128,Observe(world,74)))
    else if id == 70 then state == Running(1309,[4162871616,32,128],Store(Store([],64,128),128,Observe(world,74)))
    else false
  }
  lemma Advance0(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(0,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(1,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(0,[],[]);
    assert Fetch(code,0) == Op(96,2,128);
  }
  lemma Advance1(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(1,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(2,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2,[128],[]);
    assert Fetch(code,2) == Op(96,4,64);
  }
  lemma Advance2(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(2,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(3,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(4,[128,64],[]);
    assert Fetch(code,4) == Op(82,5,0);
    StoreLoad([],64,128);
  }
  lemma Advance3(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(3,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(4,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(5,[],Store([],64,128));
    assert Fetch(code,5) == Op(52,6,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(4,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(5,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(6,[value],Store([],64,128));
    assert Fetch(code,6) == Op(128,7,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(5,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(6,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(7,[value,value],Store([],64,128));
    assert Fetch(code,7) == Op(21,8,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(6,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(7,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8,[value,(if value == 0 then 1 else 0)],Store([],64,128));
    assert Fetch(code,8) == Op(97,11,15);
  }
  lemma Advance7(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(7,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(8,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(11,[value,(if value == 0 then 1 else 0),15],Store([],64,128));
    assert Fetch(code,11) == Op(87,12,0);
    assert 15 in Destinations() && code[15] == 91;
  }
  lemma Advance8(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(8,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(9,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(15,[value],Store([],64,128));
    assert Fetch(code,15) == Op(91,16,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(9,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(10,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(16,[value],Store([],64,128));
    assert Fetch(code,16) == Op(80,17,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(10,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(11,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17,[],Store([],64,128));
    assert Fetch(code,17) == Op(96,19,4);
  }
  lemma Advance11(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(11,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(12,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19,[4],Store([],64,128));
    assert Fetch(code,19) == Op(54,20,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(12,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(13,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(20,[4,size],Store([],64,128));
    assert Fetch(code,20) == Op(16,21,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(13,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(14,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(21,[(if (size) < (4) then 1 else 0)],Store([],64,128));
    assert Fetch(code,21) == Op(97,24,1266);
  }
  lemma Advance14(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(14,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(15,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(24,[(if (size) < (4) then 1 else 0),1266],Store([],64,128));
    assert Fetch(code,24) == Op(87,25,0);
    assert 1266 in Destinations() && code[1266] == 91;
  }
  lemma Advance15(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(15,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(16,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(25,[],Store([],64,128));
    assert Fetch(code,25) == Op(95,26,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(16,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(17,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(26,[0],Store([],64,128));
    assert Fetch(code,26) == Op(53,27,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(17,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(18,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(27,[word],Store([],64,128));
    assert Fetch(code,27) == Op(96,29,224);
  }
  lemma Advance18(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(18,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(19,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(29,[word,224],Store([],64,128));
    assert Fetch(code,29) == Op(28,30,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(19,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(20,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(30,[4162871616],Store([],64,128));
    assert Fetch(code,30) == Op(128,31,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(20,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(21,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(31,[4162871616,4162871616],Store([],64,128));
    assert Fetch(code,31) == Op(99,36,2180929414);
  }
  lemma Advance21(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(21,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(22,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(36,[4162871616,4162871616,2180929414],Store([],64,128));
    assert Fetch(code,36) == Op(17,37,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(22,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(23,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(37,[4162871616,0],Store([],64,128));
    assert Fetch(code,37) == Op(97,40,655);
  }
  lemma Advance23(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(23,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(24,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(40,[4162871616,0,655],Store([],64,128));
    assert Fetch(code,40) == Op(87,41,0);
    assert 655 in Destinations() && code[655] == 91;
  }
  lemma Advance24(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(24,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(25,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(41,[4162871616],Store([],64,128));
    assert Fetch(code,41) == Op(128,42,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(25,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(26,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(42,[4162871616,4162871616],Store([],64,128));
    assert Fetch(code,42) == Op(99,47,2972706854);
  }
  lemma Advance26(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(26,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(27,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(47,[4162871616,4162871616,2972706854],Store([],64,128));
    assert Fetch(code,47) == Op(17,48,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(27,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(28,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(48,[4162871616,0],Store([],64,128));
    assert Fetch(code,48) == Op(97,51,353);
  }
  lemma Advance28(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(28,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(29,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(51,[4162871616,0,353],Store([],64,128));
    assert Fetch(code,51) == Op(87,52,0);
    assert 353 in Destinations() && code[353] == 91;
  }
  lemma Advance29(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(29,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(30,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(52,[4162871616],Store([],64,128));
    assert Fetch(code,52) == Op(128,53,0);
  }
  lemma Advance30(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(30,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(31,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(53,[4162871616,4162871616],Store([],64,128));
    assert Fetch(code,53) == Op(99,58,3737291867);
  }
  lemma Advance31(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(31,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(32,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(58,[4162871616,4162871616,3737291867],Store([],64,128));
    assert Fetch(code,58) == Op(17,59,0);
  }
  lemma Advance32(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(32,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(33,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(59,[4162871616,0],Store([],64,128));
    assert Fetch(code,59) == Op(97,62,213);
  }
  lemma Advance33(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(33,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(34,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(62,[4162871616,0,213],Store([],64,128));
    assert Fetch(code,62) == Op(87,63,0);
    assert 213 in Destinations() && code[213] == 91;
  }
  lemma Advance34(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(34,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(35,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(63,[4162871616],Store([],64,128));
    assert Fetch(code,63) == Op(128,64,0);
  }
  lemma Advance35(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(35,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(36,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(64,[4162871616,4162871616],Store([],64,128));
    assert Fetch(code,64) == Op(99,69,4135589559);
  }
  lemma Advance36(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(36,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(37,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(69,[4162871616,4162871616,4135589559],Store([],64,128));
    assert Fetch(code,69) == Op(17,70,0);
  }
  lemma Advance37(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(37,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(38,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(70,[4162871616,0],Store([],64,128));
    assert Fetch(code,70) == Op(97,73,143);
  }
  lemma Advance38(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(38,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(39,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(73,[4162871616,0,143],Store([],64,128));
    assert Fetch(code,73) == Op(87,74,0);
    assert 143 in Destinations() && code[143] == 91;
  }
  lemma Advance39(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(39,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(40,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(74,[4162871616],Store([],64,128));
    assert Fetch(code,74) == Op(128,75,0);
  }
  lemma Advance40(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(40,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(41,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(75,[4162871616,4162871616],Store([],64,128));
    assert Fetch(code,75) == Op(99,80,4135589559);
  }
  lemma Advance41(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(41,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(42,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(80,[4162871616,4162871616,4135589559],Store([],64,128));
    assert Fetch(code,80) == Op(20,81,0);
  }
  lemma Advance42(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(42,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(43,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(81,[4162871616,0],Store([],64,128));
    assert Fetch(code,81) == Op(97,84,2915);
  }
  lemma Advance43(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(43,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(44,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(84,[4162871616,0,2915],Store([],64,128));
    assert Fetch(code,84) == Op(87,85,0);
    assert 2915 in Destinations() && code[2915] == 91;
  }
  lemma Advance44(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(44,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(45,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(85,[4162871616],Store([],64,128));
    assert Fetch(code,85) == Op(128,86,0);
  }
  lemma Advance45(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(45,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(46,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(86,[4162871616,4162871616],Store([],64,128));
    assert Fetch(code,86) == Op(99,91,4162871616);
  }
  lemma Advance46(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(46,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(47,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(91,[4162871616,4162871616,4162871616],Store([],64,128));
    assert Fetch(code,91) == Op(20,92,0);
  }
  lemma Advance47(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(47,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(48,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(92,[4162871616,1],Store([],64,128));
    assert Fetch(code,92) == Op(97,95,2921);
  }
  lemma Advance48(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(48,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(49,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(95,[4162871616,1,2921],Store([],64,128));
    assert Fetch(code,95) == Op(87,96,0);
    assert 2921 in Destinations() && code[2921] == 91;
  }
  lemma Advance49(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(49,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(50,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2921,[4162871616],Store([],64,128));
    assert Fetch(code,2921) == Op(91,2922,0);
  }
  lemma Advance50(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(50,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(51,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2922,[4162871616],Store([],64,128));
    assert Fetch(code,2922) == Op(74,2923,0);
  }
  lemma Advance51(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(51,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(52,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2923,[4162871616,Observe(world,74)],Store([],64,128));
    assert Fetch(code,2923) == Op(97,2926,1329);
  }
  lemma Advance52(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(52,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(53,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2926,[4162871616,Observe(world,74),1329],Store([],64,128));
    assert Fetch(code,2926) == Op(86,2927,0);
    assert 1329 in Destinations() && code[1329] == 91;
  }
  lemma Advance53(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(53,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(54,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1329,[4162871616,Observe(world,74)],Store([],64,128));
    assert Fetch(code,1329) == Op(91,1330,0);
  }
  lemma Advance54(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(54,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(55,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1330,[4162871616,Observe(world,74)],Store([],64,128));
    assert Fetch(code,1330) == Op(96,1332,64);
  }
  lemma Advance55(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(55,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(56,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1332,[4162871616,Observe(world,74),64],Store([],64,128));
    assert Fetch(code,1332) == Op(81,1333,0);
    StoreLoad([],64,128);
  }
  lemma Advance56(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(56,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(57,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1333,[4162871616,Observe(world,74),128],Store([],64,128));
    assert Fetch(code,1333) == Op(144,1334,0);
  }
  lemma Advance57(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(57,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(58,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1334,[4162871616,128,Observe(world,74)],Store([],64,128));
    assert Fetch(code,1334) == Op(129,1335,0);
  }
  lemma Advance58(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(58,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(59,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1335,[4162871616,128,Observe(world,74),128],Store([],64,128));
    assert Fetch(code,1335) == Op(82,1336,0);
    StoreLoad(Store([],64,128),128,Observe(world,74));
  }
  lemma Advance59(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(59,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(60,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1336,[4162871616,128],Store(Store([],64,128),128,Observe(world,74)));
    assert Fetch(code,1336) == Op(96,1338,32);
  }
  lemma Advance60(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(60,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(61,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1338,[4162871616,128,32],Store(Store([],64,128),128,Observe(world,74)));
    assert Fetch(code,1338) == Op(1,1339,0);
  }
  lemma Advance61(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(61,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(62,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1339,[4162871616,160],Store(Store([],64,128),128,Observe(world,74)));
    assert Fetch(code,1339) == Op(97,1342,1301);
  }
  lemma Advance62(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(62,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(63,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1342,[4162871616,160,1301],Store(Store([],64,128),128,Observe(world,74)));
    assert Fetch(code,1342) == Op(86,1343,0);
    assert 1301 in Destinations() && code[1301] == 91;
  }
  lemma Advance63(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(63,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(64,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1301,[4162871616,160],Store(Store([],64,128),128,Observe(world,74)));
    assert Fetch(code,1301) == Op(91,1302,0);
  }
  lemma Advance64(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(64,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(65,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1302,[4162871616,160],Store(Store([],64,128),128,Observe(world,74)));
    assert Fetch(code,1302) == Op(96,1304,64);
  }
  lemma Advance65(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(65,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(66,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1304,[4162871616,160,64],Store(Store([],64,128),128,Observe(world,74)));
    assert Fetch(code,1304) == Op(81,1305,0);
    StoreLoad([],64,128);
    StoreFrame(Store([],64,128),128,Observe(world,74),64);
  }
  lemma Advance66(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(66,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(67,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1305,[4162871616,160,128],Store(Store([],64,128),128,Observe(world,74)));
    assert Fetch(code,1305) == Op(128,1306,0);
  }
  lemma Advance67(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(67,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(68,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1306,[4162871616,160,128,128],Store(Store([],64,128),128,Observe(world,74)));
    assert Fetch(code,1306) == Op(145,1307,0);
  }
  lemma Advance68(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(68,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(69,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1307,[4162871616,128,128,160],Store(Store([],64,128),128,Observe(world,74)));
    assert Fetch(code,1307) == Op(3,1308,0);
  }
  lemma Advance69(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(69,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(70,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1308,[4162871616,128,32],Store(Store([],64,128),128,Observe(world,74)));
    assert Fetch(code,1308) == Op(144,1309,0);
  }
  lemma Advance70(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(70,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 4 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); next == Returned(Encode(Result(world),32))
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1309,[4162871616,32,128],Store(Store([],64,128),128,Observe(world,74)));
    assert Fetch(code,1309) == Op(243,1310,0);
    StoreLoad(Store([],64,128),128,Observe(world,74));
  }
  lemma Start(value: Word, size: Word, word: Word, world: World)
    ensures Good(0,Running(0,[],[]),value,size,word,world)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, value: Word, size: Word, word: Word, world: World) returns (state: State)
    requires Matches(code) && Admitted(value,size,word,world)
    ensures state == Returned(Encode(Result(world),32))
  {
    Start(value,size,word,world);
    state := Running(0,[],[]);
    Advance0(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance1(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance2(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance3(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance4(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance5(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance6(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance7(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance8(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance9(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance10(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance11(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance12(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance13(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance14(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance15(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance16(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance17(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance18(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance19(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance20(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance21(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance22(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance23(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance24(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance25(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance26(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance27(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance28(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance29(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance30(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance31(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance32(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance33(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance34(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance35(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance36(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance37(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance38(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance39(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance40(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance41(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance42(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance43(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance44(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance45(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance46(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance47(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance48(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance49(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance50(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance51(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance52(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance53(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance54(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance55(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance56(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance57(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance58(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance59(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance60(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance61(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance62(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance63(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance64(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance65(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance66(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance67(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance68(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance69(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance70(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
  }
}
