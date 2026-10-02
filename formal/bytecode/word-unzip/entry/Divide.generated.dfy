// SPDX-License-Identifier: MIT
// Generated pinned unzipWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeUnzipAdmissionBeginDivide {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeScanDecoderScalar
  function Count(length: Word, lane: Word): Word { if lane == 0 then (length/32+1)/2 else length/32/2 }
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, lane: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && lane <= 1 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6019] == 91 &&
                                              code[6020] == 95 &&
                                              code[6021] == 97 &&
                                              code[6022] == 23 &&
                                              code[6023] == 143 &&
                                              code[6024] == 96 &&
                                              code[6025] == 32 &&
                                              code[6026] == 133 &&
                                              code[6027] == 97 &&
                                              code[6028] == 92 &&
                                              code[6029] == 10 &&
                                              code[6030] == 86 &&
                                              code[23562] == 91
  }
  function Destinations(): set<nat> { {23562} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>) { Admitted(offset,length,lane) && (
                                                                                                           if id == 0 then state == Running(6019,[2989505972,518,offset,length,lane,96],mem)
                                                                                                           else if id == 1 then state == Running(6020,[2989505972,518,offset,length,lane,96],mem)
                                                                                                           else if id == 2 then state == Running(6021,[2989505972,518,offset,length,lane,96,0],mem)
                                                                                                           else if id == 3 then state == Running(6024,[2989505972,518,offset,length,lane,96,0,6031],mem)
                                                                                                           else if id == 4 then state == Running(6026,[2989505972,518,offset,length,lane,96,0,6031,32],mem)
                                                                                                           else if id == 5 then state == Running(6027,[2989505972,518,offset,length,lane,96,0,6031,32,length],mem)
                                                                                                           else if id == 6 then state == Running(6030,[2989505972,518,offset,length,lane,96,0,6031,32,length,23562],mem)
                                                                                                           else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(0,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6019,[2989505972,518,offset,length,lane,96],mem);
    assert Fetch(code,6019) == Op(91,6020,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(1,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6020,[2989505972,518,offset,length,lane,96],mem);
    assert Fetch(code,6020) == Op(95,6021,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(2,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6021,[2989505972,518,offset,length,lane,96,0],mem);
    F.Push2(code,6021);
    assert Fetch(code,6021) == Op(97,6024,6031);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(3,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6024,[2989505972,518,offset,length,lane,96,0,6031],mem);
    F.Push1(code,6024);
    assert Fetch(code,6024) == Op(96,6026,32);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(4,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6026,[2989505972,518,offset,length,lane,96,0,6031,32],mem);
    assert Fetch(code,6026) == Op(133,6027,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(5,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6027,[2989505972,518,offset,length,lane,96,0,6031,32,length],mem);
    F.Push2(code,6027);
    assert Fetch(code,6027) == Op(97,6030,23562);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(6,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23562,[2989505972,518,offset,length,lane,96,0,6031,32,length],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6030,[2989505972,518,offset,length,lane,96,0,6031,32,length,23562],mem);
    assert Fetch(code,6030) == Op(86,6031,0);
  }
  lemma Start(offset: Word, length: Word, lane: Word, mem: seq<Byte>)
    requires Admitted(offset,length,lane)
    ensures Good(0,Running(6019,[2989505972,518,offset,length,lane,96],mem),offset,length,lane,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,lane)
    ensures state == Running(23562,[2989505972,518,offset,length,lane,96,0,6031,32,length],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 8 && trace[0] == Running(6019,[2989505972,518,offset,length,lane,96],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,lane,mem);
    state := Running(6019,[2989505972,518,offset,length,lane,96],mem);
    trace := [state];
    Advance0(code,state,offset,length,lane,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6019,[2989505972,518,offset,length,lane,96],mem);
    state := next0;
    Advance1(code,state,offset,length,lane,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6019,[2989505972,518,offset,length,lane,96],mem);
    state := next1;
    Advance2(code,state,offset,length,lane,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6019,[2989505972,518,offset,length,lane,96],mem);
    state := next2;
    Advance3(code,state,offset,length,lane,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6019,[2989505972,518,offset,length,lane,96],mem);
    state := next3;
    Advance4(code,state,offset,length,lane,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6019,[2989505972,518,offset,length,lane,96],mem);
    state := next4;
    Advance5(code,state,offset,length,lane,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6019,[2989505972,518,offset,length,lane,96],mem);
    state := next5;
    Advance6(code,state,offset,length,lane,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6019,[2989505972,518,offset,length,lane,96],mem);
    state := next6;
  }
}
