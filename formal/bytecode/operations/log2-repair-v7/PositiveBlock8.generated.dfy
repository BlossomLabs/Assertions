// SPDX-License-Identifier: MIT
// Generated complete exact log2 instruction block. Never edit directly.
include "PositiveState.generated.dfy"
module OperationsBytecodeLog2PositiveBlock8 {
  import opened OperationsBytecodeLog2Machine
  import opened OperationsBytecodeLog2PositiveState
  import K = OperationsBytecodeLog2Kernel
  import F = OperationsBytecodeLog2Math
  import B = OperationsBytecodeLog2BinaryKernel
  lemma Advance160(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(160,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(161,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(2987,[1414971155,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)),1329,0,a],Store([],64,128));
    assert Fetch(code,2987)==Op(80,2988,0);
  }
  lemma Advance161(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(161,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(162,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(2988,[1414971155,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)),1329,0],Store([],64,128));
    assert Fetch(code,2988)==Op(80,2989,0);
  }
  lemma Advance162(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(162,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(163,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(2989,[1414971155,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)),1329],Store([],64,128));
    assert Fetch(code,2989)==Op(86,2990,0);
    assert 1329 in Destinations() && code[1329]==0x5b;
  }
  lemma Advance163(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(163,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(164,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1329,[1414971155,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))],Store([],64,128));
    assert Fetch(code,1329)==Op(91,1330,0);
  }
  lemma Advance164(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(164,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(165,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1330,[1414971155,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))],Store([],64,128));
    assert Immediate(code,1331,1)==64;
    assert Fetch(code,1330)==Op(96,1332,64);
  }
  lemma Advance165(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(165,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(166,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1332,[1414971155,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)),64],Store([],64,128));
    assert Fetch(code,1332)==Op(81,1333,0);
    StoreLoad([],64,128);
  }
  lemma Advance166(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(166,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(167,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1333,[1414971155,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)),128],Store([],64,128));
    assert Fetch(code,1333)==Op(144,1334,0);
  }
  lemma Advance167(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(167,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(168,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1334,[1414971155,128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))],Store([],64,128));
    assert Fetch(code,1334)==Op(129,1335,0);
  }
  lemma Advance168(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(168,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(169,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1335,[1414971155,128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)),128],Store([],64,128));
    assert Fetch(code,1335)==Op(82,1336,0);
    StoreLoad(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)));
  }
  lemma Advance169(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(169,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(170,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1336,[1414971155,128],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))));
    assert Immediate(code,1337,1)==32;
    assert Fetch(code,1336)==Op(96,1338,32);
  }
  lemma Advance170(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(170,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(171,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1338,[1414971155,128,32],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))));
    assert Fetch(code,1338)==Op(1,1339,0);
  }
  lemma Advance171(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(171,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(172,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1339,[1414971155,160],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))));
    assert Immediate(code,1340,1)==5;
    assert Immediate(code,1340,2)==1301;
    assert Fetch(code,1339)==Op(97,1342,1301);
  }
  lemma Advance172(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(172,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(173,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1342,[1414971155,160,1301],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))));
    assert Fetch(code,1342)==Op(86,1343,0);
    assert 1301 in Destinations() && code[1301]==0x5b;
  }
  lemma Advance173(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(173,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(174,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1301,[1414971155,160],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))));
    assert Fetch(code,1301)==Op(91,1302,0);
  }
  lemma Advance174(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(174,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(175,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1302,[1414971155,160],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))));
    assert Immediate(code,1303,1)==64;
    assert Fetch(code,1302)==Op(96,1304,64);
  }
  lemma Advance175(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(175,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(176,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1304,[1414971155,160,64],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))));
    assert Fetch(code,1304)==Op(81,1305,0);
    StoreLoad([],64,128);
    StoreFrame(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)),64);
  }
  lemma Advance176(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(176,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(177,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1305,[1414971155,160,128],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))));
    assert Fetch(code,1305)==Op(128,1306,0);
  }
  lemma Advance177(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(177,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(178,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1306,[1414971155,160,128,128],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))));
    assert Fetch(code,1306)==Op(145,1307,0);
  }
  lemma Advance178(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(178,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(179,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1307,[1414971155,128,128,160],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))));
    assert Fetch(code,1307)==Op(3,1308,0);
  }
  lemma Advance179(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(179,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(180,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1308,[1414971155,128,32],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))));
    assert Fetch(code,1308)==Op(144,1309,0);
  }
  ghost method RunBlock(code: seq<Byte>,initial: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(160,initial,value,size,word,a,b,c)
    ensures Good(180,state,value,size,word,a,b,c)
  {
    state:=initial;
    Advance160(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance161(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance162(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance163(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance164(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance165(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance166(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance167(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance168(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance169(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance170(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance171(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance172(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance173(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance174(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance175(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance176(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance177(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance178(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance179(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
  }
}
