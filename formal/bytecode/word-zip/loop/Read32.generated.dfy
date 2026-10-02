// SPDX-License-Identifier: MIT
// Generated actual current Collections helper instructions; no compiler correctness axiom.
include "../../scans/Execution.dfy"
module BytecodeZipHelperRead32 {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  predicate Admitted(prefix: seq<Word>, offset: Word, ret: Word) { |prefix| <= 1000 && ret in {2161,2222} }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[2161] == 91 &&
                                              code[2222] == 91 &&
                                              code[13698] == 91 &&
                                              code[13699] == 146 &&
                                              code[13700] == 145 &&
                                              code[13701] == 80 &&
                                              code[13702] == 80 &&
                                              code[13703] == 86 &&
                                              code[23662] == 91 &&
                                              code[23663] == 128 &&
                                              code[23664] == 53 &&
                                              code[23665] == 96 &&
                                              code[23666] == 32 &&
                                              code[23667] == 131 &&
                                              code[23668] == 16 &&
                                              code[23669] == 21 &&
                                              code[23670] == 97 &&
                                              code[23671] == 53 &&
                                              code[23672] == 130 &&
                                              code[23673] == 87
  }
  function Destinations(): set<nat> { {2161,2222,13698} }
  opaque predicate Good(id: nat, state: State, prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, data: seq<Byte>) {
    Admitted(prefix,offset,ret) && (
      if id == 0 then state == Running(23662,prefix+[ret,32,offset],mem)
      else if id == 1 then state == Running(23663,prefix+[ret,32,offset],mem)
      else if id == 2 then state == Running(23664,prefix+[ret,32,offset,offset],mem)
      else if id == 3 then state == Running(23665,prefix+[ret,32,offset,DataWord(data,offset)],mem)
      else if id == 4 then state == Running(23667,prefix+[ret,32,offset,DataWord(data,offset),32],mem)
      else if id == 5 then state == Running(23668,prefix+[ret,32,offset,DataWord(data,offset),32,32],mem)
      else if id == 6 then state == Running(23669,prefix+[ret,32,offset,DataWord(data,offset),0],mem)
      else if id == 7 then state == Running(23670,prefix+[ret,32,offset,DataWord(data,offset),1],mem)
      else if id == 8 then state == Running(23673,prefix+[ret,32,offset,DataWord(data,offset),1,13698],mem)
      else if id == 9 then state == Running(13698,prefix+[ret,32,offset,DataWord(data,offset)],mem)
      else if id == 10 then state == Running(13699,prefix+[ret,32,offset,DataWord(data,offset)],mem)
      else if id == 11 then state == Running(13700,prefix+[DataWord(data,offset),32,offset,ret],mem)
      else if id == 12 then state == Running(13701,prefix+[DataWord(data,offset),ret,offset,32],mem)
      else if id == 13 then state == Running(13702,prefix+[DataWord(data,offset),ret,offset],mem)
      else if id == 14 then state == Running(13703,prefix+[DataWord(data,offset),ret],mem)
      else false)
  }
  lemma Advance0(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,ret) && Good(0,state,prefix,offset,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,prefix,offset,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23662,prefix+[ret,32,offset],mem);
    assert Fetch(code,23662) == Op(91,23663,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,ret) && Good(1,state,prefix,offset,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,prefix,offset,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23663,prefix+[ret,32,offset],mem);
    assert Fetch(code,23663) == Op(128,23664,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,ret) && Good(2,state,prefix,offset,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,prefix,offset,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23664,prefix+[ret,32,offset,offset],mem);
    assert Fetch(code,23664) == Op(53,23665,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,ret) && Good(3,state,prefix,offset,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,prefix,offset,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23665,prefix+[ret,32,offset,DataWord(data,offset)],mem);
    F.Push1(code,23665);
    assert Fetch(code,23665) == Op(96,23667,32);
  }
  lemma Advance4(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,ret) && Good(4,state,prefix,offset,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,prefix,offset,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23667,prefix+[ret,32,offset,DataWord(data,offset),32],mem);
    assert Fetch(code,23667) == Op(131,23668,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,ret) && Good(5,state,prefix,offset,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,prefix,offset,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23668,prefix+[ret,32,offset,DataWord(data,offset),32,32],mem);
    assert Fetch(code,23668) == Op(16,23669,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,ret) && Good(6,state,prefix,offset,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,prefix,offset,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23669,prefix+[ret,32,offset,DataWord(data,offset),0],mem);
    assert Fetch(code,23669) == Op(21,23670,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,ret) && Good(7,state,prefix,offset,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,prefix,offset,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23670,prefix+[ret,32,offset,DataWord(data,offset),1],mem);
    F.Push2(code,23670);
    assert Fetch(code,23670) == Op(97,23673,13698);
  }
  lemma Advance8(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,ret) && Good(8,state,prefix,offset,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,prefix,offset,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23673,prefix+[ret,32,offset,DataWord(data,offset),1,13698],mem);
    assert Fetch(code,23673) == Op(87,23674,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,ret) && Good(9,state,prefix,offset,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,prefix,offset,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13698,prefix+[ret,32,offset,DataWord(data,offset)],mem);
    assert Fetch(code,13698) == Op(91,13699,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,ret) && Good(10,state,prefix,offset,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,prefix,offset,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13699,prefix+[ret,32,offset,DataWord(data,offset)],mem);
    assert Fetch(code,13699) == Op(146,13700,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,ret) && Good(11,state,prefix,offset,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,prefix,offset,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13700,prefix+[DataWord(data,offset),32,offset,ret],mem);
    assert Fetch(code,13700) == Op(145,13701,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,ret) && Good(12,state,prefix,offset,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,prefix,offset,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13701,prefix+[DataWord(data,offset),ret,offset,32],mem);
    assert Fetch(code,13701) == Op(80,13702,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,ret) && Good(13,state,prefix,offset,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,prefix,offset,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13702,prefix+[DataWord(data,offset),ret,offset],mem);
    assert Fetch(code,13702) == Op(80,13703,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,offset,ret) && Good(14,state,prefix,offset,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(ret,prefix+[DataWord(data,offset)],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13703,prefix+[DataWord(data,offset),ret],mem);
    assert Fetch(code,13703) == Op(86,13704,0);
  }
  lemma Start(prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, data: seq<Byte>)
    requires Admitted(prefix,offset,ret)
    ensures Good(0,Running(23662,prefix+[ret,32,offset],mem),prefix,offset,ret,mem,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, prefix: seq<Word>, offset: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(prefix,offset,ret)
    ensures state == Running(ret,prefix+[DataWord(data,offset)],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 16 && trace[0] == Running(23662,prefix+[ret,32,offset],mem) && trace[|trace|-1] == state
  {
    Start(prefix,offset,ret,mem,data);
    state := Running(23662,prefix+[ret,32,offset],mem);
    trace := [state];
    Advance0(code,state,prefix,offset,ret,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,prefix,offset,ret,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,prefix,offset,ret,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,prefix,offset,ret,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,prefix,offset,ret,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,prefix,offset,ret,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,prefix,offset,ret,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,prefix,offset,ret,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,prefix,offset,ret,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,prefix,offset,ret,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,prefix,offset,ret,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
    Advance11(code,state,prefix,offset,ret,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    state := next11;
    Advance12(code,state,prefix,offset,ret,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    state := next12;
    Advance13(code,state,prefix,offset,ret,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    state := next13;
    Advance14(code,state,prefix,offset,ret,mem,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    state := next14;
  }
}
