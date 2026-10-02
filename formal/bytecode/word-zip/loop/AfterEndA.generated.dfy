// SPDX-License-Identifier: MIT
// Generated pinned zipWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
module BytecodeZipSegmentAfterEndA {
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
                                              code[2139] == 91 &&
                                              code[2140] == 146 &&
                                              code[2141] == 97 &&
                                              code[2142] == 8 &&
                                              code[2143] == 104 &&
                                              code[2144] == 147 &&
                                              code[2145] == 146 &&
                                              code[2146] == 145 &&
                                              code[2147] == 144 &&
                                              code[2148] == 97 &&
                                              code[2149] == 92 &&
                                              code[2150] == 71 &&
                                              code[2151] == 86 &&
                                              code[23623] == 91
  }
  function Destinations(): set<nat> { {23623} }
  opaque predicate Good(id: nat, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>) { Admitted(a,b,length,index,wordA,wordB) && (
                                                                                                                                          if id == 0 then state == Running(2139,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,NextPosition(index)],mem)
                                                                                                                                          else if id == 1 then state == Running(2140,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,NextPosition(index)],mem)
                                                                                                                                          else if id == 2 then state == Running(2141,[269019481,518,a,length,b,length,128,length/32,index,0,NextPosition(index),Position(index),length,a],mem)
                                                                                                                                          else if id == 3 then state == Running(2144,[269019481,518,a,length,b,length,128,length/32,index,0,NextPosition(index),Position(index),length,a,2152],mem)
                                                                                                                                          else if id == 4 then state == Running(2145,[269019481,518,a,length,b,length,128,length/32,index,0,2152,Position(index),length,a,NextPosition(index)],mem)
                                                                                                                                          else if id == 5 then state == Running(2146,[269019481,518,a,length,b,length,128,length/32,index,0,2152,NextPosition(index),length,a,Position(index)],mem)
                                                                                                                                          else if id == 6 then state == Running(2147,[269019481,518,a,length,b,length,128,length/32,index,0,2152,NextPosition(index),Position(index),a,length],mem)
                                                                                                                                          else if id == 7 then state == Running(2148,[269019481,518,a,length,b,length,128,length/32,index,0,2152,NextPosition(index),Position(index),length,a],mem)
                                                                                                                                          else if id == 8 then state == Running(2151,[269019481,518,a,length,b,length,128,length/32,index,0,2152,NextPosition(index),Position(index),length,a,23623],mem)
                                                                                                                                          else false) }
  lemma Advance0(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(0,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2139,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,NextPosition(index)],mem);
    assert Fetch(code,2139) == Op(91,2140,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(1,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2140,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,NextPosition(index)],mem);
    assert Fetch(code,2140) == Op(146,2141,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(2,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2141,[269019481,518,a,length,b,length,128,length/32,index,0,NextPosition(index),Position(index),length,a],mem);
    F.Push2(code,2141);
    assert Fetch(code,2141) == Op(97,2144,2152);
  }
  lemma Advance3(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(3,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2144,[269019481,518,a,length,b,length,128,length/32,index,0,NextPosition(index),Position(index),length,a,2152],mem);
    assert Fetch(code,2144) == Op(147,2145,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(4,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2145,[269019481,518,a,length,b,length,128,length/32,index,0,2152,Position(index),length,a,NextPosition(index)],mem);
    assert Fetch(code,2145) == Op(146,2146,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(5,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2146,[269019481,518,a,length,b,length,128,length/32,index,0,2152,NextPosition(index),length,a,Position(index)],mem);
    assert Fetch(code,2146) == Op(145,2147,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(6,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2147,[269019481,518,a,length,b,length,128,length/32,index,0,2152,NextPosition(index),Position(index),a,length],mem);
    assert Fetch(code,2147) == Op(144,2148,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(7,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2148,[269019481,518,a,length,b,length,128,length/32,index,0,2152,NextPosition(index),Position(index),length,a],mem);
    F.Push2(code,2148);
    assert Fetch(code,2148) == Op(97,2151,23623);
  }
  lemma Advance8(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(8,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23623,[269019481,518,a,length,b,length,128,length/32,index,0,2152,NextPosition(index),Position(index),length,a],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2151,[269019481,518,a,length,b,length,128,length/32,index,0,2152,NextPosition(index),Position(index),length,a,23623],mem);
    assert Fetch(code,2151) == Op(86,2152,0);
  }
  lemma Start(a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>)
    requires Admitted(a,b,length,index,wordA,wordB)
    ensures Good(0,Running(2139,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,NextPosition(index)],mem),a,b,length,index,wordA,wordB,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB)
    ensures state == Running(23623,[269019481,518,a,length,b,length,128,length/32,index,0,2152,NextPosition(index),Position(index),length,a],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 10 && trace[0] == Running(2139,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,NextPosition(index)],mem) && trace[|trace|-1] == state
  {
    Start(a,b,length,index,wordA,wordB,mem);
    state := Running(2139,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,NextPosition(index)],mem);
    trace := [state];
    Advance0(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(2139,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,NextPosition(index)],mem);
    state := next0;
    Advance1(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(2139,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,NextPosition(index)],mem);
    state := next1;
    Advance2(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(2139,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,NextPosition(index)],mem);
    state := next2;
    Advance3(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(2139,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,NextPosition(index)],mem);
    state := next3;
    Advance4(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(2139,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,NextPosition(index)],mem);
    state := next4;
    Advance5(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(2139,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,NextPosition(index)],mem);
    state := next5;
    Advance6(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(2139,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,NextPosition(index)],mem);
    state := next6;
    Advance7(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(2139,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,NextPosition(index)],mem);
    state := next7;
    Advance8(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(2139,[269019481,518,a,length,b,length,128,length/32,index,0,a,Position(index),length,NextPosition(index)],mem);
    state := next8;
  }
}
