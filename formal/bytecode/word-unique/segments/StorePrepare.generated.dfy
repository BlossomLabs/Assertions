// SPDX-License-Identifier: MIT
// Generated pinned uniqueWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeUniqueSegmentStorePrepare {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeUniqueLoopScalar
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { ((index as nat)*32+32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  function Target(kept: Word): Word { (160+(kept as nat)*32)%G.Modulus() }
  predicate MemoryAdmitted(mem: seq<Byte>, j: Word, last: Word) { true }
  predicate Admitted(offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && ordered <= 1 && kept <= index <= length/32 && j <= kept && seen <= 1 && index < length/32 && seen == 0 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6890] == 91 &&
                                              code[6891] == 128 &&
                                              code[6892] == 97 &&
                                              code[6893] == 27 &&
                                              code[6894] == 13 &&
                                              code[6895] == 87 &&
                                              code[6896] == 97 &&
                                              code[6897] == 27 &&
                                              code[6898] == 13 &&
                                              code[6899] == 133 &&
                                              code[6900] == 133 &&
                                              code[6901] == 97 &&
                                              code[6902] == 26 &&
                                              code[6903] == 253 &&
                                              code[6904] == 129 &&
                                              code[6905] == 97 &&
                                              code[6906] == 92 &&
                                              code[6907] == 208 &&
                                              code[6908] == 86 &&
                                              code[6925] == 91 &&
                                              code[23760] == 91
  }
  function Destinations(): set<nat> { {6925,23760} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>) { Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && (
                                                                                                                                                                                    if id == 0 then state == Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem)
                                                                                                                                                                                    else if id == 1 then state == Running(6891,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem)
                                                                                                                                                                                    else if id == 2 then state == Running(6892,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,seen],mem)
                                                                                                                                                                                    else if id == 3 then state == Running(6895,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,seen,6925],mem)
                                                                                                                                                                                    else if id == 4 then state == Running(6896,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem)
                                                                                                                                                                                    else if id == 5 then state == Running(6899,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925],mem)
                                                                                                                                                                                    else if id == 6 then state == Running(6900,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128],mem)
                                                                                                                                                                                    else if id == 7 then state == Running(6901,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept],mem)
                                                                                                                                                                                    else if id == 8 then state == Running(6904,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,6909],mem)
                                                                                                                                                                                    else if id == 9 then state == Running(6905,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,6909,kept],mem)
                                                                                                                                                                                    else if id == 10 then state == Running(6908,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,6909,kept,23760],mem)
                                                                                                                                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(0,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem);
    assert Fetch(code,6890) == Op(91,6891,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(1,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6891,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem);
    assert Fetch(code,6891) == Op(128,6892,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(2,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6892,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,seen],mem);
    F.Push2(code,6892);
    assert Fetch(code,6892) == Op(97,6895,6925);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(3,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6895,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,seen,6925],mem);
    assert Fetch(code,6895) == Op(87,6896,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(4,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6896,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem);
    F.Push2(code,6896);
    assert Fetch(code,6896) == Op(97,6899,6925);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(5,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6899,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925],mem);
    assert Fetch(code,6899) == Op(133,6900,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(6,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6900,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128],mem);
    assert Fetch(code,6900) == Op(133,6901,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(7,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6901,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept],mem);
    F.Push2(code,6901);
    assert Fetch(code,6901) == Op(97,6904,6909);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(8,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6904,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,6909],mem);
    assert Fetch(code,6904) == Op(129,6905,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(9,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6905,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,6909,kept],mem);
    F.Push2(code,6905);
    assert Fetch(code,6905) == Op(97,6908,23760);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(10,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23760,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,6909,kept],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6908,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,6909,kept,23760],mem);
    assert Fetch(code,6908) == Op(86,6909,0);
  }
  lemma Start(offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>)
    requires Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last)
    ensures Good(0,Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem),offset,length,ordered,kept,index,j,word,last,seen,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last)
    ensures state == Running(23760,[3045624246,518,offset,length,ordered,128,kept,index,word,seen,6925,128,kept,6909,kept],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 12 && trace[0] == Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,ordered,kept,index,j,word,last,seen,mem);
    state := Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem);
    trace := [state];
    Advance0(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem);
    state := next0;
    Advance1(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem);
    state := next1;
    Advance2(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem);
    state := next2;
    Advance3(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem);
    state := next3;
    Advance4(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem);
    state := next4;
    Advance5(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem);
    state := next5;
    Advance6(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem);
    state := next6;
    Advance7(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem);
    state := next7;
    Advance8(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem);
    state := next8;
    Advance9(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem);
    state := next9;
    Advance10(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(6890,[3045624246,518,offset,length,ordered,128,kept,index,word,seen],mem);
    state := next10;
  }
}
