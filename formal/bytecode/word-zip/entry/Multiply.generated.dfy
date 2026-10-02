// SPDX-License-Identifier: MIT
// Generated pinned zipWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeZipAdmissionMultiply {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeScanDecoderScalar
  predicate Admitted(a: Word, lengthA: Word, b: Word, lengthB: Word) { lengthA < 0x10000000000000000 && lengthB < 0x10000000000000000 && lengthA%32 == 0 && lengthB%32 == 0 && lengthA == lengthB }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[2011] == 91 &&
                                              code[2012] == 144 &&
                                              code[2013] == 80 &&
                                              code[2014] == 97 &&
                                              code[2015] == 7 &&
                                              code[2016] == 232 &&
                                              code[2017] == 133 &&
                                              code[2018] == 96 &&
                                              code[2019] == 2 &&
                                              code[2020] == 97 &&
                                              code[2021] == 92 &&
                                              code[2022] == 29 &&
                                              code[2023] == 86 &&
                                              code[23581] == 91
  }
  function Destinations(): set<nat> { {23581} }
  opaque predicate Good(id: nat, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>) { Admitted(a,lengthA,b,lengthB) && (
                                                                                                                   if id == 0 then state == Running(2011,[269019481,518,a,lengthA,b,lengthB,96,0,lengthA/32],mem)
                                                                                                                   else if id == 1 then state == Running(2012,[269019481,518,a,lengthA,b,lengthB,96,0,lengthA/32],mem)
                                                                                                                   else if id == 2 then state == Running(2013,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,0],mem)
                                                                                                                   else if id == 3 then state == Running(2014,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32],mem)
                                                                                                                   else if id == 4 then state == Running(2017,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,2024],mem)
                                                                                                                   else if id == 5 then state == Running(2018,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,2024,lengthA],mem)
                                                                                                                   else if id == 6 then state == Running(2020,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,2024,lengthA,2],mem)
                                                                                                                   else if id == 7 then state == Running(2023,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,2024,lengthA,2,23581],mem)
                                                                                                                   else false) }
  lemma Advance0(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(0,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2011,[269019481,518,a,lengthA,b,lengthB,96,0,lengthA/32],mem);
    assert Fetch(code,2011) == Op(91,2012,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(1,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2012,[269019481,518,a,lengthA,b,lengthB,96,0,lengthA/32],mem);
    assert Fetch(code,2012) == Op(144,2013,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(2,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2013,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,0],mem);
    assert Fetch(code,2013) == Op(80,2014,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(3,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2014,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32],mem);
    F.Push2(code,2014);
    assert Fetch(code,2014) == Op(97,2017,2024);
  }
  lemma Advance4(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(4,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2017,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,2024],mem);
    assert Fetch(code,2017) == Op(133,2018,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(5,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2018,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,2024,lengthA],mem);
    F.Push1(code,2018);
    assert Fetch(code,2018) == Op(96,2020,2);
  }
  lemma Advance6(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(6,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2020,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,2024,lengthA,2],mem);
    F.Push2(code,2020);
    assert Fetch(code,2020) == Op(97,2023,23581);
  }
  lemma Advance7(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(7,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23581,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,2024,lengthA,2],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2023,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,2024,lengthA,2,23581],mem);
    assert Fetch(code,2023) == Op(86,2024,0);
  }
  lemma Start(a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>)
    requires Admitted(a,lengthA,b,lengthB)
    ensures Good(0,Running(2011,[269019481,518,a,lengthA,b,lengthB,96,0,lengthA/32],mem),a,lengthA,b,lengthB,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB)
    ensures state == Running(23581,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,2024,lengthA,2],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 9 && trace[0] == Running(2011,[269019481,518,a,lengthA,b,lengthB,96,0,lengthA/32],mem) && trace[|trace|-1] == state
  {
    Start(a,lengthA,b,lengthB,mem);
    state := Running(2011,[269019481,518,a,lengthA,b,lengthB,96,0,lengthA/32],mem);
    trace := [state];
    Advance0(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(2011,[269019481,518,a,lengthA,b,lengthB,96,0,lengthA/32],mem);
    state := next0;
    Advance1(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(2011,[269019481,518,a,lengthA,b,lengthB,96,0,lengthA/32],mem);
    state := next1;
    Advance2(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(2011,[269019481,518,a,lengthA,b,lengthB,96,0,lengthA/32],mem);
    state := next2;
    Advance3(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(2011,[269019481,518,a,lengthA,b,lengthB,96,0,lengthA/32],mem);
    state := next3;
    Advance4(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(2011,[269019481,518,a,lengthA,b,lengthB,96,0,lengthA/32],mem);
    state := next4;
    Advance5(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(2011,[269019481,518,a,lengthA,b,lengthB,96,0,lengthA/32],mem);
    state := next5;
    Advance6(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(2011,[269019481,518,a,lengthA,b,lengthB,96,0,lengthA/32],mem);
    state := next6;
    Advance7(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(2011,[269019481,518,a,lengthA,b,lengthB,96,0,lengthA/32],mem);
    state := next7;
  }
}
