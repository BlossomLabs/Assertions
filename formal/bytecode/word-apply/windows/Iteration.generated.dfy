// SPDX-License-Identifier: MIT
// Generated valid element-window control fragment; all reached instructions and helper calls retained.
include "Inputs.dfy"
module BytecodeApplyWindowsIteration {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import W = BytecodeApplyWindowInputs
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted(data: seq<Byte>,templateLength: Word,arrayOffset: Word,count: Word,index: Word) { W.Represented(templateLength,arrayOffset,count,data) && templateLength >= 32 && index < count && W.At(arrayOffset,index,data) <= templateLength-32 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 &&
                                              code[12235] == 91 &&
                                              code[13698] == 91 &&
                                              code[13699] == 146 &&
                                              code[13700] == 145 &&
                                              code[13701] == 80 &&
                                              code[13702] == 80 &&
                                              code[13703] == 86 &&
                                              code[16419] == 91 &&
                                              code[16728] == 91 &&
                                              code[16729] == 129 &&
                                              code[16730] == 129 &&
                                              code[16731] == 16 &&
                                              code[16732] == 21 &&
                                              code[16733] == 97 &&
                                              code[16734] == 64 &&
                                              code[16735] == 35 &&
                                              code[16736] == 87 &&
                                              code[16737] == 97 &&
                                              code[16738] == 65 &&
                                              code[16739] == 107 &&
                                              code[16740] == 96 &&
                                              code[16741] == 32 &&
                                              code[16742] == 133 &&
                                              code[16743] == 97 &&
                                              code[16744] == 92 &&
                                              code[16745] == 232 &&
                                              code[16746] == 86 &&
                                              code[16747] == 91 &&
                                              code[16748] == 131 &&
                                              code[16749] == 131 &&
                                              code[16750] == 131 &&
                                              code[16751] == 129 &&
                                              code[16752] == 129 &&
                                              code[16753] == 16 &&
                                              code[16754] == 97 &&
                                              code[16755] == 65 &&
                                              code[16756] == 125 &&
                                              code[16757] == 87 &&
                                              code[16765] == 91 &&
                                              code[16766] == 144 &&
                                              code[16767] == 80 &&
                                              code[16768] == 96 &&
                                              code[16769] == 32 &&
                                              code[16770] == 2 &&
                                              code[16771] == 1 &&
                                              code[16772] == 53 &&
                                              code[16773] == 17 &&
                                              code[16774] == 21 &&
                                              code[16775] == 97 &&
                                              code[16776] == 65 &&
                                              code[16777] == 200 &&
                                              code[16778] == 87 &&
                                              code[16840] == 91 &&
                                              code[16841] == 96 &&
                                              code[16842] == 1 &&
                                              code[16843] == 1 &&
                                              code[16844] == 97 &&
                                              code[16845] == 65 &&
                                              code[16846] == 88 &&
                                              code[16847] == 86 &&
                                              code[23784] == 91 &&
                                              code[23785] == 129 &&
                                              code[23786] == 129 &&
                                              code[23787] == 3 &&
                                              code[23788] == 129 &&
                                              code[23789] == 129 &&
                                              code[23790] == 17 &&
                                              code[23791] == 21 &&
                                              code[23792] == 97 &&
                                              code[23793] == 53 &&
                                              code[23794] == 130 &&
                                              code[23795] == 87
  }
  function Destinations(): set<nat> { {12235,13698,16419,16728,16747,16765,16840,23784} }
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word) { Admitted(data,templateLength,arrayOffset,count,index) && (
                                                                                                                                                                                                                if id == 0 then state == Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem)
                                                                                                                                                                                                                else if id == 1 then state == Running(16729,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem)
                                                                                                                                                                                                                else if id == 2 then state == Running(16730,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,count],mem)
                                                                                                                                                                                                                else if id == 3 then state == Running(16731,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,count,index],mem)
                                                                                                                                                                                                                else if id == 4 then state == Running(16732,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,1],mem)
                                                                                                                                                                                                                else if id == 5 then state == Running(16733,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,0],mem)
                                                                                                                                                                                                                else if id == 6 then state == Running(16736,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,0,16419],mem)
                                                                                                                                                                                                                else if id == 7 then state == Running(16737,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem)
                                                                                                                                                                                                                else if id == 8 then state == Running(16740,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747],mem)
                                                                                                                                                                                                                else if id == 9 then state == Running(16742,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32],mem)
                                                                                                                                                                                                                else if id == 10 then state == Running(16743,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength],mem)
                                                                                                                                                                                                                else if id == 11 then state == Running(16746,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,23784],mem)
                                                                                                                                                                                                                else if id == 12 then state == Running(23784,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength],mem)
                                                                                                                                                                                                                else if id == 13 then state == Running(23785,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength],mem)
                                                                                                                                                                                                                else if id == 14 then state == Running(23786,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,32],mem)
                                                                                                                                                                                                                else if id == 15 then state == Running(23787,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,32,templateLength],mem)
                                                                                                                                                                                                                else if id == 16 then state == Running(23788,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32],mem)
                                                                                                                                                                                                                else if id == 17 then state == Running(23789,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,templateLength],mem)
                                                                                                                                                                                                                else if id == 18 then state == Running(23790,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,templateLength,templateLength-32],mem)
                                                                                                                                                                                                                else if id == 19 then state == Running(23791,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,0],mem)
                                                                                                                                                                                                                else if id == 20 then state == Running(23792,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,1],mem)
                                                                                                                                                                                                                else if id == 21 then state == Running(23795,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,1,13698],mem)
                                                                                                                                                                                                                else if id == 22 then state == Running(13698,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32],mem)
                                                                                                                                                                                                                else if id == 23 then state == Running(13699,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32],mem)
                                                                                                                                                                                                                else if id == 24 then state == Running(13700,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,32,templateLength,16747],mem)
                                                                                                                                                                                                                else if id == 25 then state == Running(13701,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,16747,templateLength,32],mem)
                                                                                                                                                                                                                else if id == 26 then state == Running(13702,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,16747,templateLength],mem)
                                                                                                                                                                                                                else if id == 27 then state == Running(13703,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,16747],mem)
                                                                                                                                                                                                                else if id == 28 then state == Running(16747,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32],mem)
                                                                                                                                                                                                                else if id == 29 then state == Running(16748,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32],mem)
                                                                                                                                                                                                                else if id == 30 then state == Running(16749,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset],mem)
                                                                                                                                                                                                                else if id == 31 then state == Running(16750,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count],mem)
                                                                                                                                                                                                                else if id == 32 then state == Running(16751,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index],mem)
                                                                                                                                                                                                                else if id == 33 then state == Running(16752,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index,count],mem)
                                                                                                                                                                                                                else if id == 34 then state == Running(16753,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index,count,index],mem)
                                                                                                                                                                                                                else if id == 35 then state == Running(16754,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index,1],mem)
                                                                                                                                                                                                                else if id == 36 then state == Running(16757,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index,1,16765],mem)
                                                                                                                                                                                                                else if id == 37 then state == Running(16765,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index],mem)
                                                                                                                                                                                                                else if id == 38 then state == Running(16766,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index],mem)
                                                                                                                                                                                                                else if id == 39 then state == Running(16767,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,index,count],mem)
                                                                                                                                                                                                                else if id == 40 then state == Running(16768,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,index],mem)
                                                                                                                                                                                                                else if id == 41 then state == Running(16770,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,index,32],mem)
                                                                                                                                                                                                                else if id == 42 then state == Running(16771,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,((32 as nat)*(index as nat))%G.Modulus()],mem)
                                                                                                                                                                                                                else if id == 43 then state == Running(16772,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,((((32 as nat)*(index as nat))%G.Modulus() as nat)+(arrayOffset as nat))%G.Modulus()],mem)
                                                                                                                                                                                                                else if id == 44 then state == Running(16773,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,W.At(arrayOffset,index,data)],mem)
                                                                                                                                                                                                                else if id == 45 then state == Running(16774,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,0],mem)
                                                                                                                                                                                                                else if id == 46 then state == Running(16775,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,1],mem)
                                                                                                                                                                                                                else if id == 47 then state == Running(16778,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,1,16840],mem)
                                                                                                                                                                                                                else if id == 48 then state == Running(16840,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem)
                                                                                                                                                                                                                else if id == 49 then state == Running(16841,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem)
                                                                                                                                                                                                                else if id == 50 then state == Running(16843,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,1],mem)
                                                                                                                                                                                                                else if id == 51 then state == Running(16844,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index+1],mem)
                                                                                                                                                                                                                else if id == 52 then state == Running(16847,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index+1,16728],mem)
                                                                                                                                                                                                                else false) }
  lemma Advance0(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(0,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem);
    assert Fetch(code,16728) == Op(91,16729,0);
  }
  lemma Advance1(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(1,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16729,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem);
    assert Fetch(code,16729) == Op(129,16730,0);
  }
  lemma Advance2(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(2,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16730,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,count],mem);
    assert Fetch(code,16730) == Op(129,16731,0);
  }
  lemma Advance3(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(3,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16731,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,count,index],mem);
    assert Fetch(code,16731) == Op(16,16732,0);
  }
  lemma Advance4(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(4,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16732,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,1],mem);
    assert Fetch(code,16732) == Op(21,16733,0);
  }
  lemma Advance5(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(5,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16733,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,0],mem);
    F.Push2(code,16733);
    assert Fetch(code,16733) == Op(97,16736,16419);
  }
  lemma Advance6(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(6,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16736,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,0,16419],mem);
    assert Fetch(code,16736) == Op(87,16737,0);
  }
  lemma Advance7(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(7,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16737,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem);
    F.Push2(code,16737);
    assert Fetch(code,16737) == Op(97,16740,16747);
  }
  lemma Advance8(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(8,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16740,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747],mem);
    F.Push1(code,16740);
    assert Fetch(code,16740) == Op(96,16742,32);
  }
  lemma Advance9(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(9,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16742,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32],mem);
    assert Fetch(code,16742) == Op(133,16743,0);
  }
  lemma Advance10(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(10,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16743,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength],mem);
    F.Push2(code,16743);
    assert Fetch(code,16743) == Op(97,16746,23784);
  }
  lemma Advance11(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(11,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16746,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,23784],mem);
    assert Fetch(code,16746) == Op(86,16747,0);
  }
  lemma Advance12(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(12,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23784,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength],mem);
    assert Fetch(code,23784) == Op(91,23785,0);
  }
  lemma Advance13(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(13,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23785,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength],mem);
    assert Fetch(code,23785) == Op(129,23786,0);
  }
  lemma Advance14(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(14,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23786,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,32],mem);
    assert Fetch(code,23786) == Op(129,23787,0);
  }
  lemma Advance15(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(15,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23787,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,32,templateLength],mem);
    assert Fetch(code,23787) == Op(3,23788,0);
  }
  lemma Advance16(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(16,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23788,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32],mem);
    assert Fetch(code,23788) == Op(129,23789,0);
  }
  lemma Advance17(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(17,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23789,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,templateLength],mem);
    assert Fetch(code,23789) == Op(129,23790,0);
  }
  lemma Advance18(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(18,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23790,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,templateLength,templateLength-32],mem);
    assert Fetch(code,23790) == Op(17,23791,0);
  }
  lemma Advance19(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(19,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23791,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,0],mem);
    assert Fetch(code,23791) == Op(21,23792,0);
  }
  lemma Advance20(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(20,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23792,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,1],mem);
    F.Push2(code,23792);
    assert Fetch(code,23792) == Op(97,23795,13698);
  }
  lemma Advance21(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(21,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23795,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32,1,13698],mem);
    assert Fetch(code,23795) == Op(87,23796,0);
  }
  lemma Advance22(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(22,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13698,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32],mem);
    assert Fetch(code,13698) == Op(91,13699,0);
  }
  lemma Advance23(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(23,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13699,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,16747,32,templateLength,templateLength-32],mem);
    assert Fetch(code,13699) == Op(146,13700,0);
  }
  lemma Advance24(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(24,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13700,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,32,templateLength,16747],mem);
    assert Fetch(code,13700) == Op(145,13701,0);
  }
  lemma Advance25(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(25,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13701,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,16747,templateLength,32],mem);
    assert Fetch(code,13701) == Op(80,13702,0);
  }
  lemma Advance26(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(26,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13702,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,16747,templateLength],mem);
    assert Fetch(code,13702) == Op(80,13703,0);
  }
  lemma Advance27(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(27,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(13703,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,16747],mem);
    assert Fetch(code,13703) == Op(86,13704,0);
  }
  lemma Advance28(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(28,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16747,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32],mem);
    assert Fetch(code,16747) == Op(91,16748,0);
  }
  lemma Advance29(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(29,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16748,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32],mem);
    assert Fetch(code,16748) == Op(131,16749,0);
  }
  lemma Advance30(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(30,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16749,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset],mem);
    assert Fetch(code,16749) == Op(131,16750,0);
  }
  lemma Advance31(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(31,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(32,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16750,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count],mem);
    assert Fetch(code,16750) == Op(131,16751,0);
  }
  lemma Advance32(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(32,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(33,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16751,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index],mem);
    assert Fetch(code,16751) == Op(129,16752,0);
  }
  lemma Advance33(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(33,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(34,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16752,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index,count],mem);
    assert Fetch(code,16752) == Op(129,16753,0);
  }
  lemma Advance34(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(34,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(35,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16753,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index,count,index],mem);
    assert Fetch(code,16753) == Op(16,16754,0);
  }
  lemma Advance35(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(35,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(36,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16754,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index,1],mem);
    F.Push2(code,16754);
    assert Fetch(code,16754) == Op(97,16757,16765);
  }
  lemma Advance36(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(36,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(37,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16757,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index,1,16765],mem);
    assert Fetch(code,16757) == Op(87,16758,0);
  }
  lemma Advance37(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(37,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(38,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16765,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index],mem);
    assert Fetch(code,16765) == Op(91,16766,0);
  }
  lemma Advance38(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(38,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(39,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16766,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,count,index],mem);
    assert Fetch(code,16766) == Op(144,16767,0);
  }
  lemma Advance39(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(39,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(40,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16767,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,index,count],mem);
    assert Fetch(code,16767) == Op(80,16768,0);
  }
  lemma Advance40(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(40,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(41,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16768,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,index],mem);
    F.Push1(code,16768);
    assert Fetch(code,16768) == Op(96,16770,32);
  }
  lemma Advance41(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(41,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(42,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16770,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,index,32],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16770) == Op(2,16771,0);
  }
  lemma Advance42(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(42,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(43,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16771,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,arrayOffset,((32 as nat)*(index as nat))%G.Modulus()],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16771) == Op(1,16772,0);
  }
  lemma Advance43(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(43,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(44,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16772,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,((((32 as nat)*(index as nat))%G.Modulus() as nat)+(arrayOffset as nat))%G.Modulus()],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16772) == Op(53,16773,0);
  }
  lemma Advance44(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(44,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(45,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16773,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,templateLength-32,W.At(arrayOffset,index,data)],mem);
    assert Fetch(code,16773) == Op(17,16774,0);
  }
  lemma Advance45(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(45,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(46,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16774,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,0],mem);
    assert Fetch(code,16774) == Op(21,16775,0);
  }
  lemma Advance46(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(46,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(47,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16775,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,1],mem);
    F.Push2(code,16775);
    assert Fetch(code,16775) == Op(97,16778,16840);
  }
  lemma Advance47(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(47,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(48,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16778,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,1,16840],mem);
    assert Fetch(code,16778) == Op(87,16779,0);
  }
  lemma Advance48(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(48,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(49,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16840,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem);
    assert Fetch(code,16840) == Op(91,16841,0);
  }
  lemma Advance49(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(49,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(50,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16841,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem);
    F.Push1(code,16841);
    assert Fetch(code,16841) == Op(96,16843,1);
  }
  lemma Advance50(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(50,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(51,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16843,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index,1],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16843) == Op(1,16844,0);
  }
  lemma Advance51(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(51,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(52,next,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16844,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index+1],mem);
    F.Push2(code,16844);
    assert Fetch(code,16844) == Op(97,16847,16728);
  }
  lemma Advance52(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(52,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index+1],mem)
  {
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16847,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index+1,16728],mem);
    assert Fetch(code,16847) == Op(86,16848,0);
  }
  lemma Start(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word)
    requires returnPc == 12235 && Admitted(data,templateLength,arrayOffset,count,index)
    ensures Good(0,Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem),data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index)
  { reveal Good(); }
  ghost method Block0(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word) returns (state: State, trace: seq<State>)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(0,initial,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures Good(20,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance0(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);
    trace := trace+[next0]; state := next0;
    Advance1(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);
    trace := trace+[next1]; state := next1;
    Advance2(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);
    trace := trace+[next2]; state := next2;
    Advance3(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);
    trace := trace+[next3]; state := next3;
    Advance4(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);
    trace := trace+[next4]; state := next4;
    Advance5(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);
    trace := trace+[next5]; state := next5;
    Advance6(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);
    trace := trace+[next6]; state := next6;
    Advance7(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);
    trace := trace+[next7]; state := next7;
    Advance8(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);
    trace := trace+[next8]; state := next8;
    Advance9(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);
    trace := trace+[next9]; state := next9;
    Advance10(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);
    trace := trace+[next10]; state := next10;
    Advance11(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);
    trace := trace+[next11]; state := next11;
    Advance12(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);
    trace := trace+[next12]; state := next12;
    Advance13(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);
    trace := trace+[next13]; state := next13;
    Advance14(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);
    trace := trace+[next14]; state := next14;
    Advance15(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);
    trace := trace+[next15]; state := next15;
    Advance16(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);
    trace := trace+[next16]; state := next16;
    Advance17(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);
    trace := trace+[next17]; state := next17;
    Advance18(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);
    trace := trace+[next18]; state := next18;
    Advance19(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);
    trace := trace+[next19]; state := next19;
  }
  ghost method Block1(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word) returns (state: State, trace: seq<State>)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(20,initial,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures Good(40,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance20(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);
    trace := trace+[next20]; state := next20;
    Advance21(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);
    trace := trace+[next21]; state := next21;
    Advance22(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);
    trace := trace+[next22]; state := next22;
    Advance23(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);
    trace := trace+[next23]; state := next23;
    Advance24(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);
    trace := trace+[next24]; state := next24;
    Advance25(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);
    trace := trace+[next25]; state := next25;
    Advance26(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);
    trace := trace+[next26]; state := next26;
    Advance27(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);
    trace := trace+[next27]; state := next27;
    Advance28(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);
    trace := trace+[next28]; state := next28;
    Advance29(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);
    trace := trace+[next29]; state := next29;
    Advance30(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next30 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30);
    trace := trace+[next30]; state := next30;
    Advance31(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next31 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31);
    trace := trace+[next31]; state := next31;
    Advance32(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next32 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next32);
    trace := trace+[next32]; state := next32;
    Advance33(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next33 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next33);
    trace := trace+[next33]; state := next33;
    Advance34(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next34 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next34);
    trace := trace+[next34]; state := next34;
    Advance35(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next35 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next35);
    trace := trace+[next35]; state := next35;
    Advance36(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next36 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next36);
    trace := trace+[next36]; state := next36;
    Advance37(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next37 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next37);
    trace := trace+[next37]; state := next37;
    Advance38(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next38 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next38);
    trace := trace+[next38]; state := next38;
    Advance39(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next39 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next39);
    trace := trace+[next39]; state := next39;
  }
  ghost method Block2(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word) returns (state: State, trace: seq<State>)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && Good(40,initial,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state == Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index+1],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 14 && trace[0] == initial && trace[|trace|-1] == state
  {
    state := initial; trace := [state];
    Advance40(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next40 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next40);
    trace := trace+[next40]; state := next40;
    Advance41(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next41 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next41);
    trace := trace+[next41]; state := next41;
    Advance42(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next42 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next42);
    trace := trace+[next42]; state := next42;
    Advance43(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next43 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next43);
    trace := trace+[next43]; state := next43;
    Advance44(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next44 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next44);
    trace := trace+[next44]; state := next44;
    Advance45(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next45 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next45);
    trace := trace+[next45]; state := next45;
    Advance46(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next46 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next46);
    trace := trace+[next46]; state := next46;
    Advance47(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next47 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next47);
    trace := trace+[next47]; state := next47;
    Advance48(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next48 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next48);
    trace := trace+[next48]; state := next48;
    Advance49(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next49 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next49);
    trace := trace+[next49]; state := next49;
    Advance50(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next50 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next50);
    trace := trace+[next50]; state := next50;
    Advance51(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next51 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next51);
    trace := trace+[next51]; state := next51;
    Advance52(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    var next52 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next52);
    trace := trace+[next52]; state := next52;
  }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word) returns (state: State, trace: seq<State>)
    requires returnPc == 12235 && Matches(code) && Admitted(data,templateLength,arrayOffset,count,index) && |prefix| <= 1012
    ensures state == Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index+1],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 54 && trace[0] == Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem) && trace[|trace|-1] == state
  {
    Start(data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index);
    state := Running(16728,prefix+[returnPc,templateOffset,templateLength,arrayOffset,count,index],mem); trace := [state];
    var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block1(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block2(code,state,data,mem,prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
