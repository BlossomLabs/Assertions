// SPDX-License-Identifier: MIT
// Generated actual current Collections helper instructions; no compiler correctness axiom.
include "../scans/Execution.dfy"
module BytecodeIndexMod {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  predicate Admitted(prefix: seq<Word>, length: Word) { |prefix| <= 1000 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[8247] == 91 &&
                                              code[23523] == 91 &&
                                              code[23524] == 95 &&
                                              code[23525] == 130 &&
                                              code[23526] == 97 &&
                                              code[23527] == 91 &&
                                              code[23528] == 241 &&
                                              code[23529] == 87 &&
                                              code[23537] == 91 &&
                                              code[23538] == 80 &&
                                              code[23539] == 6 &&
                                              code[23540] == 144 &&
                                              code[23541] == 86
  }
  function Destinations(): set<nat> { {8247,23537} }
  opaque predicate Good(id: nat, state: State, prefix: seq<Word>, length: Word, mem: seq<Byte>, data: seq<Byte>) {
    Admitted(prefix,length) && (
      if id == 0 then state == Running(23523,prefix+[8247,32,length],mem)
      else if id == 1 then state == Running(23524,prefix+[8247,32,length],mem)
      else if id == 2 then state == Running(23525,prefix+[8247,32,length,0],mem)
      else if id == 3 then state == Running(23526,prefix+[8247,32,length,0,32],mem)
      else if id == 4 then state == Running(23529,prefix+[8247,32,length,0,32,23537],mem)
      else if id == 5 then state == Running(23537,prefix+[8247,32,length,0],mem)
      else if id == 6 then state == Running(23538,prefix+[8247,32,length,0],mem)
      else if id == 7 then state == Running(23539,prefix+[8247,32,length],mem)
      else if id == 8 then state == Running(23540,prefix+[8247,(if 32 == 0 then 0 else (length as nat)%(32 as nat))],mem)
      else if id == 9 then state == Running(23541,prefix+[(if 32 == 0 then 0 else (length as nat)%(32 as nat)),8247],mem)
      else false)
  }
  lemma Advance0(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length) && Good(0,state,prefix,length,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,prefix,length,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23523,prefix+[8247,32,length],mem);
    assert Fetch(code,23523) == Op(91,23524,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length) && Good(1,state,prefix,length,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,prefix,length,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23524,prefix+[8247,32,length],mem);
    assert Fetch(code,23524) == Op(95,23525,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length) && Good(2,state,prefix,length,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,prefix,length,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23525,prefix+[8247,32,length,0],mem);
    assert Fetch(code,23525) == Op(130,23526,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length) && Good(3,state,prefix,length,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,prefix,length,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23526,prefix+[8247,32,length,0,32],mem);
    F.Push2(code,23526);
    assert Fetch(code,23526) == Op(97,23529,23537);
  }
  lemma Advance4(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length) && Good(4,state,prefix,length,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,prefix,length,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23529,prefix+[8247,32,length,0,32,23537],mem);
    assert Fetch(code,23529) == Op(87,23530,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length) && Good(5,state,prefix,length,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,prefix,length,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23537,prefix+[8247,32,length,0],mem);
    assert Fetch(code,23537) == Op(91,23538,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length) && Good(6,state,prefix,length,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,prefix,length,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23538,prefix+[8247,32,length,0],mem);
    assert Fetch(code,23538) == Op(80,23539,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length) && Good(7,state,prefix,length,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,prefix,length,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23539,prefix+[8247,32,length],mem);
    assert Fetch(code,23539) == Op(6,23540,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length) && Good(8,state,prefix,length,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,prefix,length,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23540,prefix+[8247,(if 32 == 0 then 0 else (length as nat)%(32 as nat))],mem);
    assert Fetch(code,23540) == Op(144,23541,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length) && Good(9,state,prefix,length,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(8247,prefix+[length%32],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23541,prefix+[(if 32 == 0 then 0 else (length as nat)%(32 as nat)),8247],mem);
    assert Fetch(code,23541) == Op(86,23542,0);
  }
  lemma Start(prefix: seq<Word>, length: Word, mem: seq<Byte>, data: seq<Byte>)
    requires Admitted(prefix,length)
    ensures Good(0,Running(23523,prefix+[8247,32,length],mem),prefix,length,mem,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, prefix: seq<Word>, length: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(prefix,length)
    ensures state == Running(8247,prefix+[length%32],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 11 && trace[0] == Running(23523,prefix+[8247,32,length],mem) && trace[|trace|-1] == state
  {
    Start(prefix,length,mem,data);
    state := Running(23523,prefix+[8247,32,length],mem);
    trace := [state];
    Advance0(code,state,prefix,length,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,prefix,length,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,prefix,length,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,prefix,length,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,prefix,length,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,prefix,length,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,prefix,length,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,prefix,length,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,prefix,length,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,prefix,length,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
  }
}
