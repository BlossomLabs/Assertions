// SPDX-License-Identifier: MIT
// Generated exact executed-byte certificate. Never edit directly.
include "../Machine.dfy"
include "../Mask.dfy"
module OperationsAccountEnvironmentRawBalanceBadAddress {
  import opened OperationsAccountEnvironmentMachine
  import Mask = OperationsAccountMask
  function Result(a: Word, world: World): Word { 0 }
  predicate Admitted(value: Word, size: Word, word: Word, a: Word, world: World) {
    value == 0 && 36 <= size < 0x10000000000000000 && a >= Mask.Bound() && Selector(word) == 3822481623
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
    code[143] == 91 &&
    code[144] == 128 &&
    code[145] == 99 &&
    code[146] == 222 &&
    code[147] == 194 &&
    code[148] == 140 &&
    code[149] == 91 &&
    code[150] == 20 &&
    code[151] == 97 &&
    code[152] == 10 &&
    code[153] == 233 &&
    code[154] == 87 &&
    code[155] == 128 &&
    code[156] == 99 &&
    code[157] == 224 &&
    code[158] == 4 &&
    code[159] == 19 &&
    code[160] == 150 &&
    code[161] == 20 &&
    code[162] == 97 &&
    code[163] == 10 &&
    code[164] == 252 &&
    code[165] == 87 &&
    code[166] == 128 &&
    code[167] == 99 &&
    code[168] == 224 &&
    code[169] == 139 &&
    code[170] == 195 &&
    code[171] == 254 &&
    code[172] == 20 &&
    code[173] == 97 &&
    code[174] == 11 &&
    code[175] == 15 &&
    code[176] == 87 &&
    code[177] == 128 &&
    code[178] == 99 &&
    code[179] == 227 &&
    code[180] == 214 &&
    code[181] == 112 &&
    code[182] == 215 &&
    code[183] == 20 &&
    code[184] == 97 &&
    code[185] == 11 &&
    code[186] == 34 &&
    code[187] == 87 &&
    code[213] == 91 &&
    code[353] == 91 &&
    code[655] == 91 &&
    code[1266] == 91 &&
    code[1537] == 91 &&
    code[2793] == 91 &&
    code[2812] == 91 &&
    code[2831] == 91 &&
    code[2850] == 91 &&
    code[2851] == 97 &&
    code[2852] == 5 &&
    code[2853] == 49 &&
    code[2854] == 97 &&
    code[2855] == 11 &&
    code[2856] == 48 &&
    code[2857] == 54 &&
    code[2858] == 96 &&
    code[2859] == 4 &&
    code[2860] == 97 &&
    code[2861] == 75 &&
    code[2862] == 103 &&
    code[2863] == 86 &&
    code[18723] == 91 &&
    code[18724] == 128 &&
    code[18725] == 53 &&
    code[18726] == 96 &&
    code[18727] == 1 &&
    code[18728] == 96 &&
    code[18729] == 1 &&
    code[18730] == 96 &&
    code[18731] == 160 &&
    code[18732] == 27 &&
    code[18733] == 3 &&
    code[18734] == 129 &&
    code[18735] == 22 &&
    code[18736] == 129 &&
    code[18737] == 20 &&
    code[18738] == 97 &&
    code[18739] == 6 &&
    code[18740] == 1 &&
    code[18741] == 87 &&
    code[18742] == 95 &&
    code[18743] == 95 &&
    code[18744] == 253 &&
    code[19303] == 91 &&
    code[19304] == 95 &&
    code[19305] == 96 &&
    code[19306] == 32 &&
    code[19307] == 130 &&
    code[19308] == 132 &&
    code[19309] == 3 &&
    code[19310] == 18 &&
    code[19311] == 21 &&
    code[19312] == 97 &&
    code[19313] == 75 &&
    code[19314] == 119 &&
    code[19315] == 87 &&
    code[19319] == 91 &&
    code[19320] == 97 &&
    code[19321] == 12 &&
    code[19322] == 13 &&
    code[19323] == 130 &&
    code[19324] == 97 &&
    code[19325] == 73 &&
    code[19326] == 35 &&
    code[19327] == 86
  }
  function Destinations(): set<nat> { {15,143,213,353,655,1266,1537,2793,2812,2831,2850,18723,19303,19319} }
  opaque predicate Good(id: nat, state: State, value: Word, size: Word, word: Word, a: Word, world: World) {
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
    else if id == 19 then state == Running(30,[3822481623],Store([],64,128))
    else if id == 20 then state == Running(31,[3822481623,3822481623],Store([],64,128))
    else if id == 21 then state == Running(36,[3822481623,3822481623,2180929414],Store([],64,128))
    else if id == 22 then state == Running(37,[3822481623,0],Store([],64,128))
    else if id == 23 then state == Running(40,[3822481623,0,655],Store([],64,128))
    else if id == 24 then state == Running(41,[3822481623],Store([],64,128))
    else if id == 25 then state == Running(42,[3822481623,3822481623],Store([],64,128))
    else if id == 26 then state == Running(47,[3822481623,3822481623,2972706854],Store([],64,128))
    else if id == 27 then state == Running(48,[3822481623,0],Store([],64,128))
    else if id == 28 then state == Running(51,[3822481623,0,353],Store([],64,128))
    else if id == 29 then state == Running(52,[3822481623],Store([],64,128))
    else if id == 30 then state == Running(53,[3822481623,3822481623],Store([],64,128))
    else if id == 31 then state == Running(58,[3822481623,3822481623,3737291867],Store([],64,128))
    else if id == 32 then state == Running(59,[3822481623,0],Store([],64,128))
    else if id == 33 then state == Running(62,[3822481623,0,213],Store([],64,128))
    else if id == 34 then state == Running(63,[3822481623],Store([],64,128))
    else if id == 35 then state == Running(64,[3822481623,3822481623],Store([],64,128))
    else if id == 36 then state == Running(69,[3822481623,3822481623,4135589559],Store([],64,128))
    else if id == 37 then state == Running(70,[3822481623,1],Store([],64,128))
    else if id == 38 then state == Running(73,[3822481623,1,143],Store([],64,128))
    else if id == 39 then state == Running(143,[3822481623],Store([],64,128))
    else if id == 40 then state == Running(144,[3822481623],Store([],64,128))
    else if id == 41 then state == Running(145,[3822481623,3822481623],Store([],64,128))
    else if id == 42 then state == Running(150,[3822481623,3822481623,3737291867],Store([],64,128))
    else if id == 43 then state == Running(151,[3822481623,0],Store([],64,128))
    else if id == 44 then state == Running(154,[3822481623,0,2793],Store([],64,128))
    else if id == 45 then state == Running(155,[3822481623],Store([],64,128))
    else if id == 46 then state == Running(156,[3822481623,3822481623],Store([],64,128))
    else if id == 47 then state == Running(161,[3822481623,3822481623,3758363542],Store([],64,128))
    else if id == 48 then state == Running(162,[3822481623,0],Store([],64,128))
    else if id == 49 then state == Running(165,[3822481623,0,2812],Store([],64,128))
    else if id == 50 then state == Running(166,[3822481623],Store([],64,128))
    else if id == 51 then state == Running(167,[3822481623,3822481623],Store([],64,128))
    else if id == 52 then state == Running(172,[3822481623,3822481623,3767256062],Store([],64,128))
    else if id == 53 then state == Running(173,[3822481623,0],Store([],64,128))
    else if id == 54 then state == Running(176,[3822481623,0,2831],Store([],64,128))
    else if id == 55 then state == Running(177,[3822481623],Store([],64,128))
    else if id == 56 then state == Running(178,[3822481623,3822481623],Store([],64,128))
    else if id == 57 then state == Running(183,[3822481623,3822481623,3822481623],Store([],64,128))
    else if id == 58 then state == Running(184,[3822481623,1],Store([],64,128))
    else if id == 59 then state == Running(187,[3822481623,1,2850],Store([],64,128))
    else if id == 60 then state == Running(2850,[3822481623],Store([],64,128))
    else if id == 61 then state == Running(2851,[3822481623],Store([],64,128))
    else if id == 62 then state == Running(2854,[3822481623,1329],Store([],64,128))
    else if id == 63 then state == Running(2857,[3822481623,1329,2864],Store([],64,128))
    else if id == 64 then state == Running(2858,[3822481623,1329,2864,size],Store([],64,128))
    else if id == 65 then state == Running(2860,[3822481623,1329,2864,size,4],Store([],64,128))
    else if id == 66 then state == Running(2863,[3822481623,1329,2864,size,4,19303],Store([],64,128))
    else if id == 67 then state == Running(19303,[3822481623,1329,2864,size,4],Store([],64,128))
    else if id == 68 then state == Running(19304,[3822481623,1329,2864,size,4],Store([],64,128))
    else if id == 69 then state == Running(19305,[3822481623,1329,2864,size,4,0],Store([],64,128))
    else if id == 70 then state == Running(19307,[3822481623,1329,2864,size,4,0,32],Store([],64,128))
    else if id == 71 then state == Running(19308,[3822481623,1329,2864,size,4,0,32,4],Store([],64,128))
    else if id == 72 then state == Running(19309,[3822481623,1329,2864,size,4,0,32,4,size],Store([],64,128))
    else if id == 73 then state == Running(19310,[3822481623,1329,2864,size,4,0,32,((size)+Modulus()-(4))%Modulus()],Store([],64,128))
    else if id == 74 then state == Running(19311,[3822481623,1329,2864,size,4,0,(if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(32) then 1 else 0)],Store([],64,128))
    else if id == 75 then state == Running(19312,[3822481623,1329,2864,size,4,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(32) then 1 else 0) == 0 then 1 else 0)],Store([],64,128))
    else if id == 76 then state == Running(19315,[3822481623,1329,2864,size,4,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(32) then 1 else 0) == 0 then 1 else 0),19319],Store([],64,128))
    else if id == 77 then state == Running(19319,[3822481623,1329,2864,size,4,0],Store([],64,128))
    else if id == 78 then state == Running(19320,[3822481623,1329,2864,size,4,0],Store([],64,128))
    else if id == 79 then state == Running(19323,[3822481623,1329,2864,size,4,0,3085],Store([],64,128))
    else if id == 80 then state == Running(19324,[3822481623,1329,2864,size,4,0,3085,4],Store([],64,128))
    else if id == 81 then state == Running(19327,[3822481623,1329,2864,size,4,0,3085,4,18723],Store([],64,128))
    else if id == 82 then state == Running(18723,[3822481623,1329,2864,size,4,0,3085,4],Store([],64,128))
    else if id == 83 then state == Running(18724,[3822481623,1329,2864,size,4,0,3085,4],Store([],64,128))
    else if id == 84 then state == Running(18725,[3822481623,1329,2864,size,4,0,3085,4,4],Store([],64,128))
    else if id == 85 then state == Running(18726,[3822481623,1329,2864,size,4,0,3085,4,a],Store([],64,128))
    else if id == 86 then state == Running(18728,[3822481623,1329,2864,size,4,0,3085,4,a,1],Store([],64,128))
    else if id == 87 then state == Running(18730,[3822481623,1329,2864,size,4,0,3085,4,a,1,1],Store([],64,128))
    else if id == 88 then state == Running(18732,[3822481623,1329,2864,size,4,0,3085,4,a,1,1,160],Store([],64,128))
    else if id == 89 then state == Running(18733,[3822481623,1329,2864,size,4,0,3085,4,a,1,1461501637330902918203684832716283019655932542976],Store([],64,128))
    else if id == 90 then state == Running(18734,[3822481623,1329,2864,size,4,0,3085,4,a,1461501637330902918203684832716283019655932542975],Store([],64,128))
    else if id == 91 then state == Running(18735,[3822481623,1329,2864,size,4,0,3085,4,a,1461501637330902918203684832716283019655932542975,a],Store([],64,128))
    else if id == 92 then state == Running(18736,[3822481623,1329,2864,size,4,0,3085,4,a,Clean(a)],Store([],64,128))
    else if id == 93 then state == Running(18737,[3822481623,1329,2864,size,4,0,3085,4,a,Clean(a),a],Store([],64,128))
    else if id == 94 then state == Running(18738,[3822481623,1329,2864,size,4,0,3085,4,a,(if (a) == (Clean(a)) then 1 else 0)],Store([],64,128))
    else if id == 95 then state == Running(18741,[3822481623,1329,2864,size,4,0,3085,4,a,(if (a) == (Clean(a)) then 1 else 0),1537],Store([],64,128))
    else if id == 96 then state == Running(18742,[3822481623,1329,2864,size,4,0,3085,4,a],Store([],64,128))
    else if id == 97 then state == Running(18743,[3822481623,1329,2864,size,4,0,3085,4,a,0],Store([],64,128))
    else if id == 98 then state == Running(18744,[3822481623,1329,2864,size,4,0,3085,4,a,0,0],Store([],64,128))
    else false
  }
  lemma Advance0(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(0,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(1,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(0,[],[]);
    assert Fetch(code,0) == Op(96,2,128);
  }
  lemma Advance1(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(1,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(2,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2,[128],[]);
    assert Fetch(code,2) == Op(96,4,64);
  }
  lemma Advance2(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(2,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(3,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(4,[128,64],[]);
    assert Fetch(code,4) == Op(82,5,0);
    StoreLoad([],64,128);
  }
  lemma Advance3(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(3,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(4,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(5,[],Store([],64,128));
    assert Fetch(code,5) == Op(52,6,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(4,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(5,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(6,[value],Store([],64,128));
    assert Fetch(code,6) == Op(128,7,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(5,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(6,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(7,[value,value],Store([],64,128));
    assert Fetch(code,7) == Op(21,8,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(6,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(7,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8,[value,(if value == 0 then 1 else 0)],Store([],64,128));
    assert Fetch(code,8) == Op(97,11,15);
  }
  lemma Advance7(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(7,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(8,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(11,[value,(if value == 0 then 1 else 0),15],Store([],64,128));
    assert Fetch(code,11) == Op(87,12,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
    assert 15 in Destinations() && code[15] == 91;
  }
  lemma Advance8(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(8,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(9,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(15,[value],Store([],64,128));
    assert Fetch(code,15) == Op(91,16,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(9,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(10,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(16,[value],Store([],64,128));
    assert Fetch(code,16) == Op(80,17,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(10,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(11,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17,[],Store([],64,128));
    assert Fetch(code,17) == Op(96,19,4);
  }
  lemma Advance11(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(11,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(12,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19,[4],Store([],64,128));
    assert Fetch(code,19) == Op(54,20,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(12,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(13,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(20,[4,size],Store([],64,128));
    assert Fetch(code,20) == Op(16,21,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(13,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(14,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(21,[(if (size) < (4) then 1 else 0)],Store([],64,128));
    assert Fetch(code,21) == Op(97,24,1266);
  }
  lemma Advance14(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(14,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(15,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(24,[(if (size) < (4) then 1 else 0),1266],Store([],64,128));
    assert Fetch(code,24) == Op(87,25,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
    assert 1266 in Destinations() && code[1266] == 91;
  }
  lemma Advance15(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(15,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(16,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(25,[],Store([],64,128));
    assert Fetch(code,25) == Op(95,26,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(16,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(17,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(26,[0],Store([],64,128));
    assert Fetch(code,26) == Op(53,27,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(17,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(18,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(27,[word],Store([],64,128));
    assert Fetch(code,27) == Op(96,29,224);
  }
  lemma Advance18(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(18,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(19,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(29,[word,224],Store([],64,128));
    assert Fetch(code,29) == Op(28,30,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(19,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(20,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(30,[3822481623],Store([],64,128));
    assert Fetch(code,30) == Op(128,31,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(20,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(21,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(31,[3822481623,3822481623],Store([],64,128));
    assert Fetch(code,31) == Op(99,36,2180929414);
  }
  lemma Advance21(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(21,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(22,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(36,[3822481623,3822481623,2180929414],Store([],64,128));
    assert Fetch(code,36) == Op(17,37,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(22,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(23,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(37,[3822481623,0],Store([],64,128));
    assert Fetch(code,37) == Op(97,40,655);
  }
  lemma Advance23(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(23,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(24,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(40,[3822481623,0,655],Store([],64,128));
    assert Fetch(code,40) == Op(87,41,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
    assert 655 in Destinations() && code[655] == 91;
  }
  lemma Advance24(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(24,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(25,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(41,[3822481623],Store([],64,128));
    assert Fetch(code,41) == Op(128,42,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(25,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(26,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(42,[3822481623,3822481623],Store([],64,128));
    assert Fetch(code,42) == Op(99,47,2972706854);
  }
  lemma Advance26(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(26,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(27,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(47,[3822481623,3822481623,2972706854],Store([],64,128));
    assert Fetch(code,47) == Op(17,48,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(27,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(28,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(48,[3822481623,0],Store([],64,128));
    assert Fetch(code,48) == Op(97,51,353);
  }
  lemma Advance28(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(28,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(29,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(51,[3822481623,0,353],Store([],64,128));
    assert Fetch(code,51) == Op(87,52,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
    assert 353 in Destinations() && code[353] == 91;
  }
  lemma Advance29(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(29,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(30,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(52,[3822481623],Store([],64,128));
    assert Fetch(code,52) == Op(128,53,0);
  }
  lemma Advance30(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(30,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(31,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(53,[3822481623,3822481623],Store([],64,128));
    assert Fetch(code,53) == Op(99,58,3737291867);
  }
  lemma Advance31(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(31,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(32,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(58,[3822481623,3822481623,3737291867],Store([],64,128));
    assert Fetch(code,58) == Op(17,59,0);
  }
  lemma Advance32(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(32,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(33,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(59,[3822481623,0],Store([],64,128));
    assert Fetch(code,59) == Op(97,62,213);
  }
  lemma Advance33(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(33,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(34,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(62,[3822481623,0,213],Store([],64,128));
    assert Fetch(code,62) == Op(87,63,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
    assert 213 in Destinations() && code[213] == 91;
  }
  lemma Advance34(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(34,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(35,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(63,[3822481623],Store([],64,128));
    assert Fetch(code,63) == Op(128,64,0);
  }
  lemma Advance35(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(35,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(36,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(64,[3822481623,3822481623],Store([],64,128));
    assert Fetch(code,64) == Op(99,69,4135589559);
  }
  lemma Advance36(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(36,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(37,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(69,[3822481623,3822481623,4135589559],Store([],64,128));
    assert Fetch(code,69) == Op(17,70,0);
  }
  lemma Advance37(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(37,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(38,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(70,[3822481623,1],Store([],64,128));
    assert Fetch(code,70) == Op(97,73,143);
  }
  lemma Advance38(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(38,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(39,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(73,[3822481623,1,143],Store([],64,128));
    assert Fetch(code,73) == Op(87,74,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
    assert 143 in Destinations() && code[143] == 91;
  }
  lemma Advance39(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(39,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(40,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(143,[3822481623],Store([],64,128));
    assert Fetch(code,143) == Op(91,144,0);
  }
  lemma Advance40(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(40,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(41,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(144,[3822481623],Store([],64,128));
    assert Fetch(code,144) == Op(128,145,0);
  }
  lemma Advance41(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(41,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(42,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(145,[3822481623,3822481623],Store([],64,128));
    assert Fetch(code,145) == Op(99,150,3737291867);
  }
  lemma Advance42(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(42,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(43,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(150,[3822481623,3822481623,3737291867],Store([],64,128));
    assert Fetch(code,150) == Op(20,151,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
  }
  lemma Advance43(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(43,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(44,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(151,[3822481623,0],Store([],64,128));
    assert Fetch(code,151) == Op(97,154,2793);
  }
  lemma Advance44(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(44,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(45,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(154,[3822481623,0,2793],Store([],64,128));
    assert Fetch(code,154) == Op(87,155,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
    assert 2793 in Destinations() && code[2793] == 91;
  }
  lemma Advance45(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(45,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(46,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(155,[3822481623],Store([],64,128));
    assert Fetch(code,155) == Op(128,156,0);
  }
  lemma Advance46(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(46,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(47,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(156,[3822481623,3822481623],Store([],64,128));
    assert Fetch(code,156) == Op(99,161,3758363542);
  }
  lemma Advance47(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(47,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(48,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(161,[3822481623,3822481623,3758363542],Store([],64,128));
    assert Fetch(code,161) == Op(20,162,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
  }
  lemma Advance48(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(48,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(49,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(162,[3822481623,0],Store([],64,128));
    assert Fetch(code,162) == Op(97,165,2812);
  }
  lemma Advance49(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(49,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(50,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(165,[3822481623,0,2812],Store([],64,128));
    assert Fetch(code,165) == Op(87,166,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
    assert 2812 in Destinations() && code[2812] == 91;
  }
  lemma Advance50(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(50,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(51,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(166,[3822481623],Store([],64,128));
    assert Fetch(code,166) == Op(128,167,0);
  }
  lemma Advance51(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(51,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(52,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(167,[3822481623,3822481623],Store([],64,128));
    assert Fetch(code,167) == Op(99,172,3767256062);
  }
  lemma Advance52(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(52,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(53,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(172,[3822481623,3822481623,3767256062],Store([],64,128));
    assert Fetch(code,172) == Op(20,173,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
  }
  lemma Advance53(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(53,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(54,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(173,[3822481623,0],Store([],64,128));
    assert Fetch(code,173) == Op(97,176,2831);
  }
  lemma Advance54(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(54,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(55,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(176,[3822481623,0,2831],Store([],64,128));
    assert Fetch(code,176) == Op(87,177,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
    assert 2831 in Destinations() && code[2831] == 91;
  }
  lemma Advance55(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(55,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(56,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(177,[3822481623],Store([],64,128));
    assert Fetch(code,177) == Op(128,178,0);
  }
  lemma Advance56(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(56,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(57,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(178,[3822481623,3822481623],Store([],64,128));
    assert Fetch(code,178) == Op(99,183,3822481623);
  }
  lemma Advance57(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(57,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(58,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(183,[3822481623,3822481623,3822481623],Store([],64,128));
    assert Fetch(code,183) == Op(20,184,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
  }
  lemma Advance58(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(58,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(59,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(184,[3822481623,1],Store([],64,128));
    assert Fetch(code,184) == Op(97,187,2850);
  }
  lemma Advance59(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(59,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(60,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(187,[3822481623,1,2850],Store([],64,128));
    assert Fetch(code,187) == Op(87,188,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
    assert 2850 in Destinations() && code[2850] == 91;
  }
  lemma Advance60(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(60,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(61,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2850,[3822481623],Store([],64,128));
    assert Fetch(code,2850) == Op(91,2851,0);
  }
  lemma Advance61(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(61,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(62,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2851,[3822481623],Store([],64,128));
    assert Fetch(code,2851) == Op(97,2854,1329);
  }
  lemma Advance62(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(62,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(63,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2854,[3822481623,1329],Store([],64,128));
    assert Fetch(code,2854) == Op(97,2857,2864);
  }
  lemma Advance63(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(63,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(64,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2857,[3822481623,1329,2864],Store([],64,128));
    assert Fetch(code,2857) == Op(54,2858,0);
  }
  lemma Advance64(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(64,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(65,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2858,[3822481623,1329,2864,size],Store([],64,128));
    assert Fetch(code,2858) == Op(96,2860,4);
  }
  lemma Advance65(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(65,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(66,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2860,[3822481623,1329,2864,size,4],Store([],64,128));
    assert Fetch(code,2860) == Op(97,2863,19303);
  }
  lemma Advance66(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(66,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(67,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2863,[3822481623,1329,2864,size,4,19303],Store([],64,128));
    assert Fetch(code,2863) == Op(86,2864,0);
    assert 19303 in Destinations() && code[19303] == 91;
  }
  lemma Advance67(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(67,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(68,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19303,[3822481623,1329,2864,size,4],Store([],64,128));
    assert Fetch(code,19303) == Op(91,19304,0);
  }
  lemma Advance68(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(68,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(69,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19304,[3822481623,1329,2864,size,4],Store([],64,128));
    assert Fetch(code,19304) == Op(95,19305,0);
  }
  lemma Advance69(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(69,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(70,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19305,[3822481623,1329,2864,size,4,0],Store([],64,128));
    assert Fetch(code,19305) == Op(96,19307,32);
  }
  lemma Advance70(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(70,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(71,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19307,[3822481623,1329,2864,size,4,0,32],Store([],64,128));
    assert Fetch(code,19307) == Op(130,19308,0);
  }
  lemma Advance71(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(71,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(72,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19308,[3822481623,1329,2864,size,4,0,32,4],Store([],64,128));
    assert Fetch(code,19308) == Op(132,19309,0);
  }
  lemma Advance72(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(72,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(73,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19309,[3822481623,1329,2864,size,4,0,32,4,size],Store([],64,128));
    assert Fetch(code,19309) == Op(3,19310,0);
  }
  lemma Advance73(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(73,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(74,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19310,[3822481623,1329,2864,size,4,0,32,((size)+Modulus()-(4))%Modulus()],Store([],64,128));
    assert Fetch(code,19310) == Op(18,19311,0);
  }
  lemma Advance74(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(74,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(75,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19311,[3822481623,1329,2864,size,4,0,(if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(32) then 1 else 0)],Store([],64,128));
    assert Fetch(code,19311) == Op(21,19312,0);
  }
  lemma Advance75(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(75,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(76,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19312,[3822481623,1329,2864,size,4,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(32) then 1 else 0) == 0 then 1 else 0)],Store([],64,128));
    assert Fetch(code,19312) == Op(97,19315,19319);
  }
  lemma Advance76(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(76,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(77,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19315,[3822481623,1329,2864,size,4,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(32) then 1 else 0) == 0 then 1 else 0),19319],Store([],64,128));
    assert Fetch(code,19315) == Op(87,19316,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
    assert 19319 in Destinations() && code[19319] == 91;
  }
  lemma Advance77(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(77,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(78,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19319,[3822481623,1329,2864,size,4,0],Store([],64,128));
    assert Fetch(code,19319) == Op(91,19320,0);
  }
  lemma Advance78(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(78,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(79,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19320,[3822481623,1329,2864,size,4,0],Store([],64,128));
    assert Fetch(code,19320) == Op(97,19323,3085);
  }
  lemma Advance79(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(79,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(80,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19323,[3822481623,1329,2864,size,4,0,3085],Store([],64,128));
    assert Fetch(code,19323) == Op(130,19324,0);
  }
  lemma Advance80(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(80,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(81,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19324,[3822481623,1329,2864,size,4,0,3085,4],Store([],64,128));
    assert Fetch(code,19324) == Op(97,19327,18723);
  }
  lemma Advance81(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(81,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(82,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19327,[3822481623,1329,2864,size,4,0,3085,4,18723],Store([],64,128));
    assert Fetch(code,19327) == Op(86,19328,0);
    assert 18723 in Destinations() && code[18723] == 91;
  }
  lemma Advance82(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(82,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(83,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18723,[3822481623,1329,2864,size,4,0,3085,4],Store([],64,128));
    assert Fetch(code,18723) == Op(91,18724,0);
  }
  lemma Advance83(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(83,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(84,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18724,[3822481623,1329,2864,size,4,0,3085,4],Store([],64,128));
    assert Fetch(code,18724) == Op(128,18725,0);
  }
  lemma Advance84(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(84,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(85,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18725,[3822481623,1329,2864,size,4,0,3085,4,4],Store([],64,128));
    assert Fetch(code,18725) == Op(53,18726,0);
  }
  lemma Advance85(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(85,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(86,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18726,[3822481623,1329,2864,size,4,0,3085,4,a],Store([],64,128));
    assert Fetch(code,18726) == Op(96,18728,1);
  }
  lemma Advance86(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(86,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(87,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18728,[3822481623,1329,2864,size,4,0,3085,4,a,1],Store([],64,128));
    assert Fetch(code,18728) == Op(96,18730,1);
  }
  lemma Advance87(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(87,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(88,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18730,[3822481623,1329,2864,size,4,0,3085,4,a,1,1],Store([],64,128));
    assert Fetch(code,18730) == Op(96,18732,160);
  }
  lemma Advance88(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(88,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(89,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18732,[3822481623,1329,2864,size,4,0,3085,4,a,1,1,160],Store([],64,128));
    assert Fetch(code,18732) == Op(27,18733,0);
  }
  lemma Advance89(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(89,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(90,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18733,[3822481623,1329,2864,size,4,0,3085,4,a,1,1461501637330902918203684832716283019655932542976],Store([],64,128));
    assert Fetch(code,18733) == Op(3,18734,0);
  }
  lemma Advance90(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(90,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(91,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18734,[3822481623,1329,2864,size,4,0,3085,4,a,1461501637330902918203684832716283019655932542975],Store([],64,128));
    assert Fetch(code,18734) == Op(129,18735,0);
  }
  lemma Advance91(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(91,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(92,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18735,[3822481623,1329,2864,size,4,0,3085,4,a,1461501637330902918203684832716283019655932542975,a],Store([],64,128));
    assert Fetch(code,18735) == Op(22,18736,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
  }
  lemma Advance92(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(92,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(93,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18736,[3822481623,1329,2864,size,4,0,3085,4,a,Clean(a)],Store([],64,128));
    assert Fetch(code,18736) == Op(129,18737,0);
  }
  lemma Advance93(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(93,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(94,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18737,[3822481623,1329,2864,size,4,0,3085,4,a,Clean(a),a],Store([],64,128));
    assert Fetch(code,18737) == Op(20,18738,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
  }
  lemma Advance94(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(94,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(95,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18738,[3822481623,1329,2864,size,4,0,3085,4,a,(if (a) == (Clean(a)) then 1 else 0)],Store([],64,128));
    assert Fetch(code,18738) == Op(97,18741,1537);
  }
  lemma Advance95(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(95,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(96,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18741,[3822481623,1329,2864,size,4,0,3085,4,a,(if (a) == (Clean(a)) then 1 else 0),1537],Store([],64,128));
    assert Fetch(code,18741) == Op(87,18742,0);
    CleanDefinition(a); Mask.AcceptedExactly(a);
    assert 1537 in Destinations() && code[1537] == 91;
  }
  lemma Advance96(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(96,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(97,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18742,[3822481623,1329,2864,size,4,0,3085,4,a],Store([],64,128));
    assert Fetch(code,18742) == Op(95,18743,0);
  }
  lemma Advance97(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(97,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(98,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18743,[3822481623,1329,2864,size,4,0,3085,4,a,0],Store([],64,128));
    assert Fetch(code,18743) == Op(95,18744,0);
  }
  lemma Advance98(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(98,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); next == Reverted([])
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18744,[3822481623,1329,2864,size,4,0,3085,4,a,0,0],Store([],64,128));
    assert Fetch(code,18744) == Op(253,18745,0);
    assert Grow(Store([],64,128),0)[0..0] == [];
  }
  lemma Start(value: Word, size: Word, word: Word, a: Word, world: World)
    ensures Good(0,Running(0,[],[]),value,size,word,a,world)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, value: Word, size: Word, word: Word, a: Word, world: World) returns (state: State)
    requires Matches(code) && Admitted(value,size,word,a,world)
    ensures state == Reverted([])
  {
    Start(value,size,word,a,world);
    state := Running(0,[],[]);
    Advance0(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance1(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance2(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance3(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance4(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance5(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance6(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance7(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance8(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance9(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance10(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance11(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance12(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance13(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance14(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance15(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance16(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance17(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance18(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance19(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance20(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance21(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance22(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance23(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance24(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance25(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance26(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance27(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance28(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance29(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance30(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance31(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance32(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance33(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance34(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance35(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance36(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance37(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance38(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance39(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance40(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance41(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance42(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance43(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance44(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance45(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance46(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance47(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance48(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance49(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance50(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance51(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance52(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance53(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance54(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance55(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance56(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance57(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance58(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance59(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance60(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance61(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance62(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance63(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance64(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance65(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance66(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance67(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance68(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance69(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance70(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance71(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance72(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance73(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance74(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance75(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance76(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance77(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance78(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance79(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance80(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance81(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance82(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance83(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance84(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance85(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance86(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance87(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance88(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance89(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance90(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance91(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance92(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance93(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance94(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance95(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance96(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance97(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance98(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
  }
}
