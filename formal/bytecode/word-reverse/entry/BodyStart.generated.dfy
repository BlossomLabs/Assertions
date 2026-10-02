// SPDX-License-Identifier: MIT
// Generated pinned reverseWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeReverseAdmissionBodyStart {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeScanDecoderScalar
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[5715] == 91 &&
                                              code[5716] == 96 &&
                                              code[5717] == 96 &&
                                              code[5718] == 97 &&
                                              code[5719] == 22 &&
                                              code[5720] == 96 &&
                                              code[5721] == 96 &&
                                              code[5722] == 32 &&
                                              code[5723] == 131 &&
                                              code[5724] == 97 &&
                                              code[5725] == 91 &&
                                              code[5726] == 227 &&
                                              code[5727] == 86 &&
                                              code[23523] == 91
  }
  function Destinations(): set<nat> { {23523} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, mem: seq<Byte>) { Admitted(offset,length) && (
                                                                                               if id == 0 then state == Running(5715,[2874738232,518,offset,length],mem)
                                                                                               else if id == 1 then state == Running(5716,[2874738232,518,offset,length],mem)
                                                                                               else if id == 2 then state == Running(5718,[2874738232,518,offset,length,96],mem)
                                                                                               else if id == 3 then state == Running(5721,[2874738232,518,offset,length,96,5728],mem)
                                                                                               else if id == 4 then state == Running(5723,[2874738232,518,offset,length,96,5728,32],mem)
                                                                                               else if id == 5 then state == Running(5724,[2874738232,518,offset,length,96,5728,32,length],mem)
                                                                                               else if id == 6 then state == Running(5727,[2874738232,518,offset,length,96,5728,32,length,23523],mem)
                                                                                               else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(0,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5715,[2874738232,518,offset,length],mem);
    assert Fetch(code,5715) == Op(91,5716,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(1,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5716,[2874738232,518,offset,length],mem);
    F.Push1(code,5716);
    assert Fetch(code,5716) == Op(96,5718,96);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(2,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5718,[2874738232,518,offset,length,96],mem);
    F.Push2(code,5718);
    assert Fetch(code,5718) == Op(97,5721,5728);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(3,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5721,[2874738232,518,offset,length,96,5728],mem);
    F.Push1(code,5721);
    assert Fetch(code,5721) == Op(96,5723,32);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(4,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5723,[2874738232,518,offset,length,96,5728,32],mem);
    assert Fetch(code,5723) == Op(131,5724,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(5,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5724,[2874738232,518,offset,length,96,5728,32,length],mem);
    F.Push2(code,5724);
    assert Fetch(code,5724) == Op(97,5727,23523);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(6,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23523,[2874738232,518,offset,length,96,5728,32,length],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5727,[2874738232,518,offset,length,96,5728,32,length,23523],mem);
    assert Fetch(code,5727) == Op(86,5728,0);
  }
  lemma Start(offset: Word, length: Word, mem: seq<Byte>)
    requires Admitted(offset,length)
    ensures Good(0,Running(5715,[2874738232,518,offset,length],mem),offset,length,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length)
    ensures state == Running(23523,[2874738232,518,offset,length,96,5728,32,length],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 8 && trace[0] == Running(5715,[2874738232,518,offset,length],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,mem);
    state := Running(5715,[2874738232,518,offset,length],mem);
    trace := [state];
    Advance0(code,state,offset,length,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(5715,[2874738232,518,offset,length],mem);
    state := next0;
    Advance1(code,state,offset,length,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(5715,[2874738232,518,offset,length],mem);
    state := next1;
    Advance2(code,state,offset,length,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(5715,[2874738232,518,offset,length],mem);
    state := next2;
    Advance3(code,state,offset,length,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(5715,[2874738232,518,offset,length],mem);
    state := next3;
    Advance4(code,state,offset,length,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(5715,[2874738232,518,offset,length],mem);
    state := next4;
    Advance5(code,state,offset,length,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(5715,[2874738232,518,offset,length],mem);
    state := next5;
    Advance6(code,state,offset,length,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(5715,[2874738232,518,offset,length],mem);
    state := next6;
  }
}
