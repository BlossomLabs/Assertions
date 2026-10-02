// SPDX-License-Identifier: MIT
// Generated actual raw bytes decoder empty-rejection path.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeUniqueRawHeadShort {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import DS = BytecodeScanDecoderScalar
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  function OrderedWord(data: seq<Byte>): Word { DataWord(data,36) }
  function Head(data: seq<Byte>): Word { DataWord(data,4) }
  function HeadPosition(data: seq<Byte>): Word { ((Head(data) as nat)+4)%G.Modulus() }
  function Length(data: seq<Byte>): Word { DataWord(data,HeadPosition(data)) }
  function Offset(data: seq<Byte>): Word { ((Head(data) as nat)+36)%G.Modulus() }
  predicate Admitted(data: seq<Byte>) { 4 <= |data| < 0x10000000000000000 && |data| < 68 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[903] == 91 &&
                                              code[904] == 97 &&
                                              code[905] == 2 &&
                                              code[906] == 6 &&
                                              code[907] == 97 &&
                                              code[908] == 3 &&
                                              code[909] == 149 &&
                                              code[910] == 54 &&
                                              code[911] == 96 &&
                                              code[912] == 4 &&
                                              code[913] == 97 &&
                                              code[914] == 89 &&
                                              code[915] == 201 &&
                                              code[916] == 86 &&
                                              code[22985] == 91 &&
                                              code[22986] == 95 &&
                                              code[22987] == 95 &&
                                              code[22988] == 95 &&
                                              code[22989] == 96 &&
                                              code[22990] == 64 &&
                                              code[22991] == 132 &&
                                              code[22992] == 134 &&
                                              code[22993] == 3 &&
                                              code[22994] == 18 &&
                                              code[22995] == 21 &&
                                              code[22996] == 97 &&
                                              code[22997] == 89 &&
                                              code[22998] == 219 &&
                                              code[22999] == 87 &&
                                              code[23000] == 95 &&
                                              code[23001] == 95 &&
                                              code[23002] == 253 &&
                                              code[23003] == 91
  }
  function Destinations(): set<nat> { {22985,23003} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>) { Admitted(data) && (
                                                                                    if id == 0 then state == Running(903,[3045624246],mem)
                                                                                    else if id == 1 then state == Running(904,[3045624246],mem)
                                                                                    else if id == 2 then state == Running(907,[3045624246,518],mem)
                                                                                    else if id == 3 then state == Running(910,[3045624246,518,917],mem)
                                                                                    else if id == 4 then state == Running(911,[3045624246,518,917,|data|],mem)
                                                                                    else if id == 5 then state == Running(913,[3045624246,518,917,|data|,4],mem)
                                                                                    else if id == 6 then state == Running(916,[3045624246,518,917,|data|,4,22985],mem)
                                                                                    else if id == 7 then state == Running(22985,[3045624246,518,917,|data|,4],mem)
                                                                                    else if id == 8 then state == Running(22986,[3045624246,518,917,|data|,4],mem)
                                                                                    else if id == 9 then state == Running(22987,[3045624246,518,917,|data|,4,0],mem)
                                                                                    else if id == 10 then state == Running(22988,[3045624246,518,917,|data|,4,0,0],mem)
                                                                                    else if id == 11 then state == Running(22989,[3045624246,518,917,|data|,4,0,0,0],mem)
                                                                                    else if id == 12 then state == Running(22991,[3045624246,518,917,|data|,4,0,0,0,64],mem)
                                                                                    else if id == 13 then state == Running(22992,[3045624246,518,917,|data|,4,0,0,0,64,4],mem)
                                                                                    else if id == 14 then state == Running(22993,[3045624246,518,917,|data|,4,0,0,0,64,4,|data|],mem)
                                                                                    else if id == 15 then state == Running(22994,[3045624246,518,917,|data|,4,0,0,0,64,((|data| as nat)+G.Modulus()-(4 as nat))%G.Modulus()],mem)
                                                                                    else if id == 16 then state == Running(22995,[3045624246,518,917,|data|,4,0,0,0,1],mem)
                                                                                    else if id == 17 then state == Running(22996,[3045624246,518,917,|data|,4,0,0,0,0],mem)
                                                                                    else if id == 18 then state == Running(22999,[3045624246,518,917,|data|,4,0,0,0,0,23003],mem)
                                                                                    else if id == 19 then state == Running(23000,[3045624246,518,917,|data|,4,0,0,0],mem)
                                                                                    else if id == 20 then state == Running(23001,[3045624246,518,917,|data|,4,0,0,0,0],mem)
                                                                                    else if id == 21 then state == Running(23002,[3045624246,518,917,|data|,4,0,0,0,0,0],mem)
                                                                                    else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(0,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(903,[3045624246],mem);
    assert Fetch(code,903) == Op(91,904,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(1,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(904,[3045624246],mem);
    F.Push2(code,904);
    assert Fetch(code,904) == Op(97,907,518);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(2,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(907,[3045624246,518],mem);
    F.Push2(code,907);
    assert Fetch(code,907) == Op(97,910,917);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(3,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(910,[3045624246,518,917],mem);
    assert Fetch(code,910) == Op(54,911,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(4,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(911,[3045624246,518,917,|data|],mem);
    F.Push1(code,911);
    assert Fetch(code,911) == Op(96,913,4);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(5,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(913,[3045624246,518,917,|data|,4],mem);
    F.Push2(code,913);
    assert Fetch(code,913) == Op(97,916,22985);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(6,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(916,[3045624246,518,917,|data|,4,22985],mem);
    assert Fetch(code,916) == Op(86,917,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(7,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22985,[3045624246,518,917,|data|,4],mem);
    assert Fetch(code,22985) == Op(91,22986,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(8,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22986,[3045624246,518,917,|data|,4],mem);
    assert Fetch(code,22986) == Op(95,22987,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(9,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22987,[3045624246,518,917,|data|,4,0],mem);
    assert Fetch(code,22987) == Op(95,22988,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(10,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22988,[3045624246,518,917,|data|,4,0,0],mem);
    assert Fetch(code,22988) == Op(95,22989,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(11,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22989,[3045624246,518,917,|data|,4,0,0,0],mem);
    F.Push1(code,22989);
    assert Fetch(code,22989) == Op(96,22991,64);
  }
  lemma Advance12(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(12,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22991,[3045624246,518,917,|data|,4,0,0,0,64],mem);
    assert Fetch(code,22991) == Op(132,22992,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(13,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22992,[3045624246,518,917,|data|,4,0,0,0,64,4],mem);
    assert Fetch(code,22992) == Op(134,22993,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(14,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22993,[3045624246,518,917,|data|,4,0,0,0,64,4,|data|],mem);
    assert Fetch(code,22993) == Op(3,22994,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(15,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22994,[3045624246,518,917,|data|,4,0,0,0,64,((|data| as nat)+G.Modulus()-(4 as nat))%G.Modulus()],mem);
    assert Fetch(code,22994) == Op(18,22995,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(16,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22995,[3045624246,518,917,|data|,4,0,0,0,1],mem);
    assert Fetch(code,22995) == Op(21,22996,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(17,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22996,[3045624246,518,917,|data|,4,0,0,0,0],mem);
    F.Push2(code,22996);
    assert Fetch(code,22996) == Op(97,22999,23003);
  }
  lemma Advance18(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(18,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(22999,[3045624246,518,917,|data|,4,0,0,0,0,23003],mem);
    assert Fetch(code,22999) == Op(87,23000,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(19,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23000,[3045624246,518,917,|data|,4,0,0,0],mem);
    assert Fetch(code,23000) == Op(95,23001,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(20,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23001,[3045624246,518,917,|data|,4,0,0,0,0],mem);
    assert Fetch(code,23001) == Op(95,23002,0);
  }
  lemma Advance21(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good(21,state,data,mem)
    ensures state.Running? && |state.stack| <= 11 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Reverted([])
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23002,[3045624246,518,917,|data|,4,0,0,0,0,0],mem);
    assert Fetch(code,23002) == Op(253,23003,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>)
    requires Admitted(data)
    ensures Good(0,Running(903,[3045624246],mem),data,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data)
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 23 && trace[0] == Running(903,[3045624246],mem) && trace[|trace|-1] == state
  {
    Start(data,mem);
    state := Running(903,[3045624246],mem);
    trace := [state];
    Advance0(code,state,data,mem,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next0;
    Advance1(code,state,data,mem,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next1;
    Advance2(code,state,data,mem,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next2;
    Advance3(code,state,data,mem,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next3;
    Advance4(code,state,data,mem,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next4;
    Advance5(code,state,data,mem,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next5;
    Advance6(code,state,data,mem,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next6;
    Advance7(code,state,data,mem,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next7;
    Advance8(code,state,data,mem,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next8;
    Advance9(code,state,data,mem,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next9;
    Advance10(code,state,data,mem,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next10;
    Advance11(code,state,data,mem,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next11;
    Advance12(code,state,data,mem,value);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next12;
    Advance13(code,state,data,mem,value);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next13;
    Advance14(code,state,data,mem,value);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next14;
    Advance15(code,state,data,mem,value);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next15;
    Advance16(code,state,data,mem,value);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next16;
    Advance17(code,state,data,mem,value);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next17;
    Advance18(code,state,data,mem,value);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next18;
    Advance19(code,state,data,mem,value);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next19;
    Advance20(code,state,data,mem,value);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next20;
    Advance21(code,state,data,mem,value);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21];
    assert trace[0] == Running(903,[3045624246],mem);
    state := next21;
  }
}
