// SPDX-License-Identifier: MIT
// Generated complete bytes payload packing helper. Explicit fitting memory; no public evidence claim.
include "../callback-copy/Memory.dfy"
include "../../copy/Execution.dfy"
module BytecodeApplyCallbackPack {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import C = BytecodeCopyMachine
  import E = BytecodeCopyExecution
  import H = BytecodeApplyCallbackCopyMemory
  predicate Admitted(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word) { H.Fits(mem,ptr,free,length) && Load(mem,ptr) == length && |prefix| <= 1012 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[8389] == 91 &&
                                              code[8390] == 147 &&
                                              code[8391] == 146 &&
                                              code[8392] == 80 &&
                                              code[8393] == 80 &&
                                              code[8394] == 80 &&
                                              code[8395] == 86 &&
                                              code[16936] == 91 &&
                                              code[23460] == 91 &&
                                              code[23461] == 95 &&
                                              code[23462] == 129 &&
                                              code[23463] == 81 &&
                                              code[23464] == 128 &&
                                              code[23465] == 96 &&
                                              code[23466] == 32 &&
                                              code[23467] == 132 &&
                                              code[23468] == 1 &&
                                              code[23469] == 133 &&
                                              code[23470] == 94 &&
                                              code[23471] == 95 &&
                                              code[23472] == 147 &&
                                              code[23473] == 1 &&
                                              code[23474] == 146 &&
                                              code[23475] == 131 &&
                                              code[23476] == 82 &&
                                              code[23477] == 80 &&
                                              code[23478] == 144 &&
                                              code[23479] == 145 &&
                                              code[23480] == 144 &&
                                              code[23481] == 80 &&
                                              code[23482] == 86 &&
                                              code[24276] == 91 &&
                                              code[24277] == 95 &&
                                              code[24278] == 97 &&
                                              code[24279] == 32 &&
                                              code[24280] == 197 &&
                                              code[24281] == 130 &&
                                              code[24282] == 132 &&
                                              code[24283] == 97 &&
                                              code[24284] == 91 &&
                                              code[24285] == 164 &&
                                              code[24286] == 86
  }
  function Destinations(): set<nat> { {8389,16936,23460} }
  opaque predicate Good(id: nat,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word) { Admitted(data,mem,prefix,ptr,free,length,value) && (
                                                                                                                                                 if id == 0 then state == Running(24276,prefix+[16936,ptr,free],mem)
                                                                                                                                                 else if id == 1 then state == Running(24277,prefix+[16936,ptr,free],mem)
                                                                                                                                                 else if id == 2 then state == Running(24278,prefix+[16936,ptr,free,0],mem)
                                                                                                                                                 else if id == 3 then state == Running(24281,prefix+[16936,ptr,free,0,8389],mem)
                                                                                                                                                 else if id == 4 then state == Running(24282,prefix+[16936,ptr,free,0,8389,free],mem)
                                                                                                                                                 else if id == 5 then state == Running(24283,prefix+[16936,ptr,free,0,8389,free,ptr],mem)
                                                                                                                                                 else if id == 6 then state == Running(24286,prefix+[16936,ptr,free,0,8389,free,ptr,23460],mem)
                                                                                                                                                 else if id == 7 then state == Running(23460,prefix+[16936,ptr,free,0,8389,free,ptr],mem)
                                                                                                                                                 else if id == 8 then state == Running(23461,prefix+[16936,ptr,free,0,8389,free,ptr],mem)
                                                                                                                                                 else if id == 9 then state == Running(23462,prefix+[16936,ptr,free,0,8389,free,ptr,0],mem)
                                                                                                                                                 else if id == 10 then state == Running(23463,prefix+[16936,ptr,free,0,8389,free,ptr,0,ptr],mem)
                                                                                                                                                 else if id == 11 then state == Running(23464,prefix+[16936,ptr,free,0,8389,free,ptr,0,length],mem)
                                                                                                                                                 else if id == 12 then state == Running(23465,prefix+[16936,ptr,free,0,8389,free,ptr,0,length,length],mem)
                                                                                                                                                 else if id == 13 then state == Running(23467,prefix+[16936,ptr,free,0,8389,free,ptr,0,length,length,32],mem)
                                                                                                                                                 else if id == 14 then state == Running(23468,prefix+[16936,ptr,free,0,8389,free,ptr,0,length,length,32,ptr],mem)
                                                                                                                                                 else if id == 15 then state == Running(23469,prefix+[16936,ptr,free,0,8389,free,ptr,0,length,length,ptr+32],mem)
                                                                                                                                                 else if id == 16 then state == Running(23470,prefix+[16936,ptr,free,0,8389,free,ptr,0,length,length,ptr+32,free],mem)
                                                                                                                                                 else if id == 17 then state == Running(23471,prefix+[16936,ptr,free,0,8389,free,ptr,0,length],H.Copied(mem,ptr,free,length))
                                                                                                                                                 else if id == 18 then state == Running(23472,prefix+[16936,ptr,free,0,8389,free,ptr,0,length,0],H.Copied(mem,ptr,free,length))
                                                                                                                                                 else if id == 19 then state == Running(23473,prefix+[16936,ptr,free,0,8389,0,ptr,0,length,free],H.Copied(mem,ptr,free,length))
                                                                                                                                                 else if id == 20 then state == Running(23474,prefix+[16936,ptr,free,0,8389,0,ptr,0,free+length],H.Copied(mem,ptr,free,length))
                                                                                                                                                 else if id == 21 then state == Running(23475,prefix+[16936,ptr,free,0,8389,free+length,ptr,0,0],H.Copied(mem,ptr,free,length))
                                                                                                                                                 else if id == 22 then state == Running(23476,prefix+[16936,ptr,free,0,8389,free+length,ptr,0,0,free+length],H.Copied(mem,ptr,free,length))
                                                                                                                                                 else if id == 23 then state == Running(23477,prefix+[16936,ptr,free,0,8389,free+length,ptr,0],H.Packed(mem,ptr,free,length))
                                                                                                                                                 else if id == 24 then state == Running(23478,prefix+[16936,ptr,free,0,8389,free+length,ptr],H.Packed(mem,ptr,free,length))
                                                                                                                                                 else if id == 25 then state == Running(23479,prefix+[16936,ptr,free,0,8389,ptr,free+length],H.Packed(mem,ptr,free,length))
                                                                                                                                                 else if id == 26 then state == Running(23480,prefix+[16936,ptr,free,0,free+length,ptr,8389],H.Packed(mem,ptr,free,length))
                                                                                                                                                 else if id == 27 then state == Running(23481,prefix+[16936,ptr,free,0,free+length,8389,ptr],H.Packed(mem,ptr,free,length))
                                                                                                                                                 else if id == 28 then state == Running(23482,prefix+[16936,ptr,free,0,free+length,8389],H.Packed(mem,ptr,free,length))
                                                                                                                                                 else if id == 29 then state == Running(8389,prefix+[16936,ptr,free,0,free+length],H.Packed(mem,ptr,free,length))
                                                                                                                                                 else if id == 30 then state == Running(8390,prefix+[16936,ptr,free,0,free+length],H.Packed(mem,ptr,free,length))
                                                                                                                                                 else if id == 31 then state == Running(8391,prefix+[free+length,ptr,free,0,16936],H.Packed(mem,ptr,free,length))
                                                                                                                                                 else if id == 32 then state == Running(8392,prefix+[free+length,16936,free,0,ptr],H.Packed(mem,ptr,free,length))
                                                                                                                                                 else if id == 33 then state == Running(8393,prefix+[free+length,16936,free,0],H.Packed(mem,ptr,free,length))
                                                                                                                                                 else if id == 34 then state == Running(8394,prefix+[free+length,16936,free],H.Packed(mem,ptr,free,length))
                                                                                                                                                 else if id == 35 then state == Running(8395,prefix+[free+length,16936],H.Packed(mem,ptr,free,length))
                                                                                                                                                 else false) }
  lemma Advance0(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(0,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(24276,prefix+[16936,ptr,free],mem);
    assert Fetch(code,24276) == Op(91,24277,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance1(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(1,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(24277,prefix+[16936,ptr,free],mem);
    assert Fetch(code,24277) == Op(95,24278,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance2(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(2,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(24278,prefix+[16936,ptr,free,0],mem);
    F.Push2(code,24278);
    assert Fetch(code,24278) == Op(97,24281,8389);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance3(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(3,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(24281,prefix+[16936,ptr,free,0,8389],mem);
    assert Fetch(code,24281) == Op(130,24282,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance4(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(4,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(24282,prefix+[16936,ptr,free,0,8389,free],mem);
    assert Fetch(code,24282) == Op(132,24283,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance5(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(5,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(24283,prefix+[16936,ptr,free,0,8389,free,ptr],mem);
    F.Push2(code,24283);
    assert Fetch(code,24283) == Op(97,24286,23460);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance6(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(6,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(24286,prefix+[16936,ptr,free,0,8389,free,ptr,23460],mem);
    assert Fetch(code,24286) == Op(86,24287,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance7(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(7,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23460,prefix+[16936,ptr,free,0,8389,free,ptr],mem);
    assert Fetch(code,23460) == Op(91,23461,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance8(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(8,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23461,prefix+[16936,ptr,free,0,8389,free,ptr],mem);
    assert Fetch(code,23461) == Op(95,23462,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance9(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(9,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23462,prefix+[16936,ptr,free,0,8389,free,ptr,0],mem);
    assert Fetch(code,23462) == Op(129,23463,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance10(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(10,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23463,prefix+[16936,ptr,free,0,8389,free,ptr,0,ptr],mem);
    assert Fetch(code,23463) == Op(81,23464,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance11(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(11,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23464,prefix+[16936,ptr,free,0,8389,free,ptr,0,length],mem);
    assert Fetch(code,23464) == Op(128,23465,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance12(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(12,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23465,prefix+[16936,ptr,free,0,8389,free,ptr,0,length,length],mem);
    F.Push1(code,23465);
    assert Fetch(code,23465) == Op(96,23467,32);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance13(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(13,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23467,prefix+[16936,ptr,free,0,8389,free,ptr,0,length,length,32],mem);
    assert Fetch(code,23467) == Op(132,23468,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance14(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(14,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23468,prefix+[16936,ptr,free,0,8389,free,ptr,0,length,length,32,ptr],mem);
    assert Fetch(code,23468) == Op(1,23469,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance15(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(15,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(16,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23469,prefix+[16936,ptr,free,0,8389,free,ptr,0,length,length,ptr+32],mem);
    assert Fetch(code,23469) == Op(133,23470,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance16(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(16,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(17,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23470,prefix+[16936,ptr,free,0,8389,free,ptr,0,length,length,ptr+32,free],mem);
    assert Fetch(code,23470) == Op(94,23471,0);
    H.Bounds(mem,ptr,free,length);
    reveal C.Step();
  }
  lemma Advance17(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(17,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23471,prefix+[16936,ptr,free,0,8389,free,ptr,0,length],H.Copied(mem,ptr,free,length));
    assert Fetch(code,23471) == Op(95,23472,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance18(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(18,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(19,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23472,prefix+[16936,ptr,free,0,8389,free,ptr,0,length,0],H.Copied(mem,ptr,free,length));
    assert Fetch(code,23472) == Op(147,23473,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance19(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(19,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(20,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23473,prefix+[16936,ptr,free,0,8389,0,ptr,0,length,free],H.Copied(mem,ptr,free,length));
    assert Fetch(code,23473) == Op(1,23474,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance20(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(20,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(21,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23474,prefix+[16936,ptr,free,0,8389,0,ptr,0,free+length],H.Copied(mem,ptr,free,length));
    assert Fetch(code,23474) == Op(146,23475,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance21(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(21,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(22,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23475,prefix+[16936,ptr,free,0,8389,free+length,ptr,0,0],H.Copied(mem,ptr,free,length));
    assert Fetch(code,23475) == Op(131,23476,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance22(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(22,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(23,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23476,prefix+[16936,ptr,free,0,8389,free+length,ptr,0,0,free+length],H.Copied(mem,ptr,free,length));
    assert Fetch(code,23476) == Op(82,23477,0);
    H.Bounds(mem,ptr,free,length);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance23(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(23,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(24,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23477,prefix+[16936,ptr,free,0,8389,free+length,ptr,0],H.Packed(mem,ptr,free,length));
    assert Fetch(code,23477) == Op(80,23478,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance24(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(24,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(25,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23478,prefix+[16936,ptr,free,0,8389,free+length,ptr],H.Packed(mem,ptr,free,length));
    assert Fetch(code,23478) == Op(144,23479,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance25(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(25,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(26,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23479,prefix+[16936,ptr,free,0,8389,ptr,free+length],H.Packed(mem,ptr,free,length));
    assert Fetch(code,23479) == Op(145,23480,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance26(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(26,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(27,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23480,prefix+[16936,ptr,free,0,free+length,ptr,8389],H.Packed(mem,ptr,free,length));
    assert Fetch(code,23480) == Op(144,23481,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance27(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(27,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(28,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23481,prefix+[16936,ptr,free,0,free+length,8389,ptr],H.Packed(mem,ptr,free,length));
    assert Fetch(code,23481) == Op(80,23482,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance28(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(28,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(29,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(23482,prefix+[16936,ptr,free,0,free+length,8389],H.Packed(mem,ptr,free,length));
    assert Fetch(code,23482) == Op(86,23483,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance29(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(29,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(30,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(8389,prefix+[16936,ptr,free,0,free+length],H.Packed(mem,ptr,free,length));
    assert Fetch(code,8389) == Op(91,8390,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance30(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(30,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(31,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(8390,prefix+[16936,ptr,free,0,free+length],H.Packed(mem,ptr,free,length));
    assert Fetch(code,8390) == Op(147,8391,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance31(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(31,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(32,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(8391,prefix+[free+length,ptr,free,0,16936],H.Packed(mem,ptr,free,length));
    assert Fetch(code,8391) == Op(146,8392,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance32(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(32,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(33,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(8392,prefix+[free+length,16936,free,0,ptr],H.Packed(mem,ptr,free,length));
    assert Fetch(code,8392) == Op(80,8393,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance33(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(33,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(34,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(8393,prefix+[free+length,16936,free,0],H.Packed(mem,ptr,free,length));
    assert Fetch(code,8393) == Op(80,8394,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance34(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(34,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); Good(35,next,data,mem,prefix,ptr,free,length,value)
  {
    reveal Matches(); reveal Good();
    assert state == Running(8394,prefix+[free+length,16936,free],H.Packed(mem,ptr,free,length));
    assert Fetch(code,8394) == Op(80,8395,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  lemma Advance35(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(35,state,data,mem,prefix,ptr,free,length,value)
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); next == Running(16936,prefix+[free+length],H.Packed(mem,ptr,free,length))
  {
    reveal Matches(); reveal Good();
    assert state == Running(8395,prefix+[free+length,16936],H.Packed(mem,ptr,free,length));
    assert Fetch(code,8395) == Op(86,8396,0);
    C.Delegate(code,Destinations(),state,value,data);
    reveal Step();
  }
  ghost method Block0(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(0,initial,data,mem,prefix,ptr,free,length,value)
    ensures Good(15,state,data,mem,prefix,ptr,free,length,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 16 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial; trace := [state];
    Advance0(code,state,data,mem,prefix,ptr,free,length,value);
    var next0 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0); trace := trace+[next0]; state := next0;
    Advance1(code,state,data,mem,prefix,ptr,free,length,value);
    var next1 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1); trace := trace+[next1]; state := next1;
    Advance2(code,state,data,mem,prefix,ptr,free,length,value);
    var next2 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2); trace := trace+[next2]; state := next2;
    Advance3(code,state,data,mem,prefix,ptr,free,length,value);
    var next3 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3); trace := trace+[next3]; state := next3;
    Advance4(code,state,data,mem,prefix,ptr,free,length,value);
    var next4 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4); trace := trace+[next4]; state := next4;
    Advance5(code,state,data,mem,prefix,ptr,free,length,value);
    var next5 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5); trace := trace+[next5]; state := next5;
    Advance6(code,state,data,mem,prefix,ptr,free,length,value);
    var next6 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6); trace := trace+[next6]; state := next6;
    Advance7(code,state,data,mem,prefix,ptr,free,length,value);
    var next7 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7); trace := trace+[next7]; state := next7;
    Advance8(code,state,data,mem,prefix,ptr,free,length,value);
    var next8 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8); trace := trace+[next8]; state := next8;
    Advance9(code,state,data,mem,prefix,ptr,free,length,value);
    var next9 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9); trace := trace+[next9]; state := next9;
    Advance10(code,state,data,mem,prefix,ptr,free,length,value);
    var next10 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10); trace := trace+[next10]; state := next10;
    Advance11(code,state,data,mem,prefix,ptr,free,length,value);
    var next11 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11); trace := trace+[next11]; state := next11;
    Advance12(code,state,data,mem,prefix,ptr,free,length,value);
    var next12 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12); trace := trace+[next12]; state := next12;
    Advance13(code,state,data,mem,prefix,ptr,free,length,value);
    var next13 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13); trace := trace+[next13]; state := next13;
    Advance14(code,state,data,mem,prefix,ptr,free,length,value);
    var next14 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14); trace := trace+[next14]; state := next14;
  }
  ghost method Block1(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(15,initial,data,mem,prefix,ptr,free,length,value)
    ensures Good(30,state,data,mem,prefix,ptr,free,length,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 16 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial; trace := [state];
    Advance15(code,state,data,mem,prefix,ptr,free,length,value);
    var next15 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15); trace := trace+[next15]; state := next15;
    Advance16(code,state,data,mem,prefix,ptr,free,length,value);
    var next16 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16); trace := trace+[next16]; state := next16;
    Advance17(code,state,data,mem,prefix,ptr,free,length,value);
    var next17 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17); trace := trace+[next17]; state := next17;
    Advance18(code,state,data,mem,prefix,ptr,free,length,value);
    var next18 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18); trace := trace+[next18]; state := next18;
    Advance19(code,state,data,mem,prefix,ptr,free,length,value);
    var next19 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19); trace := trace+[next19]; state := next19;
    Advance20(code,state,data,mem,prefix,ptr,free,length,value);
    var next20 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20); trace := trace+[next20]; state := next20;
    Advance21(code,state,data,mem,prefix,ptr,free,length,value);
    var next21 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21); trace := trace+[next21]; state := next21;
    Advance22(code,state,data,mem,prefix,ptr,free,length,value);
    var next22 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22); trace := trace+[next22]; state := next22;
    Advance23(code,state,data,mem,prefix,ptr,free,length,value);
    var next23 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23); trace := trace+[next23]; state := next23;
    Advance24(code,state,data,mem,prefix,ptr,free,length,value);
    var next24 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24); trace := trace+[next24]; state := next24;
    Advance25(code,state,data,mem,prefix,ptr,free,length,value);
    var next25 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25); trace := trace+[next25]; state := next25;
    Advance26(code,state,data,mem,prefix,ptr,free,length,value);
    var next26 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26); trace := trace+[next26]; state := next26;
    Advance27(code,state,data,mem,prefix,ptr,free,length,value);
    var next27 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27); trace := trace+[next27]; state := next27;
    Advance28(code,state,data,mem,prefix,ptr,free,length,value);
    var next28 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28); trace := trace+[next28]; state := next28;
    Advance29(code,state,data,mem,prefix,ptr,free,length,value);
    var next29 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29); trace := trace+[next29]; state := next29;
  }
  ghost method Block2(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value) && Good(30,initial,data,mem,prefix,ptr,free,length,value)
    ensures state == Running(16936,prefix+[free+length],H.Packed(mem,ptr,free,length)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 7 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial; trace := [state];
    Advance30(code,state,data,mem,prefix,ptr,free,length,value);
    var next30 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30); trace := trace+[next30]; state := next30;
    Advance31(code,state,data,mem,prefix,ptr,free,length,value);
    var next31 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31); trace := trace+[next31]; state := next31;
    Advance32(code,state,data,mem,prefix,ptr,free,length,value);
    var next32 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next32); trace := trace+[next32]; state := next32;
    Advance33(code,state,data,mem,prefix,ptr,free,length,value);
    var next33 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next33); trace := trace+[next33]; state := next33;
    Advance34(code,state,data,mem,prefix,ptr,free,length,value);
    var next34 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next34); trace := trace+[next34]; state := next34;
    Advance35(code,state,data,mem,prefix,ptr,free,length,value);
    var next35 := C.Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next35); trace := trace+[next35]; state := next35;
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,ptr,free,length,value)
    ensures state == Running(16936,prefix+[free+length],H.Packed(mem,ptr,free,length)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 37 && trace[0] == Running(24276,prefix+[16936,ptr,free],mem) && trace[|trace|-1] == state
  { state := Running(24276,prefix+[16936,ptr,free],mem); trace := [state]; reveal Good();
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,ptr,free,length,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block1(code,state,data,mem,prefix,ptr,free,length,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block2(code,state,data,mem,prefix,ptr,free,length,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
