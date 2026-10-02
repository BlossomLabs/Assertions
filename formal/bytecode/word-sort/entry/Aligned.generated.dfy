// SPDX-License-Identifier: MIT
// Generated pinned sortWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeSortAdmissionAligned {
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
                                              code[3435] == 91 &&
                                              code[3436] == 21 &&
                                              code[3437] == 97 &&
                                              code[3438] == 13 &&
                                              code[3439] == 140 &&
                                              code[3440] == 87 &&
                                              code[3468] == 91
  }
  function Destinations(): set<nat> { {3468} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, mem: seq<Byte>) { Admitted(offset,length) && (
                                                                                               if id == 0 then state == Running(3435,[785862473,518,offset,length,96,length%32],mem)
                                                                                               else if id == 1 then state == Running(3436,[785862473,518,offset,length,96,length%32],mem)
                                                                                               else if id == 2 then state == Running(3437,[785862473,518,offset,length,96,1],mem)
                                                                                               else if id == 3 then state == Running(3440,[785862473,518,offset,length,96,1,3468],mem)
                                                                                               else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(0,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3435,[785862473,518,offset,length,96,length%32],mem);
    assert Fetch(code,3435) == Op(91,3436,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(1,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3436,[785862473,518,offset,length,96,length%32],mem);
    assert Fetch(code,3436) == Op(21,3437,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(2,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3437,[785862473,518,offset,length,96,1],mem);
    F.Push2(code,3437);
    assert Fetch(code,3437) == Op(97,3440,3468);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(3,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(3468,[785862473,518,offset,length,96],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3440,[785862473,518,offset,length,96,1,3468],mem);
    assert Fetch(code,3440) == Op(87,3441,0);
  }
  lemma Start(offset: Word, length: Word, mem: seq<Byte>)
    requires Admitted(offset,length)
    ensures Good(0,Running(3435,[785862473,518,offset,length,96,length%32],mem),offset,length,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length)
    ensures state == Running(3468,[785862473,518,offset,length,96],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 5 && trace[0] == Running(3435,[785862473,518,offset,length,96,length%32],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,mem);
    state := Running(3435,[785862473,518,offset,length,96,length%32],mem);
    trace := [state];
    Advance0(code,state,offset,length,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(3435,[785862473,518,offset,length,96,length%32],mem);
    state := next0;
    Advance1(code,state,offset,length,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(3435,[785862473,518,offset,length,96,length%32],mem);
    state := next1;
    Advance2(code,state,offset,length,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(3435,[785862473,518,offset,length,96,length%32],mem);
    state := next2;
    Advance3(code,state,offset,length,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(3435,[785862473,518,offset,length,96,length%32],mem);
    state := next3;
  }
}
