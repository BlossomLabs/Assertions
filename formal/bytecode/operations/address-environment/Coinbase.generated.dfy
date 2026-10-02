// SPDX-License-Identifier: MIT
// Generated exact executed-byte certificate. Never edit directly.
include "Machine.dfy"
include "Mask.dfy"
module OperationsAddressEnvironmentCoinbase {
  import opened OperationsAddressEnvironmentMachine
  import K = OperationsAddressMask
  function Result(world: World): Word { world.coinbase }
  predicate Admitted(value: Word, size: Word, word: Word, world: World) {
    value == 0 && 4 <= size < 0x10000000000000000 && Selector(word) == 2796423852
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
    code[365] == 128 &&
    code[366] == 99 &&
    code[367] == 167 &&
    code[368] == 51 &&
    code[369] == 73 &&
    code[370] == 99 &&
    code[371] == 17 &&
    code[372] == 97 &&
    code[373] == 1 &&
    code[374] == 189 &&
    code[375] == 87 &&
    code[445] == 91 &&
    code[446] == 128 &&
    code[447] == 99 &&
    code[448] == 161 &&
    code[449] == 188 &&
    code[450] == 33 &&
    code[451] == 57 &&
    code[452] == 20 &&
    code[453] == 97 &&
    code[454] == 9 &&
    code[455] == 75 &&
    code[456] == 87 &&
    code[457] == 128 &&
    code[458] == 99 &&
    code[459] == 163 &&
    code[460] == 34 &&
    code[461] == 196 &&
    code[462] == 14 &&
    code[463] == 20 &&
    code[464] == 97 &&
    code[465] == 9 &&
    code[466] == 94 &&
    code[467] == 87 &&
    code[468] == 128 &&
    code[469] == 99 &&
    code[470] == 163 &&
    code[471] == 145 &&
    code[472] == 193 &&
    code[473] == 91 &&
    code[474] == 20 &&
    code[475] == 97 &&
    code[476] == 9 &&
    code[477] == 113 &&
    code[478] == 87 &&
    code[479] == 128 &&
    code[480] == 99 &&
    code[481] == 164 &&
    code[482] == 173 &&
    code[483] == 46 &&
    code[484] == 233 &&
    code[485] == 20 &&
    code[486] == 97 &&
    code[487] == 9 &&
    code[488] == 132 &&
    code[489] == 87 &&
    code[490] == 128 &&
    code[491] == 99 &&
    code[492] == 165 &&
    code[493] == 243 &&
    code[494] == 194 &&
    code[495] == 59 &&
    code[496] == 20 &&
    code[497] == 97 &&
    code[498] == 9 &&
    code[499] == 151 &&
    code[500] == 87 &&
    code[501] == 128 &&
    code[502] == 99 &&
    code[503] == 166 &&
    code[504] == 174 &&
    code[505] == 10 &&
    code[506] == 172 &&
    code[507] == 20 &&
    code[508] == 97 &&
    code[509] == 9 &&
    code[510] == 170 &&
    code[511] == 87 &&
    code[515] == 91 &&
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
    code[2265] == 86 &&
    code[2379] == 91 &&
    code[2398] == 91 &&
    code[2417] == 91 &&
    code[2436] == 91 &&
    code[2455] == 91 &&
    code[2474] == 91 &&
    code[2475] == 65 &&
    code[2476] == 97 &&
    code[2477] == 8 &&
    code[2478] == 194 &&
    code[2479] == 86
  }
  function Destinations(): set<nat> { {15,353,445,515,655,1266,1301,2242,2379,2398,2417,2436,2455,2474} }
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
    else if id == 19 then state == Running(30,[2796423852],Store([],64,128))
    else if id == 20 then state == Running(31,[2796423852,2796423852],Store([],64,128))
    else if id == 21 then state == Running(36,[2796423852,2796423852,2180929414],Store([],64,128))
    else if id == 22 then state == Running(37,[2796423852,0],Store([],64,128))
    else if id == 23 then state == Running(40,[2796423852,0,655],Store([],64,128))
    else if id == 24 then state == Running(41,[2796423852],Store([],64,128))
    else if id == 25 then state == Running(42,[2796423852,2796423852],Store([],64,128))
    else if id == 26 then state == Running(47,[2796423852,2796423852,2972706854],Store([],64,128))
    else if id == 27 then state == Running(48,[2796423852,1],Store([],64,128))
    else if id == 28 then state == Running(51,[2796423852,1,353],Store([],64,128))
    else if id == 29 then state == Running(353,[2796423852],Store([],64,128))
    else if id == 30 then state == Running(354,[2796423852],Store([],64,128))
    else if id == 31 then state == Running(355,[2796423852,2796423852],Store([],64,128))
    else if id == 32 then state == Running(360,[2796423852,2796423852,2713461049],Store([],64,128))
    else if id == 33 then state == Running(361,[2796423852,0],Store([],64,128))
    else if id == 34 then state == Running(364,[2796423852,0,515],Store([],64,128))
    else if id == 35 then state == Running(365,[2796423852],Store([],64,128))
    else if id == 36 then state == Running(366,[2796423852,2796423852],Store([],64,128))
    else if id == 37 then state == Running(371,[2796423852,2796423852,2805156195],Store([],64,128))
    else if id == 38 then state == Running(372,[2796423852,1],Store([],64,128))
    else if id == 39 then state == Running(375,[2796423852,1,445],Store([],64,128))
    else if id == 40 then state == Running(445,[2796423852],Store([],64,128))
    else if id == 41 then state == Running(446,[2796423852],Store([],64,128))
    else if id == 42 then state == Running(447,[2796423852,2796423852],Store([],64,128))
    else if id == 43 then state == Running(452,[2796423852,2796423852,2713461049],Store([],64,128))
    else if id == 44 then state == Running(453,[2796423852,0],Store([],64,128))
    else if id == 45 then state == Running(456,[2796423852,0,2379],Store([],64,128))
    else if id == 46 then state == Running(457,[2796423852],Store([],64,128))
    else if id == 47 then state == Running(458,[2796423852,2796423852],Store([],64,128))
    else if id == 48 then state == Running(463,[2796423852,2796423852,2736964622],Store([],64,128))
    else if id == 49 then state == Running(464,[2796423852,0],Store([],64,128))
    else if id == 50 then state == Running(467,[2796423852,0,2398],Store([],64,128))
    else if id == 51 then state == Running(468,[2796423852],Store([],64,128))
    else if id == 52 then state == Running(469,[2796423852,2796423852],Store([],64,128))
    else if id == 53 then state == Running(474,[2796423852,2796423852,2744238427],Store([],64,128))
    else if id == 54 then state == Running(475,[2796423852,0],Store([],64,128))
    else if id == 55 then state == Running(478,[2796423852,0,2417],Store([],64,128))
    else if id == 56 then state == Running(479,[2796423852],Store([],64,128))
    else if id == 57 then state == Running(480,[2796423852,2796423852],Store([],64,128))
    else if id == 58 then state == Running(485,[2796423852,2796423852,2762813161],Store([],64,128))
    else if id == 59 then state == Running(486,[2796423852,0],Store([],64,128))
    else if id == 60 then state == Running(489,[2796423852,0,2436],Store([],64,128))
    else if id == 61 then state == Running(490,[2796423852],Store([],64,128))
    else if id == 62 then state == Running(491,[2796423852,2796423852],Store([],64,128))
    else if id == 63 then state == Running(496,[2796423852,2796423852,2784215611],Store([],64,128))
    else if id == 64 then state == Running(497,[2796423852,0],Store([],64,128))
    else if id == 65 then state == Running(500,[2796423852,0,2455],Store([],64,128))
    else if id == 66 then state == Running(501,[2796423852],Store([],64,128))
    else if id == 67 then state == Running(502,[2796423852,2796423852],Store([],64,128))
    else if id == 68 then state == Running(507,[2796423852,2796423852,2796423852],Store([],64,128))
    else if id == 69 then state == Running(508,[2796423852,1],Store([],64,128))
    else if id == 70 then state == Running(511,[2796423852,1,2474],Store([],64,128))
    else if id == 71 then state == Running(2474,[2796423852],Store([],64,128))
    else if id == 72 then state == Running(2475,[2796423852],Store([],64,128))
    else if id == 73 then state == Running(2476,[2796423852,Observe(world,65)],Store([],64,128))
    else if id == 74 then state == Running(2479,[2796423852,Observe(world,65),2242],Store([],64,128))
    else if id == 75 then state == Running(2242,[2796423852,Observe(world,65)],Store([],64,128))
    else if id == 76 then state == Running(2243,[2796423852,Observe(world,65)],Store([],64,128))
    else if id == 77 then state == Running(2245,[2796423852,Observe(world,65),64],Store([],64,128))
    else if id == 78 then state == Running(2246,[2796423852,Observe(world,65),128],Store([],64,128))
    else if id == 79 then state == Running(2248,[2796423852,Observe(world,65),128,1],Store([],64,128))
    else if id == 80 then state == Running(2250,[2796423852,Observe(world,65),128,1,1],Store([],64,128))
    else if id == 81 then state == Running(2252,[2796423852,Observe(world,65),128,1,1,160],Store([],64,128))
    else if id == 82 then state == Running(2253,[2796423852,Observe(world,65),128,1,1461501637330902918203684832716283019655932542976],Store([],64,128))
    else if id == 83 then state == Running(2254,[2796423852,Observe(world,65),128,1461501637330902918203684832716283019655932542975],Store([],64,128))
    else if id == 84 then state == Running(2255,[2796423852,Observe(world,65),1461501637330902918203684832716283019655932542975,128],Store([],64,128))
    else if id == 85 then state == Running(2256,[2796423852,128,1461501637330902918203684832716283019655932542975,Observe(world,65)],Store([],64,128))
    else if id == 86 then state == Running(2257,[2796423852,128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)],Store([],64,128))
    else if id == 87 then state == Running(2258,[2796423852,128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975),128],Store([],64,128))
    else if id == 88 then state == Running(2259,[2796423852,128],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)))
    else if id == 89 then state == Running(2261,[2796423852,128,32],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)))
    else if id == 90 then state == Running(2262,[2796423852,160],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)))
    else if id == 91 then state == Running(2265,[2796423852,160,1301],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)))
    else if id == 92 then state == Running(1301,[2796423852,160],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)))
    else if id == 93 then state == Running(1302,[2796423852,160],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)))
    else if id == 94 then state == Running(1304,[2796423852,160,64],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)))
    else if id == 95 then state == Running(1305,[2796423852,160,128],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)))
    else if id == 96 then state == Running(1306,[2796423852,160,128,128],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)))
    else if id == 97 then state == Running(1307,[2796423852,128,128,160],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)))
    else if id == 98 then state == Running(1308,[2796423852,128,32],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)))
    else if id == 99 then state == Running(1309,[2796423852,32,128],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)))
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
    assert state == Running(30,[2796423852],Store([],64,128));
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
    assert state == Running(31,[2796423852,2796423852],Store([],64,128));
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
    assert state == Running(36,[2796423852,2796423852,2180929414],Store([],64,128));
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
    assert state == Running(37,[2796423852,0],Store([],64,128));
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
    assert state == Running(40,[2796423852,0,655],Store([],64,128));
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
    assert state == Running(41,[2796423852],Store([],64,128));
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
    assert state == Running(42,[2796423852,2796423852],Store([],64,128));
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
    assert state == Running(47,[2796423852,2796423852,2972706854],Store([],64,128));
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
    assert state == Running(48,[2796423852,1],Store([],64,128));
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
    assert state == Running(51,[2796423852,1,353],Store([],64,128));
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
    assert state == Running(353,[2796423852],Store([],64,128));
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
    assert state == Running(354,[2796423852],Store([],64,128));
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
    assert state == Running(355,[2796423852,2796423852],Store([],64,128));
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
    assert state == Running(360,[2796423852,2796423852,2713461049],Store([],64,128));
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
    assert state == Running(361,[2796423852,0],Store([],64,128));
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
    assert state == Running(364,[2796423852,0,515],Store([],64,128));
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
    assert state == Running(365,[2796423852],Store([],64,128));
    assert Fetch(code,365) == Op(128,366,0);
  }
  lemma Advance36(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(36,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(37,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(366,[2796423852,2796423852],Store([],64,128));
    assert Fetch(code,366) == Op(99,371,2805156195);
  }
  lemma Advance37(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(37,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(38,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(371,[2796423852,2796423852,2805156195],Store([],64,128));
    assert Fetch(code,371) == Op(17,372,0);
  }
  lemma Advance38(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(38,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(39,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(372,[2796423852,1],Store([],64,128));
    assert Fetch(code,372) == Op(97,375,445);
  }
  lemma Advance39(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(39,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(40,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(375,[2796423852,1,445],Store([],64,128));
    assert Fetch(code,375) == Op(87,376,0);
    assert 445 in Destinations() && code[445] == 91;
  }
  lemma Advance40(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(40,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(41,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(445,[2796423852],Store([],64,128));
    assert Fetch(code,445) == Op(91,446,0);
  }
  lemma Advance41(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(41,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(42,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(446,[2796423852],Store([],64,128));
    assert Fetch(code,446) == Op(128,447,0);
  }
  lemma Advance42(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(42,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(43,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(447,[2796423852,2796423852],Store([],64,128));
    assert Fetch(code,447) == Op(99,452,2713461049);
  }
  lemma Advance43(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(43,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(44,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(452,[2796423852,2796423852,2713461049],Store([],64,128));
    assert Fetch(code,452) == Op(20,453,0);
  }
  lemma Advance44(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(44,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(45,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(453,[2796423852,0],Store([],64,128));
    assert Fetch(code,453) == Op(97,456,2379);
  }
  lemma Advance45(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(45,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(46,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(456,[2796423852,0,2379],Store([],64,128));
    assert Fetch(code,456) == Op(87,457,0);
    assert 2379 in Destinations() && code[2379] == 91;
  }
  lemma Advance46(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(46,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(47,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(457,[2796423852],Store([],64,128));
    assert Fetch(code,457) == Op(128,458,0);
  }
  lemma Advance47(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(47,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(48,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(458,[2796423852,2796423852],Store([],64,128));
    assert Fetch(code,458) == Op(99,463,2736964622);
  }
  lemma Advance48(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(48,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(49,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(463,[2796423852,2796423852,2736964622],Store([],64,128));
    assert Fetch(code,463) == Op(20,464,0);
  }
  lemma Advance49(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(49,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(50,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(464,[2796423852,0],Store([],64,128));
    assert Fetch(code,464) == Op(97,467,2398);
  }
  lemma Advance50(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(50,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(51,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(467,[2796423852,0,2398],Store([],64,128));
    assert Fetch(code,467) == Op(87,468,0);
    assert 2398 in Destinations() && code[2398] == 91;
  }
  lemma Advance51(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(51,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(52,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(468,[2796423852],Store([],64,128));
    assert Fetch(code,468) == Op(128,469,0);
  }
  lemma Advance52(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(52,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(53,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(469,[2796423852,2796423852],Store([],64,128));
    assert Fetch(code,469) == Op(99,474,2744238427);
  }
  lemma Advance53(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(53,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(54,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(474,[2796423852,2796423852,2744238427],Store([],64,128));
    assert Fetch(code,474) == Op(20,475,0);
  }
  lemma Advance54(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(54,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(55,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(475,[2796423852,0],Store([],64,128));
    assert Fetch(code,475) == Op(97,478,2417);
  }
  lemma Advance55(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(55,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(56,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(478,[2796423852,0,2417],Store([],64,128));
    assert Fetch(code,478) == Op(87,479,0);
    assert 2417 in Destinations() && code[2417] == 91;
  }
  lemma Advance56(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(56,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(57,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(479,[2796423852],Store([],64,128));
    assert Fetch(code,479) == Op(128,480,0);
  }
  lemma Advance57(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(57,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(58,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(480,[2796423852,2796423852],Store([],64,128));
    assert Fetch(code,480) == Op(99,485,2762813161);
  }
  lemma Advance58(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(58,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(59,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(485,[2796423852,2796423852,2762813161],Store([],64,128));
    assert Fetch(code,485) == Op(20,486,0);
  }
  lemma Advance59(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(59,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(60,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(486,[2796423852,0],Store([],64,128));
    assert Fetch(code,486) == Op(97,489,2436);
  }
  lemma Advance60(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(60,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(61,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(489,[2796423852,0,2436],Store([],64,128));
    assert Fetch(code,489) == Op(87,490,0);
    assert 2436 in Destinations() && code[2436] == 91;
  }
  lemma Advance61(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(61,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(62,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(490,[2796423852],Store([],64,128));
    assert Fetch(code,490) == Op(128,491,0);
  }
  lemma Advance62(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(62,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(63,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(491,[2796423852,2796423852],Store([],64,128));
    assert Fetch(code,491) == Op(99,496,2784215611);
  }
  lemma Advance63(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(63,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(64,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(496,[2796423852,2796423852,2784215611],Store([],64,128));
    assert Fetch(code,496) == Op(20,497,0);
  }
  lemma Advance64(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(64,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(65,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(497,[2796423852,0],Store([],64,128));
    assert Fetch(code,497) == Op(97,500,2455);
  }
  lemma Advance65(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(65,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(66,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(500,[2796423852,0,2455],Store([],64,128));
    assert Fetch(code,500) == Op(87,501,0);
    assert 2455 in Destinations() && code[2455] == 91;
  }
  lemma Advance66(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(66,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(67,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(501,[2796423852],Store([],64,128));
    assert Fetch(code,501) == Op(128,502,0);
  }
  lemma Advance67(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(67,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(68,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(502,[2796423852,2796423852],Store([],64,128));
    assert Fetch(code,502) == Op(99,507,2796423852);
  }
  lemma Advance68(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(68,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(69,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(507,[2796423852,2796423852,2796423852],Store([],64,128));
    assert Fetch(code,507) == Op(20,508,0);
  }
  lemma Advance69(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(69,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(70,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(508,[2796423852,1],Store([],64,128));
    assert Fetch(code,508) == Op(97,511,2474);
  }
  lemma Advance70(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(70,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(71,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(511,[2796423852,1,2474],Store([],64,128));
    assert Fetch(code,511) == Op(87,512,0);
    assert 2474 in Destinations() && code[2474] == 91;
  }
  lemma Advance71(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(71,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(72,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2474,[2796423852],Store([],64,128));
    assert Fetch(code,2474) == Op(91,2475,0);
  }
  lemma Advance72(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(72,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(73,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2475,[2796423852],Store([],64,128));
    assert Fetch(code,2475) == Op(65,2476,0);
  }
  lemma Advance73(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(73,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(74,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2476,[2796423852,Observe(world,65)],Store([],64,128));
    assert Fetch(code,2476) == Op(97,2479,2242);
  }
  lemma Advance74(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(74,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(75,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2479,[2796423852,Observe(world,65),2242],Store([],64,128));
    assert Fetch(code,2479) == Op(86,2480,0);
    assert 2242 in Destinations() && code[2242] == 91;
  }
  lemma Advance75(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(75,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(76,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2242,[2796423852,Observe(world,65)],Store([],64,128));
    assert Fetch(code,2242) == Op(91,2243,0);
  }
  lemma Advance76(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(76,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(77,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2243,[2796423852,Observe(world,65)],Store([],64,128));
    assert Fetch(code,2243) == Op(96,2245,64);
  }
  lemma Advance77(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(77,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(78,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2245,[2796423852,Observe(world,65),64],Store([],64,128));
    assert Fetch(code,2245) == Op(81,2246,0);
    StoreLoad([],64,128);
  }
  lemma Advance78(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(78,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(79,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2246,[2796423852,Observe(world,65),128],Store([],64,128));
    assert Fetch(code,2246) == Op(96,2248,1);
  }
  lemma Advance79(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(79,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(80,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2248,[2796423852,Observe(world,65),128,1],Store([],64,128));
    assert Fetch(code,2248) == Op(96,2250,1);
  }
  lemma Advance80(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(80,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(81,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2250,[2796423852,Observe(world,65),128,1,1],Store([],64,128));
    assert Fetch(code,2250) == Op(96,2252,160);
  }
  lemma Advance81(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(81,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(82,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2252,[2796423852,Observe(world,65),128,1,1,160],Store([],64,128));
    assert Fetch(code,2252) == Op(27,2253,0);
  }
  lemma Advance82(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(82,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(83,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2253,[2796423852,Observe(world,65),128,1,1461501637330902918203684832716283019655932542976],Store([],64,128));
    assert Fetch(code,2253) == Op(3,2254,0);
  }
  lemma Advance83(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(83,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(84,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2254,[2796423852,Observe(world,65),128,1461501637330902918203684832716283019655932542975],Store([],64,128));
    assert Fetch(code,2254) == Op(144,2255,0);
  }
  lemma Advance84(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(84,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(85,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2255,[2796423852,Observe(world,65),1461501637330902918203684832716283019655932542975,128],Store([],64,128));
    assert Fetch(code,2255) == Op(145,2256,0);
  }
  lemma Advance85(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(85,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(86,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2256,[2796423852,128,1461501637330902918203684832716283019655932542975,Observe(world,65)],Store([],64,128));
    assert Fetch(code,2256) == Op(22,2257,0);
  }
  lemma Advance86(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(86,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(87,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2257,[2796423852,128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)],Store([],64,128));
    assert Fetch(code,2257) == Op(129,2258,0);
  }
  lemma Advance87(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(87,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(88,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2258,[2796423852,128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975),128],Store([],64,128));
    assert Fetch(code,2258) == Op(82,2259,0);
    StoreLoad(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975));
  }
  lemma Advance88(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(88,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(89,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2259,[2796423852,128],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,2259) == Op(96,2261,32);
  }
  lemma Advance89(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(89,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(90,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2261,[2796423852,128,32],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,2261) == Op(1,2262,0);
  }
  lemma Advance90(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(90,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(91,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2262,[2796423852,160],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,2262) == Op(97,2265,1301);
  }
  lemma Advance91(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(91,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(92,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2265,[2796423852,160,1301],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,2265) == Op(86,2266,0);
    assert 1301 in Destinations() && code[1301] == 91;
  }
  lemma Advance92(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(92,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(93,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1301,[2796423852,160],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,1301) == Op(91,1302,0);
  }
  lemma Advance93(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(93,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(94,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1302,[2796423852,160],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,1302) == Op(96,1304,64);
  }
  lemma Advance94(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(94,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(95,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1304,[2796423852,160,64],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,1304) == Op(81,1305,0);
    StoreLoad([],64,128);
    StoreFrame(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975),64);
  }
  lemma Advance95(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(95,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(96,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1305,[2796423852,160,128],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,1305) == Op(128,1306,0);
  }
  lemma Advance96(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(96,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(97,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1306,[2796423852,160,128,128],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,1306) == Op(145,1307,0);
  }
  lemma Advance97(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(97,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(98,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1307,[2796423852,128,128,160],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,1307) == Op(3,1308,0);
  }
  lemma Advance98(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(98,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); Good(99,next,value,size,word,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1308,[2796423852,128,32],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,1308) == Op(144,1309,0);
  }
  lemma Advance99(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(99,state,value,size,word,world)
    ensures state.Running? && |state.stack| <= 6 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,world); next == Returned(Encode(Result(world),32))
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1309,[2796423852,32,128],Store(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975)));
    assert Fetch(code,1309) == Op(243,1310,0);
    K.Canonical(world.coinbase);
    StoreLoad(Store([],64,128),128,BitAnd(Observe(world,65),1461501637330902918203684832716283019655932542975));
  }
  lemma SemanticResult(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(87,state,value,size,word,world)
    ensures state.Running? && |state.stack| >= 2
    ensures state.stack[|state.stack|-1] == 128
    ensures state.stack[|state.stack|-2] == Result(world)
  { reveal Good(); K.Canonical(world.origin); K.Canonical(world.coinbase); }
  lemma SemanticWitness(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,world) && Good(87,state,value,size,word,world)
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
    Advance94(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance95(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance96(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance97(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance98(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
    Advance99(code,state,value,size,word,world);
    state := Step(code,Destinations(),state,value,size,word,world);
  }
}
