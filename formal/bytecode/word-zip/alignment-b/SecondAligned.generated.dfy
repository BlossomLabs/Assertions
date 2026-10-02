// SPDX-License-Identifier: MIT
// Generated pinned zipWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeZipAdmissionSecondAligned {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeScanDecoderScalar
  predicate Admitted(a: Word, lengthA: Word, b: Word, lengthB: Word) { lengthA < 0x10000000000000000 && lengthB < 0x10000000000000000 && lengthA%32 == 0 && lengthB%32 == 0 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[1903] == 91 &&
                                              code[1904] == 21 &&
                                              code[1905] == 97 &&
                                              code[1906] == 7 &&
                                              code[1907] == 144 &&
                                              code[1908] == 87 &&
                                              code[1936] == 91
  }
  function Destinations(): set<nat> { {1936} }
  opaque predicate Good(id: nat, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>) { Admitted(a,lengthA,b,lengthB) && (
                                                                                                                   if id == 0 then state == Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem)
                                                                                                                   else if id == 1 then state == Running(1904,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem)
                                                                                                                   else if id == 2 then state == Running(1905,[269019481,518,a,lengthA,b,lengthB,96,1],mem)
                                                                                                                   else if id == 3 then state == Running(1908,[269019481,518,a,lengthA,b,lengthB,96,1,1936],mem)
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
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(1936,[269019481,518,a,lengthA,b,lengthB,96],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1908,[269019481,518,a,lengthA,b,lengthB,96,1,1936],mem);
    assert Fetch(code,1908) == Op(87,1909,0);
  }
  lemma Start(a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>)
    requires Admitted(a,lengthA,b,lengthB)
    ensures Good(0,Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem),a,lengthA,b,lengthB,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB)
    ensures state == Running(1936,[269019481,518,a,lengthA,b,lengthB,96],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 5 && trace[0] == Running(1903,[269019481,518,a,lengthA,b,lengthB,96,lengthB%32],mem) && trace[|trace|-1] == state
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
  }
}
