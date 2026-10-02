// SPDX-License-Identifier: MIT
// Generated actual stamping loop leaf; arbitrary finite indices and words.
include "../windows/Inputs.dfy"
include "../../scans/Push.dfy"
module BytecodeApplyStampIteration {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import W = BytecodeApplyWindowInputs
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted(data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word) { W.Valid(templateLength,arrayOffset,count,data) && index < count && callPtr < 0x20000000000000000 && |mem|%32 == 0 && |mem| < 0x80000000000000000 && (callPtr as nat)+32+templateLength <= |mem| && returnPc == 12472 && |prefix| <= 1012 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 && code[12472] == 91 &&
                                              code[16419] == 91 &&
                                              code[16850] == 91 &&
                                              code[16851] == 130 &&
                                              code[16852] == 129 &&
                                              code[16853] == 16 &&
                                              code[16854] == 21 &&
                                              code[16855] == 97 &&
                                              code[16856] == 64 &&
                                              code[16857] == 35 &&
                                              code[16858] == 87 &&
                                              code[16859] == 95 &&
                                              code[16860] == 132 &&
                                              code[16861] == 132 &&
                                              code[16862] == 131 &&
                                              code[16863] == 129 &&
                                              code[16864] == 129 &&
                                              code[16865] == 16 &&
                                              code[16866] == 97 &&
                                              code[16867] == 65 &&
                                              code[16868] == 237 &&
                                              code[16869] == 87 &&
                                              code[16877] == 91 &&
                                              code[16878] == 96 &&
                                              code[16879] == 32 &&
                                              code[16880] == 144 &&
                                              code[16881] == 129 &&
                                              code[16882] == 2 &&
                                              code[16883] == 146 &&
                                              code[16884] == 144 &&
                                              code[16885] == 146 &&
                                              code[16886] == 1 &&
                                              code[16887] == 53 &&
                                              code[16888] == 136 &&
                                              code[16889] == 1 &&
                                              code[16890] == 144 &&
                                              code[16891] == 145 &&
                                              code[16892] == 1 &&
                                              code[16893] == 132 &&
                                              code[16894] == 144 &&
                                              code[16895] == 82 &&
                                              code[16896] == 80 &&
                                              code[16897] == 80 &&
                                              code[16898] == 96 &&
                                              code[16899] == 1 &&
                                              code[16900] == 1 &&
                                              code[16901] == 97 &&
                                              code[16902] == 65 &&
                                              code[16903] == 210 &&
                                              code[16904] == 86 }
  function Destinations(): set<nat> { {12472,16419,16850,16877} }
  opaque predicate Good(id: nat,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word) { Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && (
                                                                                                                                                                                                                                if id == 0 then state == Running(16850,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem)
                                                                                                                                                                                                                                else if id == 1 then state == Running(16851,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem)
                                                                                                                                                                                                                                else if id == 2 then state == Running(16852,prefix+[returnPc,callPtr,arrayOffset,count,word,index,count],mem)
                                                                                                                                                                                                                                else if id == 3 then state == Running(16853,prefix+[returnPc,callPtr,arrayOffset,count,word,index,count,index],mem)
                                                                                                                                                                                                                                else if id == 4 then state == Running(16854,prefix+[returnPc,callPtr,arrayOffset,count,word,index,1],mem)
                                                                                                                                                                                                                                else if id == 5 then state == Running(16855,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0],mem)
                                                                                                                                                                                                                                else if id == 6 then state == Running(16858,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,16419],mem)
                                                                                                                                                                                                                                else if id == 7 then state == Running(16859,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem)
                                                                                                                                                                                                                                else if id == 8 then state == Running(16860,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0],mem)
                                                                                                                                                                                                                                else if id == 9 then state == Running(16861,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset],mem)
                                                                                                                                                                                                                                else if id == 10 then state == Running(16862,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count],mem)
                                                                                                                                                                                                                                else if id == 11 then state == Running(16863,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,index],mem)
                                                                                                                                                                                                                                else if id == 12 then state == Running(16864,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,index,count],mem)
                                                                                                                                                                                                                                else if id == 13 then state == Running(16865,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,index,count,index],mem)
                                                                                                                                                                                                                                else if id == 14 then state == Running(16866,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,index,1],mem)
                                                                                                                                                                                                                                else if id == 15 then state == Running(16869,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,index,1,16877],mem)
                                                                                                                                                                                                                                else if id == 16 then state == Running(16877,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,index],mem)
                                                                                                                                                                                                                                else if id == 17 then state == Running(16878,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,index],mem)
                                                                                                                                                                                                                                else if id == 18 then state == Running(16880,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,index,32],mem)
                                                                                                                                                                                                                                else if id == 19 then state == Running(16881,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,32,index],mem)
                                                                                                                                                                                                                                else if id == 20 then state == Running(16882,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,32,index,32],mem)
                                                                                                                                                                                                                                else if id == 21 then state == Running(16883,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,32,index*32],mem)
                                                                                                                                                                                                                                else if id == 22 then state == Running(16884,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,index*32,count,32,arrayOffset],mem)
                                                                                                                                                                                                                                else if id == 23 then state == Running(16885,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,index*32,count,arrayOffset,32],mem)
                                                                                                                                                                                                                                else if id == 24 then state == Running(16886,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,32,count,arrayOffset,index*32],mem)
                                                                                                                                                                                                                                else if id == 25 then state == Running(16887,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,32,count,((arrayOffset as nat)+index*32)%G.Modulus()],mem)
                                                                                                                                                                                                                                else if id == 26 then state == Running(16888,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,32,count,W.At(arrayOffset,index,data)],mem)
                                                                                                                                                                                                                                else if id == 27 then state == Running(16889,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,32,count,W.At(arrayOffset,index,data),callPtr],mem)
                                                                                                                                                                                                                                else if id == 28 then state == Running(16890,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,32,count,callPtr+W.At(arrayOffset,index,data)],mem)
                                                                                                                                                                                                                                else if id == 29 then state == Running(16891,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,32,callPtr+W.At(arrayOffset,index,data),count],mem)
                                                                                                                                                                                                                                else if id == 30 then state == Running(16892,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,count,callPtr+W.At(arrayOffset,index,data),32],mem)
                                                                                                                                                                                                                                else if id == 31 then state == Running(16893,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,count,callPtr+W.At(arrayOffset,index,data)+32],mem)
                                                                                                                                                                                                                                else if id == 32 then state == Running(16894,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,count,callPtr+W.At(arrayOffset,index,data)+32,word],mem)
                                                                                                                                                                                                                                else if id == 33 then state == Running(16895,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,count,word,callPtr+W.At(arrayOffset,index,data)+32],mem)
                                                                                                                                                                                                                                else if id == 34 then state == Running(16896,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,count],Store(mem,callPtr+W.At(arrayOffset,index,data)+32,word))
                                                                                                                                                                                                                                else if id == 35 then state == Running(16897,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0],Store(mem,callPtr+W.At(arrayOffset,index,data)+32,word))
                                                                                                                                                                                                                                else if id == 36 then state == Running(16898,prefix+[returnPc,callPtr,arrayOffset,count,word,index],Store(mem,callPtr+W.At(arrayOffset,index,data)+32,word))
                                                                                                                                                                                                                                else if id == 37 then state == Running(16900,prefix+[returnPc,callPtr,arrayOffset,count,word,index,1],Store(mem,callPtr+W.At(arrayOffset,index,data)+32,word))
                                                                                                                                                                                                                                else if id == 38 then state == Running(16901,prefix+[returnPc,callPtr,arrayOffset,count,word,index+1],Store(mem,callPtr+W.At(arrayOffset,index,data)+32,word))
                                                                                                                                                                                                                                else if id == 39 then state == Running(16904,prefix+[returnPc,callPtr,arrayOffset,count,word,index+1,16850],Store(mem,callPtr+W.At(arrayOffset,index,data)+32,word))
                                                                                                                                                                                                                                else false) }
  lemma Advance0(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(0,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16850,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16850) == Op(91,16851,0);
  }
  lemma Advance1(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(1,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16851,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16851) == Op(130,16852,0);
  }
  lemma Advance2(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(2,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16852,prefix+[returnPc,callPtr,arrayOffset,count,word,index,count],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16852) == Op(129,16853,0);
  }
  lemma Advance3(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(3,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16853,prefix+[returnPc,callPtr,arrayOffset,count,word,index,count,index],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16853) == Op(16,16854,0);
  }
  lemma Advance4(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(4,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16854,prefix+[returnPc,callPtr,arrayOffset,count,word,index,1],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16854) == Op(21,16855,0);
  }
  lemma Advance5(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(5,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16855,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0],mem);
    F.Push2(code,16855);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16855) == Op(97,16858,16419);
  }
  lemma Advance6(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(6,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16858,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,16419],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16858) == Op(87,16859,0);
  }
  lemma Advance7(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(7,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16859,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16859) == Op(95,16860,0);
  }
  lemma Advance8(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(8,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16860,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16860) == Op(132,16861,0);
  }
  lemma Advance9(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(9,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16861,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16861) == Op(132,16862,0);
  }
  lemma Advance10(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(10,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16862,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16862) == Op(131,16863,0);
  }
  lemma Advance11(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(11,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16863,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,index],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16863) == Op(129,16864,0);
  }
  lemma Advance12(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(12,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16864,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,index,count],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16864) == Op(129,16865,0);
  }
  lemma Advance13(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(13,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16865,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,index,count,index],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16865) == Op(16,16866,0);
  }
  lemma Advance14(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(14,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16866,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,index,1],mem);
    F.Push2(code,16866);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16866) == Op(97,16869,16877);
  }
  lemma Advance15(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(15,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16869,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,index,1,16877],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16869) == Op(87,16870,0);
  }
  lemma Advance16(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(16,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16877,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,index],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16877) == Op(91,16878,0);
  }
  lemma Advance17(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(17,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16878,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,index],mem);
    F.Push1(code,16878);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16878) == Op(96,16880,32);
  }
  lemma Advance18(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(18,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16880,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,index,32],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16880) == Op(144,16881,0);
  }
  lemma Advance19(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(19,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16881,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,32,index],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16881) == Op(129,16882,0);
  }
  lemma Advance20(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(20,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16882,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,32,index,32],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16882) == Op(2,16883,0);
  }
  lemma Advance21(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(21,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16883,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,arrayOffset,count,32,index*32],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16883) == Op(146,16884,0);
  }
  lemma Advance22(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(22,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16884,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,index*32,count,32,arrayOffset],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16884) == Op(144,16885,0);
  }
  lemma Advance23(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(23,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16885,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,index*32,count,arrayOffset,32],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16885) == Op(146,16886,0);
  }
  lemma Advance24(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(24,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16886,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,32,count,arrayOffset,index*32],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16886) == Op(1,16887,0);
  }
  lemma Advance25(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(25,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16887,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,32,count,((arrayOffset as nat)+index*32)%G.Modulus()],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16887) == Op(53,16888,0);
  }
  lemma Advance26(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(26,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16888,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,32,count,W.At(arrayOffset,index,data)],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16888) == Op(136,16889,0);
  }
  lemma Advance27(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(27,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16889,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,32,count,W.At(arrayOffset,index,data),callPtr],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16889) == Op(1,16890,0);
  }
  lemma Advance28(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(28,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16890,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,32,count,callPtr+W.At(arrayOffset,index,data)],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16890) == Op(144,16891,0);
  }
  lemma Advance29(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(29,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16891,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,32,callPtr+W.At(arrayOffset,index,data),count],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16891) == Op(145,16892,0);
  }
  lemma Advance30(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(30,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16892,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,count,callPtr+W.At(arrayOffset,index,data),32],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16892) == Op(1,16893,0);
  }
  lemma Advance31(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(31,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(32,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16893,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,count,callPtr+W.At(arrayOffset,index,data)+32],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16893) == Op(132,16894,0);
  }
  lemma Advance32(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(32,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(33,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16894,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,count,callPtr+W.At(arrayOffset,index,data)+32,word],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16894) == Op(144,16895,0);
  }
  lemma Advance33(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(33,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(34,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16895,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,count,word,callPtr+W.At(arrayOffset,index,data)+32],mem);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16895) == Op(82,16896,0);
  }
  lemma Advance34(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(34,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(35,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16896,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0,count],Store(mem,callPtr+W.At(arrayOffset,index,data)+32,word));
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16896) == Op(80,16897,0);
  }
  lemma Advance35(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(35,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(36,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16897,prefix+[returnPc,callPtr,arrayOffset,count,word,index,0],Store(mem,callPtr+W.At(arrayOffset,index,data)+32,word));
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16897) == Op(80,16898,0);
  }
  lemma Advance36(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(36,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(37,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16898,prefix+[returnPc,callPtr,arrayOffset,count,word,index],Store(mem,callPtr+W.At(arrayOffset,index,data)+32,word));
    F.Push1(code,16898);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16898) == Op(96,16900,1);
  }
  lemma Advance37(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(37,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(38,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16900,prefix+[returnPc,callPtr,arrayOffset,count,word,index,1],Store(mem,callPtr+W.At(arrayOffset,index,data)+32,word));
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16900) == Op(1,16901,0);
  }
  lemma Advance38(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(38,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(39,next,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16901,prefix+[returnPc,callPtr,arrayOffset,count,word,index+1],Store(mem,callPtr+W.At(arrayOffset,index,data)+32,word));
    F.Push2(code,16901);
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16901) == Op(97,16904,16850);
  }
  lemma Advance39(code: seq<Byte>,state: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(39,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(16850,prefix+[returnPc,callPtr,arrayOffset,count,word,index+1],Store(mem,callPtr+W.At(arrayOffset,index,data)+32,word))
  { reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(16904,prefix+[returnPc,callPtr,arrayOffset,count,word,index+1,16850],Store(mem,callPtr+W.At(arrayOffset,index,data)+32,word));
    W.Index(templateLength,arrayOffset,count,data,index);
    assert Fetch(code,16904) == Op(86,16905,0);
  }
  ghost method Block0(code: seq<Byte>,initial: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(0,initial,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures Good(20,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial; trace := [state];
    Advance0(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0); trace := trace+[next0]; state := next0;
    Advance1(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1); trace := trace+[next1]; state := next1;
    Advance2(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2); trace := trace+[next2]; state := next2;
    Advance3(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3); trace := trace+[next3]; state := next3;
    Advance4(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4); trace := trace+[next4]; state := next4;
    Advance5(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5); trace := trace+[next5]; state := next5;
    Advance6(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6); trace := trace+[next6]; state := next6;
    Advance7(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7); trace := trace+[next7]; state := next7;
    Advance8(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8); trace := trace+[next8]; state := next8;
    Advance9(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9); trace := trace+[next9]; state := next9;
    Advance10(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10); trace := trace+[next10]; state := next10;
    Advance11(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11); trace := trace+[next11]; state := next11;
    Advance12(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12); trace := trace+[next12]; state := next12;
    Advance13(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13); trace := trace+[next13]; state := next13;
    Advance14(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14); trace := trace+[next14]; state := next14;
    Advance15(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15); trace := trace+[next15]; state := next15;
    Advance16(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16); trace := trace+[next16]; state := next16;
    Advance17(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17); trace := trace+[next17]; state := next17;
    Advance18(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18); trace := trace+[next18]; state := next18;
    Advance19(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19); trace := trace+[next19]; state := next19;
  }
  ghost method Block1(code: seq<Byte>,initial: State,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value) && Good(20,initial,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state == Running(16850,prefix+[returnPc,callPtr,arrayOffset,count,word,index+1],Store(mem,callPtr+W.At(arrayOffset,index,data)+32,word)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial; trace := [state];
    Advance20(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20); trace := trace+[next20]; state := next20;
    Advance21(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21); trace := trace+[next21]; state := next21;
    Advance22(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22); trace := trace+[next22]; state := next22;
    Advance23(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23); trace := trace+[next23]; state := next23;
    Advance24(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24); trace := trace+[next24]; state := next24;
    Advance25(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25); trace := trace+[next25]; state := next25;
    Advance26(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26); trace := trace+[next26]; state := next26;
    Advance27(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27); trace := trace+[next27]; state := next27;
    Advance28(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28); trace := trace+[next28]; state := next28;
    Advance29(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29); trace := trace+[next29]; state := next29;
    Advance30(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next30 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30); trace := trace+[next30]; state := next30;
    Advance31(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next31 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31); trace := trace+[next31]; state := next31;
    Advance32(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next32 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next32); trace := trace+[next32]; state := next32;
    Advance33(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next33 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next33); trace := trace+[next33]; state := next33;
    Advance34(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next34 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next34); trace := trace+[next34]; state := next34;
    Advance35(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next35 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next35); trace := trace+[next35]; state := next35;
    Advance36(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next36 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next36); trace := trace+[next36]; state := next36;
    Advance37(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next37 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next37); trace := trace+[next37]; state := next37;
    Advance38(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next38 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next38); trace := trace+[next38]; state := next38;
    Advance39(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    var next39 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next39); trace := trace+[next39]; state := next39;
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value)
    ensures state == Running(16850,prefix+[returnPc,callPtr,arrayOffset,count,word,index+1],Store(mem,callPtr+W.At(arrayOffset,index,data)+32,word)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 41 && trace[0] == Running(16850,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem) && trace[|trace|-1] == state
  { state := Running(16850,prefix+[returnPc,callPtr,arrayOffset,count,word,index],mem); trace := [state]; reveal Good(); var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
    state,part := Block1(code,state,data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value);
    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];
  }
}
