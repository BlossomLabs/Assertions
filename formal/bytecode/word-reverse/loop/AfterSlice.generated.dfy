// SPDX-License-Identifier: MIT
// Generated pinned reverseWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeReverseSegmentAfterSlice {
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
                                              code[5904] == 91 &&
                                              code[5905] == 97 &&
                                              code[5906] == 23 &&
                                              code[5907] == 25 &&
                                              code[5908] == 145 &&
                                              code[5909] == 97 &&
                                              code[5910] == 92 &&
                                              code[5911] == 110 &&
                                              code[5912] == 86 &&
                                              code[23662] == 91
  }
  function Destinations(): set<nat> { {23662} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,index,word) && (
                                                                                                                        if id == 0 then state == Running(5904,[2874738232,518,offset,length,128,length/32,index,0,WordOffset(offset,index),32],mem)
                                                                                                                        else if id == 1 then state == Running(5905,[2874738232,518,offset,length,128,length/32,index,0,WordOffset(offset,index),32],mem)
                                                                                                                        else if id == 2 then state == Running(5908,[2874738232,518,offset,length,128,length/32,index,0,WordOffset(offset,index),32,5913],mem)
                                                                                                                        else if id == 3 then state == Running(5909,[2874738232,518,offset,length,128,length/32,index,0,5913,32,WordOffset(offset,index)],mem)
                                                                                                                        else if id == 4 then state == Running(5912,[2874738232,518,offset,length,128,length/32,index,0,5913,32,WordOffset(offset,index),23662],mem)
                                                                                                                        else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(0,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5904,[2874738232,518,offset,length,128,length/32,index,0,WordOffset(offset,index),32],mem);
    assert Fetch(code,5904) == Op(91,5905,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(1,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5905,[2874738232,518,offset,length,128,length/32,index,0,WordOffset(offset,index),32],mem);
    F.Push2(code,5905);
    assert Fetch(code,5905) == Op(97,5908,5913);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(2,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5908,[2874738232,518,offset,length,128,length/32,index,0,WordOffset(offset,index),32,5913],mem);
    assert Fetch(code,5908) == Op(145,5909,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(3,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5909,[2874738232,518,offset,length,128,length/32,index,0,5913,32,WordOffset(offset,index)],mem);
    F.Push2(code,5909);
    assert Fetch(code,5909) == Op(97,5912,23662);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(4,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23662,[2874738232,518,offset,length,128,length/32,index,0,5913,32,WordOffset(offset,index)],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5912,[2874738232,518,offset,length,128,length/32,index,0,5913,32,WordOffset(offset,index),23662],mem);
    assert Fetch(code,5912) == Op(86,5913,0);
  }
  lemma Start(offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,index,word)
    ensures Good(0,Running(5904,[2874738232,518,offset,length,128,length/32,index,0,WordOffset(offset,index),32],mem),offset,length,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,index,word)
    ensures state == Running(23662,[2874738232,518,offset,length,128,length/32,index,0,5913,32,WordOffset(offset,index)],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 6 && trace[0] == Running(5904,[2874738232,518,offset,length,128,length/32,index,0,WordOffset(offset,index),32],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,index,word,mem);
    state := Running(5904,[2874738232,518,offset,length,128,length/32,index,0,WordOffset(offset,index),32],mem);
    trace := [state];
    Advance0(code,state,offset,length,index,word,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(5904,[2874738232,518,offset,length,128,length/32,index,0,WordOffset(offset,index),32],mem);
    state := next0;
    Advance1(code,state,offset,length,index,word,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(5904,[2874738232,518,offset,length,128,length/32,index,0,WordOffset(offset,index),32],mem);
    state := next1;
    Advance2(code,state,offset,length,index,word,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(5904,[2874738232,518,offset,length,128,length/32,index,0,WordOffset(offset,index),32],mem);
    state := next2;
    Advance3(code,state,offset,length,index,word,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(5904,[2874738232,518,offset,length,128,length/32,index,0,WordOffset(offset,index),32],mem);
    state := next3;
    Advance4(code,state,offset,length,index,word,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(5904,[2874738232,518,offset,length,128,length/32,index,0,WordOffset(offset,index),32],mem);
    state := next4;
  }
}
