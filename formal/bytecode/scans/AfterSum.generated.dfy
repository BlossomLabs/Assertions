// SPDX-License-Identifier: MIT
// Generated pinned sum loop instructions between actual helper boundaries.
include "Execution.dfy"
module BytecodeSumAfterSum {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, total: Word, index: Word, word: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && index <= length/32 && index < length/32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[2828] == 91 &&
                                              code[2904] == 91 &&
                                              code[2905] == 146 &&
                                              code[2906] == 80 &&
                                              code[2907] == 96 &&
                                              code[2908] == 1 &&
                                              code[2909] == 1 &&
                                              code[2910] == 97 &&
                                              code[2911] == 11 &&
                                              code[2912] == 12 &&
                                              code[2913] == 86
  }
  function Destinations(): set<nat> { {2828} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,total,index,word) && (
                                                                                                                                     if id == 0 then state == Running(2904,[394725771,604,offset,length,total,length/32,index,word],mem)
                                                                                                                                     else if id == 1 then state == Running(2905,[394725771,604,offset,length,total,length/32,index,word],mem)
                                                                                                                                     else if id == 2 then state == Running(2906,[394725771,604,offset,length,word,length/32,index,total],mem)
                                                                                                                                     else if id == 3 then state == Running(2907,[394725771,604,offset,length,word,length/32,index],mem)
                                                                                                                                     else if id == 4 then state == Running(2909,[394725771,604,offset,length,word,length/32,index,1],mem)
                                                                                                                                     else if id == 5 then state == Running(2910,[394725771,604,offset,length,word,length/32,((1 as nat)+(index as nat))%G.Modulus()],mem)
                                                                                                                                     else if id == 6 then state == Running(2913,[394725771,604,offset,length,word,length/32,((1 as nat)+(index as nat))%G.Modulus(),2828],mem)
                                                                                                                                     else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(0,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2904,[394725771,604,offset,length,total,length/32,index,word],mem);
    assert Fetch(code,2904) == Op(91,2905,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(1,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2905,[394725771,604,offset,length,total,length/32,index,word],mem);
    assert Fetch(code,2905) == Op(146,2906,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(2,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2906,[394725771,604,offset,length,word,length/32,index,total],mem);
    assert Fetch(code,2906) == Op(80,2907,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(3,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2907,[394725771,604,offset,length,word,length/32,index],mem);
    F.Push1(code,2907);
    assert Fetch(code,2907) == Op(96,2909,1);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(4,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2909,[394725771,604,offset,length,word,length/32,index,1],mem);
    assert Fetch(code,2909) == Op(1,2910,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(5,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2910,[394725771,604,offset,length,word,length/32,((1 as nat)+(index as nat))%G.Modulus()],mem);
    F.Push2(code,2910);
    assert Fetch(code,2910) == Op(97,2913,2828);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(6,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(2828,[394725771,604,offset,length,word,length/32,(index as nat)+1],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2913,[394725771,604,offset,length,word,length/32,((1 as nat)+(index as nat))%G.Modulus(),2828],mem);
    assert Fetch(code,2913) == Op(86,2914,0);
  }
  lemma Start(offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,total,index,word)
    ensures Good(0,Running(2904,[394725771,604,offset,length,total,length/32,index,word],mem),offset,length,total,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,total,index,word)
    ensures state == Running(2828,[394725771,604,offset,length,word,length/32,(index as nat)+1],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 8 && trace[0] == Running(2904,[394725771,604,offset,length,total,length/32,index,word],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,total,index,word,mem);
    state := Running(2904,[394725771,604,offset,length,total,length/32,index,word],mem);
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
