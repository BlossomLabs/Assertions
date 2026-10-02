// SPDX-License-Identifier: MIT
// Generated pinned reverseWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeReverseSegmentAfterEnd {
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
                                              code[5891] == 91 &&
                                              code[5892] == 146 &&
                                              code[5893] == 97 &&
                                              code[5894] == 23 &&
                                              code[5895] == 16 &&
                                              code[5896] == 147 &&
                                              code[5897] == 146 &&
                                              code[5898] == 145 &&
                                              code[5899] == 144 &&
                                              code[5900] == 97 &&
                                              code[5901] == 92 &&
                                              code[5902] == 71 &&
                                              code[5903] == 86 &&
                                              code[23623] == 91
  }
  function Destinations(): set<nat> { {23623} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,index,word) && (
                                                                                                                        if id == 0 then state == Running(5891,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,NextPosition(index)],mem)
                                                                                                                        else if id == 1 then state == Running(5892,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,NextPosition(index)],mem)
                                                                                                                        else if id == 2 then state == Running(5893,[2874738232,518,offset,length,128,length/32,index,0,NextPosition(index),Position(index),length,offset],mem)
                                                                                                                        else if id == 3 then state == Running(5896,[2874738232,518,offset,length,128,length/32,index,0,NextPosition(index),Position(index),length,offset,5904],mem)
                                                                                                                        else if id == 4 then state == Running(5897,[2874738232,518,offset,length,128,length/32,index,0,5904,Position(index),length,offset,NextPosition(index)],mem)
                                                                                                                        else if id == 5 then state == Running(5898,[2874738232,518,offset,length,128,length/32,index,0,5904,NextPosition(index),length,offset,Position(index)],mem)
                                                                                                                        else if id == 6 then state == Running(5899,[2874738232,518,offset,length,128,length/32,index,0,5904,NextPosition(index),Position(index),offset,length],mem)
                                                                                                                        else if id == 7 then state == Running(5900,[2874738232,518,offset,length,128,length/32,index,0,5904,NextPosition(index),Position(index),length,offset],mem)
                                                                                                                        else if id == 8 then state == Running(5903,[2874738232,518,offset,length,128,length/32,index,0,5904,NextPosition(index),Position(index),length,offset,23623],mem)
                                                                                                                        else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(0,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5891,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,NextPosition(index)],mem);
    assert Fetch(code,5891) == Op(91,5892,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(1,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5892,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,NextPosition(index)],mem);
    assert Fetch(code,5892) == Op(146,5893,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(2,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5893,[2874738232,518,offset,length,128,length/32,index,0,NextPosition(index),Position(index),length,offset],mem);
    F.Push2(code,5893);
    assert Fetch(code,5893) == Op(97,5896,5904);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(3,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5896,[2874738232,518,offset,length,128,length/32,index,0,NextPosition(index),Position(index),length,offset,5904],mem);
    assert Fetch(code,5896) == Op(147,5897,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(4,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5897,[2874738232,518,offset,length,128,length/32,index,0,5904,Position(index),length,offset,NextPosition(index)],mem);
    assert Fetch(code,5897) == Op(146,5898,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(5,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5898,[2874738232,518,offset,length,128,length/32,index,0,5904,NextPosition(index),length,offset,Position(index)],mem);
    assert Fetch(code,5898) == Op(145,5899,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(6,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5899,[2874738232,518,offset,length,128,length/32,index,0,5904,NextPosition(index),Position(index),offset,length],mem);
    assert Fetch(code,5899) == Op(144,5900,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(7,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5900,[2874738232,518,offset,length,128,length/32,index,0,5904,NextPosition(index),Position(index),length,offset],mem);
    F.Push2(code,5900);
    assert Fetch(code,5900) == Op(97,5903,23623);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,index,word) && Good(8,state,offset,length,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23623,[2874738232,518,offset,length,128,length/32,index,0,5904,NextPosition(index),Position(index),length,offset],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5903,[2874738232,518,offset,length,128,length/32,index,0,5904,NextPosition(index),Position(index),length,offset,23623],mem);
    assert Fetch(code,5903) == Op(86,5904,0);
  }
  lemma Start(offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,index,word)
    ensures Good(0,Running(5891,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,NextPosition(index)],mem),offset,length,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,index,word)
    ensures state == Running(23623,[2874738232,518,offset,length,128,length/32,index,0,5904,NextPosition(index),Position(index),length,offset],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 10 && trace[0] == Running(5891,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,NextPosition(index)],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,index,word,mem);
    state := Running(5891,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,NextPosition(index)],mem);
    trace := [state];
    Advance0(code,state,offset,length,index,word,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(5891,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next0;
    Advance1(code,state,offset,length,index,word,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(5891,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next1;
    Advance2(code,state,offset,length,index,word,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(5891,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next2;
    Advance3(code,state,offset,length,index,word,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(5891,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next3;
    Advance4(code,state,offset,length,index,word,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(5891,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next4;
    Advance5(code,state,offset,length,index,word,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(5891,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next5;
    Advance6(code,state,offset,length,index,word,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(5891,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next6;
    Advance7(code,state,offset,length,index,word,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(5891,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next7;
    Advance8(code,state,offset,length,index,word,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(5891,[2874738232,518,offset,length,128,length/32,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next8;
  }
}
