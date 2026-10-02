// SPDX-License-Identifier: MIT
// Generated pinned sum loop instructions between actual helper boundaries.
include "../scans/Execution.dfy"
module BytecodeIndexBodyStart {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, needle: Word, index: Word, word: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && index <= length/32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[8235] == 91 &&
                                              code[8236] == 95 &&
                                              code[8237] == 97 &&
                                              code[8238] == 32 &&
                                              code[8239] == 55 &&
                                              code[8240] == 96 &&
                                              code[8241] == 32 &&
                                              code[8242] == 132 &&
                                              code[8243] == 97 &&
                                              code[8244] == 91 &&
                                              code[8245] == 227 &&
                                              code[8246] == 86 &&
                                              code[23523] == 91
  }
  function Destinations(): set<nat> { {23523} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,needle,index,word) && (
                                                                                                                                      if id == 0 then state == Running(8235,[3904669827,604,offset,length,needle],mem)
                                                                                                                                      else if id == 1 then state == Running(8236,[3904669827,604,offset,length,needle],mem)
                                                                                                                                      else if id == 2 then state == Running(8237,[3904669827,604,offset,length,needle,0],mem)
                                                                                                                                      else if id == 3 then state == Running(8240,[3904669827,604,offset,length,needle,0,8247],mem)
                                                                                                                                      else if id == 4 then state == Running(8242,[3904669827,604,offset,length,needle,0,8247,32],mem)
                                                                                                                                      else if id == 5 then state == Running(8243,[3904669827,604,offset,length,needle,0,8247,32,length],mem)
                                                                                                                                      else if id == 6 then state == Running(8246,[3904669827,604,offset,length,needle,0,8247,32,length,23523],mem)
                                                                                                                                      else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(0,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8235,[3904669827,604,offset,length,needle],mem);
    assert Fetch(code,8235) == Op(91,8236,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(1,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8236,[3904669827,604,offset,length,needle],mem);
    assert Fetch(code,8236) == Op(95,8237,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(2,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8237,[3904669827,604,offset,length,needle,0],mem);
    F.Push2(code,8237);
    assert Fetch(code,8237) == Op(97,8240,8247);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(3,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8240,[3904669827,604,offset,length,needle,0,8247],mem);
    F.Push1(code,8240);
    assert Fetch(code,8240) == Op(96,8242,32);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(4,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8242,[3904669827,604,offset,length,needle,0,8247,32],mem);
    assert Fetch(code,8242) == Op(132,8243,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(5,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8243,[3904669827,604,offset,length,needle,0,8247,32,length],mem);
    F.Push2(code,8243);
    assert Fetch(code,8243) == Op(97,8246,23523);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(6,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23523,[3904669827,604,offset,length,needle,0,8247,32,length],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8246,[3904669827,604,offset,length,needle,0,8247,32,length,23523],mem);
    assert Fetch(code,8246) == Op(86,8247,0);
  }
  lemma Start(offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,needle,index,word)
    ensures Good(0,Running(8235,[3904669827,604,offset,length,needle],mem),offset,length,needle,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,needle,index,word)
    ensures state == Running(23523,[3904669827,604,offset,length,needle,0,8247,32,length],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 8 && trace[0] == Running(8235,[3904669827,604,offset,length,needle],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,needle,index,word,mem);
    state := Running(8235,[3904669827,604,offset,length,needle],mem);
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
  }
}
