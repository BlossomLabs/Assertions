// SPDX-License-Identifier: MIT
// Generated pinned zipWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeZipAdmissionBothAlignedEqual {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeScanDecoderScalar
  predicate Admitted(a: Word, lengthA: Word, b: Word, lengthB: Word) { lengthA < 0x10000000000000000 && lengthB < 0x10000000000000000 && lengthA%32 == 0 && lengthB%32 == 0 && lengthA == lengthB }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[1903] == 91 &&
                                              code[1904] == 21 &&
                                              code[1905] == 97 &&
                                              code[1906] == 7 &&
                                              code[1907] == 144 &&
                                              code[1908] == 87 &&
                                              code[1936] == 91 &&
                                              code[1937] == 131 &&
                                              code[1938] == 130 &&
                                              code[1939] == 20 &&
                                              code[1940] == 97 &&
                                              code[1941] == 7 &&
                                              code[1942] == 207 &&
                                              code[1943] == 87 &&
                                              code[1999] == 91
  }
  function Destinations(): set<nat> { {1936,1999} }
  opaque predicate Good(id: nat, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>) { Admitted(a,lengthA,b,lengthB) && (
                                                                                                                   if id == 0 then state == Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem)
                                                                                                                   else if id == 1 then state == Running(1904,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem)
                                                                                                                   else if id == 2 then state == Running(1905,[269019481,518,a,lengthA,b,lengthB,96,1],mem)
                                                                                                                   else if id == 3 then state == Running(1908,[269019481,518,a,lengthA,b,lengthB,96,1,1936],mem)
                                                                                                                   else if id == 4 then state == Running(1936,[269019481,518,a,lengthA,b,lengthB,96],mem)
                                                                                                                   else if id == 5 then state == Running(1937,[269019481,518,a,lengthA,b,lengthB,96],mem)
                                                                                                                   else if id == 6 then state == Running(1938,[269019481,518,a,lengthA,b,lengthB,96,lengthA],mem)
                                                                                                                   else if id == 7 then state == Running(1939,[269019481,518,a,lengthA,b,lengthB,96,lengthA,lengthB],mem)
                                                                                                                   else if id == 8 then state == Running(1940,[269019481,518,a,lengthA,b,lengthB,96,1],mem)
                                                                                                                   else if id == 9 then state == Running(1943,[269019481,518,a,lengthA,b,lengthB,96,1,1999],mem)
                                                                                                                   else false) }
  lemma Advance0(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(0,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem);
    assert Fetch(code,1903) == Op(91,1904,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(1,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1904,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem);
    assert Fetch(code,1904) == Op(21,1905,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(2,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1905,[269019481,518,a,lengthA,b,lengthB,96,1],mem);
    F.Push2(code,1905);
    assert Fetch(code,1905) == Op(97,1908,1936);
  }
  lemma Advance3(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(3,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1908,[269019481,518,a,lengthA,b,lengthB,96,1,1936],mem);
    assert Fetch(code,1908) == Op(87,1909,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(4,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1936,[269019481,518,a,lengthA,b,lengthB,96],mem);
    assert Fetch(code,1936) == Op(91,1937,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(5,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1937,[269019481,518,a,lengthA,b,lengthB,96],mem);
    assert Fetch(code,1937) == Op(131,1938,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(6,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1938,[269019481,518,a,lengthA,b,lengthB,96,lengthA],mem);
    assert Fetch(code,1938) == Op(130,1939,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(7,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1939,[269019481,518,a,lengthA,b,lengthB,96,lengthA,lengthB],mem);
    assert Fetch(code,1939) == Op(20,1940,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(8,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1940,[269019481,518,a,lengthA,b,lengthB,96,1],mem);
    F.Push2(code,1940);
    assert Fetch(code,1940) == Op(97,1943,1999);
  }
  lemma Advance9(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(9,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(1999,[269019481,518,a,lengthA,b,lengthB,96],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1943,[269019481,518,a,lengthA,b,lengthB,96,1,1999],mem);
    assert Fetch(code,1943) == Op(87,1944,0);
  }
  lemma Start(a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>)
    requires Admitted(a,lengthA,b,lengthB)
    ensures Good(0,Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem),a,lengthA,b,lengthB,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB)
    ensures state == Running(1999,[269019481,518,a,lengthA,b,lengthB,96],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 11 && trace[0] == Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem) && trace[|trace|-1] == state
  {
    Start(a,lengthA,b,lengthB,mem);
    state := Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem);
    trace := [state];
    Advance0(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem);
    state := next0;
    Advance1(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem);
    state := next1;
    Advance2(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem);
    state := next2;
    Advance3(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem);
    state := next3;
    Advance4(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem);
    state := next4;
    Advance5(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem);
    state := next5;
    Advance6(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem);
    state := next6;
    Advance7(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem);
    state := next7;
    Advance8(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem);
    state := next8;
    Advance9(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem);
    state := next9;
  }
}
