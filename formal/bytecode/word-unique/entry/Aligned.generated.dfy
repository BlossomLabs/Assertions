// SPDX-License-Identifier: MIT
// Generated pinned uniqueWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeUniqueAdmissionAligned {
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
                                              code[6619] == 91 &&
                                              code[6620] == 21 &&
                                              code[6621] == 97 &&
                                              code[6622] == 25 &&
                                              code[6623] == 252 &&
                                              code[6624] == 87 &&
                                              code[6652] == 91
  }
  function Destinations(): set<nat> { {6652} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>) { Admitted(offset,length,ordered) && (
                                                                                                              if id == 0 then state == Running(6619,[3045624246,518,offset,length,ordered,96,length%32],mem)
                                                                                                              else if id == 1 then state == Running(6620,[3045624246,518,offset,length,ordered,96,length%32],mem)
                                                                                                              else if id == 2 then state == Running(6621,[3045624246,518,offset,length,ordered,96,1],mem)
                                                                                                              else if id == 3 then state == Running(6624,[3045624246,518,offset,length,ordered,96,1,6652],mem)
                                                                                                              else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(0,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6619,[3045624246,518,offset,length,ordered,96,length%32],mem);
    assert Fetch(code,6619) == Op(91,6620,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(1,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6620,[3045624246,518,offset,length,ordered,96,length%32],mem);
    assert Fetch(code,6620) == Op(21,6621,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(2,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,ordered,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6621,[3045624246,518,offset,length,ordered,96,1],mem);
    F.Push2(code,6621);
    assert Fetch(code,6621) == Op(97,6624,6652);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered) && Good(3,state,offset,length,ordered,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(6652,[3045624246,518,offset,length,ordered,96],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6624,[3045624246,518,offset,length,ordered,96,1,6652],mem);
    assert Fetch(code,6624) == Op(87,6625,0);
  }
  lemma Start(offset: Word, length: Word, ordered: Word, mem: seq<Byte>)
    requires Admitted(offset,length,ordered)
    ensures Good(0,Running(6619,[3045624246,518,offset,length,ordered,96,length%32],mem),offset,length,ordered,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, ordered: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,ordered)
    ensures state == Running(6652,[3045624246,518,offset,length,ordered,96],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 5 && trace[0] == Running(6619,[3045624246,518,offset,length,ordered,96,length%32],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,ordered,mem);
    state := Running(6619,[3045624246,518,offset,length,ordered,96,length%32],mem);
    trace := [state];
    Advance0(code,state,offset,length,ordered,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6619,[3045624246,518,offset,length,ordered,96,length%32],mem);
    state := next0;
    Advance1(code,state,offset,length,ordered,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6619,[3045624246,518,offset,length,ordered,96,length%32],mem);
    state := next1;
    Advance2(code,state,offset,length,ordered,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6619,[3045624246,518,offset,length,ordered,96,length%32],mem);
    state := next2;
    Advance3(code,state,offset,length,ordered,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6619,[3045624246,518,offset,length,ordered,96,length%32],mem);
    state := next3;
  }
}
