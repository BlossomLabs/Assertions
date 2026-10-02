// SPDX-License-Identifier: MIT
// Generated actual current Collections helper instructions; no compiler correctness axiom.
include "../../scans/Execution.dfy"
include "../../copy/Memory.dfy"
module BytecodeSortMemoryHelperWordAt {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  predicate Admitted(prefix: seq<Word>, base: Word, index: Word) { |prefix| <= 1000 && index < 0x800000000000000 }
  predicate MemoryAdmitted(mem: seq<Byte>, base: Word, index: Word) { base+32+index*32+32 <= |mem| < G.Modulus() && Round32(|mem|) == |mem| }
  lemma NoExpand(mem: seq<Byte>, base: Word, index: Word)
    requires MemoryAdmitted(mem,base,index)
    ensures Expand(mem,base+32+index*32+32) == mem
  { C.RoundedMonotone(base+32+index*32+32,|mem|); }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[3833] == 91 &&
                                              code[3834] == 96 &&
                                              code[3835] == 32 &&
                                              code[3836] == 144 &&
                                              code[3837] == 129 &&
                                              code[3838] == 2 &&
                                              code[3839] == 145 &&
                                              code[3840] == 144 &&
                                              code[3841] == 145 &&
                                              code[3842] == 1 &&
                                              code[3843] == 1 &&
                                              code[3844] == 81 &&
                                              code[3845] == 144 &&
                                              code[3846] == 86 &&
                                              code[3847] == 91
  }
  function Destinations(): set<nat> { {3847} }
  opaque predicate Good(id: nat, state: State, prefix: seq<Word>, base: Word, index: Word, mem: seq<Byte>, data: seq<Byte>) {
    Admitted(prefix,base,index) && MemoryAdmitted(mem,base,index) && (
      if id == 0 then state == Running(3833,prefix+[3847,base,index],mem)
      else if id == 1 then state == Running(3834,prefix+[3847,base,index],mem)
      else if id == 2 then state == Running(3836,prefix+[3847,base,index,32],mem)
      else if id == 3 then state == Running(3837,prefix+[3847,base,32,index],mem)
      else if id == 4 then state == Running(3838,prefix+[3847,base,32,index,32],mem)
      else if id == 5 then state == Running(3839,prefix+[3847,base,32,((32 as nat)*(index as nat))%G.Modulus()],mem)
      else if id == 6 then state == Running(3840,prefix+[3847,((32 as nat)*(index as nat))%G.Modulus(),32,base],mem)
      else if id == 7 then state == Running(3841,prefix+[3847,((32 as nat)*(index as nat))%G.Modulus(),base,32],mem)
      else if id == 8 then state == Running(3842,prefix+[3847,32,base,((32 as nat)*(index as nat))%G.Modulus()],mem)
      else if id == 9 then state == Running(3843,prefix+[3847,32,((((32 as nat)*(index as nat))%G.Modulus() as nat)+(base as nat))%G.Modulus()],mem)
      else if id == 10 then state == Running(3844,prefix+[3847,((((((32 as nat)*(index as nat))%G.Modulus() as nat)+(base as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem)
      else if id == 11 then state == Running(3845,prefix+[3847,Load(mem,base+32+index*32)],mem)
      else if id == 12 then state == Running(3846,prefix+[Load(mem,base+32+index*32),3847],mem)
      else false)
  }
  lemma Advance0(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index) && MemoryAdmitted(mem,base,index) && Good(0,state,prefix,base,index,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,prefix,base,index,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3833,prefix+[3847,base,index],mem);
    assert Fetch(code,3833) == Op(91,3834,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index) && MemoryAdmitted(mem,base,index) && Good(1,state,prefix,base,index,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,prefix,base,index,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3834,prefix+[3847,base,index],mem);
    F.Push1(code,3834);
    assert Fetch(code,3834) == Op(96,3836,32);
  }
  lemma Advance2(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index) && MemoryAdmitted(mem,base,index) && Good(2,state,prefix,base,index,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,prefix,base,index,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3836,prefix+[3847,base,index,32],mem);
    assert Fetch(code,3836) == Op(144,3837,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index) && MemoryAdmitted(mem,base,index) && Good(3,state,prefix,base,index,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,prefix,base,index,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3837,prefix+[3847,base,32,index],mem);
    assert Fetch(code,3837) == Op(129,3838,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index) && MemoryAdmitted(mem,base,index) && Good(4,state,prefix,base,index,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,prefix,base,index,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3838,prefix+[3847,base,32,index,32],mem);
    assert Fetch(code,3838) == Op(2,3839,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index) && MemoryAdmitted(mem,base,index) && Good(5,state,prefix,base,index,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,prefix,base,index,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3839,prefix+[3847,base,32,((32 as nat)*(index as nat))%G.Modulus()],mem);
    assert Fetch(code,3839) == Op(145,3840,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index) && MemoryAdmitted(mem,base,index) && Good(6,state,prefix,base,index,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,prefix,base,index,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3840,prefix+[3847,((32 as nat)*(index as nat))%G.Modulus(),32,base],mem);
    assert Fetch(code,3840) == Op(144,3841,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index) && MemoryAdmitted(mem,base,index) && Good(7,state,prefix,base,index,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,prefix,base,index,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3841,prefix+[3847,((32 as nat)*(index as nat))%G.Modulus(),base,32],mem);
    assert Fetch(code,3841) == Op(145,3842,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index) && MemoryAdmitted(mem,base,index) && Good(8,state,prefix,base,index,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,prefix,base,index,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3842,prefix+[3847,32,base,((32 as nat)*(index as nat))%G.Modulus()],mem);
    assert Fetch(code,3842) == Op(1,3843,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index) && MemoryAdmitted(mem,base,index) && Good(9,state,prefix,base,index,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,prefix,base,index,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3843,prefix+[3847,32,((((32 as nat)*(index as nat))%G.Modulus() as nat)+(base as nat))%G.Modulus()],mem);
    assert Fetch(code,3843) == Op(1,3844,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index) && MemoryAdmitted(mem,base,index) && Good(10,state,prefix,base,index,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,prefix,base,index,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3844,prefix+[3847,((((((32 as nat)*(index as nat))%G.Modulus() as nat)+(base as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem);
    assert Fetch(code,3844) == Op(81,3845,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index) && MemoryAdmitted(mem,base,index) && Good(11,state,prefix,base,index,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,prefix,base,index,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3845,prefix+[3847,Load(mem,base+32+index*32)],mem);
    assert Fetch(code,3845) == Op(144,3846,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index) && MemoryAdmitted(mem,base,index) && Good(12,state,prefix,base,index,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(3847,prefix+[Load(mem,base+32+index*32)],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3846,prefix+[Load(mem,base+32+index*32),3847],mem);
    assert Fetch(code,3846) == Op(86,3847,0);
  }
  lemma Start(prefix: seq<Word>, base: Word, index: Word, mem: seq<Byte>, data: seq<Byte>)
    requires Admitted(prefix,base,index) && MemoryAdmitted(mem,base,index)
    ensures Good(0,Running(3833,prefix+[3847,base,index],mem),prefix,base,index,mem,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, prefix: seq<Word>, base: Word, index: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(prefix,base,index) && MemoryAdmitted(mem,base,index)
    ensures state == Running(3847,prefix+[Load(mem,base+32+index*32)],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 14 && trace[0] == Running(3833,prefix+[3847,base,index],mem) && trace[|trace|-1] == state
  {
    Start(prefix,base,index,mem,data);
    state := Running(3833,prefix+[3847,base,index],mem);
    trace := [state];
    Advance0(code,state,prefix,base,index,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,prefix,base,index,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,prefix,base,index,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,prefix,base,index,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,prefix,base,index,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,prefix,base,index,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,prefix,base,index,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,prefix,base,index,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,prefix,base,index,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,prefix,base,index,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,prefix,base,index,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
    Advance11(code,state,prefix,base,index,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    state := next11;
    Advance12(code,state,prefix,base,index,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    state := next12;
  }
}
