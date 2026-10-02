// SPDX-License-Identifier: MIT
// Generated pinned sortWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeSortAdmissionBodyStart {
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
                                              code[3422] == 91 &&
                                              code[3423] == 96 &&
                                              code[3424] == 96 &&
                                              code[3425] == 97 &&
                                              code[3426] == 13 &&
                                              code[3427] == 107 &&
                                              code[3428] == 96 &&
                                              code[3429] == 32 &&
                                              code[3430] == 131 &&
                                              code[3431] == 97 &&
                                              code[3432] == 91 &&
                                              code[3433] == 227 &&
                                              code[3434] == 86 &&
                                              code[23523] == 91
  }
  function Destinations(): set<nat> { {23523} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, mem: seq<Byte>) { Admitted(offset,length) && (
                                                                                               if id == 0 then state == Running(3422,[785862473,518,offset,length],mem)
                                                                                               else if id == 1 then state == Running(3423,[785862473,518,offset,length],mem)
                                                                                               else if id == 2 then state == Running(3425,[785862473,518,offset,length,96],mem)
                                                                                               else if id == 3 then state == Running(3428,[785862473,518,offset,length,96,3435],mem)
                                                                                               else if id == 4 then state == Running(3430,[785862473,518,offset,length,96,3435,32],mem)
                                                                                               else if id == 5 then state == Running(3431,[785862473,518,offset,length,96,3435,32,length],mem)
                                                                                               else if id == 6 then state == Running(3434,[785862473,518,offset,length,96,3435,32,length,23523],mem)
                                                                                               else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(0,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3422,[785862473,518,offset,length],mem);
    assert Fetch(code,3422) == Op(91,3423,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(1,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3423,[785862473,518,offset,length],mem);
    F.Push1(code,3423);
    assert Fetch(code,3423) == Op(96,3425,96);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(2,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3425,[785862473,518,offset,length,96],mem);
    F.Push2(code,3425);
    assert Fetch(code,3425) == Op(97,3428,3435);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(3,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3428,[785862473,518,offset,length,96,3435],mem);
    F.Push1(code,3428);
    assert Fetch(code,3428) == Op(96,3430,32);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(4,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3430,[785862473,518,offset,length,96,3435,32],mem);
    assert Fetch(code,3430) == Op(131,3431,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(5,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3431,[785862473,518,offset,length,96,3435,32,length],mem);
    F.Push2(code,3431);
    assert Fetch(code,3431) == Op(97,3434,23523);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(6,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23523,[785862473,518,offset,length,96,3435,32,length],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(3434,[785862473,518,offset,length,96,3435,32,length,23523],mem);
    assert Fetch(code,3434) == Op(86,3435,0);
  }
  lemma Start(offset: Word, length: Word, mem: seq<Byte>)
    requires Admitted(offset,length)
    ensures Good(0,Running(3422,[785862473,518,offset,length],mem),offset,length,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length)
    ensures state == Running(23523,[785862473,518,offset,length,96,3435,32,length],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 8 && trace[0] == Running(3422,[785862473,518,offset,length],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,mem);
    state := Running(3422,[785862473,518,offset,length],mem);
    trace := [state];
    Advance0(code,state,offset,length,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(3422,[785862473,518,offset,length],mem);
    state := next0;
    Advance1(code,state,offset,length,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(3422,[785862473,518,offset,length],mem);
    state := next1;
    Advance2(code,state,offset,length,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(3422,[785862473,518,offset,length],mem);
    state := next2;
    Advance3(code,state,offset,length,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(3422,[785862473,518,offset,length],mem);
    state := next3;
    Advance4(code,state,offset,length,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(3422,[785862473,518,offset,length],mem);
    state := next4;
    Advance5(code,state,offset,length,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(3422,[785862473,518,offset,length],mem);
    state := next5;
    Advance6(code,state,offset,length,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(3422,[785862473,518,offset,length],mem);
    state := next6;
  }
}
