// SPDX-License-Identifier: MIT
// Generated from the pinned current Collections checked-add helper.
include "Fetch.dfy"
module BytecodeScanCheckedAdd {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import G = BytecodeGetterMachine
  function Sum(a: Word, b: Word): Word { ((a as nat)+(b as nat))%G.Modulus() }
  predicate Admitted(prefix: seq<Word>, a: Word, b: Word) { |prefix| <= 1000 && (a as nat)+(b as nat) < G.Modulus() }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[2904] == 91 &&
                                              code[13698] == 91 &&
                                              code[13699] == 146 &&
                                              code[13700] == 145 &&
                                              code[13701] == 80 &&
                                              code[13702] == 80 &&
                                              code[13703] == 86 &&
                                              code[23604] == 91 &&
                                              code[23605] == 128 &&
                                              code[23606] == 130 &&
                                              code[23607] == 1 &&
                                              code[23608] == 128 &&
                                              code[23609] == 130 &&
                                              code[23610] == 17 &&
                                              code[23611] == 21 &&
                                              code[23612] == 97 &&
                                              code[23613] == 53 &&
                                              code[23614] == 130 &&
                                              code[23615] == 87
  }
  function Destinations(): set<nat> { {2904,13698} }
  opaque predicate Good(id: nat, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>) {
    Admitted(prefix,a,b) && (
      if id == 0 then state == Running(23604,prefix+[2904,a,b],mem)
      else if id == 1 then state == Running(23605,prefix+[2904,a,b],mem)
      else if id == 2 then state == Running(23606,prefix+[2904,a,b,b],mem)
      else if id == 3 then state == Running(23607,prefix+[2904,a,b,b,a],mem)
      else if id == 4 then state == Running(23608,prefix+[2904,a,b,Sum(a,b)],mem)
      else if id == 5 then state == Running(23609,prefix+[2904,a,b,Sum(a,b),Sum(a,b)],mem)
      else if id == 6 then state == Running(23610,prefix+[2904,a,b,Sum(a,b),Sum(a,b),b],mem)
      else if id == 7 then state == Running(23611,prefix+[2904,a,b,Sum(a,b),0],mem)
      else if id == 8 then state == Running(23612,prefix+[2904,a,b,Sum(a,b),1],mem)
      else if id == 9 then state == Running(23615,prefix+[2904,a,b,Sum(a,b),1,13698],mem)
      else if id == 10 then state == Running(13698,prefix+[2904,a,b,Sum(a,b)],mem)
      else if id == 11 then state == Running(13699,prefix+[2904,a,b,Sum(a,b)],mem)
      else if id == 12 then state == Running(13700,prefix+[Sum(a,b),a,b,2904],mem)
      else if id == 13 then state == Running(13701,prefix+[Sum(a,b),2904,b,a],mem)
      else if id == 14 then state == Running(13702,prefix+[Sum(a,b),2904,b],mem)
      else if id == 15 then state == Running(13703,prefix+[Sum(a,b),2904],mem)
      else false)
  }
  lemma Advance0(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(0,state,prefix,a,b,mem)
    ensures state.Running? && |state.stack| <= 1007
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,prefix,a,b,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23604,prefix+[2904,a,b],mem);
    assert Fetch(code,23604) == Op(91,23605,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(1,state,prefix,a,b,mem)
    ensures state.Running? && |state.stack| <= 1007
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,prefix,a,b,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23605,prefix+[2904,a,b],mem);
    assert Fetch(code,23605) == Op(128,23606,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(2,state,prefix,a,b,mem)
    ensures state.Running? && |state.stack| <= 1007
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,prefix,a,b,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23606,prefix+[2904,a,b,b],mem);
    assert Fetch(code,23606) == Op(130,23607,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(3,state,prefix,a,b,mem)
    ensures state.Running? && |state.stack| <= 1007
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,prefix,a,b,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23607,prefix+[2904,a,b,b,a],mem);
    assert Fetch(code,23607) == Op(1,23608,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(4,state,prefix,a,b,mem)
    ensures state.Running? && |state.stack| <= 1007
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,prefix,a,b,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23608,prefix+[2904,a,b,Sum(a,b)],mem);
    assert Fetch(code,23608) == Op(128,23609,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(5,state,prefix,a,b,mem)
    ensures state.Running? && |state.stack| <= 1007
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,prefix,a,b,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23609,prefix+[2904,a,b,Sum(a,b),Sum(a,b)],mem);
    assert Fetch(code,23609) == Op(130,23610,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(6,state,prefix,a,b,mem)
    ensures state.Running? && |state.stack| <= 1007
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,prefix,a,b,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23610,prefix+[2904,a,b,Sum(a,b),Sum(a,b),b],mem);
    assert Fetch(code,23610) == Op(17,23611,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(7,state,prefix,a,b,mem)
    ensures state.Running? && |state.stack| <= 1007
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,prefix,a,b,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23611,prefix+[2904,a,b,Sum(a,b),0],mem);
    assert Fetch(code,23611) == Op(21,23612,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(8,state,prefix,a,b,mem)
    ensures state.Running? && |state.stack| <= 1007
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,prefix,a,b,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23612,prefix+[2904,a,b,Sum(a,b),1],mem);
    F.Push2(code,23612);
    assert Fetch(code,23612) == Op(97,23615,13698);
  }
  lemma Advance9(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(9,state,prefix,a,b,mem)
    ensures state.Running? && |state.stack| <= 1007
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,prefix,a,b,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23615,prefix+[2904,a,b,Sum(a,b),1,13698],mem);
    assert Fetch(code,23615) == Op(87,23616,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(10,state,prefix,a,b,mem)
    ensures state.Running? && |state.stack| <= 1007
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,prefix,a,b,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13698,prefix+[2904,a,b,Sum(a,b)],mem);
    assert Fetch(code,13698) == Op(91,13699,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(11,state,prefix,a,b,mem)
    ensures state.Running? && |state.stack| <= 1007
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,prefix,a,b,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13699,prefix+[2904,a,b,Sum(a,b)],mem);
    assert Fetch(code,13699) == Op(146,13700,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(12,state,prefix,a,b,mem)
    ensures state.Running? && |state.stack| <= 1007
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,prefix,a,b,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13700,prefix+[Sum(a,b),a,b,2904],mem);
    assert Fetch(code,13700) == Op(145,13701,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(13,state,prefix,a,b,mem)
    ensures state.Running? && |state.stack| <= 1007
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,prefix,a,b,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13701,prefix+[Sum(a,b),2904,b,a],mem);
    assert Fetch(code,13701) == Op(80,13702,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(14,state,prefix,a,b,mem)
    ensures state.Running? && |state.stack| <= 1007
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,prefix,a,b,mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13702,prefix+[Sum(a,b),2904,b],mem);
    assert Fetch(code,13702) == Op(80,13703,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good(15,state,prefix,a,b,mem)
    ensures state.Running? && |state.stack| <= 1007
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(2904,prefix+[Sum(a,b)],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13703,prefix+[Sum(a,b),2904],mem);
    assert Fetch(code,13703) == Op(86,13704,0);
  }
  lemma Start(prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>)
    requires Admitted(prefix,a,b)
    ensures Good(0,Running(23604,prefix+[2904,a,b],mem),prefix,a,b,mem)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State)
    requires Matches(code) && Admitted(prefix,a,b)
    ensures state == Running(2904,prefix+[(a as nat)+(b as nat)],mem)
  {
    Start(prefix,a,b,mem);
    state := Running(23604,prefix+[2904,a,b],mem);
    Advance0(code,state,prefix,a,b,mem,value,data);
    state := Step(code,Destinations(),state,value,data);
    Advance1(code,state,prefix,a,b,mem,value,data);
    state := Step(code,Destinations(),state,value,data);
    Advance2(code,state,prefix,a,b,mem,value,data);
    state := Step(code,Destinations(),state,value,data);
    Advance3(code,state,prefix,a,b,mem,value,data);
    state := Step(code,Destinations(),state,value,data);
    Advance4(code,state,prefix,a,b,mem,value,data);
    state := Step(code,Destinations(),state,value,data);
    Advance5(code,state,prefix,a,b,mem,value,data);
    state := Step(code,Destinations(),state,value,data);
    Advance6(code,state,prefix,a,b,mem,value,data);
    state := Step(code,Destinations(),state,value,data);
    Advance7(code,state,prefix,a,b,mem,value,data);
    state := Step(code,Destinations(),state,value,data);
    Advance8(code,state,prefix,a,b,mem,value,data);
    state := Step(code,Destinations(),state,value,data);
    Advance9(code,state,prefix,a,b,mem,value,data);
    state := Step(code,Destinations(),state,value,data);
    Advance10(code,state,prefix,a,b,mem,value,data);
    state := Step(code,Destinations(),state,value,data);
    Advance11(code,state,prefix,a,b,mem,value,data);
    state := Step(code,Destinations(),state,value,data);
    Advance12(code,state,prefix,a,b,mem,value,data);
    state := Step(code,Destinations(),state,value,data);
    Advance13(code,state,prefix,a,b,mem,value,data);
    state := Step(code,Destinations(),state,value,data);
    Advance14(code,state,prefix,a,b,mem,value,data);
    state := Step(code,Destinations(),state,value,data);
    Advance15(code,state,prefix,a,b,mem,value,data);
    state := Step(code,Destinations(),state,value,data);
  }
}
