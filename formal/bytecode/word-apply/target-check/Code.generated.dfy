// SPDX-License-Identifier: MIT
// Generated exact target admission with truthful EXTCODESIZE observation; arbitrary caller-local returndata preserved.
include "../../external-calls/Execution.dfy"
include "../address-kernel/Mask.dfy"
include "MaskOpcode.dfy"
include "Sequence.dfy"
module BytecodeApplyTargetCode {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import C = BytecodeCopyMachine
  import A = BytecodeApplyAddressMask
  import O = BytecodeApplyTargetMaskOpcode
  import Q = BytecodeApplyTargetSequence
  predicate Admitted(target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>) { X.Context(self) && target < A.Bound() && 0 < codeSize && |prefix| <= 1018 && cursor < |observations| && observations[cursor] == X.CodeSize(target,codeSize) }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[12334] == 91 &&
                                              code[15859] == 91 &&
                                              code[15860] == 128 &&
                                              code[15861] == 96 &&
                                              code[15862] == 1 &&
                                              code[15863] == 96 &&
                                              code[15864] == 1 &&
                                              code[15865] == 96 &&
                                              code[15866] == 160 &&
                                              code[15867] == 27 &&
                                              code[15868] == 3 &&
                                              code[15869] == 22 &&
                                              code[15870] == 59 &&
                                              code[15871] == 95 &&
                                              code[15872] == 3 &&
                                              code[15873] == 97 &&
                                              code[15874] == 62 &&
                                              code[15875] == 40 &&
                                              code[15876] == 87 &&
                                              code[15912] == 91 &&
                                              code[15913] == 80 &&
                                              code[15914] == 86
  }
  function Destinations(): set<nat> { {12334,15912} }
  opaque predicate Good(id: nat,frame: X.Frame,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>) { Admitted(target,codeSize,prefix,mem,returned,cursor,observations,self,value,data) && (
                                                                                                                                                                                                                                  if id == 0 then frame == X.Frame(Running(15859,prefix+[12334,target],mem),returned,cursor+0)
                                                                                                                                                                                                                                  else if id == 1 then frame == X.Frame(Running(15860,prefix+[12334,target],mem),returned,cursor+0)
                                                                                                                                                                                                                                  else if id == 2 then frame == X.Frame(Running(15861,prefix+[12334,target,target],mem),returned,cursor+0)
                                                                                                                                                                                                                                  else if id == 3 then frame == X.Frame(Running(15863,prefix+[12334,target,target,1],mem),returned,cursor+0)
                                                                                                                                                                                                                                  else if id == 4 then frame == X.Frame(Running(15865,prefix+[12334,target,target,1,1],mem),returned,cursor+0)
                                                                                                                                                                                                                                  else if id == 5 then frame == X.Frame(Running(15867,prefix+[12334,target,target,1,1,160],mem),returned,cursor+0)
                                                                                                                                                                                                                                  else if id == 6 then frame == X.Frame(Running(15868,prefix+[12334,target,target,1,1461501637330902918203684832716283019655932542976],mem),returned,cursor+0)
                                                                                                                                                                                                                                  else if id == 7 then frame == X.Frame(Running(15869,prefix+[12334,target,target,1461501637330902918203684832716283019655932542975],mem),returned,cursor+0)
                                                                                                                                                                                                                                  else if id == 8 then frame == X.Frame(Running(15870,prefix+[12334,target,target],mem),returned,cursor+0)
                                                                                                                                                                                                                                  else if id == 9 then frame == X.Frame(Running(15871,prefix+[12334,target,codeSize],mem),returned,cursor+1)
                                                                                                                                                                                                                                  else if id == 10 then frame == X.Frame(Running(15872,prefix+[12334,target,codeSize,0],mem),returned,cursor+1)
                                                                                                                                                                                                                                  else if id == 11 then frame == X.Frame(Running(15873,prefix+[12334,target,G.Modulus()-codeSize],mem),returned,cursor+1)
                                                                                                                                                                                                                                  else if id == 12 then frame == X.Frame(Running(15876,prefix+[12334,target,G.Modulus()-codeSize,15912],mem),returned,cursor+1)
                                                                                                                                                                                                                                  else if id == 13 then frame == X.Frame(Running(15912,prefix+[12334,target],mem),returned,cursor+1)
                                                                                                                                                                                                                                  else if id == 14 then frame == X.Frame(Running(15913,prefix+[12334,target],mem),returned,cursor+1)
                                                                                                                                                                                                                                  else if id == 15 then frame == X.Frame(Running(15914,prefix+[12334],mem),returned,cursor+1)
                                                                                                                                                                                                                                  else false) }
  lemma Advance0(code: seq<Byte>,frame: X.Frame,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(0,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(1,next,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
  {
    hide G.BitAnd();
    reveal Matches(); reveal Good();
    assert frame == X.Frame(Running(15859,prefix+[12334,target],mem),returned,cursor+0);
    assert Fetch(code,15859) == Op(91,15860,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
  }
  lemma Advance1(code: seq<Byte>,frame: X.Frame,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(1,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(2,next,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
  {
    hide G.BitAnd();
    reveal Matches(); reveal Good();
    assert frame == X.Frame(Running(15860,prefix+[12334,target],mem),returned,cursor+0);
    assert Fetch(code,15860) == Op(128,15861,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
  }
  lemma Advance2(code: seq<Byte>,frame: X.Frame,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(2,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(3,next,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
  {
    hide G.BitAnd();
    reveal Matches(); reveal Good();
    assert frame == X.Frame(Running(15861,prefix+[12334,target,target],mem),returned,cursor+0);
    F.Push1(code,15861);
    assert Fetch(code,15861) == Op(96,15863,1);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
  }
  lemma Advance3(code: seq<Byte>,frame: X.Frame,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(3,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(4,next,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
  {
    hide G.BitAnd();
    reveal Matches(); reveal Good();
    assert frame == X.Frame(Running(15863,prefix+[12334,target,target,1],mem),returned,cursor+0);
    F.Push1(code,15863);
    assert Fetch(code,15863) == Op(96,15865,1);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
  }
  lemma Advance4(code: seq<Byte>,frame: X.Frame,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(4,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(5,next,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
  {
    hide G.BitAnd();
    reveal Matches(); reveal Good();
    assert frame == X.Frame(Running(15865,prefix+[12334,target,target,1,1],mem),returned,cursor+0);
    F.Push1(code,15865);
    assert Fetch(code,15865) == Op(96,15867,160);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
  }
  lemma Advance5(code: seq<Byte>,frame: X.Frame,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(5,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(6,next,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
  {
    hide G.BitAnd();
    reveal Matches(); reveal Good();
    assert frame == X.Frame(Running(15867,prefix+[12334,target,target,1,1,160],mem),returned,cursor+0);
    assert Fetch(code,15867) == Op(27,15868,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
    A.Limit();
  }
  lemma Advance6(code: seq<Byte>,frame: X.Frame,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(6,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(7,next,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
  {
    hide G.BitAnd();
    reveal Matches(); reveal Good();
    assert frame == X.Frame(Running(15868,prefix+[12334,target,target,1,1461501637330902918203684832716283019655932542976],mem),returned,cursor+0);
    assert Fetch(code,15868) == Op(3,15869,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
  }
  lemma Advance7(code: seq<Byte>,frame: X.Frame,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(7,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(8,next,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
  {
    hide G.BitAnd();
    reveal Matches(); reveal Good();
    assert frame == X.Frame(Running(15869,prefix+[12334,target,target,1461501637330902918203684832716283019655932542975],mem),returned,cursor+0);
    assert Fetch(code,15869) == Op(22,15870,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    assert frame.state == Running(15869,(prefix+[12334,target])+[target,0xffffffffffffffffffffffffffffffffffffffff],mem);
    O.Step(code,Destinations(),prefix+[12334,target],mem,target,value,data);
    assert Step(code,Destinations(),frame.state,value,data) == Running(15870,prefix+[12334,target,target],mem);
  }
  lemma Advance8(code: seq<Byte>,frame: X.Frame,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(8,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(9,next,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
  {
    hide G.BitAnd();
    reveal Matches(); reveal Good();
    assert frame == X.Frame(Running(15870,prefix+[12334,target,target],mem),returned,cursor+0);
    assert Fetch(code,15870) == Op(59,15871,0);
    Q.Append(prefix,12334,target,target);
    Q.Append(prefix,12334,target,codeSize);
    assert frame == X.Frame(Running(15870,(prefix+[12334,target])+[target],mem),returned,cursor);
    assert X.Address(target) == target;
    X.CodeSizeStep(code,15870,prefix+[12334,target],mem,self,target,codeSize,returned,cursor,observations,value,data);
    assert X.Step(code,{},frame,self,value,data,observations) == X.Frame(Running(15871,prefix+[12334,target,codeSize],mem),returned,cursor+1);
    E.WidenStep(code,{},Destinations(),frame,self,value,data,observations);
  }
  lemma Advance9(code: seq<Byte>,frame: X.Frame,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(9,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(10,next,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
  {
    hide G.BitAnd();
    reveal Matches(); reveal Good();
    assert frame == X.Frame(Running(15871,prefix+[12334,target,codeSize],mem),returned,cursor+1);
    assert Fetch(code,15871) == Op(95,15872,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
  }
  lemma Advance10(code: seq<Byte>,frame: X.Frame,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(10,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(11,next,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
  {
    hide G.BitAnd();
    reveal Matches(); reveal Good();
    assert frame == X.Frame(Running(15872,prefix+[12334,target,codeSize,0],mem),returned,cursor+1);
    assert Fetch(code,15872) == Op(3,15873,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
  }
  lemma Advance11(code: seq<Byte>,frame: X.Frame,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(11,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(12,next,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
  {
    hide G.BitAnd();
    reveal Matches(); reveal Good();
    assert frame == X.Frame(Running(15873,prefix+[12334,target,G.Modulus()-codeSize],mem),returned,cursor+1);
    F.Push2(code,15873);
    assert Fetch(code,15873) == Op(97,15876,15912);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
  }
  lemma Advance12(code: seq<Byte>,frame: X.Frame,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(12,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(13,next,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
  {
    hide G.BitAnd();
    reveal Matches(); reveal Good();
    assert frame == X.Frame(Running(15876,prefix+[12334,target,G.Modulus()-codeSize,15912],mem),returned,cursor+1);
    assert Fetch(code,15876) == Op(87,15877,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
  }
  lemma Advance13(code: seq<Byte>,frame: X.Frame,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(13,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(14,next,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
  {
    hide G.BitAnd();
    reveal Matches(); reveal Good();
    assert frame == X.Frame(Running(15912,prefix+[12334,target],mem),returned,cursor+1);
    assert Fetch(code,15912) == Op(91,15913,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
  }
  lemma Advance14(code: seq<Byte>,frame: X.Frame,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(14,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); Good(15,next,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
  {
    hide G.BitAnd();
    reveal Matches(); reveal Good();
    assert frame == X.Frame(Running(15913,prefix+[12334,target],mem),returned,cursor+1);
    assert Fetch(code,15913) == Op(80,15914,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
  }
  lemma Advance15(code: seq<Byte>,frame: X.Frame,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(15,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); next == X.Frame(Running(12334,prefix,mem),returned,cursor+1)
  {
    hide G.BitAnd();
    reveal Matches(); reveal Good();
    assert frame == X.Frame(Running(15914,prefix+[12334],mem),returned,cursor+1);
    assert Fetch(code,15914) == Op(86,15915,0);
    X.Delegate(code,Destinations(),frame,self,value,data,observations);
    C.Delegate(code,Destinations(),frame.state,value,data);
    reveal Step();
  }
  ghost method Run(code: seq<Byte>,target: Word, codeSize: Word, prefix: seq<Word>, mem: seq<Byte>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted(target,codeSize,prefix,mem,returned,cursor,observations,self,value,data)
    ensures frame == X.Frame(Running(12334,prefix,mem),returned,cursor+1)
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == 17 && trace[0] == X.Frame(Running(15859,prefix+[12334,target],mem),returned,cursor) && trace[|trace|-1] == frame
  {
    frame := X.Frame(Running(15859,prefix+[12334,target],mem),returned,cursor); trace := [frame];
    reveal Good();
    Advance0(code,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data);
    var next0 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next0);
    trace := trace+[next0]; frame := next0;
    Advance1(code,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data);
    var next1 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next1);
    trace := trace+[next1]; frame := next1;
    Advance2(code,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data);
    var next2 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next2);
    trace := trace+[next2]; frame := next2;
    Advance3(code,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data);
    var next3 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next3);
    trace := trace+[next3]; frame := next3;
    Advance4(code,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data);
    var next4 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next4);
    trace := trace+[next4]; frame := next4;
    Advance5(code,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data);
    var next5 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next5);
    trace := trace+[next5]; frame := next5;
    Advance6(code,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data);
    var next6 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next6);
    trace := trace+[next6]; frame := next6;
    Advance7(code,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data);
    var next7 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next7);
    trace := trace+[next7]; frame := next7;
    Advance8(code,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data);
    var next8 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next8);
    trace := trace+[next8]; frame := next8;
    Advance9(code,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data);
    var next9 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next9);
    trace := trace+[next9]; frame := next9;
    Advance10(code,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data);
    var next10 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next10);
    trace := trace+[next10]; frame := next10;
    Advance11(code,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data);
    var next11 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next11);
    trace := trace+[next11]; frame := next11;
    Advance12(code,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data);
    var next12 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next12);
    trace := trace+[next12]; frame := next12;
    Advance13(code,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data);
    var next13 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next13);
    trace := trace+[next13]; frame := next13;
    Advance14(code,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data);
    var next14 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next14);
    trace := trace+[next14]; frame := next14;
    Advance15(code,frame,target,codeSize,prefix,mem,returned,cursor,observations,self,value,data);
    var next15 := X.Step(code,Destinations(),frame,self,value,data,observations);
    E.Extend(code,Destinations(),self,value,data,observations,trace,next15);
    trace := trace+[next15]; frame := next15;
  }
}
