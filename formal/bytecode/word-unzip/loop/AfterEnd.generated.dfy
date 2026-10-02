// SPDX-License-Identifier: MIT
// Generated pinned unzipWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeUnzipSegmentAfterEnd {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeUnzipLoopScalar
  function Count(length: Word, lane: Word): Word { if lane == 0 then (length/32+1)/2 else length/32/2 }
  function Twice(index: Word): Word { ((index as nat)*2)%G.Modulus() }
  function SourceIndex(index: Word, lane: Word): Word { ((index as nat)*2+(lane as nat))%G.Modulus() }
  function Position(index: Word, lane: Word): Word { (((index as nat)*2+(lane as nat))*32)%G.Modulus() }
  function NextPosition(index: Word, lane: Word): Word { (((index as nat)*2+(lane as nat))*32+32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word, lane: Word): Word { ((offset as nat)+((index as nat)*2+(lane as nat))*32)%G.Modulus() }
  function Target(index: Word): Word { (160+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, lane: Word, index: Word, word: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && lane <= 1 && index <= Count(length,lane) && index < Count(length,lane) }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6251] == 91 &&
                                              code[6252] == 146 &&
                                              code[6253] == 97 &&
                                              code[6254] == 24 &&
                                              code[6255] == 120 &&
                                              code[6256] == 147 &&
                                              code[6257] == 146 &&
                                              code[6258] == 145 &&
                                              code[6259] == 144 &&
                                              code[6260] == 97 &&
                                              code[6261] == 92 &&
                                              code[6262] == 71 &&
                                              code[6263] == 86 &&
                                              code[23623] == 91
  }
  function Destinations(): set<nat> { {23623} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,lane,index,word) && (
                                                                                                                                    if id == 0 then state == Running(6251,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,Position(index,lane),length,NextPosition(index,lane)],mem)
                                                                                                                                    else if id == 1 then state == Running(6252,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,Position(index,lane),length,NextPosition(index,lane)],mem)
                                                                                                                                    else if id == 2 then state == Running(6253,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,NextPosition(index,lane),Position(index,lane),length,offset],mem)
                                                                                                                                    else if id == 3 then state == Running(6256,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,NextPosition(index,lane),Position(index,lane),length,offset,6264],mem)
                                                                                                                                    else if id == 4 then state == Running(6257,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6264,Position(index,lane),length,offset,NextPosition(index,lane)],mem)
                                                                                                                                    else if id == 5 then state == Running(6258,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6264,NextPosition(index,lane),length,offset,Position(index,lane)],mem)
                                                                                                                                    else if id == 6 then state == Running(6259,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6264,NextPosition(index,lane),Position(index,lane),offset,length],mem)
                                                                                                                                    else if id == 7 then state == Running(6260,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6264,NextPosition(index,lane),Position(index,lane),length,offset],mem)
                                                                                                                                    else if id == 8 then state == Running(6263,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6264,NextPosition(index,lane),Position(index,lane),length,offset,23623],mem)
                                                                                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(0,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6251,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,Position(index,lane),length,NextPosition(index,lane)],mem);
    assert Fetch(code,6251) == Op(91,6252,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(1,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6252,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,Position(index,lane),length,NextPosition(index,lane)],mem);
    assert Fetch(code,6252) == Op(146,6253,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(2,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6253,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,NextPosition(index,lane),Position(index,lane),length,offset],mem);
    F.Push2(code,6253);
    assert Fetch(code,6253) == Op(97,6256,6264);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(3,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6256,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,NextPosition(index,lane),Position(index,lane),length,offset,6264],mem);
    assert Fetch(code,6256) == Op(147,6257,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(4,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6257,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6264,Position(index,lane),length,offset,NextPosition(index,lane)],mem);
    assert Fetch(code,6257) == Op(146,6258,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(5,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6258,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6264,NextPosition(index,lane),length,offset,Position(index,lane)],mem);
    assert Fetch(code,6258) == Op(145,6259,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(6,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6259,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6264,NextPosition(index,lane),Position(index,lane),offset,length],mem);
    assert Fetch(code,6259) == Op(144,6260,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(7,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6260,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6264,NextPosition(index,lane),Position(index,lane),length,offset],mem);
    F.Push2(code,6260);
    assert Fetch(code,6260) == Op(97,6263,23623);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(8,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23623,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6264,NextPosition(index,lane),Position(index,lane),length,offset],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6263,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6264,NextPosition(index,lane),Position(index,lane),length,offset,23623],mem);
    assert Fetch(code,6263) == Op(86,6264,0);
  }
  lemma Start(offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,lane,index,word)
    ensures Good(0,Running(6251,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,Position(index,lane),length,NextPosition(index,lane)],mem),offset,length,lane,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,lane,index,word)
    ensures state == Running(23623,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6264,NextPosition(index,lane),Position(index,lane),length,offset],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 10 && trace[0] == Running(6251,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,Position(index,lane),length,NextPosition(index,lane)],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,lane,index,word,mem);
    state := Running(6251,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,Position(index,lane),length,NextPosition(index,lane)],mem);
    trace := [state];
    Advance0(code,state,offset,length,lane,index,word,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6251,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,Position(index,lane),length,NextPosition(index,lane)],mem);
    state := next0;
    Advance1(code,state,offset,length,lane,index,word,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6251,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,Position(index,lane),length,NextPosition(index,lane)],mem);
    state := next1;
    Advance2(code,state,offset,length,lane,index,word,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6251,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,Position(index,lane),length,NextPosition(index,lane)],mem);
    state := next2;
    Advance3(code,state,offset,length,lane,index,word,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6251,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,Position(index,lane),length,NextPosition(index,lane)],mem);
    state := next3;
    Advance4(code,state,offset,length,lane,index,word,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6251,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,Position(index,lane),length,NextPosition(index,lane)],mem);
    state := next4;
    Advance5(code,state,offset,length,lane,index,word,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6251,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,Position(index,lane),length,NextPosition(index,lane)],mem);
    state := next5;
    Advance6(code,state,offset,length,lane,index,word,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6251,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,Position(index,lane),length,NextPosition(index,lane)],mem);
    state := next6;
    Advance7(code,state,offset,length,lane,index,word,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(6251,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,Position(index,lane),length,NextPosition(index,lane)],mem);
    state := next7;
    Advance8(code,state,offset,length,lane,index,word,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(6251,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,offset,Position(index,lane),length,NextPosition(index,lane)],mem);
    state := next8;
  }
}
