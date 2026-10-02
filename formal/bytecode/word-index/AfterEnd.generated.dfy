// SPDX-License-Identifier: MIT
// Generated pinned sum loop instructions between actual helper boundaries.
include "../scans/Execution.dfy"
module BytecodeIndexAfterEnd {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, needle: Word, index: Word, word: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && index <= length/32 && index < length/32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[8341] == 91 &&
                                              code[8342] == 146 &&
                                              code[8343] == 97 &&
                                              code[8344] == 32 &&
                                              code[8345] == 162 &&
                                              code[8346] == 147 &&
                                              code[8347] == 146 &&
                                              code[8348] == 145 &&
                                              code[8349] == 144 &&
                                              code[8350] == 97 &&
                                              code[8351] == 92 &&
                                              code[8352] == 71 &&
                                              code[8353] == 86 &&
                                              code[23623] == 91
  }
  function Destinations(): set<nat> { {23623} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,needle,index,word) && (
                                                                                                                                      if id == 0 then state == Running(8341,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,NextPosition(index)],mem)
                                                                                                                                      else if id == 1 then state == Running(8342,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,NextPosition(index)],mem)
                                                                                                                                      else if id == 2 then state == Running(8343,[3904669827,604,offset,length,needle,0,length/32,index,needle,NextPosition(index),Position(index),length,offset],mem)
                                                                                                                                      else if id == 3 then state == Running(8346,[3904669827,604,offset,length,needle,0,length/32,index,needle,NextPosition(index),Position(index),length,offset,8354],mem)
                                                                                                                                      else if id == 4 then state == Running(8347,[3904669827,604,offset,length,needle,0,length/32,index,needle,8354,Position(index),length,offset,NextPosition(index)],mem)
                                                                                                                                      else if id == 5 then state == Running(8348,[3904669827,604,offset,length,needle,0,length/32,index,needle,8354,NextPosition(index),length,offset,Position(index)],mem)
                                                                                                                                      else if id == 6 then state == Running(8349,[3904669827,604,offset,length,needle,0,length/32,index,needle,8354,NextPosition(index),Position(index),offset,length],mem)
                                                                                                                                      else if id == 7 then state == Running(8350,[3904669827,604,offset,length,needle,0,length/32,index,needle,8354,NextPosition(index),Position(index),length,offset],mem)
                                                                                                                                      else if id == 8 then state == Running(8353,[3904669827,604,offset,length,needle,0,length/32,index,needle,8354,NextPosition(index),Position(index),length,offset,23623],mem)
                                                                                                                                      else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(0,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8341,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,NextPosition(index)],mem);
    assert Fetch(code,8341) == Op(91,8342,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(1,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8342,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,NextPosition(index)],mem);
    assert Fetch(code,8342) == Op(146,8343,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(2,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8343,[3904669827,604,offset,length,needle,0,length/32,index,needle,NextPosition(index),Position(index),length,offset],mem);
    F.Push2(code,8343);
    assert Fetch(code,8343) == Op(97,8346,8354);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(3,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8346,[3904669827,604,offset,length,needle,0,length/32,index,needle,NextPosition(index),Position(index),length,offset,8354],mem);
    assert Fetch(code,8346) == Op(147,8347,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(4,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8347,[3904669827,604,offset,length,needle,0,length/32,index,needle,8354,Position(index),length,offset,NextPosition(index)],mem);
    assert Fetch(code,8347) == Op(146,8348,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(5,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8348,[3904669827,604,offset,length,needle,0,length/32,index,needle,8354,NextPosition(index),length,offset,Position(index)],mem);
    assert Fetch(code,8348) == Op(145,8349,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(6,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8349,[3904669827,604,offset,length,needle,0,length/32,index,needle,8354,NextPosition(index),Position(index),offset,length],mem);
    assert Fetch(code,8349) == Op(144,8350,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(7,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8350,[3904669827,604,offset,length,needle,0,length/32,index,needle,8354,NextPosition(index),Position(index),length,offset],mem);
    F.Push2(code,8350);
    assert Fetch(code,8350) == Op(97,8353,23623);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(8,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23623,[3904669827,604,offset,length,needle,0,length/32,index,needle,8354,NextPosition(index),Position(index),length,offset],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8353,[3904669827,604,offset,length,needle,0,length/32,index,needle,8354,NextPosition(index),Position(index),length,offset,23623],mem);
    assert Fetch(code,8353) == Op(86,8354,0);
  }
  lemma Start(offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,needle,index,word)
    ensures Good(0,Running(8341,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,NextPosition(index)],mem),offset,length,needle,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,needle,index,word)
    ensures state == Running(23623,[3904669827,604,offset,length,needle,0,length/32,index,needle,8354,NextPosition(index),Position(index),length,offset],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 10 && trace[0] == Running(8341,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,NextPosition(index)],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,needle,index,word,mem);
    state := Running(8341,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,NextPosition(index)],mem);
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
    Advance5(code,state,offset,length,needle,index,word,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,offset,length,needle,index,word,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,offset,length,needle,index,word,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,offset,length,needle,index,word,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
  }
}
