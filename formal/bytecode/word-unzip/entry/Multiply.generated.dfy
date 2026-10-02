// SPDX-License-Identifier: MIT
// Generated pinned unzipWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeUnzipAdmissionMultiply {
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
                                              code[6079] == 91 &&
                                              code[6080] == 144 &&
                                              code[6081] == 80 &&
                                              code[6082] == 97 &&
                                              code[6083] == 23 &&
                                              code[6084] == 204 &&
                                              code[6085] == 129 &&
                                              code[6086] == 96 &&
                                              code[6087] == 32 &&
                                              code[6088] == 97 &&
                                              code[6089] == 92 &&
                                              code[6090] == 29 &&
                                              code[6091] == 86 &&
                                              code[23581] == 91
  }
  function Destinations(): set<nat> { {23581} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>) { Admitted(offset,length,lane) && (
                                                                                                           if id == 0 then state == Running(6079,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem)
                                                                                                           else if id == 1 then state == Running(6080,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem)
                                                                                                           else if id == 2 then state == Running(6081,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),0],mem)
                                                                                                           else if id == 3 then state == Running(6082,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane)],mem)
                                                                                                           else if id == 4 then state == Running(6085,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),6092],mem)
                                                                                                           else if id == 5 then state == Running(6086,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),6092,Count(length,lane)],mem)
                                                                                                           else if id == 6 then state == Running(6088,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),6092,Count(length,lane),32],mem)
                                                                                                           else if id == 7 then state == Running(6091,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),6092,Count(length,lane),32,23581],mem)
                                                                                                           else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(0,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6079,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem);
    assert Fetch(code,6079) == Op(91,6080,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(1,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6080,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem);
    assert Fetch(code,6080) == Op(144,6081,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(2,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6081,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),0],mem);
    assert Fetch(code,6081) == Op(80,6082,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(3,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6082,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane)],mem);
    F.Push2(code,6082);
    assert Fetch(code,6082) == Op(97,6085,6092);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(4,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6085,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),6092],mem);
    assert Fetch(code,6085) == Op(129,6086,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(5,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6086,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),6092,Count(length,lane)],mem);
    F.Push1(code,6086);
    assert Fetch(code,6086) == Op(96,6088,32);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(6,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6088,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),6092,Count(length,lane),32],mem);
    F.Push2(code,6088);
    assert Fetch(code,6088) == Op(97,6091,23581);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(7,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23581,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),6092,Count(length,lane),32],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6091,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),6092,Count(length,lane),32,23581],mem);
    assert Fetch(code,6091) == Op(86,6092,0);
  }
  lemma Start(offset: Word, length: Word, lane: Word, mem: seq<Byte>)
    requires Admitted(offset,length,lane)
    ensures Good(0,Running(6079,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem),offset,length,lane,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,lane)
    ensures state == Running(23581,[2989505972,518,offset,length,lane,96,length/32,Count(length,lane),6092,Count(length,lane),32],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 9 && trace[0] == Running(6079,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,lane,mem);
    state := Running(6079,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem);
    trace := [state];
    Advance0(code,state,offset,length,lane,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6079,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem);
    state := next0;
    Advance1(code,state,offset,length,lane,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6079,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem);
    state := next1;
    Advance2(code,state,offset,length,lane,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6079,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem);
    state := next2;
    Advance3(code,state,offset,length,lane,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6079,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem);
    state := next3;
    Advance4(code,state,offset,length,lane,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6079,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem);
    state := next4;
    Advance5(code,state,offset,length,lane,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6079,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem);
    state := next5;
    Advance6(code,state,offset,length,lane,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6079,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem);
    state := next6;
    Advance7(code,state,offset,length,lane,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(6079,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem);
    state := next7;
  }
}
