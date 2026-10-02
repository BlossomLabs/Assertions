// SPDX-License-Identifier: MIT
// Generated exact executed-byte certificate. Never edit directly.
include "Machine.dfy"
include "Binary.dfy"
module OperationsIndexedEnvironmentBlobHash {
  import opened OperationsIndexedEnvironmentMachine
  import K = OperationsIndexedEnvironmentBinaryKernel
  function Result(world: World,a: Word): Word { BlobHash(world,a) }
  predicate Admitted(value: Word, size: Word, word: Word, a: Word, world: World) {
    value == 0 && 36 <= size < 0x10000000000000000 && Selector(word) == 195382834
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
    code[968] == 91 &&
    code[969] == 128 &&
    code[970] == 99 &&
    code[971] == 36 &&
    code[972] == 141 &&
    code[973] == 108 &&
    code[974] == 56 &&
    code[975] == 17 &&
    code[976] == 97 &&
    code[977] == 4 &&
    code[978] == 106 &&
    code[979] == 87 &&
    code[1130] == 91 &&
    code[1131] == 128 &&
    code[1132] == 99 &&
    code[1133] == 24 &&
    code[1134] == 90 &&
    code[1135] == 240 &&
    code[1136] == 173 &&
    code[1137] == 17 &&
    code[1138] == 97 &&
    code[1139] == 4 &&
    code[1140] == 187 &&
    code[1141] == 87 &&
    code[1211] == 91 &&
    code[1212] == 128 &&
    code[1213] == 98 &&
    code[1214] == 19 &&
    code[1215] == 107 &&
    code[1216] == 184 &&
    code[1217] == 20 &&
    code[1218] == 97 &&
    code[1219] == 4 &&
    code[1220] == 246 &&
    code[1221] == 87 &&
    code[1222] == 128 &&
    code[1223] == 99 &&
    code[1224] == 8 &&
    code[1225] == 25 &&
    code[1226] == 138 &&
    code[1227] == 221 &&
    code[1228] == 20 &&
    code[1229] == 97 &&
    code[1230] == 5 &&
    code[1231] == 30 &&
    code[1232] == 87 &&
    code[1233] == 128 &&
    code[1234] == 99 &&
    code[1235] == 9 &&
    code[1236] == 172 &&
    code[1237] == 170 &&
    code[1238] == 150 &&
    code[1239] == 20 &&
    code[1240] == 97 &&
    code[1241] == 5 &&
    code[1242] == 63 &&
    code[1243] == 87 &&
    code[1244] == 128 &&
    code[1245] == 99 &&
    code[1246] == 11 &&
    code[1247] == 165 &&
    code[1248] == 78 &&
    code[1249] == 50 &&
    code[1250] == 20 &&
    code[1251] == 97 &&
    code[1252] == 5 &&
    code[1253] == 95 &&
    code[1254] == 87 &&
    code[1266] == 91 &&
    code[1270] == 91 &&
    code[1301] == 91 &&
    code[1302] == 96 &&
    code[1303] == 64 &&
    code[1304] == 81 &&
    code[1305] == 128 &&
    code[1306] == 145 &&
    code[1307] == 3 &&
    code[1308] == 144 &&
    code[1309] == 243 &&
    code[1310] == 91 &&
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
    code[1343] == 91 &&
    code[1375] == 91 &&
    code[1376] == 97 &&
    code[1377] == 5 &&
    code[1378] == 49 &&
    code[1379] == 97 &&
    code[1380] == 5 &&
    code[1381] == 109 &&
    code[1382] == 54 &&
    code[1383] == 96 &&
    code[1384] == 4 &&
    code[1385] == 97 &&
    code[1386] == 74 &&
    code[1387] == 11 &&
    code[1388] == 86 &&
    code[1389] == 91 &&
    code[1390] == 73 &&
    code[1391] == 144 &&
    code[1392] == 86 &&
    code[18955] == 91 &&
    code[18956] == 95 &&
    code[18957] == 96 &&
    code[18958] == 32 &&
    code[18959] == 130 &&
    code[18960] == 132 &&
    code[18961] == 3 &&
    code[18962] == 18 &&
    code[18963] == 21 &&
    code[18964] == 97 &&
    code[18965] == 74 &&
    code[18966] == 27 &&
    code[18967] == 87 &&
    code[18971] == 91 &&
    code[18972] == 80 &&
    code[18973] == 53 &&
    code[18974] == 145 &&
    code[18975] == 144 &&
    code[18976] == 80 &&
    code[18977] == 86
  }
  function Destinations(): set<nat> { {15,655,968,1130,1211,1266,1270,1301,1310,1329,1343,1375,1389,18955,18971} }
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
    else if id == 19 then state == Running(30,[195382834],Store([],64,128))
    else if id == 20 then state == Running(31,[195382834,195382834],Store([],64,128))
    else if id == 21 then state == Running(36,[195382834,195382834,2180929414],Store([],64,128))
    else if id == 22 then state == Running(37,[195382834,1],Store([],64,128))
    else if id == 23 then state == Running(40,[195382834,1,655],Store([],64,128))
    else if id == 24 then state == Running(655,[195382834],Store([],64,128))
    else if id == 25 then state == Running(656,[195382834],Store([],64,128))
    else if id == 26 then state == Running(657,[195382834,195382834],Store([],64,128))
    else if id == 27 then state == Running(662,[195382834,195382834,1082224558],Store([],64,128))
    else if id == 28 then state == Running(663,[195382834,1],Store([],64,128))
    else if id == 29 then state == Running(666,[195382834,1,968],Store([],64,128))
    else if id == 30 then state == Running(968,[195382834],Store([],64,128))
    else if id == 31 then state == Running(969,[195382834],Store([],64,128))
    else if id == 32 then state == Running(970,[195382834,195382834],Store([],64,128))
    else if id == 33 then state == Running(975,[195382834,195382834,613248056],Store([],64,128))
    else if id == 34 then state == Running(976,[195382834,1],Store([],64,128))
    else if id == 35 then state == Running(979,[195382834,1,1130],Store([],64,128))
    else if id == 36 then state == Running(1130,[195382834],Store([],64,128))
    else if id == 37 then state == Running(1131,[195382834],Store([],64,128))
    else if id == 38 then state == Running(1132,[195382834,195382834],Store([],64,128))
    else if id == 39 then state == Running(1137,[195382834,195382834,408613037],Store([],64,128))
    else if id == 40 then state == Running(1138,[195382834,1],Store([],64,128))
    else if id == 41 then state == Running(1141,[195382834,1,1211],Store([],64,128))
    else if id == 42 then state == Running(1211,[195382834],Store([],64,128))
    else if id == 43 then state == Running(1212,[195382834],Store([],64,128))
    else if id == 44 then state == Running(1213,[195382834,195382834],Store([],64,128))
    else if id == 45 then state == Running(1217,[195382834,195382834,1272760],Store([],64,128))
    else if id == 46 then state == Running(1218,[195382834,0],Store([],64,128))
    else if id == 47 then state == Running(1221,[195382834,0,1270],Store([],64,128))
    else if id == 48 then state == Running(1222,[195382834],Store([],64,128))
    else if id == 49 then state == Running(1223,[195382834,195382834],Store([],64,128))
    else if id == 50 then state == Running(1228,[195382834,195382834,135891677],Store([],64,128))
    else if id == 51 then state == Running(1229,[195382834,0],Store([],64,128))
    else if id == 52 then state == Running(1232,[195382834,0,1310],Store([],64,128))
    else if id == 53 then state == Running(1233,[195382834],Store([],64,128))
    else if id == 54 then state == Running(1234,[195382834,195382834],Store([],64,128))
    else if id == 55 then state == Running(1239,[195382834,195382834,162310806],Store([],64,128))
    else if id == 56 then state == Running(1240,[195382834,0],Store([],64,128))
    else if id == 57 then state == Running(1243,[195382834,0,1343],Store([],64,128))
    else if id == 58 then state == Running(1244,[195382834],Store([],64,128))
    else if id == 59 then state == Running(1245,[195382834,195382834],Store([],64,128))
    else if id == 60 then state == Running(1250,[195382834,195382834,195382834],Store([],64,128))
    else if id == 61 then state == Running(1251,[195382834,1],Store([],64,128))
    else if id == 62 then state == Running(1254,[195382834,1,1375],Store([],64,128))
    else if id == 63 then state == Running(1375,[195382834],Store([],64,128))
    else if id == 64 then state == Running(1376,[195382834],Store([],64,128))
    else if id == 65 then state == Running(1379,[195382834,1329],Store([],64,128))
    else if id == 66 then state == Running(1382,[195382834,1329,1389],Store([],64,128))
    else if id == 67 then state == Running(1383,[195382834,1329,1389,size],Store([],64,128))
    else if id == 68 then state == Running(1385,[195382834,1329,1389,size,4],Store([],64,128))
    else if id == 69 then state == Running(1388,[195382834,1329,1389,size,4,18955],Store([],64,128))
    else if id == 70 then state == Running(18955,[195382834,1329,1389,size,4],Store([],64,128))
    else if id == 71 then state == Running(18956,[195382834,1329,1389,size,4],Store([],64,128))
    else if id == 72 then state == Running(18957,[195382834,1329,1389,size,4,0],Store([],64,128))
    else if id == 73 then state == Running(18959,[195382834,1329,1389,size,4,0,32],Store([],64,128))
    else if id == 74 then state == Running(18960,[195382834,1329,1389,size,4,0,32,4],Store([],64,128))
    else if id == 75 then state == Running(18961,[195382834,1329,1389,size,4,0,32,4,size],Store([],64,128))
    else if id == 76 then state == Running(18962,[195382834,1329,1389,size,4,0,32,((size)+Modulus()-(4))%Modulus()],Store([],64,128))
    else if id == 77 then state == Running(18963,[195382834,1329,1389,size,4,0,(if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(32) then 1 else 0)],Store([],64,128))
    else if id == 78 then state == Running(18964,[195382834,1329,1389,size,4,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(32) then 1 else 0) == 0 then 1 else 0)],Store([],64,128))
    else if id == 79 then state == Running(18967,[195382834,1329,1389,size,4,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(32) then 1 else 0) == 0 then 1 else 0),18971],Store([],64,128))
    else if id == 80 then state == Running(18971,[195382834,1329,1389,size,4,0],Store([],64,128))
    else if id == 81 then state == Running(18972,[195382834,1329,1389,size,4,0],Store([],64,128))
    else if id == 82 then state == Running(18973,[195382834,1329,1389,size,4],Store([],64,128))
    else if id == 83 then state == Running(18974,[195382834,1329,1389,size,a],Store([],64,128))
    else if id == 84 then state == Running(18975,[195382834,1329,a,size,1389],Store([],64,128))
    else if id == 85 then state == Running(18976,[195382834,1329,a,1389,size],Store([],64,128))
    else if id == 86 then state == Running(18977,[195382834,1329,a,1389],Store([],64,128))
    else if id == 87 then state == Running(1389,[195382834,1329,a],Store([],64,128))
    else if id == 88 then state == Running(1390,[195382834,1329,a],Store([],64,128))
    else if id == 89 then state == Running(1391,[195382834,1329,Observe(world,73,a)],Store([],64,128))
    else if id == 90 then state == Running(1392,[195382834,Observe(world,73,a),1329],Store([],64,128))
    else if id == 91 then state == Running(1329,[195382834,Observe(world,73,a)],Store([],64,128))
    else if id == 92 then state == Running(1330,[195382834,Observe(world,73,a)],Store([],64,128))
    else if id == 93 then state == Running(1332,[195382834,Observe(world,73,a),64],Store([],64,128))
    else if id == 94 then state == Running(1333,[195382834,Observe(world,73,a),128],Store([],64,128))
    else if id == 95 then state == Running(1334,[195382834,128,Observe(world,73,a)],Store([],64,128))
    else if id == 96 then state == Running(1335,[195382834,128,Observe(world,73,a),128],Store([],64,128))
    else if id == 97 then state == Running(1336,[195382834,128],Store(Store([],64,128),128,Observe(world,73,a)))
    else if id == 98 then state == Running(1338,[195382834,128,32],Store(Store([],64,128),128,Observe(world,73,a)))
    else if id == 99 then state == Running(1339,[195382834,160],Store(Store([],64,128),128,Observe(world,73,a)))
    else if id == 100 then state == Running(1342,[195382834,160,1301],Store(Store([],64,128),128,Observe(world,73,a)))
    else if id == 101 then state == Running(1301,[195382834,160],Store(Store([],64,128),128,Observe(world,73,a)))
    else if id == 102 then state == Running(1302,[195382834,160],Store(Store([],64,128),128,Observe(world,73,a)))
    else if id == 103 then state == Running(1304,[195382834,160,64],Store(Store([],64,128),128,Observe(world,73,a)))
    else if id == 104 then state == Running(1305,[195382834,160,128],Store(Store([],64,128),128,Observe(world,73,a)))
    else if id == 105 then state == Running(1306,[195382834,160,128,128],Store(Store([],64,128),128,Observe(world,73,a)))
    else if id == 106 then state == Running(1307,[195382834,128,128,160],Store(Store([],64,128),128,Observe(world,73,a)))
    else if id == 107 then state == Running(1308,[195382834,128,32],Store(Store([],64,128),128,Observe(world,73,a)))
    else if id == 108 then state == Running(1309,[195382834,32,128],Store(Store([],64,128),128,Observe(world,73,a)))
    else false
  }
  lemma Advance0(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(0,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(8,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(11,[value,(if value == 0 then 1 else 0),15],Store([],64,128));
    assert Fetch(code,11) == Op(87,12,0);
    assert 15 in Destinations() && code[15] == 91;
  }
  lemma Advance8(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(8,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(15,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(24,[(if (size) < (4) then 1 else 0),1266],Store([],64,128));
    assert Fetch(code,24) == Op(87,25,0);
    assert 1266 in Destinations() && code[1266] == 91;
  }
  lemma Advance15(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(15,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(20,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(30,[195382834],Store([],64,128));
    assert Fetch(code,30) == Op(128,31,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(20,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(21,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(31,[195382834,195382834],Store([],64,128));
    assert Fetch(code,31) == Op(99,36,2180929414);
  }
  lemma Advance21(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(21,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(22,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(36,[195382834,195382834,2180929414],Store([],64,128));
    assert Fetch(code,36) == Op(17,37,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(22,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(23,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(37,[195382834,1],Store([],64,128));
    assert Fetch(code,37) == Op(97,40,655);
  }
  lemma Advance23(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(23,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(24,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(40,[195382834,1,655],Store([],64,128));
    assert Fetch(code,40) == Op(87,41,0);
    assert 655 in Destinations() && code[655] == 91;
  }
  lemma Advance24(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(24,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(25,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(655,[195382834],Store([],64,128));
    assert Fetch(code,655) == Op(91,656,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(25,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(26,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(656,[195382834],Store([],64,128));
    assert Fetch(code,656) == Op(128,657,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(26,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(27,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(657,[195382834,195382834],Store([],64,128));
    assert Fetch(code,657) == Op(99,662,1082224558);
  }
  lemma Advance27(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(27,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(28,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(662,[195382834,195382834,1082224558],Store([],64,128));
    assert Fetch(code,662) == Op(17,663,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(28,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(29,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(663,[195382834,1],Store([],64,128));
    assert Fetch(code,663) == Op(97,666,968);
  }
  lemma Advance29(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(29,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(30,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(666,[195382834,1,968],Store([],64,128));
    assert Fetch(code,666) == Op(87,667,0);
    assert 968 in Destinations() && code[968] == 91;
  }
  lemma Advance30(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(30,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(31,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(968,[195382834],Store([],64,128));
    assert Fetch(code,968) == Op(91,969,0);
  }
  lemma Advance31(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(31,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(32,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(969,[195382834],Store([],64,128));
    assert Fetch(code,969) == Op(128,970,0);
  }
  lemma Advance32(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(32,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(33,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(970,[195382834,195382834],Store([],64,128));
    assert Fetch(code,970) == Op(99,975,613248056);
  }
  lemma Advance33(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(33,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(34,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(975,[195382834,195382834,613248056],Store([],64,128));
    assert Fetch(code,975) == Op(17,976,0);
  }
  lemma Advance34(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(34,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(35,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(976,[195382834,1],Store([],64,128));
    assert Fetch(code,976) == Op(97,979,1130);
  }
  lemma Advance35(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(35,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(36,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(979,[195382834,1,1130],Store([],64,128));
    assert Fetch(code,979) == Op(87,980,0);
    assert 1130 in Destinations() && code[1130] == 91;
  }
  lemma Advance36(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(36,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(37,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1130,[195382834],Store([],64,128));
    assert Fetch(code,1130) == Op(91,1131,0);
  }
  lemma Advance37(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(37,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(38,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1131,[195382834],Store([],64,128));
    assert Fetch(code,1131) == Op(128,1132,0);
  }
  lemma Advance38(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(38,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(39,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1132,[195382834,195382834],Store([],64,128));
    assert Fetch(code,1132) == Op(99,1137,408613037);
  }
  lemma Advance39(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(39,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(40,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1137,[195382834,195382834,408613037],Store([],64,128));
    assert Fetch(code,1137) == Op(17,1138,0);
  }
  lemma Advance40(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(40,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(41,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1138,[195382834,1],Store([],64,128));
    assert Fetch(code,1138) == Op(97,1141,1211);
  }
  lemma Advance41(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(41,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(42,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1141,[195382834,1,1211],Store([],64,128));
    assert Fetch(code,1141) == Op(87,1142,0);
    assert 1211 in Destinations() && code[1211] == 91;
  }
  lemma Advance42(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(42,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(43,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1211,[195382834],Store([],64,128));
    assert Fetch(code,1211) == Op(91,1212,0);
  }
  lemma Advance43(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(43,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(44,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1212,[195382834],Store([],64,128));
    assert Fetch(code,1212) == Op(128,1213,0);
  }
  lemma Advance44(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(44,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(45,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1213,[195382834,195382834],Store([],64,128));
    assert Fetch(code,1213) == Op(98,1217,1272760);
  }
  lemma Advance45(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(45,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(46,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1217,[195382834,195382834,1272760],Store([],64,128));
    assert Fetch(code,1217) == Op(20,1218,0);
  }
  lemma Advance46(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(46,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(47,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1218,[195382834,0],Store([],64,128));
    assert Fetch(code,1218) == Op(97,1221,1270);
  }
  lemma Advance47(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(47,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(48,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1221,[195382834,0,1270],Store([],64,128));
    assert Fetch(code,1221) == Op(87,1222,0);
    assert 1270 in Destinations() && code[1270] == 91;
  }
  lemma Advance48(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(48,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(49,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1222,[195382834],Store([],64,128));
    assert Fetch(code,1222) == Op(128,1223,0);
  }
  lemma Advance49(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(49,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(50,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1223,[195382834,195382834],Store([],64,128));
    assert Fetch(code,1223) == Op(99,1228,135891677);
  }
  lemma Advance50(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(50,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(51,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1228,[195382834,195382834,135891677],Store([],64,128));
    assert Fetch(code,1228) == Op(20,1229,0);
  }
  lemma Advance51(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(51,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(52,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1229,[195382834,0],Store([],64,128));
    assert Fetch(code,1229) == Op(97,1232,1310);
  }
  lemma Advance52(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(52,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(53,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1232,[195382834,0,1310],Store([],64,128));
    assert Fetch(code,1232) == Op(87,1233,0);
    assert 1310 in Destinations() && code[1310] == 91;
  }
  lemma Advance53(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(53,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(54,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1233,[195382834],Store([],64,128));
    assert Fetch(code,1233) == Op(128,1234,0);
  }
  lemma Advance54(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(54,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(55,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1234,[195382834,195382834],Store([],64,128));
    assert Fetch(code,1234) == Op(99,1239,162310806);
  }
  lemma Advance55(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(55,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(56,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1239,[195382834,195382834,162310806],Store([],64,128));
    assert Fetch(code,1239) == Op(20,1240,0);
  }
  lemma Advance56(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(56,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(57,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1240,[195382834,0],Store([],64,128));
    assert Fetch(code,1240) == Op(97,1243,1343);
  }
  lemma Advance57(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(57,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(58,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1243,[195382834,0,1343],Store([],64,128));
    assert Fetch(code,1243) == Op(87,1244,0);
    assert 1343 in Destinations() && code[1343] == 91;
  }
  lemma Advance58(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(58,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(59,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1244,[195382834],Store([],64,128));
    assert Fetch(code,1244) == Op(128,1245,0);
  }
  lemma Advance59(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(59,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(60,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1245,[195382834,195382834],Store([],64,128));
    assert Fetch(code,1245) == Op(99,1250,195382834);
  }
  lemma Advance60(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(60,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(61,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1250,[195382834,195382834,195382834],Store([],64,128));
    assert Fetch(code,1250) == Op(20,1251,0);
  }
  lemma Advance61(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(61,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(62,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1251,[195382834,1],Store([],64,128));
    assert Fetch(code,1251) == Op(97,1254,1375);
  }
  lemma Advance62(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(62,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(63,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1254,[195382834,1,1375],Store([],64,128));
    assert Fetch(code,1254) == Op(87,1255,0);
    assert 1375 in Destinations() && code[1375] == 91;
  }
  lemma Advance63(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(63,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(64,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1375,[195382834],Store([],64,128));
    assert Fetch(code,1375) == Op(91,1376,0);
  }
  lemma Advance64(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(64,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(65,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1376,[195382834],Store([],64,128));
    assert Fetch(code,1376) == Op(97,1379,1329);
  }
  lemma Advance65(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(65,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(66,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1379,[195382834,1329],Store([],64,128));
    assert Fetch(code,1379) == Op(97,1382,1389);
  }
  lemma Advance66(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(66,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(67,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1382,[195382834,1329,1389],Store([],64,128));
    assert Fetch(code,1382) == Op(54,1383,0);
  }
  lemma Advance67(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(67,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(68,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1383,[195382834,1329,1389,size],Store([],64,128));
    assert Fetch(code,1383) == Op(96,1385,4);
  }
  lemma Advance68(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(68,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(69,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1385,[195382834,1329,1389,size,4],Store([],64,128));
    assert Fetch(code,1385) == Op(97,1388,18955);
  }
  lemma Advance69(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(69,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(70,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1388,[195382834,1329,1389,size,4,18955],Store([],64,128));
    assert Fetch(code,1388) == Op(86,1389,0);
    assert 18955 in Destinations() && code[18955] == 91;
  }
  lemma Advance70(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(70,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(71,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18955,[195382834,1329,1389,size,4],Store([],64,128));
    assert Fetch(code,18955) == Op(91,18956,0);
  }
  lemma Advance71(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(71,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(72,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18956,[195382834,1329,1389,size,4],Store([],64,128));
    assert Fetch(code,18956) == Op(95,18957,0);
  }
  lemma Advance72(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(72,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(73,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18957,[195382834,1329,1389,size,4,0],Store([],64,128));
    assert Fetch(code,18957) == Op(96,18959,32);
  }
  lemma Advance73(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(73,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(74,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18959,[195382834,1329,1389,size,4,0,32],Store([],64,128));
    assert Fetch(code,18959) == Op(130,18960,0);
  }
  lemma Advance74(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(74,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(75,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18960,[195382834,1329,1389,size,4,0,32,4],Store([],64,128));
    assert Fetch(code,18960) == Op(132,18961,0);
  }
  lemma Advance75(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(75,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(76,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(18961,[195382834,1329,1389,size,4,0,32,4,size],Store([],64,128));
    assert Fetch(code,18961) == Op(3,18962,0);
    var prefix: seq<Word> := [195382834,1329,1389,size,4,0,32];
    assert state == Running(18961,prefix+[4,size],Store([],64,128));
    K.SubStep(code,Destinations(),18961,18962,prefix,Store([],64,128),size,4,value,size,word,a,world);
  }
  lemma Advance76(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(76,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(77,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18962,[195382834,1329,1389,size,4,0,32,((size)+Modulus()-(4))%Modulus()],Store([],64,128));
    assert Fetch(code,18962) == Op(18,18963,0);
  }
  lemma Advance77(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(77,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(78,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18963,[195382834,1329,1389,size,4,0,(if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(32) then 1 else 0)],Store([],64,128));
    assert Fetch(code,18963) == Op(21,18964,0);
  }
  lemma Advance78(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(78,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(79,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18964,[195382834,1329,1389,size,4,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(32) then 1 else 0) == 0 then 1 else 0)],Store([],64,128));
    assert Fetch(code,18964) == Op(97,18967,18971);
  }
  lemma Advance79(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(79,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(80,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18967,[195382834,1329,1389,size,4,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(32) then 1 else 0) == 0 then 1 else 0),18971],Store([],64,128));
    assert Fetch(code,18967) == Op(87,18968,0);
    assert 18971 in Destinations() && code[18971] == 91;
  }
  lemma Advance80(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(80,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(81,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18971,[195382834,1329,1389,size,4,0],Store([],64,128));
    assert Fetch(code,18971) == Op(91,18972,0);
  }
  lemma Advance81(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(81,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(82,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18972,[195382834,1329,1389,size,4,0],Store([],64,128));
    assert Fetch(code,18972) == Op(80,18973,0);
  }
  lemma Advance82(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(82,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(83,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18973,[195382834,1329,1389,size,4],Store([],64,128));
    assert Fetch(code,18973) == Op(53,18974,0);
  }
  lemma Advance83(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(83,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(84,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18974,[195382834,1329,1389,size,a],Store([],64,128));
    assert Fetch(code,18974) == Op(145,18975,0);
  }
  lemma Advance84(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(84,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(85,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18975,[195382834,1329,a,size,1389],Store([],64,128));
    assert Fetch(code,18975) == Op(144,18976,0);
  }
  lemma Advance85(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(85,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(86,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18976,[195382834,1329,a,1389,size],Store([],64,128));
    assert Fetch(code,18976) == Op(80,18977,0);
  }
  lemma Advance86(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(86,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(87,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18977,[195382834,1329,a,1389],Store([],64,128));
    assert Fetch(code,18977) == Op(86,18978,0);
    assert 1389 in Destinations() && code[1389] == 91;
  }
  lemma Advance87(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(87,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(88,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1389,[195382834,1329,a],Store([],64,128));
    assert Fetch(code,1389) == Op(91,1390,0);
  }
  lemma Advance88(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(88,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(89,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1390,[195382834,1329,a],Store([],64,128));
    assert Fetch(code,1390) == Op(73,1391,0);
  }
  lemma Advance89(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(89,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(90,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1391,[195382834,1329,Observe(world,73,a)],Store([],64,128));
    assert Fetch(code,1391) == Op(144,1392,0);
  }
  lemma Advance90(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(90,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(91,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1392,[195382834,Observe(world,73,a),1329],Store([],64,128));
    assert Fetch(code,1392) == Op(86,1393,0);
    assert 1329 in Destinations() && code[1329] == 91;
  }
  lemma Advance91(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(91,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(92,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1329,[195382834,Observe(world,73,a)],Store([],64,128));
    assert Fetch(code,1329) == Op(91,1330,0);
  }
  lemma Advance92(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(92,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(93,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1330,[195382834,Observe(world,73,a)],Store([],64,128));
    assert Fetch(code,1330) == Op(96,1332,64);
  }
  lemma Advance93(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(93,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(94,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1332,[195382834,Observe(world,73,a),64],Store([],64,128));
    assert Fetch(code,1332) == Op(81,1333,0);
    StoreLoad([],64,128);
  }
  lemma Advance94(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(94,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(95,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1333,[195382834,Observe(world,73,a),128],Store([],64,128));
    assert Fetch(code,1333) == Op(144,1334,0);
  }
  lemma Advance95(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(95,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(96,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1334,[195382834,128,Observe(world,73,a)],Store([],64,128));
    assert Fetch(code,1334) == Op(129,1335,0);
  }
  lemma Advance96(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(96,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(97,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1335,[195382834,128,Observe(world,73,a),128],Store([],64,128));
    assert Fetch(code,1335) == Op(82,1336,0);
    StoreLoad(Store([],64,128),128,Observe(world,73,a));
  }
  lemma Advance97(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(97,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(98,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1336,[195382834,128],Store(Store([],64,128),128,Observe(world,73,a)));
    assert Fetch(code,1336) == Op(96,1338,32);
  }
  lemma Advance98(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(98,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(99,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(1338,[195382834,128,32],Store(Store([],64,128),128,Observe(world,73,a)));
    assert Fetch(code,1338) == Op(1,1339,0);
    var prefix: seq<Word> := [195382834];
    assert state == Running(1338,prefix+[128,32],Store(Store([],64,128),128,Observe(world,73,a)));
    K.AddStep(code,Destinations(),1338,1339,prefix,Store(Store([],64,128),128,Observe(world,73,a)),32,128,value,size,word,a,world);
  }
  lemma Advance99(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(99,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(100,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1339,[195382834,160],Store(Store([],64,128),128,Observe(world,73,a)));
    assert Fetch(code,1339) == Op(97,1342,1301);
  }
  lemma Advance100(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(100,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(101,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1342,[195382834,160,1301],Store(Store([],64,128),128,Observe(world,73,a)));
    assert Fetch(code,1342) == Op(86,1343,0);
    assert 1301 in Destinations() && code[1301] == 91;
  }
  lemma Advance101(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(101,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(102,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1301,[195382834,160],Store(Store([],64,128),128,Observe(world,73,a)));
    assert Fetch(code,1301) == Op(91,1302,0);
  }
  lemma Advance102(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(102,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(103,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1302,[195382834,160],Store(Store([],64,128),128,Observe(world,73,a)));
    assert Fetch(code,1302) == Op(96,1304,64);
  }
  lemma Advance103(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(103,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(104,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1304,[195382834,160,64],Store(Store([],64,128),128,Observe(world,73,a)));
    assert Fetch(code,1304) == Op(81,1305,0);
    StoreLoad([],64,128);
    StoreFrame(Store([],64,128),128,Observe(world,73,a),64);
  }
  lemma Advance104(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(104,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(105,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1305,[195382834,160,128],Store(Store([],64,128),128,Observe(world,73,a)));
    assert Fetch(code,1305) == Op(128,1306,0);
  }
  lemma Advance105(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(105,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(106,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1306,[195382834,160,128,128],Store(Store([],64,128),128,Observe(world,73,a)));
    assert Fetch(code,1306) == Op(145,1307,0);
  }
  lemma Advance106(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(106,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(107,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(1307,[195382834,128,128,160],Store(Store([],64,128),128,Observe(world,73,a)));
    assert Fetch(code,1307) == Op(3,1308,0);
    var prefix: seq<Word> := [195382834,128];
    assert state == Running(1307,prefix+[128,160],Store(Store([],64,128),128,Observe(world,73,a)));
    K.SubStep(code,Destinations(),1307,1308,prefix,Store(Store([],64,128),128,Observe(world,73,a)),160,128,value,size,word,a,world);
  }
  lemma Advance107(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(107,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); Good(108,next,value,size,word,a,world)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1308,[195382834,128,32],Store(Store([],64,128),128,Observe(world,73,a)));
    assert Fetch(code,1308) == Op(144,1309,0);
  }
  lemma Advance108(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(108,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| <= 9 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,world); next == Returned(Encode(Result(world,a),32))
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1309,[195382834,32,128],Store(Store([],64,128),128,Observe(world,73,a)));
    assert Fetch(code,1309) == Op(243,1310,0);
    ExactObservations(world,a);
    StoreLoad(Store([],64,128),128,Observe(world,73,a));
  }
  lemma SemanticResult(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(96,state,value,size,word,a,world)
    ensures state.Running? && |state.stack| >= 2
    ensures state.stack[|state.stack|-1] == 128
    ensures state.stack[|state.stack|-2] == Result(world,a)
  {{ reveal Good(); ExactObservations(world,a); }}
  lemma SemanticWitness(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, world: World)
    requires Matches(code) && Admitted(value,size,word,a,world) && Good(96,state,value,size,word,a,world)
    requires BlockHash(world,a) != BlobHash(world,a)
    ensures state.Running? && |state.stack| >= 2
    ensures state.stack[|state.stack|-1] == 128
    ensures state.stack[|state.stack|-2] == Result(world,a)
  {{ reveal Good(); ExactObservations(world,a); }}
  lemma Start(value: Word, size: Word, word: Word, a: Word, world: World)
    ensures Good(0,Running(0,[],[]),value,size,word,a,world)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, value: Word, size: Word, word: Word, a: Word, world: World) returns (state: State)
    requires Matches(code) && Admitted(value,size,word,a,world)
    ensures state == Returned(Encode(Result(world,a),32))
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
    Advance99(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance100(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance101(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance102(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance103(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance104(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance105(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance106(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance107(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
    Advance108(code,state,value,size,word,a,world);
    state := Step(code,Destinations(),state,value,size,word,a,world);
  }
}
