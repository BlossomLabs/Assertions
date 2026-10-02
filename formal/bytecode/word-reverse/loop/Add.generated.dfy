// SPDX-License-Identifier: MIT
// Generated actual current Collections helper instructions; no compiler correctness axiom.
include "../../scans/Execution.dfy"
module BytecodeReverseHelperAdd {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  predicate Admitted(prefix: seq<Word>, a: Word, b: Word, ret: Word) { |prefix| <= 1000 && (a as nat)+(b as nat) < G.Modulus() && ret in {5891} }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[5891] == 91 &&
                                              code[13698] == 91 &&
                                              code[13699] == 146 &&
                                              code[13700] == 145 &&
                                              code[13701] == 80 &&
                                              code[13702] == 80 &&
                                              code[13703] == 86 &&
                                              code[23604] == 91 &&
                                              code[23605] == 128 &&
                                              code[23606] == 130 &&
                                              code[23607] == 1 &&
                                              code[23608] == 128 &&
                                              code[23609] == 130 &&
                                              code[23610] == 17 &&
                                              code[23611] == 21 &&
                                              code[23612] == 97 &&
                                              code[23613] == 53 &&
                                              code[23614] == 130 &&
                                              code[23615] == 87
  }
  function Destinations(): set<nat> { {5891,13698} }
  opaque predicate Good(id: nat, state: State, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, data: seq<Byte>) {
    Admitted(prefix,a,b,ret) && (
      if id == 0 then state == Running(23604,prefix+[ret,a,b],mem)
      else if id == 1 then state == Running(23605,prefix+[ret,a,b],mem)
      else if id == 2 then state == Running(23606,prefix+[ret,a,b,b],mem)
      else if id == 3 then state == Running(23607,prefix+[ret,a,b,b,a],mem)
      else if id == 4 then state == Running(23608,prefix+[ret,a,b,((a as nat)+(b as nat))%G.Modulus()],mem)
      else if id == 5 then state == Running(23609,prefix+[ret,a,b,((a as nat)+(b as nat))%G.Modulus(),((a as nat)+(b as nat))%G.Modulus()],mem)
      else if id == 6 then state == Running(23610,prefix+[ret,a,b,((a as nat)+(b as nat))%G.Modulus(),((a as nat)+(b as nat))%G.Modulus(),b],mem)
      else if id == 7 then state == Running(23611,prefix+[ret,a,b,((a as nat)+(b as nat))%G.Modulus(),0],mem)
      else if id == 8 then state == Running(23612,prefix+[ret,a,b,((a as nat)+(b as nat))%G.Modulus(),1],mem)
      else if id == 9 then state == Running(23615,prefix+[ret,a,b,((a as nat)+(b as nat))%G.Modulus(),1,13698],mem)
      else if id == 10 then state == Running(13698,prefix+[ret,a,b,((a as nat)+(b as nat))%G.Modulus()],mem)
      else if id == 11 then state == Running(13699,prefix+[ret,a,b,((a as nat)+(b as nat))%G.Modulus()],mem)
      else if id == 12 then state == Running(13700,prefix+[((a as nat)+(b as nat))%G.Modulus(),a,b,ret],mem)
      else if id == 13 then state == Running(13701,prefix+[((a as nat)+(b as nat))%G.Modulus(),ret,b,a],mem)
      else if id == 14 then state == Running(13702,prefix+[((a as nat)+(b as nat))%G.Modulus(),ret,b],mem)
      else if id == 15 then state == Running(13703,prefix+[((a as nat)+(b as nat))%G.Modulus(),ret],mem)
      else false)
  }
  lemma Advance0(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b,ret) && Good(0,state,prefix,a,b,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,prefix,a,b,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23604,prefix+[ret,a,b],mem);
    assert Fetch(code,23604) == Op(91,23605,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b,ret) && Good(1,state,prefix,a,b,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,prefix,a,b,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23605,prefix+[ret,a,b],mem);
    assert Fetch(code,23605) == Op(128,23606,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b,ret) && Good(2,state,prefix,a,b,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,prefix,a,b,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23606,prefix+[ret,a,b,b],mem);
    assert Fetch(code,23606) == Op(130,23607,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b,ret) && Good(3,state,prefix,a,b,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,prefix,a,b,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23607,prefix+[ret,a,b,b,a],mem);
    assert Fetch(code,23607) == Op(1,23608,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b,ret) && Good(4,state,prefix,a,b,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,prefix,a,b,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23608,prefix+[ret,a,b,((a as nat)+(b as nat))%G.Modulus()],mem);
    assert Fetch(code,23608) == Op(128,23609,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b,ret) && Good(5,state,prefix,a,b,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,prefix,a,b,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23609,prefix+[ret,a,b,((a as nat)+(b as nat))%G.Modulus(),((a as nat)+(b as nat))%G.Modulus()],mem);
    assert Fetch(code,23609) == Op(130,23610,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b,ret) && Good(6,state,prefix,a,b,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,prefix,a,b,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23610,prefix+[ret,a,b,((a as nat)+(b as nat))%G.Modulus(),((a as nat)+(b as nat))%G.Modulus(),b],mem);
    assert Fetch(code,23610) == Op(17,23611,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b,ret) && Good(7,state,prefix,a,b,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,prefix,a,b,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23611,prefix+[ret,a,b,((a as nat)+(b as nat))%G.Modulus(),0],mem);
    assert Fetch(code,23611) == Op(21,23612,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b,ret) && Good(8,state,prefix,a,b,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,prefix,a,b,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23612,prefix+[ret,a,b,((a as nat)+(b as nat))%G.Modulus(),1],mem);
    F.Push2(code,23612);
    assert Fetch(code,23612) == Op(97,23615,13698);
  }
  lemma Advance9(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b,ret) && Good(9,state,prefix,a,b,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,prefix,a,b,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23615,prefix+[ret,a,b,((a as nat)+(b as nat))%G.Modulus(),1,13698],mem);
    assert Fetch(code,23615) == Op(87,23616,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b,ret) && Good(10,state,prefix,a,b,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,prefix,a,b,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13698,prefix+[ret,a,b,((a as nat)+(b as nat))%G.Modulus()],mem);
    assert Fetch(code,13698) == Op(91,13699,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b,ret) && Good(11,state,prefix,a,b,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,prefix,a,b,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13699,prefix+[ret,a,b,((a as nat)+(b as nat))%G.Modulus()],mem);
    assert Fetch(code,13699) == Op(146,13700,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b,ret) && Good(12,state,prefix,a,b,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,prefix,a,b,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13700,prefix+[((a as nat)+(b as nat))%G.Modulus(),a,b,ret],mem);
    assert Fetch(code,13700) == Op(145,13701,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b,ret) && Good(13,state,prefix,a,b,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,prefix,a,b,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13701,prefix+[((a as nat)+(b as nat))%G.Modulus(),ret,b,a],mem);
    assert Fetch(code,13701) == Op(80,13702,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b,ret) && Good(14,state,prefix,a,b,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,prefix,a,b,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13702,prefix+[((a as nat)+(b as nat))%G.Modulus(),ret,b],mem);
    assert Fetch(code,13702) == Op(80,13703,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,a,b,ret) && Good(15,state,prefix,a,b,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(ret,prefix+[(a as nat)+(b as nat)],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13703,prefix+[((a as nat)+(b as nat))%G.Modulus(),ret],mem);
    assert Fetch(code,13703) == Op(86,13704,0);
  }
  lemma Start(prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, data: seq<Byte>)
    requires Admitted(prefix,a,b,ret)
    ensures Good(0,Running(23604,prefix+[ret,a,b],mem),prefix,a,b,ret,mem,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, prefix: seq<Word>, a: Word, b: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(prefix,a,b,ret)
    ensures state == Running(ret,prefix+[(a as nat)+(b as nat)],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 17 && trace[0] == Running(23604,prefix+[ret,a,b],mem) && trace[|trace|-1] == state
  {
    Start(prefix,a,b,ret,mem,data);
    state := Running(23604,prefix+[ret,a,b],mem);
    trace := [state];
    Advance0(code,state,prefix,a,b,ret,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,prefix,a,b,ret,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,prefix,a,b,ret,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,prefix,a,b,ret,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,prefix,a,b,ret,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,prefix,a,b,ret,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,prefix,a,b,ret,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,prefix,a,b,ret,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,prefix,a,b,ret,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,prefix,a,b,ret,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,prefix,a,b,ret,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
    Advance11(code,state,prefix,a,b,ret,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    state := next11;
    Advance12(code,state,prefix,a,b,ret,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    state := next12;
    Advance13(code,state,prefix,a,b,ret,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    state := next13;
    Advance14(code,state,prefix,a,b,ret,mem,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    state := next14;
    Advance15(code,state,prefix,a,b,ret,mem,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    state := next15;
  }
}
