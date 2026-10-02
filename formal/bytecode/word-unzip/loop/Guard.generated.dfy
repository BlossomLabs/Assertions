// SPDX-License-Identifier: MIT
// Generated pinned unzipWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeUnzipSegmentGuard {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeUnzipLoopScalar
  function Count(length: Word, lane: Word): Word { if lane == 0 then (length/32+1)/2 else length/32/2 }
  function Twice(index: Word): Word { ((index as nat)*2)%G.Modulus() }
  function SourceIndex(index: Word, lane: Word): Word { ((index as nat)*2+(lane as nat))%G.Modulus() }
  function Position(index: Word, lane: Word): Word { (((index as nat)*2+(lane as nat))*32)%G.Modulus() }
  function NextPosition(index: Word, lane: Word): Word { (((index as nat)*2+(lane as nat))*32+32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word, lane: Word): Word { ((offset as nat)+((index as nat)*2+(lane as nat))*32)%G.Modulus() }
  function Target(index: Word): Word { (160+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, lane: Word, index: Word, word: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && lane <= 1 && index <= Count(length,lane) && index < Count(length,lane) }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6162] == 91 &&
                                              code[6163] == 129 &&
                                              code[6164] == 129 &&
                                              code[6165] == 16 &&
                                              code[6166] == 21 &&
                                              code[6167] == 97 &&
                                              code[6168] == 24 &&
                                              code[6169] == 147 &&
                                              code[6170] == 87 &&
                                              code[6171] == 95 &&
                                              code[6172] == 135 &&
                                              code[6173] == 135 &&
                                              code[6174] == 135 &&
                                              code[6175] == 97 &&
                                              code[6176] == 24 &&
                                              code[6177] == 41 &&
                                              code[6178] == 133 &&
                                              code[6179] == 96 &&
                                              code[6180] == 2 &&
                                              code[6181] == 97 &&
                                              code[6182] == 92 &&
                                              code[6183] == 29 &&
                                              code[6184] == 86 &&
                                              code[6291] == 91 &&
                                              code[23581] == 91
  }
  function Destinations(): set<nat> { {6291,23581} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,lane,index,word) && (
                                                                                                                                    if id == 0 then state == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem)
                                                                                                                                    else if id == 1 then state == Running(6163,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem)
                                                                                                                                    else if id == 2 then state == Running(6164,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,Count(length,lane)],mem)
                                                                                                                                    else if id == 3 then state == Running(6165,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,Count(length,lane),index],mem)
                                                                                                                                    else if id == 4 then state == Running(6166,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,1],mem)
                                                                                                                                    else if id == 5 then state == Running(6167,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0],mem)
                                                                                                                                    else if id == 6 then state == Running(6170,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6291],mem)
                                                                                                                                    else if id == 7 then state == Running(6171,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem)
                                                                                                                                    else if id == 8 then state == Running(6172,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0],mem)
                                                                                                                                    else if id == 9 then state == Running(6173,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset],mem)
                                                                                                                                    else if id == 10 then state == Running(6174,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length],mem)
                                                                                                                                    else if id == 11 then state == Running(6175,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,lane],mem)
                                                                                                                                    else if id == 12 then state == Running(6178,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,lane,6185],mem)
                                                                                                                                    else if id == 13 then state == Running(6179,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,lane,6185,index],mem)
                                                                                                                                    else if id == 14 then state == Running(6181,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,lane,6185,index,2],mem)
                                                                                                                                    else if id == 15 then state == Running(6184,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,lane,6185,index,2,23581],mem)
                                                                                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(0,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    assert Fetch(code,6162) == Op(91,6163,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(1,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6163,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    assert Fetch(code,6163) == Op(129,6164,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(2,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6164,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,Count(length,lane)],mem);
    assert Fetch(code,6164) == Op(129,6165,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(3,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6165,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,Count(length,lane),index],mem);
    assert Fetch(code,6165) == Op(16,6166,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(4,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6166,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,1],mem);
    assert Fetch(code,6166) == Op(21,6167,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(5,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6167,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0],mem);
    F.Push2(code,6167);
    assert Fetch(code,6167) == Op(97,6170,6291);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(6,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6170,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6291],mem);
    assert Fetch(code,6170) == Op(87,6171,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(7,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6171,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    assert Fetch(code,6171) == Op(95,6172,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(8,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6172,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0],mem);
    assert Fetch(code,6172) == Op(135,6173,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(9,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6173,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset],mem);
    assert Fetch(code,6173) == Op(135,6174,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(10,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6174,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length],mem);
    assert Fetch(code,6174) == Op(135,6175,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(11,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6175,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,lane],mem);
    F.Push2(code,6175);
    assert Fetch(code,6175) == Op(97,6178,6185);
  }
  lemma Advance12(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(12,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6178,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,lane,6185],mem);
    assert Fetch(code,6178) == Op(133,6179,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(13,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6179,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,lane,6185,index],mem);
    F.Push1(code,6179);
    assert Fetch(code,6179) == Op(96,6181,2);
  }
  lemma Advance14(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(14,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6181,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,lane,6185,index,2],mem);
    F.Push2(code,6181);
    assert Fetch(code,6181) == Op(97,6184,23581);
  }
  lemma Advance15(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(15,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23581,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,lane,6185,index,2],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6184,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,lane,6185,index,2,23581],mem);
    assert Fetch(code,6184) == Op(86,6185,0);
  }
  lemma Start(offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,lane,index,word)
    ensures Good(0,Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem),offset,length,lane,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,lane,index,word)
    ensures state == Running(23581,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,lane,6185,index,2],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 17 && trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,lane,index,word,mem);
    state := Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    trace := [state];
    Advance0(code,state,offset,length,lane,index,word,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    state := next0;
    Advance1(code,state,offset,length,lane,index,word,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    state := next1;
    Advance2(code,state,offset,length,lane,index,word,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    state := next2;
    Advance3(code,state,offset,length,lane,index,word,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    state := next3;
    Advance4(code,state,offset,length,lane,index,word,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    state := next4;
    Advance5(code,state,offset,length,lane,index,word,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    state := next5;
    Advance6(code,state,offset,length,lane,index,word,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    state := next6;
    Advance7(code,state,offset,length,lane,index,word,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    state := next7;
    Advance8(code,state,offset,length,lane,index,word,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    state := next8;
    Advance9(code,state,offset,length,lane,index,word,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    state := next9;
    Advance10(code,state,offset,length,lane,index,word,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    state := next10;
    Advance11(code,state,offset,length,lane,index,word,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    state := next11;
    Advance12(code,state,offset,length,lane,index,word,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    state := next12;
    Advance13(code,state,offset,length,lane,index,word,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    state := next13;
    Advance14(code,state,offset,length,lane,index,word,mem,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    state := next14;
    Advance15(code,state,offset,length,lane,index,word,mem,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],mem);
    state := next15;
  }
}
