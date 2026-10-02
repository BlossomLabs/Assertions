// SPDX-License-Identifier: MIT
// Generated exact executed-byte certificate. Never edit directly.
include "Machine.dfy"
include "Binary.dfy"
module OperationsSignedDivisionModSNonzero {
  import opened OperationsSignedDivisionMachine
  import K = OperationsSignedDivisionBinaryKernel
  function Result(a: Word, b: Word): Word { SignedRemainder(a,b) }
  predicate Admitted(value: Word, size: Word, word: Word, a: Word, b: Word) {
    value == 0 && 68 <= size < 0x10000000000000000 && Selector(word) == 618826024 && (b > 0)
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
    code[980] == 128 &&
    code[981] == 99 &&
    code[982] == 49 &&
    code[983] == 71 &&
    code[984] == 1 &&
    code[985] == 69 &&
    code[986] == 17 &&
    code[987] == 97 &&
    code[988] == 4 &&
    code[989] == 36 &&
    code[990] == 87 &&
    code[1060] == 91 &&
    code[1061] == 128 &&
    code[1062] == 99 &&
    code[1063] == 36 &&
    code[1064] == 141 &&
    code[1065] == 108 &&
    code[1066] == 56 &&
    code[1067] == 20 &&
    code[1068] == 97 &&
    code[1069] == 5 &&
    code[1070] == 243 &&
    code[1071] == 87 &&
    code[1072] == 128 &&
    code[1073] == 99 &&
    code[1074] == 36 &&
    code[1075] == 226 &&
    code[1076] == 137 &&
    code[1077] == 40 &&
    code[1078] == 20 &&
    code[1079] == 97 &&
    code[1080] == 6 &&
    code[1081] == 6 &&
    code[1082] == 87 &&
    code[1130] == 91 &&
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
    code[1523] == 91 &&
    code[1542] == 91 &&
    code[1543] == 97 &&
    code[1544] == 5 &&
    code[1545] == 49 &&
    code[1546] == 97 &&
    code[1547] == 6 &&
    code[1548] == 20 &&
    code[1549] == 54 &&
    code[1550] == 96 &&
    code[1551] == 4 &&
    code[1552] == 97 &&
    code[1553] == 72 &&
    code[1554] == 218 &&
    code[1555] == 86 &&
    code[1556] == 91 &&
    code[1557] == 97 &&
    code[1558] == 13 &&
    code[1559] == 104 &&
    code[1560] == 86 &&
    code[3085] == 91 &&
    code[3086] == 147 &&
    code[3087] == 146 &&
    code[3088] == 80 &&
    code[3089] == 80 &&
    code[3090] == 80 &&
    code[3091] == 86 &&
    code[3432] == 91 &&
    code[3433] == 95 &&
    code[3434] == 97 &&
    code[3435] == 12 &&
    code[3436] == 13 &&
    code[3437] == 130 &&
    code[3438] == 132 &&
    code[3439] == 97 &&
    code[3440] == 79 &&
    code[3441] == 27 &&
    code[3442] == 86 &&
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
    code[18681] == 86 &&
    code[20251] == 91 &&
    code[20252] == 95 &&
    code[20253] == 130 &&
    code[20254] == 97 &&
    code[20255] == 79 &&
    code[20256] == 41 &&
    code[20257] == 87 &&
    code[20265] == 91 &&
    code[20266] == 80 &&
    code[20267] == 7 &&
    code[20268] == 144 &&
    code[20269] == 86
  }
  function Destinations(): set<nat> { {15,655,968,1060,1130,1266,1301,1329,1523,1542,1556,3085,3432,18650,18667,20251,20265} }
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
    else if id == 19 then state == Running(30,[618826024],Store([],64,128))
    else if id == 20 then state == Running(31,[618826024,618826024],Store([],64,128))
    else if id == 21 then state == Running(36,[618826024,618826024,2180929414],Store([],64,128))
    else if id == 22 then state == Running(37,[618826024,1],Store([],64,128))
    else if id == 23 then state == Running(40,[618826024,1,655],Store([],64,128))
    else if id == 24 then state == Running(655,[618826024],Store([],64,128))
    else if id == 25 then state == Running(656,[618826024],Store([],64,128))
    else if id == 26 then state == Running(657,[618826024,618826024],Store([],64,128))
    else if id == 27 then state == Running(662,[618826024,618826024,1082224558],Store([],64,128))
    else if id == 28 then state == Running(663,[618826024,1],Store([],64,128))
    else if id == 29 then state == Running(666,[618826024,1,968],Store([],64,128))
    else if id == 30 then state == Running(968,[618826024],Store([],64,128))
    else if id == 31 then state == Running(969,[618826024],Store([],64,128))
    else if id == 32 then state == Running(970,[618826024,618826024],Store([],64,128))
    else if id == 33 then state == Running(975,[618826024,618826024,613248056],Store([],64,128))
    else if id == 34 then state == Running(976,[618826024,0],Store([],64,128))
    else if id == 35 then state == Running(979,[618826024,0,1130],Store([],64,128))
    else if id == 36 then state == Running(980,[618826024],Store([],64,128))
    else if id == 37 then state == Running(981,[618826024,618826024],Store([],64,128))
    else if id == 38 then state == Running(986,[618826024,618826024,826736965],Store([],64,128))
    else if id == 39 then state == Running(987,[618826024,1],Store([],64,128))
    else if id == 40 then state == Running(990,[618826024,1,1060],Store([],64,128))
    else if id == 41 then state == Running(1060,[618826024],Store([],64,128))
    else if id == 42 then state == Running(1061,[618826024],Store([],64,128))
    else if id == 43 then state == Running(1062,[618826024,618826024],Store([],64,128))
    else if id == 44 then state == Running(1067,[618826024,618826024,613248056],Store([],64,128))
    else if id == 45 then state == Running(1068,[618826024,0],Store([],64,128))
    else if id == 46 then state == Running(1071,[618826024,0,1523],Store([],64,128))
    else if id == 47 then state == Running(1072,[618826024],Store([],64,128))
    else if id == 48 then state == Running(1073,[618826024,618826024],Store([],64,128))
    else if id == 49 then state == Running(1078,[618826024,618826024,618826024],Store([],64,128))
    else if id == 50 then state == Running(1079,[618826024,1],Store([],64,128))
    else if id == 51 then state == Running(1082,[618826024,1,1542],Store([],64,128))
    else if id == 52 then state == Running(1542,[618826024],Store([],64,128))
    else if id == 53 then state == Running(1543,[618826024],Store([],64,128))
    else if id == 54 then state == Running(1546,[618826024,1329],Store([],64,128))
    else if id == 55 then state == Running(1549,[618826024,1329,1556],Store([],64,128))
    else if id == 56 then state == Running(1550,[618826024,1329,1556,size],Store([],64,128))
    else if id == 57 then state == Running(1552,[618826024,1329,1556,size,4],Store([],64,128))
    else if id == 58 then state == Running(1555,[618826024,1329,1556,size,4,18650],Store([],64,128))
    else if id == 59 then state == Running(18650,[618826024,1329,1556,size,4],Store([],64,128))
    else if id == 60 then state == Running(18651,[618826024,1329,1556,size,4],Store([],64,128))
    else if id == 61 then state == Running(18652,[618826024,1329,1556,size,4,0],Store([],64,128))
    else if id == 62 then state == Running(18653,[618826024,1329,1556,size,4,0,0],Store([],64,128))
    else if id == 63 then state == Running(18655,[618826024,1329,1556,size,4,0,0,64],Store([],64,128))
    else if id == 64 then state == Running(18656,[618826024,1329,1556,size,4,0,0,64,4],Store([],64,128))
    else if id == 65 then state == Running(18657,[618826024,1329,1556,size,4,0,0,64,4,size],Store([],64,128))
    else if id == 66 then state == Running(18658,[618826024,1329,1556,size,4,0,0,64,((size)+Modulus()-(4))%Modulus()],Store([],64,128))
    else if id == 67 then state == Running(18659,[618826024,1329,1556,size,4,0,0,(if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0)],Store([],64,128))
    else if id == 68 then state == Running(18660,[618826024,1329,1556,size,4,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0) == 0 then 1 else 0)],Store([],64,128))
    else if id == 69 then state == Running(18663,[618826024,1329,1556,size,4,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0) == 0 then 1 else 0),18667],Store([],64,128))
    else if id == 70 then state == Running(18667,[618826024,1329,1556,size,4,0,0],Store([],64,128))
    else if id == 71 then state == Running(18668,[618826024,1329,1556,size,4,0,0],Store([],64,128))
    else if id == 72 then state == Running(18669,[618826024,1329,1556,size,4,0],Store([],64,128))
    else if id == 73 then state == Running(18670,[618826024,1329,1556,size,4],Store([],64,128))
    else if id == 74 then state == Running(18671,[618826024,1329,1556,size,4,4],Store([],64,128))
    else if id == 75 then state == Running(18672,[618826024,1329,1556,size,4,a],Store([],64,128))
    else if id == 76 then state == Running(18673,[618826024,1329,a,size,4,1556],Store([],64,128))
    else if id == 77 then state == Running(18675,[618826024,1329,a,size,4,1556,32],Store([],64,128))
    else if id == 78 then state == Running(18676,[618826024,1329,a,size,4,32,1556],Store([],64,128))
    else if id == 79 then state == Running(18677,[618826024,1329,a,size,1556,32,4],Store([],64,128))
    else if id == 80 then state == Running(18678,[618826024,1329,a,size,1556,36],Store([],64,128))
    else if id == 81 then state == Running(18679,[618826024,1329,a,size,1556,b],Store([],64,128))
    else if id == 82 then state == Running(18680,[618826024,1329,a,b,1556,size],Store([],64,128))
    else if id == 83 then state == Running(18681,[618826024,1329,a,b,1556],Store([],64,128))
    else if id == 84 then state == Running(1556,[618826024,1329,a,b],Store([],64,128))
    else if id == 85 then state == Running(1557,[618826024,1329,a,b],Store([],64,128))
    else if id == 86 then state == Running(1560,[618826024,1329,a,b,3432],Store([],64,128))
    else if id == 87 then state == Running(3432,[618826024,1329,a,b],Store([],64,128))
    else if id == 88 then state == Running(3433,[618826024,1329,a,b],Store([],64,128))
    else if id == 89 then state == Running(3434,[618826024,1329,a,b,0],Store([],64,128))
    else if id == 90 then state == Running(3437,[618826024,1329,a,b,0,3085],Store([],64,128))
    else if id == 91 then state == Running(3438,[618826024,1329,a,b,0,3085,b],Store([],64,128))
    else if id == 92 then state == Running(3439,[618826024,1329,a,b,0,3085,b,a],Store([],64,128))
    else if id == 93 then state == Running(3442,[618826024,1329,a,b,0,3085,b,a,20251],Store([],64,128))
    else if id == 94 then state == Running(20251,[618826024,1329,a,b,0,3085,b,a],Store([],64,128))
    else if id == 95 then state == Running(20252,[618826024,1329,a,b,0,3085,b,a],Store([],64,128))
    else if id == 96 then state == Running(20253,[618826024,1329,a,b,0,3085,b,a,0],Store([],64,128))
    else if id == 97 then state == Running(20254,[618826024,1329,a,b,0,3085,b,a,0,b],Store([],64,128))
    else if id == 98 then state == Running(20257,[618826024,1329,a,b,0,3085,b,a,0,b,20265],Store([],64,128))
    else if id == 99 then state == Running(20265,[618826024,1329,a,b,0,3085,b,a,0],Store([],64,128))
    else if id == 100 then state == Running(20266,[618826024,1329,a,b,0,3085,b,a,0],Store([],64,128))
    else if id == 101 then state == Running(20267,[618826024,1329,a,b,0,3085,b,a],Store([],64,128))
    else if id == 102 then state == Running(20268,[618826024,1329,a,b,0,3085,SignedRemainder(a,b)],Store([],64,128))
    else if id == 103 then state == Running(20269,[618826024,1329,a,b,0,SignedRemainder(a,b),3085],Store([],64,128))
    else if id == 104 then state == Running(3085,[618826024,1329,a,b,0,SignedRemainder(a,b)],Store([],64,128))
    else if id == 105 then state == Running(3086,[618826024,1329,a,b,0,SignedRemainder(a,b)],Store([],64,128))
    else if id == 106 then state == Running(3087,[618826024,SignedRemainder(a,b),a,b,0,1329],Store([],64,128))
    else if id == 107 then state == Running(3088,[618826024,SignedRemainder(a,b),1329,b,0,a],Store([],64,128))
    else if id == 108 then state == Running(3089,[618826024,SignedRemainder(a,b),1329,b,0],Store([],64,128))
    else if id == 109 then state == Running(3090,[618826024,SignedRemainder(a,b),1329,b],Store([],64,128))
    else if id == 110 then state == Running(3091,[618826024,SignedRemainder(a,b),1329],Store([],64,128))
    else if id == 111 then state == Running(1329,[618826024,SignedRemainder(a,b)],Store([],64,128))
    else if id == 112 then state == Running(1330,[618826024,SignedRemainder(a,b)],Store([],64,128))
    else if id == 113 then state == Running(1332,[618826024,SignedRemainder(a,b),64],Store([],64,128))
    else if id == 114 then state == Running(1333,[618826024,SignedRemainder(a,b),128],Store([],64,128))
    else if id == 115 then state == Running(1334,[618826024,128,SignedRemainder(a,b)],Store([],64,128))
    else if id == 116 then state == Running(1335,[618826024,128,SignedRemainder(a,b),128],Store([],64,128))
    else if id == 117 then state == Running(1336,[618826024,128],Store(Store([],64,128),128,SignedRemainder(a,b)))
    else if id == 118 then state == Running(1338,[618826024,128,32],Store(Store([],64,128),128,SignedRemainder(a,b)))
    else if id == 119 then state == Running(1339,[618826024,160],Store(Store([],64,128),128,SignedRemainder(a,b)))
    else if id == 120 then state == Running(1342,[618826024,160,1301],Store(Store([],64,128),128,SignedRemainder(a,b)))
    else if id == 121 then state == Running(1301,[618826024,160],Store(Store([],64,128),128,SignedRemainder(a,b)))
    else if id == 122 then state == Running(1302,[618826024,160],Store(Store([],64,128),128,SignedRemainder(a,b)))
    else if id == 123 then state == Running(1304,[618826024,160,64],Store(Store([],64,128),128,SignedRemainder(a,b)))
    else if id == 124 then state == Running(1305,[618826024,160,128],Store(Store([],64,128),128,SignedRemainder(a,b)))
    else if id == 125 then state == Running(1306,[618826024,160,128,128],Store(Store([],64,128),128,SignedRemainder(a,b)))
    else if id == 126 then state == Running(1307,[618826024,128,128,160],Store(Store([],64,128),128,SignedRemainder(a,b)))
    else if id == 127 then state == Running(1308,[618826024,128,32],Store(Store([],64,128),128,SignedRemainder(a,b)))
    else if id == 128 then state == Running(1309,[618826024,32,128],Store(Store([],64,128),128,SignedRemainder(a,b)))
    else false
  }
  lemma Advance0(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(0,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
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
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(19,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(29,[word,224],Store([],64,128));
    assert Fetch(code,29) == Op(28,30,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(19,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(20,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(30,[618826024],Store([],64,128));
    assert Fetch(code,30) == Op(128,31,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(20,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(21,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(31,[618826024,618826024],Store([],64,128));
    assert Fetch(code,31) == Op(99,36,2180929414);
  }
  lemma Advance21(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(21,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(22,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(36,[618826024,618826024,2180929414],Store([],64,128));
    assert Fetch(code,36) == Op(17,37,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(22,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(23,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(37,[618826024,1],Store([],64,128));
    assert Fetch(code,37) == Op(97,40,655);
  }
  lemma Advance23(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(23,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(24,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(40,[618826024,1,655],Store([],64,128));
    assert Fetch(code,40) == Op(87,41,0);
    assert 655 in Destinations() && code[655] == 91;
  }
  lemma Advance24(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(24,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(25,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(655,[618826024],Store([],64,128));
    assert Fetch(code,655) == Op(91,656,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(25,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(26,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(656,[618826024],Store([],64,128));
    assert Fetch(code,656) == Op(128,657,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(26,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(27,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(657,[618826024,618826024],Store([],64,128));
    assert Fetch(code,657) == Op(99,662,1082224558);
  }
  lemma Advance27(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(27,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(28,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(662,[618826024,618826024,1082224558],Store([],64,128));
    assert Fetch(code,662) == Op(17,663,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(28,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(29,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(663,[618826024,1],Store([],64,128));
    assert Fetch(code,663) == Op(97,666,968);
  }
  lemma Advance29(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(29,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(30,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(666,[618826024,1,968],Store([],64,128));
    assert Fetch(code,666) == Op(87,667,0);
    assert 968 in Destinations() && code[968] == 91;
  }
  lemma Advance30(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(30,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(31,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(968,[618826024],Store([],64,128));
    assert Fetch(code,968) == Op(91,969,0);
  }
  lemma Advance31(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(31,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(32,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(969,[618826024],Store([],64,128));
    assert Fetch(code,969) == Op(128,970,0);
  }
  lemma Advance32(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(32,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(33,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(970,[618826024,618826024],Store([],64,128));
    assert Fetch(code,970) == Op(99,975,613248056);
  }
  lemma Advance33(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(33,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(34,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(975,[618826024,618826024,613248056],Store([],64,128));
    assert Fetch(code,975) == Op(17,976,0);
  }
  lemma Advance34(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(34,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(35,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(976,[618826024,0],Store([],64,128));
    assert Fetch(code,976) == Op(97,979,1130);
  }
  lemma Advance35(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(35,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(36,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(979,[618826024,0,1130],Store([],64,128));
    assert Fetch(code,979) == Op(87,980,0);
    assert 1130 in Destinations() && code[1130] == 91;
  }
  lemma Advance36(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(36,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(37,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(980,[618826024],Store([],64,128));
    assert Fetch(code,980) == Op(128,981,0);
  }
  lemma Advance37(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(37,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(38,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(981,[618826024,618826024],Store([],64,128));
    assert Fetch(code,981) == Op(99,986,826736965);
  }
  lemma Advance38(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(38,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(39,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(986,[618826024,618826024,826736965],Store([],64,128));
    assert Fetch(code,986) == Op(17,987,0);
  }
  lemma Advance39(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(39,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(40,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(987,[618826024,1],Store([],64,128));
    assert Fetch(code,987) == Op(97,990,1060);
  }
  lemma Advance40(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(40,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(41,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(990,[618826024,1,1060],Store([],64,128));
    assert Fetch(code,990) == Op(87,991,0);
    assert 1060 in Destinations() && code[1060] == 91;
  }
  lemma Advance41(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(41,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(42,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1060,[618826024],Store([],64,128));
    assert Fetch(code,1060) == Op(91,1061,0);
  }
  lemma Advance42(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(42,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(43,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1061,[618826024],Store([],64,128));
    assert Fetch(code,1061) == Op(128,1062,0);
  }
  lemma Advance43(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(43,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(44,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1062,[618826024,618826024],Store([],64,128));
    assert Fetch(code,1062) == Op(99,1067,613248056);
  }
  lemma Advance44(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(44,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(45,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1067,[618826024,618826024,613248056],Store([],64,128));
    assert Fetch(code,1067) == Op(20,1068,0);
  }
  lemma Advance45(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(45,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(46,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1068,[618826024,0],Store([],64,128));
    assert Fetch(code,1068) == Op(97,1071,1523);
  }
  lemma Advance46(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(46,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(47,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1071,[618826024,0,1523],Store([],64,128));
    assert Fetch(code,1071) == Op(87,1072,0);
    assert 1523 in Destinations() && code[1523] == 91;
  }
  lemma Advance47(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(47,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(48,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1072,[618826024],Store([],64,128));
    assert Fetch(code,1072) == Op(128,1073,0);
  }
  lemma Advance48(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(48,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(49,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1073,[618826024,618826024],Store([],64,128));
    assert Fetch(code,1073) == Op(99,1078,618826024);
  }
  lemma Advance49(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(49,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(50,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1078,[618826024,618826024,618826024],Store([],64,128));
    assert Fetch(code,1078) == Op(20,1079,0);
  }
  lemma Advance50(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(50,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(51,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1079,[618826024,1],Store([],64,128));
    assert Fetch(code,1079) == Op(97,1082,1542);
  }
  lemma Advance51(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(51,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(52,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1082,[618826024,1,1542],Store([],64,128));
    assert Fetch(code,1082) == Op(87,1083,0);
    assert 1542 in Destinations() && code[1542] == 91;
  }
  lemma Advance52(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(52,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(53,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1542,[618826024],Store([],64,128));
    assert Fetch(code,1542) == Op(91,1543,0);
  }
  lemma Advance53(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(53,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(54,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1543,[618826024],Store([],64,128));
    assert Fetch(code,1543) == Op(97,1546,1329);
  }
  lemma Advance54(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(54,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(55,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1546,[618826024,1329],Store([],64,128));
    assert Fetch(code,1546) == Op(97,1549,1556);
  }
  lemma Advance55(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(55,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(56,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1549,[618826024,1329,1556],Store([],64,128));
    assert Fetch(code,1549) == Op(54,1550,0);
  }
  lemma Advance56(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(56,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(57,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1550,[618826024,1329,1556,size],Store([],64,128));
    assert Fetch(code,1550) == Op(96,1552,4);
  }
  lemma Advance57(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(57,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(58,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1552,[618826024,1329,1556,size,4],Store([],64,128));
    assert Fetch(code,1552) == Op(97,1555,18650);
  }
  lemma Advance58(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(58,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(59,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1555,[618826024,1329,1556,size,4,18650],Store([],64,128));
    assert Fetch(code,1555) == Op(86,1556,0);
    assert 18650 in Destinations() && code[18650] == 91;
  }
  lemma Advance59(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(59,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(60,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18650,[618826024,1329,1556,size,4],Store([],64,128));
    assert Fetch(code,18650) == Op(91,18651,0);
  }
  lemma Advance60(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(60,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(61,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18651,[618826024,1329,1556,size,4],Store([],64,128));
    assert Fetch(code,18651) == Op(95,18652,0);
  }
  lemma Advance61(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(61,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(62,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18652,[618826024,1329,1556,size,4,0],Store([],64,128));
    assert Fetch(code,18652) == Op(95,18653,0);
  }
  lemma Advance62(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(62,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(63,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18653,[618826024,1329,1556,size,4,0,0],Store([],64,128));
    assert Fetch(code,18653) == Op(96,18655,64);
  }
  lemma Advance63(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(63,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(64,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18655,[618826024,1329,1556,size,4,0,0,64],Store([],64,128));
    assert Fetch(code,18655) == Op(131,18656,0);
  }
  lemma Advance64(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(64,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(65,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18656,[618826024,1329,1556,size,4,0,0,64,4],Store([],64,128));
    assert Fetch(code,18656) == Op(133,18657,0);
  }
  lemma Advance65(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(65,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(66,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(18657,[618826024,1329,1556,size,4,0,0,64,4,size],Store([],64,128));
    assert Fetch(code,18657) == Op(3,18658,0);
    var prefix: seq<Word> := [618826024,1329,1556,size,4,0,0,64];
    assert state == Running(18657,prefix+[4,size],Store([],64,128));
    K.SubStep(code,Destinations(),18657,18658,prefix,Store([],64,128),size,4,value,size,word,a,b);
  }
  lemma Advance66(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(66,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(67,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18658,[618826024,1329,1556,size,4,0,0,64,((size)+Modulus()-(4))%Modulus()],Store([],64,128));
    assert Fetch(code,18658) == Op(18,18659,0);
  }
  lemma Advance67(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(67,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(68,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18659,[618826024,1329,1556,size,4,0,0,(if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0)],Store([],64,128));
    assert Fetch(code,18659) == Op(21,18660,0);
  }
  lemma Advance68(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(68,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(69,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18660,[618826024,1329,1556,size,4,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0) == 0 then 1 else 0)],Store([],64,128));
    assert Fetch(code,18660) == Op(97,18663,18667);
  }
  lemma Advance69(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(69,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(70,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18663,[618826024,1329,1556,size,4,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0) == 0 then 1 else 0),18667],Store([],64,128));
    assert Fetch(code,18663) == Op(87,18664,0);
    assert 18667 in Destinations() && code[18667] == 91;
  }
  lemma Advance70(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(70,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(71,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18667,[618826024,1329,1556,size,4,0,0],Store([],64,128));
    assert Fetch(code,18667) == Op(91,18668,0);
  }
  lemma Advance71(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(71,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(72,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18668,[618826024,1329,1556,size,4,0,0],Store([],64,128));
    assert Fetch(code,18668) == Op(80,18669,0);
  }
  lemma Advance72(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(72,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(73,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18669,[618826024,1329,1556,size,4,0],Store([],64,128));
    assert Fetch(code,18669) == Op(80,18670,0);
  }
  lemma Advance73(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(73,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(74,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18670,[618826024,1329,1556,size,4],Store([],64,128));
    assert Fetch(code,18670) == Op(128,18671,0);
  }
  lemma Advance74(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(74,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(75,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18671,[618826024,1329,1556,size,4,4],Store([],64,128));
    assert Fetch(code,18671) == Op(53,18672,0);
  }
  lemma Advance75(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(75,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(76,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18672,[618826024,1329,1556,size,4,a],Store([],64,128));
    assert Fetch(code,18672) == Op(146,18673,0);
  }
  lemma Advance76(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(76,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(77,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18673,[618826024,1329,a,size,4,1556],Store([],64,128));
    assert Fetch(code,18673) == Op(96,18675,32);
  }
  lemma Advance77(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(77,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(78,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18675,[618826024,1329,a,size,4,1556,32],Store([],64,128));
    assert Fetch(code,18675) == Op(144,18676,0);
  }
  lemma Advance78(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(78,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(79,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18676,[618826024,1329,a,size,4,32,1556],Store([],64,128));
    assert Fetch(code,18676) == Op(145,18677,0);
  }
  lemma Advance79(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(79,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(80,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(18677,[618826024,1329,a,size,1556,32,4],Store([],64,128));
    assert Fetch(code,18677) == Op(1,18678,0);
    var prefix: seq<Word> := [618826024,1329,a,size,1556];
    assert state == Running(18677,prefix+[32,4],Store([],64,128));
    K.AddStep(code,Destinations(),18677,18678,prefix,Store([],64,128),4,32,value,size,word,a,b);
  }
  lemma Advance80(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(80,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(81,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18678,[618826024,1329,a,size,1556,36],Store([],64,128));
    assert Fetch(code,18678) == Op(53,18679,0);
  }
  lemma Advance81(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(81,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(82,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18679,[618826024,1329,a,size,1556,b],Store([],64,128));
    assert Fetch(code,18679) == Op(145,18680,0);
  }
  lemma Advance82(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(82,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(83,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18680,[618826024,1329,a,b,1556,size],Store([],64,128));
    assert Fetch(code,18680) == Op(80,18681,0);
  }
  lemma Advance83(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(83,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(84,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18681,[618826024,1329,a,b,1556],Store([],64,128));
    assert Fetch(code,18681) == Op(86,18682,0);
    assert 1556 in Destinations() && code[1556] == 91;
  }
  lemma Advance84(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(84,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(85,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1556,[618826024,1329,a,b],Store([],64,128));
    assert Fetch(code,1556) == Op(91,1557,0);
  }
  lemma Advance85(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(85,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(86,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1557,[618826024,1329,a,b],Store([],64,128));
    assert Fetch(code,1557) == Op(97,1560,3432);
  }
  lemma Advance86(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(86,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(87,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1560,[618826024,1329,a,b,3432],Store([],64,128));
    assert Fetch(code,1560) == Op(86,1561,0);
    assert 3432 in Destinations() && code[3432] == 91;
  }
  lemma Advance87(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(87,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(88,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(3432,[618826024,1329,a,b],Store([],64,128));
    assert Fetch(code,3432) == Op(91,3433,0);
  }
  lemma Advance88(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(88,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(89,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(3433,[618826024,1329,a,b],Store([],64,128));
    assert Fetch(code,3433) == Op(95,3434,0);
  }
  lemma Advance89(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(89,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(90,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(3434,[618826024,1329,a,b,0],Store([],64,128));
    assert Fetch(code,3434) == Op(97,3437,3085);
  }
  lemma Advance90(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(90,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(91,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(3437,[618826024,1329,a,b,0,3085],Store([],64,128));
    assert Fetch(code,3437) == Op(130,3438,0);
  }
  lemma Advance91(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(91,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(92,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(3438,[618826024,1329,a,b,0,3085,b],Store([],64,128));
    assert Fetch(code,3438) == Op(132,3439,0);
  }
  lemma Advance92(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(92,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(93,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(3439,[618826024,1329,a,b,0,3085,b,a],Store([],64,128));
    assert Fetch(code,3439) == Op(97,3442,20251);
  }
  lemma Advance93(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(93,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(94,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(3442,[618826024,1329,a,b,0,3085,b,a,20251],Store([],64,128));
    assert Fetch(code,3442) == Op(86,3443,0);
    assert 20251 in Destinations() && code[20251] == 91;
  }
  lemma Advance94(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(94,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(95,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(20251,[618826024,1329,a,b,0,3085,b,a],Store([],64,128));
    assert Fetch(code,20251) == Op(91,20252,0);
  }
  lemma Advance95(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(95,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(96,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(20252,[618826024,1329,a,b,0,3085,b,a],Store([],64,128));
    assert Fetch(code,20252) == Op(95,20253,0);
  }
  lemma Advance96(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(96,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(97,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(20253,[618826024,1329,a,b,0,3085,b,a,0],Store([],64,128));
    assert Fetch(code,20253) == Op(130,20254,0);
  }
  lemma Advance97(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(97,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(98,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(20254,[618826024,1329,a,b,0,3085,b,a,0,b],Store([],64,128));
    assert Fetch(code,20254) == Op(97,20257,20265);
  }
  lemma Advance98(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(98,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(99,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(20257,[618826024,1329,a,b,0,3085,b,a,0,b,20265],Store([],64,128));
    assert Fetch(code,20257) == Op(87,20258,0);
    assert 20265 in Destinations() && code[20265] == 91;
  }
  lemma Advance99(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(99,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(100,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(20265,[618826024,1329,a,b,0,3085,b,a,0],Store([],64,128));
    assert Fetch(code,20265) == Op(91,20266,0);
  }
  lemma Advance100(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(100,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(101,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(20266,[618826024,1329,a,b,0,3085,b,a,0],Store([],64,128));
    assert Fetch(code,20266) == Op(80,20267,0);
  }
  lemma Advance101(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(101,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(102,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(20267,[618826024,1329,a,b,0,3085,b,a],Store([],64,128));
    assert Fetch(code,20267) == Op(7,20268,0);
  }
  lemma Advance102(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(102,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(103,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(20268,[618826024,1329,a,b,0,3085,SignedRemainder(a,b)],Store([],64,128));
    assert Fetch(code,20268) == Op(144,20269,0);
  }
  lemma Advance103(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(103,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(104,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(20269,[618826024,1329,a,b,0,SignedRemainder(a,b),3085],Store([],64,128));
    assert Fetch(code,20269) == Op(86,20270,0);
    assert 3085 in Destinations() && code[3085] == 91;
  }
  lemma Advance104(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(104,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(105,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(3085,[618826024,1329,a,b,0,SignedRemainder(a,b)],Store([],64,128));
    assert Fetch(code,3085) == Op(91,3086,0);
  }
  lemma Advance105(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(105,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(106,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(3086,[618826024,1329,a,b,0,SignedRemainder(a,b)],Store([],64,128));
    assert Fetch(code,3086) == Op(147,3087,0);
  }
  lemma Advance106(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(106,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(107,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(3087,[618826024,SignedRemainder(a,b),a,b,0,1329],Store([],64,128));
    assert Fetch(code,3087) == Op(146,3088,0);
  }
  lemma Advance107(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(107,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(108,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(3088,[618826024,SignedRemainder(a,b),1329,b,0,a],Store([],64,128));
    assert Fetch(code,3088) == Op(80,3089,0);
  }
  lemma Advance108(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(108,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(109,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(3089,[618826024,SignedRemainder(a,b),1329,b,0],Store([],64,128));
    assert Fetch(code,3089) == Op(80,3090,0);
  }
  lemma Advance109(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(109,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(110,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(3090,[618826024,SignedRemainder(a,b),1329,b],Store([],64,128));
    assert Fetch(code,3090) == Op(80,3091,0);
  }
  lemma Advance110(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(110,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(111,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(3091,[618826024,SignedRemainder(a,b),1329],Store([],64,128));
    assert Fetch(code,3091) == Op(86,3092,0);
    assert 1329 in Destinations() && code[1329] == 91;
  }
  lemma Advance111(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(111,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(112,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1329,[618826024,SignedRemainder(a,b)],Store([],64,128));
    assert Fetch(code,1329) == Op(91,1330,0);
  }
  lemma Advance112(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(112,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(113,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1330,[618826024,SignedRemainder(a,b)],Store([],64,128));
    assert Fetch(code,1330) == Op(96,1332,64);
  }
  lemma Advance113(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(113,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(114,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1332,[618826024,SignedRemainder(a,b),64],Store([],64,128));
    assert Fetch(code,1332) == Op(81,1333,0);
    StoreLoad([],64,128);
  }
  lemma Advance114(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(114,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(115,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1333,[618826024,SignedRemainder(a,b),128],Store([],64,128));
    assert Fetch(code,1333) == Op(144,1334,0);
  }
  lemma Advance115(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(115,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(116,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1334,[618826024,128,SignedRemainder(a,b)],Store([],64,128));
    assert Fetch(code,1334) == Op(129,1335,0);
  }
  lemma Advance116(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(116,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(117,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1335,[618826024,128,SignedRemainder(a,b),128],Store([],64,128));
    assert Fetch(code,1335) == Op(82,1336,0);
    StoreLoad(Store([],64,128),128,SignedRemainder(a,b));
  }
  lemma Advance117(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(117,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(118,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1336,[618826024,128],Store(Store([],64,128),128,SignedRemainder(a,b)));
    assert Fetch(code,1336) == Op(96,1338,32);
  }
  lemma Advance118(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(118,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(119,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(1338,[618826024,128,32],Store(Store([],64,128),128,SignedRemainder(a,b)));
    assert Fetch(code,1338) == Op(1,1339,0);
    var prefix: seq<Word> := [618826024];
    assert state == Running(1338,prefix+[128,32],Store(Store([],64,128),128,SignedRemainder(a,b)));
    K.AddStep(code,Destinations(),1338,1339,prefix,Store(Store([],64,128),128,SignedRemainder(a,b)),32,128,value,size,word,a,b);
  }
  lemma Advance119(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(119,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(120,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1339,[618826024,160],Store(Store([],64,128),128,SignedRemainder(a,b)));
    assert Fetch(code,1339) == Op(97,1342,1301);
  }
  lemma Advance120(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(120,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(121,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1342,[618826024,160,1301],Store(Store([],64,128),128,SignedRemainder(a,b)));
    assert Fetch(code,1342) == Op(86,1343,0);
    assert 1301 in Destinations() && code[1301] == 91;
  }
  lemma Advance121(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(121,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(122,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1301,[618826024,160],Store(Store([],64,128),128,SignedRemainder(a,b)));
    assert Fetch(code,1301) == Op(91,1302,0);
  }
  lemma Advance122(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(122,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(123,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1302,[618826024,160],Store(Store([],64,128),128,SignedRemainder(a,b)));
    assert Fetch(code,1302) == Op(96,1304,64);
  }
  lemma Advance123(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(123,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(124,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1304,[618826024,160,64],Store(Store([],64,128),128,SignedRemainder(a,b)));
    assert Fetch(code,1304) == Op(81,1305,0);
    StoreLoad([],64,128);
    StoreFrame(Store([],64,128),128,SignedRemainder(a,b),64);
  }
  lemma Advance124(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(124,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(125,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1305,[618826024,160,128],Store(Store([],64,128),128,SignedRemainder(a,b)));
    assert Fetch(code,1305) == Op(128,1306,0);
  }
  lemma Advance125(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(125,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(126,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1306,[618826024,160,128,128],Store(Store([],64,128),128,SignedRemainder(a,b)));
    assert Fetch(code,1306) == Op(145,1307,0);
  }
  lemma Advance126(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(126,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(127,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(1307,[618826024,128,128,160],Store(Store([],64,128),128,SignedRemainder(a,b)));
    assert Fetch(code,1307) == Op(3,1308,0);
    var prefix: seq<Word> := [618826024,128];
    assert state == Running(1307,prefix+[128,160],Store(Store([],64,128),128,SignedRemainder(a,b)));
    K.SubStep(code,Destinations(),1307,1308,prefix,Store(Store([],64,128),128,SignedRemainder(a,b)),160,128,value,size,word,a,b);
  }
  lemma Advance127(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(127,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); Good(128,next,value,size,word,a,b)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1308,[618826024,128,32],Store(Store([],64,128),128,SignedRemainder(a,b)));
    assert Fetch(code,1308) == Op(144,1309,0);
  }
  lemma Advance128(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(128,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b); next == Returned(Encode(Result(a,b),32))
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1309,[618826024,32,128],Store(Store([],64,128),128,SignedRemainder(a,b)));
    assert Fetch(code,1309) == Op(243,1310,0);
    StoreLoad(Store([],64,128),128,SignedRemainder(a,b));
  }
  lemma SemanticResult(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(116,state,value,size,word,a,b)
    ensures state.Running? && |state.stack| >= 2
    ensures state.stack[|state.stack|-1] == 128
    ensures state.stack[|state.stack|-2] == Result(a,b)
  { reveal Good(); }
  lemma SemanticWitness(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word)
    requires Matches(code) && Admitted(value,size,word,a,b) && Good(116,state,value,size,word,a,b)
    requires a == 123 && b == 456
    ensures state.Running? && |state.stack| >= 2
    ensures state.stack[|state.stack|-1] == 128
    ensures state.stack[|state.stack|-2] == Result(a,b)
  { reveal Good(); }
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
    Advance109(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance110(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance111(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance112(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance113(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance114(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance115(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance116(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance117(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance118(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance119(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance120(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance121(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance122(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance123(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance124(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance125(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance126(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance127(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
    Advance128(code,state,value,size,word,a,b);
    state := Step(code,Destinations(),state,value,size,word,a,b);
  }
}
