// SPDX-License-Identifier: MIT
// Generated exact executed-byte certificate. Never edit directly.
include "Machine.dfy"
include "Binary.dfy"
module OperationsHashPairSortedKeep {
  import opened OperationsHashPairSortedMachine
  import K = OperationsHashPairSortedBinaryKernel
  function Result(a: Word, b: Word, h: HashEngine): Word { Hash(h,SortedPair(a,b)) }
  predicate Admitted(value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine) {
    HashDomain(h,a,b) && value == 0 && 68 <= size < 0x10000000000000000 && Selector(word) == 3255037363 && (a <= b)
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
    code[213] == 91 &&
    code[214] == 128 &&
    code[215] == 99 &&
    code[216] == 193 &&
    code[217] == 69 &&
    code[218] == 156 &&
    code[219] == 4 &&
    code[220] == 17 &&
    code[221] == 97 &&
    code[222] == 1 &&
    code[223] == 38 &&
    code[224] == 87 &&
    code[225] == 128 &&
    code[226] == 99 &&
    code[227] == 193 &&
    code[228] == 69 &&
    code[229] == 156 &&
    code[230] == 4 &&
    code[231] == 20 &&
    code[232] == 97 &&
    code[233] == 10 &&
    code[234] == 119 &&
    code[235] == 87 &&
    code[236] == 128 &&
    code[237] == 99 &&
    code[238] == 194 &&
    code[239] == 3 &&
    code[240] == 237 &&
    code[241] == 179 &&
    code[242] == 20 &&
    code[243] == 97 &&
    code[244] == 10 &&
    code[245] == 138 &&
    code[246] == 87 &&
    code[294] == 91 &&
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
    code[2679] == 91 &&
    code[2698] == 91 &&
    code[2699] == 97 &&
    code[2700] == 5 &&
    code[2701] == 49 &&
    code[2702] == 97 &&
    code[2703] == 10 &&
    code[2704] == 152 &&
    code[2705] == 54 &&
    code[2706] == 96 &&
    code[2707] == 4 &&
    code[2708] == 97 &&
    code[2709] == 72 &&
    code[2710] == 218 &&
    code[2711] == 86 &&
    code[2712] == 91 &&
    code[2713] == 97 &&
    code[2714] == 31 &&
    code[2715] == 164 &&
    code[2716] == 86 &&
    code[8100] == 91 &&
    code[8101] == 95 &&
    code[8102] == 129 &&
    code[8103] == 131 &&
    code[8104] == 17 &&
    code[8105] == 21 &&
    code[8106] == 97 &&
    code[8107] == 31 &&
    code[8108] == 177 &&
    code[8109] == 87 &&
    code[8113] == 91 &&
    code[8114] == 80 &&
    code[8115] == 96 &&
    code[8116] == 64 &&
    code[8117] == 128 &&
    code[8118] == 81 &&
    code[8119] == 96 &&
    code[8120] == 32 &&
    code[8121] == 128 &&
    code[8122] == 130 &&
    code[8123] == 1 &&
    code[8124] == 148 &&
    code[8125] == 144 &&
    code[8126] == 148 &&
    code[8127] == 82 &&
    code[8128] == 128 &&
    code[8129] == 130 &&
    code[8130] == 1 &&
    code[8131] == 146 &&
    code[8132] == 144 &&
    code[8133] == 146 &&
    code[8134] == 82 &&
    code[8135] == 128 &&
    code[8136] == 81 &&
    code[8137] == 128 &&
    code[8138] == 131 &&
    code[8139] == 3 &&
    code[8140] == 130 &&
    code[8141] == 1 &&
    code[8142] == 129 &&
    code[8143] == 82 &&
    code[8144] == 96 &&
    code[8145] == 96 &&
    code[8146] == 144 &&
    code[8147] == 146 &&
    code[8148] == 1 &&
    code[8149] == 144 &&
    code[8150] == 82 &&
    code[8151] == 128 &&
    code[8152] == 81 &&
    code[8153] == 145 &&
    code[8154] == 1 &&
    code[8155] == 32 &&
    code[8156] == 144 &&
    code[8157] == 86 &&
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
  function Destinations(): set<nat> { {15,213,294,353,655,1266,1301,1329,2679,2698,2712,8100,8113,18650,18667} }
  opaque predicate Good(id: nat, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine) {
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
    else if id == 19 then state == Running(30,[3255037363],Store([],64,128))
    else if id == 20 then state == Running(31,[3255037363,3255037363],Store([],64,128))
    else if id == 21 then state == Running(36,[3255037363,3255037363,2180929414],Store([],64,128))
    else if id == 22 then state == Running(37,[3255037363,0],Store([],64,128))
    else if id == 23 then state == Running(40,[3255037363,0,655],Store([],64,128))
    else if id == 24 then state == Running(41,[3255037363],Store([],64,128))
    else if id == 25 then state == Running(42,[3255037363,3255037363],Store([],64,128))
    else if id == 26 then state == Running(47,[3255037363,3255037363,2972706854],Store([],64,128))
    else if id == 27 then state == Running(48,[3255037363,0],Store([],64,128))
    else if id == 28 then state == Running(51,[3255037363,0,353],Store([],64,128))
    else if id == 29 then state == Running(52,[3255037363],Store([],64,128))
    else if id == 30 then state == Running(53,[3255037363,3255037363],Store([],64,128))
    else if id == 31 then state == Running(58,[3255037363,3255037363,3737291867],Store([],64,128))
    else if id == 32 then state == Running(59,[3255037363,1],Store([],64,128))
    else if id == 33 then state == Running(62,[3255037363,1,213],Store([],64,128))
    else if id == 34 then state == Running(213,[3255037363],Store([],64,128))
    else if id == 35 then state == Running(214,[3255037363],Store([],64,128))
    else if id == 36 then state == Running(215,[3255037363,3255037363],Store([],64,128))
    else if id == 37 then state == Running(220,[3255037363,3255037363,3242564612],Store([],64,128))
    else if id == 38 then state == Running(221,[3255037363,0],Store([],64,128))
    else if id == 39 then state == Running(224,[3255037363,0,294],Store([],64,128))
    else if id == 40 then state == Running(225,[3255037363],Store([],64,128))
    else if id == 41 then state == Running(226,[3255037363,3255037363],Store([],64,128))
    else if id == 42 then state == Running(231,[3255037363,3255037363,3242564612],Store([],64,128))
    else if id == 43 then state == Running(232,[3255037363,0],Store([],64,128))
    else if id == 44 then state == Running(235,[3255037363,0,2679],Store([],64,128))
    else if id == 45 then state == Running(236,[3255037363],Store([],64,128))
    else if id == 46 then state == Running(237,[3255037363,3255037363],Store([],64,128))
    else if id == 47 then state == Running(242,[3255037363,3255037363,3255037363],Store([],64,128))
    else if id == 48 then state == Running(243,[3255037363,1],Store([],64,128))
    else if id == 49 then state == Running(246,[3255037363,1,2698],Store([],64,128))
    else if id == 50 then state == Running(2698,[3255037363],Store([],64,128))
    else if id == 51 then state == Running(2699,[3255037363],Store([],64,128))
    else if id == 52 then state == Running(2702,[3255037363,1329],Store([],64,128))
    else if id == 53 then state == Running(2705,[3255037363,1329,2712],Store([],64,128))
    else if id == 54 then state == Running(2706,[3255037363,1329,2712,size],Store([],64,128))
    else if id == 55 then state == Running(2708,[3255037363,1329,2712,size,4],Store([],64,128))
    else if id == 56 then state == Running(2711,[3255037363,1329,2712,size,4,18650],Store([],64,128))
    else if id == 57 then state == Running(18650,[3255037363,1329,2712,size,4],Store([],64,128))
    else if id == 58 then state == Running(18651,[3255037363,1329,2712,size,4],Store([],64,128))
    else if id == 59 then state == Running(18652,[3255037363,1329,2712,size,4,0],Store([],64,128))
    else if id == 60 then state == Running(18653,[3255037363,1329,2712,size,4,0,0],Store([],64,128))
    else if id == 61 then state == Running(18655,[3255037363,1329,2712,size,4,0,0,64],Store([],64,128))
    else if id == 62 then state == Running(18656,[3255037363,1329,2712,size,4,0,0,64,4],Store([],64,128))
    else if id == 63 then state == Running(18657,[3255037363,1329,2712,size,4,0,0,64,4,size],Store([],64,128))
    else if id == 64 then state == Running(18658,[3255037363,1329,2712,size,4,0,0,64,((size)+Modulus()-(4))%Modulus()],Store([],64,128))
    else if id == 65 then state == Running(18659,[3255037363,1329,2712,size,4,0,0,(if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0)],Store([],64,128))
    else if id == 66 then state == Running(18660,[3255037363,1329,2712,size,4,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0) == 0 then 1 else 0)],Store([],64,128))
    else if id == 67 then state == Running(18663,[3255037363,1329,2712,size,4,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0) == 0 then 1 else 0),18667],Store([],64,128))
    else if id == 68 then state == Running(18667,[3255037363,1329,2712,size,4,0,0],Store([],64,128))
    else if id == 69 then state == Running(18668,[3255037363,1329,2712,size,4,0,0],Store([],64,128))
    else if id == 70 then state == Running(18669,[3255037363,1329,2712,size,4,0],Store([],64,128))
    else if id == 71 then state == Running(18670,[3255037363,1329,2712,size,4],Store([],64,128))
    else if id == 72 then state == Running(18671,[3255037363,1329,2712,size,4,4],Store([],64,128))
    else if id == 73 then state == Running(18672,[3255037363,1329,2712,size,4,a],Store([],64,128))
    else if id == 74 then state == Running(18673,[3255037363,1329,a,size,4,2712],Store([],64,128))
    else if id == 75 then state == Running(18675,[3255037363,1329,a,size,4,2712,32],Store([],64,128))
    else if id == 76 then state == Running(18676,[3255037363,1329,a,size,4,32,2712],Store([],64,128))
    else if id == 77 then state == Running(18677,[3255037363,1329,a,size,2712,32,4],Store([],64,128))
    else if id == 78 then state == Running(18678,[3255037363,1329,a,size,2712,36],Store([],64,128))
    else if id == 79 then state == Running(18679,[3255037363,1329,a,size,2712,b],Store([],64,128))
    else if id == 80 then state == Running(18680,[3255037363,1329,a,b,2712,size],Store([],64,128))
    else if id == 81 then state == Running(18681,[3255037363,1329,a,b,2712],Store([],64,128))
    else if id == 82 then state == Running(2712,[3255037363,1329,a,b],Store([],64,128))
    else if id == 83 then state == Running(2713,[3255037363,1329,a,b],Store([],64,128))
    else if id == 84 then state == Running(2716,[3255037363,1329,a,b,8100],Store([],64,128))
    else if id == 85 then state == Running(8100,[3255037363,1329,a,b],Store([],64,128))
    else if id == 86 then state == Running(8101,[3255037363,1329,a,b],Store([],64,128))
    else if id == 87 then state == Running(8102,[3255037363,1329,a,b,0],Store([],64,128))
    else if id == 88 then state == Running(8103,[3255037363,1329,a,b,0,b],Store([],64,128))
    else if id == 89 then state == Running(8104,[3255037363,1329,a,b,0,b,a],Store([],64,128))
    else if id == 90 then state == Running(8105,[3255037363,1329,a,b,0,(if (a) > (b) then 1 else 0)],Store([],64,128))
    else if id == 91 then state == Running(8106,[3255037363,1329,a,b,0,(if (if (a) > (b) then 1 else 0) == 0 then 1 else 0)],Store([],64,128))
    else if id == 92 then state == Running(8109,[3255037363,1329,a,b,0,(if (if (a) > (b) then 1 else 0) == 0 then 1 else 0),8113],Store([],64,128))
    else if id == 93 then state == Running(8113,[3255037363,1329,a,b,0],Store([],64,128))
    else if id == 94 then state == Running(8114,[3255037363,1329,a,b,0],Store([],64,128))
    else if id == 95 then state == Running(8115,[3255037363,1329,a,b],Store([],64,128))
    else if id == 96 then state == Running(8117,[3255037363,1329,a,b,64],Store([],64,128))
    else if id == 97 then state == Running(8118,[3255037363,1329,a,b,64,64],Store([],64,128))
    else if id == 98 then state == Running(8119,[3255037363,1329,a,b,64,128],Store([],64,128))
    else if id == 99 then state == Running(8121,[3255037363,1329,a,b,64,128,32],Store([],64,128))
    else if id == 100 then state == Running(8122,[3255037363,1329,a,b,64,128,32,32],Store([],64,128))
    else if id == 101 then state == Running(8123,[3255037363,1329,a,b,64,128,32,32,128],Store([],64,128))
    else if id == 102 then state == Running(8124,[3255037363,1329,a,b,64,128,32,160],Store([],64,128))
    else if id == 103 then state == Running(8125,[3255037363,1329,160,b,64,128,32,a],Store([],64,128))
    else if id == 104 then state == Running(8126,[3255037363,1329,160,b,64,128,a,32],Store([],64,128))
    else if id == 105 then state == Running(8127,[3255037363,1329,32,b,64,128,a,160],Store([],64,128))
    else if id == 106 then state == Running(8128,[3255037363,1329,32,b,64,128],Store(Store([],64,128),160,a))
    else if id == 107 then state == Running(8129,[3255037363,1329,32,b,64,128,128],Store(Store([],64,128),160,a))
    else if id == 108 then state == Running(8130,[3255037363,1329,32,b,64,128,128,64],Store(Store([],64,128),160,a))
    else if id == 109 then state == Running(8131,[3255037363,1329,32,b,64,128,192],Store(Store([],64,128),160,a))
    else if id == 110 then state == Running(8132,[3255037363,1329,32,192,64,128,b],Store(Store([],64,128),160,a))
    else if id == 111 then state == Running(8133,[3255037363,1329,32,192,64,b,128],Store(Store([],64,128),160,a))
    else if id == 112 then state == Running(8134,[3255037363,1329,32,128,64,b,192],Store(Store([],64,128),160,a))
    else if id == 113 then state == Running(8135,[3255037363,1329,32,128,64],Store(Store(Store([],64,128),160,a),192,b))
    else if id == 114 then state == Running(8136,[3255037363,1329,32,128,64,64],Store(Store(Store([],64,128),160,a),192,b))
    else if id == 115 then state == Running(8137,[3255037363,1329,32,128,64,128],Store(Store(Store([],64,128),160,a),192,b))
    else if id == 116 then state == Running(8138,[3255037363,1329,32,128,64,128,128],Store(Store(Store([],64,128),160,a),192,b))
    else if id == 117 then state == Running(8139,[3255037363,1329,32,128,64,128,128,128],Store(Store(Store([],64,128),160,a),192,b))
    else if id == 118 then state == Running(8140,[3255037363,1329,32,128,64,128,0],Store(Store(Store([],64,128),160,a),192,b))
    else if id == 119 then state == Running(8141,[3255037363,1329,32,128,64,128,0,64],Store(Store(Store([],64,128),160,a),192,b))
    else if id == 120 then state == Running(8142,[3255037363,1329,32,128,64,128,64],Store(Store(Store([],64,128),160,a),192,b))
    else if id == 121 then state == Running(8143,[3255037363,1329,32,128,64,128,64,128],Store(Store(Store([],64,128),160,a),192,b))
    else if id == 122 then state == Running(8144,[3255037363,1329,32,128,64,128],Store(Store(Store(Store([],64,128),160,a),192,b),128,64))
    else if id == 123 then state == Running(8146,[3255037363,1329,32,128,64,128,96],Store(Store(Store(Store([],64,128),160,a),192,b),128,64))
    else if id == 124 then state == Running(8147,[3255037363,1329,32,128,64,96,128],Store(Store(Store(Store([],64,128),160,a),192,b),128,64))
    else if id == 125 then state == Running(8148,[3255037363,1329,32,128,64,96,128],Store(Store(Store(Store([],64,128),160,a),192,b),128,64))
    else if id == 126 then state == Running(8149,[3255037363,1329,32,128,64,224],Store(Store(Store(Store([],64,128),160,a),192,b),128,64))
    else if id == 127 then state == Running(8150,[3255037363,1329,32,128,224,64],Store(Store(Store(Store([],64,128),160,a),192,b),128,64))
    else if id == 128 then state == Running(8151,[3255037363,1329,32,128],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224))
    else if id == 129 then state == Running(8152,[3255037363,1329,32,128,128],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224))
    else if id == 130 then state == Running(8153,[3255037363,1329,32,128,64],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224))
    else if id == 131 then state == Running(8154,[3255037363,1329,64,128,32],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224))
    else if id == 132 then state == Running(8155,[3255037363,1329,64,160],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224))
    else if id == 133 then state == Running(8156,[3255037363,1329,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224))
    else if id == 134 then state == Running(8157,[3255037363,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224]),1329],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224))
    else if id == 135 then state == Running(1329,[3255037363,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224))
    else if id == 136 then state == Running(1330,[3255037363,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224))
    else if id == 137 then state == Running(1332,[3255037363,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224]),64],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224))
    else if id == 138 then state == Running(1333,[3255037363,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224]),224],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224))
    else if id == 139 then state == Running(1334,[3255037363,224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224))
    else if id == 140 then state == Running(1335,[3255037363,224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224]),224],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224))
    else if id == 141 then state == Running(1336,[3255037363,224],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])))
    else if id == 142 then state == Running(1338,[3255037363,224,32],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])))
    else if id == 143 then state == Running(1339,[3255037363,256],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])))
    else if id == 144 then state == Running(1342,[3255037363,256,1301],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])))
    else if id == 145 then state == Running(1301,[3255037363,256],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])))
    else if id == 146 then state == Running(1302,[3255037363,256],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])))
    else if id == 147 then state == Running(1304,[3255037363,256,64],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])))
    else if id == 148 then state == Running(1305,[3255037363,256,224],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])))
    else if id == 149 then state == Running(1306,[3255037363,256,224,224],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])))
    else if id == 150 then state == Running(1307,[3255037363,224,224,256],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])))
    else if id == 151 then state == Running(1308,[3255037363,224,32],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])))
    else if id == 152 then state == Running(1309,[3255037363,32,224],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])))
    else false
  }
  lemma Advance0(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(0,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(1,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(0,[],[]);
    assert Fetch(code,0) == Op(96,2,128);
  }
  lemma Advance1(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(1,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(2,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2,[128],[]);
    assert Fetch(code,2) == Op(96,4,64);
  }
  lemma Advance2(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(2,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(3,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(4,[128,64],[]);
    assert Fetch(code,4) == Op(82,5,0);
    StoreLoad([],64,128);
  }
  lemma Advance3(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(3,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(4,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(5,[],Store([],64,128));
    assert Fetch(code,5) == Op(52,6,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(4,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(5,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(6,[value],Store([],64,128));
    assert Fetch(code,6) == Op(128,7,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(5,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(6,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(7,[value,value],Store([],64,128));
    assert Fetch(code,7) == Op(21,8,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(6,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(7,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8,[value,(if value == 0 then 1 else 0)],Store([],64,128));
    assert Fetch(code,8) == Op(97,11,15);
  }
  lemma Advance7(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(7,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(8,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(11,[value,(if value == 0 then 1 else 0),15],Store([],64,128));
    assert Fetch(code,11) == Op(87,12,0);
    assert 15 in Destinations() && code[15] == 91;
  }
  lemma Advance8(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(8,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(9,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(15,[value],Store([],64,128));
    assert Fetch(code,15) == Op(91,16,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(9,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(10,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(16,[value],Store([],64,128));
    assert Fetch(code,16) == Op(80,17,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(10,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(11,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17,[],Store([],64,128));
    assert Fetch(code,17) == Op(96,19,4);
  }
  lemma Advance11(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(11,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(12,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19,[4],Store([],64,128));
    assert Fetch(code,19) == Op(54,20,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(12,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(13,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(20,[4,size],Store([],64,128));
    assert Fetch(code,20) == Op(16,21,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(13,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(14,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(21,[(if (size) < (4) then 1 else 0)],Store([],64,128));
    assert Fetch(code,21) == Op(97,24,1266);
  }
  lemma Advance14(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(14,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(15,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(24,[(if (size) < (4) then 1 else 0),1266],Store([],64,128));
    assert Fetch(code,24) == Op(87,25,0);
    assert 1266 in Destinations() && code[1266] == 91;
  }
  lemma Advance15(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(15,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(16,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(25,[],Store([],64,128));
    assert Fetch(code,25) == Op(95,26,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(16,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(17,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(26,[0],Store([],64,128));
    assert Fetch(code,26) == Op(53,27,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(17,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(18,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(27,[word],Store([],64,128));
    assert Fetch(code,27) == Op(96,29,224);
  }
  lemma Advance18(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(18,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(19,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(29,[word,224],Store([],64,128));
    assert Fetch(code,29) == Op(28,30,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(19,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(20,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(30,[3255037363],Store([],64,128));
    assert Fetch(code,30) == Op(128,31,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(20,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(21,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(31,[3255037363,3255037363],Store([],64,128));
    assert Fetch(code,31) == Op(99,36,2180929414);
  }
  lemma Advance21(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(21,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(22,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(36,[3255037363,3255037363,2180929414],Store([],64,128));
    assert Fetch(code,36) == Op(17,37,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(22,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(23,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(37,[3255037363,0],Store([],64,128));
    assert Fetch(code,37) == Op(97,40,655);
  }
  lemma Advance23(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(23,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(24,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(40,[3255037363,0,655],Store([],64,128));
    assert Fetch(code,40) == Op(87,41,0);
    assert 655 in Destinations() && code[655] == 91;
  }
  lemma Advance24(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(24,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(25,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(41,[3255037363],Store([],64,128));
    assert Fetch(code,41) == Op(128,42,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(25,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(26,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(42,[3255037363,3255037363],Store([],64,128));
    assert Fetch(code,42) == Op(99,47,2972706854);
  }
  lemma Advance26(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(26,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(27,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(47,[3255037363,3255037363,2972706854],Store([],64,128));
    assert Fetch(code,47) == Op(17,48,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(27,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(28,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(48,[3255037363,0],Store([],64,128));
    assert Fetch(code,48) == Op(97,51,353);
  }
  lemma Advance28(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(28,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(29,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(51,[3255037363,0,353],Store([],64,128));
    assert Fetch(code,51) == Op(87,52,0);
    assert 353 in Destinations() && code[353] == 91;
  }
  lemma Advance29(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(29,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(30,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(52,[3255037363],Store([],64,128));
    assert Fetch(code,52) == Op(128,53,0);
  }
  lemma Advance30(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(30,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(31,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(53,[3255037363,3255037363],Store([],64,128));
    assert Fetch(code,53) == Op(99,58,3737291867);
  }
  lemma Advance31(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(31,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(32,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(58,[3255037363,3255037363,3737291867],Store([],64,128));
    assert Fetch(code,58) == Op(17,59,0);
  }
  lemma Advance32(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(32,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(33,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(59,[3255037363,1],Store([],64,128));
    assert Fetch(code,59) == Op(97,62,213);
  }
  lemma Advance33(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(33,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(34,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(62,[3255037363,1,213],Store([],64,128));
    assert Fetch(code,62) == Op(87,63,0);
    assert 213 in Destinations() && code[213] == 91;
  }
  lemma Advance34(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(34,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(35,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(213,[3255037363],Store([],64,128));
    assert Fetch(code,213) == Op(91,214,0);
  }
  lemma Advance35(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(35,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(36,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(214,[3255037363],Store([],64,128));
    assert Fetch(code,214) == Op(128,215,0);
  }
  lemma Advance36(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(36,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(37,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(215,[3255037363,3255037363],Store([],64,128));
    assert Fetch(code,215) == Op(99,220,3242564612);
  }
  lemma Advance37(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(37,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(38,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(220,[3255037363,3255037363,3242564612],Store([],64,128));
    assert Fetch(code,220) == Op(17,221,0);
  }
  lemma Advance38(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(38,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(39,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(221,[3255037363,0],Store([],64,128));
    assert Fetch(code,221) == Op(97,224,294);
  }
  lemma Advance39(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(39,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(40,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(224,[3255037363,0,294],Store([],64,128));
    assert Fetch(code,224) == Op(87,225,0);
    assert 294 in Destinations() && code[294] == 91;
  }
  lemma Advance40(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(40,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(41,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(225,[3255037363],Store([],64,128));
    assert Fetch(code,225) == Op(128,226,0);
  }
  lemma Advance41(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(41,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(42,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(226,[3255037363,3255037363],Store([],64,128));
    assert Fetch(code,226) == Op(99,231,3242564612);
  }
  lemma Advance42(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(42,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(43,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(231,[3255037363,3255037363,3242564612],Store([],64,128));
    assert Fetch(code,231) == Op(20,232,0);
  }
  lemma Advance43(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(43,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(44,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(232,[3255037363,0],Store([],64,128));
    assert Fetch(code,232) == Op(97,235,2679);
  }
  lemma Advance44(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(44,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(45,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(235,[3255037363,0,2679],Store([],64,128));
    assert Fetch(code,235) == Op(87,236,0);
    assert 2679 in Destinations() && code[2679] == 91;
  }
  lemma Advance45(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(45,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(46,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(236,[3255037363],Store([],64,128));
    assert Fetch(code,236) == Op(128,237,0);
  }
  lemma Advance46(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(46,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(47,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(237,[3255037363,3255037363],Store([],64,128));
    assert Fetch(code,237) == Op(99,242,3255037363);
  }
  lemma Advance47(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(47,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(48,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(242,[3255037363,3255037363,3255037363],Store([],64,128));
    assert Fetch(code,242) == Op(20,243,0);
  }
  lemma Advance48(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(48,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(49,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(243,[3255037363,1],Store([],64,128));
    assert Fetch(code,243) == Op(97,246,2698);
  }
  lemma Advance49(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(49,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(50,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(246,[3255037363,1,2698],Store([],64,128));
    assert Fetch(code,246) == Op(87,247,0);
    assert 2698 in Destinations() && code[2698] == 91;
  }
  lemma Advance50(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(50,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(51,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2698,[3255037363],Store([],64,128));
    assert Fetch(code,2698) == Op(91,2699,0);
  }
  lemma Advance51(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(51,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(52,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2699,[3255037363],Store([],64,128));
    assert Fetch(code,2699) == Op(97,2702,1329);
  }
  lemma Advance52(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(52,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(53,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2702,[3255037363,1329],Store([],64,128));
    assert Fetch(code,2702) == Op(97,2705,2712);
  }
  lemma Advance53(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(53,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(54,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2705,[3255037363,1329,2712],Store([],64,128));
    assert Fetch(code,2705) == Op(54,2706,0);
  }
  lemma Advance54(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(54,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(55,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2706,[3255037363,1329,2712,size],Store([],64,128));
    assert Fetch(code,2706) == Op(96,2708,4);
  }
  lemma Advance55(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(55,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(56,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2708,[3255037363,1329,2712,size,4],Store([],64,128));
    assert Fetch(code,2708) == Op(97,2711,18650);
  }
  lemma Advance56(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(56,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(57,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2711,[3255037363,1329,2712,size,4,18650],Store([],64,128));
    assert Fetch(code,2711) == Op(86,2712,0);
    assert 18650 in Destinations() && code[18650] == 91;
  }
  lemma Advance57(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(57,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(58,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18650,[3255037363,1329,2712,size,4],Store([],64,128));
    assert Fetch(code,18650) == Op(91,18651,0);
  }
  lemma Advance58(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(58,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(59,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18651,[3255037363,1329,2712,size,4],Store([],64,128));
    assert Fetch(code,18651) == Op(95,18652,0);
  }
  lemma Advance59(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(59,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(60,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18652,[3255037363,1329,2712,size,4,0],Store([],64,128));
    assert Fetch(code,18652) == Op(95,18653,0);
  }
  lemma Advance60(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(60,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(61,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18653,[3255037363,1329,2712,size,4,0,0],Store([],64,128));
    assert Fetch(code,18653) == Op(96,18655,64);
  }
  lemma Advance61(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(61,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(62,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18655,[3255037363,1329,2712,size,4,0,0,64],Store([],64,128));
    assert Fetch(code,18655) == Op(131,18656,0);
  }
  lemma Advance62(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(62,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(63,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18656,[3255037363,1329,2712,size,4,0,0,64,4],Store([],64,128));
    assert Fetch(code,18656) == Op(133,18657,0);
  }
  lemma Advance63(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(63,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(64,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(18657,[3255037363,1329,2712,size,4,0,0,64,4,size],Store([],64,128));
    assert Fetch(code,18657) == Op(3,18658,0);
    var prefix: seq<Word> := [3255037363,1329,2712,size,4,0,0,64];
    assert state == Running(18657,prefix+[4,size],Store([],64,128));
    K.SubStep(code,Destinations(),18657,18658,prefix,Store([],64,128),size,4,value,size,word,a,b,h);
  }
  lemma Advance64(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(64,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(65,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18658,[3255037363,1329,2712,size,4,0,0,64,((size)+Modulus()-(4))%Modulus()],Store([],64,128));
    assert Fetch(code,18658) == Op(18,18659,0);
  }
  lemma Advance65(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(65,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(66,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18659,[3255037363,1329,2712,size,4,0,0,(if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0)],Store([],64,128));
    assert Fetch(code,18659) == Op(21,18660,0);
  }
  lemma Advance66(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(66,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(67,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18660,[3255037363,1329,2712,size,4,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0) == 0 then 1 else 0)],Store([],64,128));
    assert Fetch(code,18660) == Op(97,18663,18667);
  }
  lemma Advance67(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(67,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(68,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18663,[3255037363,1329,2712,size,4,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(64) then 1 else 0) == 0 then 1 else 0),18667],Store([],64,128));
    assert Fetch(code,18663) == Op(87,18664,0);
    assert 18667 in Destinations() && code[18667] == 91;
  }
  lemma Advance68(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(68,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(69,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18667,[3255037363,1329,2712,size,4,0,0],Store([],64,128));
    assert Fetch(code,18667) == Op(91,18668,0);
  }
  lemma Advance69(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(69,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(70,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18668,[3255037363,1329,2712,size,4,0,0],Store([],64,128));
    assert Fetch(code,18668) == Op(80,18669,0);
  }
  lemma Advance70(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(70,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(71,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18669,[3255037363,1329,2712,size,4,0],Store([],64,128));
    assert Fetch(code,18669) == Op(80,18670,0);
  }
  lemma Advance71(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(71,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(72,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18670,[3255037363,1329,2712,size,4],Store([],64,128));
    assert Fetch(code,18670) == Op(128,18671,0);
  }
  lemma Advance72(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(72,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(73,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18671,[3255037363,1329,2712,size,4,4],Store([],64,128));
    assert Fetch(code,18671) == Op(53,18672,0);
  }
  lemma Advance73(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(73,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(74,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18672,[3255037363,1329,2712,size,4,a],Store([],64,128));
    assert Fetch(code,18672) == Op(146,18673,0);
  }
  lemma Advance74(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(74,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(75,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18673,[3255037363,1329,a,size,4,2712],Store([],64,128));
    assert Fetch(code,18673) == Op(96,18675,32);
  }
  lemma Advance75(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(75,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(76,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18675,[3255037363,1329,a,size,4,2712,32],Store([],64,128));
    assert Fetch(code,18675) == Op(144,18676,0);
  }
  lemma Advance76(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(76,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(77,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18676,[3255037363,1329,a,size,4,32,2712],Store([],64,128));
    assert Fetch(code,18676) == Op(145,18677,0);
  }
  lemma Advance77(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(77,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(78,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(18677,[3255037363,1329,a,size,2712,32,4],Store([],64,128));
    assert Fetch(code,18677) == Op(1,18678,0);
    var prefix: seq<Word> := [3255037363,1329,a,size,2712];
    assert state == Running(18677,prefix+[32,4],Store([],64,128));
    K.AddStep(code,Destinations(),18677,18678,prefix,Store([],64,128),4,32,value,size,word,a,b,h);
  }
  lemma Advance78(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(78,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(79,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18678,[3255037363,1329,a,size,2712,36],Store([],64,128));
    assert Fetch(code,18678) == Op(53,18679,0);
  }
  lemma Advance79(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(79,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(80,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18679,[3255037363,1329,a,size,2712,b],Store([],64,128));
    assert Fetch(code,18679) == Op(145,18680,0);
  }
  lemma Advance80(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(80,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(81,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18680,[3255037363,1329,a,b,2712,size],Store([],64,128));
    assert Fetch(code,18680) == Op(80,18681,0);
  }
  lemma Advance81(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(81,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(82,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18681,[3255037363,1329,a,b,2712],Store([],64,128));
    assert Fetch(code,18681) == Op(86,18682,0);
    assert 2712 in Destinations() && code[2712] == 91;
  }
  lemma Advance82(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(82,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(83,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2712,[3255037363,1329,a,b],Store([],64,128));
    assert Fetch(code,2712) == Op(91,2713,0);
  }
  lemma Advance83(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(83,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(84,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2713,[3255037363,1329,a,b],Store([],64,128));
    assert Fetch(code,2713) == Op(97,2716,8100);
  }
  lemma Advance84(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(84,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(85,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2716,[3255037363,1329,a,b,8100],Store([],64,128));
    assert Fetch(code,2716) == Op(86,2717,0);
    assert 8100 in Destinations() && code[8100] == 91;
  }
  lemma Advance85(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(85,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(86,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8100,[3255037363,1329,a,b],Store([],64,128));
    assert Fetch(code,8100) == Op(91,8101,0);
  }
  lemma Advance86(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(86,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(87,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8101,[3255037363,1329,a,b],Store([],64,128));
    assert Fetch(code,8101) == Op(95,8102,0);
  }
  lemma Advance87(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(87,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(88,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8102,[3255037363,1329,a,b,0],Store([],64,128));
    assert Fetch(code,8102) == Op(129,8103,0);
  }
  lemma Advance88(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(88,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(89,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8103,[3255037363,1329,a,b,0,b],Store([],64,128));
    assert Fetch(code,8103) == Op(131,8104,0);
  }
  lemma Advance89(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(89,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(90,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8104,[3255037363,1329,a,b,0,b,a],Store([],64,128));
    assert Fetch(code,8104) == Op(17,8105,0);
  }
  lemma Advance90(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(90,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(91,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8105,[3255037363,1329,a,b,0,(if (a) > (b) then 1 else 0)],Store([],64,128));
    assert Fetch(code,8105) == Op(21,8106,0);
  }
  lemma Advance91(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(91,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(92,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8106,[3255037363,1329,a,b,0,(if (if (a) > (b) then 1 else 0) == 0 then 1 else 0)],Store([],64,128));
    assert Fetch(code,8106) == Op(97,8109,8113);
  }
  lemma Advance92(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(92,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(93,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8109,[3255037363,1329,a,b,0,(if (if (a) > (b) then 1 else 0) == 0 then 1 else 0),8113],Store([],64,128));
    assert Fetch(code,8109) == Op(87,8110,0);
    assert 8113 in Destinations() && code[8113] == 91;
  }
  lemma Advance93(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(93,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(94,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8113,[3255037363,1329,a,b,0],Store([],64,128));
    assert Fetch(code,8113) == Op(91,8114,0);
  }
  lemma Advance94(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(94,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(95,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8114,[3255037363,1329,a,b,0],Store([],64,128));
    assert Fetch(code,8114) == Op(80,8115,0);
  }
  lemma Advance95(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(95,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(96,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8115,[3255037363,1329,a,b],Store([],64,128));
    assert Fetch(code,8115) == Op(96,8117,64);
  }
  lemma Advance96(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(96,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(97,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8117,[3255037363,1329,a,b,64],Store([],64,128));
    assert Fetch(code,8117) == Op(128,8118,0);
  }
  lemma Advance97(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(97,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(98,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8118,[3255037363,1329,a,b,64,64],Store([],64,128));
    assert Fetch(code,8118) == Op(81,8119,0);
    StoreLoad([],64,128);
  }
  lemma Advance98(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(98,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(99,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8119,[3255037363,1329,a,b,64,128],Store([],64,128));
    assert Fetch(code,8119) == Op(96,8121,32);
  }
  lemma Advance99(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(99,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(100,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8121,[3255037363,1329,a,b,64,128,32],Store([],64,128));
    assert Fetch(code,8121) == Op(128,8122,0);
  }
  lemma Advance100(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(100,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(101,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8122,[3255037363,1329,a,b,64,128,32,32],Store([],64,128));
    assert Fetch(code,8122) == Op(130,8123,0);
  }
  lemma Advance101(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(101,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(102,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(8123,[3255037363,1329,a,b,64,128,32,32,128],Store([],64,128));
    assert Fetch(code,8123) == Op(1,8124,0);
    var prefix: seq<Word> := [3255037363,1329,a,b,64,128,32];
    assert state == Running(8123,prefix+[32,128],Store([],64,128));
    K.AddStep(code,Destinations(),8123,8124,prefix,Store([],64,128),128,32,value,size,word,a,b,h);
  }
  lemma Advance102(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(102,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(103,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8124,[3255037363,1329,a,b,64,128,32,160],Store([],64,128));
    assert Fetch(code,8124) == Op(148,8125,0);
  }
  lemma Advance103(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(103,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(104,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8125,[3255037363,1329,160,b,64,128,32,a],Store([],64,128));
    assert Fetch(code,8125) == Op(144,8126,0);
  }
  lemma Advance104(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(104,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(105,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8126,[3255037363,1329,160,b,64,128,a,32],Store([],64,128));
    assert Fetch(code,8126) == Op(148,8127,0);
  }
  lemma Advance105(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(105,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(106,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8127,[3255037363,1329,32,b,64,128,a,160],Store([],64,128));
    assert Fetch(code,8127) == Op(82,8128,0);
    StoreLoad(Store([],64,128),160,a);
  }
  lemma Advance106(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(106,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(107,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8128,[3255037363,1329,32,b,64,128],Store(Store([],64,128),160,a));
    assert Fetch(code,8128) == Op(128,8129,0);
  }
  lemma Advance107(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(107,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(108,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8129,[3255037363,1329,32,b,64,128,128],Store(Store([],64,128),160,a));
    assert Fetch(code,8129) == Op(130,8130,0);
  }
  lemma Advance108(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(108,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(109,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(8130,[3255037363,1329,32,b,64,128,128,64],Store(Store([],64,128),160,a));
    assert Fetch(code,8130) == Op(1,8131,0);
    var prefix: seq<Word> := [3255037363,1329,32,b,64,128];
    assert state == Running(8130,prefix+[128,64],Store(Store([],64,128),160,a));
    K.AddStep(code,Destinations(),8130,8131,prefix,Store(Store([],64,128),160,a),64,128,value,size,word,a,b,h);
  }
  lemma Advance109(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(109,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(110,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8131,[3255037363,1329,32,b,64,128,192],Store(Store([],64,128),160,a));
    assert Fetch(code,8131) == Op(146,8132,0);
  }
  lemma Advance110(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(110,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(111,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8132,[3255037363,1329,32,192,64,128,b],Store(Store([],64,128),160,a));
    assert Fetch(code,8132) == Op(144,8133,0);
  }
  lemma Advance111(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(111,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(112,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8133,[3255037363,1329,32,192,64,b,128],Store(Store([],64,128),160,a));
    assert Fetch(code,8133) == Op(146,8134,0);
  }
  lemma Advance112(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(112,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(113,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8134,[3255037363,1329,32,128,64,b,192],Store(Store([],64,128),160,a));
    assert Fetch(code,8134) == Op(82,8135,0);
    StoreLoad(Store(Store([],64,128),160,a),192,b);
  }
  lemma Advance113(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(113,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(114,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8135,[3255037363,1329,32,128,64],Store(Store(Store([],64,128),160,a),192,b));
    assert Fetch(code,8135) == Op(128,8136,0);
  }
  lemma Advance114(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(114,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(115,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8136,[3255037363,1329,32,128,64,64],Store(Store(Store([],64,128),160,a),192,b));
    assert Fetch(code,8136) == Op(81,8137,0);
    StoreLoad([],64,128);
    StoreFrame(Store([],64,128),160,a,64);
    StoreFrame(Store(Store([],64,128),160,a),192,b,64);
  }
  lemma Advance115(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(115,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(116,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8137,[3255037363,1329,32,128,64,128],Store(Store(Store([],64,128),160,a),192,b));
    assert Fetch(code,8137) == Op(128,8138,0);
  }
  lemma Advance116(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(116,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(117,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8138,[3255037363,1329,32,128,64,128,128],Store(Store(Store([],64,128),160,a),192,b));
    assert Fetch(code,8138) == Op(131,8139,0);
  }
  lemma Advance117(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(117,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(118,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(8139,[3255037363,1329,32,128,64,128,128,128],Store(Store(Store([],64,128),160,a),192,b));
    assert Fetch(code,8139) == Op(3,8140,0);
    var prefix: seq<Word> := [3255037363,1329,32,128,64,128];
    assert state == Running(8139,prefix+[128,128],Store(Store(Store([],64,128),160,a),192,b));
    K.SubStep(code,Destinations(),8139,8140,prefix,Store(Store(Store([],64,128),160,a),192,b),128,128,value,size,word,a,b,h);
  }
  lemma Advance118(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(118,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(119,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8140,[3255037363,1329,32,128,64,128,0],Store(Store(Store([],64,128),160,a),192,b));
    assert Fetch(code,8140) == Op(130,8141,0);
  }
  lemma Advance119(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(119,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(120,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(8141,[3255037363,1329,32,128,64,128,0,64],Store(Store(Store([],64,128),160,a),192,b));
    assert Fetch(code,8141) == Op(1,8142,0);
    var prefix: seq<Word> := [3255037363,1329,32,128,64,128];
    assert state == Running(8141,prefix+[0,64],Store(Store(Store([],64,128),160,a),192,b));
    K.AddStep(code,Destinations(),8141,8142,prefix,Store(Store(Store([],64,128),160,a),192,b),64,0,value,size,word,a,b,h);
  }
  lemma Advance120(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(120,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(121,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8142,[3255037363,1329,32,128,64,128,64],Store(Store(Store([],64,128),160,a),192,b));
    assert Fetch(code,8142) == Op(129,8143,0);
  }
  lemma Advance121(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(121,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(122,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8143,[3255037363,1329,32,128,64,128,64,128],Store(Store(Store([],64,128),160,a),192,b));
    assert Fetch(code,8143) == Op(82,8144,0);
    StoreLoad(Store(Store(Store([],64,128),160,a),192,b),128,64);
  }
  lemma Advance122(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(122,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(123,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8144,[3255037363,1329,32,128,64,128],Store(Store(Store(Store([],64,128),160,a),192,b),128,64));
    assert Fetch(code,8144) == Op(96,8146,96);
  }
  lemma Advance123(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(123,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(124,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8146,[3255037363,1329,32,128,64,128,96],Store(Store(Store(Store([],64,128),160,a),192,b),128,64));
    assert Fetch(code,8146) == Op(144,8147,0);
  }
  lemma Advance124(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(124,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(125,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8147,[3255037363,1329,32,128,64,96,128],Store(Store(Store(Store([],64,128),160,a),192,b),128,64));
    assert Fetch(code,8147) == Op(146,8148,0);
  }
  lemma Advance125(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(125,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(126,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(8148,[3255037363,1329,32,128,64,96,128],Store(Store(Store(Store([],64,128),160,a),192,b),128,64));
    assert Fetch(code,8148) == Op(1,8149,0);
    var prefix: seq<Word> := [3255037363,1329,32,128,64];
    assert state == Running(8148,prefix+[96,128],Store(Store(Store(Store([],64,128),160,a),192,b),128,64));
    K.AddStep(code,Destinations(),8148,8149,prefix,Store(Store(Store(Store([],64,128),160,a),192,b),128,64),128,96,value,size,word,a,b,h);
  }
  lemma Advance126(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(126,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(127,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8149,[3255037363,1329,32,128,64,224],Store(Store(Store(Store([],64,128),160,a),192,b),128,64));
    assert Fetch(code,8149) == Op(144,8150,0);
  }
  lemma Advance127(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(127,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(128,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8150,[3255037363,1329,32,128,224,64],Store(Store(Store(Store([],64,128),160,a),192,b),128,64));
    assert Fetch(code,8150) == Op(82,8151,0);
    StoreLoad(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224);
  }
  lemma Advance128(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(128,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(129,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8151,[3255037363,1329,32,128],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224));
    assert Fetch(code,8151) == Op(128,8152,0);
  }
  lemma Advance129(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(129,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(130,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8152,[3255037363,1329,32,128,128],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224));
    assert Fetch(code,8152) == Op(81,8153,0);
    StoreLoad(Store(Store(Store([],64,128),160,a),192,b),128,64);
    StoreFrame(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224,128);
  }
  lemma Advance130(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(130,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(131,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8153,[3255037363,1329,32,128,64],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224));
    assert Fetch(code,8153) == Op(145,8154,0);
  }
  lemma Advance131(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(131,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(132,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(8154,[3255037363,1329,64,128,32],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224));
    assert Fetch(code,8154) == Op(1,8155,0);
    var prefix: seq<Word> := [3255037363,1329,64];
    assert state == Running(8154,prefix+[128,32],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224));
    K.AddStep(code,Destinations(),8154,8155,prefix,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),32,128,value,size,word,a,b,h);
  }
  lemma Advance132(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(132,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(133,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8155,[3255037363,1329,64,160],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224));
    assert Fetch(code,8155) == Op(32,8156,0);
    PairWindow(a,b);
    PairWindow(a,b);
  }
  lemma Advance133(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(133,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(134,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8156,[3255037363,1329,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224));
    assert Fetch(code,8156) == Op(144,8157,0);
    PairWindow(a,b);
  }
  lemma Advance134(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(134,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(135,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8157,[3255037363,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224]),1329],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224));
    assert Fetch(code,8157) == Op(86,8158,0);
    PairWindow(a,b);
    assert 1329 in Destinations() && code[1329] == 91;
  }
  lemma Advance135(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(135,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(136,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1329,[3255037363,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224));
    assert Fetch(code,1329) == Op(91,1330,0);
    PairWindow(a,b);
  }
  lemma Advance136(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(136,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(137,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1330,[3255037363,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224));
    assert Fetch(code,1330) == Op(96,1332,64);
    PairWindow(a,b);
  }
  lemma Advance137(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(137,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(138,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1332,[3255037363,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224]),64],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224));
    assert Fetch(code,1332) == Op(81,1333,0);
    PairWindow(a,b);
    StoreLoad(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224);
  }
  lemma Advance138(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(138,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(139,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1333,[3255037363,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224]),224],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224));
    assert Fetch(code,1333) == Op(144,1334,0);
    PairWindow(a,b);
  }
  lemma Advance139(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(139,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(140,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1334,[3255037363,224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224));
    assert Fetch(code,1334) == Op(129,1335,0);
    PairWindow(a,b);
  }
  lemma Advance140(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(140,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(141,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1335,[3255037363,224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224]),224],Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224));
    assert Fetch(code,1335) == Op(82,1336,0);
    PairWindow(a,b);
    StoreLoad(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224]));
  }
  lemma Advance141(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(141,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(142,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1336,[3255037363,224],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])));
    assert Fetch(code,1336) == Op(96,1338,32);
    PairWindow(a,b);
  }
  lemma Advance142(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(142,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(143,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(1338,[3255037363,224,32],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])));
    assert Fetch(code,1338) == Op(1,1339,0);
    PairWindow(a,b);
    var prefix: seq<Word> := [3255037363];
    assert state == Running(1338,prefix+[224,32],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])));
    K.AddStep(code,Destinations(),1338,1339,prefix,Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])),32,224,value,size,word,a,b,h);
  }
  lemma Advance143(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(143,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(144,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1339,[3255037363,256],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])));
    assert Fetch(code,1339) == Op(97,1342,1301);
    PairWindow(a,b);
  }
  lemma Advance144(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(144,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(145,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1342,[3255037363,256,1301],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])));
    assert Fetch(code,1342) == Op(86,1343,0);
    PairWindow(a,b);
    assert 1301 in Destinations() && code[1301] == 91;
  }
  lemma Advance145(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(145,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(146,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1301,[3255037363,256],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])));
    assert Fetch(code,1301) == Op(91,1302,0);
    PairWindow(a,b);
  }
  lemma Advance146(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(146,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(147,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1302,[3255037363,256],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])));
    assert Fetch(code,1302) == Op(96,1304,64);
    PairWindow(a,b);
  }
  lemma Advance147(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(147,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(148,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1304,[3255037363,256,64],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])));
    assert Fetch(code,1304) == Op(81,1305,0);
    PairWindow(a,b);
    StoreLoad(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224);
    StoreFrame(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224]),64);
  }
  lemma Advance148(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(148,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(149,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1305,[3255037363,256,224],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])));
    assert Fetch(code,1305) == Op(128,1306,0);
    PairWindow(a,b);
  }
  lemma Advance149(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(149,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(150,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1306,[3255037363,256,224,224],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])));
    assert Fetch(code,1306) == Op(145,1307,0);
    PairWindow(a,b);
  }
  lemma Advance150(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(150,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(151,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    assert state == Running(1307,[3255037363,224,224,256],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])));
    assert Fetch(code,1307) == Op(3,1308,0);
    PairWindow(a,b);
    var prefix: seq<Word> := [3255037363,224];
    assert state == Running(1307,prefix+[224,256],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])));
    K.SubStep(code,Destinations(),1307,1308,prefix,Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])),256,224,value,size,word,a,b,h);
  }
  lemma Advance151(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(151,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); Good(152,next,value,size,word,a,b,h)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1308,[3255037363,224,32],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])));
    assert Fetch(code,1308) == Op(144,1309,0);
    PairWindow(a,b);
  }
  lemma Advance152(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(152,state,value,size,word,a,b,h)
    ensures state.Running? && |state.stack| <= 10 && |state.memory| <= 256
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,h); next == Returned(Encode(Result(a,b,h),32))
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1309,[3255037363,32,224],Store(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224])));
    assert Fetch(code,1309) == Op(243,1310,0);
    PairWindow(a,b);
    StoreLoad(Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224),224,Hash(h,Store(Store(Store(Store(Store([],64,128),160,a),192,b),128,64),64,224)[160..224]));
  }
  lemma SemanticPreimage(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(132,state,value,size,word,a,b,h)
    ensures state.Running? && |state.memory| >= 224
    ensures state.memory[160..224] == SortedPair(a,b)
  { reveal Good(); PairWindow(a,b); }
  lemma SemanticWitness(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(132,state,value,size,word,a,b,h)
    requires a == 123 && b == 456
    ensures state.Running? && |state.memory| >= 224
    ensures state.memory[160..224] == SortedPair(a,b)
  { reveal Good(); PairWindow(a,b); }
  ghost method RunBlock0(code: seq<Byte>,initial: State,value: Word,size: Word,word: Word,a: Word,b: Word,h: HashEngine) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(0,initial,value,size,word,a,b,h)
    ensures Good(20,state,value,size,word,a,b,h)
  {
    state:=initial;
    Advance0(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance1(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance2(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance3(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance4(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance5(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance6(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance7(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance8(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance9(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance10(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance11(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance12(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance13(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance14(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance15(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance16(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance17(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance18(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance19(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
  }
  ghost method RunBlock20(code: seq<Byte>,initial: State,value: Word,size: Word,word: Word,a: Word,b: Word,h: HashEngine) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(20,initial,value,size,word,a,b,h)
    ensures Good(40,state,value,size,word,a,b,h)
  {
    state:=initial;
    Advance20(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance21(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance22(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance23(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance24(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance25(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance26(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance27(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance28(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance29(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance30(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance31(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance32(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance33(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance34(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance35(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance36(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance37(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance38(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance39(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
  }
  ghost method RunBlock40(code: seq<Byte>,initial: State,value: Word,size: Word,word: Word,a: Word,b: Word,h: HashEngine) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(40,initial,value,size,word,a,b,h)
    ensures Good(60,state,value,size,word,a,b,h)
  {
    state:=initial;
    Advance40(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance41(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance42(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance43(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance44(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance45(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance46(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance47(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance48(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance49(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance50(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance51(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance52(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance53(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance54(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance55(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance56(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance57(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance58(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance59(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
  }
  ghost method RunBlock60(code: seq<Byte>,initial: State,value: Word,size: Word,word: Word,a: Word,b: Word,h: HashEngine) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(60,initial,value,size,word,a,b,h)
    ensures Good(80,state,value,size,word,a,b,h)
  {
    state:=initial;
    Advance60(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance61(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance62(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance63(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance64(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance65(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance66(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance67(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance68(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance69(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance70(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance71(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance72(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance73(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance74(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance75(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance76(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance77(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance78(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance79(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
  }
  ghost method RunBlock80(code: seq<Byte>,initial: State,value: Word,size: Word,word: Word,a: Word,b: Word,h: HashEngine) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(80,initial,value,size,word,a,b,h)
    ensures Good(100,state,value,size,word,a,b,h)
  {
    state:=initial;
    Advance80(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance81(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance82(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance83(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance84(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance85(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance86(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance87(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance88(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance89(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance90(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance91(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance92(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance93(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance94(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance95(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance96(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance97(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance98(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance99(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
  }
  ghost method RunBlock100(code: seq<Byte>,initial: State,value: Word,size: Word,word: Word,a: Word,b: Word,h: HashEngine) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(100,initial,value,size,word,a,b,h)
    ensures Good(120,state,value,size,word,a,b,h)
  {
    state:=initial;
    Advance100(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance101(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance102(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance103(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance104(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance105(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance106(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance107(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance108(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance109(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance110(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance111(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance112(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance113(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance114(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance115(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance116(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance117(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance118(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance119(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
  }
  ghost method RunBlock120(code: seq<Byte>,initial: State,value: Word,size: Word,word: Word,a: Word,b: Word,h: HashEngine) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(120,initial,value,size,word,a,b,h)
    ensures Good(140,state,value,size,word,a,b,h)
  {
    state:=initial;
    Advance120(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance121(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance122(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance123(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance124(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance125(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance126(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance127(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance128(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance129(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance130(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance131(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance132(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance133(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance134(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance135(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance136(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance137(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance138(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance139(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
  }
  ghost method RunBlock140(code: seq<Byte>,initial: State,value: Word,size: Word,word: Word,a: Word,b: Word,h: HashEngine) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,h) && Good(140,initial,value,size,word,a,b,h)
    ensures state == Returned(Encode(Result(a,b,h),32))
  {
    state:=initial;
    Advance140(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance141(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance142(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance143(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance144(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance145(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance146(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance147(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance148(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance149(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance150(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance151(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
    Advance152(code,state,value,size,word,a,b,h);
    state := Step(code,Destinations(),state,value,size,word,a,b,h);
  }
  lemma Start(value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine)
    ensures Good(0,Running(0,[],[]),value,size,word,a,b,h)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, value: Word, size: Word, word: Word, a: Word, b: Word, h: HashEngine) returns (state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,h)
    ensures state == Returned(Encode(Result(a,b,h),32))
  {
    Start(value,size,word,a,b,h);
    state := Running(0,[],[]);
    state:=RunBlock0(code,state,value,size,word,a,b,h);
    state:=RunBlock20(code,state,value,size,word,a,b,h);
    state:=RunBlock40(code,state,value,size,word,a,b,h);
    state:=RunBlock60(code,state,value,size,word,a,b,h);
    state:=RunBlock80(code,state,value,size,word,a,b,h);
    state:=RunBlock100(code,state,value,size,word,a,b,h);
    state:=RunBlock120(code,state,value,size,word,a,b,h);
    state:=RunBlock140(code,state,value,size,word,a,b,h);
  }
}
