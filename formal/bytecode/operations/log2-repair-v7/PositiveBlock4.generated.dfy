// SPDX-License-Identifier: MIT
// Generated complete exact log2 instruction block. Never edit directly.
include "PositiveState.generated.dfy"
module OperationsBytecodeLog2PositiveBlock4 {
  import opened OperationsBytecodeLog2Machine
  import opened OperationsBytecodeLog2PositiveState
  import K = OperationsBytecodeLog2Kernel
  import F = OperationsBytecodeLog2Math
  import B = OperationsBytecodeLog2BinaryKernel
  lemma Advance80(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(80,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(81,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4688,[1414971155,1329,a,0],Store([],64,128));
    assert Fetch(code,4688)==Op(91,4689,0);
  }
  lemma Advance81(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(81,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(82,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4689,[1414971155,1329,a,0],Store([],64,128));
    assert Immediate(code,4690,1)==11;
    assert Immediate(code,4690,2)==2984;
    assert Fetch(code,4689)==Op(97,4692,2984);
  }
  lemma Advance82(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(82,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(83,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4692,[1414971155,1329,a,0,2984],Store([],64,128));
    assert Fetch(code,4692)==Op(130,4693,0);
  }
  lemma Advance83(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(83,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(84,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4693,[1414971155,1329,a,0,2984,a],Store([],64,128));
    assert Immediate(code,4694,1)==42;
    assert Immediate(code,4694,2)==10993;
    assert Fetch(code,4693)==Op(97,4696,10993);
  }
  lemma Advance84(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(84,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(85,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4696,[1414971155,1329,a,0,2984,a,10993],Store([],64,128));
    assert Fetch(code,4696)==Op(86,4697,0);
    assert 10993 in Destinations() && code[10993]==0x5b;
  }
  lemma Advance85(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(85,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(86,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(10993,[1414971155,1329,a,0,2984,a],Store([],64,128));
    assert Fetch(code,10993)==Op(91,10994,0);
  }
  lemma Advance86(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(86,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(87,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(10994,[1414971155,1329,a,0,2984,a],Store([],64,128));
    assert Fetch(code,10994)==Op(95,10995,0);
  }
  lemma Advance87(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(87,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(88,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(10995,[1414971155,1329,a,0,2984,a,0],Store([],64,128));
    assert Immediate(code,10996,1)==7;
    assert Fetch(code,10995)==Op(96,10997,7);
  }
  lemma Advance88(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(88,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(89,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(10997,[1414971155,1329,a,0,2984,a,0,7],Store([],64,128));
    assert Immediate(code,10998,1)==255;
    assert Immediate(code,10998,2)==65535;
    assert Immediate(code,10998,3)==16777215;
    assert Immediate(code,10998,4)==4294967295;
    assert Immediate(code,10998,5)==1099511627775;
    assert Immediate(code,10998,6)==281474976710655;
    assert Immediate(code,10998,7)==72057594037927935;
    assert Immediate(code,10998,8)==18446744073709551615;
    assert Immediate(code,10998,9)==4722366482869645213695;
    assert Immediate(code,10998,10)==1208925819614629174706175;
    assert Immediate(code,10998,11)==309485009821345068724781055;
    assert Immediate(code,10998,12)==79228162514264337593543950335;
    assert Immediate(code,10998,13)==20282409603651670423947251286015;
    assert Immediate(code,10998,14)==5192296858534827628530496329220095;
    assert Immediate(code,10998,15)==1329227995784915872903807060280344575;
    assert Immediate(code,10998,16)==340282366920938463463374607431768211455;
    assert Fetch(code,10997)==Op(111,11014,340282366920938463463374607431768211455);
  }
  lemma Advance89(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(89,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(90,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11014,[1414971155,1329,a,0,2984,a,0,7,340282366920938463463374607431768211455],Store([],64,128));
    assert Fetch(code,11014)==Op(131,11015,0);
  }
  lemma Advance90(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(90,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(91,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11015,[1414971155,1329,a,0,2984,a,0,7,340282366920938463463374607431768211455,a],Store([],64,128));
    assert Fetch(code,11015)==Op(17,11016,0);
  }
  lemma Advance91(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(91,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(92,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11016,[1414971155,1329,a,0,2984,a,0,7,K.Bool((a)>(340282366920938463463374607431768211455))],Store([],64,128));
    assert Fetch(code,11016)==Op(144,11017,0);
  }
  lemma Advance92(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(92,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(93,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11017,[1414971155,1329,a,0,2984,a,0,K.Bool((a)>(340282366920938463463374607431768211455)),7],Store([],64,128));
    assert Fetch(code,11017)==Op(27,11018,0);
    K.InitialOpcode(a);
  }
  lemma Advance93(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(93,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(94,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11018,[1414971155,1329,a,0,2984,a,0,K.R128(a)],Store([],64,128));
    assert Fetch(code,11018)==Op(144,11019,0);
  }
  lemma Advance94(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(94,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(95,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11019,[1414971155,1329,a,0,2984,a,K.R128(a),0],Store([],64,128));
    assert Fetch(code,11019)==Op(80,11020,0);
  }
  lemma Advance95(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(95,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(96,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11020,[1414971155,1329,a,0,2984,a,K.R128(a)],Store([],64,128));
    assert Immediate(code,11021,1)==6;
    assert Fetch(code,11020)==Op(96,11022,6);
  }
  lemma Advance96(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(96,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(97,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11022,[1414971155,1329,a,0,2984,a,K.R128(a),6],Store([],64,128));
    assert Immediate(code,11023,1)==1;
    assert Fetch(code,11022)==Op(96,11024,1);
  }
  lemma Advance97(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(97,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(98,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11024,[1414971155,1329,a,0,2984,a,K.R128(a),6,1],Store([],64,128));
    assert Immediate(code,11025,1)==1;
    assert Fetch(code,11024)==Op(96,11026,1);
  }
  lemma Advance98(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(98,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(99,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11026,[1414971155,1329,a,0,2984,a,K.R128(a),6,1,1],Store([],64,128));
    assert Immediate(code,11027,1)==64;
    assert Fetch(code,11026)==Op(96,11028,64);
  }
  lemma Advance99(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(99,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(100,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11028,[1414971155,1329,a,0,2984,a,K.R128(a),6,1,1,64],Store([],64,128));
    assert Fetch(code,11028)==Op(27,11029,0);
    K.FixedShift(1,64,18446744073709551616);
  }
  ghost method RunBlock(code: seq<Byte>,initial: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(80,initial,value,size,word,a,b,c)
    ensures Good(100,state,value,size,word,a,b,c)
  {
    state:=initial;
    Advance80(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance81(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance82(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance83(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance84(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance85(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance86(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance87(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance88(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance89(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance90(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance91(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance92(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance93(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance94(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance95(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance96(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance97(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance98(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance99(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
  }
}
