// SPDX-License-Identifier: MIT
// Generated pinned zipWords admission instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeZipAdmissionDivideCount {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeScanDecoderScalar
  predicate Admitted(a: Word, lengthA: Word, b: Word, lengthB: Word) { lengthA < 0x10000000000000000 && lengthB < 0x10000000000000000 && lengthA%32 == 0 && lengthB%32 == 0 && lengthA == lengthB }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[1999] == 91 &&
                                              code[2000] == 95 &&
                                              code[2001] == 97 &&
                                              code[2002] == 7 &&
                                              code[2003] == 219 &&
                                              code[2004] == 96 &&
                                              code[2005] == 32 &&
                                              code[2006] == 134 &&
                                              code[2007] == 97 &&
                                              code[2008] == 92 &&
                                              code[2009] == 10 &&
                                              code[2010] == 86 &&
                                              code[23562] == 91
  }
  function Destinations(): set<nat> { {23562} }
  opaque predicate Good(id: nat, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>) { Admitted(a,lengthA,b,lengthB) && (
                                                                                                                   if id == 0 then state == Running(1999,[269019481,518,a,lengthA,b,lengthB,96],mem)
                                                                                                                   else if id == 1 then state == Running(2000,[269019481,518,a,lengthA,b,lengthB,96],mem)
                                                                                                                   else if id == 2 then state == Running(2001,[269019481,518,a,lengthA,b,lengthB,96,0],mem)
                                                                                                                   else if id == 3 then state == Running(2004,[269019481,518,a,lengthA,b,lengthB,96,0,2011],mem)
                                                                                                                   else if id == 4 then state == Running(2006,[269019481,518,a,lengthA,b,lengthB,96,0,2011,32],mem)
                                                                                                                   else if id == 5 then state == Running(2007,[269019481,518,a,lengthA,b,lengthB,96,0,2011,32,lengthA],mem)
                                                                                                                   else if id == 6 then state == Running(2010,[269019481,518,a,lengthA,b,lengthB,96,0,2011,32,lengthA,23562],mem)
                                                                                                                   else false) }
  lemma Advance0(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(0,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(1999,[269019481,518,a,lengthA,b,lengthB,96],mem);
    assert Fetch(code,1999) == Op(91,2000,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(1,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2000,[269019481,518,a,lengthA,b,lengthB,96],mem);
    assert Fetch(code,2000) == Op(95,2001,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(2,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2001,[269019481,518,a,lengthA,b,lengthB,96,0],mem);
    F.Push2(code,2001);
    assert Fetch(code,2001) == Op(97,2004,2011);
  }
  lemma Advance3(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(3,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2004,[269019481,518,a,lengthA,b,lengthB,96,0,2011],mem);
    F.Push1(code,2004);
    assert Fetch(code,2004) == Op(96,2006,32);
  }
  lemma Advance4(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(4,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2006,[269019481,518,a,lengthA,b,lengthB,96,0,2011,32],mem);
    assert Fetch(code,2006) == Op(134,2007,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(5,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,a,lengthA,b,lengthB,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2007,[269019481,518,a,lengthA,b,lengthB,96,0,2011,32,lengthA],mem);
    F.Push2(code,2007);
    assert Fetch(code,2007) == Op(97,2010,23562);
  }
  lemma Advance6(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(6,state,a,lengthA,b,lengthB,mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23562,[269019481,518,a,lengthA,b,lengthB,96,0,2011,32,lengthA],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(2010,[269019481,518,a,lengthA,b,lengthB,96,0,2011,32,lengthA,23562],mem);
    assert Fetch(code,2010) == Op(86,2011,0);
  }
  lemma Start(a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>)
    requires Admitted(a,lengthA,b,lengthB)
    ensures Good(0,Running(1999,[269019481,518,a,lengthA,b,lengthB,96],mem),a,lengthA,b,lengthB,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, a: Word, lengthA: Word, b: Word, lengthB: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB)
    ensures state == Running(23562,[269019481,518,a,lengthA,b,lengthB,96,0,2011,32,lengthA],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 8 && trace[0] == Running(1999,[269019481,518,a,lengthA,b,lengthB,96],mem) && trace[|trace|-1] == state
  {
    Start(a,lengthA,b,lengthB,mem);
    state := Running(1999,[269019481,518,a,lengthA,b,lengthB,96],mem);
    trace := [state];
    Advance0(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(1999,[269019481,518,a,lengthA,b,lengthB,96],mem);
    state := next0;
    Advance1(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(1999,[269019481,518,a,lengthA,b,lengthB,96],mem);
    state := next1;
    Advance2(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(1999,[269019481,518,a,lengthA,b,lengthB,96],mem);
    state := next2;
    Advance3(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(1999,[269019481,518,a,lengthA,b,lengthB,96],mem);
    state := next3;
    Advance4(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(1999,[269019481,518,a,lengthA,b,lengthB,96],mem);
    state := next4;
    Advance5(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(1999,[269019481,518,a,lengthA,b,lengthB,96],mem);
    state := next5;
    Advance6(code,state,a,lengthA,b,lengthB,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(1999,[269019481,518,a,lengthA,b,lengthB,96],mem);
    state := next6;
  }
}
