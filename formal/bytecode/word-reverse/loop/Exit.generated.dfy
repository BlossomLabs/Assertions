// SPDX-License-Identifier: MIT
// Generated pinned reverseWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeReverseSegmentExit {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeReverseLoopScalar
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  function Target(length: Word, index: Word): Word { (if index < length/32 then 160+(length/32-1-index)*32 else 160)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, index: Word, word: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && index <= length/32 && index == length/32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[518] == 91 &&
                                              code[2914] == 91 &&
                                              code[2915] == 80 &&
                                              code[2916] == 80 &&
                                              code[2917] == 146 &&
                                              code[2918] == 145 &&
                                              code[2919] == 80 &&
                                              code[2920] == 80 &&
                                              code[2921] == 86 &&
                                              code[5846] == 91 &&
                                              code[5847] == 129 &&
                                              code[5848] == 129 &&
                                              code[5849] == 16 &&
                                              code[5850] == 21 &&
                                              code[5851] == 97 &&
                                              code[5852] == 11 &&
                                              code[5853] == 98 &&
                                              code[5854] == 87
  }
  function Destinations(): set<nat> { {518,2914} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,index,word) && (
                                                                                                                        if id == 0 then state == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem)
                                                                                                                        else if id == 1 then state == Running(5847,[2874738232,518,offset,length,128,length/32,index],mem)
                                                                                                                        else if id == 2 then state == Running(5848,[2874738232,518,offset,length,128,length/32,index,length/32],mem)
                                                                                                                        else if id == 3 then state == Running(5849,[2874738232,518,offset,length,128,length/32,index,length/32,index],mem)
                                                                                                                        else if id == 4 then state == Running(5850,[2874738232,518,offset,length,128,length/32,index,0],mem)
                                                                                                                        else if id == 5 then state == Running(5851,[2874738232,518,offset,length,128,length/32,index,1],mem)
                                                                                                                        else if id == 6 then state == Running(5854,[2874738232,518,offset,length,128,length/32,index,1,2914],mem)
                                                                                                                        else if id == 7 then state == Running(2914,[2874738232,518,offset,length,128,length/32,index],mem)
                                                                                                                        else if id == 8 then state == Running(2915,[2874738232,518,offset,length,128,length/32,index],mem)
                                                                                                                        else if id == 9 then state == Running(2916,[2874738232,518,offset,length,128,length/32],mem)
                                                                                                                        else if id == 10 then state == Running(2917,[2874738232,518,offset,length,128],mem)
                                                                                                                        else if id == 11 then state == Running(2918,[2874738232,128,offset,length,518],mem)
                                                                                                                        else if id == 12 then state == Running(2919,[2874738232,128,518,length,offset],mem)
                                                                                                                        else if id == 13 then state == Running(2920,[2874738232,128,518,length],mem)
                                                                                                                        else if id == 14 then state == Running(2921,[2874738232,128,518],mem)
                                                                                                                        else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(0,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem);
    assert Fetch(code,5846) == Op(91,5847,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(1,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5847,[2874738232,518,offset,length,128,length/32,index],mem);
    assert Fetch(code,5847) == Op(129,5848,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(2,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5848,[2874738232,518,offset,length,128,length/32,index,length/32],mem);
    assert Fetch(code,5848) == Op(129,5849,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(3,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5849,[2874738232,518,offset,length,128,length/32,index,length/32,index],mem);
    assert Fetch(code,5849) == Op(16,5850,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(4,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5850,[2874738232,518,offset,length,128,length/32,index,0],mem);
    assert Fetch(code,5850) == Op(21,5851,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(5,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5851,[2874738232,518,offset,length,128,length/32,index,1],mem);
    F.Push2(code,5851);
    assert Fetch(code,5851) == Op(97,5854,2914);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(6,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5854,[2874738232,518,offset,length,128,length/32,index,1,2914],mem);
    assert Fetch(code,5854) == Op(87,5855,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(7,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2914,[2874738232,518,offset,length,128,length/32,index],mem);
    assert Fetch(code,2914) == Op(91,2915,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(8,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2915,[2874738232,518,offset,length,128,length/32,index],mem);
    assert Fetch(code,2915) == Op(80,2916,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(9,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2916,[2874738232,518,offset,length,128,length/32],mem);
    assert Fetch(code,2916) == Op(80,2917,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(10,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2917,[2874738232,518,offset,length,128],mem);
    assert Fetch(code,2917) == Op(146,2918,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(11,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2918,[2874738232,128,offset,length,518],mem);
    assert Fetch(code,2918) == Op(145,2919,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(12,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2919,[2874738232,128,518,length,offset],mem);
    assert Fetch(code,2919) == Op(80,2920,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(13,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2920,[2874738232,128,518,length],mem);
    assert Fetch(code,2920) == Op(80,2921,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(14,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(518,[2874738232,128],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2921,[2874738232,128,518],mem);
    assert Fetch(code,2921) == Op(86,2922,0);
  }
  lemma Start(offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,index,word)
    ensures Good(0,Running(5846,[2874738232,518,offset,length,128,length/32,index],mem),offset,length,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,index,word)
    ensures state == Running(518,[2874738232,128],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 16 && trace[0] == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,index,word,mem);
    state := Running(5846,[2874738232,518,offset,length,128,length/32,index],mem);
    trace := [state];
    Advance0(code,state,offset,length,index,word,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem);
    state := next0;
    Advance1(code,state,offset,length,index,word,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem);
    state := next1;
    Advance2(code,state,offset,length,index,word,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem);
    state := next2;
    Advance3(code,state,offset,length,index,word,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem);
    state := next3;
    Advance4(code,state,offset,length,index,word,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem);
    state := next4;
    Advance5(code,state,offset,length,index,word,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem);
    state := next5;
    Advance6(code,state,offset,length,index,word,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem);
    state := next6;
    Advance7(code,state,offset,length,index,word,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem);
    state := next7;
    Advance8(code,state,offset,length,index,word,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem);
    state := next8;
    Advance9(code,state,offset,length,index,word,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem);
    state := next9;
    Advance10(code,state,offset,length,index,word,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem);
    state := next10;
    Advance11(code,state,offset,length,index,word,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem);
    state := next11;
    Advance12(code,state,offset,length,index,word,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem);
    state := next12;
    Advance13(code,state,offset,length,index,word,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem);
    state := next13;
    Advance14(code,state,offset,length,index,word,mem,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(5846,[2874738232,518,offset,length,128,length/32,index],mem);
    state := next14;
  }
}
