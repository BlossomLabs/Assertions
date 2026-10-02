// SPDX-License-Identifier: MIT
// Generated exact post-zero-copy output allocation tail; arbitrary lower prefix and memory preserved.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeApplyAllocationCopyTail {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import D = BytecodeScanDecoderScalar
  predicate Admitted(data: seq<Byte>, n: Word) { n < 0x800000000000000 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[12312] == 1 &&
                                              code[12313] == 144 &&
                                              code[12314] == 80 &&
                                              code[12315] == 91 &&
                                              code[12316] == 80 &&
                                              code[12317] == 145 &&
                                              code[12318] == 80 &&
                                              code[12319] == 95
  }
  function Destinations(): set<nat> { {12319} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word) { Admitted(data,n) && (
                                                                                                                                                                                                                                                                              if id == 0 then state == Running(12312,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,n,128,n*32,160,n*32],mem)
                                                                                                                                                                                                                                                                              else if id == 1 then state == Running(12313,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,n,128,n*32,n*32+160],mem)
                                                                                                                                                                                                                                                                              else if id == 2 then state == Running(12314,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,n,128,n*32+160,n*32],mem)
                                                                                                                                                                                                                                                                              else if id == 3 then state == Running(12315,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,n,128,n*32+160],mem)
                                                                                                                                                                                                                                                                              else if id == 4 then state == Running(12316,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,n,128,n*32+160],mem)
                                                                                                                                                                                                                                                                              else if id == 5 then state == Running(12317,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,n,128],mem)
                                                                                                                                                                                                                                                                              else if id == 6 then state == Running(12318,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,96],mem)
                                                                                                                                                                                                                                                                              else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, value: Word)
    requires Matches(code) && Admitted(data,n) && Good(0,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n) && |prefix| <= 1009
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12312,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,n,128,n*32,160,n*32],mem);
    assert Fetch(code,12312) == Op(1,12313,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, value: Word)
    requires Matches(code) && Admitted(data,n) && Good(1,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n) && |prefix| <= 1009
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12313,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,n,128,n*32,n*32+160],mem);
    assert Fetch(code,12313) == Op(144,12314,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, value: Word)
    requires Matches(code) && Admitted(data,n) && Good(2,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n) && |prefix| <= 1009
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12314,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,n,128,n*32+160,n*32],mem);
    assert Fetch(code,12314) == Op(80,12315,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, value: Word)
    requires Matches(code) && Admitted(data,n) && Good(3,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n) && |prefix| <= 1009
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12315,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,n,128,n*32+160],mem);
    assert Fetch(code,12315) == Op(91,12316,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, value: Word)
    requires Matches(code) && Admitted(data,n) && Good(4,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n) && |prefix| <= 1009
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12316,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,n,128,n*32+160],mem);
    assert Fetch(code,12316) == Op(80,12317,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, value: Word)
    requires Matches(code) && Admitted(data,n) && Good(5,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n) && |prefix| <= 1009
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12317,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,n,128],mem);
    assert Fetch(code,12317) == Op(145,12318,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, value: Word)
    requires Matches(code) && Admitted(data,n) && Good(6,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n) && |prefix| <= 1009
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(12319,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12318,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n,96],mem);
    assert Fetch(code,12318) == Op(80,12319,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word)
    requires Admitted(data,n)
    ensures Good(0,Running(12312,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,n,128,n*32,160,n*32],mem),data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n)
  { reveal Good(); }
  ghost method Block0(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data,n) && Good(0,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n) && |prefix| <= 1009
    ensures state == Running(12319,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 8 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance0(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0]; state := next0;
    Advance1(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1]; state := next1;
    Advance2(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2]; state := next2;
    Advance3(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3]; state := next3;
    Advance4(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4]; state := next4;
    Advance5(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5]; state := next5;
    Advance6(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6]; state := next6;
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, n: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data,n) && |prefix| <= 1009
    ensures state == Running(12319,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,n],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 8 && trace[0] == Running(12312,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,n,128,n*32,160,n*32],mem) && trace[|trace|-1] == state
  {
    Start(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n);
    state := Running(12312,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,n,128,n*32,160,n*32],mem); trace := [state];
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,n,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
