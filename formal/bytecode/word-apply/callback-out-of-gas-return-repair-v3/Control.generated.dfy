// SPDX-License-Identifier: MIT
// Generated actual local four-byte SubcallOutOfGas return.
include "Memory.dfy"
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
module BytecodeApplyCallbackOutOfGasReturnControl {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import E = BytecodeScanExecution
  import H = BytecodeApplyWrongCallbackMemory
  import M = BytecodeApplyCallbackOutOfGasReturnMemory
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 && code[16171] == 96 &&
                                              code[16172] == 64 &&
                                              code[16173] == 81 &&
                                              code[16174] == 99 &&
                                              code[16175] == 105 &&
                                              code[16176] == 56 &&
                                              code[16177] == 131 &&
                                              code[16178] == 7 &&
                                              code[16179] == 96 &&
                                              code[16180] == 225 &&
                                              code[16181] == 27 &&
                                              code[16182] == 129 &&
                                              code[16183] == 82 &&
                                              code[16184] == 96 &&
                                              code[16185] == 4 &&
                                              code[16186] == 1 &&
                                              code[16187] == 96 &&
                                              code[16188] == 64 &&
                                              code[16189] == 81 &&
                                              code[16190] == 128 &&
                                              code[16191] == 145 &&
                                              code[16192] == 3 &&
                                              code[16193] == 144 &&
                                              code[16194] == 253 }
  opaque predicate Admitted(mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>) { H.Fits(mem,free) && |prefix| <= 1021 }
  lemma Admission(mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>)
    requires Admitted(mem,prefix,free,value,data)
    ensures H.Fits(mem,free) && free+160 < 0x10000000000000000000000000000000000000000000000000000000000000000 && |prefix| <= 1021
  { reveal Admitted(); }
  opaque predicate Good(id: nat,state: State,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>) { Admitted(mem,prefix,free,value,data) && H.Fits(mem,free) && free+160 < 0x10000000000000000000000000000000000000000000000000000000000000000 && (
                                                                                                                          if id == 0 then state == Running(16171,prefix+[],mem)
                                                                                                                          else if id == 1 then state == Running(16173,prefix+[64],mem)
                                                                                                                          else if id == 2 then state == Running(16174,prefix+[free],mem)
                                                                                                                          else if id == 3 then state == Running(16179,prefix+[free,1765311239],mem)
                                                                                                                          else if id == 4 then state == Running(16181,prefix+[free,1765311239,225],mem)
                                                                                                                          else if id == 5 then state == Running(16182,prefix+[free,M.Header()],mem)
                                                                                                                          else if id == 6 then state == Running(16183,prefix+[free,M.Header(),free],mem)
                                                                                                                          else if id == 7 then state == Running(16184,prefix+[free],M.Complete(mem,free))
                                                                                                                          else if id == 8 then state == Running(16186,prefix+[free,4],M.Complete(mem,free))
                                                                                                                          else if id == 9 then state == Running(16187,prefix+[free+4],M.Complete(mem,free))
                                                                                                                          else if id == 10 then state == Running(16189,prefix+[free+4,64],M.Complete(mem,free))
                                                                                                                          else if id == 11 then state == Running(16190,prefix+[free+4,free],M.Complete(mem,free))
                                                                                                                          else if id == 12 then state == Running(16191,prefix+[free+4,free,free],M.Complete(mem,free))
                                                                                                                          else if id == 13 then state == Running(16192,prefix+[free,free,free+4],M.Complete(mem,free))
                                                                                                                          else if id == 14 then state == Running(16193,prefix+[free,4],M.Complete(mem,free))
                                                                                                                          else if id == 15 then state == Running(16194,prefix+[4,free],M.Complete(mem,free))
                                                                                                                          else false) }
  lemma Advance0(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted(mem,prefix,free,value,data) && Good(0,state,mem,prefix,free,value,data)
    ensures Step(code,{},state,value,data) != Bad
    ensures var next := Step(code,{},state,value,data); Good(1,next,mem,prefix,free,value,data)
  { hide G.BitAnd(); hide BitNot(); hide M.Complete(); reveal Matches(); reveal Good(); reveal Step();
    Admission(mem,prefix,free,value,data); M.Layout(mem,free);
    assert state == Running(16171,prefix+[],mem);
    F.Push1(code,16171);
    assert Fetch(code,16171) == Op(96,16173,64);
  }
  lemma Advance1(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted(mem,prefix,free,value,data) && Good(1,state,mem,prefix,free,value,data)
    ensures Step(code,{},state,value,data) != Bad
    ensures var next := Step(code,{},state,value,data); Good(2,next,mem,prefix,free,value,data)
  { hide G.BitAnd(); hide BitNot(); hide M.Complete(); reveal Matches(); reveal Good(); reveal Step();
    Admission(mem,prefix,free,value,data); M.Layout(mem,free);
    assert state == Running(16173,prefix+[64],mem);
    assert Fetch(code,16173) == Op(81,16174,0);
  }
  lemma Advance2(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted(mem,prefix,free,value,data) && Good(2,state,mem,prefix,free,value,data)
    ensures Step(code,{},state,value,data) != Bad
    ensures var next := Step(code,{},state,value,data); Good(3,next,mem,prefix,free,value,data)
  { hide G.BitAnd(); hide BitNot(); hide M.Complete(); reveal Matches(); reveal Good(); reveal Step();
    Admission(mem,prefix,free,value,data); M.Layout(mem,free);
    assert state == Running(16174,prefix+[free],mem);
    P.Push4(code,16174);
    assert Fetch(code,16174) == Op(99,16179,1765311239);
  }
  lemma Advance3(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted(mem,prefix,free,value,data) && Good(3,state,mem,prefix,free,value,data)
    ensures Step(code,{},state,value,data) != Bad
    ensures var next := Step(code,{},state,value,data); Good(4,next,mem,prefix,free,value,data)
  { hide G.BitAnd(); hide BitNot(); hide M.Complete(); reveal Matches(); reveal Good(); reveal Step();
    Admission(mem,prefix,free,value,data); M.Layout(mem,free);
    assert state == Running(16179,prefix+[free,1765311239],mem);
    F.Push1(code,16179);
    assert Fetch(code,16179) == Op(96,16181,225);
  }
  lemma Advance4(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted(mem,prefix,free,value,data) && Good(4,state,mem,prefix,free,value,data)
    ensures Step(code,{},state,value,data) != Bad
    ensures var next := Step(code,{},state,value,data); Good(5,next,mem,prefix,free,value,data)
  { hide G.BitAnd(); hide BitNot(); hide M.Complete(); reveal Matches(); reveal Good(); reveal Step();
    Admission(mem,prefix,free,value,data); M.Layout(mem,free);
    M.Literal();
    assert state == Running(16181,prefix+[free,1765311239,225],mem);
    assert Fetch(code,16181) == Op(27,16182,0);
  }
  lemma Advance5(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted(mem,prefix,free,value,data) && Good(5,state,mem,prefix,free,value,data)
    ensures Step(code,{},state,value,data) != Bad
    ensures var next := Step(code,{},state,value,data); Good(6,next,mem,prefix,free,value,data)
  { hide G.BitAnd(); hide BitNot(); hide M.Complete(); reveal Matches(); reveal Good(); reveal Step();
    Admission(mem,prefix,free,value,data); M.Layout(mem,free);
    assert state == Running(16182,prefix+[free,M.Header()],mem);
    assert Fetch(code,16182) == Op(129,16183,0);
  }
  lemma Advance6(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted(mem,prefix,free,value,data) && Good(6,state,mem,prefix,free,value,data)
    ensures Step(code,{},state,value,data) != Bad
    ensures var next := Step(code,{},state,value,data); Good(7,next,mem,prefix,free,value,data)
  { hide G.BitAnd(); hide BitNot(); hide M.Complete(); reveal Matches(); reveal Good(); reveal Step();
    Admission(mem,prefix,free,value,data); M.Layout(mem,free);
    assert state == Running(16183,prefix+[free,M.Header(),free],mem);
    assert Fetch(code,16183) == Op(82,16184,0);
    reveal M.Complete();
  }
  lemma Advance7(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted(mem,prefix,free,value,data) && Good(7,state,mem,prefix,free,value,data)
    ensures Step(code,{},state,value,data) != Bad
    ensures var next := Step(code,{},state,value,data); Good(8,next,mem,prefix,free,value,data)
  { hide G.BitAnd(); hide BitNot(); hide M.Complete(); reveal Matches(); reveal Good(); reveal Step();
    Admission(mem,prefix,free,value,data); M.Layout(mem,free);
    assert state == Running(16184,prefix+[free],M.Complete(mem,free));
    F.Push1(code,16184);
    assert Fetch(code,16184) == Op(96,16186,4);
  }
  lemma Advance8(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted(mem,prefix,free,value,data) && Good(8,state,mem,prefix,free,value,data)
    ensures Step(code,{},state,value,data) != Bad
    ensures var next := Step(code,{},state,value,data); Good(9,next,mem,prefix,free,value,data)
  { hide G.BitAnd(); hide BitNot(); hide M.Complete(); reveal Matches(); reveal Good(); reveal Step();
    Admission(mem,prefix,free,value,data); M.Layout(mem,free);
    assert state == Running(16186,prefix+[free,4],M.Complete(mem,free));
    assert Fetch(code,16186) == Op(1,16187,0);
  }
  lemma Advance9(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted(mem,prefix,free,value,data) && Good(9,state,mem,prefix,free,value,data)
    ensures Step(code,{},state,value,data) != Bad
    ensures var next := Step(code,{},state,value,data); Good(10,next,mem,prefix,free,value,data)
  { hide G.BitAnd(); hide BitNot(); hide M.Complete(); reveal Matches(); reveal Good(); reveal Step();
    Admission(mem,prefix,free,value,data); M.Layout(mem,free);
    assert state == Running(16187,prefix+[free+4],M.Complete(mem,free));
    F.Push1(code,16187);
    assert Fetch(code,16187) == Op(96,16189,64);
  }
  lemma Advance10(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted(mem,prefix,free,value,data) && Good(10,state,mem,prefix,free,value,data)
    ensures Step(code,{},state,value,data) != Bad
    ensures var next := Step(code,{},state,value,data); Good(11,next,mem,prefix,free,value,data)
  { hide G.BitAnd(); hide BitNot(); hide M.Complete(); reveal Matches(); reveal Good(); reveal Step();
    Admission(mem,prefix,free,value,data); M.Layout(mem,free);
    assert state == Running(16189,prefix+[free+4,64],M.Complete(mem,free));
    assert Fetch(code,16189) == Op(81,16190,0);
  }
  lemma Advance11(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted(mem,prefix,free,value,data) && Good(11,state,mem,prefix,free,value,data)
    ensures Step(code,{},state,value,data) != Bad
    ensures var next := Step(code,{},state,value,data); Good(12,next,mem,prefix,free,value,data)
  { hide G.BitAnd(); hide BitNot(); hide M.Complete(); reveal Matches(); reveal Good(); reveal Step();
    Admission(mem,prefix,free,value,data); M.Layout(mem,free);
    assert state == Running(16190,prefix+[free+4,free],M.Complete(mem,free));
    assert Fetch(code,16190) == Op(128,16191,0);
  }
  lemma Advance12(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted(mem,prefix,free,value,data) && Good(12,state,mem,prefix,free,value,data)
    ensures Step(code,{},state,value,data) != Bad
    ensures var next := Step(code,{},state,value,data); Good(13,next,mem,prefix,free,value,data)
  { hide G.BitAnd(); hide BitNot(); hide M.Complete(); reveal Matches(); reveal Good(); reveal Step();
    Admission(mem,prefix,free,value,data); M.Layout(mem,free);
    assert state == Running(16191,prefix+[free+4,free,free],M.Complete(mem,free));
    assert Fetch(code,16191) == Op(145,16192,0);
  }
  lemma Advance13(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted(mem,prefix,free,value,data) && Good(13,state,mem,prefix,free,value,data)
    ensures Step(code,{},state,value,data) != Bad
    ensures var next := Step(code,{},state,value,data); Good(14,next,mem,prefix,free,value,data)
  { hide G.BitAnd(); hide BitNot(); hide M.Complete(); reveal Matches(); reveal Good(); reveal Step();
    Admission(mem,prefix,free,value,data); M.Layout(mem,free);
    assert state == Running(16192,prefix+[free,free,free+4],M.Complete(mem,free));
    assert Fetch(code,16192) == Op(3,16193,0);
  }
  lemma Advance14(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted(mem,prefix,free,value,data) && Good(14,state,mem,prefix,free,value,data)
    ensures Step(code,{},state,value,data) != Bad
    ensures var next := Step(code,{},state,value,data); Good(15,next,mem,prefix,free,value,data)
  { hide G.BitAnd(); hide BitNot(); hide M.Complete(); reveal Matches(); reveal Good(); reveal Step();
    Admission(mem,prefix,free,value,data); M.Layout(mem,free);
    assert state == Running(16193,prefix+[free,4],M.Complete(mem,free));
    assert Fetch(code,16193) == Op(144,16194,0);
  }
  lemma Advance15(code: seq<Byte>,state: State,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted(mem,prefix,free,value,data) && Good(15,state,mem,prefix,free,value,data)
    ensures Step(code,{},state,value,data) != Bad
    ensures var next := Step(code,{},state,value,data); next == Reverted(M.Packet())
  { hide G.BitAnd(); hide BitNot(); hide M.Complete(); reveal Matches(); reveal Good(); reveal Step();
    Admission(mem,prefix,free,value,data); M.Layout(mem,free);
    M.Bytes(mem,free);
    assert G.Grow(M.Complete(mem,free),free+4) == M.Complete(mem,free);
    assert state == Running(16194,prefix+[4,free],M.Complete(mem,free));
    assert Fetch(code,16194) == Op(253,16195,0);
  }
  ghost method Run(code: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,free: Word,value: Word,data: seq<Byte>) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(mem,prefix,free,value,data)
    ensures state == Reverted(M.Packet()) && E.Trace(code,{},value,data,trace)
    ensures |trace| == 17 && trace[0] == Running(16171,prefix+[],mem) && trace[|trace|-1] == state
  { hide E.Trace(); Admission(mem,prefix,free,value,data); state := Running(16171,prefix+[],mem);trace := [state];reveal Good();
    Advance0(code,state,mem,prefix,free,value,data);
    var next0 := Step(code,{},state,value,data);
    E.Extend(code,{},value,data,trace,next0);trace := trace+[next0];state := next0;
    Advance1(code,state,mem,prefix,free,value,data);
    var next1 := Step(code,{},state,value,data);
    E.Extend(code,{},value,data,trace,next1);trace := trace+[next1];state := next1;
    Advance2(code,state,mem,prefix,free,value,data);
    var next2 := Step(code,{},state,value,data);
    E.Extend(code,{},value,data,trace,next2);trace := trace+[next2];state := next2;
    Advance3(code,state,mem,prefix,free,value,data);
    var next3 := Step(code,{},state,value,data);
    E.Extend(code,{},value,data,trace,next3);trace := trace+[next3];state := next3;
    Advance4(code,state,mem,prefix,free,value,data);
    var next4 := Step(code,{},state,value,data);
    E.Extend(code,{},value,data,trace,next4);trace := trace+[next4];state := next4;
    Advance5(code,state,mem,prefix,free,value,data);
    var next5 := Step(code,{},state,value,data);
    E.Extend(code,{},value,data,trace,next5);trace := trace+[next5];state := next5;
    Advance6(code,state,mem,prefix,free,value,data);
    var next6 := Step(code,{},state,value,data);
    E.Extend(code,{},value,data,trace,next6);trace := trace+[next6];state := next6;
    Advance7(code,state,mem,prefix,free,value,data);
    var next7 := Step(code,{},state,value,data);
    E.Extend(code,{},value,data,trace,next7);trace := trace+[next7];state := next7;
    Advance8(code,state,mem,prefix,free,value,data);
    var next8 := Step(code,{},state,value,data);
    E.Extend(code,{},value,data,trace,next8);trace := trace+[next8];state := next8;
    Advance9(code,state,mem,prefix,free,value,data);
    var next9 := Step(code,{},state,value,data);
    E.Extend(code,{},value,data,trace,next9);trace := trace+[next9];state := next9;
    Advance10(code,state,mem,prefix,free,value,data);
    var next10 := Step(code,{},state,value,data);
    E.Extend(code,{},value,data,trace,next10);trace := trace+[next10];state := next10;
    Advance11(code,state,mem,prefix,free,value,data);
    var next11 := Step(code,{},state,value,data);
    E.Extend(code,{},value,data,trace,next11);trace := trace+[next11];state := next11;
    Advance12(code,state,mem,prefix,free,value,data);
    var next12 := Step(code,{},state,value,data);
    E.Extend(code,{},value,data,trace,next12);trace := trace+[next12];state := next12;
    Advance13(code,state,mem,prefix,free,value,data);
    var next13 := Step(code,{},state,value,data);
    E.Extend(code,{},value,data,trace,next13);trace := trace+[next13];state := next13;
    Advance14(code,state,mem,prefix,free,value,data);
    var next14 := Step(code,{},state,value,data);
    E.Extend(code,{},value,data,trace,next14);trace := trace+[next14];state := next14;
    Advance15(code,state,mem,prefix,free,value,data);
    var next15 := Step(code,{},state,value,data);
    E.Extend(code,{},value,data,trace,next15);trace := trace+[next15];state := next15;
  }
}
