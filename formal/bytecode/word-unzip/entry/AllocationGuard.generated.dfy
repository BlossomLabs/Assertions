// SPDX-License-Identifier: MIT
// Generated pinned unzipWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeUnzipAdmissionAllocationGuard {
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
                                              code[6092] == 91 &&
                                              code[6093] == 96 &&
                                              code[6094] == 1 &&
                                              code[6095] == 96 &&
                                              code[6096] == 1 &&
                                              code[6097] == 96 &&
                                              code[6098] == 64 &&
                                              code[6099] == 27 &&
                                              code[6100] == 3 &&
                                              code[6101] == 129 &&
                                              code[6102] == 17 &&
                                              code[6103] == 21 &&
                                              code[6104] == 97 &&
                                              code[6105] == 23 &&
                                              code[6106] == 227 &&
                                              code[6107] == 87 &&
                                              code[6115] == 91
  }
  function Destinations(): set<nat> { {6115} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>) { Admitted(offset,length,lane) && (
                                                                                                           if id == 0 then state == Running(6092,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem)
                                                                                                           else if id == 1 then state == Running(6093,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem)
                                                                                                           else if id == 2 then state == Running(6095,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,1],mem)
                                                                                                           else if id == 3 then state == Running(6097,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,1,1],mem)
                                                                                                           else if id == 4 then state == Running(6099,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,1,1,64],mem)
                                                                                                           else if id == 5 then state == Running(6100,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,1,18446744073709551616],mem)
                                                                                                           else if id == 6 then state == Running(6101,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,18446744073709551615],mem)
                                                                                                           else if id == 7 then state == Running(6102,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,18446744073709551615,Count(length,lane)*32],mem)
                                                                                                           else if id == 8 then state == Running(6103,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,0],mem)
                                                                                                           else if id == 9 then state == Running(6104,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,1],mem)
                                                                                                           else if id == 10 then state == Running(6107,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,1,6115],mem)
                                                                                                           else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(0,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6092,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem);
    assert Fetch(code,6092) == Op(91,6093,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(1,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6093,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem);
    F.Push1(code,6093);
    assert Fetch(code,6093) == Op(96,6095,1);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(2,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6095,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,1],mem);
    F.Push1(code,6095);
    assert Fetch(code,6095) == Op(96,6097,1);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(3,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6097,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,1,1],mem);
    F.Push1(code,6097);
    assert Fetch(code,6097) == Op(96,6099,64);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(4,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6099,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,1,1,64],mem);
    SC.DecoderLimit();
    assert Fetch(code,6099) == Op(27,6100,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(5,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6100,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,1,18446744073709551616],mem);
    assert Fetch(code,6100) == Op(3,6101,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(6,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6101,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,18446744073709551615],mem);
    assert Fetch(code,6101) == Op(129,6102,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(7,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6102,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,18446744073709551615,Count(length,lane)*32],mem);
    assert Fetch(code,6102) == Op(17,6103,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(8,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6103,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,0],mem);
    assert Fetch(code,6103) == Op(21,6104,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(9,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6104,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,1],mem);
    F.Push2(code,6104);
    assert Fetch(code,6104) == Op(97,6107,6115);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(10,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(6115,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6107,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32,1,6115],mem);
    assert Fetch(code,6107) == Op(87,6108,0);
  }
  lemma Start(offset: Word, length: Word, lane: Word, mem: seq<Byte>)
    requires Admitted(offset,length,lane)
    ensures Good(0,Running(6092,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem),offset,length,lane,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,lane)
    ensures state == Running(6115,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 12 && trace[0] == Running(6092,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,lane,mem);
    state := Running(6092,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem);
    trace := [state];
    Advance0(code,state,offset,length,lane,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6092,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem);
    state := next0;
    Advance1(code,state,offset,length,lane,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6092,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem);
    state := next1;
    Advance2(code,state,offset,length,lane,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6092,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem);
    state := next2;
    Advance3(code,state,offset,length,lane,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6092,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem);
    state := next3;
    Advance4(code,state,offset,length,lane,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6092,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem);
    state := next4;
    Advance5(code,state,offset,length,lane,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6092,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem);
    state := next5;
    Advance6(code,state,offset,length,lane,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6092,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem);
    state := next6;
    Advance7(code,state,offset,length,lane,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(6092,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem);
    state := next7;
    Advance8(code,state,offset,length,lane,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(6092,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem);
    state := next8;
    Advance9(code,state,offset,length,lane,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(6092,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem);
    state := next9;
    Advance10(code,state,offset,length,lane,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(6092,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),Count(length,lane)*32],mem);
    state := next10;
  }
}
