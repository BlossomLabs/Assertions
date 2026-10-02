// SPDX-License-Identifier: MIT
// Generated pinned zipWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeZipAdmissionFirstAligned {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeScanDecoderScalar
  predicate Admitted(a: Word, lengthA: Word, b: Word, lengthB: Word) { lengthA < 0x10000000000000000 && lengthB < 0x10000000000000000 && lengthA%32 == 0 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[1859] == 91 &&
                                              code[1860] == 21 &&
                                              code[1861] == 97 &&
                                              code[1862] == 7 &&
                                              code[1863] == 100 &&
                                              code[1864] == 87 &&
                                              code[1892] == 91 &&
                                              code[1893] == 97 &&
                                              code[1894] == 7 &&
                                              code[1895] == 111 &&
                                              code[1896] == 96 &&
                                              code[1897] == 32 &&
                                              code[1898] == 131 &&
                                              code[1899] == 97 &&
                                              code[1900] == 91 &&
                                              code[1901] == 227 &&
                                              code[1902] == 86 &&
                                              code[23523] == 91
  }
  function Destinations(): set<nat> { {1892,23523} }
  opaque predicate Good(id: nat, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>) { Admitted(a,lengthA,b,lengthB) && (
                                                                                                                   if id == 0 then state == Running(1859,[269019481,518,a,lengthA,b,lengthB,96,lengthA%32],mem)
                                                                                                                   else if id == 1 then state == Running(1860,[269019481,518,a,lengthA,b,lengthB,96,lengthA%32],mem)
                                                                                                                   else if id == 2 then state == Running(1861,[269019481,518,a,lengthA,b,lengthB,96,1],mem)
                                                                                                                   else if id == 3 then state == Running(1864,[269019481,518,a,lengthA,b,lengthB,96,1,1892],mem)
                                                                                                                   else if id == 4 then state == Running(1892,[269019481,518,a,lengthA,b,lengthB,96],mem)
                                                                                                                   else if id == 5 then state == Running(1893,[269019481,518,a,lengthA,b,lengthB,96],mem)
                                                                                                                   else if id == 6 then state == Running(1896,[269019481,518,a,lengthA,b,lengthB,96,1903],mem)
                                                                                                                   else if id == 7 then state == Running(1898,[269019481,518,a,lengthA,b,lengthB,96,1903,32],mem)
                                                                                                                   else if id == 8 then state == Running(1899,[269019481,518,a,lengthA,b,lengthB,96,1903,32,lengthB],mem)
                                                                                                                   else if id == 9 then state == Running(1902,[269019481,518,a,lengthA,b,lengthB,96,1903,32,lengthB,23523],mem)
                                                                                                                   else false) }
  lemma Advance0(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(0,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1859,[269019481,518,a,lengthA,b,lengthB,96,lengthA%32],mem);
    assert Fetch(code,1859) == Op(91,1860,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(1,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1860,[269019481,518,a,lengthA,b,lengthB,96,lengthA%32],mem);
    assert Fetch(code,1860) == Op(21,1861,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(2,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1861,[269019481,518,a,lengthA,b,lengthB,96,1],mem);
    F.Push2(code,1861);
    assert Fetch(code,1861) == Op(97,1864,1892);
  }
  lemma Advance3(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(3,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1864,[269019481,518,a,lengthA,b,lengthB,96,1,1892],mem);
    assert Fetch(code,1864) == Op(87,1865,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(4,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1892,[269019481,518,a,lengthA,b,lengthB,96],mem);
    assert Fetch(code,1892) == Op(91,1893,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(5,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1893,[269019481,518,a,lengthA,b,lengthB,96],mem);
    F.Push2(code,1893);
    assert Fetch(code,1893) == Op(97,1896,1903);
  }
  lemma Advance6(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(6,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1896,[269019481,518,a,lengthA,b,lengthB,96,1903],mem);
    F.Push1(code,1896);
    assert Fetch(code,1896) == Op(96,1898,32);
  }
  lemma Advance7(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(7,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1898,[269019481,518,a,lengthA,b,lengthB,96,1903,32],mem);
    assert Fetch(code,1898) == Op(131,1899,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(8,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1899,[269019481,518,a,lengthA,b,lengthB,96,1903,32,lengthB],mem);
    F.Push2(code,1899);
    assert Fetch(code,1899) == Op(97,1902,23523);
  }
  lemma Advance9(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(9,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23523,[269019481,518,a,lengthA,b,lengthB,96,1903,32,lengthB],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1902,[269019481,518,a,lengthA,b,lengthB,96,1903,32,lengthB,23523],mem);
    assert Fetch(code,1902) == Op(86,1903,0);
  }
  lemma Start(a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>)
    requires Admitted(a,lengthA,b,lengthB)
    ensures Good(0,Running(1859,[269019481,518,a,lengthA,b,lengthB,96,lengthA%32],mem),a,lengthA,b,lengthB,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB)
    ensures state == Running(23523,[269019481,518,a,lengthA,b,lengthB,96,1903,32,lengthB],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 11 && trace[0] == Running(1859,[269019481,518,a,lengthA,b,lengthB,96,lengthA%32],mem) && trace[|trace|-1] == state
  {
    Start(a,lengthA,b,lengthB,mem);
    state := Running(1859,[269019481,518,a,lengthA,b,lengthB,96,lengthA%32],mem);
    trace := [state];
    Advance0(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(1859,[269019481,518,a,lengthA,b,lengthB,96,lengthA%32],mem);
    state := next0;
    Advance1(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(1859,[269019481,518,a,lengthA,b,lengthB,96,lengthA%32],mem);
    state := next1;
    Advance2(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(1859,[269019481,518,a,lengthA,b,lengthB,96,lengthA%32],mem);
    state := next2;
    Advance3(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(1859,[269019481,518,a,lengthA,b,lengthB,96,lengthA%32],mem);
    state := next3;
    Advance4(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(1859,[269019481,518,a,lengthA,b,lengthB,96,lengthA%32],mem);
    state := next4;
    Advance5(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(1859,[269019481,518,a,lengthA,b,lengthB,96,lengthA%32],mem);
    state := next5;
    Advance6(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(1859,[269019481,518,a,lengthA,b,lengthB,96,lengthA%32],mem);
    state := next6;
    Advance7(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(1859,[269019481,518,a,lengthA,b,lengthB,96,lengthA%32],mem);
    state := next7;
    Advance8(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(1859,[269019481,518,a,lengthA,b,lengthB,96,lengthA%32],mem);
    state := next8;
    Advance9(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(1859,[269019481,518,a,lengthA,b,lengthB,96,lengthA%32],mem);
    state := next9;
  }
}
