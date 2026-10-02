// SPDX-License-Identifier: MIT
// Generated reached exact error instructions; native proof pins error bytes.
include "../scans/Execution.dfy"
include "../scans/Push.dfy"
include "../scans/ErrorBytes.dfy"
include "../scans/Scalar.dfy"
module BytecodeIotaPanic41 {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import R = BytecodeScanRepresentation
  import ER = BytecodeScanErrorBytes
  import SC = BytecodeScanScalar
  import E = BytecodeScanExecution
  predicate Admitted(prefix: seq<Word>) { |prefix| <= 1000 }
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
  opaque predicate Good(id: nat, state: State, prefix: seq<Word>) { Admitted(prefix) && (
                                                                      if id == 0 then state == Running(23354,prefix+[],Store([],64,128))
                                                                      else if id == 1 then state == Running(23355,prefix+[],Store([],64,128))
                                                                      else if id == 2 then state == Running(23360,prefix+[1313373041],Store([],64,128))
                                                                      else if id == 3 then state == Running(23362,prefix+[1313373041,224],Store([],64,128))
                                                                      else if id == 4 then state == Running(23363,prefix+[35408467139433450592217433187231851964531694900788300625387963629091585785856],Store([],64,128))
                                                                      else if id == 5 then state == Running(23364,prefix+[35408467139433450592217433187231851964531694900788300625387963629091585785856,0],Store([],64,128))
                                                                      else if id == 6 then state == Running(23365,prefix+[],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856))
                                                                      else if id == 7 then state == Running(23367,prefix+[65],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856))
                                                                      else if id == 8 then state == Running(23369,prefix+[65,4],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856))
                                                                      else if id == 9 then state == Running(23370,prefix+[],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65))
                                                                      else if id == 10 then state == Running(23372,prefix+[36],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65))
                                                                      else if id == 11 then state == Running(23373,prefix+[36,0],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65))
                                                                      else false) }
  lemma Advance0(code: seq<Byte>, state: State, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix) && Good(0,state,prefix)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,prefix)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23354,prefix+[],Store([],64,128));
    assert Fetch(code,23354) == Op(91,23355,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix) && Good(1,state,prefix)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,prefix)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23355,prefix+[],Store([],64,128));
    P.Push4(code,23355);
    assert Fetch(code,23355) == Op(99,23360,1313373041);
  }
  lemma Advance2(code: seq<Byte>, state: State, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix) && Good(2,state,prefix)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,prefix)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23360,prefix+[1313373041],Store([],64,128));
    F.Push1(code,23360);
    assert Fetch(code,23360) == Op(96,23362,224);
  }
  lemma Advance3(code: seq<Byte>, state: State, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix) && Good(3,state,prefix)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,prefix)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    SC.ErrorSelectors();
    assert state == Running(23362,prefix+[1313373041,224],Store([],64,128));
    assert Fetch(code,23362) == Op(27,23363,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix) && Good(4,state,prefix)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,prefix)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    assert state == Running(23363,prefix+[35408467139433450592217433187231851964531694900788300625387963629091585785856],Store([],64,128));
    assert Fetch(code,23363) == Op(95,23364,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix) && Good(5,state,prefix)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,prefix)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    assert state == Running(23364,prefix+[35408467139433450592217433187231851964531694900788300625387963629091585785856,0],Store([],64,128));
    assert Fetch(code,23364) == Op(82,23365,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix) && Good(6,state,prefix)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,prefix)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    assert state == Running(23365,prefix+[],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856));
    F.Push1(code,23365);
    assert Fetch(code,23365) == Op(96,23367,65);
  }
  lemma Advance7(code: seq<Byte>, state: State, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix) && Good(7,state,prefix)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,prefix)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    assert state == Running(23367,prefix+[65],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856));
    F.Push1(code,23367);
    assert Fetch(code,23367) == Op(96,23369,4);
  }
  lemma Advance8(code: seq<Byte>, state: State, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix) && Good(8,state,prefix)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,prefix)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    R.StoredWord(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65);
    assert state == Running(23369,prefix+[65,4],Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856));
    assert Fetch(code,23369) == Op(82,23370,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix) && Good(9,state,prefix)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,prefix)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    R.StoredWord(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65);
    assert state == Running(23370,prefix+[],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65));
    F.Push1(code,23370);
    assert Fetch(code,23370) == Op(96,23372,36);
  }
  lemma Advance10(code: seq<Byte>, state: State, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix) && Good(10,state,prefix)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,prefix)
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    R.StoredWord(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65);
    assert state == Running(23372,prefix+[36],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65));
    assert Fetch(code,23372) == Op(95,23373,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix) && Good(11,state,prefix)
    ensures state.Running? && |state.stack| <= 1020 && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted(G.Encode(1313373041,4)+G.Encode(65,32))
  {
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856);
    R.StoredWord(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65);
    ER.PhysicalError(Store([],64,128),0,1313373041,35408467139433450592217433187231851964531694900788300625387963629091585785856,65);
    assert state == Running(23373,prefix+[36,0],Store(Store(Store([],64,128),0,35408467139433450592217433187231851964531694900788300625387963629091585785856),4,65));
    assert Fetch(code,23373) == Op(253,23374,0);
  }
  lemma Start(prefix: seq<Word>)
    requires Admitted(prefix)
    ensures Good(0,Running(23354,prefix+[],Store([],64,128)),prefix)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, prefix: seq<Word>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(prefix)
    ensures state == Reverted(G.Encode(1313373041,4)+G.Encode(65,32))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 13 && trace[0] == Running(23354,prefix+[],Store([],64,128)) && trace[|trace|-1] == state
  {
    Start(prefix);
    state := Running(23354,prefix+[],Store([],64,128));
    trace := [state];
    Advance0(code,state,prefix,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,prefix,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,prefix,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,prefix,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,prefix,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,prefix,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,prefix,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,prefix,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,prefix,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,prefix,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,prefix,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
    Advance11(code,state,prefix,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    state := next11;
  }
}
