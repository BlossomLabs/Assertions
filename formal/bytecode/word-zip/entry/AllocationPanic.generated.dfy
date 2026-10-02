// SPDX-License-Identifier: MIT
// Generated reached exact error instructions; native proof pins error bytes.
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
include "../../scans/ErrorBytes.dfy"
include "../../scans/Scalar.dfy"
include "ErrorScalar.dfy"
include "ErrorMemory.dfy"
module BytecodeZipErrorAllocationPanic {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import R = BytecodeScanRepresentation
  import ER = BytecodeScanErrorBytes
  import SC = BytecodeScanScalar
  import E = BytecodeScanExecution
  import CS = BytecodeZipErrorScalar
  import EM = BytecodeZipErrorMemory
  predicate Admitted(a: Word, lengthA: Word, b: Word, lengthB: Word) { 0x8000000000000000 <= lengthA < 0x10000000000000000 && lengthA == lengthB && lengthA%32 == 0 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[23354] == 91 &&
                                              code[23355] == 99 &&
                                              code[23356] == 78 &&
                                              code[23357] == 72 &&
                                              code[23358] == 123 &&
                                              code[23359] == 113 &&
                                              code[23360] == 96 &&
                                              code[23361] == 224 &&
                                              code[23362] == 27 &&
                                              code[23363] == 95 &&
                                              code[23364] == 82 &&
                                              code[23365] == 96 &&
                                              code[23366] == 65 &&
                                              code[23367] == 96 &&
                                              code[23368] == 4 &&
                                              code[23369] == 82 &&
                                              code[23370] == 96 &&
                                              code[23371] == 36 &&
                                              code[23372] == 95 &&
                                              code[23373] == 253
  }
  function Destinations(): set<nat> { {} }
  opaque predicate Good(id: nat, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word) { Admitted(a,lengthA,b,lengthB) && (
                                                                                                   if id == 0 then state == Running(23354,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128))
                                                                                                   else if id == 1 then state == Running(23355,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128))
                                                                                                   else if id == 2 then state == Running(23360,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047,1313373041],Store([],64,128))
                                                                                                   else if id == 3 then state == Running(23362,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047,1313373041,224],Store([],64,128))
                                                                                                   else if id == 4 then state == Running(23363,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047,35408467139433450592217433187231851964531694900788300625387963629091585785856],Store([],64,128))
                                                                                                   else if id == 5 then state == Running(23364,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047,35408467139433450592217433187231851964531694900788300625387963629091585785856,0],Store([],64,128))
                                                                                                   else if id == 6 then state == Running(23365,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856))
                                                                                                   else if id == 7 then state == Running(23367,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047,65],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856))
                                                                                                   else if id == 8 then state == Running(23369,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047,65,4],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856))
                                                                                                   else if id == 9 then state == Running(23370,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65))
                                                                                                   else if id == 10 then state == Running(23372,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047,36],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65))
                                                                                                   else if id == 11 then state == Running(23373,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047,36,0],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65))
                                                                                                   else false) }
  lemma Advance0(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(0,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23354,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128));
    assert Fetch(code,23354) == Op(91,23355,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(1,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23355,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128));
    P.Push4(code,23355);
    assert Fetch(code,23355) == Op(99,23360,1313373041);
  }
  lemma Advance2(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(2,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23360,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047,1313373041],Store([],64,128));
    F.Push1(code,23360);
    assert Fetch(code,23360) == Op(96,23362,224);
  }
  lemma Advance3(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(3,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    SC.ErrorSelectors();
    assert state == Running(23362,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047,1313373041,224],Store([],64,128));
    assert Fetch(code,23362) == Op(27,23363,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(4,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23363,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047,35408467139433450592217433187231851964531694900788300625387963629091585785856],Store([],64,128));
    assert Fetch(code,23363) == Op(95,23364,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(5,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    assert state == Running(23364,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047,35408467139433450592217433187231851964531694900788300625387963629091585785856,0],Store([],64,128));
    assert Fetch(code,23364) == Op(82,23365,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(6,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    assert state == Running(23365,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856));
    F.Push1(code,23365);
    assert Fetch(code,23365) == Op(96,23367,65);
  }
  lemma Advance7(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(7,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    assert state == Running(23367,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047,65],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856));
    F.Push1(code,23367);
    assert Fetch(code,23367) == Op(96,23369,4);
  }
  lemma Advance8(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(8,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    R.StoredWord(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65);
    assert state == Running(23369,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047,65,4],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856));
    assert Fetch(code,23369) == Op(82,23370,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(9,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    R.StoredWord(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65);
    assert state == Running(23370,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65));
    F.Push1(code,23370);
    assert Fetch(code,23370) == Op(96,23372,36);
  }
  lemma Advance10(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(10,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,a,lengthA,b,lengthB)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    R.StoredWord(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65);
    assert state == Running(23372,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047,36],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65));
    assert Fetch(code,23372) == Op(95,23373,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB) && Good(11,state,a,lengthA,b,lengthB)
    ensures state.Running? && |state.stack| <= 12 && |state.memory| <= 192
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted(G.Encode(1313373041,4)+G.Encode(65,32))
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    R.StoredWord(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65);
    ER.PhysicalError(Store([],64,128),0,1313373041,35408467139433450592217433187231851964531694900788300625387963629091585785856,65);
    assert state == Running(23373,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047,36,0],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65));
    assert Fetch(code,23373) == Op(253,23374,0);
  }
  lemma Start(a: Word, lengthA: Word, b: Word, lengthB: Word)
    requires Admitted(a,lengthA,b,lengthB)
    ensures Good(0,Running(23354,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128)),a,lengthA,b,lengthB)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, a: Word, lengthA: Word, b: Word, lengthB: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(a,lengthA,b,lengthB)
    ensures state == Reverted(G.Encode(1313373041,4)+G.Encode(65,32))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 13 && trace[0] == Running(23354,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128)) && trace[|trace|-1] == state
  {
    Start(a,lengthA,b,lengthB);
    state := Running(23354,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128));
    trace := [state];
    Advance0(code,state,a,lengthA,b,lengthB,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(23354,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128));
    state := next0;
    Advance1(code,state,a,lengthA,b,lengthB,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(23354,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128));
    state := next1;
    Advance2(code,state,a,lengthA,b,lengthB,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(23354,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128));
    state := next2;
    Advance3(code,state,a,lengthA,b,lengthB,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(23354,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128));
    state := next3;
    Advance4(code,state,a,lengthA,b,lengthB,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(23354,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128));
    state := next4;
    Advance5(code,state,a,lengthA,b,lengthB,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(23354,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128));
    state := next5;
    Advance6(code,state,a,lengthA,b,lengthB,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(23354,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128));
    state := next6;
    Advance7(code,state,a,lengthA,b,lengthB,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(23354,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128));
    state := next7;
    Advance8(code,state,a,lengthA,b,lengthB,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(23354,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128));
    state := next8;
    Advance9(code,state,a,lengthA,b,lengthB,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(23354,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128));
    state := next9;
    Advance10(code,state,a,lengthA,b,lengthB,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(23354,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128));
    state := next10;
    Advance11(code,state,a,lengthA,b,lengthB,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(23354,[269019481,518,a,lengthA,b,lengthB,96,lengthA/32,lengthA*2,2047],Store([],64,128));
    state := next11;
  }
}
