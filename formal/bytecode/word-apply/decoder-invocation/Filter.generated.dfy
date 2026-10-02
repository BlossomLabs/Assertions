// SPDX-License-Identifier: MIT
// Generated actual public wrapper call into the shared raw decoder; arbitrary lower prefix and memory preserved.
include "../../scans/Execution.dfy"
module BytecodeApplyDecodeInvokeFilter {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted(data: seq<Byte>) { |data| < G.Modulus() }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[770] == 91 &&
                                              code[771] == 97 &&
                                              code[772] == 2 &&
                                              code[773] == 6 &&
                                              code[774] == 97 &&
                                              code[775] == 3 &&
                                              code[776] == 16 &&
                                              code[777] == 54 &&
                                              code[778] == 96 &&
                                              code[779] == 4 &&
                                              code[780] == 97 &&
                                              code[781] == 88 &&
                                              code[782] == 51 &&
                                              code[783] == 86 &&
                                              code[22579] == 91
  }
  function Destinations(): set<nat> { {22579} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>) { Admitted(data) && (
                                                                                                       if id == 0 then state == Running(770,prefix+[],mem)
                                                                                                       else if id == 1 then state == Running(771,prefix+[],mem)
                                                                                                       else if id == 2 then state == Running(774,prefix+[518],mem)
                                                                                                       else if id == 3 then state == Running(777,prefix+[518,784],mem)
                                                                                                       else if id == 4 then state == Running(778,prefix+[518,784,|data|],mem)
                                                                                                       else if id == 5 then state == Running(780,prefix+[518,784,|data|,4],mem)
                                                                                                       else if id == 6 then state == Running(783,prefix+[518,784,|data|,4,22579],mem)
                                                                                                       else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, value: Word)
    requires Matches(code) && Admitted(data) && Good(0,state,data,mem,prefix) && |prefix| <= 1019
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(770,prefix+[],mem);
    assert Fetch(code,770) == Op(91,771,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, value: Word)
    requires Matches(code) && Admitted(data) && Good(1,state,data,mem,prefix) && |prefix| <= 1019
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(771,prefix+[],mem);
    F.Push2(code,771);
    assert Fetch(code,771) == Op(97,774,518);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, value: Word)
    requires Matches(code) && Admitted(data) && Good(2,state,data,mem,prefix) && |prefix| <= 1019
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(774,prefix+[518],mem);
    F.Push2(code,774);
    assert Fetch(code,774) == Op(97,777,784);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, value: Word)
    requires Matches(code) && Admitted(data) && Good(3,state,data,mem,prefix) && |prefix| <= 1019
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(777,prefix+[518,784],mem);
    assert Fetch(code,777) == Op(54,778,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, value: Word)
    requires Matches(code) && Admitted(data) && Good(4,state,data,mem,prefix) && |prefix| <= 1019
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(778,prefix+[518,784,|data|],mem);
    F.Push1(code,778);
    assert Fetch(code,778) == Op(96,780,4);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, value: Word)
    requires Matches(code) && Admitted(data) && Good(5,state,data,mem,prefix) && |prefix| <= 1019
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(780,prefix+[518,784,|data|,4],mem);
    F.Push2(code,780);
    assert Fetch(code,780) == Op(97,783,22579);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, value: Word)
    requires Matches(code) && Admitted(data) && Good(6,state,data,mem,prefix) && |prefix| <= 1019
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(22579,prefix+[518,784,|data|,4],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(783,prefix+[518,784,|data|,4,22579],mem);
    assert Fetch(code,783) == Op(86,784,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>)
    requires Admitted(data)
    ensures Good(0,Running(770,prefix+[],mem),data,mem,prefix)
  { reveal Good(); }
  ghost method Block0(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && Good(0,initial,data,mem,prefix) && |prefix| <= 1019
    ensures state == Running(22579,prefix+[518,784,|data|,4],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 8 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance0(code,state,data,mem,prefix,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0]; state := next0;
    Advance1(code,state,data,mem,prefix,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1]; state := next1;
    Advance2(code,state,data,mem,prefix,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2]; state := next2;
    Advance3(code,state,data,mem,prefix,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3]; state := next3;
    Advance4(code,state,data,mem,prefix,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4]; state := next4;
    Advance5(code,state,data,mem,prefix,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5]; state := next5;
    Advance6(code,state,data,mem,prefix,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6]; state := next6;
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && |prefix| <= 1019
    ensures state == Running(22579,prefix+[518,784,|data|,4],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 8 && trace[0] == Running(770,prefix+[],mem) && trace[|trace|-1] == state
  {
    Start(data,mem,prefix);
    state := Running(770,prefix+[],mem); trace := [state];
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
