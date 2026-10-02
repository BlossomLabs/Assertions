// SPDX-License-Identifier: MIT
// Generated actual iota allocation byte-length guard instructions.
include "Arithmetic.dfy"
include "../scans/DecoderScalar.dfy"
module BytecodeIotaAllocationLimit {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import A = BytecodeIotaArithmetic
  import SC = BytecodeScanDecoderScalar
  predicate Admitted(n: Word) { 0x800000000000000 <= n <= A.Limit() }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[5553] == 91 &&
                                              code[5554] == 96 &&
                                              code[5555] == 1 &&
                                              code[5556] == 96 &&
                                              code[5557] == 1 &&
                                              code[5558] == 96 &&
                                              code[5559] == 64 &&
                                              code[5560] == 27 &&
                                              code[5561] == 3 &&
                                              code[5562] == 129 &&
                                              code[5563] == 17 &&
                                              code[5564] == 21 &&
                                              code[5565] == 97 &&
                                              code[5566] == 21 &&
                                              code[5567] == 200 &&
                                              code[5568] == 87 &&
                                              code[5569] == 97 &&
                                              code[5570] == 21 &&
                                              code[5571] == 200 &&
                                              code[5572] == 97 &&
                                              code[5573] == 91 &&
                                              code[5574] == 58 &&
                                              code[5575] == 86 &&
                                              code[5576] == 91 &&
                                              code[23354] == 91
  }
  function Destinations(): set<nat> { {5576,23354} }
  opaque predicate Good(id: nat, state: State, n: Word) { Admitted(n) && (
                                                            if id == 0 then state == Running(5553,[2368205965,518,n,96,A.Product(n)],Store([],64,128))
                                                            else if id == 1 then state == Running(5554,[2368205965,518,n,96,A.Product(n)],Store([],64,128))
                                                            else if id == 2 then state == Running(5556,[2368205965,518,n,96,A.Product(n),1],Store([],64,128))
                                                            else if id == 3 then state == Running(5558,[2368205965,518,n,96,A.Product(n),1,1],Store([],64,128))
                                                            else if id == 4 then state == Running(5560,[2368205965,518,n,96,A.Product(n),1,1,64],Store([],64,128))
                                                            else if id == 5 then state == Running(5561,[2368205965,518,n,96,A.Product(n),1,18446744073709551616],Store([],64,128))
                                                            else if id == 6 then state == Running(5562,[2368205965,518,n,96,A.Product(n),18446744073709551615],Store([],64,128))
                                                            else if id == 7 then state == Running(5563,[2368205965,518,n,96,A.Product(n),18446744073709551615,A.Product(n)],Store([],64,128))
                                                            else if id == 8 then state == Running(5564,[2368205965,518,n,96,A.Product(n),1],Store([],64,128))
                                                            else if id == 9 then state == Running(5565,[2368205965,518,n,96,A.Product(n),0],Store([],64,128))
                                                            else if id == 10 then state == Running(5568,[2368205965,518,n,96,A.Product(n),0,5576],Store([],64,128))
                                                            else if id == 11 then state == Running(5569,[2368205965,518,n,96,A.Product(n)],Store([],64,128))
                                                            else if id == 12 then state == Running(5572,[2368205965,518,n,96,A.Product(n),5576],Store([],64,128))
                                                            else if id == 13 then state == Running(5575,[2368205965,518,n,96,A.Product(n),5576,23354],Store([],64,128))
                                                            else false) }
  lemma Advance0(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(0,state,n)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    A.Fit(n);
    SC.DecoderLimit();
    assert state == Running(5553,[2368205965,518,n,96,A.Product(n)],Store([],64,128));
    assert Fetch(code,5553) == Op(91,5554,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(1,state,n)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    A.Fit(n);
    SC.DecoderLimit();
    assert state == Running(5554,[2368205965,518,n,96,A.Product(n)],Store([],64,128));
    F.Push1(code,5554);
    assert Fetch(code,5554) == Op(96,5556,1);
  }
  lemma Advance2(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(2,state,n)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    A.Fit(n);
    SC.DecoderLimit();
    assert state == Running(5556,[2368205965,518,n,96,A.Product(n),1],Store([],64,128));
    F.Push1(code,5556);
    assert Fetch(code,5556) == Op(96,5558,1);
  }
  lemma Advance3(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(3,state,n)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    A.Fit(n);
    SC.DecoderLimit();
    assert state == Running(5558,[2368205965,518,n,96,A.Product(n),1,1],Store([],64,128));
    F.Push1(code,5558);
    assert Fetch(code,5558) == Op(96,5560,64);
  }
  lemma Advance4(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(4,state,n)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    A.Fit(n);
    SC.DecoderLimit();
    assert state == Running(5560,[2368205965,518,n,96,A.Product(n),1,1,64],Store([],64,128));
    assert Fetch(code,5560) == Op(27,5561,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(5,state,n)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    A.Fit(n);
    SC.DecoderLimit();
    assert state == Running(5561,[2368205965,518,n,96,A.Product(n),1,18446744073709551616],Store([],64,128));
    assert Fetch(code,5561) == Op(3,5562,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(6,state,n)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    A.Fit(n);
    SC.DecoderLimit();
    assert state == Running(5562,[2368205965,518,n,96,A.Product(n),18446744073709551615],Store([],64,128));
    assert Fetch(code,5562) == Op(129,5563,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(7,state,n)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    A.Fit(n);
    SC.DecoderLimit();
    assert state == Running(5563,[2368205965,518,n,96,A.Product(n),18446744073709551615,A.Product(n)],Store([],64,128));
    assert Fetch(code,5563) == Op(17,5564,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(8,state,n)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    A.Fit(n);
    SC.DecoderLimit();
    assert state == Running(5564,[2368205965,518,n,96,A.Product(n),1],Store([],64,128));
    assert Fetch(code,5564) == Op(21,5565,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(9,state,n)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    A.Fit(n);
    SC.DecoderLimit();
    assert state == Running(5565,[2368205965,518,n,96,A.Product(n),0],Store([],64,128));
    F.Push2(code,5565);
    assert Fetch(code,5565) == Op(97,5568,5576);
  }
  lemma Advance10(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(10,state,n)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    A.Fit(n);
    SC.DecoderLimit();
    assert state == Running(5568,[2368205965,518,n,96,A.Product(n),0,5576],Store([],64,128));
    assert Fetch(code,5568) == Op(87,5569,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(11,state,n)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    A.Fit(n);
    SC.DecoderLimit();
    assert state == Running(5569,[2368205965,518,n,96,A.Product(n)],Store([],64,128));
    F.Push2(code,5569);
    assert Fetch(code,5569) == Op(97,5572,5576);
  }
  lemma Advance12(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(12,state,n)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    A.Fit(n);
    SC.DecoderLimit();
    assert state == Running(5572,[2368205965,518,n,96,A.Product(n),5576],Store([],64,128));
    F.Push2(code,5572);
    assert Fetch(code,5572) == Op(97,5575,23354);
  }
  lemma Advance13(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(13,state,n)
    ensures state.Running? && |state.stack| <= 8 && |state.memory| == 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(23354,[2368205965,518,n,96,A.Product(n),5576],Store([],64,128))
  {
    reveal Matches(); reveal Good(); reveal Step();
    A.Fit(n);
    SC.DecoderLimit();
    assert state == Running(5575,[2368205965,518,n,96,A.Product(n),5576,23354],Store([],64,128));
    assert Fetch(code,5575) == Op(86,5576,0);
  }
  lemma Start(n: Word)
    requires Admitted(n)
    ensures Good(0,Running(5553,[2368205965,518,n,96,A.Product(n)],Store([],64,128)),n)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, n: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n)
    ensures state == Running(23354,[2368205965,518,n,96,A.Product(n),5576],Store([],64,128))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 15 && trace[0] == Running(5553,[2368205965,518,n,96,A.Product(n)],Store([],64,128)) && trace[|trace|-1] == state
  {
    Start(n);
    state := Running(5553,[2368205965,518,n,96,A.Product(n)],Store([],64,128));
    trace := [state];
    Advance0(code,state,n,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,n,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,n,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,n,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,n,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,n,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,n,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,n,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,n,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,n,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,n,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
    Advance11(code,state,n,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    state := next11;
    Advance12(code,state,n,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    state := next12;
    Advance13(code,state,n,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    state := next13;
  }
}
