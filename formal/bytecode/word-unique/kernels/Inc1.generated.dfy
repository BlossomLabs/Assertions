// SPDX-License-Identifier: MIT
// Generated actual current Collections helper instructions; no compiler correctness axiom.
include "../../scans/Execution.dfy"
module BytecodeUniqueHelperInc1 {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  predicate Admitted(prefix: seq<Word>, kept: Word) { |prefix| <= 1000 && kept < G.Modulus()-1 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[6909] == 91 &&
                                              code[23760] == 91 &&
                                              code[23761] == 95 &&
                                              code[23762] == 96 &&
                                              code[23763] == 1 &&
                                              code[23764] == 130 &&
                                              code[23765] == 1 &&
                                              code[23766] == 97 &&
                                              code[23767] == 92 &&
                                              code[23768] == 225 &&
                                              code[23769] == 87 &&
                                              code[23777] == 91 &&
                                              code[23778] == 80 &&
                                              code[23779] == 96 &&
                                              code[23780] == 1 &&
                                              code[23781] == 1 &&
                                              code[23782] == 144 &&
                                              code[23783] == 86
  }
  function Destinations(): set<nat> { {6909,23777} }
  opaque predicate Good(id: nat, state: State, prefix: seq<Word>, kept: Word, mem: seq<Byte>, data: seq<Byte>) {
    Admitted(prefix,kept) && (
      if id == 0 then state == Running(23760,prefix+[6909,kept],mem)
      else if id == 1 then state == Running(23761,prefix+[6909,kept],mem)
      else if id == 2 then state == Running(23762,prefix+[6909,kept,0],mem)
      else if id == 3 then state == Running(23764,prefix+[6909,kept,0,1],mem)
      else if id == 4 then state == Running(23765,prefix+[6909,kept,0,1,kept],mem)
      else if id == 5 then state == Running(23766,prefix+[6909,kept,0,((kept as nat)+(1 as nat))%G.Modulus()],mem)
      else if id == 6 then state == Running(23769,prefix+[6909,kept,0,((kept as nat)+(1 as nat))%G.Modulus(),23777],mem)
      else if id == 7 then state == Running(23777,prefix+[6909,kept,0],mem)
      else if id == 8 then state == Running(23778,prefix+[6909,kept,0],mem)
      else if id == 9 then state == Running(23779,prefix+[6909,kept],mem)
      else if id == 10 then state == Running(23781,prefix+[6909,kept,1],mem)
      else if id == 11 then state == Running(23782,prefix+[6909,((1 as nat)+(kept as nat))%G.Modulus()],mem)
      else if id == 12 then state == Running(23783,prefix+[((1 as nat)+(kept as nat))%G.Modulus(),6909],mem)
      else false)
  }
  lemma Advance0(code: seq<Byte>, state: State, prefix: seq<Word>, kept: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,kept) && Good(0,state,prefix,kept,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,prefix,kept,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23760,prefix+[6909,kept],mem);
    assert Fetch(code,23760) == Op(91,23761,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, prefix: seq<Word>, kept: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,kept) && Good(1,state,prefix,kept,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,prefix,kept,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23761,prefix+[6909,kept],mem);
    assert Fetch(code,23761) == Op(95,23762,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, prefix: seq<Word>, kept: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,kept) && Good(2,state,prefix,kept,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,prefix,kept,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23762,prefix+[6909,kept,0],mem);
    F.Push1(code,23762);
    assert Fetch(code,23762) == Op(96,23764,1);
  }
  lemma Advance3(code: seq<Byte>, state: State, prefix: seq<Word>, kept: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,kept) && Good(3,state,prefix,kept,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,prefix,kept,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23764,prefix+[6909,kept,0,1],mem);
    assert Fetch(code,23764) == Op(130,23765,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, prefix: seq<Word>, kept: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,kept) && Good(4,state,prefix,kept,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,prefix,kept,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23765,prefix+[6909,kept,0,1,kept],mem);
    assert Fetch(code,23765) == Op(1,23766,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, prefix: seq<Word>, kept: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,kept) && Good(5,state,prefix,kept,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,prefix,kept,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23766,prefix+[6909,kept,0,((kept as nat)+(1 as nat))%G.Modulus()],mem);
    F.Push2(code,23766);
    assert Fetch(code,23766) == Op(97,23769,23777);
  }
  lemma Advance6(code: seq<Byte>, state: State, prefix: seq<Word>, kept: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,kept) && Good(6,state,prefix,kept,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,prefix,kept,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23769,prefix+[6909,kept,0,((kept as nat)+(1 as nat))%G.Modulus(),23777],mem);
    assert Fetch(code,23769) == Op(87,23770,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, prefix: seq<Word>, kept: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,kept) && Good(7,state,prefix,kept,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,prefix,kept,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23777,prefix+[6909,kept,0],mem);
    assert Fetch(code,23777) == Op(91,23778,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, prefix: seq<Word>, kept: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,kept) && Good(8,state,prefix,kept,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,prefix,kept,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23778,prefix+[6909,kept,0],mem);
    assert Fetch(code,23778) == Op(80,23779,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, prefix: seq<Word>, kept: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,kept) && Good(9,state,prefix,kept,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,prefix,kept,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23779,prefix+[6909,kept],mem);
    F.Push1(code,23779);
    assert Fetch(code,23779) == Op(96,23781,1);
  }
  lemma Advance10(code: seq<Byte>, state: State, prefix: seq<Word>, kept: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,kept) && Good(10,state,prefix,kept,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,prefix,kept,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23781,prefix+[6909,kept,1],mem);
    assert Fetch(code,23781) == Op(1,23782,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, prefix: seq<Word>, kept: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,kept) && Good(11,state,prefix,kept,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,prefix,kept,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23782,prefix+[6909,((1 as nat)+(kept as nat))%G.Modulus()],mem);
    assert Fetch(code,23782) == Op(144,23783,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, prefix: seq<Word>, kept: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,kept) && Good(12,state,prefix,kept,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(6909,prefix+[(kept as nat)+1],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23783,prefix+[((1 as nat)+(kept as nat))%G.Modulus(),6909],mem);
    assert Fetch(code,23783) == Op(86,23784,0);
  }
  lemma Start(prefix: seq<Word>, kept: Word, mem: seq<Byte>, data: seq<Byte>)
    requires Admitted(prefix,kept)
    ensures Good(0,Running(23760,prefix+[6909,kept],mem),prefix,kept,mem,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, prefix: seq<Word>, kept: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(prefix,kept)
    ensures state == Running(6909,prefix+[(kept as nat)+1],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 14 && trace[0] == Running(23760,prefix+[6909,kept],mem) && trace[|trace|-1] == state
  {
    Start(prefix,kept,mem,data);
    state := Running(23760,prefix+[6909,kept],mem);
    trace := [state];
    Advance0(code,state,prefix,kept,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,prefix,kept,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,prefix,kept,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,prefix,kept,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,prefix,kept,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,prefix,kept,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,prefix,kept,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,prefix,kept,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,prefix,kept,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,prefix,kept,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,prefix,kept,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
    Advance11(code,state,prefix,kept,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    state := next11;
    Advance12(code,state,prefix,kept,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    state := next12;
  }
}
