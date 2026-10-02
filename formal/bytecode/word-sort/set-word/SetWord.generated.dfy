// SPDX-License-Identifier: MIT
// Generated actual current Collections helper instructions; no compiler correctness axiom.
include "../../scans/Execution.dfy"
include "../../copy/Memory.dfy"
module BytecodeSortMemoryHelperSetWord {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  predicate Admitted(prefix: seq<Word>, base: Word, index: Word, written: Word) { |prefix| <= 1000 && index < 0x800000000000000 }
  predicate MemoryAdmitted(mem: seq<Byte>, base: Word, index: Word) { base+32+index*32+32 <= |mem| < G.Modulus() && Round32(|mem|) == |mem| }
  lemma NoExpand(mem: seq<Byte>, base: Word, index: Word)
    requires MemoryAdmitted(mem,base,index)
    ensures Expand(mem,base+32+index*32+32) == mem
  { C.RoundedMonotone(base+32+index*32+32,|mem|); }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[3847] == 91 &&
                                              code[3848] == 96 &&
                                              code[3849] == 32 &&
                                              code[3850] == 145 &&
                                              code[3851] == 130 &&
                                              code[3852] == 2 &&
                                              code[3853] == 146 &&
                                              code[3854] == 144 &&
                                              code[3855] == 146 &&
                                              code[3856] == 1 &&
                                              code[3857] == 1 &&
                                              code[3858] == 82 &&
                                              code[3859] == 86 &&
                                              code[3860] == 91
  }
  function Destinations(): set<nat> { {3860} }
  opaque predicate Good(id: nat, state: State, prefix: seq<Word>, base: Word, index: Word, written: Word, mem: seq<Byte>, data: seq<Byte>) {
    Admitted(prefix,base,index,written) && MemoryAdmitted(mem,base,index) && (
      if id == 0 then state == Running(3847,prefix+[3860,base,index,written],mem)
      else if id == 1 then state == Running(3848,prefix+[3860,base,index,written],mem)
      else if id == 2 then state == Running(3850,prefix+[3860,base,index,written,32],mem)
      else if id == 3 then state == Running(3851,prefix+[3860,base,32,written,index],mem)
      else if id == 4 then state == Running(3852,prefix+[3860,base,32,written,index,32],mem)
      else if id == 5 then state == Running(3853,prefix+[3860,base,32,written,((32 as nat)*(index as nat))%G.Modulus()],mem)
      else if id == 6 then state == Running(3854,prefix+[3860,((32 as nat)*(index as nat))%G.Modulus(),32,written,base],mem)
      else if id == 7 then state == Running(3855,prefix+[3860,((32 as nat)*(index as nat))%G.Modulus(),32,base,written],mem)
      else if id == 8 then state == Running(3856,prefix+[3860,written,32,base,((32 as nat)*(index as nat))%G.Modulus()],mem)
      else if id == 9 then state == Running(3857,prefix+[3860,written,32,((((32 as nat)*(index as nat))%G.Modulus() as nat)+(base as nat))%G.Modulus()],mem)
      else if id == 10 then state == Running(3858,prefix+[3860,written,((((((32 as nat)*(index as nat))%G.Modulus() as nat)+(base as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem)
      else if id == 11 then state == Running(3859,prefix+[3860],Store(mem,base+32+index*32,written))
      else false)
  }
  lemma Advance0(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, written: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index,written) && MemoryAdmitted(mem,base,index) && Good(0,state,prefix,base,index,written,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,prefix,base,index,written,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3847,prefix+[3860,base,index,written],mem);
    assert Fetch(code,3847) == Op(91,3848,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, written: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index,written) && MemoryAdmitted(mem,base,index) && Good(1,state,prefix,base,index,written,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,prefix,base,index,written,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3848,prefix+[3860,base,index,written],mem);
    F.Push1(code,3848);
    assert Fetch(code,3848) == Op(96,3850,32);
  }
  lemma Advance2(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, written: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index,written) && MemoryAdmitted(mem,base,index) && Good(2,state,prefix,base,index,written,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,prefix,base,index,written,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3850,prefix+[3860,base,index,written,32],mem);
    assert Fetch(code,3850) == Op(145,3851,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, written: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index,written) && MemoryAdmitted(mem,base,index) && Good(3,state,prefix,base,index,written,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,prefix,base,index,written,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3851,prefix+[3860,base,32,written,index],mem);
    assert Fetch(code,3851) == Op(130,3852,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, written: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index,written) && MemoryAdmitted(mem,base,index) && Good(4,state,prefix,base,index,written,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,prefix,base,index,written,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3852,prefix+[3860,base,32,written,index,32],mem);
    assert Fetch(code,3852) == Op(2,3853,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, written: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index,written) && MemoryAdmitted(mem,base,index) && Good(5,state,prefix,base,index,written,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,prefix,base,index,written,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3853,prefix+[3860,base,32,written,((32 as nat)*(index as nat))%G.Modulus()],mem);
    assert Fetch(code,3853) == Op(146,3854,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, written: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index,written) && MemoryAdmitted(mem,base,index) && Good(6,state,prefix,base,index,written,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,prefix,base,index,written,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3854,prefix+[3860,((32 as nat)*(index as nat))%G.Modulus(),32,written,base],mem);
    assert Fetch(code,3854) == Op(144,3855,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, written: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index,written) && MemoryAdmitted(mem,base,index) && Good(7,state,prefix,base,index,written,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,prefix,base,index,written,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3855,prefix+[3860,((32 as nat)*(index as nat))%G.Modulus(),32,base,written],mem);
    assert Fetch(code,3855) == Op(146,3856,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, written: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index,written) && MemoryAdmitted(mem,base,index) && Good(8,state,prefix,base,index,written,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,prefix,base,index,written,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3856,prefix+[3860,written,32,base,((32 as nat)*(index as nat))%G.Modulus()],mem);
    assert Fetch(code,3856) == Op(1,3857,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, written: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index,written) && MemoryAdmitted(mem,base,index) && Good(9,state,prefix,base,index,written,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,prefix,base,index,written,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3857,prefix+[3860,written,32,((((32 as nat)*(index as nat))%G.Modulus() as nat)+(base as nat))%G.Modulus()],mem);
    assert Fetch(code,3857) == Op(1,3858,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, written: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index,written) && MemoryAdmitted(mem,base,index) && Good(10,state,prefix,base,index,written,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,prefix,base,index,written,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3858,prefix+[3860,written,((((((32 as nat)*(index as nat))%G.Modulus() as nat)+(base as nat))%G.Modulus() as nat)+(32 as nat))%G.Modulus()],mem);
    assert Fetch(code,3858) == Op(82,3859,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, prefix: seq<Word>, base: Word, index: Word, written: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,base,index,written) && MemoryAdmitted(mem,base,index) && Good(11,state,prefix,base,index,written,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(3860,prefix+[],Store(mem,base+32+index*32,written))
  {
    reveal Matches(); reveal Good(); reveal Step();
    NoExpand(mem,base,index);
    assert state == Running(3859,prefix+[3860],Store(mem,base+32+index*32,written));
    assert Fetch(code,3859) == Op(86,3860,0);
  }
  lemma Start(prefix: seq<Word>, base: Word, index: Word, written: Word, mem: seq<Byte>, data: seq<Byte>)
    requires Admitted(prefix,base,index,written) && MemoryAdmitted(mem,base,index)
    ensures Good(0,Running(3847,prefix+[3860,base,index,written],mem),prefix,base,index,written,mem,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, prefix: seq<Word>, base: Word, index: Word, written: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(prefix,base,index,written) && MemoryAdmitted(mem,base,index)
    ensures state == Running(3860,prefix+[],Store(mem,base+32+index*32,written))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 13 && trace[0] == Running(3847,prefix+[3860,base,index,written],mem) && trace[|trace|-1] == state
  {
    Start(prefix,base,index,written,mem,data);
    state := Running(3847,prefix+[3860,base,index,written],mem);
    trace := [state];
    Advance0(code,state,prefix,base,index,written,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,prefix,base,index,written,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,prefix,base,index,written,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,prefix,base,index,written,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,prefix,base,index,written,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,prefix,base,index,written,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,prefix,base,index,written,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,prefix,base,index,written,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,prefix,base,index,written,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,prefix,base,index,written,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,prefix,base,index,written,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
    Advance11(code,state,prefix,base,index,written,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    state := next11;
  }
}
