// SPDX-License-Identifier: MIT
// Generated exact checked DIV helper and source-length allocation guard; arbitrary lower prefix and memory preserved.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeApplyAllocationCount {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import D = BytecodeScanDecoderScalar
  predicate Admitted(data: seq<Byte>, sourceLength: Word) { sourceLength < 0x10000000000000000 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[12235] == 91 &&
                                              code[12236] == 95 &&
                                              code[12237] == 97 &&
                                              code[12238] == 47 &&
                                              code[12239] == 215 &&
                                              code[12240] == 96 &&
                                              code[12241] == 32 &&
                                              code[12242] == 138 &&
                                              code[12243] == 97 &&
                                              code[12244] == 92 &&
                                              code[12245] == 10 &&
                                              code[12246] == 86 &&
                                              code[12247] == 91 &&
                                              code[12248] == 144 &&
                                              code[12249] == 80 &&
                                              code[12250] == 136 &&
                                              code[12251] == 96 &&
                                              code[12252] == 1 &&
                                              code[12253] == 96 &&
                                              code[12254] == 1 &&
                                              code[12255] == 96 &&
                                              code[12256] == 64 &&
                                              code[12257] == 27 &&
                                              code[12258] == 3 &&
                                              code[12259] == 129 &&
                                              code[12260] == 17 &&
                                              code[12261] == 21 &&
                                              code[12262] == 97 &&
                                              code[12263] == 47 &&
                                              code[12264] == 241 &&
                                              code[12265] == 87 &&
                                              code[12273] == 91 &&
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
  function Destinations(): set<nat> { {12247,12273,23562,23576} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word) { Admitted(data,sourceLength) && (
                                                                                                                                                                                                                                                                     if id == 0 then state == Running(12235,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96],mem)
                                                                                                                                                                                                                                                                     else if id == 1 then state == Running(12236,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96],mem)
                                                                                                                                                                                                                                                                     else if id == 2 then state == Running(12237,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0],mem)
                                                                                                                                                                                                                                                                     else if id == 3 then state == Running(12240,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247],mem)
                                                                                                                                                                                                                                                                     else if id == 4 then state == Running(12242,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32],mem)
                                                                                                                                                                                                                                                                     else if id == 5 then state == Running(12243,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength],mem)
                                                                                                                                                                                                                                                                     else if id == 6 then state == Running(12246,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength,23562],mem)
                                                                                                                                                                                                                                                                     else if id == 7 then state == Running(23562,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength],mem)
                                                                                                                                                                                                                                                                     else if id == 8 then state == Running(23563,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength],mem)
                                                                                                                                                                                                                                                                     else if id == 9 then state == Running(23564,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength,0],mem)
                                                                                                                                                                                                                                                                     else if id == 10 then state == Running(23565,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength,0,32],mem)
                                                                                                                                                                                                                                                                     else if id == 11 then state == Running(23568,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength,0,32,23576],mem)
                                                                                                                                                                                                                                                                     else if id == 12 then state == Running(23576,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength,0],mem)
                                                                                                                                                                                                                                                                     else if id == 13 then state == Running(23577,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength,0],mem)
                                                                                                                                                                                                                                                                     else if id == 14 then state == Running(23578,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength],mem)
                                                                                                                                                                                                                                                                     else if id == 15 then state == Running(23579,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,sourceLength/32],mem)
                                                                                                                                                                                                                                                                     else if id == 16 then state == Running(23580,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,sourceLength/32,12247],mem)
                                                                                                                                                                                                                                                                     else if id == 17 then state == Running(12247,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,sourceLength/32],mem)
                                                                                                                                                                                                                                                                     else if id == 18 then state == Running(12248,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,sourceLength/32],mem)
                                                                                                                                                                                                                                                                     else if id == 19 then state == Running(12249,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,0],mem)
                                                                                                                                                                                                                                                                     else if id == 20 then state == Running(12250,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32],mem)
                                                                                                                                                                                                                                                                     else if id == 21 then state == Running(12251,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength],mem)
                                                                                                                                                                                                                                                                     else if id == 22 then state == Running(12253,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,1],mem)
                                                                                                                                                                                                                                                                     else if id == 23 then state == Running(12255,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,1,1],mem)
                                                                                                                                                                                                                                                                     else if id == 24 then state == Running(12257,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,1,1,64],mem)
                                                                                                                                                                                                                                                                     else if id == 25 then state == Running(12258,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,1,18446744073709551616],mem)
                                                                                                                                                                                                                                                                     else if id == 26 then state == Running(12259,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,18446744073709551615],mem)
                                                                                                                                                                                                                                                                     else if id == 27 then state == Running(12260,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,18446744073709551615,sourceLength],mem)
                                                                                                                                                                                                                                                                     else if id == 28 then state == Running(12261,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,0],mem)
                                                                                                                                                                                                                                                                     else if id == 29 then state == Running(12262,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,1],mem)
                                                                                                                                                                                                                                                                     else if id == 30 then state == Running(12265,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,1,12273],mem)
                                                                                                                                                                                                                                                                     else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(0,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12235,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96],mem);
    assert Fetch(code,12235) == Op(91,12236,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(1,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12236,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96],mem);
    assert Fetch(code,12236) == Op(95,12237,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(2,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12237,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0],mem);
    F.Push2(code,12237);
    assert Fetch(code,12237) == Op(97,12240,12247);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(3,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12240,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247],mem);
    F.Push1(code,12240);
    assert Fetch(code,12240) == Op(96,12242,32);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(4,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12242,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32],mem);
    assert Fetch(code,12242) == Op(138,12243,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(5,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12243,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength],mem);
    F.Push2(code,12243);
    assert Fetch(code,12243) == Op(97,12246,23562);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(6,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12246,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength,23562],mem);
    assert Fetch(code,12246) == Op(86,12247,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(7,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23562,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength],mem);
    assert Fetch(code,23562) == Op(91,23563,0);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(8,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23563,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength],mem);
    assert Fetch(code,23563) == Op(95,23564,0);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(9,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23564,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength,0],mem);
    assert Fetch(code,23564) == Op(130,23565,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(10,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23565,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength,0,32],mem);
    F.Push2(code,23565);
    assert Fetch(code,23565) == Op(97,23568,23576);
  }
  lemma Advance11(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(11,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23568,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength,0,32,23576],mem);
    assert Fetch(code,23568) == Op(87,23569,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(12,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23576,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength,0],mem);
    assert Fetch(code,23576) == Op(91,23577,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(13,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23577,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength,0],mem);
    assert Fetch(code,23577) == Op(80,23578,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(14,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23578,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,32,sourceLength],mem);
    assert Fetch(code,23578) == Op(4,23579,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(15,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23579,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,12247,sourceLength/32],mem);
    assert Fetch(code,23579) == Op(144,23580,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(16,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23580,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,sourceLength/32,12247],mem);
    assert Fetch(code,23580) == Op(86,23581,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(17,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12247,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,sourceLength/32],mem);
    assert Fetch(code,12247) == Op(91,12248,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(18,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12248,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,0,sourceLength/32],mem);
    assert Fetch(code,12248) == Op(144,12249,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(19,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12249,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,0],mem);
    assert Fetch(code,12249) == Op(80,12250,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(20,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12250,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32],mem);
    assert Fetch(code,12250) == Op(136,12251,0);
  }
  lemma Advance21(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(21,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12251,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength],mem);
    F.Push1(code,12251);
    assert Fetch(code,12251) == Op(96,12253,1);
  }
  lemma Advance22(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(22,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12253,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,1],mem);
    F.Push1(code,12253);
    assert Fetch(code,12253) == Op(96,12255,1);
  }
  lemma Advance23(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(23,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12255,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,1,1],mem);
    F.Push1(code,12255);
    assert Fetch(code,12255) == Op(96,12257,64);
  }
  lemma Advance24(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(24,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12257,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,1,1,64],mem);
    D.DecoderLimit();
    assert Fetch(code,12257) == Op(27,12258,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(25,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12258,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,1,18446744073709551616],mem);
    assert Fetch(code,12258) == Op(3,12259,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(26,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12259,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,18446744073709551615],mem);
    assert Fetch(code,12259) == Op(129,12260,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(27,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12260,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,18446744073709551615,sourceLength],mem);
    assert Fetch(code,12260) == Op(17,12261,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(28,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12261,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,0],mem);
    assert Fetch(code,12261) == Op(21,12262,0);
  }
  lemma Advance29(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(29,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12262,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,1],mem);
    F.Push2(code,12262);
    assert Fetch(code,12262) == Op(97,12265,12273);
  }
  lemma Advance30(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word)
    requires Matches(code) && Admitted(data,sourceLength) && Good(30,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(12273,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12265,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength,1,12273],mem);
    assert Fetch(code,12265) == Op(87,12266,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word)
    requires Admitted(data,sourceLength)
    ensures Good(0,Running(12235,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96],mem),data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode)
  { reveal Good(); }
  ghost method Block0(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data,sourceLength) && Good(0,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
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
    requires Matches(code) && Admitted(data,sourceLength) && Good(20,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode) && |prefix| <= 1007
    ensures state == Running(12273,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 12 && trace[0] == initial && trace[|trace|-1] == state
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
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, sourceOffset: Word, sourceLength: Word, target: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, mode: Word, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data,sourceLength) && |prefix| <= 1007
    ensures state == Running(12273,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96,sourceLength/32,sourceLength],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 32 && trace[0] == Running(12235,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96],mem) && trace[|trace|-1] == state
  {
    Start(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode);
    state := Running(12235,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,96],mem); trace := [state];
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block1(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,mode,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
