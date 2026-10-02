// SPDX-License-Identifier: MIT
// Generated pinned zipWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
module BytecodeZipSegmentAfterReadA {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { ((index as nat)*32+32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  function TargetA(index: Word): Word { (160+(index as nat)*64)%G.Modulus() }
  function TargetB(index: Word): Word { (192+(index as nat)*64)%G.Modulus() }
  predicate Admitted(a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word) { length < 0x8000000000000000 && (a as nat)+(length as nat) < G.Modulus() && (b as nat)+(length as nat) < G.Modulus() && length%32 == 0 && index <= length/32 && index < length/32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[2161] == 91 &&
                                              code[2162] == 144 &&
                                              code[2163] == 80 &&
                                              code[2164] == 95 &&
                                              code[2165] == 134 &&
                                              code[2166] == 134 &&
                                              code[2167] == 97 &&
                                              code[2168] == 8 &&
                                              code[2169] == 129 &&
                                              code[2170] == 133 &&
                                              code[2171] == 96 &&
                                              code[2172] == 32 &&
                                              code[2173] == 97 &&
                                              code[2174] == 92 &&
                                              code[2175] == 29 &&
                                              code[2176] == 86 &&
                                              code[23581] == 91
  }
  function Destinations(): set<nat> { {23581} }
  opaque predicate Good(id: nat, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>) { Admitted(a,b,length,index,wordA,wordB) && (
                                                                                                                                          if id == 0 then state == Running(2161,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem)
                                                                                                                                          else if id == 1 then state == Running(2162,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem)
                                                                                                                                          else if id == 2 then state == Running(2163,[269019481,518,a,length,b,length,128,length/32,index,wordA,0],mem)
                                                                                                                                          else if id == 3 then state == Running(2164,[269019481,518,a,length,b,length,128,length/32,index,wordA],mem)
                                                                                                                                          else if id == 4 then state == Running(2165,[269019481,518,a,length,b,length,128,length/32,index,wordA,0],mem)
                                                                                                                                          else if id == 5 then state == Running(2166,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b],mem)
                                                                                                                                          else if id == 6 then state == Running(2167,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,length],mem)
                                                                                                                                          else if id == 7 then state == Running(2170,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,length,2177],mem)
                                                                                                                                          else if id == 8 then state == Running(2171,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,length,2177,index],mem)
                                                                                                                                          else if id == 9 then state == Running(2173,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,length,2177,index,32],mem)
                                                                                                                                          else if id == 10 then state == Running(2176,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,length,2177,index,32,23581],mem)
                                                                                                                                          else false) }
  lemma Advance0(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(0,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2161,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem);
    assert Fetch(code,2161) == Op(91,2162,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(1,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2162,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem);
    assert Fetch(code,2162) == Op(144,2163,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(2,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2163,[269019481,518,a,length,b,length,128,length/32,index,wordA,0],mem);
    assert Fetch(code,2163) == Op(80,2164,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(3,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2164,[269019481,518,a,length,b,length,128,length/32,index,wordA],mem);
    assert Fetch(code,2164) == Op(95,2165,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(4,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2165,[269019481,518,a,length,b,length,128,length/32,index,wordA,0],mem);
    assert Fetch(code,2165) == Op(134,2166,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(5,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2166,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b],mem);
    assert Fetch(code,2166) == Op(134,2167,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(6,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2167,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,length],mem);
    F.Push2(code,2167);
    assert Fetch(code,2167) == Op(97,2170,2177);
  }
  lemma Advance7(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(7,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2170,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,length,2177],mem);
    assert Fetch(code,2170) == Op(133,2171,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(8,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2171,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,length,2177,index],mem);
    F.Push1(code,2171);
    assert Fetch(code,2171) == Op(96,2173,32);
  }
  lemma Advance9(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(9,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2173,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,length,2177,index,32],mem);
    F.Push2(code,2173);
    assert Fetch(code,2173) == Op(97,2176,23581);
  }
  lemma Advance10(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(10,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23581,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,length,2177,index,32],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2176,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,length,2177,index,32,23581],mem);
    assert Fetch(code,2176) == Op(86,2177,0);
  }
  lemma Start(a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>)
    requires Admitted(a,b,length,index,wordA,wordB)
    ensures Good(0,Running(2161,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem),a,b,length,index,wordA,wordB,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB)
    ensures state == Running(23581,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,length,2177,index,32],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 12 && trace[0] == Running(2161,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem) && trace[|trace|-1] == state
  {
    Start(a,b,length,index,wordA,wordB,mem);
    state := Running(2161,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem);
    trace := [state];
    Advance0(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(2161,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem);
    state := next0;
    Advance1(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(2161,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem);
    state := next1;
    Advance2(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(2161,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem);
    state := next2;
    Advance3(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(2161,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem);
    state := next3;
    Advance4(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(2161,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem);
    state := next4;
    Advance5(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(2161,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem);
    state := next5;
    Advance6(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(2161,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem);
    state := next6;
    Advance7(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(2161,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem);
    state := next7;
    Advance8(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(2161,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem);
    state := next8;
    Advance9(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(2161,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem);
    state := next9;
    Advance10(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(2161,[269019481,518,a,length,b,length,128,length/32,index,0,wordA],mem);
    state := next10;
  }
}
