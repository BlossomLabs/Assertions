// SPDX-License-Identifier: MIT
// Generated pinned unzipWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeUnzipAdmissionDivideZero {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeScanDecoderScalar
  function Count(length: Word, lane: Word): Word { if lane == 0 then (length/32+1)/2 else length/32/2 }
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, lane: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && lane <= 1 && lane == 0 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6069] == 91 &&
                                              code[6070] == 97 &&
                                              code[6071] == 23 &&
                                              code[6072] == 191 &&
                                              code[6073] == 145 &&
                                              code[6074] == 144 &&
                                              code[6075] == 97 &&
                                              code[6076] == 92 &&
                                              code[6077] == 10 &&
                                              code[6078] == 86 &&
                                              code[23562] == 91
  }
  function Destinations(): set<nat> { {23562} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>) { Admitted(offset,length,lane) && (
                                                                                                           if id == 0 then state == Running(6069,[2989505972,518,offset,length,lane,96,length/32,0,2,length/32+1],mem)
                                                                                                           else if id == 1 then state == Running(6070,[2989505972,518,offset,length,lane,96,length/32,0,2,length/32+1],mem)
                                                                                                           else if id == 2 then state == Running(6073,[2989505972,518,offset,length,lane,96,length/32,0,2,length/32+1,6079],mem)
                                                                                                           else if id == 3 then state == Running(6074,[2989505972,518,offset,length,lane,96,length/32,0,6079,length/32+1,2],mem)
                                                                                                           else if id == 4 then state == Running(6075,[2989505972,518,offset,length,lane,96,length/32,0,6079,2,length/32+1],mem)
                                                                                                           else if id == 5 then state == Running(6078,[2989505972,518,offset,length,lane,96,length/32,0,6079,2,length/32+1,23562],mem)
                                                                                                           else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(0,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6069,[2989505972,518,offset,length,lane,96,length/32,0,2,length/32+1],mem);
    assert Fetch(code,6069) == Op(91,6070,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(1,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6070,[2989505972,518,offset,length,lane,96,length/32,0,2,length/32+1],mem);
    F.Push2(code,6070);
    assert Fetch(code,6070) == Op(97,6073,6079);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(2,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6073,[2989505972,518,offset,length,lane,96,length/32,0,2,length/32+1,6079],mem);
    assert Fetch(code,6073) == Op(145,6074,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(3,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6074,[2989505972,518,offset,length,lane,96,length/32,0,6079,length/32+1,2],mem);
    assert Fetch(code,6074) == Op(144,6075,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(4,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6075,[2989505972,518,offset,length,lane,96,length/32,0,6079,2,length/32+1],mem);
    F.Push2(code,6075);
    assert Fetch(code,6075) == Op(97,6078,23562);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(5,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23562,[2989505972,518,offset,length,lane,96,length/32,0,6079,2,length/32+1],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6078,[2989505972,518,offset,length,lane,96,length/32,0,6079,2,length/32+1,23562],mem);
    assert Fetch(code,6078) == Op(86,6079,0);
  }
  lemma Start(offset: Word, length: Word, lane: Word, mem: seq<Byte>)
    requires Admitted(offset,length,lane)
    ensures Good(0,Running(6069,[2989505972,518,offset,length,lane,96,length/32,0,2,length/32+1],mem),offset,length,lane,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,lane)
    ensures state == Running(23562,[2989505972,518,offset,length,lane,96,length/32,0,6079,2,length/32+1],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 7 && trace[0] == Running(6069,[2989505972,518,offset,length,lane,96,length/32,0,2,length/32+1],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,lane,mem);
    state := Running(6069,[2989505972,518,offset,length,lane,96,length/32,0,2,length/32+1],mem);
    trace := [state];
    Advance0(code,state,offset,length,lane,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6069,[2989505972,518,offset,length,lane,96,length/32,0,2,length/32+1],mem);
    state := next0;
    Advance1(code,state,offset,length,lane,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6069,[2989505972,518,offset,length,lane,96,length/32,0,2,length/32+1],mem);
    state := next1;
    Advance2(code,state,offset,length,lane,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6069,[2989505972,518,offset,length,lane,96,length/32,0,2,length/32+1],mem);
    state := next2;
    Advance3(code,state,offset,length,lane,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6069,[2989505972,518,offset,length,lane,96,length/32,0,2,length/32+1],mem);
    state := next3;
    Advance4(code,state,offset,length,lane,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6069,[2989505972,518,offset,length,lane,96,length/32,0,2,length/32+1],mem);
    state := next4;
    Advance5(code,state,offset,length,lane,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6069,[2989505972,518,offset,length,lane,96,length/32,0,2,length/32+1],mem);
    state := next5;
  }
}
