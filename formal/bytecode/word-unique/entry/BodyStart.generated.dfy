// SPDX-License-Identifier: MIT
// Generated pinned uniqueWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeUniqueAdmissionBodyStart {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeScanDecoderScalar
  function Count(length: Word, ordered: Word): Word { if ordered == 0 then (length/32+1)/2 else length/32/2 }
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, ordered: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && ordered <= 1 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6606] == 91 &&
                                              code[6607] == 96 &&
                                              code[6608] == 96 &&
                                              code[6609] == 97 &&
                                              code[6610] == 25 &&
                                              code[6611] == 219 &&
                                              code[6612] == 96 &&
                                              code[6613] == 32 &&
                                              code[6614] == 132 &&
                                              code[6615] == 97 &&
                                              code[6616] == 91 &&
                                              code[6617] == 227 &&
                                              code[6618] == 86 &&
                                              code[23523] == 91
  }
  function Destinations(): set<nat> { {23523} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>) { Admitted(offset,length,ordered) && (
                                                                                                              if id == 0 then state == Running(6606,[3045624246,518,offset,length,ordered],mem)
                                                                                                              else if id == 1 then state == Running(6607,[3045624246,518,offset,length,ordered],mem)
                                                                                                              else if id == 2 then state == Running(6609,[3045624246,518,offset,length,ordered,96],mem)
                                                                                                              else if id == 3 then state == Running(6612,[3045624246,518,offset,length,ordered,96,6619],mem)
                                                                                                              else if id == 4 then state == Running(6614,[3045624246,518,offset,length,ordered,96,6619,32],mem)
                                                                                                              else if id == 5 then state == Running(6615,[3045624246,518,offset,length,ordered,96,6619,32,length],mem)
                                                                                                              else if id == 6 then state == Running(6618,[3045624246,518,offset,length,ordered,96,6619,32,length,23523],mem)
                                                                                                              else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(0,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6606,[3045624246,518,offset,length,ordered],mem);
    assert Fetch(code,6606) == Op(91,6607,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(1,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6607,[3045624246,518,offset,length,ordered],mem);
    F.Push1(code,6607);
    assert Fetch(code,6607) == Op(96,6609,96);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(2,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6609,[3045624246,518,offset,length,ordered,96],mem);
    F.Push2(code,6609);
    assert Fetch(code,6609) == Op(97,6612,6619);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(3,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6612,[3045624246,518,offset,length,ordered,96,6619],mem);
    F.Push1(code,6612);
    assert Fetch(code,6612) == Op(96,6614,32);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(4,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6614,[3045624246,518,offset,length,ordered,96,6619,32],mem);
    assert Fetch(code,6614) == Op(132,6615,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(5,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6615,[3045624246,518,offset,length,ordered,96,6619,32,length],mem);
    F.Push2(code,6615);
    assert Fetch(code,6615) == Op(97,6618,23523);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(6,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23523,[3045624246,518,offset,length,ordered,96,6619,32,length],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6618,[3045624246,518,offset,length,ordered,96,6619,32,length,23523],mem);
    assert Fetch(code,6618) == Op(86,6619,0);
  }
  lemma Start(offset: Word, length: Word, ordered: Word, mem: seq<Byte>)
    requires Admitted(offset,length,ordered)
    ensures Good(0,Running(6606,[3045624246,518,offset,length,ordered],mem),offset,length,ordered,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,ordered)
    ensures state == Running(23523,[3045624246,518,offset,length,ordered,96,6619,32,length],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 8 && trace[0] == Running(6606,[3045624246,518,offset,length,ordered],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,ordered,mem);
    state := Running(6606,[3045624246,518,offset,length,ordered],mem);
    trace := [state];
    Advance0(code,state,offset,length,ordered,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6606,[3045624246,518,offset,length,ordered],mem);
    state := next0;
    Advance1(code,state,offset,length,ordered,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6606,[3045624246,518,offset,length,ordered],mem);
    state := next1;
    Advance2(code,state,offset,length,ordered,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6606,[3045624246,518,offset,length,ordered],mem);
    state := next2;
    Advance3(code,state,offset,length,ordered,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6606,[3045624246,518,offset,length,ordered],mem);
    state := next3;
    Advance4(code,state,offset,length,ordered,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6606,[3045624246,518,offset,length,ordered],mem);
    state := next4;
    Advance5(code,state,offset,length,ordered,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6606,[3045624246,518,offset,length,ordered],mem);
    state := next5;
    Advance6(code,state,offset,length,ordered,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6606,[3045624246,518,offset,length,ordered],mem);
    state := next6;
  }
}
