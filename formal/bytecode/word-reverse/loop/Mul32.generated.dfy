// SPDX-License-Identifier: MIT
// Generated actual current Collections helper instructions; no compiler correctness axiom.
include "../../scans/Execution.dfy"
module BytecodeReverseHelperMul32 {
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  predicate Admitted(prefix: seq<Word>, index: Word, ret: Word) { |prefix| <= 1000 && index < 0x10000000000000000 && ret in {5868,5880} }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[5868] == 91 &&
                                              code[5880] == 91 &&
                                              code[13698] == 91 &&
                                              code[13699] == 146 &&
                                              code[13700] == 145 &&
                                              code[13701] == 80 &&
                                              code[13702] == 80 &&
                                              code[13703] == 86 &&
                                              code[23581] == 91 &&
                                              code[23582] == 128 &&
                                              code[23583] == 130 &&
                                              code[23584] == 2 &&
                                              code[23585] == 129 &&
                                              code[23586] == 21 &&
                                              code[23587] == 130 &&
                                              code[23588] == 130 &&
                                              code[23589] == 4 &&
                                              code[23590] == 132 &&
                                              code[23591] == 20 &&
                                              code[23592] == 23 &&
                                              code[23593] == 97 &&
                                              code[23594] == 53 &&
                                              code[23595] == 130 &&
                                              code[23596] == 87
  }
  function Destinations(): set<nat> { {5868,5880,13698} }
  opaque predicate Good(id: nat, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, data: seq<Byte>) {
    Admitted(prefix,index,ret) && (
      if id == 0 then state == Running(23581,prefix+[ret,index,32],mem)
      else if id == 1 then state == Running(23582,prefix+[ret,index,32],mem)
      else if id == 2 then state == Running(23583,prefix+[ret,index,32,32],mem)
      else if id == 3 then state == Running(23584,prefix+[ret,index,32,32,index],mem)
      else if id == 4 then state == Running(23585,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus()],mem)
      else if id == 5 then state == Running(23586,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),32],mem)
      else if id == 6 then state == Running(23587,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),0],mem)
      else if id == 7 then state == Running(23588,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),0,32],mem)
      else if id == 8 then state == Running(23589,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),0,32,((index as nat)*(32 as nat))%G.Modulus()],mem)
      else if id == 9 then state == Running(23590,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),0,(if 32 == 0 then 0 else (((index as nat)*(32 as nat))%G.Modulus() as nat)/(32 as nat))],mem)
      else if id == 10 then state == Running(23591,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),0,(if 32 == 0 then 0 else (((index as nat)*(32 as nat))%G.Modulus() as nat)/(32 as nat)),index],mem)
      else if id == 11 then state == Running(23592,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),0,1],mem)
      else if id == 12 then state == Running(23593,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),1],mem)
      else if id == 13 then state == Running(23596,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),1,13698],mem)
      else if id == 14 then state == Running(13698,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus()],mem)
      else if id == 15 then state == Running(13699,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus()],mem)
      else if id == 16 then state == Running(13700,prefix+[((index as nat)*(32 as nat))%G.Modulus(),index,32,ret],mem)
      else if id == 17 then state == Running(13701,prefix+[((index as nat)*(32 as nat))%G.Modulus(),ret,32,index],mem)
      else if id == 18 then state == Running(13702,prefix+[((index as nat)*(32 as nat))%G.Modulus(),ret,32],mem)
      else if id == 19 then state == Running(13703,prefix+[((index as nat)*(32 as nat))%G.Modulus(),ret],mem)
      else false)
  }
  lemma Advance0(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(0,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23581,prefix+[ret,index,32],mem);
    assert Fetch(code,23581) == Op(91,23582,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(1,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23582,prefix+[ret,index,32],mem);
    assert Fetch(code,23582) == Op(128,23583,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(2,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23583,prefix+[ret,index,32,32],mem);
    assert Fetch(code,23583) == Op(130,23584,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(3,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23584,prefix+[ret,index,32,32,index],mem);
    assert Fetch(code,23584) == Op(2,23585,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(4,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23585,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus()],mem);
    assert Fetch(code,23585) == Op(129,23586,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(5,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23586,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),32],mem);
    assert Fetch(code,23586) == Op(21,23587,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(6,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23587,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),0],mem);
    assert Fetch(code,23587) == Op(130,23588,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(7,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23588,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),0,32],mem);
    assert Fetch(code,23588) == Op(130,23589,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(8,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23589,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),0,32,((index as nat)*(32 as nat))%G.Modulus()],mem);
    assert Fetch(code,23589) == Op(4,23590,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(9,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23590,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),0,(if 32 == 0 then 0 else (((index as nat)*(32 as nat))%G.Modulus() as nat)/(32 as nat))],mem);
    assert Fetch(code,23590) == Op(132,23591,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(10,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23591,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),0,(if 32 == 0 then 0 else (((index as nat)*(32 as nat))%G.Modulus() as nat)/(32 as nat)),index],mem);
    assert Fetch(code,23591) == Op(20,23592,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(11,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23592,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),0,1],mem);
    assert Fetch(code,23592) == Op(23,23593,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(12,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23593,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),1],mem);
    F.Push2(code,23593);
    assert Fetch(code,23593) == Op(97,23596,13698);
  }
  lemma Advance13(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(13,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23596,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus(),1,13698],mem);
    assert Fetch(code,23596) == Op(87,23597,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(14,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13698,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus()],mem);
    assert Fetch(code,13698) == Op(91,13699,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(15,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13699,prefix+[ret,index,32,((index as nat)*(32 as nat))%G.Modulus()],mem);
    assert Fetch(code,13699) == Op(146,13700,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(16,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13700,prefix+[((index as nat)*(32 as nat))%G.Modulus(),index,32,ret],mem);
    assert Fetch(code,13700) == Op(145,13701,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(17,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13701,prefix+[((index as nat)*(32 as nat))%G.Modulus(),ret,32,index],mem);
    assert Fetch(code,13701) == Op(80,13702,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(18,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,prefix,index,ret,mem,data)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13702,prefix+[((index as nat)*(32 as nat))%G.Modulus(),ret,32],mem);
    assert Fetch(code,13702) == Op(80,13703,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,index,ret) && Good(19,state,prefix,index,ret,mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(ret,prefix+[(index as nat)*32],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13703,prefix+[((index as nat)*(32 as nat))%G.Modulus(),ret],mem);
    assert Fetch(code,13703) == Op(86,13704,0);
  }
  lemma Start(prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, data: seq<Byte>)
    requires Admitted(prefix,index,ret)
    ensures Good(0,Running(23581,prefix+[ret,index,32],mem),prefix,index,ret,mem,data)
  { reveal Good(); }
  ghost method Run(code: seq<Byte>, prefix: seq<Word>, index: Word, ret: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(prefix,index,ret)
    ensures state == Running(ret,prefix+[(index as nat)*32],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == Running(23581,prefix+[ret,index,32],mem) && trace[|trace|-1] == state
  {
    Start(prefix,index,ret,mem,data);
    state := Running(23581,prefix+[ret,index,32],mem);
    trace := [state];
    Advance0(code,state,prefix,index,ret,mem,value,data);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0];
    state := next0;
    Advance1(code,state,prefix,index,ret,mem,value,data);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1];
    state := next1;
    Advance2(code,state,prefix,index,ret,mem,value,data);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2];
    state := next2;
    Advance3(code,state,prefix,index,ret,mem,value,data);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3];
    state := next3;
    Advance4(code,state,prefix,index,ret,mem,value,data);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4];
    state := next4;
    Advance5(code,state,prefix,index,ret,mem,value,data);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5];
    state := next5;
    Advance6(code,state,prefix,index,ret,mem,value,data);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6];
    state := next6;
    Advance7(code,state,prefix,index,ret,mem,value,data);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7];
    state := next7;
    Advance8(code,state,prefix,index,ret,mem,value,data);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8];
    state := next8;
    Advance9(code,state,prefix,index,ret,mem,value,data);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9];
    state := next9;
    Advance10(code,state,prefix,index,ret,mem,value,data);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10];
    state := next10;
    Advance11(code,state,prefix,index,ret,mem,value,data);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11];
    state := next11;
    Advance12(code,state,prefix,index,ret,mem,value,data);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12];
    state := next12;
    Advance13(code,state,prefix,index,ret,mem,value,data);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13];
    state := next13;
    Advance14(code,state,prefix,index,ret,mem,value,data);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14];
    state := next14;
    Advance15(code,state,prefix,index,ret,mem,value,data);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15];
    state := next15;
    Advance16(code,state,prefix,index,ret,mem,value,data);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16];
    state := next16;
    Advance17(code,state,prefix,index,ret,mem,value,data);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17];
    state := next17;
    Advance18(code,state,prefix,index,ret,mem,value,data);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18];
    state := next18;
    Advance19(code,state,prefix,index,ret,mem,value,data);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19];
    state := next19;
  }
}
