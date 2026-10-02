// SPDX-License-Identifier: MIT
// Generated pinned sum loop instructions between actual helper boundaries.
include "../scans/Execution.dfy"
module BytecodeIndexAfterSlice {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, needle: Word, index: Word, word: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && index <= length/32 && index < length/32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[8354] == 91 &&
                                              code[8355] == 97 &&
                                              code[8356] == 32 &&
                                              code[8357] == 171 &&
                                              code[8358] == 145 &&
                                              code[8359] == 97 &&
                                              code[8360] == 92 &&
                                              code[8361] == 110 &&
                                              code[8362] == 86 &&
                                              code[23662] == 91
  }
  function Destinations(): set<nat> { {23662} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,needle,index,word) && (
                                                                                                                                      if id == 0 then state == Running(8354,[3904669827,604,offset,length,needle,0,length/32,index,needle,WordOffset(offset,index),32],mem)
                                                                                                                                      else if id == 1 then state == Running(8355,[3904669827,604,offset,length,needle,0,length/32,index,needle,WordOffset(offset,index),32],mem)
                                                                                                                                      else if id == 2 then state == Running(8358,[3904669827,604,offset,length,needle,0,length/32,index,needle,WordOffset(offset,index),32,8363],mem)
                                                                                                                                      else if id == 3 then state == Running(8359,[3904669827,604,offset,length,needle,0,length/32,index,needle,8363,32,WordOffset(offset,index)],mem)
                                                                                                                                      else if id == 4 then state == Running(8362,[3904669827,604,offset,length,needle,0,length/32,index,needle,8363,32,WordOffset(offset,index),23662],mem)
                                                                                                                                      else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(0,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8354,[3904669827,604,offset,length,needle,0,length/32,index,needle,WordOffset(offset,index),32],mem);
    assert Fetch(code,8354) == Op(91,8355,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(1,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8355,[3904669827,604,offset,length,needle,0,length/32,index,needle,WordOffset(offset,index),32],mem);
    F.Push2(code,8355);
    assert Fetch(code,8355) == Op(97,8358,8363);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(2,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8358,[3904669827,604,offset,length,needle,0,length/32,index,needle,WordOffset(offset,index),32,8363],mem);
    assert Fetch(code,8358) == Op(145,8359,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(3,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8359,[3904669827,604,offset,length,needle,0,length/32,index,needle,8363,32,WordOffset(offset,index)],mem);
    F.Push2(code,8359);
    assert Fetch(code,8359) == Op(97,8362,23662);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(4,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23662,[3904669827,604,offset,length,needle,0,length/32,index,needle,8363,32,WordOffset(offset,index)],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8362,[3904669827,604,offset,length,needle,0,length/32,index,needle,8363,32,WordOffset(offset,index),23662],mem);
    assert Fetch(code,8362) == Op(86,8363,0);
  }
  lemma Start(offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,needle,index,word)
    ensures Good(0,Running(8354,[3904669827,604,offset,length,needle,0,length/32,index,needle,WordOffset(offset,index),32],mem),offset,length,needle,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,needle,index,word)
    ensures state == Running(23662,[3904669827,604,offset,length,needle,0,length/32,index,needle,8363,32,WordOffset(offset,index)],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 6 && trace[0] == Running(8354,[3904669827,604,offset,length,needle,0,length/32,index,needle,WordOffset(offset,index),32],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,needle,index,word,mem);
    state := Running(8354,[3904669827,604,offset,length,needle,0,length/32,index,needle,WordOffset(offset,index),32],mem);
    trace := [state];
    Advance0(code,state,offset,length,needle,index,word,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,offset,length,needle,index,word,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,offset,length,needle,index,word,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,offset,length,needle,index,word,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,offset,length,needle,index,word,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
  }
}
