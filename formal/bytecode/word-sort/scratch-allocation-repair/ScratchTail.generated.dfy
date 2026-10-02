// SPDX-License-Identifier: MIT
// Generated current sortWords scratch allocation segments.
include "../../scans/Execution.dfy"
include "../../scans/Representation.dfy"
include "../../scans/DecoderScalar.dfy"
include "MaskOpcode.dfy"
module BytecodeSortScratchTail {
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
                                              code[3603] == 1 &&
                                              code[3604] == 144 &&
                                              code[3605] == 80 &&
                                              code[3606] == 91 &&
                                              code[3607] == 80 &&
                                              code[3608] == 144 &&
                                              code[3609] == 80 &&
                                              code[3610] == 96 &&
                                              code[3611] == 1
  }
  function Destinations(): set<nat> { {} }
  opaque predicate Good(id: nat, state: State, n: Word, offset: Word, mem: seq<Byte>, data: seq<Byte>) { Admitted(n,mem,data) && (
                                                                                                           if id == 0 then state == Running(3603,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32],mem)
                                                                                                           else if id == 1 then state == Running(3604,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+2*n*32],mem)
                                                                                                           else if id == 2 then state == Running(3605,[785862473,518,offset,n*32,128,n,0,160+n*32,192+2*n*32,n*32],mem)
                                                                                                           else if id == 3 then state == Running(3606,[785862473,518,offset,n*32,128,n,0,160+n*32,192+2*n*32],mem)
                                                                                                           else if id == 4 then state == Running(3607,[785862473,518,offset,n*32,128,n,0,160+n*32,192+2*n*32],mem)
                                                                                                           else if id == 5 then state == Running(3608,[785862473,518,offset,n*32,128,n,0,160+n*32],mem)
                                                                                                           else if id == 6 then state == Running(3609,[785862473,518,offset,n*32,128,n,160+n*32,0],mem)
                                                                                                           else if id == 7 then state == Running(3610,[785862473,518,offset,n*32,128,n,160+n*32],mem)
                                                                                                           else false) }
  lemma Advance0(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(0,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3603,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32],mem);
    assert Fetch(code,3603) == Op(1,3604,0);

  }
  lemma Advance1(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(1,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3604,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+2*n*32],mem);
    assert Fetch(code,3604) == Op(144,3605,0);

  }
  lemma Advance2(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(2,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3605,[785862473,518,offset,n*32,128,n,0,160+n*32,192+2*n*32,n*32],mem);
    assert Fetch(code,3605) == Op(80,3606,0);

  }
  lemma Advance3(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(3,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3606,[785862473,518,offset,n*32,128,n,0,160+n*32,192+2*n*32],mem);
    assert Fetch(code,3606) == Op(91,3607,0);

  }
  lemma Advance4(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(4,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3607,[785862473,518,offset,n*32,128,n,0,160+n*32,192+2*n*32],mem);
    assert Fetch(code,3607) == Op(80,3608,0);

  }
  lemma Advance5(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(5,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3608,[785862473,518,offset,n*32,128,n,0,160+n*32],mem);
    assert Fetch(code,3608) == Op(144,3609,0);

  }
  lemma Advance6(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(6,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,n,offset,mem,data)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3609,[785862473,518,offset,n*32,128,n,160+n*32,0],mem);
    assert Fetch(code,3609) == Op(80,3610,0);

  }
  lemma Advance7(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem,data) && Good(7,state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= 11 && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(3612,[785862473,518,offset,n*32,128,n,160+n*32,1],mem)
  {
    reveal Matches(); reveal Good();
    reveal Step();
    assert state == Running(3610,[785862473,518,offset,n*32,128,n,160+n*32],mem);
    F.Push1(code,3610);
    assert Fetch(code,3610) == Op(96,3612,1);

  }
  lemma Start(n: Word, offset: Word, mem: seq<Byte>, data: seq<Byte>)
    requires Admitted(n,mem,data)
    ensures Good(0,Running(3603,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32],mem),n,offset,mem,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,mem,data)
    ensures state == Running(3612,[785862473,518,offset,n*32,128,n,160+n*32,1],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 9 && trace[0] == Running(3603,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32],mem) && trace[|trace|-1] == state
  {
    Start(n,offset,mem,data);
    state := Running(3603,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32],mem);
    trace := [state];
    Advance0(code,state,n,offset,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    assert trace[0] == Running(3603,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32],mem);
    state := next0;
    Advance1(code,state,n,offset,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    assert trace[0] == Running(3603,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32],mem);
    state := next1;
    Advance2(code,state,n,offset,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    assert trace[0] == Running(3603,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32],mem);
    state := next2;
    Advance3(code,state,n,offset,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    assert trace[0] == Running(3603,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32],mem);
    state := next3;
    Advance4(code,state,n,offset,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    assert trace[0] == Running(3603,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32],mem);
    state := next4;
    Advance5(code,state,n,offset,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    assert trace[0] == Running(3603,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32],mem);
    state := next5;
    Advance6(code,state,n,offset,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    assert trace[0] == Running(3603,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32],mem);
    state := next6;
    Advance7(code,state,n,offset,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    assert trace[0] == Running(3603,[785862473,518,offset,n*32,128,n,0,160+n*32,n*32,192+n*32,n*32],mem);
    state := next7;
  }
}
