// SPDX-License-Identifier: MIT
// Generated pinned zipWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
module BytecodeZipSegmentAfterPositionAEnd {
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
                                              code[2128] == 91 &&
                                              code[2129] == 97 &&
                                              code[2130] == 8 &&
                                              code[2131] == 91 &&
                                              code[2132] == 144 &&
                                              code[2133] == 96 &&
                                              code[2134] == 32 &&
                                              code[2135] == 97 &&
                                              code[2136] == 92 &&
                                              code[2137] == 52 &&
                                              code[2138] == 86 &&
                                              code[23604] == 91
  }
  function Destinations(): set<nat> { {23604} }
  opaque predicate Good(id: nat, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>) { Admitted(a,b,length,index,wordA,wordB) && (
                                                                                                                                          if id == 0 then state == Running(2128,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,Position(index)],mem)
                                                                                                                                          else if id == 1 then state == Running(2129,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,Position(index)],mem)
                                                                                                                                          else if id == 2 then state == Running(2132,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,Position(index),2139],mem)
                                                                                                                                          else if id == 3 then state == Running(2133,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,2139,Position(index)],mem)
                                                                                                                                          else if id == 4 then state == Running(2135,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,2139,Position(index),32],mem)
                                                                                                                                          else if id == 5 then state == Running(2138,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,2139,Position(index),32,23604],mem)
                                                                                                                                          else false) }
  lemma Advance0(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(0,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2128,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,Position(index)],mem);
    assert Fetch(code,2128) == Op(91,2129,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(1,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2129,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,Position(index)],mem);
    F.Push2(code,2129);
    assert Fetch(code,2129) == Op(97,2132,2139);
  }
  lemma Advance2(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(2,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2132,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,Position(index),2139],mem);
    assert Fetch(code,2132) == Op(144,2133,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(3,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2133,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,2139,Position(index)],mem);
    F.Push1(code,2133);
    assert Fetch(code,2133) == Op(96,2135,32);
  }
  lemma Advance4(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(4,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2135,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,2139,Position(index),32],mem);
    F.Push2(code,2135);
    assert Fetch(code,2135) == Op(97,2138,23604);
  }
  lemma Advance5(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(5,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23604,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,2139,Position(index),32],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2138,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,2139,Position(index),32,23604],mem);
    assert Fetch(code,2138) == Op(86,2139,0);
  }
  lemma Start(a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>)
    requires Admitted(a,b,length,index,wordA,wordB)
    ensures Good(0,Running(2128,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,Position(index)],mem),a,b,length,index,wordA,wordB,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB)
    ensures state == Running(23604,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,2139,Position(index),32],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 7 && trace[0] == Running(2128,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,Position(index)],mem) && trace[|trace|-1] == state
  {
    Start(a,b,length,index,wordA,wordB,mem);
    state := Running(2128,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,Position(index)],mem);
    trace := [state];
    Advance0(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(2128,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,Position(index)],mem);
    state := next0;
    Advance1(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(2128,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,Position(index)],mem);
    state := next1;
    Advance2(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(2128,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,Position(index)],mem);
    state := next2;
    Advance3(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(2128,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,Position(index)],mem);
    state := next3;
    Advance4(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(2128,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,Position(index)],mem);
    state := next4;
    Advance5(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(2128,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,Position(index)],mem);
    state := next5;
  }
}
