// SPDX-License-Identifier: MIT
// Generated pinned sum loop instructions between actual helper boundaries.
include "../scans/Execution.dfy"
module BytecodeIndexAfterMulSecond {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, needle: Word, index: Word, word: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && index <= length/32 && index < length/32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[8330] == 91 &&
                                              code[8331] == 97 &&
                                              code[8332] == 32 &&
                                              code[8333] == 149 &&
                                              code[8334] == 144 &&
                                              code[8335] == 96 &&
                                              code[8336] == 32 &&
                                              code[8337] == 97 &&
                                              code[8338] == 92 &&
                                              code[8339] == 52 &&
                                              code[8340] == 86 &&
                                              code[23604] == 91
  }
  function Destinations(): set<nat> { {23604} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,needle,index,word) && (
                                                                                                                                      if id == 0 then state == Running(8330,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,Position(index)],mem)
                                                                                                                                      else if id == 1 then state == Running(8331,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,Position(index)],mem)
                                                                                                                                      else if id == 2 then state == Running(8334,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,Position(index),8341],mem)
                                                                                                                                      else if id == 3 then state == Running(8335,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,8341,Position(index)],mem)
                                                                                                                                      else if id == 4 then state == Running(8337,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,8341,Position(index),32],mem)
                                                                                                                                      else if id == 5 then state == Running(8340,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,8341,Position(index),32,23604],mem)
                                                                                                                                      else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(0,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8330,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,Position(index)],mem);
    assert Fetch(code,8330) == Op(91,8331,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(1,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8331,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,Position(index)],mem);
    F.Push2(code,8331);
    assert Fetch(code,8331) == Op(97,8334,8341);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(2,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8334,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,Position(index),8341],mem);
    assert Fetch(code,8334) == Op(144,8335,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(3,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8335,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,8341,Position(index)],mem);
    F.Push1(code,8335);
    assert Fetch(code,8335) == Op(96,8337,32);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(4,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8337,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,8341,Position(index),32],mem);
    F.Push2(code,8337);
    assert Fetch(code,8337) == Op(97,8340,23604);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(5,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23604,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,8341,Position(index),32],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8340,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,8341,Position(index),32,23604],mem);
    assert Fetch(code,8340) == Op(86,8341,0);
  }
  lemma Start(offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,needle,index,word)
    ensures Good(0,Running(8330,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,Position(index)],mem),offset,length,needle,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,needle,index,word)
    ensures state == Running(23604,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,8341,Position(index),32],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 7 && trace[0] == Running(8330,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,Position(index)],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,needle,index,word,mem);
    state := Running(8330,[3904669827,604,offset,length,needle,0,length/32,index,needle,offset,Position(index),length,Position(index)],mem);
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
  }
}
