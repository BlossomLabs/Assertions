// SPDX-License-Identifier: MIT
// Generated pinned uniqueWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeUniqueSegmentUnorderedRead {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeUniqueLoopScalar
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { ((index as nat)*32+32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  function Target(kept: Word): Word { (160+(kept as nat)*32)%G.Modulus() }
  predicate MemoryAdmitted(mem: seq<Byte>, j: Word, last: Word) { 160+j*32+32 <= |mem| < G.Modulus() && Round32(|mem|) == |mem| && Load(mem,160+j*32) == last }
  predicate Admitted(offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && ordered <= 1 && kept <= index <= length/32 && j <= kept && seen <= 1 && index < length/32 && ordered == 0 && j < kept }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6847] == 91 &&
                                              code[6848] == 132 &&
                                              code[6849] == 129 &&
                                              code[6850] == 16 &&
                                              code[6851] == 21 &&
                                              code[6852] == 97 &&
                                              code[6853] == 26 &&
                                              code[6854] == 232 &&
                                              code[6855] == 87 &&
                                              code[6856] == 96 &&
                                              code[6857] == 32 &&
                                              code[6858] == 128 &&
                                              code[6859] == 130 &&
                                              code[6860] == 2 &&
                                              code[6861] == 135 &&
                                              code[6862] == 1 &&
                                              code[6863] == 1 &&
                                              code[6864] == 81 &&
                                              code[6888] == 91
  }
  function Destinations(): set<nat> { {6888} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>) { Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && (
                                                                                                                                                                                    if id == 0 then state == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem)
                                                                                                                                                                                    else if id == 1 then state == Running(6848,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem)
                                                                                                                                                                                    else if id == 2 then state == Running(6849,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,kept],mem)
                                                                                                                                                                                    else if id == 3 then state == Running(6850,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,kept,j],mem)
                                                                                                                                                                                    else if id == 4 then state == Running(6851,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,1],mem)
                                                                                                                                                                                    else if id == 5 then state == Running(6852,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,0],mem)
                                                                                                                                                                                    else if id == 6 then state == Running(6855,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,0,6888],mem)
                                                                                                                                                                                    else if id == 7 then state == Running(6856,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem)
                                                                                                                                                                                    else if id == 8 then state == Running(6858,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,32],mem)
                                                                                                                                                                                    else if id == 9 then state == Running(6859,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,32,32],mem)
                                                                                                                                                                                    else if id == 10 then state == Running(6860,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,32,32,j],mem)
                                                                                                                                                                                    else if id == 11 then state == Running(6861,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,32,((j as nat)*(32 as nat))%G.Modulus()],mem)
                                                                                                                                                                                    else if id == 12 then state == Running(6862,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,32,((j as nat)*(32 as nat))%G.Modulus(),128],mem)
                                                                                                                                                                                    else if id == 13 then state == Running(6863,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,32,((128 as nat)+(((j as nat)*(32 as nat))%G.Modulus() as nat))%G.Modulus()],mem)
                                                                                                                                                                                    else if id == 14 then state == Running(6864,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,((((128 as nat)+(((j as nat)*(32 as nat))%G.Modulus() as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem)
                                                                                                                                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(0,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    assert Fetch(code,6847) == Op(91,6848,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(1,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6848,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    assert Fetch(code,6848) == Op(132,6849,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(2,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6849,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,kept],mem);
    assert Fetch(code,6849) == Op(129,6850,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(3,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6850,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,kept,j],mem);
    assert Fetch(code,6850) == Op(16,6851,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(4,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6851,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,1],mem);
    assert Fetch(code,6851) == Op(21,6852,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(5,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6852,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,0],mem);
    F.Push2(code,6852);
    assert Fetch(code,6852) == Op(97,6855,6888);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(6,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6855,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,0,6888],mem);
    assert Fetch(code,6855) == Op(87,6856,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(7,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6856,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    F.Push1(code,6856);
    assert Fetch(code,6856) == Op(96,6858,32);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(8,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6858,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,32],mem);
    assert Fetch(code,6858) == Op(128,6859,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(9,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6859,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,32,32],mem);
    assert Fetch(code,6859) == Op(130,6860,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(10,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6860,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,32,32,j],mem);
    assert Fetch(code,6860) == Op(2,6861,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(11,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6861,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,32,((j as nat)*(32 as nat))%G.Modulus()],mem);
    assert Fetch(code,6861) == Op(135,6862,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(12,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6862,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,32,((j as nat)*(32 as nat))%G.Modulus(),128],mem);
    assert Fetch(code,6862) == Op(1,6863,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(13,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6863,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,32,((128 as nat)+(((j as nat)*(32 as nat))%G.Modulus() as nat))%G.Modulus()],mem);
    assert Fetch(code,6863) == Op(1,6864,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(14,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(6865,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,last],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6864,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,((((128 as nat)+(((j as nat)*(32 as nat))%G.Modulus() as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem);
    SC.NoExpand(mem,j);
    assert Fetch(code,6864) == Op(81,6865,0);
  }
  lemma Start(offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>)
    requires Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last)
    ensures Good(0,Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem),offset,length,ordered,kept,index,j,word,last,seen,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last)
    ensures state == Running(6865,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j,last],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 16 && trace[0] == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,ordered,kept,index,j,word,last,seen,mem);
    state := Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    trace := [state];
    Advance0(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    state := next0;
    Advance1(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    state := next1;
    Advance2(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    state := next2;
    Advance3(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    state := next3;
    Advance4(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    state := next4;
    Advance5(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    state := next5;
    Advance6(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    state := next6;
    Advance7(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    state := next7;
    Advance8(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    state := next8;
    Advance9(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    state := next9;
    Advance10(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    state := next10;
    Advance11(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    state := next11;
    Advance12(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    state := next12;
    Advance13(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    state := next13;
    Advance14(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(6847,[3045624246,518,offset,length,ordered,128,kept,index,word,0,j],mem);
    state := next14;
  }
}
