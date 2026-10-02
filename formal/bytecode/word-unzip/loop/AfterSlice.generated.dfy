// SPDX-License-Identifier: MIT
// Generated pinned unzipWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeUnzipSegmentAfterSlice {
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
                                              code[6264] == 91 &&
                                              code[6265] == 97 &&
                                              code[6266] == 24 &&
                                              code[6267] == 129 &&
                                              code[6268] == 145 &&
                                              code[6269] == 97 &&
                                              code[6270] == 92 &&
                                              code[6271] == 110 &&
                                              code[6272] == 86 &&
                                              code[23662] == 91
  }
  function Destinations(): set<nat> { {23662} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,lane,index,word) && (
                                                                                                                                    if id == 0 then state == Running(6264,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,WordOffset(offset,index,lane),32],mem)
                                                                                                                                    else if id == 1 then state == Running(6265,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,WordOffset(offset,index,lane),32],mem)
                                                                                                                                    else if id == 2 then state == Running(6268,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,WordOffset(offset,index,lane),32,6273],mem)
                                                                                                                                    else if id == 3 then state == Running(6269,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6273,32,WordOffset(offset,index,lane)],mem)
                                                                                                                                    else if id == 4 then state == Running(6272,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6273,32,WordOffset(offset,index,lane),23662],mem)
                                                                                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(0,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6264,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,WordOffset(offset,index,lane),32],mem);
    assert Fetch(code,6264) == Op(91,6265,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(1,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6265,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,WordOffset(offset,index,lane),32],mem);
    F.Push2(code,6265);
    assert Fetch(code,6265) == Op(97,6268,6273);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(2,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6268,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,WordOffset(offset,index,lane),32,6273],mem);
    assert Fetch(code,6268) == Op(145,6269,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(3,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,lane,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6269,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6273,32,WordOffset(offset,index,lane)],mem);
    F.Push2(code,6269);
    assert Fetch(code,6269) == Op(97,6272,23662);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,lane,index,word) && Good(4,state,offset,length,lane,index,word,mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23662,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6273,32,WordOffset(offset,index,lane)],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(6272,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6273,32,WordOffset(offset,index,lane),23662],mem);
    assert Fetch(code,6272) == Op(86,6273,0);
  }
  lemma Start(offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,lane,index,word)
    ensures Good(0,Running(6264,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,WordOffset(offset,index,lane),32],mem),offset,length,lane,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, lane: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,lane,index,word)
    ensures state == Running(23662,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,6273,32,WordOffset(offset,index,lane)],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 6 && trace[0] == Running(6264,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,WordOffset(offset,index,lane),32],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,lane,index,word,mem);
    state := Running(6264,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,WordOffset(offset,index,lane),32],mem);
    trace := [state];
    Advance0(code,state,offset,length,lane,index,word,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(6264,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,WordOffset(offset,index,lane),32],mem);
    state := next0;
    Advance1(code,state,offset,length,lane,index,word,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(6264,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,WordOffset(offset,index,lane),32],mem);
    state := next1;
    Advance2(code,state,offset,length,lane,index,word,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(6264,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,WordOffset(offset,index,lane),32],mem);
    state := next2;
    Advance3(code,state,offset,length,lane,index,word,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(6264,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,WordOffset(offset,index,lane),32],mem);
    state := next3;
    Advance4(code,state,offset,length,lane,index,word,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(6264,[2989505972,518,offset,length,lane,128,length/32,Count(length,lane),index,0,WordOffset(offset,index,lane),32],mem);
    state := next4;
  }
}
