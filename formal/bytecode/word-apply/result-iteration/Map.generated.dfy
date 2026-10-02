// SPDX-License-Identifier: MIT
// Generated complete physical map result iteration, arbitrary input/result words.
include "../../scans/Execution.dfy"
module BytecodeApplyResultMap {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word) { 0 < n < 0x800000000000000 && index < n && kept <= index && (out as nat)+32+32*n < G.Modulus() && true && |prefix| <= 1002 }
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
                                              code[12581] == 91 &&
                                              code[12582] == 96 &&
                                              code[12583] == 32 &&
                                              code[12584] == 128 &&
                                              code[12585] == 132 &&
                                              code[12586] == 2 &&
                                              code[12587] == 136 &&
                                              code[12588] == 1 &&
                                              code[12589] == 1 &&
                                              code[12590] == 129 &&
                                              code[12591] == 144 &&
                                              code[12592] == 82 &&
                                              code[12593] == 132 &&
                                              code[12594] == 97 &&
                                              code[12595] == 49 &&
                                              code[12596] == 58 &&
                                              code[12597] == 129 &&
                                              code[12598] == 97 &&
                                              code[12599] == 92 &&
                                              code[12600] == 208 &&
                                              code[12601] == 86 &&
                                              code[12602] == 91 &&
                                              code[12603] == 149 &&
                                              code[12604] == 80 &&
                                              code[12605] == 80 &&
                                              code[12606] == 91 &&
                                              code[12607] == 80 &&
                                              code[12608] == 80 &&
                                              code[12609] == 96 &&
                                              code[12610] == 1 &&
                                              code[12611] == 1 &&
                                              code[12612] == 97 &&
                                              code[12613] == 48 &&
                                              code[12614] == 103 &&
                                              code[12615] == 86 &&
                                              code[23760] == 91 &&
                                              code[23761] == 95 &&
                                              code[23762] == 96 &&
                                              code[23763] == 1 &&
                                              code[23764] == 130 &&
                                              code[23765] == 1 &&
                                              code[23766] == 97 &&
                                              code[23767] == 92 &&
                                              code[23768] == 225 &&
                                              code[23769] == 87 &&
                                              code[23777] == 91 &&
                                              code[23778] == 80 &&
                                              code[23779] == 96 &&
                                              code[23780] == 1 &&
                                              code[23781] == 1 &&
                                              code[23782] == 144 &&
                                              code[23783] == 86 }
  function Destinations(): set<nat> { {12391,12581,12602,23760,23777} }
  opaque predicate Good(id: nat,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word) { Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && (
                                                                                                                                                                                                                                                                                                                                    if id == 0 then state == Running(12484,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,0,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 1 then state == Running(12485,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,0,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 2 then state == Running(12486,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,0],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 3 then state == Running(12487,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 4 then state == Running(12488,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,0],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 5 then state == Running(12489,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,1],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 6 then state == Running(12492,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,1,12581],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 7 then state == Running(12581,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 8 then state == Running(12582,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 9 then state == Running(12584,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,32],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 10 then state == Running(12585,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,32,32],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 11 then state == Running(12586,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,32,32,index],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 12 then state == Running(12587,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,32,index*32],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 13 then state == Running(12588,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,32,index*32,out],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 14 then state == Running(12589,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,32,out+index*32],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 15 then state == Running(12590,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,out+index*32+32],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 16 then state == Running(12591,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,out+index*32+32,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 17 then state == Running(12592,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,result,out+index*32+32],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 18 then state == Running(12593,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 19 then state == Running(12594,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 20 then state == Running(12597,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 21 then state == Running(12598,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 22 then state == Running(12601,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,23760],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 23 then state == Running(23760,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 24 then state == Running(23761,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 25 then state == Running(23762,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,0],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 26 then state == Running(23764,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,0,1],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 27 then state == Running(23765,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,0,1,kept],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 28 then state == Running(23766,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,0,kept+1],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 29 then state == Running(23769,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,0,kept+1,23777],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 30 then state == Running(23777,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,0],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 31 then state == Running(23778,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,0],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 32 then state == Running(23779,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 33 then state == Running(23781,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,1],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 34 then state == Running(23782,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept+1],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 35 then state == Running(23783,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,kept+1,12602],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 36 then state == Running(12602,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,kept+1],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 37 then state == Running(12603,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,kept+1],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 38 then state == Running(12604,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index,word,result,kept,kept],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 39 then state == Running(12605,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index,word,result,kept],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 40 then state == Running(12606,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index,word,result],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 41 then state == Running(12607,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index,word,result],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 42 then state == Running(12608,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index,word],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 43 then state == Running(12609,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 44 then state == Running(12611,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index,1],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 45 then state == Running(12612,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index+1],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else if id == 46 then state == Running(12615,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index+1,12391],Store(mem,out+index*32+32,result))
                                                                                                                                                                                                                                                                                                                                    else false) }
  lemma Advance0(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(0,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(1,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12484,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,0,result],mem);
    assert Fetch(code,12484) == Op(91,12485,0);
  }
  lemma Advance1(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(1,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(2,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12485,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,0,result],mem);
    assert Fetch(code,12485) == Op(144,12486,0);
  }
  lemma Advance2(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(2,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(3,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12486,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,0],mem);
    assert Fetch(code,12486) == Op(80,12487,0);
  }
  lemma Advance3(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(3,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(4,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12487,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result],mem);
    assert Fetch(code,12487) == Op(135,12488,0);
  }
  lemma Advance4(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(4,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(5,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12488,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,0],mem);
    assert Fetch(code,12488) == Op(21,12489,0);
  }
  lemma Advance5(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(5,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(6,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12489,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,1],mem);
    F.Push2(code,12489);
    assert Fetch(code,12489) == Op(97,12492,12581);
  }
  lemma Advance6(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(6,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(7,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12492,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,1,12581],mem);
    assert Fetch(code,12492) == Op(87,12493,0);
  }
  lemma Advance7(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(7,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(8,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12581,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result],mem);
    assert Fetch(code,12581) == Op(91,12582,0);
  }
  lemma Advance8(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(8,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(9,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12582,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result],mem);
    F.Push1(code,12582);
    assert Fetch(code,12582) == Op(96,12584,32);
  }
  lemma Advance9(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(9,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(10,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12584,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,32],mem);
    assert Fetch(code,12584) == Op(128,12585,0);
  }
  lemma Advance10(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(10,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(11,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12585,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,32,32],mem);
    assert Fetch(code,12585) == Op(132,12586,0);
  }
  lemma Advance11(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(11,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(12,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12586,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,32,32,index],mem);
    assert Fetch(code,12586) == Op(2,12587,0);
  }
  lemma Advance12(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(12,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(13,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12587,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,32,index*32],mem);
    assert Fetch(code,12587) == Op(136,12588,0);
  }
  lemma Advance13(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(13,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(14,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12588,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,32,index*32,out],mem);
    assert Fetch(code,12588) == Op(1,12589,0);
  }
  lemma Advance14(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(14,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(15,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12589,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,32,out+index*32],mem);
    assert Fetch(code,12589) == Op(1,12590,0);
  }
  lemma Advance15(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(15,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(16,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12590,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,out+index*32+32],mem);
    assert Fetch(code,12590) == Op(129,12591,0);
  }
  lemma Advance16(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(16,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(17,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12591,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,out+index*32+32,result],mem);
    assert Fetch(code,12591) == Op(144,12592,0);
  }
  lemma Advance17(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(17,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12592,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,result,out+index*32+32],mem);
    assert Fetch(code,12592) == Op(82,12593,0);
  }
  lemma Advance18(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(18,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12593,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result],Store(mem,out+index*32+32,result));
    assert Fetch(code,12593) == Op(132,12594,0);
  }
  lemma Advance19(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(19,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12594,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept],Store(mem,out+index*32+32,result));
    F.Push2(code,12594);
    assert Fetch(code,12594) == Op(97,12597,12602);
  }
  lemma Advance20(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(20,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12597,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602],Store(mem,out+index*32+32,result));
    assert Fetch(code,12597) == Op(129,12598,0);
  }
  lemma Advance21(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(21,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12598,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept],Store(mem,out+index*32+32,result));
    F.Push2(code,12598);
    assert Fetch(code,12598) == Op(97,12601,23760);
  }
  lemma Advance22(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(22,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12601,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,23760],Store(mem,out+index*32+32,result));
    assert Fetch(code,12601) == Op(86,12602,0);
  }
  lemma Advance23(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(23,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23760,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept],Store(mem,out+index*32+32,result));
    assert Fetch(code,23760) == Op(91,23761,0);
  }
  lemma Advance24(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(24,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23761,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept],Store(mem,out+index*32+32,result));
    assert Fetch(code,23761) == Op(95,23762,0);
  }
  lemma Advance25(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(25,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23762,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,0],Store(mem,out+index*32+32,result));
    F.Push1(code,23762);
    assert Fetch(code,23762) == Op(96,23764,1);
  }
  lemma Advance26(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(26,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23764,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,0,1],Store(mem,out+index*32+32,result));
    assert Fetch(code,23764) == Op(130,23765,0);
  }
  lemma Advance27(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(27,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23765,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,0,1,kept],Store(mem,out+index*32+32,result));
    assert Fetch(code,23765) == Op(1,23766,0);
  }
  lemma Advance28(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(28,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23766,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,0,kept+1],Store(mem,out+index*32+32,result));
    F.Push2(code,23766);
    assert Fetch(code,23766) == Op(97,23769,23777);
  }
  lemma Advance29(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(29,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23769,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,0,kept+1,23777],Store(mem,out+index*32+32,result));
    assert Fetch(code,23769) == Op(87,23770,0);
  }
  lemma Advance30(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(30,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23777,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,0],Store(mem,out+index*32+32,result));
    assert Fetch(code,23777) == Op(91,23778,0);
  }
  lemma Advance31(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(31,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(32,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23778,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,0],Store(mem,out+index*32+32,result));
    assert Fetch(code,23778) == Op(80,23779,0);
  }
  lemma Advance32(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(32,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(33,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23779,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept],Store(mem,out+index*32+32,result));
    F.Push1(code,23779);
    assert Fetch(code,23779) == Op(96,23781,1);
  }
  lemma Advance33(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(33,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(34,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23781,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept,1],Store(mem,out+index*32+32,result));
    assert Fetch(code,23781) == Op(1,23782,0);
  }
  lemma Advance34(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(34,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(35,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23782,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,12602,kept+1],Store(mem,out+index*32+32,result));
    assert Fetch(code,23782) == Op(144,23783,0);
  }
  lemma Advance35(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(35,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(36,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23783,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,kept+1,12602],Store(mem,out+index*32+32,result));
    assert Fetch(code,23783) == Op(86,23784,0);
  }
  lemma Advance36(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(36,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(37,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12602,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,kept+1],Store(mem,out+index*32+32,result));
    assert Fetch(code,12602) == Op(91,12603,0);
  }
  lemma Advance37(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(37,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(38,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12603,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,result,kept,kept+1],Store(mem,out+index*32+32,result));
    assert Fetch(code,12603) == Op(149,12604,0);
  }
  lemma Advance38(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(38,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(39,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12604,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index,word,result,kept,kept],Store(mem,out+index*32+32,result));
    assert Fetch(code,12604) == Op(80,12605,0);
  }
  lemma Advance39(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(39,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(40,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12605,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index,word,result,kept],Store(mem,out+index*32+32,result));
    assert Fetch(code,12605) == Op(80,12606,0);
  }
  lemma Advance40(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(40,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(41,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12606,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index,word,result],Store(mem,out+index*32+32,result));
    assert Fetch(code,12606) == Op(91,12607,0);
  }
  lemma Advance41(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(41,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(42,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12607,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index,word,result],Store(mem,out+index*32+32,result));
    assert Fetch(code,12607) == Op(80,12608,0);
  }
  lemma Advance42(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(42,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(43,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12608,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index,word],Store(mem,out+index*32+32,result));
    assert Fetch(code,12608) == Op(80,12609,0);
  }
  lemma Advance43(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(43,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(44,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12609,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index],Store(mem,out+index*32+32,result));
    F.Push1(code,12609);
    assert Fetch(code,12609) == Op(96,12611,1);
  }
  lemma Advance44(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(44,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(45,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12611,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index,1],Store(mem,out+index*32+32,result));
    assert Fetch(code,12611) == Op(1,12612,0);
  }
  lemma Advance45(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(45,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(46,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12612,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index+1],Store(mem,out+index*32+32,result));
    F.Push2(code,12612);
    assert Fetch(code,12612) == Op(97,12615,12391);
  }
  lemma Advance46(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(46,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(12391,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index+1],Store(mem,out+index*32+32,result))
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12615,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index+1,12391],Store(mem,out+index*32+32,result));
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
    ensures Good(40,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
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
    Advance28(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next28 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next28);trace := trace+[next28];state := next28;
    Advance29(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next29 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next29);trace := trace+[next29];state := next29;
    Advance30(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next30 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next30);trace := trace+[next30];state := next30;
    Advance31(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next31 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next31);trace := trace+[next31];state := next31;
    Advance32(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next32 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next32);trace := trace+[next32];state := next32;
    Advance33(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next33 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next33);trace := trace+[next33];state := next33;
    Advance34(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next34 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next34);trace := trace+[next34];state := next34;
    Advance35(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next35 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next35);trace := trace+[next35];state := next35;
    Advance36(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next36 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next36);trace := trace+[next36];state := next36;
    Advance37(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next37 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next37);trace := trace+[next37];state := next37;
    Advance38(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next38 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next38);trace := trace+[next38];state := next38;
    Advance39(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next39 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next39);trace := trace+[next39];state := next39;
  }
  ghost method Block2(code: seq<Byte>,initial: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(40,initial,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures state == Running(12391,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index+1],Store(mem,out+index*32+32,result)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 8 && trace[0] == initial && trace[|trace|-1] == state
  { state := initial;trace := [state];
    Advance40(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next40 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next40);trace := trace+[next40];state := next40;
    Advance41(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next41 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next41);trace := trace+[next41];state := next41;
    Advance42(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next42 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next42);trace := trace+[next42];state := next42;
    Advance43(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next43 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next43);trace := trace+[next43];state := next43;
    Advance44(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next44 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next44);trace := trace+[next44];state := next44;
    Advance45(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next45 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next45);trace := trace+[next45];state := next45;
    Advance46(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next46 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next46);trace := trace+[next46];state := next46;
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures state == Running(12391,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept+1,ptr,index+1],Store(mem,out+index*32+32,result)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 48 && trace[0] == Running(12484,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,0,result],mem) && trace[|trace|-1] == state
  { state := Running(12484,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,0,out,n,kept,ptr,index,word,0,result],mem);trace := [state];reveal Good();var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    state,part := Block1(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    state,part := Block2(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
  }
}
