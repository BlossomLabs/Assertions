// SPDX-License-Identifier: MIT
// Generated pinned unzipWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeUnzipAdmissionAligned {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeScanDecoderScalar
  function Count(length: Word, lane: Word): Word { if lane == 0 then (length/32+1)/2 else length/32/2 }
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, lane: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[5949] == 91 &&
                                              code[5950] == 21 &&
                                              code[5951] == 97 &&
                                              code[5952] == 23 &&
                                              code[5953] == 94 &&
                                              code[5954] == 87 &&
                                              code[5982] == 91
  }
  function Destinations(): set<nat> { {5982} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>) { Admitted(offset,length,lane) && (
                                                                                                           if id == 0 then state == Running(5949,[2989505972,518,offset,length,lane,96,length%32],mem)
                                                                                                           else if id == 1 then state == Running(5950,[2989505972,518,offset,length,lane,96,length%32],mem)
                                                                                                           else if id == 2 then state == Running(5951,[2989505972,518,offset,length,lane,96,1],mem)
                                                                                                           else if id == 3 then state == Running(5954,[2989505972,518,offset,length,lane,96,1,5982],mem)
                                                                                                           else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(0,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5949,[2989505972,518,offset,length,lane,96,length%32],mem);
    assert Fetch(code,5949) == Op(91,5950,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(1,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5950,[2989505972,518,offset,length,lane,96,length%32],mem);
    assert Fetch(code,5950) == Op(21,5951,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(2,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,lane,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5951,[2989505972,518,offset,length,lane,96,1],mem);
    F.Push2(code,5951);
    assert Fetch(code,5951) == Op(97,5954,5982);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane) && Good(3,state,offset,length,lane,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(5982,[2989505972,518,offset,length,lane,96],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5954,[2989505972,518,offset,length,lane,96,1,5982],mem);
    assert Fetch(code,5954) == Op(87,5955,0);
  }
  lemma Start(offset: Word, length: Word, lane: Word, mem: seq<Byte>)
    requires Admitted(offset,length,lane)
    ensures Good(0,Running(5949,[2989505972,518,offset,length,lane,96,length%32],mem),offset,length,lane,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, lane: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,lane)
    ensures state == Running(5982,[2989505972,518,offset,length,lane,96],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 5 && trace[0] == Running(5949,[2989505972,518,offset,length,lane,96,length%32],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,lane,mem);
    state := Running(5949,[2989505972,518,offset,length,lane,96,length%32],mem);
    trace := [state];
    Advance0(code,state,offset,length,lane,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(5949,[2989505972,518,offset,length,lane,96,length%32],mem);
    state := next0;
    Advance1(code,state,offset,length,lane,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(5949,[2989505972,518,offset,length,lane,96,length%32],mem);
    state := next1;
    Advance2(code,state,offset,length,lane,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(5949,[2989505972,518,offset,length,lane,96,length%32],mem);
    state := next2;
    Advance3(code,state,offset,length,lane,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(5949,[2989505972,518,offset,length,lane,96,length%32],mem);
    state := next3;
  }
}
