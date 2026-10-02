// SPDX-License-Identifier: MIT
// Generated pinned reverseWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeReverseSegmentAfterMulSecond {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeReverseLoopScalar
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  function Target(length: Word, index: Word): Word { (if index < length/32 then 160+(length/32-1-index)*32 else 160)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, index: Word, word: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && index <= length/32 && index < length/32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[5880] == 91 &&
                                              code[5881] == 97 &&
                                              code[5882] == 23 &&
                                              code[5883] == 3 &&
                                              code[5884] == 144 &&
                                              code[5885] == 96 &&
                                              code[5886] == 32 &&
                                              code[5887] == 97 &&
                                              code[5888] == 92 &&
                                              code[5889] == 52 &&
                                              code[5890] == 86 &&
                                              code[23604] == 91
  }
  function Destinations(): set<nat> { {23604} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,index,word) && (
                                                                                                                        if id == 0 then state == Running(5880,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,Position(index)],mem)
                                                                                                                        else if id == 1 then state == Running(5881,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,Position(index)],mem)
                                                                                                                        else if id == 2 then state == Running(5884,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,Position(index),5891],mem)
                                                                                                                        else if id == 3 then state == Running(5885,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5891,Position(index)],mem)
                                                                                                                        else if id == 4 then state == Running(5887,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5891,Position(index),32],mem)
                                                                                                                        else if id == 5 then state == Running(5890,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5891,Position(index),32,23604],mem)
                                                                                                                        else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(0,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5880,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,Position(index)],mem);
    assert Fetch(code,5880) == Op(91,5881,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(1,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5881,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,Position(index)],mem);
    F.Push2(code,5881);
    assert Fetch(code,5881) == Op(97,5884,5891);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(2,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5884,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,Position(index),5891],mem);
    assert Fetch(code,5884) == Op(144,5885,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(3,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5885,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5891,Position(index)],mem);
    F.Push1(code,5885);
    assert Fetch(code,5885) == Op(96,5887,32);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(4,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5887,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5891,Position(index),32],mem);
    F.Push2(code,5887);
    assert Fetch(code,5887) == Op(97,5890,23604);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(5,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23604,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5891,Position(index),32],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5890,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5891,Position(index),32,23604],mem);
    assert Fetch(code,5890) == Op(86,5891,0);
  }
  lemma Start(offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,index,word)
    ensures Good(0,Running(5880,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,Position(index)],mem),offset,length,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,index,word)
    ensures state == Running(23604,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5891,Position(index),32],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 7 && trace[0] == Running(5880,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,Position(index)],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,index,word,mem);
    state := Running(5880,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,Position(index)],mem);
    trace := [state];
    Advance0(code,state,offset,length,index,word,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(5880,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,Position(index)],mem);
    state := next0;
    Advance1(code,state,offset,length,index,word,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(5880,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,Position(index)],mem);
    state := next1;
    Advance2(code,state,offset,length,index,word,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(5880,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,Position(index)],mem);
    state := next2;
    Advance3(code,state,offset,length,index,word,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(5880,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,Position(index)],mem);
    state := next3;
    Advance4(code,state,offset,length,index,word,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(5880,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,Position(index)],mem);
    state := next4;
    Advance5(code,state,offset,length,index,word,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(5880,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,Position(index)],mem);
    state := next5;
  }
}
