// SPDX-License-Identifier: MIT
// Generated complete callback controls surrounding bytes-packing helper; GAS/call observations separate.
include "Mask.dfy"
include "../../scans/Execution.dfy"
module BytecodeApplyCallbackPackAfter {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import A = BytecodeApplyAddressMask
  import O = BytecodeApplyCallbackPackMask
  predicate Admitted(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word) { target < A.Bound() && 96 <= |mem| < G.Modulus() && |mem|%32 == 0 && Load(mem,64) == free && (free as nat)+length < G.Modulus() && |prefix| <= 1009 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[16936] == 91 &&
                                              code[16937] == 95 &&
                                              code[16938] == 96 &&
                                              code[16939] == 64 &&
                                              code[16940] == 81 &&
                                              code[16941] == 128 &&
                                              code[16942] == 131 &&
                                              code[16943] == 3 &&
                                              code[16944] == 129 &&
                                              code[16945] == 133 &&
                                              code[16946] == 90
  }
  function Destinations(): set<nat> { {16946} }
  opaque predicate Good(id: nat,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word) { Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && (
                                                                                                                                                                                          if id == 0 then state == Running(16936,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length],mem)
                                                                                                                                                                                          else if id == 1 then state == Running(16937,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length],mem)
                                                                                                                                                                                          else if id == 2 then state == Running(16938,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length,0],mem)
                                                                                                                                                                                          else if id == 3 then state == Running(16940,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length,0,64],mem)
                                                                                                                                                                                          else if id == 4 then state == Running(16941,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length,0,free],mem)
                                                                                                                                                                                          else if id == 5 then state == Running(16942,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length,0,free,free],mem)
                                                                                                                                                                                          else if id == 6 then state == Running(16943,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length,0,free,free,free+length],mem)
                                                                                                                                                                                          else if id == 7 then state == Running(16944,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length,0,free,length],mem)
                                                                                                                                                                                          else if id == 8 then state == Running(16945,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length,0,free,length,free],mem)
                                                                                                                                                                                          else false) }
  lemma Advance0(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(0,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16936,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length],mem);
    assert Fetch(code,16936) == Op(91,16937,0);
    reveal Step();
  }
  lemma Advance1(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(1,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16937,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length],mem);
    assert Fetch(code,16937) == Op(95,16938,0);
    reveal Step();
  }
  lemma Advance2(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(2,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16938,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length,0],mem);
    F.Push1(code,16938);
    assert Fetch(code,16938) == Op(96,16940,64);
    reveal Step();
  }
  lemma Advance3(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(3,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16940,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length,0,64],mem);
    assert Fetch(code,16940) == Op(81,16941,0);
    reveal Step();
  }
  lemma Advance4(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(4,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16941,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length,0,free],mem);
    assert Fetch(code,16941) == Op(128,16942,0);
    reveal Step();
  }
  lemma Advance5(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(5,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16942,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length,0,free,free],mem);
    assert Fetch(code,16942) == Op(131,16943,0);
    reveal Step();
  }
  lemma Advance6(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(6,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16943,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length,0,free,free,free+length],mem);
    assert Fetch(code,16943) == Op(3,16944,0);
    reveal Step();
  }
  lemma Advance7(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(7,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16944,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length,0,free,length],mem);
    assert Fetch(code,16944) == Op(129,16945,0);
    reveal Step();
  }
  lemma Advance8(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(8,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(16946,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length,0,free,length,free,target],mem)
  {
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == Running(16945,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length,0,free,length,free],mem);
    assert Fetch(code,16945) == Op(133,16946,0);
    reveal Step();
  }
  ghost method Block0(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value) && Good(0,initial,data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures state == Running(16946,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length,0,free,length,free,target],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 10 && trace[0] == initial && trace[|trace|-1] == state
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
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,target,ptr,index,free,length,gasBefore,value)
    ensures state == Running(16946,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length,0,free,length,free,target],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 10 && trace[0] == Running(16936,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length],mem) && trace[|trace|-1] == state
  { state := Running(16936,prefix+[12484,target,ptr,index,0,gasBefore,0,0,target,free+length],mem); trace := [state]; reveal Good();
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,target,ptr,index,free,length,gasBefore,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
