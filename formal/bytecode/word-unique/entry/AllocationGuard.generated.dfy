// SPDX-License-Identifier: MIT
// Generated pinned uniqueWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeUniqueAdmissionAllocationGuard {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeScanDecoderScalar
  function Count(length: Word, ordered: Word): Word { if ordered == 0 then (length/32+1)/2 else length/32/2 }
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, ordered: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && ordered <= 1 && length%32 == 0 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6652] == 91 &&
                                              code[6653] == 130 &&
                                              code[6654] == 96 &&
                                              code[6655] == 1 &&
                                              code[6656] == 96 &&
                                              code[6657] == 1 &&
                                              code[6658] == 96 &&
                                              code[6659] == 64 &&
                                              code[6660] == 27 &&
                                              code[6661] == 3 &&
                                              code[6662] == 129 &&
                                              code[6663] == 17 &&
                                              code[6664] == 21 &&
                                              code[6665] == 97 &&
                                              code[6666] == 26 &&
                                              code[6667] == 20 &&
                                              code[6668] == 87 &&
                                              code[6676] == 91
  }
  function Destinations(): set<nat> { {6676} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>) { Admitted(offset,length,ordered) && (
                                                                                                              if id == 0 then state == Running(6652,[3045624246,518,offset,length,ordered,96],mem)
                                                                                                              else if id == 1 then state == Running(6653,[3045624246,518,offset,length,ordered,96],mem)
                                                                                                              else if id == 2 then state == Running(6654,[3045624246,518,offset,length,ordered,96,length],mem)
                                                                                                              else if id == 3 then state == Running(6656,[3045624246,518,offset,length,ordered,96,length,1],mem)
                                                                                                              else if id == 4 then state == Running(6658,[3045624246,518,offset,length,ordered,96,length,1,1],mem)
                                                                                                              else if id == 5 then state == Running(6660,[3045624246,518,offset,length,ordered,96,length,1,1,64],mem)
                                                                                                              else if id == 6 then state == Running(6661,[3045624246,518,offset,length,ordered,96,length,1,18446744073709551616],mem)
                                                                                                              else if id == 7 then state == Running(6662,[3045624246,518,offset,length,ordered,96,length,18446744073709551615],mem)
                                                                                                              else if id == 8 then state == Running(6663,[3045624246,518,offset,length,ordered,96,length,18446744073709551615,length],mem)
                                                                                                              else if id == 9 then state == Running(6664,[3045624246,518,offset,length,ordered,96,length,0],mem)
                                                                                                              else if id == 10 then state == Running(6665,[3045624246,518,offset,length,ordered,96,length,1],mem)
                                                                                                              else if id == 11 then state == Running(6668,[3045624246,518,offset,length,ordered,96,length,1,6676],mem)
                                                                                                              else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(0,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6652,[3045624246,518,offset,length,ordered,96],mem);
    assert Fetch(code,6652) == Op(91,6653,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(1,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6653,[3045624246,518,offset,length,ordered,96],mem);
    assert Fetch(code,6653) == Op(130,6654,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(2,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6654,[3045624246,518,offset,length,ordered,96,length],mem);
    F.Push1(code,6654);
    assert Fetch(code,6654) == Op(96,6656,1);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(3,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6656,[3045624246,518,offset,length,ordered,96,length,1],mem);
    F.Push1(code,6656);
    assert Fetch(code,6656) == Op(96,6658,1);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(4,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6658,[3045624246,518,offset,length,ordered,96,length,1,1],mem);
    F.Push1(code,6658);
    assert Fetch(code,6658) == Op(96,6660,64);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(5,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6660,[3045624246,518,offset,length,ordered,96,length,1,1,64],mem);
    SC.DecoderLimit();
    assert Fetch(code,6660) == Op(27,6661,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(6,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6661,[3045624246,518,offset,length,ordered,96,length,1,18446744073709551616],mem);
    assert Fetch(code,6661) == Op(3,6662,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(7,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6662,[3045624246,518,offset,length,ordered,96,length,18446744073709551615],mem);
    assert Fetch(code,6662) == Op(129,6663,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(8,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6663,[3045624246,518,offset,length,ordered,96,length,18446744073709551615,length],mem);
    assert Fetch(code,6663) == Op(17,6664,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(9,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6664,[3045624246,518,offset,length,ordered,96,length,0],mem);
    assert Fetch(code,6664) == Op(21,6665,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(10,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6665,[3045624246,518,offset,length,ordered,96,length,1],mem);
    F.Push2(code,6665);
    assert Fetch(code,6665) == Op(97,6668,6676);
  }
  lemma Advance11(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(11,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(6676,[3045624246,518,offset,length,ordered,96,length],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6668,[3045624246,518,offset,length,ordered,96,length,1,6676],mem);
    assert Fetch(code,6668) == Op(87,6669,0);
  }
  lemma Start(offset: Word, length: Word, ordered: Word, mem: seq<Byte>)
    requires Admitted(offset,length,ordered)
    ensures Good(0,Running(6652,[3045624246,518,offset,length,ordered,96],mem),offset,length,ordered,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,ordered)
    ensures state == Running(6676,[3045624246,518,offset,length,ordered,96,length],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 13 && trace[0] == Running(6652,[3045624246,518,offset,length,ordered,96],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,ordered,mem);
    state := Running(6652,[3045624246,518,offset,length,ordered,96],mem);
    trace := [state];
    Advance0(code,state,offset,length,ordered,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6652,[3045624246,518,offset,length,ordered,96],mem);
    state := next0;
    Advance1(code,state,offset,length,ordered,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6652,[3045624246,518,offset,length,ordered,96],mem);
    state := next1;
    Advance2(code,state,offset,length,ordered,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6652,[3045624246,518,offset,length,ordered,96],mem);
    state := next2;
    Advance3(code,state,offset,length,ordered,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6652,[3045624246,518,offset,length,ordered,96],mem);
    state := next3;
    Advance4(code,state,offset,length,ordered,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6652,[3045624246,518,offset,length,ordered,96],mem);
    state := next4;
    Advance5(code,state,offset,length,ordered,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6652,[3045624246,518,offset,length,ordered,96],mem);
    state := next5;
    Advance6(code,state,offset,length,ordered,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6652,[3045624246,518,offset,length,ordered,96],mem);
    state := next6;
    Advance7(code,state,offset,length,ordered,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(6652,[3045624246,518,offset,length,ordered,96],mem);
    state := next7;
    Advance8(code,state,offset,length,ordered,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(6652,[3045624246,518,offset,length,ordered,96],mem);
    state := next8;
    Advance9(code,state,offset,length,ordered,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(6652,[3045624246,518,offset,length,ordered,96],mem);
    state := next9;
    Advance10(code,state,offset,length,ordered,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(6652,[3045624246,518,offset,length,ordered,96],mem);
    state := next10;
    Advance11(code,state,offset,length,ordered,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(6652,[3045624246,518,offset,length,ordered,96],mem);
    state := next11;
  }
}
