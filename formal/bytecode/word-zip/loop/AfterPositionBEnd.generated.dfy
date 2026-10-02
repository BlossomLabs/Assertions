// SPDX-License-Identifier: MIT
// Generated pinned zipWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
module BytecodeZipSegmentAfterPositionBEnd {
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
                                              code[2189] == 91 &&
                                              code[2190] == 97 &&
                                              code[2191] == 8 &&
                                              code[2192] == 152 &&
                                              code[2193] == 144 &&
                                              code[2194] == 96 &&
                                              code[2195] == 32 &&
                                              code[2196] == 97 &&
                                              code[2197] == 92 &&
                                              code[2198] == 52 &&
                                              code[2199] == 86 &&
                                              code[23604] == 91
  }
  function Destinations(): set<nat> { {23604} }
  opaque predicate Good(id: nat, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>) { Admitted(a,b,length,index,wordA,wordB) && (
                                                                                                                                          if id == 0 then state == Running(2189,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,Position(index)],mem)
                                                                                                                                          else if id == 1 then state == Running(2190,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,Position(index)],mem)
                                                                                                                                          else if id == 2 then state == Running(2193,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,Position(index),2200],mem)
                                                                                                                                          else if id == 3 then state == Running(2194,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,2200,Position(index)],mem)
                                                                                                                                          else if id == 4 then state == Running(2196,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,2200,Position(index),32],mem)
                                                                                                                                          else if id == 5 then state == Running(2199,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,2200,Position(index),32,23604],mem)
                                                                                                                                          else false) }
  lemma Advance0(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(0,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2189,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,Position(index)],mem);
    assert Fetch(code,2189) == Op(91,2190,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(1,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2190,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,Position(index)],mem);
    F.Push2(code,2190);
    assert Fetch(code,2190) == Op(97,2193,2200);
  }
  lemma Advance2(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(2,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2193,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,Position(index),2200],mem);
    assert Fetch(code,2193) == Op(144,2194,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(3,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2194,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,2200,Position(index)],mem);
    F.Push1(code,2194);
    assert Fetch(code,2194) == Op(96,2196,32);
  }
  lemma Advance4(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(4,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2196,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,2200,Position(index),32],mem);
    F.Push2(code,2196);
    assert Fetch(code,2196) == Op(97,2199,23604);
  }
  lemma Advance5(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(5,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23604,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,2200,Position(index),32],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2199,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,2200,Position(index),32,23604],mem);
    assert Fetch(code,2199) == Op(86,2200,0);
  }
  lemma Start(a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>)
    requires Admitted(a,b,length,index,wordA,wordB)
    ensures Good(0,Running(2189,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,Position(index)],mem),a,b,length,index,wordA,wordB,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB)
    ensures state == Running(23604,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,2200,Position(index),32],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 7 && trace[0] == Running(2189,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,Position(index)],mem) && trace[|trace|-1] == state
  {
    Start(a,b,length,index,wordA,wordB,mem);
    state := Running(2189,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,Position(index)],mem);
    trace := [state];
    Advance0(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(2189,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,Position(index)],mem);
    state := next0;
    Advance1(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(2189,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,Position(index)],mem);
    state := next1;
    Advance2(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(2189,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,Position(index)],mem);
    state := next2;
    Advance3(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(2189,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,Position(index)],mem);
    state := next3;
    Advance4(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(2189,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,Position(index)],mem);
    state := next4;
    Advance5(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(2189,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,b,Position(index),length,Position(index)],mem);
    state := next5;
  }
}
