// SPDX-License-Identifier: MIT
// Generated exact executed-byte certificate. Never edit directly.
include "Machine.dfy"
include "Mask.dfy"
module OperationsAddressEnvironmentOrigin {
  import opened OperationsAddressEnvironmentMachine
  import K = OperationsAddressMask
  function Result(world: World): Word { world.origin }
  predicate Admitted(value: Word, size: Word, word: Word, world: World) {
    value == 0 && 4 <= size < 0x10000000000000000 && Selector(word) == 2475384626
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
    code[353] == 91 &&
    code[354] == 128 &&
    code[355] == 99 &&
    code[356] == 161 &&
    code[357] == 188 &&
    code[358] == 33 &&
    code[359] == 57 &&
    code[360] == 17 &&
    code[361] == 97 &&
    code[362] == 2 &&
    code[363] == 3 &&
    code[364] == 87 &&
    code[515] == 91 &&
    code[516] == 128 &&
    code[517] == 99 &&
    code[518] == 152 &&
    code[519] == 19 &&
    code[520] == 24 &&
    code[521] == 118 &&
    code[522] == 17 &&
    code[523] == 97 &&
    code[524] == 2 &&
    code[525] == 84 &&
    code[526] == 87 &&
    code[596] == 91 &&
    code[597] == 128 &&
    code[598] == 99 &&
    code[599] == 129 &&
    code[600] == 254 &&
    code[601] == 87 &&
    code[602] == 134 &&
    code[603] == 20 &&
    code[604] == 97 &&
    code[605] == 8 &&
    code[606] == 117 &&
    code[607] == 87 &&
    code[608] == 128 &&
    code[609] == 99 &&
    code[610] == 130 &&
    code[611] == 31 &&
    code[612] == 22 &&
    code[613] == 123 &&
    code[614] == 20 &&
    code[615] == 97 &&
    code[616] == 8 &&
    code[617] == 136 &&
    code[618] == 87 &&
    code[619] == 128 &&
    code[620] == 99 &&
    code[621] == 133 &&
    code[622] == 223 &&
    code[623] == 81 &&
    code[624] == 253 &&
    code[625] == 20 &&
    code[626] == 97 &&
    code[627] == 8 &&
    code[628] == 155 &&
    code[629] == 87 &&
    code[630] == 128 &&
    code[631] == 99 &&
    code[632] == 133 &&
    code[633] == 225 &&
    code[634] == 246 &&
    code[635] == 108 &&
    code[636] == 20 &&
    code[637] == 97 &&
    code[638] == 8 &&
    code[639] == 173 &&
    code[640] == 87 &&
    code[641] == 128 &&
    code[642] == 99 &&
    code[643] == 147 &&
    code[644] == 139 &&
    code[645] == 95 &&
    code[646] == 50 &&
    code[647] == 20 &&
    code[648] == 97 &&
    code[649] == 8 &&
    code[650] == 192 &&
    code[651] == 87 &&
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
    code[2165] == 91 &&
    code[2184] == 91 &&
    code[2203] == 91 &&
    code[2221] == 91 &&
    code[2240] == 91 &&
    code[2241] == 50 &&
    code[2242] == 91 &&
    code[2243] == 96 &&
    code[2244] == 64 &&
    code[2245] == 81 &&
    code[2246] == 96 &&
    code[2247] == 1 &&
    code[2248] == 96 &&
    code[2249] == 1 &&
    code[2250] == 96 &&
    code[2251] == 160 &&
    code[2252] == 27 &&
    code[2253] == 3 &&
    code[2254] == 144 &&
    code[2255] == 145 &&
    code[2256] == 22 &&
    code[2257] == 129 &&
    code[2258] == 82 &&
    code[2259] == 96 &&
    code[2260] == 32 &&
    code[2261] == 1 &&
    code[2262] == 97 &&
    code[2263] == 5 &&
    code[2264] == 21 &&
    code[2265] == 86
  }
  function Destinations(): set<nat> { {15,353,515,596,655,1266,1301,2165,2184,2203,2221,2240} }
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
    else if id == 19 then state == Running(30,[2475384626],Store([],64,128))
    else if id == 20 then state == Running(31,[2475384626,2475384626],Store([],64,128))
    else if id == 21 then state == Running(36,[2475384626,2475384626,2180929414],Store([],64,128))
    else if id == 22 then state == Running(37,[2475384626,0],Store([],64,128))
    else if id == 23 then state == Running(40,[2475384626,0,655],Store([],64,128))
    else if id == 24 then state == Running(41,[2475384626],Store([],64,128))
    else if id == 25 then state == Running(42,[2475384626,2475384626],Store([],64,128))
    else if id == 26 then state == Running(47,[2475384626,2475384626,2972706854],Store([],64,128))
    else if id == 27 then state == Running(48,[2475384626,1],Store([],64,128))
    else if id == 28 then state == Running(51,[2475384626,1,353],Store([],64,128))
    else if id == 29 then state == Running(353,[2475384626],Store([],64,128))
    else if id == 30 then state == Running(354,[2475384626],Store([],64,128))
    else if id == 31 then state == Running(355,[2475384626,2475384626],Store([],64,128))
    else if id == 32 then state == Running(360,[2475384626,2475384626,2713461049],Store([],64,128))
    else if id == 33 then state == Running(361,[2475384626,1],Store([],64,128))
    else if id == 34 then state == Running(364,[2475384626,1,515],Store([],64,128))
    else if id == 35 then state == Running(515,[2475384626],Store([],64,128))
    else if id == 36 then state == Running(516,[2475384626],Store([],64,128))
    else if id == 37 then state == Running(517,[2475384626,2475384626],Store([],64,128))
    else if id == 38 then state == Running(522,[2475384626,2475384626,2551388278],Store([],64,128))
    else if id == 39 then state == Running(523,[2475384626,1],Store([],64,128))
    else if id == 40 then state == Running(526,[2475384626,1,596],Store([],64,128))
    else if id == 41 then state == Running(596,[2475384626],Store([],64,128))
    else if id == 42 then state == Running(597,[2475384626],Store([],64,128))
    else if id == 43 then state == Running(598,[2475384626,2475384626],Store([],64,128))
    else if id == 44 then state == Running(603,[2475384626,2475384626,2180929414],Store([],64,128))
    else if id == 45 then state == Running(604,[2475384626,0],Store([],64,128))
    else if id == 46 then state == Running(607,[2475384626,0,2165],Store([],64,128))
    else if id == 47 then state == Running(608,[2475384626],Store([],64,128))
    else if id == 48 then state == Running(609,[2475384626,2475384626],Store([],64,128))
    else if id == 49 then state == Running(614,[2475384626,2475384626,2183075451],Store([],64,128))
    else if id == 50 then state == Running(615,[2475384626,0],Store([],64,128))
    else if id == 51 then state == Running(618,[2475384626,0,2184],Store([],64,128))
    else if id == 52 then state == Running(619,[2475384626],Store([],64,128))
    else if id == 53 then state == Running(620,[2475384626,2475384626],Store([],64,128))
    else if id == 54 then state == Running(625,[2475384626,2475384626,2246005245],Store([],64,128))
    else if id == 55 then state == Running(626,[2475384626,0],Store([],64,128))
    else if id == 56 then state == Running(629,[2475384626,0,2203],Store([],64,128))
    else if id == 57 then state == Running(630,[2475384626],Store([],64,128))
    else if id == 58 then state == Running(631,[2475384626,2475384626],Store([],64,128))
    else if id == 59 then state == Running(636,[2475384626,2475384626,2246178412],Store([],64,128))
    else if id == 60 then state == Running(637,[2475384626,0],Store([],64,128))
    else if id == 61 then state == Running(640,[2475384626,0,2221],Store([],64,128))
    else if id == 62 then state == Running(641,[2475384626],Store([],64,128))
    else if id == 63 then state == Running(642,[2475384626,2475384626],Store([],64,128))
    else if id == 64 then state == Running(647,[2475384626,2475384626,2475384626],Store([],64,128))
    else if id == 65 then state == Running(648,[2475384626,1],Store([],64,128))
    else if id == 66 then state == Running(651,[2475384626,1,2240],Store([],64,128))
    else if id == 67 then state == Running(2240,[2475384626],Store([],64,128))
    else if id == 68 then state == Running(2241,[2475384626],Store([],64,128))
    else if id == 69 then state == Running(2242,[2475384626,Observe(world,50)],Store([],64,128))
    else if id == 70 then state == Running(2243,[2475384626,Observe(world,50)],Store([],64,128))
    else if id == 71 then state == Running(2245,[2475384626,Observe(world,50),64],Store([],64,128))
    else if id == 72 then state == Running(2246,[2475384626,Observe(world,50),128],Store([],64,128))
    else if id == 73 then state == Running(2248,[2475384626,Observe(world,50),128,1],Store([],64,128))
    else if id == 74 then state == Running(2250,[2475384626,Observe(world,50),128,1,1],Store([],64,128))
    else if id == 75 then state == Running(2252,[2475384626,Observe(world,50),128,1,1,160],Store([],64,128))
    else if id == 76 then state == Running(2253,[2475384626,Observe(world,50),128,1,1461501637330902918203684832716283019655932542976],Store([],64,128))
    else if id == 77 then state == Running(2254,[2475384626,Observe(world,50),128,1461501637330902918203684832716283019655932542975],Store([],64,128))
    else if id == 78 then state == Running(2255,[2475384626,Observe(world,50),1461501637330902918203684832716283019655932542975,128],Store([],64,128))
    else if id == 79 then state == Running(2256,[2475384626,128,1461501637330902918203684832716283019655932542975,Observe(world,50)],Store([],64,128))
    else if id == 80 then state == Running(2257,[2475384626,128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)],Store([],64,128))
    else if id == 81 then state == Running(2258,[2475384626,128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975),128],Store([],64,128))
    else if id == 82 then state == Running(2259,[2475384626,128],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)))
    else if id == 83 then state == Running(2261,[2475384626,128,32],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)))
    else if id == 84 then state == Running(2262,[2475384626,160],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)))
    else if id == 85 then state == Running(2265,[2475384626,160,1301],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)))
    else if id == 86 then state == Running(1301,[2475384626,160],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)))
    else if id == 87 then state == Running(1302,[2475384626,160],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)))
    else if id == 88 then state == Running(1304,[2475384626,160,64],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)))
    else if id == 89 then state == Running(1305,[2475384626,160,128],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)))
    else if id == 90 then state == Running(1306,[2475384626,160,128,128],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)))
    else if id == 91 then state == Running(1307,[2475384626,128,128,160],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)))
    else if id == 92 then state == Running(1308,[2475384626,128,32],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)))
    else if id == 93 then state == Running(1309,[2475384626,32,128],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)))
    else false
  }
  lemma Advance0(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(0,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(20,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(30,[2475384626],Store([],64,128));
    assert Fetch(code,30) == Op(128,31,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(20,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(21,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(31,[2475384626,2475384626],Store([],64,128));
    assert Fetch(code,31) == Op(99,36,2180929414);
  }
  lemma Advance21(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(21,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(22,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(36,[2475384626,2475384626,2180929414],Store([],64,128));
    assert Fetch(code,36) == Op(17,37,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(22,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(23,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(37,[2475384626,0],Store([],64,128));
    assert Fetch(code,37) == Op(97,40,655);
  }
  lemma Advance23(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(23,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(24,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(40,[2475384626,0,655],Store([],64,128));
    assert Fetch(code,40) == Op(87,41,0);
    assert 655 in Destinations() && code[655] == 91;
  }
  lemma Advance24(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(24,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(25,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(41,[2475384626],Store([],64,128));
    assert Fetch(code,41) == Op(128,42,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(25,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(26,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(42,[2475384626,2475384626],Store([],64,128));
    assert Fetch(code,42) == Op(99,47,2972706854);
  }
  lemma Advance26(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(26,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(27,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(47,[2475384626,2475384626,2972706854],Store([],64,128));
    assert Fetch(code,47) == Op(17,48,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(27,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(28,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(48,[2475384626,1],Store([],64,128));
    assert Fetch(code,48) == Op(97,51,353);
  }
  lemma Advance28(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(28,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(29,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(51,[2475384626,1,353],Store([],64,128));
    assert Fetch(code,51) == Op(87,52,0);
    assert 353 in Destinations() && code[353] == 91;
  }
  lemma Advance29(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(29,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(30,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(353,[2475384626],Store([],64,128));
    assert Fetch(code,353) == Op(91,354,0);
  }
  lemma Advance30(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(30,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(31,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(354,[2475384626],Store([],64,128));
    assert Fetch(code,354) == Op(128,355,0);
  }
  lemma Advance31(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(31,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(32,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(355,[2475384626,2475384626],Store([],64,128));
    assert Fetch(code,355) == Op(99,360,2713461049);
  }
  lemma Advance32(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(32,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(33,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(360,[2475384626,2475384626,2713461049],Store([],64,128));
    assert Fetch(code,360) == Op(17,361,0);
  }
  lemma Advance33(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(33,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(34,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(361,[2475384626,1],Store([],64,128));
    assert Fetch(code,361) == Op(97,364,515);
  }
  lemma Advance34(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(34,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(35,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(364,[2475384626,1,515],Store([],64,128));
    assert Fetch(code,364) == Op(87,365,0);
    assert 515 in Destinations() && code[515] == 91;
  }
  lemma Advance35(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(35,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(36,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(515,[2475384626],Store([],64,128));
    assert Fetch(code,515) == Op(91,516,0);
  }
  lemma Advance36(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(36,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(37,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(516,[2475384626],Store([],64,128));
    assert Fetch(code,516) == Op(128,517,0);
  }
  lemma Advance37(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(37,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(38,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(517,[2475384626,2475384626],Store([],64,128));
    assert Fetch(code,517) == Op(99,522,2551388278);
  }
  lemma Advance38(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(38,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(39,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(522,[2475384626,2475384626,2551388278],Store([],64,128));
    assert Fetch(code,522) == Op(17,523,0);
  }
  lemma Advance39(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(39,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(40,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(523,[2475384626,1],Store([],64,128));
    assert Fetch(code,523) == Op(97,526,596);
  }
  lemma Advance40(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(40,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(41,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(526,[2475384626,1,596],Store([],64,128));
    assert Fetch(code,526) == Op(87,527,0);
    assert 596 in Destinations() && code[596] == 91;
  }
  lemma Advance41(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(41,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(42,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(596,[2475384626],Store([],64,128));
    assert Fetch(code,596) == Op(91,597,0);
  }
  lemma Advance42(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(42,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(43,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(597,[2475384626],Store([],64,128));
    assert Fetch(code,597) == Op(128,598,0);
  }
  lemma Advance43(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(43,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(44,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(598,[2475384626,2475384626],Store([],64,128));
    assert Fetch(code,598) == Op(99,603,2180929414);
  }
  lemma Advance44(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(44,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(45,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(603,[2475384626,2475384626,2180929414],Store([],64,128));
    assert Fetch(code,603) == Op(20,604,0);
  }
  lemma Advance45(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(45,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(46,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(604,[2475384626,0],Store([],64,128));
    assert Fetch(code,604) == Op(97,607,2165);
  }
  lemma Advance46(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(46,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(47,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(607,[2475384626,0,2165],Store([],64,128));
    assert Fetch(code,607) == Op(87,608,0);
    assert 2165 in Destinations() && code[2165] == 91;
  }
  lemma Advance47(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(47,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(48,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(608,[2475384626],Store([],64,128));
    assert Fetch(code,608) == Op(128,609,0);
  }
  lemma Advance48(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(48,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(49,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(609,[2475384626,2475384626],Store([],64,128));
    assert Fetch(code,609) == Op(99,614,2183075451);
  }
  lemma Advance49(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(49,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(50,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(614,[2475384626,2475384626,2183075451],Store([],64,128));
    assert Fetch(code,614) == Op(20,615,0);
  }
  lemma Advance50(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(50,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(51,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(615,[2475384626,0],Store([],64,128));
    assert Fetch(code,615) == Op(97,618,2184);
  }
  lemma Advance51(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(51,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(52,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(618,[2475384626,0,2184],Store([],64,128));
    assert Fetch(code,618) == Op(87,619,0);
    assert 2184 in Destinations() && code[2184] == 91;
  }
  lemma Advance52(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(52,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(53,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(619,[2475384626],Store([],64,128));
    assert Fetch(code,619) == Op(128,620,0);
  }
  lemma Advance53(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(53,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(54,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(620,[2475384626,2475384626],Store([],64,128));
    assert Fetch(code,620) == Op(99,625,2246005245);
  }
  lemma Advance54(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(54,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(55,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(625,[2475384626,2475384626,2246005245],Store([],64,128));
    assert Fetch(code,625) == Op(20,626,0);
  }
  lemma Advance55(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(55,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(56,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(626,[2475384626,0],Store([],64,128));
    assert Fetch(code,626) == Op(97,629,2203);
  }
  lemma Advance56(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(56,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(57,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(629,[2475384626,0,2203],Store([],64,128));
    assert Fetch(code,629) == Op(87,630,0);
    assert 2203 in Destinations() && code[2203] == 91;
  }
  lemma Advance57(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(57,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(58,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(630,[2475384626],Store([],64,128));
    assert Fetch(code,630) == Op(128,631,0);
  }
  lemma Advance58(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(58,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(59,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(631,[2475384626,2475384626],Store([],64,128));
    assert Fetch(code,631) == Op(99,636,2246178412);
  }
  lemma Advance59(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(59,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(60,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(636,[2475384626,2475384626,2246178412],Store([],64,128));
    assert Fetch(code,636) == Op(20,637,0);
  }
  lemma Advance60(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(60,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(61,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(637,[2475384626,0],Store([],64,128));
    assert Fetch(code,637) == Op(97,640,2221);
  }
  lemma Advance61(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(61,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(62,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(640,[2475384626,0,2221],Store([],64,128));
    assert Fetch(code,640) == Op(87,641,0);
    assert 2221 in Destinations() && code[2221] == 91;
  }
  lemma Advance62(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(62,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(63,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(641,[2475384626],Store([],64,128));
    assert Fetch(code,641) == Op(128,642,0);
  }
  lemma Advance63(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(63,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(64,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(642,[2475384626,2475384626],Store([],64,128));
    assert Fetch(code,642) == Op(99,647,2475384626);
  }
  lemma Advance64(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(64,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(65,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(647,[2475384626,2475384626,2475384626],Store([],64,128));
    assert Fetch(code,647) == Op(20,648,0);
  }
  lemma Advance65(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(65,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(66,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(648,[2475384626,1],Store([],64,128));
    assert Fetch(code,648) == Op(97,651,2240);
  }
  lemma Advance66(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(66,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(67,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(651,[2475384626,1,2240],Store([],64,128));
    assert Fetch(code,651) == Op(87,652,0);
    assert 2240 in Destinations() && code[2240] == 91;
  }
  lemma Advance67(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(67,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(68,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2240,[2475384626],Store([],64,128));
    assert Fetch(code,2240) == Op(91,2241,0);
  }
  lemma Advance68(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(68,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(69,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2241,[2475384626],Store([],64,128));
    assert Fetch(code,2241) == Op(50,2242,0);
  }
  lemma Advance69(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(69,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(70,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2242,[2475384626,Observe(world,50)],Store([],64,128));
    assert Fetch(code,2242) == Op(91,2243,0);
  }
  lemma Advance70(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(70,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(71,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2243,[2475384626,Observe(world,50)],Store([],64,128));
    assert Fetch(code,2243) == Op(96,2245,64);
  }
  lemma Advance71(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(71,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(72,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2245,[2475384626,Observe(world,50),64],Store([],64,128));
    assert Fetch(code,2245) == Op(81,2246,0);
    StoreLoad([],64,128);
  }
  lemma Advance72(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(72,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(73,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2246,[2475384626,Observe(world,50),128],Store([],64,128));
    assert Fetch(code,2246) == Op(96,2248,1);
  }
  lemma Advance73(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(73,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(74,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2248,[2475384626,Observe(world,50),128,1],Store([],64,128));
    assert Fetch(code,2248) == Op(96,2250,1);
  }
  lemma Advance74(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(74,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(75,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2250,[2475384626,Observe(world,50),128,1,1],Store([],64,128));
    assert Fetch(code,2250) == Op(96,2252,160);
  }
  lemma Advance75(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(75,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(76,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2252,[2475384626,Observe(world,50),128,1,1,160],Store([],64,128));
    assert Fetch(code,2252) == Op(27,2253,0);
  }
  lemma Advance76(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(76,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(77,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2253,[2475384626,Observe(world,50),128,1,1461501637330902918203684832716283019655932542976],Store([],64,128));
    assert Fetch(code,2253) == Op(3,2254,0);
  }
  lemma Advance77(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(77,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(78,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2254,[2475384626,Observe(world,50),128,1461501637330902918203684832716283019655932542975],Store([],64,128));
    assert Fetch(code,2254) == Op(144,2255,0);
  }
  lemma Advance78(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(78,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(79,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2255,[2475384626,Observe(world,50),1461501637330902918203684832716283019655932542975,128],Store([],64,128));
    assert Fetch(code,2255) == Op(145,2256,0);
  }
  lemma Advance79(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(79,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(80,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2256,[2475384626,128,1461501637330902918203684832716283019655932542975,Observe(world,50)],Store([],64,128));
    assert Fetch(code,2256) == Op(22,2257,0);
  }
  lemma Advance80(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(80,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(81,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2257,[2475384626,128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)],Store([],64,128));
    assert Fetch(code,2257) == Op(129,2258,0);
  }
  lemma Advance81(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(81,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(82,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2258,[2475384626,128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975),128],Store([],64,128));
    assert Fetch(code,2258) == Op(82,2259,0);
    StoreLoad(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975));
  }
  lemma Advance82(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(82,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(83,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2259,[2475384626,128],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,2259) == Op(96,2261,32);
  }
  lemma Advance83(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(83,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(84,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2261,[2475384626,128,32],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,2261) == Op(1,2262,0);
  }
  lemma Advance84(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(84,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(85,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2262,[2475384626,160],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,2262) == Op(97,2265,1301);
  }
  lemma Advance85(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(85,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(86,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2265,[2475384626,160,1301],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,2265) == Op(86,2266,0);
    assert 1301 in Destinations() && code[1301] == 91;
  }
  lemma Advance86(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(86,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(87,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1301,[2475384626,160],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,1301) == Op(91,1302,0);
  }
  lemma Advance87(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(87,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(88,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1302,[2475384626,160],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,1302) == Op(96,1304,64);
  }
  lemma Advance88(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(88,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(89,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1304,[2475384626,160,64],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,1304) == Op(81,1305,0);
    StoreLoad([],64,128);
    StoreFrame(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975),64);
  }
  lemma Advance89(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(89,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(90,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1305,[2475384626,160,128],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,1305) == Op(128,1306,0);
  }
  lemma Advance90(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(90,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(91,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1306,[2475384626,160,128,128],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,1306) == Op(145,1307,0);
  }
  lemma Advance91(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(91,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(92,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1307,[2475384626,128,128,160],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,1307) == Op(3,1308,0);
  }
  lemma Advance92(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(92,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(93,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1308,[2475384626,128,32],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,1308) == Op(144,1309,0);
  }
  lemma Advance93(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(93,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); next == Returned(Encode(Result(world),32))
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1309,[2475384626,32,128],Store(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,1309) == Op(243,1310,0);
    K.Canonical(world.origin);
    StoreLoad(Store([],64,128),128,BitAnd(Observe(world,50),1461501637330902918203684832716283019655932542975));
  }
  lemma SemanticResult(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(81,state,value,size,word,world)
    ensures state.Running? && |state.stack| >= 2
    ensures state.stack[|state.stack|-1] == 128
    ensures state.stack[|state.stack|-2] == Result(world)
  { reveal Good(); K.Canonical(world.origin); K.Canonical(world.coinbase); }
  lemma SemanticWitness(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(81,state,value,size,word,world)
    requires world.origin != world.coinbase
    ensures state.Running? && |state.stack| >= 2
    ensures state.stack[|state.stack|-1] == 128
    ensures state.stack[|state.stack|-2] == Result(world)
  { reveal Good(); K.Canonical(world.origin); K.Canonical(world.coinbase); }
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
    Advance71(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance72(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance73(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance74(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance75(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance76(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance77(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance78(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance79(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance80(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance81(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance82(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance83(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance84(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance85(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance86(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance87(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance88(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance89(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance90(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance91(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance92(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance93(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
  }
}
