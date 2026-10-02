// SPDX-License-Identifier: MIT
// Generated exact executed-byte certificate. Never edit directly.
include "Machine.dfy"
module BytecodeGetterPAYLOAD {
  import opened BytecodeGetterMachine
  function Constant(): Word { 57896044618658097711785492504343953926634992332820282019728792003956564819969 }
  predicate Admitted(value: Word, size: Word, word: Word) {
    value == 0 && size >= 4 && Selector(word) == 646875021
  }
  opaque predicate Matches(code: seq<Byte>) {
    |code| == 20049 &&
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
    code[23] == 6 &&
    code[24] == 87 &&
    code[25] == 95 &&
    code[26] == 53 &&
    code[27] == 96 &&
    code[28] == 224 &&
    code[29] == 28 &&
    code[30] == 128 &&
    code[31] == 99 &&
    code[32] == 101 &&
    code[33] == 216 &&
    code[34] == 17 &&
    code[35] == 234 &&
    code[36] == 17 &&
    code[37] == 97 &&
    code[38] == 0 &&
    code[39] == 158 &&
    code[40] == 87 &&
    code[158] == 91 &&
    code[159] == 128 &&
    code[160] == 99 &&
    code[161] == 31 &&
    code[162] == 176 &&
    code[163] == 83 &&
    code[164] == 227 &&
    code[165] == 17 &&
    code[166] == 97 &&
    code[167] == 0 &&
    code[168] == 217 &&
    code[169] == 87 &&
    code[170] == 128 &&
    code[171] == 99 &&
    code[172] == 31 &&
    code[173] == 176 &&
    code[174] == 83 &&
    code[175] == 227 &&
    code[176] == 20 &&
    code[177] == 97 &&
    code[178] == 1 &&
    code[179] == 88 &&
    code[180] == 87 &&
    code[181] == 128 &&
    code[182] == 99 &&
    code[183] == 38 &&
    code[184] == 142 &&
    code[185] == 135 &&
    code[186] == 141 &&
    code[187] == 20 &&
    code[188] == 97 &&
    code[189] == 1 &&
    code[190] == 107 &&
    code[191] == 87 &&
    code[217] == 91 &&
    code[262] == 91 &&
    code[344] == 91 &&
    code[363] == 91 &&
    code[364] == 97 &&
    code[365] == 1 &&
    code[366] == 115 &&
    code[367] == 97 &&
    code[368] == 5 &&
    code[369] == 240 &&
    code[370] == 86 &&
    code[371] == 91 &&
    code[372] == 96 &&
    code[373] == 64 &&
    code[374] == 81 &&
    code[375] == 144 &&
    code[376] == 129 &&
    code[377] == 82 &&
    code[378] == 96 &&
    code[379] == 32 &&
    code[380] == 1 &&
    code[381] == 91 &&
    code[382] == 96 &&
    code[383] == 64 &&
    code[384] == 81 &&
    code[385] == 128 &&
    code[386] == 145 &&
    code[387] == 3 &&
    code[388] == 144 &&
    code[389] == 243 &&
    code[1520] == 91 &&
    code[1521] == 97 &&
    code[1522] == 5 &&
    code[1523] == 255 &&
    code[1524] == 96 &&
    code[1525] == 1 &&
    code[1526] == 96 &&
    code[1527] == 255 &&
    code[1528] == 27 &&
    code[1529] == 96 &&
    code[1530] == 1 &&
    code[1531] == 97 &&
    code[1532] == 70 &&
    code[1533] == 64 &&
    code[1534] == 86 &&
    code[1535] == 91 &&
    code[1536] == 129 &&
    code[1537] == 86 &&
    code[17984] == 91 &&
    code[17985] == 128 &&
    code[17986] == 130 &&
    code[17987] == 1 &&
    code[17988] == 130 &&
    code[17989] == 129 &&
    code[17990] == 18 &&
    code[17991] == 95 &&
    code[17992] == 131 &&
    code[17993] == 18 &&
    code[17994] == 128 &&
    code[17995] == 21 &&
    code[17996] == 130 &&
    code[17997] == 22 &&
    code[17998] == 130 &&
    code[17999] == 21 &&
    code[18000] == 130 &&
    code[18001] == 22 &&
    code[18002] == 23 &&
    code[18003] == 21 &&
    code[18004] == 97 &&
    code[18005] == 70 &&
    code[18006] == 95 &&
    code[18007] == 87 &&
    code[18015] == 91 &&
    code[18016] == 80 &&
    code[18017] == 80 &&
    code[18018] == 146 &&
    code[18019] == 145 &&
    code[18020] == 80 &&
    code[18021] == 80 &&
    code[18022] == 86
  }
  function Destinations(): set<nat> { {15,158,217,262,344,363,371,1520,1535,17984,18015} }
  opaque predicate Good(id: nat, state: State, value: Word, size: Word, word: Word) {
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
    else if id == 12 then state == Running(20,[4,size],Store([],64,128))
    else if id == 13 then state == Running(21,[0],Store([],64,128))
    else if id == 14 then state == Running(24,[0,262],Store([],64,128))
    else if id == 15 then state == Running(25,[],Store([],64,128))
    else if id == 16 then state == Running(26,[0],Store([],64,128))
    else if id == 17 then state == Running(27,[word],Store([],64,128))
    else if id == 18 then state == Running(29,[word,224],Store([],64,128))
    else if id == 19 then state == Running(30,[646875021],Store([],64,128))
    else if id == 20 then state == Running(31,[646875021,646875021],Store([],64,128))
    else if id == 21 then state == Running(36,[646875021,646875021,1708659178],Store([],64,128))
    else if id == 22 then state == Running(37,[646875021,1],Store([],64,128))
    else if id == 23 then state == Running(40,[646875021,1,158],Store([],64,128))
    else if id == 24 then state == Running(158,[646875021],Store([],64,128))
    else if id == 25 then state == Running(159,[646875021],Store([],64,128))
    else if id == 26 then state == Running(160,[646875021,646875021],Store([],64,128))
    else if id == 27 then state == Running(165,[646875021,646875021,531649507],Store([],64,128))
    else if id == 28 then state == Running(166,[646875021,0],Store([],64,128))
    else if id == 29 then state == Running(169,[646875021,0,217],Store([],64,128))
    else if id == 30 then state == Running(170,[646875021],Store([],64,128))
    else if id == 31 then state == Running(171,[646875021,646875021],Store([],64,128))
    else if id == 32 then state == Running(176,[646875021,646875021,531649507],Store([],64,128))
    else if id == 33 then state == Running(177,[646875021,0],Store([],64,128))
    else if id == 34 then state == Running(180,[646875021,0,344],Store([],64,128))
    else if id == 35 then state == Running(181,[646875021],Store([],64,128))
    else if id == 36 then state == Running(182,[646875021,646875021],Store([],64,128))
    else if id == 37 then state == Running(187,[646875021,646875021,646875021],Store([],64,128))
    else if id == 38 then state == Running(188,[646875021,1],Store([],64,128))
    else if id == 39 then state == Running(191,[646875021,1,363],Store([],64,128))
    else if id == 40 then state == Running(363,[646875021],Store([],64,128))
    else if id == 41 then state == Running(364,[646875021],Store([],64,128))
    else if id == 42 then state == Running(367,[646875021,371],Store([],64,128))
    else if id == 43 then state == Running(370,[646875021,371,1520],Store([],64,128))
    else if id == 44 then state == Running(1520,[646875021,371],Store([],64,128))
    else if id == 45 then state == Running(1521,[646875021,371],Store([],64,128))
    else if id == 46 then state == Running(1524,[646875021,371,1535],Store([],64,128))
    else if id == 47 then state == Running(1526,[646875021,371,1535,1],Store([],64,128))
    else if id == 48 then state == Running(1528,[646875021,371,1535,1,255],Store([],64,128))
    else if id == 49 then state == Running(1529,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968],Store([],64,128))
    else if id == 50 then state == Running(1531,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1],Store([],64,128))
    else if id == 51 then state == Running(1534,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,17984],Store([],64,128))
    else if id == 52 then state == Running(17984,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1],Store([],64,128))
    else if id == 53 then state == Running(17985,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1],Store([],64,128))
    else if id == 54 then state == Running(17986,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,1],Store([],64,128))
    else if id == 55 then state == Running(17987,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,1,57896044618658097711785492504343953926634992332820282019728792003956564819968],Store([],64,128))
    else if id == 56 then state == Running(17988,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969],Store([],64,128))
    else if id == 57 then state == Running(17989,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,57896044618658097711785492504343953926634992332820282019728792003956564819968],Store([],64,128))
    else if id == 58 then state == Running(17990,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,57896044618658097711785492504343953926634992332820282019728792003956564819968,57896044618658097711785492504343953926634992332820282019728792003956564819969],Store([],64,128))
    else if id == 59 then state == Running(17991,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0],Store([],64,128))
    else if id == 60 then state == Running(17992,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0],Store([],64,128))
    else if id == 61 then state == Running(17993,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,1],Store([],64,128))
    else if id == 62 then state == Running(17994,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0],Store([],64,128))
    else if id == 63 then state == Running(17995,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,0],Store([],64,128))
    else if id == 64 then state == Running(17996,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,1],Store([],64,128))
    else if id == 65 then state == Running(17997,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,1,0],Store([],64,128))
    else if id == 66 then state == Running(17998,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,0],Store([],64,128))
    else if id == 67 then state == Running(17999,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,0,0],Store([],64,128))
    else if id == 68 then state == Running(18000,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,0,1],Store([],64,128))
    else if id == 69 then state == Running(18001,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,0,1,0],Store([],64,128))
    else if id == 70 then state == Running(18002,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,0,0],Store([],64,128))
    else if id == 71 then state == Running(18003,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,0],Store([],64,128))
    else if id == 72 then state == Running(18004,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,1],Store([],64,128))
    else if id == 73 then state == Running(18007,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,1,18015],Store([],64,128))
    else if id == 74 then state == Running(18015,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0],Store([],64,128))
    else if id == 75 then state == Running(18016,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0],Store([],64,128))
    else if id == 76 then state == Running(18017,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0],Store([],64,128))
    else if id == 77 then state == Running(18018,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969],Store([],64,128))
    else if id == 78 then state == Running(18019,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,1535],Store([],64,128))
    else if id == 79 then state == Running(18020,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969,1535,1,57896044618658097711785492504343953926634992332820282019728792003956564819968],Store([],64,128))
    else if id == 80 then state == Running(18021,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969,1535,1],Store([],64,128))
    else if id == 81 then state == Running(18022,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969,1535],Store([],64,128))
    else if id == 82 then state == Running(1535,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969],Store([],64,128))
    else if id == 83 then state == Running(1536,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969],Store([],64,128))
    else if id == 84 then state == Running(1537,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969,371],Store([],64,128))
    else if id == 85 then state == Running(371,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969],Store([],64,128))
    else if id == 86 then state == Running(372,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969],Store([],64,128))
    else if id == 87 then state == Running(374,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969,64],Store([],64,128))
    else if id == 88 then state == Running(375,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969,128],Store([],64,128))
    else if id == 89 then state == Running(376,[646875021,371,128,57896044618658097711785492504343953926634992332820282019728792003956564819969],Store([],64,128))
    else if id == 90 then state == Running(377,[646875021,371,128,57896044618658097711785492504343953926634992332820282019728792003956564819969,128],Store([],64,128))
    else if id == 91 then state == Running(378,[646875021,371,128],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969))
    else if id == 92 then state == Running(380,[646875021,371,128,32],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969))
    else if id == 93 then state == Running(381,[646875021,371,160],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969))
    else if id == 94 then state == Running(382,[646875021,371,160],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969))
    else if id == 95 then state == Running(384,[646875021,371,160,64],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969))
    else if id == 96 then state == Running(385,[646875021,371,160,128],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969))
    else if id == 97 then state == Running(386,[646875021,371,160,128,128],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969))
    else if id == 98 then state == Running(387,[646875021,371,128,128,160],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969))
    else if id == 99 then state == Running(388,[646875021,371,128,32],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969))
    else if id == 100 then state == Running(389,[646875021,371,32,128],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969))
    else false
  }
  lemma Advance0(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(0,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(1,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(0,[],[]);
    assert Fetch(code,0) == Op(96,2,128);
  }
  lemma Advance1(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(1,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(2,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2,[128],[]);
    assert Fetch(code,2) == Op(96,4,64);
  }
  lemma Advance2(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(2,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(3,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(4,[128,64],[]);
    assert Fetch(code,4) == Op(82,5,0);
    StoreLoad([],64,128);
  }
  lemma Advance3(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(3,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(4,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(5,[],Store([],64,128));
    assert Fetch(code,5) == Op(52,6,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(4,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(5,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(6,[value],Store([],64,128));
    assert Fetch(code,6) == Op(128,7,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(5,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(6,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(7,[value,value],Store([],64,128));
    assert Fetch(code,7) == Op(21,8,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(6,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(7,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8,[value,1],Store([],64,128));
    assert Fetch(code,8) == Op(97,11,15);
  }
  lemma Advance7(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(7,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(8,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(11,[value,1,15],Store([],64,128));
    assert Fetch(code,11) == Op(87,12,0);
    assert 15 in Destinations() && code[15] == 91;
  }
  lemma Advance8(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(8,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(9,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(15,[value],Store([],64,128));
    assert Fetch(code,15) == Op(91,16,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(9,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(10,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(16,[value],Store([],64,128));
    assert Fetch(code,16) == Op(80,17,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(10,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(11,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17,[],Store([],64,128));
    assert Fetch(code,17) == Op(96,19,4);
  }
  lemma Advance11(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(11,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(12,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19,[4],Store([],64,128));
    assert Fetch(code,19) == Op(54,20,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(12,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(13,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(20,[4,size],Store([],64,128));
    assert Fetch(code,20) == Op(16,21,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(13,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(14,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(21,[0],Store([],64,128));
    assert Fetch(code,21) == Op(97,24,262);
  }
  lemma Advance14(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(14,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(15,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(24,[0,262],Store([],64,128));
    assert Fetch(code,24) == Op(87,25,0);
    assert 262 in Destinations() && code[262] == 91;
  }
  lemma Advance15(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(15,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(16,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(25,[],Store([],64,128));
    assert Fetch(code,25) == Op(95,26,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(16,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(17,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(26,[0],Store([],64,128));
    assert Fetch(code,26) == Op(53,27,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(17,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(18,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(27,[word],Store([],64,128));
    assert Fetch(code,27) == Op(96,29,224);
  }
  lemma Advance18(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(18,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(19,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(29,[word,224],Store([],64,128));
    assert Fetch(code,29) == Op(28,30,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(19,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(20,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(30,[646875021],Store([],64,128));
    assert Fetch(code,30) == Op(128,31,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(20,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(21,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(31,[646875021,646875021],Store([],64,128));
    assert Fetch(code,31) == Op(99,36,1708659178);
  }
  lemma Advance21(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(21,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(22,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(36,[646875021,646875021,1708659178],Store([],64,128));
    assert Fetch(code,36) == Op(17,37,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(22,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(23,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(37,[646875021,1],Store([],64,128));
    assert Fetch(code,37) == Op(97,40,158);
  }
  lemma Advance23(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(23,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(24,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(40,[646875021,1,158],Store([],64,128));
    assert Fetch(code,40) == Op(87,41,0);
    assert 158 in Destinations() && code[158] == 91;
  }
  lemma Advance24(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(24,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(25,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(158,[646875021],Store([],64,128));
    assert Fetch(code,158) == Op(91,159,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(25,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(26,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(159,[646875021],Store([],64,128));
    assert Fetch(code,159) == Op(128,160,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(26,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(27,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(160,[646875021,646875021],Store([],64,128));
    assert Fetch(code,160) == Op(99,165,531649507);
  }
  lemma Advance27(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(27,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(28,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(165,[646875021,646875021,531649507],Store([],64,128));
    assert Fetch(code,165) == Op(17,166,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(28,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(29,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(166,[646875021,0],Store([],64,128));
    assert Fetch(code,166) == Op(97,169,217);
  }
  lemma Advance29(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(29,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(30,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(169,[646875021,0,217],Store([],64,128));
    assert Fetch(code,169) == Op(87,170,0);
    assert 217 in Destinations() && code[217] == 91;
  }
  lemma Advance30(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(30,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(31,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(170,[646875021],Store([],64,128));
    assert Fetch(code,170) == Op(128,171,0);
  }
  lemma Advance31(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(31,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(32,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(171,[646875021,646875021],Store([],64,128));
    assert Fetch(code,171) == Op(99,176,531649507);
  }
  lemma Advance32(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(32,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(33,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(176,[646875021,646875021,531649507],Store([],64,128));
    assert Fetch(code,176) == Op(20,177,0);
  }
  lemma Advance33(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(33,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(34,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(177,[646875021,0],Store([],64,128));
    assert Fetch(code,177) == Op(97,180,344);
  }
  lemma Advance34(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(34,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(35,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(180,[646875021,0,344],Store([],64,128));
    assert Fetch(code,180) == Op(87,181,0);
    assert 344 in Destinations() && code[344] == 91;
  }
  lemma Advance35(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(35,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(36,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(181,[646875021],Store([],64,128));
    assert Fetch(code,181) == Op(128,182,0);
  }
  lemma Advance36(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(36,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(37,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(182,[646875021,646875021],Store([],64,128));
    assert Fetch(code,182) == Op(99,187,646875021);
  }
  lemma Advance37(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(37,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(38,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(187,[646875021,646875021,646875021],Store([],64,128));
    assert Fetch(code,187) == Op(20,188,0);
  }
  lemma Advance38(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(38,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(39,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(188,[646875021,1],Store([],64,128));
    assert Fetch(code,188) == Op(97,191,363);
  }
  lemma Advance39(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(39,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(40,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(191,[646875021,1,363],Store([],64,128));
    assert Fetch(code,191) == Op(87,192,0);
    assert 363 in Destinations() && code[363] == 91;
  }
  lemma Advance40(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(40,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(41,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(363,[646875021],Store([],64,128));
    assert Fetch(code,363) == Op(91,364,0);
  }
  lemma Advance41(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(41,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(42,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(364,[646875021],Store([],64,128));
    assert Fetch(code,364) == Op(97,367,371);
  }
  lemma Advance42(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(42,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(43,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(367,[646875021,371],Store([],64,128));
    assert Fetch(code,367) == Op(97,370,1520);
  }
  lemma Advance43(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(43,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(44,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(370,[646875021,371,1520],Store([],64,128));
    assert Fetch(code,370) == Op(86,371,0);
    assert 1520 in Destinations() && code[1520] == 91;
  }
  lemma Advance44(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(44,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(45,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1520,[646875021,371],Store([],64,128));
    assert Fetch(code,1520) == Op(91,1521,0);
  }
  lemma Advance45(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(45,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(46,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1521,[646875021,371],Store([],64,128));
    assert Fetch(code,1521) == Op(97,1524,1535);
  }
  lemma Advance46(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(46,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(47,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1524,[646875021,371,1535],Store([],64,128));
    assert Fetch(code,1524) == Op(96,1526,1);
  }
  lemma Advance47(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(47,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(48,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1526,[646875021,371,1535,1],Store([],64,128));
    assert Fetch(code,1526) == Op(96,1528,255);
  }
  lemma Advance48(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(48,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(49,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1528,[646875021,371,1535,1,255],Store([],64,128));
    assert Fetch(code,1528) == Op(27,1529,0);
  }
  lemma Advance49(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(49,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(50,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1529,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968],Store([],64,128));
    assert Fetch(code,1529) == Op(96,1531,1);
  }
  lemma Advance50(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(50,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(51,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1531,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1],Store([],64,128));
    assert Fetch(code,1531) == Op(97,1534,17984);
  }
  lemma Advance51(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(51,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(52,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1534,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,17984],Store([],64,128));
    assert Fetch(code,1534) == Op(86,1535,0);
    assert 17984 in Destinations() && code[17984] == 91;
  }
  lemma Advance52(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(52,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(53,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17984,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1],Store([],64,128));
    assert Fetch(code,17984) == Op(91,17985,0);
  }
  lemma Advance53(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(53,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(54,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17985,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1],Store([],64,128));
    assert Fetch(code,17985) == Op(128,17986,0);
  }
  lemma Advance54(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(54,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(55,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17986,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,1],Store([],64,128));
    assert Fetch(code,17986) == Op(130,17987,0);
  }
  lemma Advance55(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(55,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(56,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17987,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,1,57896044618658097711785492504343953926634992332820282019728792003956564819968],Store([],64,128));
    assert Fetch(code,17987) == Op(1,17988,0);
  }
  lemma Advance56(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(56,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(57,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17988,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969],Store([],64,128));
    assert Fetch(code,17988) == Op(130,17989,0);
  }
  lemma Advance57(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(57,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(58,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17989,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,57896044618658097711785492504343953926634992332820282019728792003956564819968],Store([],64,128));
    assert Fetch(code,17989) == Op(129,17990,0);
  }
  lemma Advance58(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(58,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(59,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17990,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,57896044618658097711785492504343953926634992332820282019728792003956564819968,57896044618658097711785492504343953926634992332820282019728792003956564819969],Store([],64,128));
    assert Fetch(code,17990) == Op(18,17991,0);
  }
  lemma Advance59(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(59,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(60,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17991,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0],Store([],64,128));
    assert Fetch(code,17991) == Op(95,17992,0);
  }
  lemma Advance60(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(60,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(61,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17992,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0],Store([],64,128));
    assert Fetch(code,17992) == Op(131,17993,0);
  }
  lemma Advance61(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(61,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(62,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17993,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,1],Store([],64,128));
    assert Fetch(code,17993) == Op(18,17994,0);
  }
  lemma Advance62(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(62,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(63,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17994,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0],Store([],64,128));
    assert Fetch(code,17994) == Op(128,17995,0);
  }
  lemma Advance63(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(63,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(64,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17995,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,0],Store([],64,128));
    assert Fetch(code,17995) == Op(21,17996,0);
  }
  lemma Advance64(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(64,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(65,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17996,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,1],Store([],64,128));
    assert Fetch(code,17996) == Op(130,17997,0);
  }
  lemma Advance65(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(65,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(66,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17997,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,1,0],Store([],64,128));
    assert Fetch(code,17997) == Op(22,17998,0);
  }
  lemma Advance66(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(66,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(67,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17998,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,0],Store([],64,128));
    assert Fetch(code,17998) == Op(130,17999,0);
  }
  lemma Advance67(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(67,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(68,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17999,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,0,0],Store([],64,128));
    assert Fetch(code,17999) == Op(21,18000,0);
  }
  lemma Advance68(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(68,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(69,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18000,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,0,1],Store([],64,128));
    assert Fetch(code,18000) == Op(130,18001,0);
  }
  lemma Advance69(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(69,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(70,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18001,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,0,1,0],Store([],64,128));
    assert Fetch(code,18001) == Op(22,18002,0);
  }
  lemma Advance70(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(70,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(71,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18002,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,0,0],Store([],64,128));
    assert Fetch(code,18002) == Op(23,18003,0);
  }
  lemma Advance71(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(71,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(72,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18003,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,0],Store([],64,128));
    assert Fetch(code,18003) == Op(21,18004,0);
  }
  lemma Advance72(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(72,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(73,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18004,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,1],Store([],64,128));
    assert Fetch(code,18004) == Op(97,18007,18015);
  }
  lemma Advance73(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(73,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(74,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18007,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0,1,18015],Store([],64,128));
    assert Fetch(code,18007) == Op(87,18008,0);
    assert 18015 in Destinations() && code[18015] == 91;
  }
  lemma Advance74(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(74,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(75,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18015,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0],Store([],64,128));
    assert Fetch(code,18015) == Op(91,18016,0);
  }
  lemma Advance75(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(75,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(76,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18016,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0,0],Store([],64,128));
    assert Fetch(code,18016) == Op(80,18017,0);
  }
  lemma Advance76(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(76,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(77,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18017,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969,0],Store([],64,128));
    assert Fetch(code,18017) == Op(80,18018,0);
  }
  lemma Advance77(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(77,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(78,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18018,[646875021,371,1535,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,57896044618658097711785492504343953926634992332820282019728792003956564819969],Store([],64,128));
    assert Fetch(code,18018) == Op(146,18019,0);
  }
  lemma Advance78(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(78,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(79,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18019,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969,57896044618658097711785492504343953926634992332820282019728792003956564819968,1,1535],Store([],64,128));
    assert Fetch(code,18019) == Op(145,18020,0);
  }
  lemma Advance79(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(79,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(80,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18020,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969,1535,1,57896044618658097711785492504343953926634992332820282019728792003956564819968],Store([],64,128));
    assert Fetch(code,18020) == Op(80,18021,0);
  }
  lemma Advance80(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(80,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(81,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18021,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969,1535,1],Store([],64,128));
    assert Fetch(code,18021) == Op(80,18022,0);
  }
  lemma Advance81(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(81,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(82,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18022,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969,1535],Store([],64,128));
    assert Fetch(code,18022) == Op(86,18023,0);
    assert 1535 in Destinations() && code[1535] == 91;
  }
  lemma Advance82(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(82,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(83,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1535,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969],Store([],64,128));
    assert Fetch(code,1535) == Op(91,1536,0);
  }
  lemma Advance83(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(83,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(84,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1536,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969],Store([],64,128));
    assert Fetch(code,1536) == Op(129,1537,0);
  }
  lemma Advance84(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(84,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(85,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(1537,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969,371],Store([],64,128));
    assert Fetch(code,1537) == Op(86,1538,0);
    assert 371 in Destinations() && code[371] == 91;
  }
  lemma Advance85(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(85,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(86,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(371,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969],Store([],64,128));
    assert Fetch(code,371) == Op(91,372,0);
  }
  lemma Advance86(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(86,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(87,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(372,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969],Store([],64,128));
    assert Fetch(code,372) == Op(96,374,64);
  }
  lemma Advance87(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(87,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(88,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(374,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969,64],Store([],64,128));
    assert Fetch(code,374) == Op(81,375,0);
    StoreLoad([],64,128);
  }
  lemma Advance88(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(88,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(89,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(375,[646875021,371,57896044618658097711785492504343953926634992332820282019728792003956564819969,128],Store([],64,128));
    assert Fetch(code,375) == Op(144,376,0);
  }
  lemma Advance89(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(89,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(90,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(376,[646875021,371,128,57896044618658097711785492504343953926634992332820282019728792003956564819969],Store([],64,128));
    assert Fetch(code,376) == Op(129,377,0);
  }
  lemma Advance90(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(90,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(91,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(377,[646875021,371,128,57896044618658097711785492504343953926634992332820282019728792003956564819969,128],Store([],64,128));
    assert Fetch(code,377) == Op(82,378,0);
    StoreLoad(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969);
  }
  lemma Advance91(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(91,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(92,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(378,[646875021,371,128],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969));
    assert Fetch(code,378) == Op(96,380,32);
  }
  lemma Advance92(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(92,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(93,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(380,[646875021,371,128,32],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969));
    assert Fetch(code,380) == Op(1,381,0);
  }
  lemma Advance93(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(93,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(94,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(381,[646875021,371,160],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969));
    assert Fetch(code,381) == Op(91,382,0);
  }
  lemma Advance94(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(94,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(95,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(382,[646875021,371,160],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969));
    assert Fetch(code,382) == Op(96,384,64);
  }
  lemma Advance95(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(95,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(96,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(384,[646875021,371,160,64],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969));
    assert Fetch(code,384) == Op(81,385,0);
    StoreLoad([],64,128);
    StoreFrame(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969,64);
  }
  lemma Advance96(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(96,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(97,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(385,[646875021,371,160,128],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969));
    assert Fetch(code,385) == Op(128,386,0);
  }
  lemma Advance97(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(97,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(98,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(386,[646875021,371,160,128,128],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969));
    assert Fetch(code,386) == Op(145,387,0);
  }
  lemma Advance98(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(98,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(99,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(387,[646875021,371,128,128,160],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969));
    assert Fetch(code,387) == Op(3,388,0);
  }
  lemma Advance99(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(99,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); Good(100,next,value,size,word)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(388,[646875021,371,128,32],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969));
    assert Fetch(code,388) == Op(144,389,0);
  }
  lemma Advance100(code: seq<Byte>, state: State, value: Word, size: Word, word: Word)
    requires Matches(code) && Admitted(value,size,word) && Good(100,state,value,size,word)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word); next == Returned(Encode(Constant(),32))
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(389,[646875021,371,32,128],Store(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969));
    assert Fetch(code,389) == Op(243,390,0);
    StoreLoad(Store([],64,128),128,57896044618658097711785492504343953926634992332820282019728792003956564819969);
  }
  lemma Start(value: Word, size: Word, word: Word)
    ensures Good(0,Running(0,[],[]),value,size,word)
  { reveal Good(); }
  lemma SignedConstant()
    ensures Signed(Constant()) == -(Modulus() as int)/2 + 1
  {}
  ghost method Run(code: seq<Byte>, value: Word, size: Word, word: Word) returns (state: State)
    requires Matches(code) && Admitted(value,size,word)
    ensures state == Returned(Encode(Constant(),32))
  {
    Start(value,size,word);
    state := Running(0,[],[]);
    Advance0(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance1(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance2(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance3(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance4(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance5(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance6(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance7(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance8(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance9(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance10(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance11(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance12(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance13(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance14(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance15(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance16(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance17(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance18(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance19(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance20(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance21(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance22(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance23(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance24(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance25(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance26(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance27(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance28(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance29(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance30(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance31(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance32(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance33(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance34(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance35(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance36(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance37(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance38(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance39(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance40(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance41(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance42(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance43(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance44(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance45(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance46(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance47(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance48(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance49(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance50(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance51(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance52(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance53(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance54(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance55(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance56(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance57(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance58(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance59(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance60(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance61(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance62(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance63(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance64(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance65(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance66(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance67(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance68(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance69(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance70(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance71(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance72(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance73(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance74(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance75(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance76(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance77(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance78(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance79(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance80(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance81(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance82(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance83(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance84(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance85(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance86(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance87(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance88(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance89(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance90(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance91(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance92(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance93(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance94(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance95(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance96(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance97(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance98(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance99(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
    Advance100(code,state,value,size,word);
    state := Step(code,Destinations(),state,value,size,word);
  }
}
