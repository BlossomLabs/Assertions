// SPDX-License-Identifier: MIT
// Generated pinned reverseWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeReverseSegmentAfterMulFirst {
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
                                              code[5868] == 91 &&
                                              code[5869] == 144 &&
                                              code[5870] == 97 &&
                                              code[5871] == 22 &&
                                              code[5872] == 248 &&
                                              code[5873] == 133 &&
                                              code[5874] == 96 &&
                                              code[5875] == 32 &&
                                              code[5876] == 97 &&
                                              code[5877] == 92 &&
                                              code[5878] == 29 &&
                                              code[5879] == 86 &&
                                              code[23581] == 91
  }
  function Destinations(): set<nat> { {23581} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,index,word) && (
                                                                                                                        if id == 0 then state == Running(5868,[2874738232,518,offset,length,128,length/32,index,0,offset,length,Position(index)],mem)
                                                                                                                        else if id == 1 then state == Running(5869,[2874738232,518,offset,length,128,length/32,index,0,offset,length,Position(index)],mem)
                                                                                                                        else if id == 2 then state == Running(5870,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length],mem)
                                                                                                                        else if id == 3 then state == Running(5873,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5880],mem)
                                                                                                                        else if id == 4 then state == Running(5874,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5880,index],mem)
                                                                                                                        else if id == 5 then state == Running(5876,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5880,index,32],mem)
                                                                                                                        else if id == 6 then state == Running(5879,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5880,index,32,23581],mem)
                                                                                                                        else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(0,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5868,[2874738232,518,offset,length,128,length/32,index,0,offset,length,Position(index)],mem);
    assert Fetch(code,5868) == Op(91,5869,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(1,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5869,[2874738232,518,offset,length,128,length/32,index,0,offset,length,Position(index)],mem);
    assert Fetch(code,5869) == Op(144,5870,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(2,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5870,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length],mem);
    F.Push2(code,5870);
    assert Fetch(code,5870) == Op(97,5873,5880);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(3,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5873,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5880],mem);
    assert Fetch(code,5873) == Op(133,5874,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(4,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5874,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5880,index],mem);
    F.Push1(code,5874);
    assert Fetch(code,5874) == Op(96,5876,32);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(5,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5876,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5880,index,32],mem);
    F.Push2(code,5876);
    assert Fetch(code,5876) == Op(97,5879,23581);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(6,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23581,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5880,index,32],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5879,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5880,index,32,23581],mem);
    assert Fetch(code,5879) == Op(86,5880,0);
  }
  lemma Start(offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,index,word)
    ensures Good(0,Running(5868,[2874738232,518,offset,length,128,length/32,index,0,offset,length,Position(index)],mem),offset,length,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,index,word)
    ensures state == Running(23581,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,5880,index,32],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 8 && trace[0] == Running(5868,[2874738232,518,offset,length,128,length/32,index,0,offset,length,Position(index)],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,index,word,mem);
    state := Running(5868,[2874738232,518,offset,length,128,length/32,index,0,offset,length,Position(index)],mem);
    trace := [state];
    Advance0(code,state,offset,length,index,word,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(5868,[2874738232,518,offset,length,128,length/32,index,0,offset,length,Position(index)],mem);
    state := next0;
    Advance1(code,state,offset,length,index,word,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(5868,[2874738232,518,offset,length,128,length/32,index,0,offset,length,Position(index)],mem);
    state := next1;
    Advance2(code,state,offset,length,index,word,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(5868,[2874738232,518,offset,length,128,length/32,index,0,offset,length,Position(index)],mem);
    state := next2;
    Advance3(code,state,offset,length,index,word,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(5868,[2874738232,518,offset,length,128,length/32,index,0,offset,length,Position(index)],mem);
    state := next3;
    Advance4(code,state,offset,length,index,word,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(5868,[2874738232,518,offset,length,128,length/32,index,0,offset,length,Position(index)],mem);
    state := next4;
    Advance5(code,state,offset,length,index,word,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(5868,[2874738232,518,offset,length,128,length/32,index,0,offset,length,Position(index)],mem);
    state := next5;
    Advance6(code,state,offset,length,index,word,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(5868,[2874738232,518,offset,length,128,length/32,index,0,offset,length,Position(index)],mem);
    state := next6;
  }
}
