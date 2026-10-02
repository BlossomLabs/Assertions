// SPDX-License-Identifier: MIT
// Generated complete exact log2 instruction block. Never edit directly.
include "PositiveState.generated.dfy"
module OperationsBytecodeLog2PositiveBlock1 {
  import opened OperationsBytecodeLog2Machine
  import opened OperationsBytecodeLog2PositiveState
  import K = OperationsBytecodeLog2Kernel
  import F = OperationsBytecodeLog2Math
  import B = OperationsBytecodeLog2BinaryKernel
  lemma Advance20(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(20,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(21,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(31,[1414971155,1414971155],Store([],64,128));
    assert Immediate(code,32,1)==129;
    assert Immediate(code,32,2)==33278;
    assert Immediate(code,32,3)==8519255;
    assert Immediate(code,32,4)==2180929414;
    assert Fetch(code,31)==Op(99,36,2180929414);
  }
  lemma Advance21(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(21,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(22,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(36,[1414971155,1414971155,2180929414],Store([],64,128));
    assert Fetch(code,36)==Op(17,37,0);
  }
  lemma Advance22(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(22,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(23,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(37,[1414971155,1],Store([],64,128));
    assert Immediate(code,38,1)==2;
    assert Immediate(code,38,2)==655;
    assert Fetch(code,37)==Op(97,40,655);
  }
  lemma Advance23(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(23,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(24,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(40,[1414971155,1,655],Store([],64,128));
    assert Fetch(code,40)==Op(87,41,0);
    assert 655 in Destinations() && code[655]==0x5b;
  }
  lemma Advance24(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(24,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(25,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(655,[1414971155],Store([],64,128));
    assert Fetch(code,655)==Op(91,656,0);
  }
  lemma Advance25(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(25,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(26,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(656,[1414971155],Store([],64,128));
    assert Fetch(code,656)==Op(128,657,0);
  }
  lemma Advance26(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(26,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(27,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(657,[1414971155,1414971155],Store([],64,128));
    assert Immediate(code,658,1)==64;
    assert Immediate(code,658,2)==16513;
    assert Immediate(code,658,3)==4227439;
    assert Immediate(code,658,4)==1082224558;
    assert Fetch(code,657)==Op(99,662,1082224558);
  }
  lemma Advance27(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(27,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(28,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(662,[1414971155,1414971155,1082224558],Store([],64,128));
    assert Fetch(code,662)==Op(17,663,0);
  }
  lemma Advance28(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(28,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(29,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(663,[1414971155,0],Store([],64,128));
    assert Immediate(code,664,1)==3;
    assert Immediate(code,664,2)==968;
    assert Fetch(code,663)==Op(97,666,968);
  }
  lemma Advance29(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(29,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(30,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(666,[1414971155,0,968],Store([],64,128));
    assert Fetch(code,666)==Op(87,667,0);
    assert 968 in Destinations() && code[968]==0x5b;
  }
  lemma Advance30(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(30,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(31,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(667,[1414971155],Store([],64,128));
    assert Fetch(code,667)==Op(128,668,0);
  }
  lemma Advance31(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(31,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(32,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(668,[1414971155,1414971155],Store([],64,128));
    assert Immediate(code,669,1)==101;
    assert Immediate(code,669,2)==25938;
    assert Immediate(code,669,3)==6640369;
    assert Immediate(code,669,4)==1699934599;
    assert Fetch(code,668)==Op(99,673,1699934599);
  }
  lemma Advance32(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(32,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(33,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(673,[1414971155,1414971155,1699934599],Store([],64,128));
    assert Fetch(code,673)==Op(17,674,0);
  }
  lemma Advance33(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(33,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(34,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(674,[1414971155,1],Store([],64,128));
    assert Immediate(code,675,1)==3;
    assert Immediate(code,675,2)==828;
    assert Fetch(code,674)==Op(97,677,828);
  }
  lemma Advance34(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(34,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(35,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(677,[1414971155,1,828],Store([],64,128));
    assert Fetch(code,677)==Op(87,678,0);
    assert 828 in Destinations() && code[828]==0x5b;
  }
  lemma Advance35(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(35,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(36,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(828,[1414971155],Store([],64,128));
    assert Fetch(code,828)==Op(91,829,0);
  }
  lemma Advance36(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(36,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(37,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(829,[1414971155],Store([],64,128));
    assert Fetch(code,829)==Op(128,830,0);
  }
  lemma Advance37(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(37,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(38,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(830,[1414971155,1414971155],Store([],64,128));
    assert Immediate(code,831,1)==84;
    assert Immediate(code,831,2)==21590;
    assert Immediate(code,831,3)==5527231;
    assert Immediate(code,831,4)==1414971155;
    assert Fetch(code,830)==Op(99,835,1414971155);
  }
  lemma Advance38(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(38,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(39,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(835,[1414971155,1414971155,1414971155],Store([],64,128));
    assert Fetch(code,835)==Op(17,836,0);
  }
  lemma Advance39(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(39,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(40,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(836,[1414971155,0],Store([],64,128));
    assert Immediate(code,837,1)==3;
    assert Immediate(code,837,2)==909;
    assert Fetch(code,836)==Op(97,839,909);
  }
  ghost method RunBlock(code: seq<Byte>,initial: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(20,initial,value,size,word,a,b,c)
    ensures Good(40,state,value,size,word,a,b,c)
  {
    state:=initial;
    Advance20(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance21(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance22(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance23(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance24(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance25(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance26(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance27(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance28(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance29(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance30(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance31(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance32(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance33(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance34(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance35(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance36(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance37(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance38(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance39(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
  }
}
