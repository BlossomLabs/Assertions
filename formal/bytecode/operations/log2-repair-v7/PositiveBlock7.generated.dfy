// SPDX-License-Identifier: MIT
// Generated complete exact log2 instruction block. Never edit directly.
include "PositiveState.generated.dfy"
module OperationsBytecodeLog2PositiveBlock7 {
  import opened OperationsBytecodeLog2Machine
  import opened OperationsBytecodeLog2PositiveState
  import K = OperationsBytecodeLog2Kernel
  import F = OperationsBytecodeLog2Math
  import B = OperationsBytecodeLog2BinaryKernel
  lemma Advance140(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(140,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(141,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11081,[1414971155,1329,a,0,2984,a,K.R8(a),2,15,Right(a,K.R8(a))],Store([],64,128));
    assert Fetch(code,11081)==Op(17,11082,0);
  }
  lemma Advance141(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(141,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(142,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11082,[1414971155,1329,a,0,2984,a,K.R8(a),2,K.Bool((Right(a,K.R8(a)))>(15))],Store([],64,128));
    assert Immediate(code,11083,1)==1;
    assert Immediate(code,11083,2)==257;
    assert Immediate(code,11083,3)==65794;
    assert Immediate(code,11083,4)==16843266;
    assert Immediate(code,11083,5)==4311876098;
    assert Immediate(code,11083,6)==1103840281090;
    assert Immediate(code,11083,7)==282583111959043;
    assert Immediate(code,11083,8)==72341276661515011;
    assert Immediate(code,11083,9)==18519366825347842819;
    assert Immediate(code,11083,10)==4740957907289047761667;
    assert Immediate(code,11083,11)==1213685224265996226986755;
    assert Immediate(code,11083,12)==310703417412095034108609283;
    assert Immediate(code,11083,13)==79540074857496328731803976451;
    assert Immediate(code,11083,14)==20362259163519060155341817971459;
    assert Fetch(code,11082)==Op(109,11097,20362259163519060155341817971459);
  }
  lemma Advance142(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(142,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(143,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11097,[1414971155,1329,a,0,2984,a,K.R8(a),2,K.Bool((Right(a,K.R8(a)))>(15)),20362259163519060155341817971459],Store([],64,128));
    assert Immediate(code,11098,1)==128;
    assert Fetch(code,11097)==Op(96,11099,128);
  }
  lemma Advance143(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(143,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(144,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11099,[1414971155,1329,a,0,2984,a,K.R8(a),2,K.Bool((Right(a,K.R8(a)))>(15)),20362259163519060155341817971459,128],Store([],64,128));
    assert Fetch(code,11099)==Op(27,11100,0);
    K.FixedShift(20362259163519060155341817971459,128,6928917744019834342450304135053993530982274426945361611473370484834304);
  }
  lemma Advance144(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(144,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(145,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11100,[1414971155,1329,a,0,2984,a,K.R8(a),2,K.Bool((Right(a,K.R8(a)))>(15)),6928917744019834342450304135053993530982274426945361611473370484834304],Store([],64,128));
    assert Fetch(code,11100)==Op(145,11101,0);
  }
  lemma Advance145(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(145,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(146,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11101,[1414971155,1329,a,0,2984,a,K.R8(a),6928917744019834342450304135053993530982274426945361611473370484834304,K.Bool((Right(a,K.R8(a)))>(15)),2],Store([],64,128));
    assert Fetch(code,11101)==Op(27,11102,0);
  }
  lemma Advance146(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(146,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(147,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11102,[1414971155,1329,a,0,2984,a,K.R8(a),6928917744019834342450304135053993530982274426945361611473370484834304,Shift(K.Bool((Right(a,K.R8(a)))>(15)),2)],Store([],64,128));
    assert Fetch(code,11102)==Op(145,11103,0);
  }
  lemma Advance147(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(147,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(148,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11103,[1414971155,1329,a,0,2984,a,Shift(K.Bool((Right(a,K.R8(a)))>(15)),2),6928917744019834342450304135053993530982274426945361611473370484834304,K.R8(a)],Store([],64,128));
    assert Fetch(code,11103)==Op(144,11104,0);
  }
  lemma Advance148(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(148,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(149,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11104,[1414971155,1329,a,0,2984,a,Shift(K.Bool((Right(a,K.R8(a)))>(15)),2),K.R8(a),6928917744019834342450304135053993530982274426945361611473370484834304],Store([],64,128));
    assert Fetch(code,11104)==Op(145,11105,0);
  }
  lemma Advance149(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(149,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(150,next,value,size,word,a,b,c)
  {
    BeforeOr149(state,value,size,word,a,b,c); reveal Matches();
    assert state==Running(11105,[1414971155,1329,a,0,2984,a,6928917744019834342450304135053993530982274426945361611473370484834304,K.R8(a),Shift(K.Bool((Right(a,K.R8(a)))>(15)),2)],Store([],64,128));
    assert Fetch(code,11105)==Op(23,11106,0);
    var prefix: seq<Word>:=[1414971155,1329,a,0,2984,a,6928917744019834342450304135053993530982274426945361611473370484834304];
    SymmetricBits(Shift(K.Bool((Right(a,K.R8(a)))>(15)),2),K.R8(a));
    assert BitOr(Shift(K.Bool((Right(a,K.R8(a)))>(15)),2),K.R8(a))==K.R4(a);
    OrStepResult(code,Destinations(),state,11105,11106,prefix,Store([],64,128),Shift(K.Bool((Right(a,K.R8(a)))>(15)),2),K.R8(a),K.R4(a),value,size,word,a,b,c);
    var next:=Step(code,Destinations(),state,value,size,word,a,b,c);
    assert next==Running(11106,prefix+[K.R4(a)],Store([],64,128));
    AfterOr149(next,value,size,word,a,b,c);
  }
  lemma Advance150(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(150,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(151,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11106,[1414971155,1329,a,0,2984,a,6928917744019834342450304135053993530982274426945361611473370484834304,K.R4(a)],Store([],64,128));
    assert Fetch(code,11106)==Op(145,11107,0);
  }
  lemma Advance151(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(151,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(152,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11107,[1414971155,1329,a,0,2984,K.R4(a),6928917744019834342450304135053993530982274426945361611473370484834304,a],Store([],64,128));
    assert Fetch(code,11107)==Op(130,11108,0);
  }
  lemma Advance152(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(152,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(153,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11108,[1414971155,1329,a,0,2984,K.R4(a),6928917744019834342450304135053993530982274426945361611473370484834304,a,K.R4(a)],Store([],64,128));
    assert Fetch(code,11108)==Op(28,11109,0);
  }
  lemma Advance153(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(153,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(154,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11109,[1414971155,1329,a,0,2984,K.R4(a),6928917744019834342450304135053993530982274426945361611473370484834304,Right(a,K.R4(a))],Store([],64,128));
    assert Fetch(code,11109)==Op(26,11110,0);
  }
  lemma Advance154(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(154,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(155,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11110,[1414971155,1329,a,0,2984,K.R4(a),ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304)],Store([],64,128));
    assert Fetch(code,11110)==Op(23,11111,0);
  }
  lemma Advance155(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(155,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(156,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11111,[1414971155,1329,a,0,2984,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))],Store([],64,128));
    assert Fetch(code,11111)==Op(144,11112,0);
  }
  lemma Advance156(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(156,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(157,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11112,[1414971155,1329,a,0,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)),2984],Store([],64,128));
    assert Fetch(code,11112)==Op(86,11113,0);
    assert 2984 in Destinations() && code[2984]==0x5b;
  }
  lemma Advance157(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(157,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(158,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(2984,[1414971155,1329,a,0,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))],Store([],64,128));
    assert Fetch(code,2984)==Op(91,2985,0);
  }
  lemma Advance158(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(158,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(159,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(2985,[1414971155,1329,a,0,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))],Store([],64,128));
    assert Fetch(code,2985)==Op(146,2986,0);
  }
  lemma Advance159(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(159,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(160,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(2986,[1414971155,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a)),a,0,1329],Store([],64,128));
    assert Fetch(code,2986)==Op(145,2987,0);
  }
  ghost method RunBlock(code: seq<Byte>,initial: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(140,initial,value,size,word,a,b,c)
    ensures Good(160,state,value,size,word,a,b,c)
  {
    state:=initial;
    Advance140(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance141(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance142(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance143(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance144(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance145(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance146(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance147(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance148(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance149(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance150(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance151(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance152(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance153(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance154(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance155(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance156(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance157(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance158(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance159(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
  }
}
