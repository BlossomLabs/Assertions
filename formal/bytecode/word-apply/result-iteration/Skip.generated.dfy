// SPDX-License-Identifier: MIT
// Generated complete physical skip result iteration, arbitrary input/result words.
include "../../scans/Execution.dfy"
module BytecodeApplyResultSkip {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word) { 0 < n < 0x800000000000000 && index < n && kept <= index && (out as nat)+32+32*n < G.Modulus() && result == 0 && |prefix| <= 1006 }
  opaque predicate Matches(code: seq<Byte>) { |code| == 24560 && code[12391] == 91 &&
                                              code[12484] == 91 &&
                                              code[12485] == 144 &&
                                              code[12486] == 80 &&
                                              code[12487] == 135 &&
                                              code[12488] == 21 &&
                                              code[12489] == 97 &&
                                              code[12490] == 49 &&
                                              code[12491] == 37 &&
                                              code[12492] == 87 &&
                                              code[12493] == 96 &&
                                              code[12494] == 1 &&
                                              code[12495] == 129 &&
                                              code[12496] == 17 &&
                                              code[12497] == 21 &&
                                              code[12498] == 97 &&
                                              code[12499] == 49 &&
                                              code[12500] == 1 &&
                                              code[12501] == 87 &&
                                              code[12545] == 91 &&
                                              code[12546] == 128 &&
                                              code[12547] == 21 &&
                                              code[12548] == 97 &&
                                              code[12549] == 49 &&
                                              code[12550] == 32 &&
                                              code[12551] == 87 &&
                                              code[12576] == 91 &&
                                              code[12577] == 97 &&
                                              code[12578] == 49 &&
                                              code[12579] == 62 &&
                                              code[12580] == 86 &&
                                              code[12581] == 91 &&
                                              code[12606] == 91 &&
                                              code[12607] == 80 &&
                                              code[12608] == 80 &&
                                              code[12609] == 96 &&
                                              code[12610] == 1 &&
                                              code[12611] == 1 &&
                                              code[12612] == 97 &&
                                              code[12613] == 48 &&
                                              code[12614] == 103 &&
                                              code[12615] == 86 }
  function Destinations(): set<nat> { {12391,12545,12576,12581,12606} }
  opaque predicate Good(id: nat,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word) { Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && (
                                                                                                                                                                                                                                                                                                                                    if id == 0 then state == Running(12484,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,0,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 1 then state == Running(12485,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,0,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 2 then state == Running(12486,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 3 then state == Running(12487,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 4 then state == Running(12488,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 5 then state == Running(12489,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 6 then state == Running(12492,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0,12581],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 7 then state == Running(12493,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 8 then state == Running(12495,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 9 then state == Running(12496,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 10 then state == Running(12497,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 11 then state == Running(12498,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 12 then state == Running(12501,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1,12545],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 13 then state == Running(12545,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 14 then state == Running(12546,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 15 then state == Running(12547,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 16 then state == Running(12548,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 17 then state == Running(12551,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1,12576],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 18 then state == Running(12576,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 19 then state == Running(12577,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 20 then state == Running(12580,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,12606],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 21 then state == Running(12606,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 22 then state == Running(12607,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 23 then state == Running(12608,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 24 then state == Running(12609,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 25 then state == Running(12611,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,1],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 26 then state == Running(12612,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index+1],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 27 then state == Running(12615,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index+1,12391],mem)
                                                                                                                                                                                                                                                                                                                                    else false) }
  lemma Advance0(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(0,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12484,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,0,result],mem);
    assert Fetch(code,12484) == Op(91,12485,0);
  }
  lemma Advance1(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(1,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12485,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,0,result],mem);
    assert Fetch(code,12485) == Op(144,12486,0);
  }
  lemma Advance2(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(2,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12486,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0],mem);
    assert Fetch(code,12486) == Op(80,12487,0);
  }
  lemma Advance3(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(3,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12487,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem);
    assert Fetch(code,12487) == Op(135,12488,0);
  }
  lemma Advance4(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(4,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12488,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1],mem);
    assert Fetch(code,12488) == Op(21,12489,0);
  }
  lemma Advance5(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(5,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12489,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0],mem);
    F.Push2(code,12489);
    assert Fetch(code,12489) == Op(97,12492,12581);
  }
  lemma Advance6(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(6,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12492,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0,12581],mem);
    assert Fetch(code,12492) == Op(87,12493,0);
  }
  lemma Advance7(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(7,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12493,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem);
    F.Push1(code,12493);
    assert Fetch(code,12493) == Op(96,12495,1);
  }
  lemma Advance8(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(8,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12495,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1],mem);
    assert Fetch(code,12495) == Op(129,12496,0);
  }
  lemma Advance9(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(9,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12496,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1,result],mem);
    assert Fetch(code,12496) == Op(17,12497,0);
  }
  lemma Advance10(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(10,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12497,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0],mem);
    assert Fetch(code,12497) == Op(21,12498,0);
  }
  lemma Advance11(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(11,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12498,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1],mem);
    F.Push2(code,12498);
    assert Fetch(code,12498) == Op(97,12501,12545);
  }
  lemma Advance12(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(12,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12501,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1,12545],mem);
    assert Fetch(code,12501) == Op(87,12502,0);
  }
  lemma Advance13(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(13,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12545,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem);
    assert Fetch(code,12545) == Op(91,12546,0);
  }
  lemma Advance14(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(14,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12546,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem);
    assert Fetch(code,12546) == Op(128,12547,0);
  }
  lemma Advance15(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(15,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12547,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,result],mem);
    assert Fetch(code,12547) == Op(21,12548,0);
  }
  lemma Advance16(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(16,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12548,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1],mem);
    F.Push2(code,12548);
    assert Fetch(code,12548) == Op(97,12551,12576);
  }
  lemma Advance17(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(17,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12551,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,1,12576],mem);
    assert Fetch(code,12551) == Op(87,12552,0);
  }
  lemma Advance18(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(18,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12576,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem);
    assert Fetch(code,12576) == Op(91,12577,0);
  }
  lemma Advance19(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(19,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12577,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem);
    F.Push2(code,12577);
    assert Fetch(code,12577) == Op(97,12580,12606);
  }
  lemma Advance20(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(20,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12580,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,12606],mem);
    assert Fetch(code,12580) == Op(86,12581,0);
  }
  lemma Advance21(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(21,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12606,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem);
    assert Fetch(code,12606) == Op(91,12607,0);
  }
  lemma Advance22(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(22,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12607,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem);
    assert Fetch(code,12607) == Op(80,12608,0);
  }
  lemma Advance23(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(23,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12608,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word],mem);
    assert Fetch(code,12608) == Op(80,12609,0);
  }
  lemma Advance24(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(24,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12609,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index],mem);
    F.Push1(code,12609);
    assert Fetch(code,12609) == Op(96,12611,1);
  }
  lemma Advance25(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(25,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12611,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,1],mem);
    assert Fetch(code,12611) == Op(1,12612,0);
  }
  lemma Advance26(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(26,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12612,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index+1],mem);
    F.Push2(code,12612);
    assert Fetch(code,12612) == Op(97,12615,12391);
  }
  lemma Advance27(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(27,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(12391,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index+1],mem)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12615,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index+1,12391],mem);
    assert Fetch(code,12615) == Op(86,12616,0);
  }
  ghost method Block0(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(0,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Good(20,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial;trace := [state];
    Advance0(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next0 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next0);trace := trace+[next0];state := next0;
    Advance1(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next1 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next1);trace := trace+[next1];state := next1;
    Advance2(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next2 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next2);trace := trace+[next2];state := next2;
    Advance3(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next3 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next3);trace := trace+[next3];state := next3;
    Advance4(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next4 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next4);trace := trace+[next4];state := next4;
    Advance5(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next5 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next5);trace := trace+[next5];state := next5;
    Advance6(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next6 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next6);trace := trace+[next6];state := next6;
    Advance7(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next7 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next7);trace := trace+[next7];state := next7;
    Advance8(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next8 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next8);trace := trace+[next8];state := next8;
    Advance9(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next9 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next9);trace := trace+[next9];state := next9;
    Advance10(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next10 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next10);trace := trace+[next10];state := next10;
    Advance11(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next11 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next11);trace := trace+[next11];state := next11;
    Advance12(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next12 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next12);trace := trace+[next12];state := next12;
    Advance13(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next13 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next13);trace := trace+[next13];state := next13;
    Advance14(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next14 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next14);trace := trace+[next14];state := next14;
    Advance15(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next15 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next15);trace := trace+[next15];state := next15;
    Advance16(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next16 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next16);trace := trace+[next16];state := next16;
    Advance17(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next17 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next17);trace := trace+[next17];state := next17;
    Advance18(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next18 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next18);trace := trace+[next18];state := next18;
    Advance19(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next19 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next19);trace := trace+[next19];state := next19;
  }
  ghost method Block1(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(20,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures state == Running(12391,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index+1],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 9 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial;trace := [state];
    Advance20(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next20 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next20);trace := trace+[next20];state := next20;
    Advance21(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next21 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next21);trace := trace+[next21];state := next21;
    Advance22(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next22 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next22);trace := trace+[next22];state := next22;
    Advance23(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next23 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next23);trace := trace+[next23];state := next23;
    Advance24(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next24 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next24);trace := trace+[next24];state := next24;
    Advance25(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next25 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next25);trace := trace+[next25];state := next25;
    Advance26(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next26 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next26);trace := trace+[next26];state := next26;
    Advance27(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next27 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next27);trace := trace+[next27];state := next27;
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures state == Running(12391,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index+1],mem) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 29 && trace[0] == Running(12484,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,0,result],mem) && trace[|trace|-1] == state
  { state := Running(12484,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,0,result],mem);trace := [state];reveal Good();var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    state,part := Block1(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
  }
}
