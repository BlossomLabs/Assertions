// SPDX-License-Identifier: MIT
// Generated pinned reverseWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeReverseAdmissionAligned {
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
                                              code[5728] == 91 &&
                                              code[5729] == 21 &&
                                              code[5730] == 97 &&
                                              code[5731] == 22 &&
                                              code[5732] == 129 &&
                                              code[5733] == 87 &&
                                              code[5761] == 91 &&
                                              code[5762] == 95 &&
                                              code[5763] == 97 &&
                                              code[5764] == 22 &&
                                              code[5765] == 141 &&
                                              code[5766] == 96 &&
                                              code[5767] == 32 &&
                                              code[5768] == 132 &&
                                              code[5769] == 97 &&
                                              code[5770] == 92 &&
                                              code[5771] == 10 &&
                                              code[5772] == 86 &&
                                              code[23562] == 91
  }
  function Destinations(): set<nat> { {5761,23562} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, mem: seq<Byte>) { Admitted(offset,length) && (
                                                                                               if id == 0 then state == Running(5728,[2874738232,518,offset,length,96,length%32],mem)
                                                                                               else if id == 1 then state == Running(5729,[2874738232,518,offset,length,96,length%32],mem)
                                                                                               else if id == 2 then state == Running(5730,[2874738232,518,offset,length,96,1],mem)
                                                                                               else if id == 3 then state == Running(5733,[2874738232,518,offset,length,96,1,5761],mem)
                                                                                               else if id == 4 then state == Running(5761,[2874738232,518,offset,length,96],mem)
                                                                                               else if id == 5 then state == Running(5762,[2874738232,518,offset,length,96],mem)
                                                                                               else if id == 6 then state == Running(5763,[2874738232,518,offset,length,96,0],mem)
                                                                                               else if id == 7 then state == Running(5766,[2874738232,518,offset,length,96,0,5773],mem)
                                                                                               else if id == 8 then state == Running(5768,[2874738232,518,offset,length,96,0,5773,32],mem)
                                                                                               else if id == 9 then state == Running(5769,[2874738232,518,offset,length,96,0,5773,32,length],mem)
                                                                                               else if id == 10 then state == Running(5772,[2874738232,518,offset,length,96,0,5773,32,length,23562],mem)
                                                                                               else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(0,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5728,[2874738232,518,offset,length,96,length%32],mem);
    assert Fetch(code,5728) == Op(91,5729,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(1,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5729,[2874738232,518,offset,length,96,length%32],mem);
    assert Fetch(code,5729) == Op(21,5730,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(2,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5730,[2874738232,518,offset,length,96,1],mem);
    F.Push2(code,5730);
    assert Fetch(code,5730) == Op(97,5733,5761);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(3,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5733,[2874738232,518,offset,length,96,1,5761],mem);
    assert Fetch(code,5733) == Op(87,5734,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(4,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5761,[2874738232,518,offset,length,96],mem);
    assert Fetch(code,5761) == Op(91,5762,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(5,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5762,[2874738232,518,offset,length,96],mem);
    assert Fetch(code,5762) == Op(95,5763,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(6,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5763,[2874738232,518,offset,length,96,0],mem);
    F.Push2(code,5763);
    assert Fetch(code,5763) == Op(97,5766,5773);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(7,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5766,[2874738232,518,offset,length,96,0,5773],mem);
    F.Push1(code,5766);
    assert Fetch(code,5766) == Op(96,5768,32);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(8,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5768,[2874738232,518,offset,length,96,0,5773,32],mem);
    assert Fetch(code,5768) == Op(132,5769,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(9,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,length,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5769,[2874738232,518,offset,length,96,0,5773,32,length],mem);
    F.Push2(code,5769);
    assert Fetch(code,5769) == Op(97,5772,23562);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length) && Good(10,state,offset,length,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23562,[2874738232,518,offset,length,96,0,5773,32,length],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5772,[2874738232,518,offset,length,96,0,5773,32,length,23562],mem);
    assert Fetch(code,5772) == Op(86,5773,0);
  }
  lemma Start(offset: Word, length: Word, mem: seq<Byte>)
    requires Admitted(offset,length)
    ensures Good(0,Running(5728,[2874738232,518,offset,length,96,length%32],mem),offset,length,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length)
    ensures state == Running(23562,[2874738232,518,offset,length,96,0,5773,32,length],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 12 && trace[0] == Running(5728,[2874738232,518,offset,length,96,length%32],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,mem);
    state := Running(5728,[2874738232,518,offset,length,96,length%32],mem);
    trace := [state];
    Advance0(code,state,offset,length,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(5728,[2874738232,518,offset,length,96,length%32],mem);
    state := next0;
    Advance1(code,state,offset,length,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(5728,[2874738232,518,offset,length,96,length%32],mem);
    state := next1;
    Advance2(code,state,offset,length,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(5728,[2874738232,518,offset,length,96,length%32],mem);
    state := next2;
    Advance3(code,state,offset,length,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(5728,[2874738232,518,offset,length,96,length%32],mem);
    state := next3;
    Advance4(code,state,offset,length,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(5728,[2874738232,518,offset,length,96,length%32],mem);
    state := next4;
    Advance5(code,state,offset,length,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(5728,[2874738232,518,offset,length,96,length%32],mem);
    state := next5;
    Advance6(code,state,offset,length,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(5728,[2874738232,518,offset,length,96,length%32],mem);
    state := next6;
    Advance7(code,state,offset,length,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(5728,[2874738232,518,offset,length,96,length%32],mem);
    state := next7;
    Advance8(code,state,offset,length,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(5728,[2874738232,518,offset,length,96,length%32],mem);
    state := next8;
    Advance9(code,state,offset,length,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(5728,[2874738232,518,offset,length,96,length%32],mem);
    state := next9;
    Advance10(code,state,offset,length,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(5728,[2874738232,518,offset,length,96,length%32],mem);
    state := next10;
  }
}
