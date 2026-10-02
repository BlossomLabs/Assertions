// SPDX-License-Identifier: MIT
// Generated pinned zipWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
module BytecodeZipSegmentGuard {
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
                                              code[2094] == 91 &&
                                              code[2095] == 129 &&
                                              code[2096] == 129 &&
                                              code[2097] == 16 &&
                                              code[2098] == 21 &&
                                              code[2099] == 97 &&
                                              code[2100] == 8 &&
                                              code[2101] == 212 &&
                                              code[2102] == 87 &&
                                              code[2103] == 95 &&
                                              code[2104] == 135 &&
                                              code[2105] == 135 &&
                                              code[2106] == 97 &&
                                              code[2107] == 8 &&
                                              code[2108] == 68 &&
                                              code[2109] == 132 &&
                                              code[2110] == 96 &&
                                              code[2111] == 32 &&
                                              code[2112] == 97 &&
                                              code[2113] == 92 &&
                                              code[2114] == 29 &&
                                              code[2115] == 86 &&
                                              code[2260] == 91 &&
                                              code[23581] == 91
  }
  function Destinations(): set<nat> { {2260,23581} }
  opaque predicate Good(id: nat, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>) { Admitted(a,b,length,index,wordA,wordB) && (
                                                                                                                                          if id == 0 then state == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem)
                                                                                                                                          else if id == 1 then state == Running(2095,[269019481,518,a,length,b,length,128,length/32,index],mem)
                                                                                                                                          else if id == 2 then state == Running(2096,[269019481,518,a,length,b,length,128,length/32,index,length/32],mem)
                                                                                                                                          else if id == 3 then state == Running(2097,[269019481,518,a,length,b,length,128,length/32,index,length/32,index],mem)
                                                                                                                                          else if id == 4 then state == Running(2098,[269019481,518,a,length,b,length,128,length/32,index,1],mem)
                                                                                                                                          else if id == 5 then state == Running(2099,[269019481,518,a,length,b,length,128,length/32,index,0],mem)
                                                                                                                                          else if id == 6 then state == Running(2102,[269019481,518,a,length,b,length,128,length/32,index,0,2260],mem)
                                                                                                                                          else if id == 7 then state == Running(2103,[269019481,518,a,length,b,length,128,length/32,index],mem)
                                                                                                                                          else if id == 8 then state == Running(2104,[269019481,518,a,length,b,length,128,length/32,index,0],mem)
                                                                                                                                          else if id == 9 then state == Running(2105,[269019481,518,a,length,b,length,128,length/32,index,0,a],mem)
                                                                                                                                          else if id == 10 then state == Running(2106,[269019481,518,a,length,b,length,128,length/32,index,0,a,length],mem)
                                                                                                                                          else if id == 11 then state == Running(2109,[269019481,518,a,length,b,length,128,length/32,index,0,a,length,2116],mem)
                                                                                                                                          else if id == 12 then state == Running(2110,[269019481,518,a,length,b,length,128,length/32,index,0,a,length,2116,index],mem)
                                                                                                                                          else if id == 13 then state == Running(2112,[269019481,518,a,length,b,length,128,length/32,index,0,a,length,2116,index,32],mem)
                                                                                                                                          else if id == 14 then state == Running(2115,[269019481,518,a,length,b,length,128,length/32,index,0,a,length,2116,index,32,23581],mem)
                                                                                                                                          else false) }
  lemma Advance0(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(0,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem);
    assert Fetch(code,2094) == Op(91,2095,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(1,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2095,[269019481,518,a,length,b,length,128,length/32,index],mem);
    assert Fetch(code,2095) == Op(129,2096,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(2,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2096,[269019481,518,a,length,b,length,128,length/32,index,length/32],mem);
    assert Fetch(code,2096) == Op(129,2097,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(3,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2097,[269019481,518,a,length,b,length,128,length/32,index,length/32,index],mem);
    assert Fetch(code,2097) == Op(16,2098,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(4,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2098,[269019481,518,a,length,b,length,128,length/32,index,1],mem);
    assert Fetch(code,2098) == Op(21,2099,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(5,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2099,[269019481,518,a,length,b,length,128,length/32,index,0],mem);
    F.Push2(code,2099);
    assert Fetch(code,2099) == Op(97,2102,2260);
  }
  lemma Advance6(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(6,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2102,[269019481,518,a,length,b,length,128,length/32,index,0,2260],mem);
    assert Fetch(code,2102) == Op(87,2103,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(7,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2103,[269019481,518,a,length,b,length,128,length/32,index],mem);
    assert Fetch(code,2103) == Op(95,2104,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(8,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2104,[269019481,518,a,length,b,length,128,length/32,index,0],mem);
    assert Fetch(code,2104) == Op(135,2105,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(9,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2105,[269019481,518,a,length,b,length,128,length/32,index,0,a],mem);
    assert Fetch(code,2105) == Op(135,2106,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(10,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2106,[269019481,518,a,length,b,length,128,length/32,index,0,a,length],mem);
    F.Push2(code,2106);
    assert Fetch(code,2106) == Op(97,2109,2116);
  }
  lemma Advance11(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(11,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2109,[269019481,518,a,length,b,length,128,length/32,index,0,a,length,2116],mem);
    assert Fetch(code,2109) == Op(132,2110,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(12,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2110,[269019481,518,a,length,b,length,128,length/32,index,0,a,length,2116,index],mem);
    F.Push1(code,2110);
    assert Fetch(code,2110) == Op(96,2112,32);
  }
  lemma Advance13(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(13,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,a,b,length,index,wordA,wordB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2112,[269019481,518,a,length,b,length,128,length/32,index,0,a,length,2116,index,32],mem);
    F.Push2(code,2112);
    assert Fetch(code,2112) == Op(97,2115,23581);
  }
  lemma Advance14(code: seq<Byte>, state: State, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB) && Good(14,state,a,b,length,index,wordA,wordB,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23581,[269019481,518,a,length,b,length,128,length/32,index,0,a,length,2116,index,32],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2115,[269019481,518,a,length,b,length,128,length/32,index,0,a,length,2116,index,32,23581],mem);
    assert Fetch(code,2115) == Op(86,2116,0);
  }
  lemma Start(a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>)
    requires Admitted(a,b,length,index,wordA,wordB)
    ensures Good(0,Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem),a,b,length,index,wordA,wordB,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(a,b,length,index,wordA,wordB)
    ensures state == Running(23581,[269019481,518,a,length,b,length,128,length/32,index,0,a,length,2116,index,32],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 16 && trace[0] == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem) && trace[|trace|-1] == state
  {
    Start(a,b,length,index,wordA,wordB,mem);
    state := Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem);
    trace := [state];
    Advance0(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem);
    state := next0;
    Advance1(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem);
    state := next1;
    Advance2(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem);
    state := next2;
    Advance3(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem);
    state := next3;
    Advance4(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem);
    state := next4;
    Advance5(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem);
    state := next5;
    Advance6(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem);
    state := next6;
    Advance7(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem);
    state := next7;
    Advance8(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem);
    state := next8;
    Advance9(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem);
    state := next9;
    Advance10(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem);
    state := next10;
    Advance11(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem);
    state := next11;
    Advance12(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem);
    state := next12;
    Advance13(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem);
    state := next13;
    Advance14(code,state,a,b,length,index,wordA,wordB,mem,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(2094,[269019481,518,a,length,b,length,128,length/32,index],mem);
    state := next14;
  }
}
