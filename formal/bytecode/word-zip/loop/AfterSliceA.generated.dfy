// SPDX-License-Identifier: MIT
// Generated pinned zipWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
module BytecodeZipSegmentAfterSliceA {
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
                                              code[2152] == 91 &&
                                              code[2153] == 97 &&
                                              code[2154] == 8 &&
                                              code[2155] == 113 &&
                                              code[2156] == 145 &&
                                              code[2157] == 97 &&
                                              code[2158] == 92 &&
                                              code[2159] == 110 &&
                                              code[2160] == 86 &&
                                              code[23662] == 91
  }
  function Destinations(): set<nat> { {23662} }
  opaque predicate Good(id: nat, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>) { Admitted(a,b,length,index,wordA,wordB) && (
                                                                                                                                          if id == 0 then state == Running(2152,[269019481,518,a,length,b,length,128,length/32,index,0,WordOffset(a,index),32],mem)
                                                                                                                                          else if id == 1 then state == Running(2153,[269019481,518,a,length,b,length,128,length/32,index,0,WordOffset(a,index),32],mem)
                                                                                                                                          else if id == 2 then state == Running(2156,[269019481,518,a,length,b,length,128,length/32,index,0,WordOffset(a,index),32,2161],mem)
                                                                                                                                          else if id == 3 then state == Running(2157,[269019481,518,a,length,b,length,128,length/32,index,0,2161,32,WordOffset(a,index)],mem)
                                                                                                                                          else if id == 4 then state == Running(2160,[269019481,518,a,length,b,length,128,length/32,index,0,2161,32,WordOffset(a,index),23662],mem)
                                                                                                                                          else false) }
  lemma Advance0(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(0,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2152,[269019481,518,a,length,b,length,128,length/32,index,0,WordOffset(a,index),32],mem);
    assert Fetch(code,2152) == Op(91,2153,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(1,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2153,[269019481,518,a,length,b,length,128,length/32,index,0,WordOffset(a,index),32],mem);
    F.Push2(code,2153);
    assert Fetch(code,2153) == Op(97,2156,2161);
  }
  lemma Advance2(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(2,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2156,[269019481,518,a,length,b,length,128,length/32,index,0,WordOffset(a,index),32,2161],mem);
    assert Fetch(code,2156) == Op(145,2157,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(3,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2157,[269019481,518,a,length,b,length,128,length/32,index,0,2161,32,WordOffset(a,index)],mem);
    F.Push2(code,2157);
    assert Fetch(code,2157) == Op(97,2160,23662);
  }
  lemma Advance4(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(4,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23662,[269019481,518,a,length,b,length,128,length/32,index,0,2161,32,WordOffset(a,index)],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2160,[269019481,518,a,length,b,length,128,length/32,index,0,2161,32,WordOffset(a,index),23662],mem);
    assert Fetch(code,2160) == Op(86,2161,0);
  }
  lemma Start(a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>)
    requires Admitted(a,b,length,index,wordA,wordB)
    ensures Good(0,Running(2152,[269019481,518,a,length,b,length,128,length/32,index,0,WordOffset(a,index),32],mem),a,b,length,index,wordA,wordB,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB)
    ensures state == Running(23662,[269019481,518,a,length,b,length,128,length/32,index,0,2161,32,WordOffset(a,index)],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 6 && trace[0] == Running(2152,[269019481,518,a,length,b,length,128,length/32,index,0,WordOffset(a,index),32],mem) && trace[|trace|-1] == state
  {
    Start(a,b,length,index,wordA,wordB,mem);
    state := Running(2152,[269019481,518,a,length,b,length,128,length/32,index,0,WordOffset(a,index),32],mem);
    trace := [state];
    Advance0(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(2152,[269019481,518,a,length,b,length,128,length/32,index,0,WordOffset(a,index),32],mem);
    state := next0;
    Advance1(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(2152,[269019481,518,a,length,b,length,128,length/32,index,0,WordOffset(a,index),32],mem);
    state := next1;
    Advance2(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(2152,[269019481,518,a,length,b,length,128,length/32,index,0,WordOffset(a,index),32],mem);
    state := next2;
    Advance3(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(2152,[269019481,518,a,length,b,length,128,length/32,index,0,WordOffset(a,index),32],mem);
    state := next3;
    Advance4(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(2152,[269019481,518,a,length,b,length,128,length/32,index,0,WordOffset(a,index),32],mem);
    state := next4;
  }
}
