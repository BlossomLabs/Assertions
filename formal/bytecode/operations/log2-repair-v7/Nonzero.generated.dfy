// SPDX-License-Identifier: MIT
// Generated exact current log2 executed-byte certificate. Never edit directly.
include "Kernel.dfy"
include "Binary.dfy"
module OperationsBytecodeLog2Nonzero {
  import opened OperationsBytecodeLog2Machine
  import K = OperationsBytecodeLog2Kernel
  import F = OperationsBytecodeLog2Math
  import B = OperationsBytecodeLog2BinaryKernel
  function Result(a: Word): Word { F.Log(a)%Modulus() }
  predicate Admitted(value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) { value!=0 }
  opaque predicate Matches(code: seq<Byte>) { |code|==21346 &&
                                              code[0]==96 &&
                                              code[1]==128 &&
                                              code[2]==96 &&
                                              code[3]==64 &&
                                              code[4]==82 &&
                                              code[5]==52 &&
                                              code[6]==128 &&
                                              code[7]==21 &&
                                              code[8]==97 &&
                                              code[9]==0 &&
                                              code[10]==15 &&
                                              code[11]==87 &&
                                              code[12]==95 &&
                                              code[13]==95 &&
                                              code[14]==253 &&
                                              code[15]==91
  }
  function Destinations(): set<nat> { {15} }
  opaque predicate Good(id: nat,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) {
    if id==0 then state==Running(0,[],[])
    else if id==1 then state==Running(2,[128],[])
    else if id==2 then state==Running(4,[128,64],[])
    else if id==3 then state==Running(5,[],Store([],64,128))
    else if id==4 then state==Running(6,[value],Store([],64,128))
    else if id==5 then state==Running(7,[value,value],Store([],64,128))
    else if id==6 then state==Running(8,[value,K.Bool((value)==0)],Store([],64,128))
    else if id==7 then state==Running(11,[value,K.Bool((value)==0),15],Store([],64,128))
    else if id==8 then state==Running(12,[value],Store([],64,128))
    else if id==9 then state==Running(13,[value,0],Store([],64,128))
    else if id==10 then state==Running(14,[value,0,0],Store([],64,128))
    else false
  }
  lemma Advance0(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(0,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=3 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(1,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(0,[],[]);
    assert Immediate(code,1,1)==128;
    assert Fetch(code,0)==Op(96,2,128);
  }
  lemma Advance1(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(1,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=3 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(2,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(2,[128],[]);
    assert Immediate(code,3,1)==64;
    assert Fetch(code,2)==Op(96,4,64);
  }
  lemma Advance2(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(2,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=3 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(3,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(4,[128,64],[]);
    assert Fetch(code,4)==Op(82,5,0);
    StoreLoad([],64,128);
  }
  lemma Advance3(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(3,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=3 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(4,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(5,[],Store([],64,128));
    assert Fetch(code,5)==Op(52,6,0);
  }
  lemma Advance4(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(4,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=3 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(5,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(6,[value],Store([],64,128));
    assert Fetch(code,6)==Op(128,7,0);
  }
  lemma Advance5(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(5,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=3 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(6,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(7,[value,value],Store([],64,128));
    assert Fetch(code,7)==Op(21,8,0);
  }
  lemma Advance6(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(6,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=3 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(7,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(8,[value,K.Bool((value)==0)],Store([],64,128));
    assert Immediate(code,9,1)==0;
    assert Immediate(code,9,2)==15;
    assert Fetch(code,8)==Op(97,11,15);
  }
  lemma Advance7(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(7,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=3 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(8,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(11,[value,K.Bool((value)==0),15],Store([],64,128));
    assert Fetch(code,11)==Op(87,12,0);
    assert 15 in Destinations() && code[15]==0x5b;
  }
  lemma Advance8(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(8,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=3 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(9,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(12,[value],Store([],64,128));
    assert Fetch(code,12)==Op(95,13,0);
  }
  lemma Advance9(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(9,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=3 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); Good(10,next,value,size,word,a,b,c)
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(13,[value,0],Store([],64,128));
    assert Fetch(code,13)==Op(95,14,0);
  }
  lemma Advance10(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(10,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=3 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); next==Reverted([])
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(14,[value,0,0],Store([],64,128));
    assert Fetch(code,14)==Op(253,15,0);
  }
  ghost method Run(code: seq<Byte>,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,c)
    ensures state==Reverted([])
  {
    reveal Good(); state:=Running(0,[],[]); assert Good(0,state,value,size,word,a,b,c);
    Advance0(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance1(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance2(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance3(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance4(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance5(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance6(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance7(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance8(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance9(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
    Advance10(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
  }
}
