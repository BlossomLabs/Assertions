// SPDX-License-Identifier: MIT
// Generated pinned sum loop instructions between actual helper boundaries.
include "Execution.dfy"
module BytecodeSumAfterSlice {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, total: Word, index: Word, word: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && index <= length/32 && index < length/32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[2885] == 91 &&
                                              code[2886] == 97 &&
                                              code[2887] == 11 &&
                                              code[2888] == 78 &&
                                              code[2889] == 145 &&
                                              code[2890] == 97 &&
                                              code[2891] == 92 &&
                                              code[2892] == 110 &&
                                              code[2893] == 86 &&
                                              code[23662] == 91
  }
  function Destinations(): set<nat> { {23662} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,total,index,word) && (
                                                                                                                                     if id == 0 then state == Running(2885,[394725771,604,offset,length,total,length/32,index,WordOffset(offset,index),32],mem)
                                                                                                                                     else if id == 1 then state == Running(2886,[394725771,604,offset,length,total,length/32,index,WordOffset(offset,index),32],mem)
                                                                                                                                     else if id == 2 then state == Running(2889,[394725771,604,offset,length,total,length/32,index,WordOffset(offset,index),32,2894],mem)
                                                                                                                                     else if id == 3 then state == Running(2890,[394725771,604,offset,length,total,length/32,index,2894,32,WordOffset(offset,index)],mem)
                                                                                                                                     else if id == 4 then state == Running(2893,[394725771,604,offset,length,total,length/32,index,2894,32,WordOffset(offset,index),23662],mem)
                                                                                                                                     else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(0,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2885,[394725771,604,offset,length,total,length/32,index,WordOffset(offset,index),32],mem);
    assert Fetch(code,2885) == Op(91,2886,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(1,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2886,[394725771,604,offset,length,total,length/32,index,WordOffset(offset,index),32],mem);
    F.Push2(code,2886);
    assert Fetch(code,2886) == Op(97,2889,2894);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(2,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2889,[394725771,604,offset,length,total,length/32,index,WordOffset(offset,index),32,2894],mem);
    assert Fetch(code,2889) == Op(145,2890,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(3,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,total,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2890,[394725771,604,offset,length,total,length/32,index,2894,32,WordOffset(offset,index)],mem);
    F.Push2(code,2890);
    assert Fetch(code,2890) == Op(97,2893,23662);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,total,index,word) && Good(4,state,offset,length,total,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23662,[394725771,604,offset,length,total,length/32,index,2894,32,WordOffset(offset,index)],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2893,[394725771,604,offset,length,total,length/32,index,2894,32,WordOffset(offset,index),23662],mem);
    assert Fetch(code,2893) == Op(86,2894,0);
  }
  lemma Start(offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,total,index,word)
    ensures Good(0,Running(2885,[394725771,604,offset,length,total,length/32,index,WordOffset(offset,index),32],mem),offset,length,total,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, total: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,total,index,word)
    ensures state == Running(23662,[394725771,604,offset,length,total,length/32,index,2894,32,WordOffset(offset,index)],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 6 && trace[0] == Running(2885,[394725771,604,offset,length,total,length/32,index,WordOffset(offset,index),32],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,total,index,word,mem);
    state := Running(2885,[394725771,604,offset,length,total,length/32,index,WordOffset(offset,index),32],mem);
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
  }
}
