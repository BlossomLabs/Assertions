// SPDX-License-Identifier: MIT
// Generated complete callback controls surrounding bytes-packing helper; GAS/call observations separate.
include "Mask.dfy"
include "../../scans/Execution.dfy"
module BytecodeApplyCallbackPackBefore {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import A = BytecodeApplyAddressMask
  import O = BytecodeApplyCallbackPackMask
  predicate Admitted(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word) { target < A.Bound() && 96 <= |mem| < G.Modulus() && |mem|%32 == 0 && Load(mem,64) == free && (free as nat)+length < G.Modulus() && |prefix| <= 1011 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[16909] == 144 &&
                                              code[16910] == 80 &&
                                              code[16911] == 95 &&
                                              code[16912] == 95 &&
                                              code[16913] == 134 &&
                                              code[16914] == 96 &&
                                              code[16915] == 1 &&
                                              code[16916] == 96 &&
                                              code[16917] == 1 &&
                                              code[16918] == 96 &&
                                              code[16919] == 160 &&
                                              code[16920] == 27 &&
                                              code[16921] == 3 &&
                                              code[16922] == 22 &&
                                              code[16923] == 134 &&
                                              code[16924] == 96 &&
                                              code[16925] == 64 &&
                                              code[16926] == 81 &&
                                              code[16927] == 97 &&
                                              code[16928] == 66 &&
                                              code[16929] == 40 &&
                                              code[16930] == 145 &&
                                              code[16931] == 144 &&
                                              code[16932] == 97 &&
                                              code[16933] == 94 &&
                                              code[16934] == 212 &&
                                              code[16935] == 86 &&
                                              code[24276] == 91
  }
  function Destinations(): set<nat> { {24276} }
  opaque predicate Good(id: nat,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word) { Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && (
                                                                                                                                                                                          if id == 0 then state == Running(16909,prefix+[12484,target,ptr,index,0,0,gasBefore],mem)
                                                                                                                                                                                          else if id == 1 then state == Running(16910,prefix+[12484,target,ptr,index,0,gasBefore,0],mem)
                                                                                                                                                                                          else if id == 2 then state == Running(16911,prefix+[12484,target,ptr,index,0,gasBefore],mem)
                                                                                                                                                                                          else if id == 3 then state == Running(16912,prefix+[12484,target,ptr,index,0,gasBefore,0],mem)
                                                                                                                                                                                          else if id == 4 then state == Running(16913,prefix+[12484,target,ptr,index,0,gasBefore,0,0],mem)
                                                                                                                                                                                          else if id == 5 then state == Running(16914,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target],mem)
                                                                                                                                                                                          else if id == 6 then state == Running(16916,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,1],mem)
                                                                                                                                                                                          else if id == 7 then state == Running(16918,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,1,1],mem)
                                                                                                                                                                                          else if id == 8 then state == Running(16920,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,1,1,160],mem)
                                                                                                                                                                                          else if id == 9 then state == Running(16921,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,1,1461501637330902918203684832716283019655932542976],mem)
                                                                                                                                                                                          else if id == 10 then state == Running(16922,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,1461501637330902918203684832716283019655932542975],mem)
                                                                                                                                                                                          else if id == 11 then state == Running(16923,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target],mem)
                                                                                                                                                                                          else if id == 12 then state == Running(16924,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,ptr],mem)
                                                                                                                                                                                          else if id == 13 then state == Running(16926,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,ptr,64],mem)
                                                                                                                                                                                          else if id == 14 then state == Running(16927,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,ptr,free],mem)
                                                                                                                                                                                          else if id == 15 then state == Running(16930,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,ptr,free,16936],mem)
                                                                                                                                                                                          else if id == 16 then state == Running(16931,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,16936,free,ptr],mem)
                                                                                                                                                                                          else if id == 17 then state == Running(16932,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,16936,ptr,free],mem)
                                                                                                                                                                                          else if id == 18 then state == Running(16935,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,16936,ptr,free,24276],mem)
                                                                                                                                                                                          else false) }
  lemma Advance0(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(0,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16909,prefix+[12484,target,ptr,index,0,0,gasBefore],mem);
    assert Fetch(code,16909) == Op(144,16910,0);
    reveal Step();
  }
  lemma Advance1(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(1,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16910,prefix+[12484,target,ptr,index,0,gasBefore,0],mem);
    assert Fetch(code,16910) == Op(80,16911,0);
    reveal Step();
  }
  lemma Advance2(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(2,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16911,prefix+[12484,target,ptr,index,0,gasBefore],mem);
    assert Fetch(code,16911) == Op(95,16912,0);
    reveal Step();
  }
  lemma Advance3(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(3,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16912,prefix+[12484,target,ptr,index,0,gasBefore,0],mem);
    assert Fetch(code,16912) == Op(95,16913,0);
    reveal Step();
  }
  lemma Advance4(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(4,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16913,prefix+[12484,target,ptr,index,0,gasBefore,0,0],mem);
    assert Fetch(code,16913) == Op(134,16914,0);
    reveal Step();
  }
  lemma Advance5(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(5,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16914,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target],mem);
    F.Push1(code,16914);
    assert Fetch(code,16914) == Op(96,16916,1);
    reveal Step();
  }
  lemma Advance6(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(6,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16916,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,1],mem);
    F.Push1(code,16916);
    assert Fetch(code,16916) == Op(96,16918,1);
    reveal Step();
  }
  lemma Advance7(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(7,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16918,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,1,1],mem);
    F.Push1(code,16918);
    assert Fetch(code,16918) == Op(96,16920,160);
    reveal Step();
  }
  lemma Advance8(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(8,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16920,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,1,1,160],mem);
    assert Fetch(code,16920) == Op(27,16921,0);
    reveal Step();
    A.Limit();
  }
  lemma Advance9(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(9,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16921,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,1,1461501637330902918203684832716283019655932542976],mem);
    assert Fetch(code,16921) == Op(3,16922,0);
    reveal Step();
  }
  lemma Advance10(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(10,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16922,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,1461501637330902918203684832716283019655932542975],mem);
    assert Fetch(code,16922) == Op(22,16923,0);
    assert state == Running(16922,(prefix+[12484,target,ptr,index,0,gasBefore,0,0])+[target,0xffffffffffffffffffffffffffffffffffffffff],mem);
    O.At(code,Destinations(),prefix+[12484,target,ptr,index,0,gasBefore,0,0],mem,target,value,data);
  }
  lemma Advance11(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(11,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16923,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target],mem);
    assert Fetch(code,16923) == Op(134,16924,0);
    reveal Step();
  }
  lemma Advance12(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(12,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16924,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,ptr],mem);
    F.Push1(code,16924);
    assert Fetch(code,16924) == Op(96,16926,64);
    reveal Step();
  }
  lemma Advance13(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(13,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16926,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,ptr,64],mem);
    assert Fetch(code,16926) == Op(81,16927,0);
    reveal Step();
  }
  lemma Advance14(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(14,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16927,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,ptr,free],mem);
    F.Push2(code,16927);
    assert Fetch(code,16927) == Op(97,16930,16936);
    reveal Step();
  }
  lemma Advance15(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(15,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16930,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,ptr,free,16936],mem);
    assert Fetch(code,16930) == Op(145,16931,0);
    reveal Step();
  }
  lemma Advance16(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(16,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16931,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,16936,free,ptr],mem);
    assert Fetch(code,16931) == Op(144,16932,0);
    reveal Step();
  }
  lemma Advance17(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(17,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16932,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,16936,ptr,free],mem);
    F.Push2(code,16932);
    assert Fetch(code,16932) == Op(97,16935,24276);
    reveal Step();
  }
  lemma Advance18(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(18,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(24276,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,16936,ptr,free],mem)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16935,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,16936,ptr,free,24276],mem);
    assert Fetch(code,16935) == Op(86,16936,0);
    reveal Step();
  }
  ghost method Block0(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(0,initial,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Good(15,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 16 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial; trace := [state];
    Advance0(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0); trace := trace+[next0]; state := next0;
    Advance1(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1); trace := trace+[next1]; state := next1;
    Advance2(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2); trace := trace+[next2]; state := next2;
    Advance3(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3); trace := trace+[next3]; state := next3;
    Advance4(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4); trace := trace+[next4]; state := next4;
    Advance5(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5); trace := trace+[next5]; state := next5;
    Advance6(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6); trace := trace+[next6]; state := next6;
    Advance7(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7); trace := trace+[next7]; state := next7;
    Advance8(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8); trace := trace+[next8]; state := next8;
    Advance9(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9); trace := trace+[next9]; state := next9;
    Advance10(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10); trace := trace+[next10]; state := next10;
    Advance11(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11); trace := trace+[next11]; state := next11;
    Advance12(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12); trace := trace+[next12]; state := next12;
    Advance13(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13); trace := trace+[next13]; state := next13;
    Advance14(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14); trace := trace+[next14]; state := next14;
  }
  ghost method Block1(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(15,initial,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures state == Running(24276,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,16936,ptr,free],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 5 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial; trace := [state];
    Advance15(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15); trace := trace+[next15]; state := next15;
    Advance16(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16); trace := trace+[next16]; state := next16;
    Advance17(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17); trace := trace+[next17]; state := next17;
    Advance18(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18); trace := trace+[next18]; state := next18;
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures state == Running(24276,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,16936,ptr,free],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 20 && trace[0] == Running(16909,prefix+[12484,target,ptr,index,0,0,gasBefore],mem) && trace[|trace|-1] == state
  { state := Running(16909,prefix+[12484,target,ptr,index,0,0,gasBefore],mem); trace := [state]; reveal Good();
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block1(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
