// SPDX-License-Identifier: MIT
// Generated current sortWords scratch allocation segments.
include "../../scans/Execution.dfy"
include "../../scans/Representation.dfy"
include "../../scans/DecoderScalar.dfy"
include "MaskOpcode.dfy"
module BytecodeSortCountGuard {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import R = BytecodeScanRepresentation
  import SC = BytecodeIotaAllocationScalar
  import DS = BytecodeScanDecoderScalar
  import AM = BytecodeWordLengthMask
  import MO = BytecodeSortScratchAllocationMaskOpcode
  predicate Admitted(n: Word, mem: seq<Byte>, data: seq<Byte>) { n < 0x800000000000000 && 96 <= |mem| <= 192+2*n*32 && Round32(|mem|) == |mem| && |data| < G.Modulus() }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[3537] == 91 &&
                                              code[3538] == 144 &&
                                              code[3539] == 80 &&
                                              code[3540] == 95 &&
                                              code[3541] == 131 &&
                                              code[3542] == 96 &&
                                              code[3543] == 1 &&
                                              code[3544] == 96 &&
                                              code[3545] == 1 &&
                                              code[3546] == 96 &&
                                              code[3547] == 64 &&
                                              code[3548] == 27 &&
                                              code[3549] == 3 &&
                                              code[3550] == 129 &&
                                              code[3551] == 17 &&
                                              code[3552] == 21 &&
                                              code[3553] == 97 &&
                                              code[3554] == 13 &&
                                              code[3555] == 236 &&
                                              code[3556] == 87 &&
                                              code[3564] == 91
  }
  function Destinations(): set<nat> { {3564} }
  opaque predicate Good(id: nat, state: State, n: Word, offset: Word, mem: seq<Byte>, data: seq<Byte>) { Admitted(n,mem,data) && (
                                                                                                           if id == 0 then state == Running(3537,[785862473,518,offset,n*32,128,0,n],mem)
                                                                                                           else if id == 1 then state == Running(3538,[785862473,518,offset,n*32,128,0,n],mem)
                                                                                                           else if id == 2 then state == Running(3539,[785862473,518,offset,n*32,128,n,0],mem)
                                                                                                           else if id == 3 then state == Running(3540,[785862473,518,offset,n*32,128,n],mem)
                                                                                                           else if id == 4 then state == Running(3541,[785862473,518,offset,n*32,128,n,0],mem)
                                                                                                           else if id == 5 then state == Running(3542,[785862473,518,offset,n*32,128,n,0,n*32],mem)
                                                                                                           else if id == 6 then state == Running(3544,[785862473,518,offset,n*32,128,n,0,n*32,1],mem)
                                                                                                           else if id == 7 then state == Running(3546,[785862473,518,offset,n*32,128,n,0,n*32,1,1],mem)
                                                                                                           else if id == 8 then state == Running(3548,[785862473,518,offset,n*32,128,n,0,n*32,1,1,64],mem)
                                                                                                           else if id == 9 then state == Running(3549,[785862473,518,offset,n*32,128,n,0,n*32,1,18446744073709551616],mem)
                                                                                                           else if id == 10 then state == Running(3550,[785862473,518,offset,n*32,128,n,0,n*32,18446744073709551615],mem)
                                                                                                           else if id == 11 then state == Running(3551,[785862473,518,offset,n*32,128,n,0,n*32,18446744073709551615,n*32],mem)
                                                                                                           else if id == 12 then state == Running(3552,[785862473,518,offset,n*32,128,n,0,n*32,0],mem)
                                                                                                           else if id == 13 then state == Running(3553,[785862473,518,offset,n*32,128,n,0,n*32,1],mem)
                                                                                                           else if id == 14 then state == Running(3556,[785862473,518,offset,n*32,128,n,0,n*32,1,3564],mem)
                                                                                                           else false) }
  lemma Advance0(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(0,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3537,[785862473,518,offset,n*32,128,0,n],mem);
    assert Fetch(code,3537) == Op(91,3538,0);

  }
  lemma Advance1(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(1,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3538,[785862473,518,offset,n*32,128,0,n],mem);
    assert Fetch(code,3538) == Op(144,3539,0);

  }
  lemma Advance2(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(2,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3539,[785862473,518,offset,n*32,128,n,0],mem);
    assert Fetch(code,3539) == Op(80,3540,0);

  }
  lemma Advance3(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(3,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3540,[785862473,518,offset,n*32,128,n],mem);
    assert Fetch(code,3540) == Op(95,3541,0);

  }
  lemma Advance4(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(4,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3541,[785862473,518,offset,n*32,128,n,0],mem);
    assert Fetch(code,3541) == Op(131,3542,0);

  }
  lemma Advance5(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(5,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3542,[785862473,518,offset,n*32,128,n,0,n*32],mem);
    F.Push1(code,3542);
    assert Fetch(code,3542) == Op(96,3544,1);

  }
  lemma Advance6(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(6,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3544,[785862473,518,offset,n*32,128,n,0,n*32,1],mem);
    F.Push1(code,3544);
    assert Fetch(code,3544) == Op(96,3546,1);

  }
  lemma Advance7(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(7,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3546,[785862473,518,offset,n*32,128,n,0,n*32,1,1],mem);
    F.Push1(code,3546);
    assert Fetch(code,3546) == Op(96,3548,64);

  }
  lemma Advance8(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(8,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3548,[785862473,518,offset,n*32,128,n,0,n*32,1,1,64],mem);
    assert Fetch(code,3548) == Op(27,3549,0);
    DS.DecoderLimit();

  }
  lemma Advance9(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(9,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3549,[785862473,518,offset,n*32,128,n,0,n*32,1,18446744073709551616],mem);
    assert Fetch(code,3549) == Op(3,3550,0);

  }
  lemma Advance10(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(10,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3550,[785862473,518,offset,n*32,128,n,0,n*32,18446744073709551615],mem);
    assert Fetch(code,3550) == Op(129,3551,0);

  }
  lemma Advance11(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(11,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3551,[785862473,518,offset,n*32,128,n,0,n*32,18446744073709551615,n*32],mem);
    assert Fetch(code,3551) == Op(17,3552,0);

  }
  lemma Advance12(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(12,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3552,[785862473,518,offset,n*32,128,n,0,n*32,0],mem);
    assert Fetch(code,3552) == Op(21,3553,0);

  }
  lemma Advance13(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(13,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3553,[785862473,518,offset,n*32,128,n,0,n*32,1],mem);
    F.Push2(code,3553);
    assert Fetch(code,3553) == Op(97,3556,3564);

  }
  lemma Advance14(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(14,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3556,[785862473,518,offset,n*32,128,n,0,n*32,1,3564],mem);
    assert Fetch(code,3556) == Op(87,3557,0);

  }
  lemma Start(n: Word, offset: Word, mem: seq<Byte>, data: seq<Byte>)
    requires Admitted(n,mem,data)
    ensures Good(0,Running(3537,[785862473,518,offset,n*32,128,0,n],mem),n,offset,mem,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,mem,data)
    ensures state == Running(3564,[785862473,518,offset,n*32,128,n,0,n*32],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 16 && trace[0] == Running(3537,[785862473,518,offset,n*32,128,0,n],mem) && trace[|trace|-1] == state
  {
    Start(n,offset,mem,data);
    state := Running(3537,[785862473,518,offset,n*32,128,0,n],mem);
    trace := [state];
    Advance0(code,state,n,offset,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(3537,[785862473,518,offset,n*32,128,0,n],mem);
    state := next0;
    Advance1(code,state,n,offset,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(3537,[785862473,518,offset,n*32,128,0,n],mem);
    state := next1;
    Advance2(code,state,n,offset,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(3537,[785862473,518,offset,n*32,128,0,n],mem);
    state := next2;
    Advance3(code,state,n,offset,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(3537,[785862473,518,offset,n*32,128,0,n],mem);
    state := next3;
    Advance4(code,state,n,offset,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(3537,[785862473,518,offset,n*32,128,0,n],mem);
    state := next4;
    Advance5(code,state,n,offset,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(3537,[785862473,518,offset,n*32,128,0,n],mem);
    state := next5;
    Advance6(code,state,n,offset,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(3537,[785862473,518,offset,n*32,128,0,n],mem);
    state := next6;
    Advance7(code,state,n,offset,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(3537,[785862473,518,offset,n*32,128,0,n],mem);
    state := next7;
    Advance8(code,state,n,offset,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    assert trace[0] == Running(3537,[785862473,518,offset,n*32,128,0,n],mem);
    state := next8;
    Advance9(code,state,n,offset,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    assert trace[0] == Running(3537,[785862473,518,offset,n*32,128,0,n],mem);
    state := next9;
    Advance10(code,state,n,offset,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    assert trace[0] == Running(3537,[785862473,518,offset,n*32,128,0,n],mem);
    state := next10;
    Advance11(code,state,n,offset,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    assert trace[0] == Running(3537,[785862473,518,offset,n*32,128,0,n],mem);
    state := next11;
    Advance12(code,state,n,offset,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    assert trace[0] == Running(3537,[785862473,518,offset,n*32,128,0,n],mem);
    state := next12;
    Advance13(code,state,n,offset,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    assert trace[0] == Running(3537,[785862473,518,offset,n*32,128,0,n],mem);
    state := next13;
    Advance14(code,state,n,offset,mem,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    assert trace[0] == Running(3537,[785862473,518,offset,n*32,128,0,n],mem);
    state := next14;
  }
}
