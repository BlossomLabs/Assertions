// SPDX-License-Identifier: MIT
// Generated pinned uniqueWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeUniqueSegmentAfterOtherPosition {
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
  predicate Admitted(offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && ordered <= 1 && kept <= index <= length/32 && j <= kept && seen <= 1 && index < length/32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6768] == 91 &&
                                              code[6769] == 97 &&
                                              code[6770] == 26 &&
                                              code[6771] == 123 &&
                                              code[6772] == 144 &&
                                              code[6773] == 96 &&
                                              code[6774] == 32 &&
                                              code[6775] == 97 &&
                                              code[6776] == 92 &&
                                              code[6777] == 52 &&
                                              code[6778] == 86 &&
                                              code[23604] == 91
  }
  function Destinations(): set<nat> { {23604} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>) { Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && (
                                                                                                                                                                                    if id == 0 then state == Running(6768,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,Position(index)],mem)
                                                                                                                                                                                    else if id == 1 then state == Running(6769,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,Position(index)],mem)
                                                                                                                                                                                    else if id == 2 then state == Running(6772,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,Position(index),6779],mem)
                                                                                                                                                                                    else if id == 3 then state == Running(6773,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,6779,Position(index)],mem)
                                                                                                                                                                                    else if id == 4 then state == Running(6775,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,6779,Position(index),32],mem)
                                                                                                                                                                                    else if id == 5 then state == Running(6778,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,6779,Position(index),32,23604],mem)
                                                                                                                                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(0,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6768,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,Position(index)],mem);
    assert Fetch(code,6768) == Op(91,6769,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(1,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6769,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,Position(index)],mem);
    F.Push2(code,6769);
    assert Fetch(code,6769) == Op(97,6772,6779);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(2,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6772,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,Position(index),6779],mem);
    assert Fetch(code,6772) == Op(144,6773,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(3,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6773,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,6779,Position(index)],mem);
    F.Push1(code,6773);
    assert Fetch(code,6773) == Op(96,6775,32);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(4,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6775,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,6779,Position(index),32],mem);
    F.Push2(code,6775);
    assert Fetch(code,6775) == Op(97,6778,23604);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(5,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23604,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,6779,Position(index),32],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6778,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,6779,Position(index),32,23604],mem);
    assert Fetch(code,6778) == Op(86,6779,0);
  }
  lemma Start(offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>)
    requires Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last)
    ensures Good(0,Running(6768,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,Position(index)],mem),offset,length,ordered,kept,index,j,word,last,seen,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last)
    ensures state == Running(23604,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,6779,Position(index),32],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 7 && trace[0] == Running(6768,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,Position(index)],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,ordered,kept,index,j,word,last,seen,mem);
    state := Running(6768,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,Position(index)],mem);
    trace := [state];
    Advance0(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6768,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,Position(index)],mem);
    state := next0;
    Advance1(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6768,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,Position(index)],mem);
    state := next1;
    Advance2(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6768,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,Position(index)],mem);
    state := next2;
    Advance3(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6768,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,Position(index)],mem);
    state := next3;
    Advance4(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6768,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,Position(index)],mem);
    state := next4;
    Advance5(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6768,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,Position(index)],mem);
    state := next5;
  }
}
