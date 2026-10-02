// SPDX-License-Identifier: MIT
// Generated pinned sum loop instructions between actual helper boundaries.
include "Execution.dfy"
module BytecodeSumAfterMulSecond {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, total: Word, index: Word, word: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && index <= length/32 && index < length/32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[2861] == 91 &&
                                              code[2862] == 97 &&
                                              code[2863] == 11 &&
                                              code[2864] == 56 &&
                                              code[2865] == 144 &&
                                              code[2866] == 96 &&
                                              code[2867] == 32 &&
                                              code[2868] == 97 &&
                                              code[2869] == 92 &&
                                              code[2870] == 52 &&
                                              code[2871] == 86 &&
                                              code[23604] == 91
  }
  function Destinations(): set<nat> { {23604} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,total,index,word) && (
                                                                                                                                     if id == 0 then state == Running(2861,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,Position(index)],mem)
                                                                                                                                     else if id == 1 then state == Running(2862,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,Position(index)],mem)
                                                                                                                                     else if id == 2 then state == Running(2865,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,Position(index),2872],mem)
                                                                                                                                     else if id == 3 then state == Running(2866,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,2872,Position(index)],mem)
                                                                                                                                     else if id == 4 then state == Running(2868,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,2872,Position(index),32],mem)
                                                                                                                                     else if id == 5 then state == Running(2871,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,2872,Position(index),32,23604],mem)
                                                                                                                                     else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(0,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2861,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,Position(index)],mem);
    assert Fetch(code,2861) == Op(91,2862,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(1,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2862,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,Position(index)],mem);
    F.Push2(code,2862);
    assert Fetch(code,2862) == Op(97,2865,2872);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(2,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2865,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,Position(index),2872],mem);
    assert Fetch(code,2865) == Op(144,2866,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(3,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2866,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,2872,Position(index)],mem);
    F.Push1(code,2866);
    assert Fetch(code,2866) == Op(96,2868,32);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(4,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2868,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,2872,Position(index),32],mem);
    F.Push2(code,2868);
    assert Fetch(code,2868) == Op(97,2871,23604);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(5,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23604,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,2872,Position(index),32],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2871,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,2872,Position(index),32,23604],mem);
    assert Fetch(code,2871) == Op(86,2872,0);
  }
  lemma Start(offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,total,index,word)
    ensures Good(0,Running(2861,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,Position(index)],mem),offset,length,total,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,total,index,word)
    ensures state == Running(23604,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,2872,Position(index),32],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 7 && trace[0] == Running(2861,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,Position(index)],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,total,index,word,mem);
    state := Running(2861,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,Position(index)],mem);
    trace := [state];
    Advance0(code,state,offset,length,total,index,word,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,offset,length,total,index,word,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,offset,length,total,index,word,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,offset,length,total,index,word,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,offset,length,total,index,word,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,offset,length,total,index,word,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
  }
}
