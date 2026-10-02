// SPDX-License-Identifier: MIT
// Generated complete exact log2 instruction block. Never edit directly.
include "PositiveState.generated.dfy"
module OperationsBytecodeLog2PositiveBlock5 {
  import opened OperationsBytecodeLog2Machine
  import opened OperationsBytecodeLog2PositiveState
  import K = OperationsBytecodeLog2Kernel
  import F = OperationsBytecodeLog2Math
  import B = OperationsBytecodeLog2BinaryKernel
  lemma Advance100(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(100,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(101,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11029,[1414971155,1329,a,0,2984,a,K.R128(a),6,1,18446744073709551616],Store([],64,128));
    assert Fetch(code,11029)==Op(3,11030,0);
  }
  lemma Advance101(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(101,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(102,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11030,[1414971155,1329,a,0,2984,a,K.R128(a),6,18446744073709551615],Store([],64,128));
    assert Fetch(code,11030)==Op(131,11031,0);
  }
  lemma Advance102(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(102,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(103,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11031,[1414971155,1329,a,0,2984,a,K.R128(a),6,18446744073709551615,a],Store([],64,128));
    assert Fetch(code,11031)==Op(131,11032,0);
  }
  lemma Advance103(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(103,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(104,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11032,[1414971155,1329,a,0,2984,a,K.R128(a),6,18446744073709551615,a,K.R128(a)],Store([],64,128));
    assert Fetch(code,11032)==Op(28,11033,0);
  }
  lemma Advance104(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(104,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(105,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11033,[1414971155,1329,a,0,2984,a,K.R128(a),6,18446744073709551615,Right(a,K.R128(a))],Store([],64,128));
    assert Fetch(code,11033)==Op(17,11034,0);
  }
  lemma Advance105(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(105,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(106,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11034,[1414971155,1329,a,0,2984,a,K.R128(a),6,K.Bool((Right(a,K.R128(a)))>(18446744073709551615))],Store([],64,128));
    assert Fetch(code,11034)==Op(144,11035,0);
  }
  lemma Advance106(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(106,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(107,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11035,[1414971155,1329,a,0,2984,a,K.R128(a),K.Bool((Right(a,K.R128(a)))>(18446744073709551615)),6],Store([],64,128));
    assert Fetch(code,11035)==Op(27,11036,0);
  }
  lemma Advance107(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(107,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(108,next,value,size,word,a,b,c)
  {
    BeforeOr107(state,value,size,word,a,b,c); reveal Matches();
    assert state==Running(11036,[1414971155,1329,a,0,2984,a,K.R128(a),Shift(K.Bool((Right(a,K.R128(a)))>(18446744073709551615)),6)],Store([],64,128));
    assert Fetch(code,11036)==Op(23,11037,0);
    var prefix: seq<Word>:=[1414971155,1329,a,0,2984,a];
    SymmetricBits(Shift(K.Bool((Right(a,K.R128(a)))>(18446744073709551615)),6),K.R128(a));
    assert BitOr(Shift(K.Bool((Right(a,K.R128(a)))>(18446744073709551615)),6),K.R128(a))==K.R64(a);
    OrStepResult(code,Destinations(),state,11036,11037,prefix,Store([],64,128),Shift(K.Bool((Right(a,K.R128(a)))>(18446744073709551615)),6),K.R128(a),K.R64(a),value,size,word,a,b,c);
    var next:=Step(code,Destinations(),state,value,size,word,a,b,c);
    assert next==Running(11037,prefix+[K.R64(a)],Store([],64,128));
    AfterOr107(next,value,size,word,a,b,c);
  }
  lemma Advance108(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(108,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(109,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11037,[1414971155,1329,a,0,2984,a,K.R64(a)],Store([],64,128));
    assert Immediate(code,11038,1)==5;
    assert Fetch(code,11037)==Op(96,11039,5);
  }
  lemma Advance109(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(109,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(110,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11039,[1414971155,1329,a,0,2984,a,K.R64(a),5],Store([],64,128));
    assert Immediate(code,11040,1)==255;
    assert Immediate(code,11040,2)==65535;
    assert Immediate(code,11040,3)==16777215;
    assert Immediate(code,11040,4)==4294967295;
    assert Fetch(code,11039)==Op(99,11044,4294967295);
  }
  lemma Advance110(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(110,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(111,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11044,[1414971155,1329,a,0,2984,a,K.R64(a),5,4294967295],Store([],64,128));
    assert Fetch(code,11044)==Op(131,11045,0);
  }
  lemma Advance111(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(111,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(112,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11045,[1414971155,1329,a,0,2984,a,K.R64(a),5,4294967295,a],Store([],64,128));
    assert Fetch(code,11045)==Op(131,11046,0);
  }
  lemma Advance112(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(112,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(113,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11046,[1414971155,1329,a,0,2984,a,K.R64(a),5,4294967295,a,K.R64(a)],Store([],64,128));
    assert Fetch(code,11046)==Op(28,11047,0);
  }
  lemma Advance113(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(113,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(114,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11047,[1414971155,1329,a,0,2984,a,K.R64(a),5,4294967295,Right(a,K.R64(a))],Store([],64,128));
    assert Fetch(code,11047)==Op(17,11048,0);
  }
  lemma Advance114(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(114,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(115,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11048,[1414971155,1329,a,0,2984,a,K.R64(a),5,K.Bool((Right(a,K.R64(a)))>(4294967295))],Store([],64,128));
    assert Fetch(code,11048)==Op(144,11049,0);
  }
  lemma Advance115(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(115,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(116,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11049,[1414971155,1329,a,0,2984,a,K.R64(a),K.Bool((Right(a,K.R64(a)))>(4294967295)),5],Store([],64,128));
    assert Fetch(code,11049)==Op(27,11050,0);
  }
  lemma Advance116(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(116,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(117,next,value,size,word,a,b,c)
  {
    BeforeOr116(state,value,size,word,a,b,c); reveal Matches();
    assert state==Running(11050,[1414971155,1329,a,0,2984,a,K.R64(a),Shift(K.Bool((Right(a,K.R64(a)))>(4294967295)),5)],Store([],64,128));
    assert Fetch(code,11050)==Op(23,11051,0);
    var prefix: seq<Word>:=[1414971155,1329,a,0,2984,a];
    SymmetricBits(Shift(K.Bool((Right(a,K.R64(a)))>(4294967295)),5),K.R64(a));
    assert BitOr(Shift(K.Bool((Right(a,K.R64(a)))>(4294967295)),5),K.R64(a))==K.R32(a);
    OrStepResult(code,Destinations(),state,11050,11051,prefix,Store([],64,128),Shift(K.Bool((Right(a,K.R64(a)))>(4294967295)),5),K.R64(a),K.R32(a),value,size,word,a,b,c);
    var next:=Step(code,Destinations(),state,value,size,word,a,b,c);
    assert next==Running(11051,prefix+[K.R32(a)],Store([],64,128));
    AfterOr116(next,value,size,word,a,b,c);
  }
  lemma Advance117(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(117,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(118,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11051,[1414971155,1329,a,0,2984,a,K.R32(a)],Store([],64,128));
    assert Immediate(code,11052,1)==4;
    assert Fetch(code,11051)==Op(96,11053,4);
  }
  lemma Advance118(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(118,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(119,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11053,[1414971155,1329,a,0,2984,a,K.R32(a),4],Store([],64,128));
    assert Immediate(code,11054,1)==255;
    assert Immediate(code,11054,2)==65535;
    assert Fetch(code,11053)==Op(97,11056,65535);
  }
  lemma Advance119(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(119,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(120,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11056,[1414971155,1329,a,0,2984,a,K.R32(a),4,65535],Store([],64,128));
    assert Fetch(code,11056)==Op(131,11057,0);
  }
  ghost method RunBlock(code: seq<Byte>,initial: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(100,initial,value,size,word,a,b,c)
    ensures Good(120,state,value,size,word,a,b,c)
  {
    state:=initial;
    Advance100(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance101(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance102(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance103(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance104(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance105(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance106(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance107(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance108(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance109(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance110(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance111(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance112(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance113(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance114(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance115(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance116(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance117(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance118(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance119(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
  }
}
