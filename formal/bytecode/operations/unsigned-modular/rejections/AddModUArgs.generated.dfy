// SPDX-License-Identifier: MIT
// Generated exact executed-byte certificate. Never edit directly.
include "../Machine.dfy"
module OperationsUnsignedModularRawAddModUArgs {
  import opened OperationsUnsignedModularMachine
  function Result(a: Word, b: Word, c: Word): Word { 0 }
  predicate Admitted(value: Word, size: Word, word: Word, a: Word, b: Word, c: Word) {
    value == 0 && 4 <= size < 100 && Selector(word) == 2972706854
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
    code[294] == 91 &&
    code[295] == 128 &&
    code[296] == 99 &&
    code[297] == 177 &&
    code[298] == 47 &&
    code[299] == 232 &&
    code[300] == 38 &&
    code[301] == 20 &&
    code[302] == 97 &&
    code[303] == 10 &&
    code[304] == 32 &&
    code[305] == 87 &&
    code[353] == 91 &&
    code[655] == 91 &&
    code[1266] == 91 &&
    code[2592] == 91 &&
    code[2593] == 97 &&
    code[2594] == 5 &&
    code[2595] == 49 &&
    code[2596] == 97 &&
    code[2597] == 10 &&
    code[2598] == 46 &&
    code[2599] == 54 &&
    code[2600] == 96 &&
    code[2601] == 4 &&
    code[2602] == 97 &&
    code[2603] == 72 &&
    code[2604] == 250 &&
    code[2605] == 86 &&
    code[18682] == 91 &&
    code[18683] == 95 &&
    code[18684] == 95 &&
    code[18685] == 95 &&
    code[18686] == 96 &&
    code[18687] == 96 &&
    code[18688] == 132 &&
    code[18689] == 134 &&
    code[18690] == 3 &&
    code[18691] == 18 &&
    code[18692] == 21 &&
    code[18693] == 97 &&
    code[18694] == 73 &&
    code[18695] == 12 &&
    code[18696] == 87 &&
    code[18697] == 95 &&
    code[18698] == 95 &&
    code[18699] == 253 &&
    code[18700] == 91
  }
  function Destinations(): set<nat> { {15,213,294,353,655,1266,2592,18682,18700} }
  opaque predicate Good(id: nat, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word) {
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
    else if id == 19 then state == Running(30,[2972706854],Store([],64,128))
    else if id == 20 then state == Running(31,[2972706854,2972706854],Store([],64,128))
    else if id == 21 then state == Running(36,[2972706854,2972706854,2180929414],Store([],64,128))
    else if id == 22 then state == Running(37,[2972706854,0],Store([],64,128))
    else if id == 23 then state == Running(40,[2972706854,0,655],Store([],64,128))
    else if id == 24 then state == Running(41,[2972706854],Store([],64,128))
    else if id == 25 then state == Running(42,[2972706854,2972706854],Store([],64,128))
    else if id == 26 then state == Running(47,[2972706854,2972706854,2972706854],Store([],64,128))
    else if id == 27 then state == Running(48,[2972706854,0],Store([],64,128))
    else if id == 28 then state == Running(51,[2972706854,0,353],Store([],64,128))
    else if id == 29 then state == Running(52,[2972706854],Store([],64,128))
    else if id == 30 then state == Running(53,[2972706854,2972706854],Store([],64,128))
    else if id == 31 then state == Running(58,[2972706854,2972706854,3737291867],Store([],64,128))
    else if id == 32 then state == Running(59,[2972706854,1],Store([],64,128))
    else if id == 33 then state == Running(62,[2972706854,1,213],Store([],64,128))
    else if id == 34 then state == Running(213,[2972706854],Store([],64,128))
    else if id == 35 then state == Running(214,[2972706854],Store([],64,128))
    else if id == 36 then state == Running(215,[2972706854,2972706854],Store([],64,128))
    else if id == 37 then state == Running(220,[2972706854,2972706854,3242564612],Store([],64,128))
    else if id == 38 then state == Running(221,[2972706854,1],Store([],64,128))
    else if id == 39 then state == Running(224,[2972706854,1,294],Store([],64,128))
    else if id == 40 then state == Running(294,[2972706854],Store([],64,128))
    else if id == 41 then state == Running(295,[2972706854],Store([],64,128))
    else if id == 42 then state == Running(296,[2972706854,2972706854],Store([],64,128))
    else if id == 43 then state == Running(301,[2972706854,2972706854,2972706854],Store([],64,128))
    else if id == 44 then state == Running(302,[2972706854,1],Store([],64,128))
    else if id == 45 then state == Running(305,[2972706854,1,2592],Store([],64,128))
    else if id == 46 then state == Running(2592,[2972706854],Store([],64,128))
    else if id == 47 then state == Running(2593,[2972706854],Store([],64,128))
    else if id == 48 then state == Running(2596,[2972706854,1329],Store([],64,128))
    else if id == 49 then state == Running(2599,[2972706854,1329,2606],Store([],64,128))
    else if id == 50 then state == Running(2600,[2972706854,1329,2606,size],Store([],64,128))
    else if id == 51 then state == Running(2602,[2972706854,1329,2606,size,4],Store([],64,128))
    else if id == 52 then state == Running(2605,[2972706854,1329,2606,size,4,18682],Store([],64,128))
    else if id == 53 then state == Running(18682,[2972706854,1329,2606,size,4],Store([],64,128))
    else if id == 54 then state == Running(18683,[2972706854,1329,2606,size,4],Store([],64,128))
    else if id == 55 then state == Running(18684,[2972706854,1329,2606,size,4,0],Store([],64,128))
    else if id == 56 then state == Running(18685,[2972706854,1329,2606,size,4,0,0],Store([],64,128))
    else if id == 57 then state == Running(18686,[2972706854,1329,2606,size,4,0,0,0],Store([],64,128))
    else if id == 58 then state == Running(18688,[2972706854,1329,2606,size,4,0,0,0,96],Store([],64,128))
    else if id == 59 then state == Running(18689,[2972706854,1329,2606,size,4,0,0,0,96,4],Store([],64,128))
    else if id == 60 then state == Running(18690,[2972706854,1329,2606,size,4,0,0,0,96,4,size],Store([],64,128))
    else if id == 61 then state == Running(18691,[2972706854,1329,2606,size,4,0,0,0,96,((size)+Modulus()-(4))%Modulus()],Store([],64,128))
    else if id == 62 then state == Running(18692,[2972706854,1329,2606,size,4,0,0,0,(if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(96) then 1 else 0)],Store([],64,128))
    else if id == 63 then state == Running(18693,[2972706854,1329,2606,size,4,0,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(96) then 1 else 0) == 0 then 1 else 0)],Store([],64,128))
    else if id == 64 then state == Running(18696,[2972706854,1329,2606,size,4,0,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(96) then 1 else 0) == 0 then 1 else 0),18700],Store([],64,128))
    else if id == 65 then state == Running(18697,[2972706854,1329,2606,size,4,0,0,0],Store([],64,128))
    else if id == 66 then state == Running(18698,[2972706854,1329,2606,size,4,0,0,0,0],Store([],64,128))
    else if id == 67 then state == Running(18699,[2972706854,1329,2606,size,4,0,0,0,0,0],Store([],64,128))
    else false
  }
  lemma Advance0(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(0,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(1,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(0,[],[]);
    assert Fetch(code,0) == Op(96,2,128);
  }
  lemma Advance1(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(1,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(2,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2,[128],[]);
    assert Fetch(code,2) == Op(96,4,64);
  }
  lemma Advance2(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(2,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(3,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(4,[128,64],[]);
    assert Fetch(code,4) == Op(82,5,0);
    StoreLoad([],64,128);
  }
  lemma Advance3(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(3,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(4,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(5,[],Store([],64,128));
    assert Fetch(code,5) == Op(52,6,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(4,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(5,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(6,[value],Store([],64,128));
    assert Fetch(code,6) == Op(128,7,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(5,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(6,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(7,[value,value],Store([],64,128));
    assert Fetch(code,7) == Op(21,8,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(6,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(7,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(8,[value,(if value == 0 then 1 else 0)],Store([],64,128));
    assert Fetch(code,8) == Op(97,11,15);
  }
  lemma Advance7(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(7,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(8,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(11,[value,(if value == 0 then 1 else 0),15],Store([],64,128));
    assert Fetch(code,11) == Op(87,12,0);
    assert 15 in Destinations() && code[15] == 91;
  }
  lemma Advance8(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(8,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(9,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(15,[value],Store([],64,128));
    assert Fetch(code,15) == Op(91,16,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(9,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(10,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(16,[value],Store([],64,128));
    assert Fetch(code,16) == Op(80,17,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(10,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(11,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(17,[],Store([],64,128));
    assert Fetch(code,17) == Op(96,19,4);
  }
  lemma Advance11(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(11,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(12,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(19,[4],Store([],64,128));
    assert Fetch(code,19) == Op(54,20,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(12,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(13,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(20,[4,size],Store([],64,128));
    assert Fetch(code,20) == Op(16,21,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(13,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(14,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(21,[(if (size) < (4) then 1 else 0)],Store([],64,128));
    assert Fetch(code,21) == Op(97,24,1266);
  }
  lemma Advance14(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(14,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(15,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(24,[(if (size) < (4) then 1 else 0),1266],Store([],64,128));
    assert Fetch(code,24) == Op(87,25,0);
    assert 1266 in Destinations() && code[1266] == 91;
  }
  lemma Advance15(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(15,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(16,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(25,[],Store([],64,128));
    assert Fetch(code,25) == Op(95,26,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(16,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(17,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(26,[0],Store([],64,128));
    assert Fetch(code,26) == Op(53,27,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(17,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(18,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(27,[word],Store([],64,128));
    assert Fetch(code,27) == Op(96,29,224);
  }
  lemma Advance18(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(18,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(19,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(29,[word,224],Store([],64,128));
    assert Fetch(code,29) == Op(28,30,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(19,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(20,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(30,[2972706854],Store([],64,128));
    assert Fetch(code,30) == Op(128,31,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(20,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(21,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(31,[2972706854,2972706854],Store([],64,128));
    assert Fetch(code,31) == Op(99,36,2180929414);
  }
  lemma Advance21(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(21,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(22,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(36,[2972706854,2972706854,2180929414],Store([],64,128));
    assert Fetch(code,36) == Op(17,37,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(22,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(23,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(37,[2972706854,0],Store([],64,128));
    assert Fetch(code,37) == Op(97,40,655);
  }
  lemma Advance23(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(23,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(24,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(40,[2972706854,0,655],Store([],64,128));
    assert Fetch(code,40) == Op(87,41,0);
    assert 655 in Destinations() && code[655] == 91;
  }
  lemma Advance24(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(24,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(25,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(41,[2972706854],Store([],64,128));
    assert Fetch(code,41) == Op(128,42,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(25,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(26,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(42,[2972706854,2972706854],Store([],64,128));
    assert Fetch(code,42) == Op(99,47,2972706854);
  }
  lemma Advance26(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(26,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(27,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(47,[2972706854,2972706854,2972706854],Store([],64,128));
    assert Fetch(code,47) == Op(17,48,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(27,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(28,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(48,[2972706854,0],Store([],64,128));
    assert Fetch(code,48) == Op(97,51,353);
  }
  lemma Advance28(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(28,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(29,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(51,[2972706854,0,353],Store([],64,128));
    assert Fetch(code,51) == Op(87,52,0);
    assert 353 in Destinations() && code[353] == 91;
  }
  lemma Advance29(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(29,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(30,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(52,[2972706854],Store([],64,128));
    assert Fetch(code,52) == Op(128,53,0);
  }
  lemma Advance30(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(30,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(31,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(53,[2972706854,2972706854],Store([],64,128));
    assert Fetch(code,53) == Op(99,58,3737291867);
  }
  lemma Advance31(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(31,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(32,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(58,[2972706854,2972706854,3737291867],Store([],64,128));
    assert Fetch(code,58) == Op(17,59,0);
  }
  lemma Advance32(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(32,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(33,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(59,[2972706854,1],Store([],64,128));
    assert Fetch(code,59) == Op(97,62,213);
  }
  lemma Advance33(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(33,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(34,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(62,[2972706854,1,213],Store([],64,128));
    assert Fetch(code,62) == Op(87,63,0);
    assert 213 in Destinations() && code[213] == 91;
  }
  lemma Advance34(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(34,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(35,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(213,[2972706854],Store([],64,128));
    assert Fetch(code,213) == Op(91,214,0);
  }
  lemma Advance35(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(35,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(36,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(214,[2972706854],Store([],64,128));
    assert Fetch(code,214) == Op(128,215,0);
  }
  lemma Advance36(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(36,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(37,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(215,[2972706854,2972706854],Store([],64,128));
    assert Fetch(code,215) == Op(99,220,3242564612);
  }
  lemma Advance37(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(37,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(38,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(220,[2972706854,2972706854,3242564612],Store([],64,128));
    assert Fetch(code,220) == Op(17,221,0);
  }
  lemma Advance38(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(38,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(39,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(221,[2972706854,1],Store([],64,128));
    assert Fetch(code,221) == Op(97,224,294);
  }
  lemma Advance39(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(39,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(40,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(224,[2972706854,1,294],Store([],64,128));
    assert Fetch(code,224) == Op(87,225,0);
    assert 294 in Destinations() && code[294] == 91;
  }
  lemma Advance40(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(40,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(41,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(294,[2972706854],Store([],64,128));
    assert Fetch(code,294) == Op(91,295,0);
  }
  lemma Advance41(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(41,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(42,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(295,[2972706854],Store([],64,128));
    assert Fetch(code,295) == Op(128,296,0);
  }
  lemma Advance42(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(42,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(43,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(296,[2972706854,2972706854],Store([],64,128));
    assert Fetch(code,296) == Op(99,301,2972706854);
  }
  lemma Advance43(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(43,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(44,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(301,[2972706854,2972706854,2972706854],Store([],64,128));
    assert Fetch(code,301) == Op(20,302,0);
  }
  lemma Advance44(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(44,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(45,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(302,[2972706854,1],Store([],64,128));
    assert Fetch(code,302) == Op(97,305,2592);
  }
  lemma Advance45(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(45,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(46,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(305,[2972706854,1,2592],Store([],64,128));
    assert Fetch(code,305) == Op(87,306,0);
    assert 2592 in Destinations() && code[2592] == 91;
  }
  lemma Advance46(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(46,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(47,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2592,[2972706854],Store([],64,128));
    assert Fetch(code,2592) == Op(91,2593,0);
  }
  lemma Advance47(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(47,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(48,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2593,[2972706854],Store([],64,128));
    assert Fetch(code,2593) == Op(97,2596,1329);
  }
  lemma Advance48(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(48,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(49,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2596,[2972706854,1329],Store([],64,128));
    assert Fetch(code,2596) == Op(97,2599,2606);
  }
  lemma Advance49(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(49,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(50,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2599,[2972706854,1329,2606],Store([],64,128));
    assert Fetch(code,2599) == Op(54,2600,0);
  }
  lemma Advance50(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(50,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(51,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2600,[2972706854,1329,2606,size],Store([],64,128));
    assert Fetch(code,2600) == Op(96,2602,4);
  }
  lemma Advance51(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(51,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(52,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2602,[2972706854,1329,2606,size,4],Store([],64,128));
    assert Fetch(code,2602) == Op(97,2605,18682);
  }
  lemma Advance52(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(52,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(53,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(2605,[2972706854,1329,2606,size,4,18682],Store([],64,128));
    assert Fetch(code,2605) == Op(86,2606,0);
    assert 18682 in Destinations() && code[18682] == 91;
  }
  lemma Advance53(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(53,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(54,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18682,[2972706854,1329,2606,size,4],Store([],64,128));
    assert Fetch(code,18682) == Op(91,18683,0);
  }
  lemma Advance54(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(54,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(55,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18683,[2972706854,1329,2606,size,4],Store([],64,128));
    assert Fetch(code,18683) == Op(95,18684,0);
  }
  lemma Advance55(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(55,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(56,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18684,[2972706854,1329,2606,size,4,0],Store([],64,128));
    assert Fetch(code,18684) == Op(95,18685,0);
  }
  lemma Advance56(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(56,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(57,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18685,[2972706854,1329,2606,size,4,0,0],Store([],64,128));
    assert Fetch(code,18685) == Op(95,18686,0);
  }
  lemma Advance57(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(57,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(58,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18686,[2972706854,1329,2606,size,4,0,0,0],Store([],64,128));
    assert Fetch(code,18686) == Op(96,18688,96);
  }
  lemma Advance58(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(58,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(59,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18688,[2972706854,1329,2606,size,4,0,0,0,96],Store([],64,128));
    assert Fetch(code,18688) == Op(132,18689,0);
  }
  lemma Advance59(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(59,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(60,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18689,[2972706854,1329,2606,size,4,0,0,0,96,4],Store([],64,128));
    assert Fetch(code,18689) == Op(134,18690,0);
  }
  lemma Advance60(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(60,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(61,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18690,[2972706854,1329,2606,size,4,0,0,0,96,4,size],Store([],64,128));
    assert Fetch(code,18690) == Op(3,18691,0);
  }
  lemma Advance61(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(61,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(62,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18691,[2972706854,1329,2606,size,4,0,0,0,96,((size)+Modulus()-(4))%Modulus()],Store([],64,128));
    assert Fetch(code,18691) == Op(18,18692,0);
  }
  lemma Advance62(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(62,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(63,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18692,[2972706854,1329,2606,size,4,0,0,0,(if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(96) then 1 else 0)],Store([],64,128));
    assert Fetch(code,18692) == Op(21,18693,0);
  }
  lemma Advance63(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(63,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(64,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18693,[2972706854,1329,2606,size,4,0,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(96) then 1 else 0) == 0 then 1 else 0)],Store([],64,128));
    assert Fetch(code,18693) == Op(97,18696,18700);
  }
  lemma Advance64(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(64,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(65,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18696,[2972706854,1329,2606,size,4,0,0,0,(if (if Signed(((size)+Modulus()-(4))%Modulus()) < Signed(96) then 1 else 0) == 0 then 1 else 0),18700],Store([],64,128));
    assert Fetch(code,18696) == Op(87,18697,0);
    assert 18700 in Destinations() && code[18700] == 91;
  }
  lemma Advance65(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(65,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(66,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18697,[2972706854,1329,2606,size,4,0,0,0],Store([],64,128));
    assert Fetch(code,18697) == Op(95,18698,0);
  }
  lemma Advance66(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(66,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); Good(67,next,value,size,word,a,b,c)
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18698,[2972706854,1329,2606,size,4,0,0,0,0],Store([],64,128));
    assert Fetch(code,18698) == Op(95,18699,0);
  }
  lemma Advance67(code: seq<Byte>, state: State, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(67,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 160
    ensures var next := Step(code,Destinations(),state,value,size,word,a,b,c); next == Reverted([])
  {
    reveal Good();
    reveal Matches();
    reveal Step();
    assert state == Running(18699,[2972706854,1329,2606,size,4,0,0,0,0,0],Store([],64,128));
    assert Fetch(code,18699) == Op(253,18700,0);
    assert Grow(Store([],64,128),0)[0..0] == [];
  }
  lemma Start(value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    ensures Good(0,Running(0,[],[]),value,size,word,a,b,c)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, value: Word, size: Word, word: Word, a: Word, b: Word, c: Word) returns (state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,c)
    ensures state == Reverted([])
  {
    Start(value,size,word,a,b,c);
    state := Running(0,[],[]);
    Advance0(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance1(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance2(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance3(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance4(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance5(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance6(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance7(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance8(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance9(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance10(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance11(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance12(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance13(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance14(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance15(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance16(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance17(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance18(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance19(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance20(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance21(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance22(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance23(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance24(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance25(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance26(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance27(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance28(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance29(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance30(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance31(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance32(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance33(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance34(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance35(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance36(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance37(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance38(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance39(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance40(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance41(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance42(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance43(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance44(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance45(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance46(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance47(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance48(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance49(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance50(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance51(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance52(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance53(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance54(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance55(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance56(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance57(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance58(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance59(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance60(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance61(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance62(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance63(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance64(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance65(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance66(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance67(code,state,value,size,word,a,b,c);
    state := Step(code,Destinations(),state,value,size,word,a,b,c);
  }
}
