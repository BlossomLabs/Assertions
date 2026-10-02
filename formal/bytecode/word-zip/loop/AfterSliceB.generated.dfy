// SPDX-License-Identifier: MIT
// Generated pinned zipWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
module BytecodeZipSegmentAfterSliceB {
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
                                              code[2213] == 91 &&
                                              code[2214] == 97 &&
                                              code[2215] == 8 &&
                                              code[2216] == 174 &&
                                              code[2217] == 145 &&
                                              code[2218] == 97 &&
                                              code[2219] == 92 &&
                                              code[2220] == 110 &&
                                              code[2221] == 86 &&
                                              code[23662] == 91
  }
  function Destinations(): set<nat> { {23662} }
  opaque predicate Good(id: nat, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>) { Admitted(a,b,length,index,wordA,wordB) && (
                                                                                                                                          if id == 0 then state == Running(2213,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,WordOffset(b,index),32],mem)
                                                                                                                                          else if id == 1 then state == Running(2214,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,WordOffset(b,index),32],mem)
                                                                                                                                          else if id == 2 then state == Running(2217,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,WordOffset(b,index),32,2222],mem)
                                                                                                                                          else if id == 3 then state == Running(2218,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,2222,32,WordOffset(b,index)],mem)
                                                                                                                                          else if id == 4 then state == Running(2221,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,2222,32,WordOffset(b,index),23662],mem)
                                                                                                                                          else false) }
  lemma Advance0(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(0,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2213,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,WordOffset(b,index),32],mem);
    assert Fetch(code,2213) == Op(91,2214,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(1,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2214,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,WordOffset(b,index),32],mem);
    F.Push2(code,2214);
    assert Fetch(code,2214) == Op(97,2217,2222);
  }
  lemma Advance2(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(2,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2217,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,WordOffset(b,index),32,2222],mem);
    assert Fetch(code,2217) == Op(145,2218,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(3,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2218,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,2222,32,WordOffset(b,index)],mem);
    F.Push2(code,2218);
    assert Fetch(code,2218) == Op(97,2221,23662);
  }
  lemma Advance4(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(4,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23662,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,2222,32,WordOffset(b,index)],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2221,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,2222,32,WordOffset(b,index),23662],mem);
    assert Fetch(code,2221) == Op(86,2222,0);
  }
  lemma Start(a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>)
    requires Admitted(a,b,length,index,wordA,wordB)
    ensures Good(0,Running(2213,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,WordOffset(b,index),32],mem),a,b,length,index,wordA,wordB,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB)
    ensures state == Running(23662,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,2222,32,WordOffset(b,index)],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 6 && trace[0] == Running(2213,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,WordOffset(b,index),32],mem) && trace[|trace|-1] == state
  {
    Start(a,b,length,index,wordA,wordB,mem);
    state := Running(2213,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,WordOffset(b,index),32],mem);
    trace := [state];
    Advance0(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(2213,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,WordOffset(b,index),32],mem);
    state := next0;
    Advance1(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(2213,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,WordOffset(b,index),32],mem);
    state := next1;
    Advance2(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(2213,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,WordOffset(b,index),32],mem);
    state := next2;
    Advance3(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(2213,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,WordOffset(b,index),32],mem);
    state := next3;
    Advance4(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(2213,[269019481,518,a,length,b,length,128,length/32,index,wordA,0,WordOffset(b,index),32],mem);
    state := next4;
  }
}
