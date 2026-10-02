// SPDX-License-Identifier: MIT
// Generated pinned unzipWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeUnzipSegmentTail {
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
                                              code[6162] == 91 &&
                                              code[6273] == 91 &&
                                              code[6274] == 96 &&
                                              code[6275] == 32 &&
                                              code[6276] == 131 &&
                                              code[6277] == 129 &&
                                              code[6278] == 2 &&
                                              code[6279] == 135 &&
                                              code[6280] == 1 &&
                                              code[6281] == 1 &&
                                              code[6282] == 82 &&
                                              code[6283] == 80 &&
                                              code[6284] == 96 &&
                                              code[6285] == 1 &&
                                              code[6286] == 1 &&
                                              code[6287] == 97 &&
                                              code[6288] == 24 &&
                                              code[6289] == 18 &&
                                              code[6290] == 86
  }
  function Destinations(): set<nat> { {6162} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,lane,index,word) && (
                                                                                                                                    if id == 0 then state == Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem)
                                                                                                                                    else if id == 1 then state == Running(6274,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem)
                                                                                                                                    else if id == 2 then state == Running(6276,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word,32],mem)
                                                                                                                                    else if id == 3 then state == Running(6277,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word,32,index],mem)
                                                                                                                                    else if id == 4 then state == Running(6278,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word,32,index,32],mem)
                                                                                                                                    else if id == 5 then state == Running(6279,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word,32,((32 as nat)*(index as nat))%G.Modulus()],mem)
                                                                                                                                    else if id == 6 then state == Running(6280,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word,32,((32 as nat)*(index as nat))%G.Modulus(),128],mem)
                                                                                                                                    else if id == 7 then state == Running(6281,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word,32,((128 as nat)+(((32 as nat)*(index as nat))%G.Modulus() as nat))%G.Modulus()],mem)
                                                                                                                                    else if id == 8 then state == Running(6282,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word,((((128 as nat)+(((32 as nat)*(index as nat))%G.Modulus() as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem)
                                                                                                                                    else if id == 9 then state == Running(6283,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0],Store(mem,Target(index),word))
                                                                                                                                    else if id == 10 then state == Running(6284,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],Store(mem,Target(index),word))
                                                                                                                                    else if id == 11 then state == Running(6286,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,1],Store(mem,Target(index),word))
                                                                                                                                    else if id == 12 then state == Running(6287,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),((1 as nat)+(index as nat))%G.Modulus()],Store(mem,Target(index),word))
                                                                                                                                    else if id == 13 then state == Running(6290,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),((1 as nat)+(index as nat))%G.Modulus(),6162],Store(mem,Target(index),word))
                                                                                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(0,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem);
    assert Fetch(code,6273) == Op(91,6274,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(1,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6274,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem);
    F.Push1(code,6274);
    assert Fetch(code,6274) == Op(96,6276,32);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(2,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6276,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word,32],mem);
    assert Fetch(code,6276) == Op(131,6277,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(3,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6277,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word,32,index],mem);
    assert Fetch(code,6277) == Op(129,6278,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(4,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6278,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word,32,index,32],mem);
    assert Fetch(code,6278) == Op(2,6279,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(5,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6279,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word,32,((32 as nat)*(index as nat))%G.Modulus()],mem);
    assert Fetch(code,6279) == Op(135,6280,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(6,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6280,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word,32,((32 as nat)*(index as nat))%G.Modulus(),128],mem);
    assert Fetch(code,6280) == Op(1,6281,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(7,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6281,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word,32,((128 as nat)+(((32 as nat)*(index as nat))%G.Modulus() as nat))%G.Modulus()],mem);
    assert Fetch(code,6281) == Op(1,6282,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(8,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6282,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word,((((128 as nat)+(((32 as nat)*(index as nat))%G.Modulus() as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem);
    assert Fetch(code,6282) == Op(82,6283,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(9,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6283,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0],Store(mem,Target(index),word));
    assert Fetch(code,6283) == Op(80,6284,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(10,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6284,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index],Store(mem,Target(index),word));
    F.Push1(code,6284);
    assert Fetch(code,6284) == Op(96,6286,1);
  }
  lemma Advance11(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(11,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6286,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,1],Store(mem,Target(index),word));
    assert Fetch(code,6286) == Op(1,6287,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(12,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6287,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),((1 as nat)+(index as nat))%G.Modulus()],Store(mem,Target(index),word));
    F.Push2(code,6287);
    assert Fetch(code,6287) == Op(97,6290,6162);
  }
  lemma Advance13(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(13,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index+1],Store(mem,Target(index),word))
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6290,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),((1 as nat)+(index as nat))%G.Modulus(),6162],Store(mem,Target(index),word));
    assert Fetch(code,6290) == Op(86,6291,0);
  }
  lemma Start(offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,lane,index,word)
    ensures Good(0,Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem),offset,length,lane,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,lane,index,word)
    ensures state == Running(6162,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index+1],Store(mem,Target(index),word))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 15 && trace[0] == Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,lane,index,word,mem);
    state := Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem);
    trace := [state];
    Advance0(code,state,offset,length,lane,index,word,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem);
    state := next0;
    Advance1(code,state,offset,length,lane,index,word,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem);
    state := next1;
    Advance2(code,state,offset,length,lane,index,word,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem);
    state := next2;
    Advance3(code,state,offset,length,lane,index,word,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem);
    state := next3;
    Advance4(code,state,offset,length,lane,index,word,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem);
    state := next4;
    Advance5(code,state,offset,length,lane,index,word,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem);
    state := next5;
    Advance6(code,state,offset,length,lane,index,word,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem);
    state := next6;
    Advance7(code,state,offset,length,lane,index,word,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem);
    state := next7;
    Advance8(code,state,offset,length,lane,index,word,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem);
    state := next8;
    Advance9(code,state,offset,length,lane,index,word,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem);
    state := next9;
    Advance10(code,state,offset,length,lane,index,word,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem);
    state := next10;
    Advance11(code,state,offset,length,lane,index,word,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem);
    state := next11;
    Advance12(code,state,offset,length,lane,index,word,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem);
    state := next12;
    Advance13(code,state,offset,length,lane,index,word,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(6273,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,word],mem);
    state := next13;
  }
}
