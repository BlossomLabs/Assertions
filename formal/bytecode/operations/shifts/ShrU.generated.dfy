// SPDX-License-Identifier: MIT
// Generated exact executed-byte certificate. Never edit directly.
include "Machine.dfy"
include "Binary.dfy"
module OperationsShiftShrU {
  import opened OperationsShiftMachine
  import K = OperationsShiftBinaryKernel
  function Result(a: Word, b: Word): Word { Right(a,b) }
  predicate Admitted(value: Word, size: Word, word: Word, a: Word, b: Word) {
    value == 0 && 68 <= size < 0x10000000000000000 && Selector(word) == 1978943386
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
    code[655] == 91 &&
    code[656] == 128 &&
    code[657] == 99 &&
    code[658] == 64 &&
    code[659] == 129 &&
    code[660] == 111 &&
    code[661] == 174 &&
    code[662] == 17 &&
    code[663] == 97 &&
    code[664] == 3 &&
    code[665] == 200 &&
    code[666] == 87 &&
    code[667] == 128 &&
    code[668] == 99 &&
    code[669] == 101 &&
    code[670] == 82 &&
    code[671] == 241 &&
    code[672] == 135 &&
    code[673] == 17 &&
    code[674] == 97 &&
    code[675] == 3 &&
    code[676] == 60 &&
    code[677] == 87 &&
    code[678] == 128 &&
    code[679] == 99 &&
    code[680] == 110 &&
    code[681] == 242 &&
    code[682] == 92 &&
    code[683] == 58 &&
    code[684] == 17 &&
    code[685] == 97 &&
    code[686] == 2 &&
    code[687] == 246 &&
    code[688] == 87 &&
    code[689] == 128 &&
    code[690] == 99 &&
    code[691] == 110 &&
    code[692] == 242 &&
    code[693] == 92 &&
    code[694] == 58 &&
    code[695] == 20 &&
    code[696] == 97 &&
    code[697] == 8 &&
    code[698] == 18 &&
    code[699] == 87 &&
    code[700] == 128 &&
    code[701] == 99 &&
    code[702] == 117 &&
    code[703] == 152 &&
    code[704] == 181 &&
    code[705] == 8 &&
    code[706] == 20 &&
    code[707] == 97 &&
    code[708] == 8 &&
    code[709] == 24 &&
    code[710] == 87 &&
    code[711] == 128 &&
    code[712] == 99 &&
    code[713] == 117 &&
    code[714] == 244 &&
    code[715] == 71 &&
    code[716] == 154 &&
    code[717] == 20 &&
    code[718] == 97 &&
    code[719] == 8 &&
    code[720] == 42 &&
    code[721] == 87 &&
    code[758] == 91 &&
    code[828] == 91 &&
    code[968] == 91 &&
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
    code[2066] == 91 &&
    code[2072] == 91 &&
    code[2090] == 91 &&
    code[2091] == 97 &&
    code[2092] == 5 &&
    code[2093] == 49 &&
    code[2094] == 97 &&
    code[2095] == 8 &&
    code[2096] == 56 &&
    code[2097] == 54 &&
    code[2098] == 96 &&
    code[2099] == 4 &&
    code[2100] == 97 &&
    code[2101] == 72 &&
    code[2102] == 218 &&
    code[2103] == 86 &&
    code[2104] == 91 &&
    code[2105] == 28 &&
    code[2106] == 144 &&
    code[2107] == 86 &&
    code[18650] == 91 &&
    code[18651] == 95 &&
    code[18652] == 95 &&
    code[18653] == 96 &&
    code[18654] == 64 &&
    code[18655] == 131 &&
    code[18656] == 133 &&
    code[18657] == 3 &&
    code[18658] == 18 &&
    code[18659] == 21 &&
    code[18660] == 97 &&
    code[18661] == 72 &&
    code[18662] == 235 &&
    code[18663] == 87 &&
    code[18667] == 91 &&
    code[18668] == 80 &&
    code[18669] == 80 &&
    code[18670] == 128 &&
    code[18671] == 53 &&
    code[18672] == 146 &&
    code[18673] == 96 &&
    code[18674] == 32 &&
    code[18675] == 144 &&
    code[18676] == 145 &&
    code[18677] == 1 &&
    code[18678] == 53 &&
    code[18679] == 145 &&
    code[18680] == 80 &&
    code[18681] == 86
  }
  function Destinations(): set<nat> { {15,655,758,828,968,1266,1301,1329,2066,2072,2090,2104,18650,18667} }
  opaque predicate Good(id: nat, state: State, value: Word, size: Word, word: Word, a: Word, b: Word) {
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
    else if id == 19 then state == Running(30,[1978943386],Store([],64,128))
    else if id == 20 then state == Running(31,[1978943386,1978943386],Store([],64,128))
    else if id == 21 then state == Running(36,[1978943386,1978943386,2180929414],Store([],64,128))
    else if id == 22 then state == Running(37,[1978943386,1],Store([],64,128))
    else if id == 23 then state == Running(40,[1978943386,1,655],Store([],64,128))
    else if id == 24 then state == Running(655,[1978943386],Store([],64,128))
    else if id == 25 then state == Running(656,[1978943386],Store([],64,128))
    else if id == 26 then state == Running(657,[1978943386,1978943386],Store([],64,128))
    else if id == 27 then state == Running(662,[1978943386,1978943386,1082224558],Store([],64,128))
    else if id == 28 then state == Running(663,[1978943386,0],Store([],64,128))
    else if id == 29 then state == Running(666,[1978943386,0,968],Store([],64,128))
    else if id == 30 then state == Running(667,[1978943386],Store([],64,128))
    else if id == 31 then state == Running(668,[1978943386,1978943386],Store([],64,128))
    else if id == 32 then state == Running(673,[1978943386,1978943386,1699934599],Store([],64,128))
    else if id == 33 then state == Running(674,[1978943386,0],Store([],64,128))
    else if id == 34 then state == Running(677,[1978943386,0,828],Store([],64,128))
    else if id == 35 then state == Running(678,[1978943386],Store([],64,128))
    else if id == 36 then state == Running(679,[1978943386,1978943386],Store([],64,128))
    else if id == 37 then state == Running(684,[1978943386,1978943386,1861377082],Store([],64,128))
    else if id == 38 then state == Running(685,[1978943386,0],Store([],64,128))
    else if id == 39 then state == Running(688,[1978943386,0,758],Store([],64,128))
    else if id == 40 then state == Running(689,[1978943386],Store([],64,128))
    else if id == 41 then state == Running(690,[1978943386,1978943386],Store([],64,128))
    else if id == 42 then state == Running(695,[1978943386,1978943386,1861377082],Store([],64,128))
    else if id == 43 then state == Running(696,[1978943386,0],Store([],64,128))
    else if id == 44 then state == Running(699,[1978943386,0,2066],Store([],64,128))
    else if id == 45 then state == Running(700,[1978943386],Store([],64,128))
    else if id == 46 then state == Running(701,[1978943386,1978943386],Store([],64,128))
    else if id == 47 then state == Running(706,[1978943386,1978943386,1972942088],Store([],64,128))
    else if id == 48 then state == Running(707,[1978943386,0],Store([],64,128))
    else if id == 49 then state == Running(710,[1978943386,0,2072],Store([],64,128))
    else if id == 50 then state == Running(711,[1978943386],Store([],64,128))
    else if id == 51 then state == Running(712,[1978943386,1978943386],Store([],64,128))
    else if id == 52 then state == Running(717,[1978943386,1978943386,1978943386],Store([],64,128))
    else if id == 53 then state == Running(718,[1978943386,1],Store([],64,128))
    else if id == 54 then state == Running(721,[1978943386,1,2090],Store([],64,128))
    else if id == 55 then state == Running(2090,[1978943386],Store([],64,128))
    else if id == 56 then state == Running(2091,[1978943386],Store([],64,128))
    else if id == 57 then state == Running(2094,[1978943386,1329],Store([],64,128))
    else if id == 58 then state == Running(2097,[1978943386,1329,2104],Store([],64,128))
    else if id == 59 then state == Running(2098,[1978943386,1329,2104,size],Store([],64,128))
    else if id == 60 then state == Running(2100,[1978943386,1329,2104,size,4],Store([],64,128))
    else if id == 61 then state == Running(2103,[1978943386,1329,2104,size,4,18650],Store([],64,128))
    else if id == 62 then state == Running(18650,[1978943386,1329,2104,size,4],Store([],64,128))
    else if id == 63 then state == Running(18651,[1978943386,1329,2104,size,4],Store([],64,128))
    else if id == 64 then state == Running(18652,[1978943386,1329,2104,size,4,0],Store([],64,128))
    else if id == 65 then state == Running(18653,[1978943386,1329,2104,size,4,0,0],Store([],64,128))
    else if id == 66 then state == Running(18655,[1978943386,1329,2104,size,4,0,0,64],Store([],64,128))
    else if id == 67 then state == Running(18656,[1978943386,1329,2104,size,4,0,0,64,4],Store([],64,128))
    else if id == 68 then state == Running(18657,[1978943386,1329,2104,size,4,0,0,64,4,size],Store([],64,128))
    else if id == 69 then state == Running(18658,[1978943386,1329,2104,size,4,0,0,64,((size)+Modulus()-(4))%Modulus()],Store([],64,128))
    else if id == 70 then state == Running(18659,[1978943386,1329,2104,size,4,0,0,(if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0)],Store([],64,128))
    else if id == 71 then state == Running(18660,[1978943386,1329,2104,size,4,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0) == 0 then 1 else 0)],Store([],64,128))
    else if id == 72 then state == Running(18663,[1978943386,1329,2104,size,4,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0) == 0 then 1 else 0),18667],Store([],64,128))
    else if id == 73 then state == Running(18667,[1978943386,1329,2104,size,4,0,0],Store([],64,128))
    else if id == 74 then state == Running(18668,[1978943386,1329,2104,size,4,0,0],Store([],64,128))
    else if id == 75 then state == Running(18669,[1978943386,1329,2104,size,4,0],Store([],64,128))
    else if id == 76 then state == Running(18670,[1978943386,1329,2104,size,4],Store([],64,128))
    else if id == 77 then state == Running(18671,[1978943386,1329,2104,size,4,4],Store([],64,128))
    else if id == 78 then state == Running(18672,[1978943386,1329,2104,size,4,a],Store([],64,128))
    else if id == 79 then state == Running(18673,[1978943386,1329,a,size,4,2104],Store([],64,128))
    else if id == 80 then state == Running(18675,[1978943386,1329,a,size,4,2104,32],Store([],64,128))
    else if id == 81 then state == Running(18676,[1978943386,1329,a,size,4,32,2104],Store([],64,128))
    else if id == 82 then state == Running(18677,[1978943386,1329,a,size,2104,32,4],Store([],64,128))
    else if id == 83 then state == Running(18678,[1978943386,1329,a,size,2104,36],Store([],64,128))
    else if id == 84 then state == Running(18679,[1978943386,1329,a,size,2104,b],Store([],64,128))
    else if id == 85 then state == Running(18680,[1978943386,1329,a,b,2104,size],Store([],64,128))
    else if id == 86 then state == Running(18681,[1978943386,1329,a,b,2104],Store([],64,128))
    else if id == 87 then state == Running(2104,[1978943386,1329,a,b],Store([],64,128))
    else if id == 88 then state == Running(2105,[1978943386,1329,a,b],Store([],64,128))
    else if id == 89 then state == Running(2106,[1978943386,1329,Right(a,b)],Store([],64,128))
    else if id == 90 then state == Running(2107,[1978943386,Right(a,b),1329],Store([],64,128))
    else if id == 91 then state == Running(1329,[1978943386,Right(a,b)],Store([],64,128))
    else if id == 92 then state == Running(1330,[1978943386,Right(a,b)],Store([],64,128))
    else if id == 93 then state == Running(1332,[1978943386,Right(a,b),64],Store([],64,128))
    else if id == 94 then state == Running(1333,[1978943386,Right(a,b),128],Store([],64,128))
    else if id == 95 then state == Running(1334,[1978943386,128,Right(a,b)],Store([],64,128))
    else if id == 96 then state == Running(1335,[1978943386,128,Right(a,b),128],Store([],64,128))
    else if id == 97 then state == Running(1336,[1978943386,128],Store(Store([],64,128),128,Right(a,b)))
    else if id == 98 then state == Running(1338,[1978943386,128,32],Store(Store([],64,128),128,Right(a,b)))
    else if id == 99 then state == Running(1339,[1978943386,160],Store(Store([],64,128),128,Right(a,b)))
    else if id == 100 then state == Running(1342,[1978943386,160,1301],Store(Store([],64,128),128,Right(a,b)))
    else if id == 101 then state == Running(1301,[1978943386,160],Store(Store([],64,128),128,Right(a,b)))
    else if id == 102 then state == Running(1302,[1978943386,160],Store(Store([],64,128),128,Right(a,b)))
    else if id == 103 then state == Running(1304,[1978943386,160,64],Store(Store([],64,128),128,Right(a,b)))
    else if id == 104 then state == Running(1305,[1978943386,160,128],Store(Store([],64,128),128,Right(a,b)))
    else if id == 105 then state == Running(1306,[1978943386,160,128,128],Store(Store([],64,128),128,Right(a,b)))
    else if id == 106 then state == Running(1307,[1978943386,128,128,160],Store(Store([],64,128),128,Right(a,b)))
    else if id == 107 then state == Running(1308,[1978943386,128,32],Store(Store([],64,128),128,Right(a,b)))
    else if id == 108 then state == Running(1309,[1978943386,32,128],Store(Store([],64,128),128,Right(a,b)))
    else false
  }
  lemma Advance0(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(0,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(1,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(0,[],[]);
    assert Fetch(code,0) == Op(96,2,128);
  }
  lemma Advance1(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(1,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(2,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2,[128],[]);
    assert Fetch(code,2) == Op(96,4,64);
  }
  lemma Advance2(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(2,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(3,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(4,[128,64],[]);
    assert Fetch(code,4) == Op(82,5,0);
    StoreLoad([],64,128);
  }
  lemma Advance3(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(3,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(4,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(5,[],Store([],64,128));
    assert Fetch(code,5) == Op(52,6,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(4,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(5,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(6,[value],Store([],64,128));
    assert Fetch(code,6) == Op(128,7,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(5,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(6,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(7,[value,value],Store([],64,128));
    assert Fetch(code,7) == Op(21,8,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(6,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(7,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8,[value,(if value == 0 then 1 else 0)],Store([],64,128));
    assert Fetch(code,8) == Op(97,11,15);
  }
  lemma Advance7(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(7,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(8,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(11,[value,(if value == 0 then 1 else 0),15],Store([],64,128));
    assert Fetch(code,11) == Op(87,12,0);
    assert 15 in Destinations() && code[15] == 91;
  }
  lemma Advance8(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(8,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(9,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(15,[value],Store([],64,128));
    assert Fetch(code,15) == Op(91,16,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(9,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(10,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(16,[value],Store([],64,128));
    assert Fetch(code,16) == Op(80,17,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(10,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(11,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17,[],Store([],64,128));
    assert Fetch(code,17) == Op(96,19,4);
  }
  lemma Advance11(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(11,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(12,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19,[4],Store([],64,128));
    assert Fetch(code,19) == Op(54,20,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(12,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(13,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(20,[4,size],Store([],64,128));
    assert Fetch(code,20) == Op(16,21,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(13,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(14,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(21,[(if (size) < (4) then 1 else 0)],Store([],64,128));
    assert Fetch(code,21) == Op(97,24,1266);
  }
  lemma Advance14(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(14,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(15,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(24,[(if (size) < (4) then 1 else 0),1266],Store([],64,128));
    assert Fetch(code,24) == Op(87,25,0);
    assert 1266 in Destinations() && code[1266] == 91;
  }
  lemma Advance15(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(15,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(16,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(25,[],Store([],64,128));
    assert Fetch(code,25) == Op(95,26,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(16,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(17,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(26,[0],Store([],64,128));
    assert Fetch(code,26) == Op(53,27,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(17,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(18,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(27,[word],Store([],64,128));
    assert Fetch(code,27) == Op(96,29,224);
  }
  lemma Advance18(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(18,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(19,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(29,[word,224],Store([],64,128));
    assert Fetch(code,29) == Op(28,30,0);
    SelectorRight(word);
  }
  lemma Advance19(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(19,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(20,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(30,[1978943386],Store([],64,128));
    assert Fetch(code,30) == Op(128,31,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(20,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(21,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(31,[1978943386,1978943386],Store([],64,128));
    assert Fetch(code,31) == Op(99,36,2180929414);
  }
  lemma Advance21(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(21,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(22,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(36,[1978943386,1978943386,2180929414],Store([],64,128));
    assert Fetch(code,36) == Op(17,37,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(22,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(23,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(37,[1978943386,1],Store([],64,128));
    assert Fetch(code,37) == Op(97,40,655);
  }
  lemma Advance23(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(23,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(24,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(40,[1978943386,1,655],Store([],64,128));
    assert Fetch(code,40) == Op(87,41,0);
    assert 655 in Destinations() && code[655] == 91;
  }
  lemma Advance24(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(24,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(25,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(655,[1978943386],Store([],64,128));
    assert Fetch(code,655) == Op(91,656,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(25,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(26,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(656,[1978943386],Store([],64,128));
    assert Fetch(code,656) == Op(128,657,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(26,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(27,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(657,[1978943386,1978943386],Store([],64,128));
    assert Fetch(code,657) == Op(99,662,1082224558);
  }
  lemma Advance27(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(27,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(28,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(662,[1978943386,1978943386,1082224558],Store([],64,128));
    assert Fetch(code,662) == Op(17,663,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(28,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(29,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(663,[1978943386,0],Store([],64,128));
    assert Fetch(code,663) == Op(97,666,968);
  }
  lemma Advance29(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(29,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(30,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(666,[1978943386,0,968],Store([],64,128));
    assert Fetch(code,666) == Op(87,667,0);
    assert 968 in Destinations() && code[968] == 91;
  }
  lemma Advance30(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(30,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(31,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(667,[1978943386],Store([],64,128));
    assert Fetch(code,667) == Op(128,668,0);
  }
  lemma Advance31(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(31,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(32,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(668,[1978943386,1978943386],Store([],64,128));
    assert Fetch(code,668) == Op(99,673,1699934599);
  }
  lemma Advance32(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(32,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(33,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(673,[1978943386,1978943386,1699934599],Store([],64,128));
    assert Fetch(code,673) == Op(17,674,0);
  }
  lemma Advance33(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(33,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(34,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(674,[1978943386,0],Store([],64,128));
    assert Fetch(code,674) == Op(97,677,828);
  }
  lemma Advance34(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(34,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(35,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(677,[1978943386,0,828],Store([],64,128));
    assert Fetch(code,677) == Op(87,678,0);
    assert 828 in Destinations() && code[828] == 91;
  }
  lemma Advance35(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(35,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(36,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(678,[1978943386],Store([],64,128));
    assert Fetch(code,678) == Op(128,679,0);
  }
  lemma Advance36(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(36,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(37,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(679,[1978943386,1978943386],Store([],64,128));
    assert Fetch(code,679) == Op(99,684,1861377082);
  }
  lemma Advance37(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(37,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(38,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(684,[1978943386,1978943386,1861377082],Store([],64,128));
    assert Fetch(code,684) == Op(17,685,0);
  }
  lemma Advance38(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(38,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(39,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(685,[1978943386,0],Store([],64,128));
    assert Fetch(code,685) == Op(97,688,758);
  }
  lemma Advance39(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(39,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(40,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(688,[1978943386,0,758],Store([],64,128));
    assert Fetch(code,688) == Op(87,689,0);
    assert 758 in Destinations() && code[758] == 91;
  }
  lemma Advance40(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(40,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(41,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(689,[1978943386],Store([],64,128));
    assert Fetch(code,689) == Op(128,690,0);
  }
  lemma Advance41(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(41,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(42,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(690,[1978943386,1978943386],Store([],64,128));
    assert Fetch(code,690) == Op(99,695,1861377082);
  }
  lemma Advance42(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(42,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(43,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(695,[1978943386,1978943386,1861377082],Store([],64,128));
    assert Fetch(code,695) == Op(20,696,0);
  }
  lemma Advance43(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(43,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(44,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(696,[1978943386,0],Store([],64,128));
    assert Fetch(code,696) == Op(97,699,2066);
  }
  lemma Advance44(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(44,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(45,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(699,[1978943386,0,2066],Store([],64,128));
    assert Fetch(code,699) == Op(87,700,0);
    assert 2066 in Destinations() && code[2066] == 91;
  }
  lemma Advance45(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(45,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(46,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(700,[1978943386],Store([],64,128));
    assert Fetch(code,700) == Op(128,701,0);
  }
  lemma Advance46(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(46,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(47,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(701,[1978943386,1978943386],Store([],64,128));
    assert Fetch(code,701) == Op(99,706,1972942088);
  }
  lemma Advance47(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(47,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(48,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(706,[1978943386,1978943386,1972942088],Store([],64,128));
    assert Fetch(code,706) == Op(20,707,0);
  }
  lemma Advance48(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(48,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(49,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(707,[1978943386,0],Store([],64,128));
    assert Fetch(code,707) == Op(97,710,2072);
  }
  lemma Advance49(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(49,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(50,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(710,[1978943386,0,2072],Store([],64,128));
    assert Fetch(code,710) == Op(87,711,0);
    assert 2072 in Destinations() && code[2072] == 91;
  }
  lemma Advance50(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(50,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(51,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(711,[1978943386],Store([],64,128));
    assert Fetch(code,711) == Op(128,712,0);
  }
  lemma Advance51(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(51,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(52,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(712,[1978943386,1978943386],Store([],64,128));
    assert Fetch(code,712) == Op(99,717,1978943386);
  }
  lemma Advance52(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(52,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(53,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(717,[1978943386,1978943386,1978943386],Store([],64,128));
    assert Fetch(code,717) == Op(20,718,0);
  }
  lemma Advance53(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(53,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(54,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(718,[1978943386,1],Store([],64,128));
    assert Fetch(code,718) == Op(97,721,2090);
  }
  lemma Advance54(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(54,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(55,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(721,[1978943386,1,2090],Store([],64,128));
    assert Fetch(code,721) == Op(87,722,0);
    assert 2090 in Destinations() && code[2090] == 91;
  }
  lemma Advance55(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(55,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(56,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2090,[1978943386],Store([],64,128));
    assert Fetch(code,2090) == Op(91,2091,0);
  }
  lemma Advance56(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(56,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(57,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2091,[1978943386],Store([],64,128));
    assert Fetch(code,2091) == Op(97,2094,1329);
  }
  lemma Advance57(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(57,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(58,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2094,[1978943386,1329],Store([],64,128));
    assert Fetch(code,2094) == Op(97,2097,2104);
  }
  lemma Advance58(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(58,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(59,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2097,[1978943386,1329,2104],Store([],64,128));
    assert Fetch(code,2097) == Op(54,2098,0);
  }
  lemma Advance59(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(59,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(60,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2098,[1978943386,1329,2104,size],Store([],64,128));
    assert Fetch(code,2098) == Op(96,2100,4);
  }
  lemma Advance60(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(60,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(61,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2100,[1978943386,1329,2104,size,4],Store([],64,128));
    assert Fetch(code,2100) == Op(97,2103,18650);
  }
  lemma Advance61(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(61,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(62,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2103,[1978943386,1329,2104,size,4,18650],Store([],64,128));
    assert Fetch(code,2103) == Op(86,2104,0);
    assert 18650 in Destinations() && code[18650] == 91;
  }
  lemma Advance62(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(62,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(63,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18650,[1978943386,1329,2104,size,4],Store([],64,128));
    assert Fetch(code,18650) == Op(91,18651,0);
  }
  lemma Advance63(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(63,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(64,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18651,[1978943386,1329,2104,size,4],Store([],64,128));
    assert Fetch(code,18651) == Op(95,18652,0);
  }
  lemma Advance64(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(64,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(65,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18652,[1978943386,1329,2104,size,4,0],Store([],64,128));
    assert Fetch(code,18652) == Op(95,18653,0);
  }
  lemma Advance65(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(65,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(66,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18653,[1978943386,1329,2104,size,4,0,0],Store([],64,128));
    assert Fetch(code,18653) == Op(96,18655,64);
  }
  lemma Advance66(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(66,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(67,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18655,[1978943386,1329,2104,size,4,0,0,64],Store([],64,128));
    assert Fetch(code,18655) == Op(131,18656,0);
  }
  lemma Advance67(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(67,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(68,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18656,[1978943386,1329,2104,size,4,0,0,64,4],Store([],64,128));
    assert Fetch(code,18656) == Op(133,18657,0);
  }
  lemma Advance68(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(68,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(69,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(18657,[1978943386,1329,2104,size,4,0,0,64,4,size],Store([],64,128));
    assert Fetch(code,18657) == Op(3,18658,0);
    var prefix: seq<Word> := [1978943386,1329,2104,size,4,0,0,64];
    assert state == Running(18657,prefix+[4,size],Store([],64,128));
    K.SubStep(code,Destinations(),18657,18658,prefix,Store([],64,128),size,4,value,size,word,a,b);
  }
  lemma Advance69(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(69,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(70,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18658,[1978943386,1329,2104,size,4,0,0,64,((size)+Modulus()-(4))%Modulus()],Store([],64,128));
    assert Fetch(code,18658) == Op(18,18659,0);
  }
  lemma Advance70(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(70,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(71,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18659,[1978943386,1329,2104,size,4,0,0,(if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0)],Store([],64,128));
    assert Fetch(code,18659) == Op(21,18660,0);
  }
  lemma Advance71(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(71,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(72,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18660,[1978943386,1329,2104,size,4,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0) == 0 then 1 else 0)],Store([],64,128));
    assert Fetch(code,18660) == Op(97,18663,18667);
  }
  lemma Advance72(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(72,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(73,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18663,[1978943386,1329,2104,size,4,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0) == 0 then 1 else 0),18667],Store([],64,128));
    assert Fetch(code,18663) == Op(87,18664,0);
    assert 18667 in Destinations() && code[18667] == 91;
  }
  lemma Advance73(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(73,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(74,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18667,[1978943386,1329,2104,size,4,0,0],Store([],64,128));
    assert Fetch(code,18667) == Op(91,18668,0);
  }
  lemma Advance74(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(74,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(75,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18668,[1978943386,1329,2104,size,4,0,0],Store([],64,128));
    assert Fetch(code,18668) == Op(80,18669,0);
  }
  lemma Advance75(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(75,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(76,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18669,[1978943386,1329,2104,size,4,0],Store([],64,128));
    assert Fetch(code,18669) == Op(80,18670,0);
  }
  lemma Advance76(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(76,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(77,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18670,[1978943386,1329,2104,size,4],Store([],64,128));
    assert Fetch(code,18670) == Op(128,18671,0);
  }
  lemma Advance77(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(77,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(78,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18671,[1978943386,1329,2104,size,4,4],Store([],64,128));
    assert Fetch(code,18671) == Op(53,18672,0);
  }
  lemma Advance78(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(78,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(79,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18672,[1978943386,1329,2104,size,4,a],Store([],64,128));
    assert Fetch(code,18672) == Op(146,18673,0);
  }
  lemma Advance79(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(79,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(80,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18673,[1978943386,1329,a,size,4,2104],Store([],64,128));
    assert Fetch(code,18673) == Op(96,18675,32);
  }
  lemma Advance80(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(80,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(81,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18675,[1978943386,1329,a,size,4,2104,32],Store([],64,128));
    assert Fetch(code,18675) == Op(144,18676,0);
  }
  lemma Advance81(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(81,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(82,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18676,[1978943386,1329,a,size,4,32,2104],Store([],64,128));
    assert Fetch(code,18676) == Op(145,18677,0);
  }
  lemma Advance82(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(82,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(83,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(18677,[1978943386,1329,a,size,2104,32,4],Store([],64,128));
    assert Fetch(code,18677) == Op(1,18678,0);
    var prefix: seq<Word> := [1978943386,1329,a,size,2104];
    assert state == Running(18677,prefix+[32,4],Store([],64,128));
    K.AddStep(code,Destinations(),18677,18678,prefix,Store([],64,128),4,32,value,size,word,a,b);
  }
  lemma Advance83(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(83,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(84,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18678,[1978943386,1329,a,size,2104,36],Store([],64,128));
    assert Fetch(code,18678) == Op(53,18679,0);
  }
  lemma Advance84(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(84,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(85,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18679,[1978943386,1329,a,size,2104,b],Store([],64,128));
    assert Fetch(code,18679) == Op(145,18680,0);
  }
  lemma Advance85(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(85,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(86,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18680,[1978943386,1329,a,b,2104,size],Store([],64,128));
    assert Fetch(code,18680) == Op(80,18681,0);
  }
  lemma Advance86(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(86,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(87,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18681,[1978943386,1329,a,b,2104],Store([],64,128));
    assert Fetch(code,18681) == Op(86,18682,0);
    assert 2104 in Destinations() && code[2104] == 91;
  }
  lemma Advance87(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(87,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(88,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2104,[1978943386,1329,a,b],Store([],64,128));
    assert Fetch(code,2104) == Op(91,2105,0);
  }
  lemma Advance88(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(88,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(89,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2105,[1978943386,1329,a,b],Store([],64,128));
    assert Fetch(code,2105) == Op(28,2106,0);
    SelectorRight(word);
  }
  lemma Advance89(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(89,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(90,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2106,[1978943386,1329,Right(a,b)],Store([],64,128));
    assert Fetch(code,2106) == Op(144,2107,0);
  }
  lemma Advance90(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(90,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(91,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2107,[1978943386,Right(a,b),1329],Store([],64,128));
    assert Fetch(code,2107) == Op(86,2108,0);
    assert 1329 in Destinations() && code[1329] == 91;
  }
  lemma Advance91(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(91,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(92,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1329,[1978943386,Right(a,b)],Store([],64,128));
    assert Fetch(code,1329) == Op(91,1330,0);
  }
  lemma Advance92(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(92,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(93,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1330,[1978943386,Right(a,b)],Store([],64,128));
    assert Fetch(code,1330) == Op(96,1332,64);
  }
  lemma Advance93(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(93,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(94,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1332,[1978943386,Right(a,b),64],Store([],64,128));
    assert Fetch(code,1332) == Op(81,1333,0);
    StoreLoad([],64,128);
  }
  lemma Advance94(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(94,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(95,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1333,[1978943386,Right(a,b),128],Store([],64,128));
    assert Fetch(code,1333) == Op(144,1334,0);
  }
  lemma Advance95(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(95,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(96,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1334,[1978943386,128,Right(a,b)],Store([],64,128));
    assert Fetch(code,1334) == Op(129,1335,0);
  }
  lemma Advance96(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(96,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(97,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1335,[1978943386,128,Right(a,b),128],Store([],64,128));
    assert Fetch(code,1335) == Op(82,1336,0);
    StoreLoad(Store([],64,128),128,Right(a,b));
  }
  lemma Advance97(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(97,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(98,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1336,[1978943386,128],Store(Store([],64,128),128,Right(a,b)));
    assert Fetch(code,1336) == Op(96,1338,32);
  }
  lemma Advance98(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(98,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(99,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(1338,[1978943386,128,32],Store(Store([],64,128),128,Right(a,b)));
    assert Fetch(code,1338) == Op(1,1339,0);
    var prefix: seq<Word> := [1978943386];
    assert state == Running(1338,prefix+[128,32],Store(Store([],64,128),128,Right(a,b)));
    K.AddStep(code,Destinations(),1338,1339,prefix,Store(Store([],64,128),128,Right(a,b)),32,128,value,size,word,a,b);
  }
  lemma Advance99(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(99,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(100,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1339,[1978943386,160],Store(Store([],64,128),128,Right(a,b)));
    assert Fetch(code,1339) == Op(97,1342,1301);
  }
  lemma Advance100(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(100,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(101,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1342,[1978943386,160,1301],Store(Store([],64,128),128,Right(a,b)));
    assert Fetch(code,1342) == Op(86,1343,0);
    assert 1301 in Destinations() && code[1301] == 91;
  }
  lemma Advance101(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(101,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(102,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1301,[1978943386,160],Store(Store([],64,128),128,Right(a,b)));
    assert Fetch(code,1301) == Op(91,1302,0);
  }
  lemma Advance102(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(102,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(103,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1302,[1978943386,160],Store(Store([],64,128),128,Right(a,b)));
    assert Fetch(code,1302) == Op(96,1304,64);
  }
  lemma Advance103(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(103,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(104,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1304,[1978943386,160,64],Store(Store([],64,128),128,Right(a,b)));
    assert Fetch(code,1304) == Op(81,1305,0);
    StoreLoad([],64,128);
    StoreFrame(Store([],64,128),128,Right(a,b),64);
  }
  lemma Advance104(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(104,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(105,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1305,[1978943386,160,128],Store(Store([],64,128),128,Right(a,b)));
    assert Fetch(code,1305) == Op(128,1306,0);
  }
  lemma Advance105(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(105,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(106,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1306,[1978943386,160,128,128],Store(Store([],64,128),128,Right(a,b)));
    assert Fetch(code,1306) == Op(145,1307,0);
  }
  lemma Advance106(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(106,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(107,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(1307,[1978943386,128,128,160],Store(Store([],64,128),128,Right(a,b)));
    assert Fetch(code,1307) == Op(3,1308,0);
    var prefix: seq<Word> := [1978943386,128];
    assert state == Running(1307,prefix+[128,160],Store(Store([],64,128),128,Right(a,b)));
    K.SubStep(code,Destinations(),1307,1308,prefix,Store(Store([],64,128),128,Right(a,b)),160,128,value,size,word,a,b);
  }
  lemma Advance107(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(107,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(108,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1308,[1978943386,128,32],Store(Store([],64,128),128,Right(a,b)));
    assert Fetch(code,1308) == Op(144,1309,0);
  }
  lemma Advance108(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(108,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); next == Returned(Encode(Result(a,b),32))
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1309,[1978943386,32,128],Store(Store([],64,128),128,Right(a,b)));
    assert Fetch(code,1309) == Op(243,1310,0);
    StoreLoad(Store([],64,128),128,Right(a,b));
  }
  lemma SemanticResult(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(96,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| >= 2
    ensures state.stack[|state.stack|-1] == 128
    ensures state.stack[|state.stack|-2] == Result(a,b)
  {{
     reveal Good();
   }}
  lemma SemanticWitness(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(96,state,value,size,word,a,b)
    requires a == 1 && b == 1
    ensures state.Running? && |state.stack| >= 2
    ensures state.stack[|state.stack|-1] == 128
    ensures state.stack[|state.stack|-2] == Result(a,b)
  {{
     reveal Good(); WitnessShifts();
   }}
  lemma Start(value: Word, size: Word, word: Word, a: Word, b: Word)
    ensures Good(0,Running(0,[],[]),value,size,word,a,b)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, value: Word, size: Word, word: Word, a: Word, b: Word) returns (state: State)
    requires Matches(code) && Admitted(value,size,word,a,b)
    ensures state == Returned(Encode(Result(a,b),32))
  {
    Start(value,size,word,a,b);
    state := Running(0,[],[]);
    Advance0(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance1(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance2(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance3(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance4(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance5(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance6(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance7(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance8(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance9(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance10(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance11(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance12(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance13(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance14(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance15(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance16(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance17(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance18(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance19(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance20(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance21(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance22(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance23(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance24(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance25(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance26(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance27(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance28(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance29(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance30(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance31(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance32(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance33(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance34(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance35(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance36(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance37(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance38(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance39(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance40(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance41(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance42(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance43(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance44(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance45(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance46(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance47(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance48(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance49(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance50(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance51(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance52(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance53(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance54(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance55(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance56(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance57(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance58(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance59(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance60(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance61(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance62(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance63(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance64(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance65(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance66(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance67(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance68(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance69(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance70(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance71(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance72(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance73(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance74(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance75(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance76(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance77(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance78(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance79(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance80(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance81(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance82(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance83(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance84(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance85(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance86(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance87(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance88(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance89(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance90(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance91(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance92(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance93(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance94(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance95(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance96(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance97(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance98(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance99(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance100(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance101(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance102(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance103(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance104(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance105(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance106(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance107(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance108(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
  }
}
