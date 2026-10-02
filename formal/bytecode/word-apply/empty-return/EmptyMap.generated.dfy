// SPDX-License-Identifier: MIT
// Generated exact empty body and wrapper cleanup to byte serializer PC518; no target or callback observation consumed.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeApplyEmptyMap {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import D = BytecodeScanDecoderScalar
  predicate Admitted(data: seq<Byte>, sourceLength: Word, mode: Word, returnPc: Word) { sourceLength == 0 && mode == 0 && returnPc == 5526 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[518] == 91 &&
                                              code[5526] == 91 &&
                                              code[5527] == 144 &&
                                              code[5528] == 80 &&
                                              code[5529] == 91 &&
                                              code[5530] == 151 &&
                                              code[5531] == 150 &&
                                              code[5532] == 80 &&
                                              code[5533] == 80 &&
                                              code[5534] == 80 &&
                                              code[5535] == 80 &&
                                              code[5536] == 80 &&
                                              code[5537] == 80 &&
                                              code[5538] == 80 &&
                                              code[5539] == 86 &&
                                              code[12319] == 95 &&
                                              code[12320] == 129 &&
                                              code[12321] == 21 &&
                                              code[12322] == 97 &&
                                              code[12323] == 49 &&
                                              code[12324] == 75 &&
                                              code[12325] == 87 &&
                                              code[12619] == 91 &&
                                              code[12620] == 131 &&
                                              code[12621] == 21 &&
                                              code[12622] == 97 &&
                                              code[12623] == 49 &&
                                              code[12624] == 88 &&
                                              code[12625] == 87 &&
                                              code[12632] == 91 &&
                                              code[12633] == 80 &&
                                              code[12634] == 80 &&
                                              code[12635] == 152 &&
                                              code[12636] == 151 &&
                                              code[12637] == 80 &&
                                              code[12638] == 80 &&
                                              code[12639] == 80 &&
                                              code[12640] == 80 &&
                                              code[12641] == 80 &&
                                              code[12642] == 80 &&
                                              code[12643] == 80 &&
                                              code[12644] == 80 &&
                                              code[12645] == 86
  }
  function Destinations(): set<nat> { {518,5526,12619,12632} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word) { Admitted(data,sourceLength,mode,returnPc) && (
                                                                                                                                                                                                                                                                     if id == 0 then state == Running(12319,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0],mem)
                                                                                                                                                                                                                                                                     else if id == 1 then state == Running(12320,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0],mem)
                                                                                                                                                                                                                                                                     else if id == 2 then state == Running(12321,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0,0],mem)
                                                                                                                                                                                                                                                                     else if id == 3 then state == Running(12322,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0,1],mem)
                                                                                                                                                                                                                                                                     else if id == 4 then state == Running(12325,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0,1,12619],mem)
                                                                                                                                                                                                                                                                     else if id == 5 then state == Running(12619,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0],mem)
                                                                                                                                                                                                                                                                     else if id == 6 then state == Running(12620,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0],mem)
                                                                                                                                                                                                                                                                     else if id == 7 then state == Running(12621,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0,mode],mem)
                                                                                                                                                                                                                                                                     else if id == 8 then state == Running(12622,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0,1],mem)
                                                                                                                                                                                                                                                                     else if id == 9 then state == Running(12625,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0,1,12632],mem)
                                                                                                                                                                                                                                                                     else if id == 10 then state == Running(12632,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0],mem)
                                                                                                                                                                                                                                                                     else if id == 11 then state == Running(12633,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0],mem)
                                                                                                                                                                                                                                                                     else if id == 12 then state == Running(12634,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0],mem)
                                                                                                                                                                                                                                                                     else if id == 13 then state == Running(12635,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128],mem)
                                                                                                                                                                                                                                                                     else if id == 14 then state == Running(12636,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,returnPc],mem)
                                                                                                                                                                                                                                                                     else if id == 15 then state == Running(12637,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,sourceOffset],mem)
                                                                                                                                                                                                                                                                     else if id == 16 then state == Running(12638,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode],mem)
                                                                                                                                                                                                                                                                     else if id == 17 then state == Running(12639,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem)
                                                                                                                                                                                                                                                                     else if id == 18 then state == Running(12640,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc,sourceLength,target,templateOffset,templateLength,arrayOffset],mem)
                                                                                                                                                                                                                                                                     else if id == 19 then state == Running(12641,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc,sourceLength,target,templateOffset,templateLength],mem)
                                                                                                                                                                                                                                                                     else if id == 20 then state == Running(12642,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc,sourceLength,target,templateOffset],mem)
                                                                                                                                                                                                                                                                     else if id == 21 then state == Running(12643,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc,sourceLength,target],mem)
                                                                                                                                                                                                                                                                     else if id == 22 then state == Running(12644,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc,sourceLength],mem)
                                                                                                                                                                                                                                                                     else if id == 23 then state == Running(12645,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc],mem)
                                                                                                                                                                                                                                                                     else if id == 24 then state == Running(5526,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128],mem)
                                                                                                                                                                                                                                                                     else if id == 25 then state == Running(5527,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128],mem)
                                                                                                                                                                                                                                                                     else if id == 26 then state == Running(5528,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,128,96],mem)
                                                                                                                                                                                                                                                                     else if id == 27 then state == Running(5529,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,128],mem)
                                                                                                                                                                                                                                                                     else if id == 28 then state == Running(5530,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,128],mem)
                                                                                                                                                                                                                                                                     else if id == 29 then state == Running(5531,prefix+[128,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,518],mem)
                                                                                                                                                                                                                                                                     else if id == 30 then state == Running(5532,prefix+[128,518,sourceLength,target,templateOffset,templateLength,arrayOffset,count,sourceOffset],mem)
                                                                                                                                                                                                                                                                     else if id == 31 then state == Running(5533,prefix+[128,518,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem)
                                                                                                                                                                                                                                                                     else if id == 32 then state == Running(5534,prefix+[128,518,sourceLength,target,templateOffset,templateLength,arrayOffset],mem)
                                                                                                                                                                                                                                                                     else if id == 33 then state == Running(5535,prefix+[128,518,sourceLength,target,templateOffset,templateLength],mem)
                                                                                                                                                                                                                                                                     else if id == 34 then state == Running(5536,prefix+[128,518,sourceLength,target,templateOffset],mem)
                                                                                                                                                                                                                                                                     else if id == 35 then state == Running(5537,prefix+[128,518,sourceLength,target],mem)
                                                                                                                                                                                                                                                                     else if id == 36 then state == Running(5538,prefix+[128,518,sourceLength],mem)
                                                                                                                                                                                                                                                                     else if id == 37 then state == Running(5539,prefix+[128,518],mem)
                                                                                                                                                                                                                                                                     else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(0,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12319,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0],mem);
    assert Fetch(code,12319) == Op(95,12320,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(1,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12320,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0],mem);
    assert Fetch(code,12320) == Op(129,12321,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(2,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12321,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0,0],mem);
    assert Fetch(code,12321) == Op(21,12322,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(3,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12322,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0,1],mem);
    F.Push2(code,12322);
    assert Fetch(code,12322) == Op(97,12325,12619);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(4,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12325,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0,1,12619],mem);
    assert Fetch(code,12325) == Op(87,12326,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(5,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12619,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0],mem);
    assert Fetch(code,12619) == Op(91,12620,0);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(6,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12620,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0],mem);
    assert Fetch(code,12620) == Op(131,12621,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(7,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12621,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0,mode],mem);
    assert Fetch(code,12621) == Op(21,12622,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(8,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12622,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0,1],mem);
    F.Push2(code,12622);
    assert Fetch(code,12622) == Op(97,12625,12632);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(9,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12625,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0,1,12632],mem);
    assert Fetch(code,12625) == Op(87,12626,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(10,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12632,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0],mem);
    assert Fetch(code,12632) == Op(91,12633,0);
  }
  lemma Advance11(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(11,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12633,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0,0],mem);
    assert Fetch(code,12633) == Op(80,12634,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(12,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12634,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0],mem);
    assert Fetch(code,12634) == Op(80,12635,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(13,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12635,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128],mem);
    assert Fetch(code,12635) == Op(152,12636,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(14,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12636,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,returnPc],mem);
    assert Fetch(code,12636) == Op(151,12637,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(15,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12637,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,sourceOffset],mem);
    assert Fetch(code,12637) == Op(80,12638,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(16,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12638,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode],mem);
    assert Fetch(code,12638) == Op(80,12639,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(17,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12639,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem);
    assert Fetch(code,12639) == Op(80,12640,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(18,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12640,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc,sourceLength,target,templateOffset,templateLength,arrayOffset],mem);
    assert Fetch(code,12640) == Op(80,12641,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(19,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12641,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc,sourceLength,target,templateOffset,templateLength],mem);
    assert Fetch(code,12641) == Op(80,12642,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(20,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12642,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc,sourceLength,target,templateOffset],mem);
    assert Fetch(code,12642) == Op(80,12643,0);
  }
  lemma Advance21(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(21,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12643,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc,sourceLength,target],mem);
    assert Fetch(code,12643) == Op(80,12644,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(22,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12644,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc,sourceLength],mem);
    assert Fetch(code,12644) == Op(80,12645,0);
  }
  lemma Advance23(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(23,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12645,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128,returnPc],mem);
    assert Fetch(code,12645) == Op(86,12646,0);
  }
  lemma Advance24(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(24,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5526,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128],mem);
    assert Fetch(code,5526) == Op(91,5527,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(25,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5527,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,128],mem);
    assert Fetch(code,5527) == Op(144,5528,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(26,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5528,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,128,96],mem);
    assert Fetch(code,5528) == Op(80,5529,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(27,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5529,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,128],mem);
    assert Fetch(code,5529) == Op(91,5530,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(28,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5530,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,128],mem);
    assert Fetch(code,5530) == Op(151,5531,0);
  }
  lemma Advance29(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(29,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5531,prefix+[128,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,518],mem);
    assert Fetch(code,5531) == Op(150,5532,0);
  }
  lemma Advance30(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(30,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5532,prefix+[128,518,sourceLength,target,templateOffset,templateLength,arrayOffset,count,sourceOffset],mem);
    assert Fetch(code,5532) == Op(80,5533,0);
  }
  lemma Advance31(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(31,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(32,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5533,prefix+[128,518,sourceLength,target,templateOffset,templateLength,arrayOffset,count],mem);
    assert Fetch(code,5533) == Op(80,5534,0);
  }
  lemma Advance32(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(32,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(33,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5534,prefix+[128,518,sourceLength,target,templateOffset,templateLength,arrayOffset],mem);
    assert Fetch(code,5534) == Op(80,5535,0);
  }
  lemma Advance33(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(33,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(34,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5535,prefix+[128,518,sourceLength,target,templateOffset,templateLength],mem);
    assert Fetch(code,5535) == Op(80,5536,0);
  }
  lemma Advance34(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(34,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(35,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5536,prefix+[128,518,sourceLength,target,templateOffset],mem);
    assert Fetch(code,5536) == Op(80,5537,0);
  }
  lemma Advance35(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(35,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(36,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5537,prefix+[128,518,sourceLength,target],mem);
    assert Fetch(code,5537) == Op(80,5538,0);
  }
  lemma Advance36(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(36,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(37,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5538,prefix+[128,518,sourceLength],mem);
    assert Fetch(code,5538) == Op(80,5539,0);
  }
  lemma Advance37(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(37,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(518,prefix+[128],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(5539,prefix+[128,518],mem);
    assert Fetch(code,5539) == Op(86,5540,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word)
    requires Admitted(data,sourceLength,mode,returnPc)
    ensures Good(0,Running(12319,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0],mem),data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  { reveal Good(); }
  ghost method Block0(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(0,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures Good(20,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance0(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0]; state := next0;
    Advance1(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1]; state := next1;
    Advance2(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2]; state := next2;
    Advance3(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3]; state := next3;
    Advance4(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4]; state := next4;
    Advance5(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5]; state := next5;
    Advance6(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6]; state := next6;
    Advance7(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7]; state := next7;
    Advance8(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8]; state := next8;
    Advance9(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9]; state := next9;
    Advance10(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10]; state := next10;
    Advance11(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11]; state := next11;
    Advance12(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12]; state := next12;
    Advance13(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13]; state := next13;
    Advance14(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14]; state := next14;
    Advance15(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15]; state := next15;
    Advance16(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16]; state := next16;
    Advance17(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17]; state := next17;
    Advance18(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18]; state := next18;
    Advance19(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19]; state := next19;
  }
  ghost method Block1(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && Good(20,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1001
    ensures state == Running(518,prefix+[128],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 19 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance20(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20]; state := next20;
    Advance21(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21]; state := next21;
    Advance22(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22]; state := next22;
    Advance23(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23]; state := next23;
    Advance24(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24]; state := next24;
    Advance25(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25]; state := next25;
    Advance26(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26]; state := next26;
    Advance27(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27]; state := next27;
    Advance28(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28]; state := next28;
    Advance29(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);
    trace := trace+[next29]; state := next29;
    Advance30(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next30 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30);
    trace := trace+[next30]; state := next30;
    Advance31(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next31 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31);
    trace := trace+[next31]; state := next31;
    Advance32(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next32 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next32);
    trace := trace+[next32]; state := next32;
    Advance33(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next33 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next33);
    trace := trace+[next33]; state := next33;
    Advance34(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next34 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next34);
    trace := trace+[next34]; state := next34;
    Advance35(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next35 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next35);
    trace := trace+[next35]; state := next35;
    Advance36(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next36 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next36);
    trace := trace+[next36]; state := next36;
    Advance37(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    var next37 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next37);
    trace := trace+[next37]; state := next37;
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data,sourceLength,mode,returnPc) && |prefix| <= 1001
    ensures state == Running(518,prefix+[128],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 39 && trace[0] == Running(12319,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0],mem) && trace[|trace|-1] == state
  {
    Start(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode);
    state := Running(12319,prefix+[518,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,96,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,128,0],mem); trace := [state];
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block1(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
