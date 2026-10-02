// SPDX-License-Identifier: MIT
// Generated pinned sum loop instructions between actual helper boundaries.
include "Execution.dfy"
module BytecodeSumAfterEnd {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, total: Word, index: Word, word: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && index <= length/32 && index < length/32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[2872] == 91 &&
                                              code[2873] == 146 &&
                                              code[2874] == 97 &&
                                              code[2875] == 11 &&
                                              code[2876] == 69 &&
                                              code[2877] == 147 &&
                                              code[2878] == 146 &&
                                              code[2879] == 145 &&
                                              code[2880] == 144 &&
                                              code[2881] == 97 &&
                                              code[2882] == 92 &&
                                              code[2883] == 71 &&
                                              code[2884] == 86 &&
                                              code[23623] == 91
  }
  function Destinations(): set<nat> { {23623} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,total,index,word) && (
                                                                                                                                     if id == 0 then state == Running(2872,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,NextPosition(index)],mem)
                                                                                                                                     else if id == 1 then state == Running(2873,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,NextPosition(index)],mem)
                                                                                                                                     else if id == 2 then state == Running(2874,[394725771,604,offset,length,total,length/32,index,NextPosition(index),Position(index),length,offset],mem)
                                                                                                                                     else if id == 3 then state == Running(2877,[394725771,604,offset,length,total,length/32,index,NextPosition(index),Position(index),length,offset,2885],mem)
                                                                                                                                     else if id == 4 then state == Running(2878,[394725771,604,offset,length,total,length/32,index,2885,Position(index),length,offset,NextPosition(index)],mem)
                                                                                                                                     else if id == 5 then state == Running(2879,[394725771,604,offset,length,total,length/32,index,2885,NextPosition(index),length,offset,Position(index)],mem)
                                                                                                                                     else if id == 6 then state == Running(2880,[394725771,604,offset,length,total,length/32,index,2885,NextPosition(index),Position(index),offset,length],mem)
                                                                                                                                     else if id == 7 then state == Running(2881,[394725771,604,offset,length,total,length/32,index,2885,NextPosition(index),Position(index),length,offset],mem)
                                                                                                                                     else if id == 8 then state == Running(2884,[394725771,604,offset,length,total,length/32,index,2885,NextPosition(index),Position(index),length,offset,23623],mem)
                                                                                                                                     else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(0,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2872,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,NextPosition(index)],mem);
    assert Fetch(code,2872) == Op(91,2873,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(1,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2873,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,NextPosition(index)],mem);
    assert Fetch(code,2873) == Op(146,2874,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(2,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2874,[394725771,604,offset,length,total,length/32,index,NextPosition(index),Position(index),length,offset],mem);
    F.Push2(code,2874);
    assert Fetch(code,2874) == Op(97,2877,2885);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(3,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2877,[394725771,604,offset,length,total,length/32,index,NextPosition(index),Position(index),length,offset,2885],mem);
    assert Fetch(code,2877) == Op(147,2878,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(4,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2878,[394725771,604,offset,length,total,length/32,index,2885,Position(index),length,offset,NextPosition(index)],mem);
    assert Fetch(code,2878) == Op(146,2879,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(5,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2879,[394725771,604,offset,length,total,length/32,index,2885,NextPosition(index),length,offset,Position(index)],mem);
    assert Fetch(code,2879) == Op(145,2880,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(6,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2880,[394725771,604,offset,length,total,length/32,index,2885,NextPosition(index),Position(index),offset,length],mem);
    assert Fetch(code,2880) == Op(144,2881,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(7,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2881,[394725771,604,offset,length,total,length/32,index,2885,NextPosition(index),Position(index),length,offset],mem);
    F.Push2(code,2881);
    assert Fetch(code,2881) == Op(97,2884,23623);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(8,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23623,[394725771,604,offset,length,total,length/32,index,2885,NextPosition(index),Position(index),length,offset],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2884,[394725771,604,offset,length,total,length/32,index,2885,NextPosition(index),Position(index),length,offset,23623],mem);
    assert Fetch(code,2884) == Op(86,2885,0);
  }
  lemma Start(offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,total,index,word)
    ensures Good(0,Running(2872,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,NextPosition(index)],mem),offset,length,total,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,total,index,word)
    ensures state == Running(23623,[394725771,604,offset,length,total,length/32,index,2885,NextPosition(index),Position(index),length,offset],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 10 && trace[0] == Running(2872,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,NextPosition(index)],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,total,index,word,mem);
    state := Running(2872,[394725771,604,offset,length,total,length/32,index,offset,Position(index),length,NextPosition(index)],mem);
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
    Advance7(code,state,offset,length,total,index,word,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,offset,length,total,index,word,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
  }
}
