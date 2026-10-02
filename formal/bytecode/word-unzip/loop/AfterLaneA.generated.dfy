// SPDX-License-Identifier: MIT
// Generated pinned unzipWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeUnzipSegmentAfterLaneA {
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
                                              code[6195] == 91 &&
                                              code[6196] == 97 &&
                                              code[6197] == 24 &&
                                              code[6198] == 62 &&
                                              code[6199] == 144 &&
                                              code[6200] == 96 &&
                                              code[6201] == 32 &&
                                              code[6202] == 97 &&
                                              code[6203] == 92 &&
                                              code[6204] == 29 &&
                                              code[6205] == 86 &&
                                              code[23581] == 91
  }
  function Destinations(): set<nat> { {23581} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,lane,index,word) && (
                                                                                                                                    if id == 0 then state == Running(6195,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,SourceIndex(index,lane)],mem)
                                                                                                                                    else if id == 1 then state == Running(6196,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,SourceIndex(index,lane)],mem)
                                                                                                                                    else if id == 2 then state == Running(6199,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,SourceIndex(index,lane),6206],mem)
                                                                                                                                    else if id == 3 then state == Running(6200,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,6206,SourceIndex(index,lane)],mem)
                                                                                                                                    else if id == 4 then state == Running(6202,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,6206,SourceIndex(index,lane),32],mem)
                                                                                                                                    else if id == 5 then state == Running(6205,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,6206,SourceIndex(index,lane),32,23581],mem)
                                                                                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(0,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6195,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,SourceIndex(index,lane)],mem);
    assert Fetch(code,6195) == Op(91,6196,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(1,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6196,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,SourceIndex(index,lane)],mem);
    F.Push2(code,6196);
    assert Fetch(code,6196) == Op(97,6199,6206);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(2,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6199,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,SourceIndex(index,lane),6206],mem);
    assert Fetch(code,6199) == Op(144,6200,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(3,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6200,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,6206,SourceIndex(index,lane)],mem);
    F.Push1(code,6200);
    assert Fetch(code,6200) == Op(96,6202,32);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(4,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6202,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,6206,SourceIndex(index,lane),32],mem);
    F.Push2(code,6202);
    assert Fetch(code,6202) == Op(97,6205,23581);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(5,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23581,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,6206,SourceIndex(index,lane),32],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6205,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,6206,SourceIndex(index,lane),32,23581],mem);
    assert Fetch(code,6205) == Op(86,6206,0);
  }
  lemma Start(offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,lane,index,word)
    ensures Good(0,Running(6195,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,SourceIndex(index,lane)],mem),offset,length,lane,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,lane,index,word)
    ensures state == Running(23581,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,6206,SourceIndex(index,lane),32],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 7 && trace[0] == Running(6195,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,SourceIndex(index,lane)],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,lane,index,word,mem);
    state := Running(6195,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,SourceIndex(index,lane)],mem);
    trace := [state];
    Advance0(code,state,offset,length,lane,index,word,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6195,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,SourceIndex(index,lane)],mem);
    state := next0;
    Advance1(code,state,offset,length,lane,index,word,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6195,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,SourceIndex(index,lane)],mem);
    state := next1;
    Advance2(code,state,offset,length,lane,index,word,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6195,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,SourceIndex(index,lane)],mem);
    state := next2;
    Advance3(code,state,offset,length,lane,index,word,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6195,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,SourceIndex(index,lane)],mem);
    state := next3;
    Advance4(code,state,offset,length,lane,index,word,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6195,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,SourceIndex(index,lane)],mem);
    state := next4;
    Advance5(code,state,offset,length,lane,index,word,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6195,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,length,SourceIndex(index,lane)],mem);
    state := next5;
  }
}
