// SPDX-License-Identifier: MIT
// Generated actual current Collections helper instructions; no compiler correctness axiom.
include "../../scans/Execution.dfy"
module BytecodeZipHelperDiv32 {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  predicate Admitted(prefix: seq<Word>, length: Word, ret: Word) { |prefix| <= 1000 && ret in {1954,1965,2011} }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[1954] == 91 &&
                                              code[1965] == 91 &&
                                              code[2011] == 91 &&
                                              code[23562] == 91 &&
                                              code[23563] == 95 &&
                                              code[23564] == 130 &&
                                              code[23565] == 97 &&
                                              code[23566] == 92 &&
                                              code[23567] == 24 &&
                                              code[23568] == 87 &&
                                              code[23576] == 91 &&
                                              code[23577] == 80 &&
                                              code[23578] == 4 &&
                                              code[23579] == 144 &&
                                              code[23580] == 86
  }
  function Destinations(): set<nat> { {1954,1965,2011,23576} }
  opaque predicate Good(id: nat, state: State, prefix: seq<Word>, length: Word, ret: Word, mem: seq<Byte>, data: seq<Byte>) {
    Admitted(prefix,length,ret) && (
      if id == 0 then state == Running(23562,prefix+[ret,32,length],mem)
      else if id == 1 then state == Running(23563,prefix+[ret,32,length],mem)
      else if id == 2 then state == Running(23564,prefix+[ret,32,length,0],mem)
      else if id == 3 then state == Running(23565,prefix+[ret,32,length,0,32],mem)
      else if id == 4 then state == Running(23568,prefix+[ret,32,length,0,32,23576],mem)
      else if id == 5 then state == Running(23576,prefix+[ret,32,length,0],mem)
      else if id == 6 then state == Running(23577,prefix+[ret,32,length,0],mem)
      else if id == 7 then state == Running(23578,prefix+[ret,32,length],mem)
      else if id == 8 then state == Running(23579,prefix+[ret,(if 32 == 0 then 0 else (length as nat)/(32 as nat))],mem)
      else if id == 9 then state == Running(23580,prefix+[(if 32 == 0 then 0 else (length as nat)/(32 as nat)),ret],mem)
      else false)
  }
  lemma Advance0(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length,ret) && Good(0,state,prefix,length,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,prefix,length,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23562,prefix+[ret,32,length],mem);
    assert Fetch(code,23562) == Op(91,23563,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length,ret) && Good(1,state,prefix,length,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,prefix,length,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23563,prefix+[ret,32,length],mem);
    assert Fetch(code,23563) == Op(95,23564,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length,ret) && Good(2,state,prefix,length,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,prefix,length,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23564,prefix+[ret,32,length,0],mem);
    assert Fetch(code,23564) == Op(130,23565,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length,ret) && Good(3,state,prefix,length,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,prefix,length,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23565,prefix+[ret,32,length,0,32],mem);
    F.Push2(code,23565);
    assert Fetch(code,23565) == Op(97,23568,23576);
  }
  lemma Advance4(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length,ret) && Good(4,state,prefix,length,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,prefix,length,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23568,prefix+[ret,32,length,0,32,23576],mem);
    assert Fetch(code,23568) == Op(87,23569,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length,ret) && Good(5,state,prefix,length,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,prefix,length,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23576,prefix+[ret,32,length,0],mem);
    assert Fetch(code,23576) == Op(91,23577,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length,ret) && Good(6,state,prefix,length,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,prefix,length,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23577,prefix+[ret,32,length,0],mem);
    assert Fetch(code,23577) == Op(80,23578,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length,ret) && Good(7,state,prefix,length,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,prefix,length,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23578,prefix+[ret,32,length],mem);
    assert Fetch(code,23578) == Op(4,23579,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length,ret) && Good(8,state,prefix,length,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,prefix,length,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23579,prefix+[ret,(if 32 == 0 then 0 else (length as nat)/(32 as nat))],mem);
    assert Fetch(code,23579) == Op(144,23580,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, prefix: seq<Word>, length: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,length,ret) && Good(9,state,prefix,length,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(ret,prefix+[length/32],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23580,prefix+[(if 32 == 0 then 0 else (length as nat)/(32 as nat)),ret],mem);
    assert Fetch(code,23580) == Op(86,23581,0);
  }
  lemma Start(prefix: seq<Word>, length: Word, ret: Word, mem: seq<Byte>, data: seq<Byte>)
    requires Admitted(prefix,length,ret)
    ensures Good(0,Running(23562,prefix+[ret,32,length],mem),prefix,length,ret,mem,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, prefix: seq<Word>, length: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(prefix,length,ret)
    ensures state == Running(ret,prefix+[length/32],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 11 && trace[0] == Running(23562,prefix+[ret,32,length],mem) && trace[|trace|-1] == state
  {
    Start(prefix,length,ret,mem,data);
    state := Running(23562,prefix+[ret,32,length],mem);
    trace := [state];
    Advance0(code,state,prefix,length,ret,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,prefix,length,ret,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,prefix,length,ret,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,prefix,length,ret,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,prefix,length,ret,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,prefix,length,ret,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,prefix,length,ret,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,prefix,length,ret,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,prefix,length,ret,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,prefix,length,ret,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
  }
}
