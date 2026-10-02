// SPDX-License-Identifier: MIT
// Generated complete exact log2 instruction block. Never edit directly.
include "PositiveState.generated.dfy"
module OperationsBytecodeLog2PositiveBlock6 {
  import opened OperationsBytecodeLog2Machine
  import opened OperationsBytecodeLog2PositiveState
  import K = OperationsBytecodeLog2Kernel
  import F = OperationsBytecodeLog2Math
  import B = OperationsBytecodeLog2BinaryKernel
  lemma Advance120(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(120,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(121,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11057,[1414971155,1329,a,0,2984,a,K.R32(a),4,65535,a],Store([],64,128));
    assert Fetch(code,11057)==Op(131,11058,0);
  }
  lemma Advance121(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(121,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(122,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11058,[1414971155,1329,a,0,2984,a,K.R32(a),4,65535,a,K.R32(a)],Store([],64,128));
    assert Fetch(code,11058)==Op(28,11059,0);
  }
  lemma Advance122(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(122,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(123,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11059,[1414971155,1329,a,0,2984,a,K.R32(a),4,65535,Right(a,K.R32(a))],Store([],64,128));
    assert Fetch(code,11059)==Op(17,11060,0);
  }
  lemma Advance123(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(123,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(124,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11060,[1414971155,1329,a,0,2984,a,K.R32(a),4,K.Bool((Right(a,K.R32(a)))>(65535))],Store([],64,128));
    assert Fetch(code,11060)==Op(144,11061,0);
  }
  lemma Advance124(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(124,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(125,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11061,[1414971155,1329,a,0,2984,a,K.R32(a),K.Bool((Right(a,K.R32(a)))>(65535)),4],Store([],64,128));
    assert Fetch(code,11061)==Op(27,11062,0);
  }
  lemma Advance125(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(125,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(126,next,value,size,word,a,b,c)
  {
    BeforeOr125(state,value,size,word,a,b,c); reveal Matches();
    assert state==Running(11062,[1414971155,1329,a,0,2984,a,K.R32(a),Shift(K.Bool((Right(a,K.R32(a)))>(65535)),4)],Store([],64,128));
    assert Fetch(code,11062)==Op(23,11063,0);
    var prefix: seq<Word>:=[1414971155,1329,a,0,2984,a];
    SymmetricBits(Shift(K.Bool((Right(a,K.R32(a)))>(65535)),4),K.R32(a));
    assert BitOr(Shift(K.Bool((Right(a,K.R32(a)))>(65535)),4),K.R32(a))==K.R16(a);
    OrStepResult(code,Destinations(),state,11062,11063,prefix,Store([],64,128),Shift(K.Bool((Right(a,K.R32(a)))>(65535)),4),K.R32(a),K.R16(a),value,size,word,a,b,c);
    var next:=Step(code,Destinations(),state,value,size,word,a,b,c);
    assert next==Running(11063,prefix+[K.R16(a)],Store([],64,128));
    AfterOr125(next,value,size,word,a,b,c);
  }
  lemma Advance126(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(126,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(127,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11063,[1414971155,1329,a,0,2984,a,K.R16(a)],Store([],64,128));
    assert Immediate(code,11064,1)==3;
    assert Fetch(code,11063)==Op(96,11065,3);
  }
  lemma Advance127(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(127,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(128,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11065,[1414971155,1329,a,0,2984,a,K.R16(a),3],Store([],64,128));
    assert Immediate(code,11066,1)==255;
    assert Fetch(code,11065)==Op(96,11067,255);
  }
  lemma Advance128(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(128,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(129,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11067,[1414971155,1329,a,0,2984,a,K.R16(a),3,255],Store([],64,128));
    assert Fetch(code,11067)==Op(131,11068,0);
  }
  lemma Advance129(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(129,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(130,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11068,[1414971155,1329,a,0,2984,a,K.R16(a),3,255,a],Store([],64,128));
    assert Fetch(code,11068)==Op(131,11069,0);
  }
  lemma Advance130(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(130,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(131,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11069,[1414971155,1329,a,0,2984,a,K.R16(a),3,255,a,K.R16(a)],Store([],64,128));
    assert Fetch(code,11069)==Op(28,11070,0);
  }
  lemma Advance131(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(131,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(132,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11070,[1414971155,1329,a,0,2984,a,K.R16(a),3,255,Right(a,K.R16(a))],Store([],64,128));
    assert Fetch(code,11070)==Op(17,11071,0);
  }
  lemma Advance132(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(132,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(133,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11071,[1414971155,1329,a,0,2984,a,K.R16(a),3,K.Bool((Right(a,K.R16(a)))>(255))],Store([],64,128));
    assert Fetch(code,11071)==Op(144,11072,0);
  }
  lemma Advance133(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(133,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(134,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11072,[1414971155,1329,a,0,2984,a,K.R16(a),K.Bool((Right(a,K.R16(a)))>(255)),3],Store([],64,128));
    assert Fetch(code,11072)==Op(27,11073,0);
  }
  lemma Advance134(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(134,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(135,next,value,size,word,a,b,c)
  {
    BeforeOr134(state,value,size,word,a,b,c); reveal Matches();
    assert state==Running(11073,[1414971155,1329,a,0,2984,a,K.R16(a),Shift(K.Bool((Right(a,K.R16(a)))>(255)),3)],Store([],64,128));
    assert Fetch(code,11073)==Op(23,11074,0);
    var prefix: seq<Word>:=[1414971155,1329,a,0,2984,a];
    SymmetricBits(Shift(K.Bool((Right(a,K.R16(a)))>(255)),3),K.R16(a));
    assert BitOr(Shift(K.Bool((Right(a,K.R16(a)))>(255)),3),K.R16(a))==K.R8(a);
    OrStepResult(code,Destinations(),state,11073,11074,prefix,Store([],64,128),Shift(K.Bool((Right(a,K.R16(a)))>(255)),3),K.R16(a),K.R8(a),value,size,word,a,b,c);
    var next:=Step(code,Destinations(),state,value,size,word,a,b,c);
    assert next==Running(11074,prefix+[K.R8(a)],Store([],64,128));
    AfterOr134(next,value,size,word,a,b,c);
  }
  lemma Advance135(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(135,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(136,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11074,[1414971155,1329,a,0,2984,a,K.R8(a)],Store([],64,128));
    assert Immediate(code,11075,1)==2;
    assert Fetch(code,11074)==Op(96,11076,2);
  }
  lemma Advance136(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(136,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(137,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11076,[1414971155,1329,a,0,2984,a,K.R8(a),2],Store([],64,128));
    assert Immediate(code,11077,1)==15;
    assert Fetch(code,11076)==Op(96,11078,15);
  }
  lemma Advance137(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(137,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(138,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11078,[1414971155,1329,a,0,2984,a,K.R8(a),2,15],Store([],64,128));
    assert Fetch(code,11078)==Op(131,11079,0);
  }
  lemma Advance138(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(138,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(139,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11079,[1414971155,1329,a,0,2984,a,K.R8(a),2,15,a],Store([],64,128));
    assert Fetch(code,11079)==Op(131,11080,0);
  }
  lemma Advance139(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(139,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(140,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11080,[1414971155,1329,a,0,2984,a,K.R8(a),2,15,a,K.R8(a)],Store([],64,128));
    assert Fetch(code,11080)==Op(28,11081,0);
  }
  ghost method RunBlock(code: seq<Byte>,initial: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(120,initial,value,size,word,a,b,c)
    ensures Good(140,state,value,size,word,a,b,c)
  {
    state:=initial;
    Advance120(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance121(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance122(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance123(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance124(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance125(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance126(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance127(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance128(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance129(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance130(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance131(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance132(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance133(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance134(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance135(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance136(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance137(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance138(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance139(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
  }
}
