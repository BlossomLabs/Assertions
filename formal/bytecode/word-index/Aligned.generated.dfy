// SPDX-License-Identifier: MIT
// Generated pinned sum loop instructions between actual helper boundaries.
include "../scans/Execution.dfy"
module BytecodeIndexAligned {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  function Position(index: Word): Word { ((index as nat)*32)%G.Modulus() }
  function NextPosition(index: Word): Word { (((index as nat)+1)*32)%G.Modulus() }
  function WordOffset(offset: Word, index: Word): Word { ((offset as nat)+(index as nat)*32)%G.Modulus() }
  predicate Admitted(offset: Word, length: Word, needle: Word, index: Word, word: Word) { length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && index <= length/32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[8247] == 91 &&
                                              code[8248] == 21 &&
                                              code[8249] == 97 &&
                                              code[8250] == 32 &&
                                              code[8251] == 88 &&
                                              code[8252] == 87 &&
                                              code[8280] == 91 &&
                                              code[8281] == 95 &&
                                              code[8282] == 97 &&
                                              code[8283] == 32 &&
                                              code[8284] == 100 &&
                                              code[8285] == 96 &&
                                              code[8286] == 32 &&
                                              code[8287] == 133 &&
                                              code[8288] == 97 &&
                                              code[8289] == 92 &&
                                              code[8290] == 10 &&
                                              code[8291] == 86 &&
                                              code[23562] == 91
  }
  function Destinations(): set<nat> { {8280,23562} }
  opaque predicate Good(id: nat, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>) { Admitted(offset,length,needle,index,word) && (
                                                                                                                                      if id == 0 then state == Running(8247,[3904669827,604,offset,length,needle,0,length%32],mem)
                                                                                                                                      else if id == 1 then state == Running(8248,[3904669827,604,offset,length,needle,0,length%32],mem)
                                                                                                                                      else if id == 2 then state == Running(8249,[3904669827,604,offset,length,needle,0,1],mem)
                                                                                                                                      else if id == 3 then state == Running(8252,[3904669827,604,offset,length,needle,0,1,8280],mem)
                                                                                                                                      else if id == 4 then state == Running(8280,[3904669827,604,offset,length,needle,0],mem)
                                                                                                                                      else if id == 5 then state == Running(8281,[3904669827,604,offset,length,needle,0],mem)
                                                                                                                                      else if id == 6 then state == Running(8282,[3904669827,604,offset,length,needle,0,0],mem)
                                                                                                                                      else if id == 7 then state == Running(8285,[3904669827,604,offset,length,needle,0,0,8292],mem)
                                                                                                                                      else if id == 8 then state == Running(8287,[3904669827,604,offset,length,needle,0,0,8292,32],mem)
                                                                                                                                      else if id == 9 then state == Running(8288,[3904669827,604,offset,length,needle,0,0,8292,32,length],mem)
                                                                                                                                      else if id == 10 then state == Running(8291,[3904669827,604,offset,length,needle,0,0,8292,32,length,23562],mem)
                                                                                                                                      else false) }
  lemma Advance0(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(0,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8247,[3904669827,604,offset,length,needle,0,length%32],mem);
    assert Fetch(code,8247) == Op(91,8248,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(1,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8248,[3904669827,604,offset,length,needle,0,length%32],mem);
    assert Fetch(code,8248) == Op(21,8249,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(2,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8249,[3904669827,604,offset,length,needle,0,1],mem);
    F.Push2(code,8249);
    assert Fetch(code,8249) == Op(97,8252,8280);
  }
  lemma Advance3(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(3,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8252,[3904669827,604,offset,length,needle,0,1,8280],mem);
    assert Fetch(code,8252) == Op(87,8253,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(4,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8280,[3904669827,604,offset,length,needle,0],mem);
    assert Fetch(code,8280) == Op(91,8281,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(5,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8281,[3904669827,604,offset,length,needle,0],mem);
    assert Fetch(code,8281) == Op(95,8282,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(6,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8282,[3904669827,604,offset,length,needle,0,0],mem);
    F.Push2(code,8282);
    assert Fetch(code,8282) == Op(97,8285,8292);
  }
  lemma Advance7(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(7,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8285,[3904669827,604,offset,length,needle,0,0,8292],mem);
    F.Push1(code,8285);
    assert Fetch(code,8285) == Op(96,8287,32);
  }
  lemma Advance8(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(8,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8287,[3904669827,604,offset,length,needle,0,0,8292,32],mem);
    assert Fetch(code,8287) == Op(133,8288,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(9,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,offset,length,needle,index,word,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8288,[3904669827,604,offset,length,needle,0,0,8292,32,length],mem);
    F.Push2(code,8288);
    assert Fetch(code,8288) == Op(97,8291,23562);
  }
  lemma Advance10(code: seq<Byte>, state: State, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(offset,length,needle,index,word) && Good(10,state,offset,length,needle,index,word,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23562,[3904669827,604,offset,length,needle,0,0,8292,32,length],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(8291,[3904669827,604,offset,length,needle,0,0,8292,32,length,23562],mem);
    assert Fetch(code,8291) == Op(86,8292,0);
  }
  lemma Start(offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>)
    requires Admitted(offset,length,needle,index,word)
    ensures Good(0,Running(8247,[3904669827,604,offset,length,needle,0,length%32],mem),offset,length,needle,index,word,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, offset: Word, length: Word, needle: Word, index: Word, word: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(offset,length,needle,index,word)
    ensures state == Running(23562,[3904669827,604,offset,length,needle,0,0,8292,32,length],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 12 && trace[0] == Running(8247,[3904669827,604,offset,length,needle,0,length%32],mem) && trace[|trace|-1] == state
  {
    Start(offset,length,needle,index,word,mem);
    state := Running(8247,[3904669827,604,offset,length,needle,0,length%32],mem);
    trace := [state];
    Advance0(code,state,offset,length,needle,index,word,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,offset,length,needle,index,word,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,offset,length,needle,index,word,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,offset,length,needle,index,word,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,offset,length,needle,index,word,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,offset,length,needle,index,word,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,offset,length,needle,index,word,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,offset,length,needle,index,word,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,offset,length,needle,index,word,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,offset,length,needle,index,word,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,offset,length,needle,index,word,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
  }
}
