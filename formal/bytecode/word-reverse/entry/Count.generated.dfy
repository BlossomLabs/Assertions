// SPDX-License-Identifier: MIT
// Generated pinned reverseWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeReverseAdmissionCount {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeScanDecoderScalar
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[5773] == 91 &&
                                              code[5774] == 144 &&
                                              code[5775] == 80 &&
                                              code[5776] == 130 &&
                                              code[5777] == 96 &&
                                              code[5778] == 1 &&
                                              code[5779] == 96 &&
                                              code[5780] == 1 &&
                                              code[5781] == 96 &&
                                              code[5782] == 64 &&
                                              code[5783] == 27 &&
                                              code[5784] == 3 &&
                                              code[5785] == 129 &&
                                              code[5786] == 17 &&
                                              code[5787] == 21 &&
                                              code[5788] == 97 &&
                                              code[5789] == 22 &&
                                              code[5790] == 167 &&
                                              code[5791] == 87 &&
                                              code[5799] == 91
  }
  function Destinations(): set<nat> { {5799} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, mem: seq<Byte>) { Admitted(offset,length) && (
                                                                                               if id == 0 then state == Running(5773,[2874738232,518,offset,length,96,0,length/32],mem)
                                                                                               else if id == 1 then state == Running(5774,[2874738232,518,offset,length,96,0,length/32],mem)
                                                                                               else if id == 2 then state == Running(5775,[2874738232,518,offset,length,96,length/32,0],mem)
                                                                                               else if id == 3 then state == Running(5776,[2874738232,518,offset,length,96,length/32],mem)
                                                                                               else if id == 4 then state == Running(5777,[2874738232,518,offset,length,96,length/32,length],mem)
                                                                                               else if id == 5 then state == Running(5779,[2874738232,518,offset,length,96,length/32,length,1],mem)
                                                                                               else if id == 6 then state == Running(5781,[2874738232,518,offset,length,96,length/32,length,1,1],mem)
                                                                                               else if id == 7 then state == Running(5783,[2874738232,518,offset,length,96,length/32,length,1,1,64],mem)
                                                                                               else if id == 8 then state == Running(5784,[2874738232,518,offset,length,96,length/32,length,1,18446744073709551616],mem)
                                                                                               else if id == 9 then state == Running(5785,[2874738232,518,offset,length,96,length/32,length,18446744073709551615],mem)
                                                                                               else if id == 10 then state == Running(5786,[2874738232,518,offset,length,96,length/32,length,18446744073709551615,length],mem)
                                                                                               else if id == 11 then state == Running(5787,[2874738232,518,offset,length,96,length/32,length,0],mem)
                                                                                               else if id == 12 then state == Running(5788,[2874738232,518,offset,length,96,length/32,length,1],mem)
                                                                                               else if id == 13 then state == Running(5791,[2874738232,518,offset,length,96,length/32,length,1,5799],mem)
                                                                                               else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(0,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5773,[2874738232,518,offset,length,96,0,length/32],mem);
    assert Fetch(code,5773) == Op(91,5774,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(1,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5774,[2874738232,518,offset,length,96,0,length/32],mem);
    assert Fetch(code,5774) == Op(144,5775,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(2,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5775,[2874738232,518,offset,length,96,length/32,0],mem);
    assert Fetch(code,5775) == Op(80,5776,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(3,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5776,[2874738232,518,offset,length,96,length/32],mem);
    assert Fetch(code,5776) == Op(130,5777,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(4,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5777,[2874738232,518,offset,length,96,length/32,length],mem);
    F.Push1(code,5777);
    assert Fetch(code,5777) == Op(96,5779,1);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(5,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5779,[2874738232,518,offset,length,96,length/32,length,1],mem);
    F.Push1(code,5779);
    assert Fetch(code,5779) == Op(96,5781,1);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(6,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5781,[2874738232,518,offset,length,96,length/32,length,1,1],mem);
    F.Push1(code,5781);
    assert Fetch(code,5781) == Op(96,5783,64);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(7,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5783,[2874738232,518,offset,length,96,length/32,length,1,1,64],mem);
    SC.DecoderLimit();
    assert Fetch(code,5783) == Op(27,5784,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(8,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5784,[2874738232,518,offset,length,96,length/32,length,1,18446744073709551616],mem);
    assert Fetch(code,5784) == Op(3,5785,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(9,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5785,[2874738232,518,offset,length,96,length/32,length,18446744073709551615],mem);
    assert Fetch(code,5785) == Op(129,5786,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(10,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5786,[2874738232,518,offset,length,96,length/32,length,18446744073709551615,length],mem);
    assert Fetch(code,5786) == Op(17,5787,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(11,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5787,[2874738232,518,offset,length,96,length/32,length,0],mem);
    assert Fetch(code,5787) == Op(21,5788,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(12,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5788,[2874738232,518,offset,length,96,length/32,length,1],mem);
    F.Push2(code,5788);
    assert Fetch(code,5788) == Op(97,5791,5799);
  }
  lemma Advance13(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(13,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(5799,[2874738232,518,offset,length,96,length/32,length],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5791,[2874738232,518,offset,length,96,length/32,length,1,5799],mem);
    assert Fetch(code,5791) == Op(87,5792,0);
  }
  lemma Start(offset: Word, length: Word, mem: seq<Byte>)
    requires Admitted(offset,length)
    ensures Good(0,Running(5773,[2874738232,518,offset,length,96,0,length/32],mem),offset,length,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length)
    ensures state == Running(5799,[2874738232,518,offset,length,96,length/32,length],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 15 && trace[0] == Running(5773,[2874738232,518,offset,length,96,0,length/32],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,mem);
    state := Running(5773,[2874738232,518,offset,length,96,0,length/32],mem);
    trace := [state];
    Advance0(code,state,offset,length,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(5773,[2874738232,518,offset,length,96,0,length/32],mem);
    state := next0;
    Advance1(code,state,offset,length,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(5773,[2874738232,518,offset,length,96,0,length/32],mem);
    state := next1;
    Advance2(code,state,offset,length,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(5773,[2874738232,518,offset,length,96,0,length/32],mem);
    state := next2;
    Advance3(code,state,offset,length,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(5773,[2874738232,518,offset,length,96,0,length/32],mem);
    state := next3;
    Advance4(code,state,offset,length,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(5773,[2874738232,518,offset,length,96,0,length/32],mem);
    state := next4;
    Advance5(code,state,offset,length,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(5773,[2874738232,518,offset,length,96,0,length/32],mem);
    state := next5;
    Advance6(code,state,offset,length,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(5773,[2874738232,518,offset,length,96,0,length/32],mem);
    state := next6;
    Advance7(code,state,offset,length,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(5773,[2874738232,518,offset,length,96,0,length/32],mem);
    state := next7;
    Advance8(code,state,offset,length,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(5773,[2874738232,518,offset,length,96,0,length/32],mem);
    state := next8;
    Advance9(code,state,offset,length,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(5773,[2874738232,518,offset,length,96,0,length/32],mem);
    state := next9;
    Advance10(code,state,offset,length,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(5773,[2874738232,518,offset,length,96,0,length/32],mem);
    state := next10;
    Advance11(code,state,offset,length,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(5773,[2874738232,518,offset,length,96,0,length/32],mem);
    state := next11;
    Advance12(code,state,offset,length,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(5773,[2874738232,518,offset,length,96,0,length/32],mem);
    state := next12;
    Advance13(code,state,offset,length,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(5773,[2874738232,518,offset,length,96,0,length/32],mem);
    state := next13;
  }
}
