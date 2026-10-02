// SPDX-License-Identifier: MIT
// Generated pinned sum loop instructions between actual helper boundaries.
include "Execution.dfy"
module BytecodeSumBodyStart {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, total: Word, index: Word, word: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && index <= length/32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[2767] == 91 &&
                                              code[2768] == 95 &&
                                              code[2769] == 97 &&
                                              code[2770] == 10 &&
                                              code[2771] == 219 &&
                                              code[2772] == 96 &&
                                              code[2773] == 32 &&
                                              code[2774] == 131 &&
                                              code[2775] == 97 &&
                                              code[2776] == 91 &&
                                              code[2777] == 227 &&
                                              code[2778] == 86 &&
                                              code[23523] == 91
  }
  function Destinations(): set<nat> { {23523} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,total,index,word) && (
                                                                                                                                     if id == 0 then state == Running(2767,[394725771,604,offset,length],mem)
                                                                                                                                     else if id == 1 then state == Running(2768,[394725771,604,offset,length],mem)
                                                                                                                                     else if id == 2 then state == Running(2769,[394725771,604,offset,length,0],mem)
                                                                                                                                     else if id == 3 then state == Running(2772,[394725771,604,offset,length,0,2779],mem)
                                                                                                                                     else if id == 4 then state == Running(2774,[394725771,604,offset,length,0,2779,32],mem)
                                                                                                                                     else if id == 5 then state == Running(2775,[394725771,604,offset,length,0,2779,32,length],mem)
                                                                                                                                     else if id == 6 then state == Running(2778,[394725771,604,offset,length,0,2779,32,length,23523],mem)
                                                                                                                                     else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(0,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2767,[394725771,604,offset,length],mem);
    assert Fetch(code,2767) == Op(91,2768,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(1,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2768,[394725771,604,offset,length],mem);
    assert Fetch(code,2768) == Op(95,2769,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(2,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2769,[394725771,604,offset,length,0],mem);
    F.Push2(code,2769);
    assert Fetch(code,2769) == Op(97,2772,2779);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(3,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2772,[394725771,604,offset,length,0,2779],mem);
    F.Push1(code,2772);
    assert Fetch(code,2772) == Op(96,2774,32);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(4,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2774,[394725771,604,offset,length,0,2779,32],mem);
    assert Fetch(code,2774) == Op(131,2775,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(5,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2775,[394725771,604,offset,length,0,2779,32,length],mem);
    F.Push2(code,2775);
    assert Fetch(code,2775) == Op(97,2778,23523);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(6,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23523,[394725771,604,offset,length,0,2779,32,length],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2778,[394725771,604,offset,length,0,2779,32,length,23523],mem);
    assert Fetch(code,2778) == Op(86,2779,0);
  }
  lemma Start(offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,total,index,word)
    ensures Good(0,Running(2767,[394725771,604,offset,length],mem),offset,length,total,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,total,index,word)
    ensures state == Running(23523,[394725771,604,offset,length,0,2779,32,length],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 8 && trace[0] == Running(2767,[394725771,604,offset,length],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,total,index,word,mem);
    state := Running(2767,[394725771,604,offset,length],mem);
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
    Advance6(code,state,offset,length,total,index,word,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
  }
}
