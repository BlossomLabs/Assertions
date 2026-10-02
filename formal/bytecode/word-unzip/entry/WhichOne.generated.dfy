// SPDX-License-Identifier: MIT
// Generated pinned unzipWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeUnzipAdmissionWhichOne {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeScanDecoderScalar
  function Count(length: Word, lane: Word): Word { if lane == 0 then (length/32+1)/2 else length/32/2 }
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, lane: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && lane <= 1 && lane == 1 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6031] == 91 &&
                                              code[6032] == 144 &&
                                              code[6033] == 80 &&
                                              code[6034] == 95 &&
                                              code[6035] == 131 &&
                                              code[6036] == 21 &&
                                              code[6037] == 97 &&
                                              code[6038] == 23 &&
                                              code[6039] == 168 &&
                                              code[6040] == 87 &&
                                              code[6041] == 97 &&
                                              code[6042] == 23 &&
                                              code[6043] == 163 &&
                                              code[6044] == 96 &&
                                              code[6045] == 2 &&
                                              code[6046] == 131 &&
                                              code[6047] == 97 &&
                                              code[6048] == 92 &&
                                              code[6049] == 10 &&
                                              code[6050] == 86 &&
                                              code[6056] == 91 &&
                                              code[23562] == 91
  }
  function Destinations(): set<nat> { {6056,23562} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>) { Admitted(offset,length,lane) && (
                                                                                                           if id == 0 then state == Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem)
                                                                                                           else if id == 1 then state == Running(6032,[2989505972,518,offset,length,lane,96,0,length/32],mem)
                                                                                                           else if id == 2 then state == Running(6033,[2989505972,518,offset,length,lane,96,length/32,0],mem)
                                                                                                           else if id == 3 then state == Running(6034,[2989505972,518,offset,length,lane,96,length/32],mem)
                                                                                                           else if id == 4 then state == Running(6035,[2989505972,518,offset,length,lane,96,length/32,0],mem)
                                                                                                           else if id == 5 then state == Running(6036,[2989505972,518,offset,length,lane,96,length/32,0,lane],mem)
                                                                                                           else if id == 6 then state == Running(6037,[2989505972,518,offset,length,lane,96,length/32,0,0],mem)
                                                                                                           else if id == 7 then state == Running(6040,[2989505972,518,offset,length,lane,96,length/32,0,0,6056],mem)
                                                                                                           else if id == 8 then state == Running(6041,[2989505972,518,offset,length,lane,96,length/32,0],mem)
                                                                                                           else if id == 9 then state == Running(6044,[2989505972,518,offset,length,lane,96,length/32,0,6051],mem)
                                                                                                           else if id == 10 then state == Running(6046,[2989505972,518,offset,length,lane,96,length/32,0,6051,2],mem)
                                                                                                           else if id == 11 then state == Running(6047,[2989505972,518,offset,length,lane,96,length/32,0,6051,2,length/32],mem)
                                                                                                           else if id == 12 then state == Running(6050,[2989505972,518,offset,length,lane,96,length/32,0,6051,2,length/32,23562],mem)
                                                                                                           else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(0,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem);
    assert Fetch(code,6031) == Op(91,6032,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(1,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6032,[2989505972,518,offset,length,lane,96,0,length/32],mem);
    assert Fetch(code,6032) == Op(144,6033,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(2,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6033,[2989505972,518,offset,length,lane,96,length/32,0],mem);
    assert Fetch(code,6033) == Op(80,6034,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(3,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6034,[2989505972,518,offset,length,lane,96,length/32],mem);
    assert Fetch(code,6034) == Op(95,6035,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(4,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6035,[2989505972,518,offset,length,lane,96,length/32,0],mem);
    assert Fetch(code,6035) == Op(131,6036,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(5,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6036,[2989505972,518,offset,length,lane,96,length/32,0,lane],mem);
    assert Fetch(code,6036) == Op(21,6037,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(6,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6037,[2989505972,518,offset,length,lane,96,length/32,0,0],mem);
    F.Push2(code,6037);
    assert Fetch(code,6037) == Op(97,6040,6056);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(7,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6040,[2989505972,518,offset,length,lane,96,length/32,0,0,6056],mem);
    assert Fetch(code,6040) == Op(87,6041,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(8,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6041,[2989505972,518,offset,length,lane,96,length/32,0],mem);
    F.Push2(code,6041);
    assert Fetch(code,6041) == Op(97,6044,6051);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(9,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6044,[2989505972,518,offset,length,lane,96,length/32,0,6051],mem);
    F.Push1(code,6044);
    assert Fetch(code,6044) == Op(96,6046,2);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(10,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6046,[2989505972,518,offset,length,lane,96,length/32,0,6051,2],mem);
    assert Fetch(code,6046) == Op(131,6047,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(11,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6047,[2989505972,518,offset,length,lane,96,length/32,0,6051,2,length/32],mem);
    F.Push2(code,6047);
    assert Fetch(code,6047) == Op(97,6050,23562);
  }
  lemma Advance12(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(12,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23562,[2989505972,518,offset,length,lane,96,length/32,0,6051,2,length/32],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6050,[2989505972,518,offset,length,lane,96,length/32,0,6051,2,length/32,23562],mem);
    assert Fetch(code,6050) == Op(86,6051,0);
  }
  lemma Start(offset: Word, length: Word, lane: Word, mem: seq<Byte>)
    requires Admitted(offset,length,lane)
    ensures Good(0,Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem),offset,length,lane,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,lane)
    ensures state == Running(23562,[2989505972,518,offset,length,lane,96,length/32,0,6051,2,length/32],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 14 && trace[0] == Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,lane,mem);
    state := Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem);
    trace := [state];
    Advance0(code,state,offset,length,lane,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem);
    state := next0;
    Advance1(code,state,offset,length,lane,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem);
    state := next1;
    Advance2(code,state,offset,length,lane,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem);
    state := next2;
    Advance3(code,state,offset,length,lane,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem);
    state := next3;
    Advance4(code,state,offset,length,lane,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem);
    state := next4;
    Advance5(code,state,offset,length,lane,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem);
    state := next5;
    Advance6(code,state,offset,length,lane,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem);
    state := next6;
    Advance7(code,state,offset,length,lane,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem);
    state := next7;
    Advance8(code,state,offset,length,lane,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem);
    state := next8;
    Advance9(code,state,offset,length,lane,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem);
    state := next9;
    Advance10(code,state,offset,length,lane,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem);
    state := next10;
    Advance11(code,state,offset,length,lane,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem);
    state := next11;
    Advance12(code,state,offset,length,lane,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(6031,[2989505972,518,offset,length,lane,96,0,length/32],mem);
    state := next12;
  }
}
