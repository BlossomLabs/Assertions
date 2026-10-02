// SPDX-License-Identifier: MIT
// Generated complete physical keep result iteration, arbitrary input/result words.
include "../../scans/Execution.dfy"
module BytecodeApplyResultKeep {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted(data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word) { 0 < n < 0x800000000000000 && index < n && kept <= index && (out as nat)+32+32*n < G.Modulus() && result == 1 && |prefix| <= 1002 }
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
                                              code[12552] == 96 &&
                                              code[12553] == 32 &&
                                              code[12554] == 128 &&
                                              code[12555] == 134 &&
                                              code[12556] == 2 &&
                                              code[12557] == 136 &&
                                              code[12558] == 1 &&
                                              code[12559] == 1 &&
                                              code[12560] == 130 &&
                                              code[12561] == 144 &&
                                              code[12562] == 82 &&
                                              code[12563] == 132 &&
                                              code[12564] == 97 &&
                                              code[12565] == 49 &&
                                              code[12566] == 28 &&
                                              code[12567] == 129 &&
                                              code[12568] == 97 &&
                                              code[12569] == 92 &&
                                              code[12570] == 208 &&
                                              code[12571] == 86 &&
                                              code[12572] == 91 &&
                                              code[12573] == 149 &&
                                              code[12574] == 80 &&
                                              code[12575] == 80 &&
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
  function Destinations(): set<nat> { {12391,12545,12572,12576,12581,12606,23760,23777} }
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
                                                                                                                                                                                                                                                                                                                                    else if id == 16 then state == Running(12548,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 17 then state == Running(12551,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0,12576],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 18 then state == Running(12552,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 19 then state == Running(12554,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,32],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 20 then state == Running(12555,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,32,32],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 21 then state == Running(12556,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,32,32,kept],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 22 then state == Running(12557,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,32,kept*32],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 23 then state == Running(12558,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,32,kept*32,out],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 24 then state == Running(12559,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,32,out+kept*32],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 25 then state == Running(12560,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,out+kept*32+32],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 26 then state == Running(12561,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,out+kept*32+32,word],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 27 then state == Running(12562,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,word,out+kept*32+32],mem)
                                                                                                                                                                                                                                                                                                                                    else if id == 28 then state == Running(12563,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 29 then state == Running(12564,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 30 then state == Running(12567,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 31 then state == Running(12568,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 32 then state == Running(12571,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,23760],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 33 then state == Running(23760,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 34 then state == Running(23761,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 35 then state == Running(23762,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,0],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 36 then state == Running(23764,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,0,1],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 37 then state == Running(23765,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,0,1,kept],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 38 then state == Running(23766,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,0,kept+1],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 39 then state == Running(23769,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,0,kept+1,23777],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 40 then state == Running(23777,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,0],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 41 then state == Running(23778,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,0],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 42 then state == Running(23779,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 43 then state == Running(23781,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,1],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 44 then state == Running(23782,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept+1],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 45 then state == Running(23783,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,kept+1,12572],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 46 then state == Running(12572,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,kept+1],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 47 then state == Running(12573,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,kept+1],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 48 then state == Running(12574,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,word,result,kept,kept],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 49 then state == Running(12575,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,word,result,kept],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 50 then state == Running(12576,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,word,result],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 51 then state == Running(12577,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,word,result],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 52 then state == Running(12580,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,word,result,12606],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 53 then state == Running(12606,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,word,result],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 54 then state == Running(12607,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,word,result],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 55 then state == Running(12608,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,word],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 56 then state == Running(12609,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 57 then state == Running(12611,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,1],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 58 then state == Running(12612,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index+1],Store(mem,out+kept*32+32,word))
                                                                                                                                                                                                                                                                                                                                    else if id == 59 then state == Running(12615,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index+1,12391],Store(mem,out+kept*32+32,word))
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
    assert state == Running(12548,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0],mem);
    F.Push2(code,12548);
    assert Fetch(code,12548) == Op(97,12551,12576);
  }
  lemma Advance17(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(17,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(18,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12551,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,0,12576],mem);
    assert Fetch(code,12551) == Op(87,12552,0);
  }
  lemma Advance18(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(18,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(19,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12552,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],mem);
    F.Push1(code,12552);
    assert Fetch(code,12552) == Op(96,12554,32);
  }
  lemma Advance19(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(19,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(20,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12554,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,32],mem);
    assert Fetch(code,12554) == Op(128,12555,0);
  }
  lemma Advance20(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(20,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(21,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12555,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,32,32],mem);
    assert Fetch(code,12555) == Op(134,12556,0);
  }
  lemma Advance21(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(21,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(22,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12556,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,32,32,kept],mem);
    assert Fetch(code,12556) == Op(2,12557,0);
  }
  lemma Advance22(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(22,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(23,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12557,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,32,kept*32],mem);
    assert Fetch(code,12557) == Op(136,12558,0);
  }
  lemma Advance23(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(23,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(24,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12558,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,32,kept*32,out],mem);
    assert Fetch(code,12558) == Op(1,12559,0);
  }
  lemma Advance24(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(24,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(25,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12559,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,32,out+kept*32],mem);
    assert Fetch(code,12559) == Op(1,12560,0);
  }
  lemma Advance25(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(25,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(26,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12560,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,out+kept*32+32],mem);
    assert Fetch(code,12560) == Op(130,12561,0);
  }
  lemma Advance26(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(26,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(27,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12561,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,out+kept*32+32,word],mem);
    assert Fetch(code,12561) == Op(144,12562,0);
  }
  lemma Advance27(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(27,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(28,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12562,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,word,out+kept*32+32],mem);
    assert Fetch(code,12562) == Op(82,12563,0);
  }
  lemma Advance28(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(28,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(29,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12563,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result],Store(mem,out+kept*32+32,word));
    assert Fetch(code,12563) == Op(132,12564,0);
  }
  lemma Advance29(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(29,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(30,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12564,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept],Store(mem,out+kept*32+32,word));
    F.Push2(code,12564);
    assert Fetch(code,12564) == Op(97,12567,12572);
  }
  lemma Advance30(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(30,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(31,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12567,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572],Store(mem,out+kept*32+32,word));
    assert Fetch(code,12567) == Op(129,12568,0);
  }
  lemma Advance31(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(31,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(32,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12568,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept],Store(mem,out+kept*32+32,word));
    F.Push2(code,12568);
    assert Fetch(code,12568) == Op(97,12571,23760);
  }
  lemma Advance32(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(32,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(33,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12571,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,23760],Store(mem,out+kept*32+32,word));
    assert Fetch(code,12571) == Op(86,12572,0);
  }
  lemma Advance33(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(33,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(34,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23760,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept],Store(mem,out+kept*32+32,word));
    assert Fetch(code,23760) == Op(91,23761,0);
  }
  lemma Advance34(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(34,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(35,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23761,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept],Store(mem,out+kept*32+32,word));
    assert Fetch(code,23761) == Op(95,23762,0);
  }
  lemma Advance35(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(35,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(36,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23762,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,0],Store(mem,out+kept*32+32,word));
    F.Push1(code,23762);
    assert Fetch(code,23762) == Op(96,23764,1);
  }
  lemma Advance36(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(36,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(37,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23764,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,0,1],Store(mem,out+kept*32+32,word));
    assert Fetch(code,23764) == Op(130,23765,0);
  }
  lemma Advance37(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(37,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(38,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23765,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,0,1,kept],Store(mem,out+kept*32+32,word));
    assert Fetch(code,23765) == Op(1,23766,0);
  }
  lemma Advance38(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(38,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(39,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23766,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,0,kept+1],Store(mem,out+kept*32+32,word));
    F.Push2(code,23766);
    assert Fetch(code,23766) == Op(97,23769,23777);
  }
  lemma Advance39(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(39,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(40,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23769,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,0,kept+1,23777],Store(mem,out+kept*32+32,word));
    assert Fetch(code,23769) == Op(87,23770,0);
  }
  lemma Advance40(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(40,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(41,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23777,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,0],Store(mem,out+kept*32+32,word));
    assert Fetch(code,23777) == Op(91,23778,0);
  }
  lemma Advance41(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(41,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(42,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23778,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,0],Store(mem,out+kept*32+32,word));
    assert Fetch(code,23778) == Op(80,23779,0);
  }
  lemma Advance42(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(42,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(43,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23779,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept],Store(mem,out+kept*32+32,word));
    F.Push1(code,23779);
    assert Fetch(code,23779) == Op(96,23781,1);
  }
  lemma Advance43(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(43,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(44,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23781,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept,1],Store(mem,out+kept*32+32,word));
    assert Fetch(code,23781) == Op(1,23782,0);
  }
  lemma Advance44(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(44,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(45,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23782,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,12572,kept+1],Store(mem,out+kept*32+32,word));
    assert Fetch(code,23782) == Op(144,23783,0);
  }
  lemma Advance45(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(45,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(46,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(23783,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,kept+1,12572],Store(mem,out+kept*32+32,word));
    assert Fetch(code,23783) == Op(86,23784,0);
  }
  lemma Advance46(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(46,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(47,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12572,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,kept+1],Store(mem,out+kept*32+32,word));
    assert Fetch(code,12572) == Op(91,12573,0);
  }
  lemma Advance47(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(47,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(48,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12573,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,result,kept,kept+1],Store(mem,out+kept*32+32,word));
    assert Fetch(code,12573) == Op(149,12574,0);
  }
  lemma Advance48(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(48,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(49,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12574,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,word,result,kept,kept],Store(mem,out+kept*32+32,word));
    assert Fetch(code,12574) == Op(80,12575,0);
  }
  lemma Advance49(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(49,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(50,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12575,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,word,result,kept],Store(mem,out+kept*32+32,word));
    assert Fetch(code,12575) == Op(80,12576,0);
  }
  lemma Advance50(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(50,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(51,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12576,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,word,result],Store(mem,out+kept*32+32,word));
    assert Fetch(code,12576) == Op(91,12577,0);
  }
  lemma Advance51(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(51,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(52,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12577,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,word,result],Store(mem,out+kept*32+32,word));
    F.Push2(code,12577);
    assert Fetch(code,12577) == Op(97,12580,12606);
  }
  lemma Advance52(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(52,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(53,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12580,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,word,result,12606],Store(mem,out+kept*32+32,word));
    assert Fetch(code,12580) == Op(86,12581,0);
  }
  lemma Advance53(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(53,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(54,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12606,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,word,result],Store(mem,out+kept*32+32,word));
    assert Fetch(code,12606) == Op(91,12607,0);
  }
  lemma Advance54(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(54,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(55,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12607,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,word,result],Store(mem,out+kept*32+32,word));
    assert Fetch(code,12607) == Op(80,12608,0);
  }
  lemma Advance55(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(55,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(56,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12608,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,word],Store(mem,out+kept*32+32,word));
    assert Fetch(code,12608) == Op(80,12609,0);
  }
  lemma Advance56(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(56,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(57,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12609,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index],Store(mem,out+kept*32+32,word));
    F.Push1(code,12609);
    assert Fetch(code,12609) == Op(96,12611,1);
  }
  lemma Advance57(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(57,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(58,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12611,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index,1],Store(mem,out+kept*32+32,word));
    assert Fetch(code,12611) == Op(1,12612,0);
  }
  lemma Advance58(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(58,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); Good(59,next,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12612,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index+1],Store(mem,out+kept*32+32,word));
    F.Push2(code,12612);
    assert Fetch(code,12612) == Op(97,12615,12391);
  }
  lemma Advance59(code: seq<Byte>,state: State,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value) && Good(59,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); next == Running(12391,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index+1],Store(mem,out+kept*32+32,word))
  { hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == Running(12615,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index+1,12391],Store(mem,out+kept*32+32,word));
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
    ensures state == Running(12391,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index+1],Store(mem,out+kept*32+32,word)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 21 && trace[0] == initial && trace[|trace|-1] == state
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
    Advance47(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next47 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next47);trace := trace+[next47];state := next47;
    Advance48(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next48 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next48);trace := trace+[next48];state := next48;
    Advance49(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next49 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next49);trace := trace+[next49];state := next49;
    Advance50(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next50 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next50);trace := trace+[next50];state := next50;
    Advance51(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next51 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next51);trace := trace+[next51];state := next51;
    Advance52(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next52 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next52);trace := trace+[next52];state := next52;
    Advance53(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next53 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next53);trace := trace+[next53];state := next53;
    Advance54(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next54 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next54);trace := trace+[next54];state := next54;
    Advance55(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next55 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next55);trace := trace+[next55];state := next55;
    Advance56(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next56 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next56);trace := trace+[next56];state := next56;
    Advance57(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next57 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next57);trace := trace+[next57];state := next57;
    Advance58(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next58 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next58);trace := trace+[next58];state := next58;
    Advance59(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    var next59 := Step(code,Destinations(),state,value,data);
    E.Extend(code,Destinations(),value,data,trace,next59);trace := trace+[next59];state := next59;
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value)
    ensures state == Running(12391,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept+1,ptr,index+1],Store(mem,out+kept*32+32,word)) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == 61 && trace[0] == Running(12484,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,0,result],mem) && trace[|trace|-1] == state
  { state := Running(12484,prefix+[returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,1,out,n,kept,ptr,index,word,0,result],mem);trace := [state];reveal Good();var part: seq<State>;
    state,part := Block0(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    state,part := Block1(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
    state,part := Block2(code,state,data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value);
    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];
  }
}
