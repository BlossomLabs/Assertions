// SPDX-License-Identifier: MIT
// Generated pinned zipWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeZipAdmissionAllocationGuard {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeScanDecoderScalar
  predicate Admitted(a: Word, lengthA: Word, b: Word, lengthB: Word) { lengthA < 0x10000000000000000 && lengthB < 0x10000000000000000 && lengthA%32 == 0 && lengthB%32 == 0 && lengthA == lengthB && lengthA < 0x8000000000000000 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[2024] == 91 &&
                                              code[2025] == 96 &&
                                              code[2026] == 1 &&
                                              code[2027] == 96 &&
                                              code[2028] == 1 &&
                                              code[2029] == 96 &&
                                              code[2030] == 64 &&
                                              code[2031] == 27 &&
                                              code[2032] == 3 &&
                                              code[2033] == 129 &&
                                              code[2034] == 17 &&
                                              code[2035] == 21 &&
                                              code[2036] == 97 &&
                                              code[2037] == 7 &&
                                              code[2038] == 255 &&
                                              code[2039] == 87 &&
                                              code[2047] == 91
  }
  function Destinations(): set<nat> { {2047} }
  opaque predicate Good(id: nat, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>) { Admitted(a,lengthA,b,lengthB) && (
                                                                                                                   if id == 0 then state == Running(2024,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem)
                                                                                                                   else if id == 1 then state == Running(2025,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem)
                                                                                                                   else if id == 2 then state == Running(2027,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,1],mem)
                                                                                                                   else if id == 3 then state == Running(2029,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,1,1],mem)
                                                                                                                   else if id == 4 then state == Running(2031,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,1,1,64],mem)
                                                                                                                   else if id == 5 then state == Running(2032,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,1,18446744073709551616],mem)
                                                                                                                   else if id == 6 then state == Running(2033,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,18446744073709551615],mem)
                                                                                                                   else if id == 7 then state == Running(2034,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,18446744073709551615,lengthA*2],mem)
                                                                                                                   else if id == 8 then state == Running(2035,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,0],mem)
                                                                                                                   else if id == 9 then state == Running(2036,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,1],mem)
                                                                                                                   else if id == 10 then state == Running(2039,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,1,2047],mem)
                                                                                                                   else false) }
  lemma Advance0(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(0,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2024,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem);
    assert Fetch(code,2024) == Op(91,2025,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(1,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2025,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem);
    F.Push1(code,2025);
    assert Fetch(code,2025) == Op(96,2027,1);
  }
  lemma Advance2(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(2,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2027,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,1],mem);
    F.Push1(code,2027);
    assert Fetch(code,2027) == Op(96,2029,1);
  }
  lemma Advance3(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(3,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2029,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,1,1],mem);
    F.Push1(code,2029);
    assert Fetch(code,2029) == Op(96,2031,64);
  }
  lemma Advance4(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(4,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2031,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,1,1,64],mem);
    SC.DecoderLimit();
    assert Fetch(code,2031) == Op(27,2032,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(5,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2032,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,1,18446744073709551616],mem);
    assert Fetch(code,2032) == Op(3,2033,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(6,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2033,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,18446744073709551615],mem);
    assert Fetch(code,2033) == Op(129,2034,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(7,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2034,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,18446744073709551615,lengthA*2],mem);
    assert Fetch(code,2034) == Op(17,2035,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(8,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2035,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,0],mem);
    assert Fetch(code,2035) == Op(21,2036,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(9,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2036,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,1],mem);
    F.Push2(code,2036);
    assert Fetch(code,2036) == Op(97,2039,2047);
  }
  lemma Advance10(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(10,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(2047,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2039,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,1,2047],mem);
    assert Fetch(code,2039) == Op(87,2040,0);
  }
  lemma Start(a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>)
    requires Admitted(a,lengthA,b,lengthB)
    ensures Good(0,Running(2024,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem),a,lengthA,b,lengthB,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB)
    ensures state == Running(2047,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 12 && trace[0] == Running(2024,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem) && trace[|trace|-1] == state
  {
    Start(a,lengthA,b,lengthB,mem);
    state := Running(2024,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem);
    trace := [state];
    Advance0(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(2024,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem);
    state := next0;
    Advance1(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(2024,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem);
    state := next1;
    Advance2(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(2024,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem);
    state := next2;
    Advance3(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(2024,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem);
    state := next3;
    Advance4(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(2024,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem);
    state := next4;
    Advance5(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(2024,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem);
    state := next5;
    Advance6(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(2024,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem);
    state := next6;
    Advance7(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(2024,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem);
    state := next7;
    Advance8(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(2024,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem);
    state := next8;
    Advance9(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(2024,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem);
    state := next9;
    Advance10(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(2024,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2],mem);
    state := next10;
  }
}
