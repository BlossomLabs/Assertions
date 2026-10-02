// SPDX-License-Identifier: MIT
// Generated pinned uniqueWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeUniqueSegmentAfterEnd {
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
                                              code[6779] == 91 &&
                                              code[6780] == 146 &&
                                              code[6781] == 97 &&
                                              code[6782] == 26 &&
                                              code[6783] == 136 &&
                                              code[6784] == 147 &&
                                              code[6785] == 146 &&
                                              code[6786] == 145 &&
                                              code[6787] == 144 &&
                                              code[6788] == 97 &&
                                              code[6789] == 92 &&
                                              code[6790] == 71 &&
                                              code[6791] == 86 &&
                                              code[23623] == 91
  }
  function Destinations(): set<nat> { {23623} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>) { Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && (
                                                                                                                                                                                    if id == 0 then state == Running(6779,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,NextPosition(index)],mem)
                                                                                                                                                                                    else if id == 1 then state == Running(6780,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,NextPosition(index)],mem)
                                                                                                                                                                                    else if id == 2 then state == Running(6781,[3045624246,518,offset,length,ordered,128,kept,index,0,NextPosition(index),Position(index),length,offset],mem)
                                                                                                                                                                                    else if id == 3 then state == Running(6784,[3045624246,518,offset,length,ordered,128,kept,index,0,NextPosition(index),Position(index),length,offset,6792],mem)
                                                                                                                                                                                    else if id == 4 then state == Running(6785,[3045624246,518,offset,length,ordered,128,kept,index,0,6792,Position(index),length,offset,NextPosition(index)],mem)
                                                                                                                                                                                    else if id == 5 then state == Running(6786,[3045624246,518,offset,length,ordered,128,kept,index,0,6792,NextPosition(index),length,offset,Position(index)],mem)
                                                                                                                                                                                    else if id == 6 then state == Running(6787,[3045624246,518,offset,length,ordered,128,kept,index,0,6792,NextPosition(index),Position(index),offset,length],mem)
                                                                                                                                                                                    else if id == 7 then state == Running(6788,[3045624246,518,offset,length,ordered,128,kept,index,0,6792,NextPosition(index),Position(index),length,offset],mem)
                                                                                                                                                                                    else if id == 8 then state == Running(6791,[3045624246,518,offset,length,ordered,128,kept,index,0,6792,NextPosition(index),Position(index),length,offset,23623],mem)
                                                                                                                                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(0,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6779,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,NextPosition(index)],mem);
    assert Fetch(code,6779) == Op(91,6780,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(1,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6780,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,NextPosition(index)],mem);
    assert Fetch(code,6780) == Op(146,6781,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(2,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6781,[3045624246,518,offset,length,ordered,128,kept,index,0,NextPosition(index),Position(index),length,offset],mem);
    F.Push2(code,6781);
    assert Fetch(code,6781) == Op(97,6784,6792);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(3,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6784,[3045624246,518,offset,length,ordered,128,kept,index,0,NextPosition(index),Position(index),length,offset,6792],mem);
    assert Fetch(code,6784) == Op(147,6785,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(4,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6785,[3045624246,518,offset,length,ordered,128,kept,index,0,6792,Position(index),length,offset,NextPosition(index)],mem);
    assert Fetch(code,6785) == Op(146,6786,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(5,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6786,[3045624246,518,offset,length,ordered,128,kept,index,0,6792,NextPosition(index),length,offset,Position(index)],mem);
    assert Fetch(code,6786) == Op(145,6787,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(6,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6787,[3045624246,518,offset,length,ordered,128,kept,index,0,6792,NextPosition(index),Position(index),offset,length],mem);
    assert Fetch(code,6787) == Op(144,6788,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(7,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,ordered,kept,index,j,word,last,seen,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6788,[3045624246,518,offset,length,ordered,128,kept,index,0,6792,NextPosition(index),Position(index),length,offset],mem);
    F.Push2(code,6788);
    assert Fetch(code,6788) == Op(97,6791,23623);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last) && Good(8,state,offset,length,ordered,kept,index,j,word,last,seen,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23623,[3045624246,518,offset,length,ordered,128,kept,index,0,6792,NextPosition(index),Position(index),length,offset],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6791,[3045624246,518,offset,length,ordered,128,kept,index,0,6792,NextPosition(index),Position(index),length,offset,23623],mem);
    assert Fetch(code,6791) == Op(86,6792,0);
  }
  lemma Start(offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>)
    requires Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last)
    ensures Good(0,Running(6779,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,NextPosition(index)],mem),offset,length,ordered,kept,index,j,word,last,seen,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,ordered,kept,index,j,word,last,seen) && MemoryAdmitted(mem,j,last)
    ensures state == Running(23623,[3045624246,518,offset,length,ordered,128,kept,index,0,6792,NextPosition(index),Position(index),length,offset],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 10 && trace[0] == Running(6779,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,NextPosition(index)],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,ordered,kept,index,j,word,last,seen,mem);
    state := Running(6779,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,NextPosition(index)],mem);
    trace := [state];
    Advance0(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6779,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next0;
    Advance1(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6779,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next1;
    Advance2(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6779,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next2;
    Advance3(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6779,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next3;
    Advance4(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6779,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next4;
    Advance5(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6779,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next5;
    Advance6(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6779,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next6;
    Advance7(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(6779,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next7;
    Advance8(code,state,offset,length,ordered,kept,index,j,word,last,seen,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(6779,[3045624246,518,offset,length,ordered,128,kept,index,0,offset,Position(index),length,NextPosition(index)],mem);
    state := next8;
  }
}
