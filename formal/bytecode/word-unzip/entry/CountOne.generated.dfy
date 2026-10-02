// SPDX-License-Identifier: MIT
// Generated pinned unzipWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeUnzipAdmissionCountOne {
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
                                              code[6051] == 91 &&
                                              code[6052] == 97 &&
                                              code[6053] == 23 &&
                                              code[6054] == 191 &&
                                              code[6055] == 86 &&
                                              code[6079] == 91
  }
  function Destinations(): set<nat> { {6079} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>) { Admitted(offset,length,lane) && (
                                                                                                           if id == 0 then state == Running(6051,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem)
                                                                                                           else if id == 1 then state == Running(6052,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem)
                                                                                                           else if id == 2 then state == Running(6055,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane),6079],mem)
                                                                                                           else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(0,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6051,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem);
    assert Fetch(code,6051) == Op(91,6052,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(1,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6052,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem);
    F.Push2(code,6052);
    assert Fetch(code,6052) == Op(97,6055,6079);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(2,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(6079,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6055,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane),6079],mem);
    assert Fetch(code,6055) == Op(86,6056,0);
  }
  lemma Start(offset: Word, length: Word, lane: Word, mem: seq<Byte>)
    requires Admitted(offset,length,lane)
    ensures Good(0,Running(6051,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem),offset,length,lane,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,lane)
    ensures state == Running(6079,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 4 && trace[0] == Running(6051,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,lane,mem);
    state := Running(6051,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem);
    trace := [state];
    Advance0(code,state,offset,length,lane,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6051,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem);
    state := next0;
    Advance1(code,state,offset,length,lane,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6051,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem);
    state := next1;
    Advance2(code,state,offset,length,lane,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6051,[2989505972,518,offset,length,lane,96,length/32,0,Count(length,lane)],mem);
    state := next2;
  }
}
